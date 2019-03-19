;+
; :NAME:
;       julian2weekday
;
; :PURPOSE:
;     Converts julian day(s) to Week day(s)
;
; :SYNTAX:
;     Result = julian2weekday( [JulianDay] [,/LONG] )
;
;    :PARAMS:
;    JulianDay (IN:Array) Double precision Julian day array
;
;
;  :KEYWORDS:
;    /LONG  Return output in long format (Monday, Tuesday, ...)
;           def (Mon, Tue, Wed,...)
;
; :REQUIRES:
;     None
;
; :EXAMPLES:
;     IDL> print,julian2weekday(julday(10,14,2011,12,0,0),/long)
;     Friday
;
;     IDL> print,julian2weekday(julday(10,14,2011,12,0,0))
;     Fri
;   On 14/10/2011:
;     IDL> print,julian2weekday(replicate(systime(/jul),3))
;     Fri Fri Fri
;
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  14-Oct-2011 17:33:59 Created. Yaswant Pradhan.
;
;-

function julian2weekday, JulianDay, LONG=long

    ; Parse argument:
    if (N_PARAMS() lt 1) then begin
        message,'Result = julian2weekday( [JulianDay] [,/LONG] )' + $
            string(10b)+'-- Returning result for Today --',/CONTINUE,/NOPREFIX

        JulianDay = SYSTIME(/JULIAN)
    endif

    fmt = KEYWORD_SET(long) ? '(C(CDwA0))' : '(C(CDwA))'

    ; Return result:
    return, STRING(JulianDay, FORMAT=fmt)

end
