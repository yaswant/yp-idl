;+
; :NAME:
;     dt2et
;
; :PURPOSE:
;     Transform Calendar Date Time to Elapsed Time
;
; :SYNTAX:
;     Result = dt2et( in_dt [,BASE_TIME=value|vector] [,/QUIET])
;
;  :PARAMS:
;    in_dt(IN:Structure) Calendar date time structure containing
;           members: YEAR, MONTH, DAY, HOUR, MINUTE, SECOND.
;
;  :KEYWORDS:
;    BASE_TIME (IN:Array) A 6 element array in the order
;           [year, month, day, hour, minute, second]
;    /QUIET Quiet mode.
;
; :REQUIRES:
;     None
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;     Date and Time
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  13-May-2008 14:27:26 Created. Yaswant Pradhan/Malcolm Brroks.
;  05-Nov-2008 Modified from et2dt. Malcolm Brooks.
;
;-

function dt2et, in_dt, BASE_TIME=base_time, QUIET=quiet

  ; Parse input
  syntax =' Result = dt2et(in_dt [,BASE_TIME=value|vector] [,/QUIET])'
  if n_params() lt 1 then message, syntax

  bt = keyword_set(base_time)
  b_year  = ( bt and n_elements(base_time) gt 0 ) ? base_time[0] : 1993
  b_month = ( bt and n_elements(base_time) gt 1 ) ? base_time[1] : 1
  b_day   = ( bt and n_elements(base_time) gt 2 ) ? base_time[2] : 1
  b_hour  = ( bt and n_elements(base_time) gt 3 ) ? base_time[3] : 0
  b_min   = ( bt and n_elements(base_time) gt 4 ) ? base_time[4] : 0
  b_sec   = ( bt and n_elements(base_time) gt 5 ) ? base_time[5] : 0
  if not bt and not keyword_set(quiet) then $
  print,'** Warning: DT2ET base_time set to [1993,01,01,0,0,0] **'

  ; Calculate Julian day and convert to Calendar date and time
  jd_base = julday(b_month, b_day, b_year, b_hour, b_min, b_sec)
  jd_in_dt = julday(in_dt.month, in_dt.day, in_dt.year, $
                    in_dt.hour, in_dt.minute, in_dt.second)

  ; Output the elapsed seconds since base time:
  et = (jd_in_dt - jd_base) * 24.*60.^2

  return, et

end
