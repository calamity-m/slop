# Java Launch Configs and JDK Selection

## Detection

Treat the repo as Java when it has `pom.xml`, `build.gradle`, `build.gradle.kts`, `.java` sources, `.java-version`, `.sdkmanrc`, or requested Java files. Inspect:

- Build tool: Maven, Gradle, or plain Java
- Main classes under `src/main/java`
- Required Java version from repo metadata
- Existing `.vscode/settings.json` Java runtime config

## Pick the Java Version

Determine the required version in this priority order:

1. Explicit repo files: `.java-version`, `.sdkmanrc`, `.tool-versions`, `mise.toml`
2. Gradle toolchain:
   - `java { toolchain { languageVersion = JavaLanguageVersion.of(<n>) } }`
   - `sourceCompatibility` / `targetCompatibility`
3. Maven compiler config:
   - `maven.compiler.release`
   - `maven.compiler.source` / `maven.compiler.target`
   - `maven-toolchains-plugin`
4. Framework/runtime constraints documented in README or CI
5. Installed default JDK if the project does not specify a version

Find installed JDKs without guessing a path:

- Check `JAVA_HOME`
- Check `mise where java`, `asdf where java`, and SDKMAN candidates when those tools/files are present
- Check common local install roots such as `/usr/lib/jvm`, `/Library/Java/JavaVirtualMachines`, and Windows JDK install directories only when running on that OS

If multiple installed JDKs match, choose the newest matching feature version unless the repo pins an exact distribution/path.

## Where to Put JDK Choice

Prefer repository-level runtime mapping in `.vscode/settings.json` when the project itself requires a JDK version and the path can be expressed portably enough:

```jsonc
{
  "java.configuration.runtimes": [
    {
      "name": "JavaSE-<version>",
      "path": "${env:JAVA_HOME}",
      "default": true
    }
  ]
}
```

Use a direct launch setting only for a one-off machine-specific debug request. If the Java debugger version in use supports `javaExec`, it can point at the selected `java` binary:

```jsonc
{
  "name": "Debug Java main",
  "type": "java",
  "request": "launch",
  "mainClass": "<fully.qualified.MainClass>",
  "projectName": "<project-name>",
  "javaExec": "<path-to-java>"
}
```

If unsure whether `javaExec` is supported in the user's installed Java debugger, avoid writing it and use `java.configuration.runtimes` instead.

## Launch Patterns

Maven or Gradle project:

```jsonc
{
  "name": "Debug Java main",
  "type": "java",
  "request": "launch",
  "mainClass": "<fully.qualified.MainClass>",
  "projectName": "<project-name>",
  "cwd": "${workspaceFolder}"
}
```

Plain single-file Java:

```jsonc
{
  "name": "Debug current Java file",
  "type": "java",
  "request": "launch",
  "mainClass": "${file}"
}
```

## Notes

- Do not commit a developer's absolute JDK path unless the user explicitly wants a local-only workspace config.
- If using `${env:JAVA_HOME}`, state that the chosen terminal/editor environment must set it to the repo-required JDK.
- For Gradle, verify with `./gradlew testClasses` or `./gradlew classes`; for Maven, verify with `mvn test -DskipTests` or `mvn -q -DskipTests compile`.
