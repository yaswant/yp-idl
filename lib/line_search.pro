;+
; :NAME:
;     line_search
;
; :PURPOSE:
;     LINE_SEARCH function returns positions of lines matching a pattern. To
;     retrun the contents of matching lines use /EXTRACT.
;
; :SYNTAX:
;     Result = line_search( array, pattern [,/EXTRACT] [,/FOLD_CASE]
;                           [,/COMPLEMENT]
;
;
;  :PARAMS:
;    array (IN:strarr) A string or string array in which to search for matches
;                     of pattern.
;    pattern (IN:string) A scalar string containing the regular expression to
;                     match.
;
;
;  :KEYWORDS:
;    /EXTRACT - Normally, LINE_SEARCH returns the index/indices of the array
;                   that matches the pattarn. Setting EXTRACT modifies this
;                   behavior to simply return the matched lines.
;    /COMPLEMENT - Returns lines which did not match the pattern
;    /FOLD_CASE - Matching is normally a case-sensitive operation. Setting
;                   FOLD_CASE performs case-insensitive matching instead.
;
; :REQUIRES:
;
;
; :EXAMPLES:
;   IDL> arr = ['Met Office', 'FitzRoy Raod', 'Exeter']
;   IDL> print, line_search(arr,'Met')
;       0
;   IDL> print, line_search(arr,'Met',/extract)
;       Met Office
;   IDL> print, line_search(arr,'Met',/extra,/complement), format='(A)'
;       FitzRoy Raod
;       Exeter
;   IDL> print, line_search(arr,'Met',/complement)
;       1           2
;
; :CATEGORIES:
;   String manipulation, Regular expressions
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  Mar 2, 2012 2:02:10 PM Created. Yaswant Pradhan.
;
;-

function line_search, array, pattern, $
          EXTRACT=extract,            $
          COMPLEMENT=complement,      $
          _EXTRA=_ex

  ; Get the positions and complementary positions of matching lines:
  pos = WHERE(STREGEX(array,pattern,/BOOLEAN, _EXTRA=_ex), $
              npos, COMPLEMENT=sop, NCOMPLEMENT=nsop)

  ; Check what to return based on complement keyword:
  x   = KEYWORD_SET(complement) ? TEMPORARY(sop) : TEMPORARY(pos)
  nx  = KEYWORD_SET(complement) ? nsop : npos

  ; Return result:
  return, KEYWORD_SET(extract) $
          ? (nx gt 0) $
            ? array[x] $
            : '' $
          : x

end
