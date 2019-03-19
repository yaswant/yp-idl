; +
; NAME:
;       DOY2YMD
; PURPOSE:
;       Convert Year and serial day of year (0-365/6) to YearMonthDay string
;
; ARGUMENTS:
;       Year (INOUT:Value|Array)
;       DayOfYear (IN:Value|Array)
;
; KEYWORDS:
;       DMY (OUT:Variable) - Named variable to store output in 'ddmmyyyy' format
;       DAY (OUT:Variable) - Named variable to store output day strarr
;       MONTH (OUT:Variable) - Named variable to store output month strarr
;       /CURRENT - Use current Year and doY
;       STATUS (OUT:Variable) - Named variable to store status or output
;                             (1:Success, 0: Problem)
;
; SYNTAX:
;       Result = DOY2YMD(Year, DayOfYear [,DMY=variable] [,DAY=variable]
;                       [,MONTH=variable] [,STATUS=variable])
;
; EXAMPLE: Note the different results for different data array
;
;       print,doy2ymd([2009,2012],[61,39])
;       20090302 20120208
;
;       print,doy2ymd(2012,[61,39])
;       20120301 20120208
;
;       print,doy2ymd([2009,2012],61)
;       20090302 20120301
;
;   Note: Input data in Array notation requires the dimensions
;       of both Year and DoY to be equal.
;       print,doy2ymd([2009,2012],[61])
;       [doy2ymd]: Error - Unequal Year and DoY array.
;       -1
;
; REQUIRES:
;       leap_year.pro
;
; LAST MODIFIED:
;   2010-01-21 12:02:42 Created. (Yaswant Pradhan)
;   2011-02-16 Add status keyword. YP
; -

function doy2ymd, Year, DayOfYear,      $
            CURRENT=current,            $
            DMY=dmy, DAY=ds, MONTH=ms,  $
            STATUS=status


  ; Parse arguments
  def__quiet=!QUIET
  !QUIET=1  ; Suppress compiler messages

  syntax  =' Result = DOY2YMD( Year, DayOfYear | ,/CURRENT [,DMY=variable]'+$
           ' [,DAY=variable] [,MONTH=variable] [,STATUS=variable])'
  if (n_params() lt 2 and ~KEYWORD_SET(current)) then message, syntax
  if (n_params() lt 2 and KEYWORD_SET(current)) then begin
    Year      = strmid(systime(),20)
    DayOfYear = doy(/QUIET)
    print,'Returning ymd for current doy ('+STRTRIM(DayOfYear,2)+'):'
  endif

  nelY  = N_ELEMENTS(Year)
  nelD  = N_ELEMENTS(DayOfYear)

  if (nelY ne nelD) then begin
    if (SIZE(Year,/DIM) eq 0) $
    then Year = REPLICATE(Year,nelD) $
    else if (SIZE(DayOfYear,/DIM) eq 0) $
    then DayOfYear = REPLICATE(DayOfYear,nelY) $
    else begin
      print,'[doy2ymd]: Error - Unequal Year and DoY array.'
      status=(dmy=(ds=(ms= -1)))
      !QUIET=0  ; Enable compiler messages before return
      return, -1
    endelse
  endif

  ; Sanity check for Input DoY and Year and set status flag accordingly
  ; Success:1, Warning/Error:0
  status= REPLICATE(1b, nelD)
  f1    = WHERE(DayOfYear lt 0 OR DayOfYear gt 366, nf1)
  f2    = WHERE(Year lt 0 OR Year/1000. ge 10, nf2)
  f3    = WHERE(DayOfYear eq 366, nf3)

  if (nf1 gt 0) then status[f1] = 0b
  if (nf2 gt 0) then status[f2] = 0b
  if (nf3 gt 0) then if not leap_year(Year[f3]) then status[f3] = 0b


  ; Get corresponding julian day(s) and calendar dates for input Year and DoY
  jd  = julday( 1, 1, Year) + DayOfYear-1
  caldat, jd, mm, dd, yy

  ; Format Year, Month and Date if necessary
  if ARG_PRESENT(ds) then ds = string(dd, FORM='(i02)')
  if ARG_PRESENT(ms) then ms = string(mm, FORM='(i02)')

  if ARG_PRESENT(dmy) or KEYWORD_SET(dmy) then begin
    res = string(dd, FORM='(i02)') +$
          string(mm, FORM='(i02)') +$
          string(yy, FORM='(i04)')
    dmy = res
  endif else begin
    res = string(yy, FORM='(i04)') +$
          string(mm, FORM='(i02)') +$
          string(dd, FORM='(i02)')
  endelse

  !QUIET=def__quiet ; Enable original !QUIET definition

  ; Return result in YYYYMMDD format
  return, res

end
