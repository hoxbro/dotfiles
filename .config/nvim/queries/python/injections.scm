; From: https://github.com/magnuslarsen/dotfiles/blob/master/dot_config/nvim/queries/python/injections.scm
; Function calls from common SQL libraries
(expression_statement
  (call
    (attribute
      attribute: (identifier) @_attribute (#any-of? @_attribute "execute" "executemany" "executescript")
    )

    (argument_list
      (string
	(string_content) @injection.content
	(#set! injection.language "sql")
      )
    )
  )
)

; CustomJS(code=...) from Bokeh
(call
  function: (identifier) @_function (#any-of? @_function "CustomJS")
  arguments: (argument_list
    (keyword_argument
      name: (identifier) @_name (#match? @_name "code")
      value: (string
        (string_content) @injection.content
        (#set! injection.language "javascript")
      )
    )
  )
)

(call
  function: (identifier) @_function (#any-of? @_function "Panel")
  arguments: (argument_list
    (keyword_argument
      name: (identifier) @_name (#match? @_name "stylesheets")
      value: (list
        (string
          (string_content) @injection.content
          (#set! injection.language "css")
        )
      )
    )
  )
)

; Language based on variables endings
(expression_statement
  (assignment
    left: (identifier) @_left (#match? @_left "(js|JS|esm|ESM)$")
    right: (string
      (string_content) @injection.content
      (#set! injection.language "javascript")
    )
  )
)

(expression_statement
  (assignment
    left: (identifier) @_left (#match? @_left "(css|CSS|stylesheet|STYLESHEET)$")
    right: (string
      (string_content) @injection.content
      (#set! injection.language "css")
    )
  )
)

(expression_statement
  (assignment
    left: (identifier) @_left (#match? @_left "(sql|SQL)$")
    right: (string
      (string_content) @injection.content
      (#set! injection.language "sql")
    )
  )
)

(expression_statement
  (assignment
    left: (identifier) @_left (#match? @_left "(json|JSON)$")
    right: (string
      (string_content) @injection.content
      (#set! injection.language "json")
    )
  )
)

(expression_statement
  (assignment
    left: (identifier) @_left (#match? @_left "(html|HTML)$")
    right: (string
      (string_content) @injection.content
      (#set! injection.language "html")
    )
  )
)

(expression_statement
  (assignment
    left: (identifier) @_left (#match? @_left "(gql|GQL)$")
    right: (string
      (string_content) @injection.content
      (#set! injection.language "graphql")
    )
  )
)

(expression_statement
  (assignment
    left: (identifier) @_left (#match? @_left "(py|PY)$")
    right: (string
      (string_content) @injection.content
      (#set! injection.language "python")
    )
  )
)
