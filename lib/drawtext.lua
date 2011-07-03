local section = {
   text, -- a string, or array of strings
   range, -- part of string (first_column, last_column), or part of array of substrings
   format,
}

local segment = {
   -- Segment is linear section of a text
   -- A segment could be just 
   -- { head } or:
   -- { head, lines } or:
   -- { head, lines, tail } or:
   -- { head, tail }
   head_chars,
   body_lines,
   tail_chars,
}

