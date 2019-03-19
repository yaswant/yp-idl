;+
; :NAME:
;     et2dt
;
; :PURPOSE:
;     Transform Elapsed Time to Calendar Date Time. The result is an
;     anonymous structure with 6 members namely,
;     {YEAR, MONTH, DAY, HOUR, MINUTE, SECOND}
;
; :SYNTAX:
;     Result = et2dt( elapsed_seconds [,BASE_TIME=value|vector]
;                     [,MASK_VALUE=Value][,/QUIET])
;
;  :PARAMS:
;    elapsed_seconds (IN:Array) Elapsed seconds from a base time;
;             dafault base_time is [1993,1,1,0,0,0]
;
;
;  :KEYWORDS:
;    BASE_TIME (IN:Array) A 6 element array containing
;             [year, month, day, hour, minute, second] in order.
;    MASK_VALUE (IN:Value) Elapsed second value to be masked
;             (e.g., -1.07374e+09); the result in the output structure
;             will be set in form of -9999(for year) and -99 (for other tags)
;    /QUIET Quiet mode.
;
; :REQUIRES:
;
;
; :EXAMPLES:
;     IDL> et = 4.83266e+08
;     IDL> print, et2dt(et)
;         Warning: ET2DT base_time set to {1993,01,01,0,0,0}
;         {    2008       4      25       8      33       4.0000346}
;     IDL> print, et2dt(et,BASE_TIME=[1970, 1, 1, 0, 0, 0])
;         {    1985       4      25       8      33       4.0000346}
;     IDL> print, et2dt(et,BASE_TIME=[1970, 1, 1])
;         {    1985       4      25       8      33       4}
;     IDL> print, et2dt(et,BASE_TIME=[1980])
;   {    1995       4      25       8      33       4}
;
;
; :CATEGORIES:
;   Date and Time
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  13-May-2008 14:27:50 Created. Yaswant Pradhan.
;  06-Jun-2008 Updated document. YP.
;
;-
function et2dt, elapsed_seconds, BASE_TIME=base_time, $
                MASK_VALUE=mask_value, QUIET=quiet

  ; Parse input
  syntax ='Result = et2dt(elapsed_time [,BASE_TIME=value|vector] '+$
          '[,MASK_VALUE=Value] [,/QUIET])'
  if n_params() lt 1 then message,syntax

  bt = keyword_set(base_time)
  b_year  = ( bt and n_elements(base_time) gt 0 ) ? base_time[0] : 1993
  b_month = ( bt and n_elements(base_time) gt 1 ) ? base_time[1] : 1
  b_day   = ( bt and n_elements(base_time) gt 2 ) ? base_time[2] : 1
  b_hour  = ( bt and n_elements(base_time) gt 3 ) ? base_time[3] : 0
  b_min   = ( bt and n_elements(base_time) gt 4 ) ? base_time[4] : 0
  b_sec   = ( bt and n_elements(base_time) gt 5 ) ? base_time[5] : 0
  if not bt and not keyword_set(quiet) then $
  print,'** Warning: ET2DT base_time set to {1993,01,01,0,0,0} **'

  ; Calculate Julian day and convert to Calendar date and time
  jd = julday(b_month, b_day, b_year, b_hour, b_min, b_sec) +$
       elapsed_seconds/86400.D0

  caldat, jd, mm, dd, yyyy, H, M, S

  n_p = 0
  if( n_elements(mask_value) ne 0 OR arg_present(mask_value) ) then begin
    p  = where( elapsed_seconds eq mask_value, n_p )

    if( n_p gt 0 ) then begin
      yyyy(p) = -9999
      mm[p] =( dd[p] =( H[p] =( M[p] =( S[p] = -99 ))))
    endif

  endif


  ; Output structure
  ret = { $
    year  : fix(yyyy), $
    month : fix(mm), $
    day   : fix(dd), $
    hour  : fix(H), $
    minute: fix(M), $
    second: fix(S)  $
  }

  return, ret

end
