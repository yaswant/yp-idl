function capitalise, InString
;+
; :NAME:
;    	capitalise (note the UK English convention)
;
; :PURPOSE:
;       The CAPITALISE function returns a copy of String with frst letter of 
;       each word converted to upper case. All letters except the first in 
;       each word converted to lower case. E.g., 
;       "tHis is A TEST" becomes "This Is A Test"
;
;
; :SYNTAX:
;       Result = capitalise(String) 
;
; :PARAMS:
;    InString (in:string) The string to be converted. If this argument is not 
;               a string, it is converted using IDL's default formatting rules.
;               If it is an array, the result is an array with the same 
;               structure.
;
; :REQUIRES:
;       None.
;
; :EXAMPLES:
;       print, capitalise(['tHis is A TEST'])
;       This Is A Test
;
; :CATEGORIES:
;       String manipulation
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Sep 19, 2012 2:11:27 PM Created. Yaswant Pradhan.
;
;-

InString= STRLOWCASE(InString)
nElem   = N_ELEMENTS(InString)
outStr  = STRARR(nElem)
 
for i=0,nElem-1 do begin
    thisString = InString[i]
    pos = STRSPLIT(thisString,COUNT=nWord)
    caps= STRUPCASE(STRMID(thisString,pos,1))
    for j=0,nWord-1 do begin
        STRPUT, thisString, caps[j], pos[j]
    endfor
    outStr[i] = thisString
endfor

return, outStr

end