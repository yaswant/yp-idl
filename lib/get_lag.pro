FUNCTION get_lag, YEAR=year, MONTH=month, DAY=day, SDY=sd, BASE_TIME=btm
;+
; :NAME:
;    	get_lag
;
; :PURPOSE:
;     Get number of days lapsed from a given date to current date.
;     Default result is 0, i.e., laf from current year,month and day.
;
; :SYNTAX:
;     Result = GET_LAG(Year=value [[,Month=value ,Day=value] | [,SDY=Value]
;                      BASE_TIME=String )
;
;
;  :KEYWORDS:
;    YEAR (IN:Array) Year array; def current year
;    MONTH (IN:Array) Month array; def current month
;    DAY (IN:Array) Day array; def current day
;    SDY (IN:Value) Serial day of year
;    BASE_TIME (IN:string) The date (yyyymmdd), insteadt of current date, 
;           until wich the lags to be count.
;
; :REQUIRES:
;     is_defined.pro
;
; :EXAMPLES:
;   On 21 May 2009
;   IDL> print,get_lag(Year=2008, month=1, day=1)
;         506
;   IDL> print,get_lag(Year=2008, sdy=1)
;         506

;
; :CATEGORIES:
;     Date and Time
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  30-Jun-2009 13:56:51 Created. Yaswant Pradhan.
;  16-Jul-2009 Added BASE_TIME keyword. YP
;-

  !quiet = 1

  print,' Negative lag meaning number of days ahead'
  if( keyword_set(btm) ) then begin    
    bt  = strtrim(string(btm),2)
    cda = fix(strmid(bt,6,2))
    cmo = fix(strmid(bt,4,2))
    cyr = fix(strmid(bt,0,4))
  endif else begin
    caldat, systime(/julian), cmo, cda, cyr
  endelse  
  
  year  = is_defined(year)  ? year  : cyr
  month = is_defined(month) ? month : cmo
  day   = is_defined(day)   ? day   : cda
  
  if( keyword_set(sd) ) then begin  
  
    t = timegen( sd, START=julday(1,1,year) )
    caldat, t[sd-1], month, day, year      
    return, round(julday(cmo,cda,cyr)-julday(month,day,year))
  
  endif else $
  return, round(julday(cmo,cda,cyr)-julday(month,day,year))
  

END
