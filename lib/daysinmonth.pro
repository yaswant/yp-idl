;+
; :NAME:
;       daysinmonth
;
; :PURPOSE:
;       Return maximum number of days in a month of a particular year.
;       If no argument is passed, DAYSINMONTH returns the result for the
;       month from system date & time
;
; :SYNTAX:
;       Result = daysinmonth( [month] [,year])
;
; :PARAMS:
;    month (in:integer) optional: Month in Year (1-12)
;    year (in:integer) optional: Year in CCYY format
;
; :REQUIRES:
;       leap_year.pro
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  04-Mar-2013 12:20:52 Created. Yaswant Pradhan.
;
;-

function daysinmonth, month, year

    caldat, SYSTIME(/JULIAN), m,d,y
    month   = KEYWORD_SET(month) ? month : m
    year    = KEYWORD_SET(year) ? year : y
    month   = STRING(month, FORM='(I0)')


    opt = TOTAL(STRMATCH(['4','6','9','11'],month)) gt 0  ; 30-days if true
    if (month eq 2) then opt = 2   ; 28 or 29 days


    case opt of
        1: result = 30
        2: result = leap_year(year) ? 29 : 28
        else: result = 31
    endcase

    return, result
end
