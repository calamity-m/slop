; inherits: gotmpl
; NOTE: This should inject YAML highlighting into Helm template text regions.
; Query lookup was verified, but visual template highlighting was not observed
; locally. If it still does not work in normal Neovim, this may be worth
; raising upstream with tree-sitter-manager.nvim or helm-ls.nvim.

((text) @injection.content
  (#set! injection.language "yaml")
  (#set! injection.combined))

(function_call
  function: (identifier) @_function
  arguments: (argument_list
    .
    (interpreted_string_literal) @injection.content)
  (#any-of? @_function
    "regexMatch" "mustRegexMatch" "regexFindAll" "mustRegexFinDall" "regexFind" "mustRegexFind"
    "regexReplaceAll" "mustRegexReplaceAll" "regexReplaceAllLiteral" "mustRegexReplaceAllLiteral"
    "regexSplit" "mustRegexSplit")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "regex"))

(function_call
  function: (identifier) @_function
  arguments: (argument_list
    .
    (interpreted_string_literal) @injection.content)
  (#any-of? @_function "fromYaml" "fromYamlArray")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "yaml"))

(function_call
  function: (identifier) @_function
  arguments: (argument_list
    .
    (interpreted_string_literal) @injection.content)
  (#any-of? @_function "fromJson" "fromJsonArray")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "json"))
