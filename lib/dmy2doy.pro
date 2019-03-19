function dmy2doy, Day, Month, Year
;+
; :NAME:
;     dmy2doy
;
; :PURPOSE:
;     Get serial day of year given day, month and year values
;
; :SYNTAX:
;     Result = dmy2doy( Day, Month, Year )
;
;  :PARAMS:
;    Day  (IN:Value) Valid Day number
;    Month(IN:Value) Valid Month number
;    Year (IN:Value) Valid Year number
;
; :REQUIRES:
;   IDL(v6.4 and above) Advanced Math and Stats license 
;
; :EXAMPLES:
;   IDL> print,dmy2doy(23,6,1987)
;        174
;
; :CATEGORIES:
;     Date and Time
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  16-Jun-2011 11:20:33 Created. Yaswant Pradhan.
;
;-

  syntax = 'Result = dmy2doy( Day, Month, Year )'

  if (N_PARAMS() lt 3) then begin
    print, syntax
    print,'** WARNING! Returning DOY for current date **'
    CALDAT, JULDAY(), Month, Day, Year
  endif

  return, FIX(1 + IMSL_DATETODAYS(Day,Month,Year) - IMSL_DATETODAYS(1,1,Year))
  

end