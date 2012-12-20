function doy, dd,mm,yyyy, UTC=utc, QUIET=quiet, ERR_INP=err_inp
;+
; :NAME:
;     doy
;
; :PURPOSE:
;     Returns serial day of year (same as sdy() function, 
;     but works with arrays)
;
; :SYNTAX:
;     Result = DOY( [day [,month] [,year]] [,/UTC] [,/QUIET] 
;                   [,ERR_INP=Variable] )
;
;  :PARAMS:
;    dd (IN:integer/array) range 1-31
;    mm (IN:integer/array) range 1-12
;    yyyy (IN:integer/array)
;
;
;  :KEYWORDS:
;    UTC - Set Current time to UTC (with no arguments)
;    QUIET - Quiet mode
;    ERR_INP (OUT:Variable) A named variable to store position of 
;            invalid input dates
;
; :REQUIRES:
;     valid_date.pro
;
; :EXAMPLES:
;   IDL> print,doy([31,31],[11,12],2007)
;   Warning! Unequal DD, MM, YY array length.
;         335         365
;         
;   IDL> print,doy([31,31],[11,12],[2008,2007], ERR=err)
;   Warning! Invalid dates found.
;         336         365
;   IDL> print,err
;         0      
;
; :CATEGORIES:
;     Date and Time
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  13-May-2008 15:17:12 Created. Yaswant Pradhan.
;  03-May-2011  Added UTC keyword. YP.
;                
;-

  syntax =' Result = DOY( [day [,month] [,year]] [,/UTC] [,/QUIET] )'
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;Parse input
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if n_params() lt 3 then begin
    
    if keyword_set(utc) then caldat, systime(/JULIAN,/UTC),mc,dc,yc $
    else caldat, systime(/JULIAN),mc,dc,yc
    
    if (n_elements(mm) eq 0) then mm = mc
    if (n_elements(dd) eq 0) then dd = dc
    if (n_elements(yyyy) eq 0) then yyyy = yc
        
    if ~keyword_set(quiet) then begin      
      print,'Syntax: '+syntax
      print,' Current Year='+strtrim(yyyy,2) +$
            ', Month='+strtrim(mm,2) +$
            ', Day='+strtrim(dd,2) +$
            ', DOY=', FORM='(A,$)'      
    endif
    
  endif
  
  
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;Sanity check and issue warning
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
  if (n_elements(dd) ne n_elements(mm) or n_elements(dd) ne n_elements(yyyy)) $
  then print,'Warning! Unequal DD, MM, YYYY array length.'
    
  ymd = string(yyyy, FORM='(i04)')+$
        string(mm, FORM='(i02)')+$
        string(dd, FORM='(i02)')    
  
  err_inp = -1  
  if (product(valid_date(ymd)) eq 0) then begin
    print,'Warning! Invalid dates found.'
    err_inp = where(valid_date(ymd) eq 0)
  endif
 
  
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Return result
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  res = 1+julday(mm,dd,yyyy) - julday(01,01,yyyy)
  if (n_params() lt 3 and ~keyword_set(quiet)) then print,strtrim(res,2)
  return, res

end