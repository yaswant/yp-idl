FUNCTION leap_year, Year, VERBOSE=verb

;+
; NAME:
;       leap_year
; 
; PURPOSE:
;       Returns 1 if leap year, 0 otherwise
; 
; SYNTAX:
;       Result = leap_year( [Year] [,/VERBOSE] )
; 
; ARGUMENTS:
;       Year (IN : Scalar|Array) Valid range [4716 B.C.E. to 5000000 C.E.]
; 
; KEYWORDS:
;       /VERBOSE - Prints out human readable message to console. Valid for
;                  scalar input (Year) only.
;
; EXAMPLE:
;   IDL> print, leap_yaer(2000)
;       1
;   IDL> print,leap_year(2000,/verb)
;       2000 is a leap year.
;       1
;   IDL> print,leap_year([2000,1999])
;       1   0
;
; CALLS TO:
;       None
;
; OUTPUTS:
;       Scalar or Array [1 if true, 0 otherwise]
; 
; CATEGORY:
;       Date and time
; 
; 
; -------------------------------------------------------------------------
; $Id: leap_year.pro,v 0.1 2010-02-12 18:31:11 yaswant Exp $
; leap_year.pro Yaswant Pradhan
; Last modification: 
; -------------------------------------------------------------------------
;- 

  if n_params() lt 1 then begin
    caldat, systime(/JULIAN), Month, Day, Year
    print,'  Current year: ',strtrim(Year,2)
  endif  

; 366 days in a leap year, that makes lastday - firstday = 365
  ret = julday(12,31,Year)-julday(1,1,Year) eq 365

  if keyword_set(verb) and n_elements(Year) eq 1 then $
  print, strtrim(Year,2)+' is '+string((ret eq 1) ? 'a leap' : 'not a leap')+' year.'
  
  return, ret
  
END
