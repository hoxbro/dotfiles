(assignment_statement
  (variable_list
    name: (identifier) @_left (#match? @_left "query$"))
  (expression_list
    value: (string
     (string_content) @injection.content
     (#set! injection.language "query"))
    )
  )
