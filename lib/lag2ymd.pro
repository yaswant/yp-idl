;+
; NAME:
;     lag2ymd
;
; PURPOSE:
;     Returns the lapsed Year, Month, Day, Hour, Minute, Seconds from current
;       (or optionally given) date for given lapse time array (in days)
;
; SYNTAX:
;     Result = LAG2YMD( Lag [,YEAR=value] [,MONTH=value] [,DAY=value]
;                       [,HOUR=value] [,MINUTE=value] [,SECOND=value])
;
; ARGUMENTS:
;     Lag (IN : Array) - Input lag array (lapse days from current or given YMDhms)
;
; KEYWORDS:
;     YEAR  (IN : Value) Year from which the lad/lapse is considered
;     MONTH (IN : Value) Month from which the lad/lapse is considered
;     DAY   (IN : Value) Day from which the lad/lapse is considered
;     HOUR  (IN : Value) Hour from which the lad/lapse is considered
;     MINUTE(IN : Value) Minute from which the lad/lapse is considered
;     SECOND(IN : Value) Seconds from which the lad/lapse is considered
; EXAMPLE:
; IDL> lag = [ 1, 20, 300]
; IDL> help, lag2ymd( lag ), /struct
; ** Structure <82284fc>, 6 tags, length=84, data length=84, refs=1:
;    YEAR            LONG      Array[3]
;    MONTH           LONG      Array[3]
;    DAY             LONG      Array[3]
;    HOUR            LONG      Array[3]
;    MINUTE          LONG      Array[3]
;    SECOND          DOUBLE    Array[3]
;
; $Id: LAG2YMD.pro, v1.0 30/06/2009 13:56 yaswant Exp $
; LAG2YMD.pro Yaswant Pradhan (c) Crown copyrights Met Office
;   Last modification:
;-

FUNCTION lag2ymd, lag, YEAR=y, MONTH=m, DAY=d, HOUR=hr, MINUTE=mn, SECOND=se

    if( n_params() lt 1 ) then message, $
        'Result = LAG2YMD( Lag [,YEAR=value] [,MONTH=value] [,DAY=value] '+$
        '[,HOUR=value] [,MINUTE=value] [,SECOND=value])'

    caldat, systime(/julian), mc, dc, yc, hrc, mnc, sec
    year  = is_defined(y) ? y : yc
    mont  = is_defined(m) ? m : mc
    day   = is_defined(d) ? d : dc
    hour  = is_defined(hr) ? hr : hrc
    minu  = is_defined(mn) ? mn : mnc
    seco  = is_defined(se) ? se : sec

    jd    = julday( mont, day, year, hour, minu, seco )
    caldat, jd-lag, mo, da, yr, hr, mn, se

    return, {year:yr, month:mo, day:da, hour:hr, minute:mn, second:se}

END
