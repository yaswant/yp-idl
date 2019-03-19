;+
; :NAME:
;       shave
;
; :PURPOSE:
;       Trim a number with n-character wide. white spaces are removed from
;       both sides of the string first. useful for formatted printing.
;
; :SYNTAX:
;       Result = shave( number [,length])
;
; :PARAMS:
;    number (in:value) input number (number is converted to string) to be
;                      shaved
;    length (in:value) width of the desired output
;
; :REQUIRES:
;    None
;
; :EXAMPLES:
;    IDL> help, shave(102.8921, 3)
;    <Expression>    STRING    = '102'
;
; :CATEGORIES:
;       string formatting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Sep 4, 2012 1:51:46 PM Created. Yaswant Pradhan.
;
;-

function shave, number, length
    if (N_PARAMS() lt 1) then message, 'Result = shave(number [,length])'

    case SIZE(number,/TYPE) of
        4:    tmp = STRTRIM(STRING(number,FORM='(f0)'),2)
        5:    tmp = STRTRIM(STRING(number,FORM='(d0)'),2)
        8:    tmp = STRTRIM(STRING(number,FORM='(d0)'),2)
        else: tmp = STRTRIM(number,2)
    endcase

    length = (N_PARAMS() eq 2) ? length : STRLEN(tmp[0])

    return, STRMID(tmp, 0,length)
end