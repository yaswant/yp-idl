;+
; :NAME:
;     strrev
;
; :PURPOSE:
;     The STRREV function reverses string or string array.
;
; :SYNTAX:
;     Result = STRREV( StringExpression [,/REVERSE_ARRAY] )
;
;  :PARAMS:
;    StringExpression (IN:String) A string or string array which to be reversed
;
;
;  :KEYWORDS:
;    /REVERSE_ARRAY - Reverse the order of the array too
;    TRIM (IN:Value) - Trim empty spaces from input string expression;
;                      0: trailing blanks, 1: leading blanks, 2: from both sides
;                      (See IDL strtrim)
;
; :REQUIRES:
;     none
;
; :EXAMPLES:
; IDL>  x=['qwerty', 'asdf','zxcvbnm']
; IDL>  print, strrev(x)
;         ytrewq fdsa mnbvcxz
; IDL>  print, strrev(x,/rev)
;         mnbvcxz fdsa ytrewq
;
; Note (1) no effects of on single character array
;   IDL> print,strrev(['a','b','c','d','e'])
;         a b c d e
;   IDL> print,strrev(['a','b','c','d','e'],/rev)
;         e d c b a
;
; However,
;   IDL> print,strrev(['a','b','c','d','ef'])
;         a b c d fe
;   IDL> print,strrev(['a','b','c','d','ef'],/rev)
;         fe d c b a
;
; Note (2) effect of null string on single character array
;   IDL> print,strrev(['','a','b','c','d','e'])
;         edcba
;
; :CATEGORIES:
;   String manipulation
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  02-Sep-2009 12:22:34 Created. Yaswant Pradhan.
;  10-Jun-2011 Check for single character arrays. YP.
;
;-
function strrev, StringExpression, REVERSE_ARRAY=reverse_array, TRIM=trim


; Convert the input values to strings and remove any white spaces
  Array = KEYWORD_SET(trim) ? STRTRIM( StringExpression,trim ) : $
                              StringExpression
  char1 = (PRODUCT(STRLEN(Array)) eq 1)

; Check for presence of mull or empty strings
  if (TOTAL(STRLEN(Array) eq 0 or STRMATCH(Array,' ')) ne 0) then $
  print,' ** WARNING: Null/Blank string present in input Array ** '

; Reverse array if length of at least one member is more than 1
  rev_str = char1 ? (STRMID(Array,INDGEN(MAX(STRLEN(Array[*]))),1)) : $
            STRJOIN( reverse(STRMID(Array,INDGEN(MAX(STRLEN(Array[*]))),1)) )

  return, KEYWORD_SET(reverse_array) and not char1 ? reverse(rev_str) : rev_str

end
