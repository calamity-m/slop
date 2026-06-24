# Run revdiff and copy any saved annotations to the X clipboard.
revdiff-clip() {
  local tmp revdiff_status xclip_status

  tmp=$(mktemp) || return $?
  revdiff -o "$tmp" "$@"
  revdiff_status=$?

  if [[ -s "$tmp" ]]; then
    xclip -selection clipboard <"$tmp"
    xclip_status=$?
    if [[ $xclip_status -eq 0 ]]; then
      printf 'revdiff annotations copied to clipboard\n' >&2
    else
      printf 'revdiff annotations were saved, but xclip failed\n' >&2
      rm -f "$tmp"
      return "$xclip_status"
    fi
  else
    printf 'revdiff produced no annotations\n' >&2
  fi

  rm -f "$tmp"
  return "$revdiff_status"
}
