#!/usr/bin/env python3

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path


def usage() -> int:
    print("Usage: validate-xml.py <diagram.xml>", file=sys.stderr)
    return 1


def load_root(xml_path: Path) -> ET.Element:
    text = xml_path.read_text(encoding="utf-8")
    return ET.fromstring(text)


def graph_models(root: ET.Element) -> list[tuple[str, ET.Element]]:
    if root.tag == "mxGraphModel":
        return [("diagram-1", root)]
    if root.tag != "mxfile":
        raise ValueError("root element must be mxGraphModel or mxfile")

    models: list[tuple[str, ET.Element]] = []
    for index, diagram in enumerate(root.findall("diagram"), start=1):
        model = diagram.find("mxGraphModel")
        if model is None:
            raise ValueError(f"diagram {index} does not contain mxGraphModel")
        models.append((diagram.get("id") or f"diagram-{index}", model))

    if not models:
        raise ValueError("mxfile does not contain any diagram elements")

    return models


def effective_cell(child: ET.Element) -> tuple[str | None, ET.Element | None]:
    if child.tag == "mxCell":
        return child.get("id"), child
    if child.tag in {"object", "UserObject"}:
        return child.get("id"), child.find("mxCell")
    return None, None


def validate_model(name: str, model: ET.Element) -> list[str]:
    errors: list[str] = []
    root = model.find("root")
    if root is None:
        return [f"{name}: missing root element"]

    seen_ids: set[str] = set()

    for child in list(root):
        cell_id, cell = effective_cell(child)
        if cell is None:
            errors.append(f"{name}: unsupported root child <{child.tag}>")
            continue
        if not cell_id:
            errors.append(f"{name}: top-level <{child.tag}> is missing an id")
            continue
        if cell_id in seen_ids:
            errors.append(f"{name}: duplicate id {cell_id!r}")
            continue
        seen_ids.add(cell_id)

        if cell_id == "0" and cell.get("parent") is not None:
            errors.append(f"{name}: structural cell '0' must not have a parent")
        if cell_id == "1" and cell.get("parent") != "0":
            errors.append(f"{name}: structural cell '1' must have parent='0'")
        if cell_id != "0" and cell.get("parent") is None:
            errors.append(f"{name}: cell {cell_id!r} is missing a parent")

        is_vertex = cell.get("vertex") == "1"
        is_edge = cell.get("edge") == "1"
        if is_vertex and is_edge:
            errors.append(f"{name}: cell {cell_id!r} cannot be both vertex and edge")

        geometry = cell.find("mxGeometry")
        if is_vertex and geometry is None:
            errors.append(f"{name}: vertex {cell_id!r} is missing mxGeometry")
        if is_vertex and geometry is not None:
            if geometry.get("as") != "geometry":
                errors.append(f"{name}: vertex {cell_id!r} must set as='geometry'")
            for attr in ("x", "y", "width", "height"):
                if geometry.get(attr) is None:
                    errors.append(f"{name}: vertex {cell_id!r} is missing geometry attribute {attr!r}")
        if is_edge:
            if geometry is None:
                errors.append(f"{name}: edge {cell_id!r} is missing mxGeometry")
            else:
                if geometry.get("relative") != "1":
                    errors.append(f"{name}: edge {cell_id!r} must set relative='1'")
                if geometry.get("as") != "geometry":
                    errors.append(f"{name}: edge {cell_id!r} must set as='geometry'")

    if "0" not in seen_ids:
        errors.append(f"{name}: missing structural cell '0'")
    if "1" not in seen_ids:
        errors.append(f"{name}: missing structural cell '1'")

    return errors


def wrap_for_schema(root: ET.Element) -> str:
    if root.tag == "mxfile":
        return ET.tostring(root, encoding="unicode")

    wrapped_root = ET.fromstring(ET.tostring(root, encoding="unicode"))
    mxfile = ET.Element("mxfile", host="codex", compressed="false")
    diagram = ET.SubElement(mxfile, "diagram", id="page-1", name="Page-1")
    diagram.append(wrapped_root)
    xml_body = ET.tostring(mxfile, encoding="unicode")
    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" + xml_body


def run_schema_validation(root: ET.Element, xsd_path: Path) -> list[str]:
    xmllint = shutil.which("xmllint")
    if not xmllint:
        return ["warning: xmllint not found; skipped XSD validation"]

    xml_text = wrap_for_schema(root)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".xml", delete=False) as handle:
        handle.write(xml_text)
        temp_path = Path(handle.name)

    try:
        result = subprocess.run(
            [xmllint, "--noout", "--schema", str(xsd_path), str(temp_path)],
            capture_output=True,
            text=True,
            check=False,
        )
    finally:
        temp_path.unlink(missing_ok=True)

    if result.returncode == 0:
        return []

    details = result.stderr.strip() or result.stdout.strip() or "schema validation failed"
    return [f"schema: {details}"]


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        return usage()

    xml_path = Path(argv[1]).expanduser().resolve()
    if not xml_path.exists():
        print(f"error: file not found: {xml_path}", file=sys.stderr)
        return 1

    try:
        root = load_root(xml_path)
        models = graph_models(root)
    except (ET.ParseError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    errors: list[str] = []
    for name, model in models:
        errors.extend(validate_model(name, model))

    xsd_path = Path(__file__).resolve().parent.parent / "references" / "mxfile.xsd"
    schema_messages = run_schema_validation(root, xsd_path)
    schema_errors = [msg for msg in schema_messages if not msg.startswith("warning:")]
    warnings = [msg for msg in schema_messages if msg.startswith("warning:")]
    errors.extend(schema_errors)

    if errors:
        for message in errors:
            print(f"error: {message}", file=sys.stderr)
        for message in warnings:
            print(message, file=sys.stderr)
        return 1

    print(f"ok: {xml_path.name} passed structural validation for {len(models)} diagram(s)")
    for message in warnings:
        print(message, file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
