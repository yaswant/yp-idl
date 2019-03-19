;+
; :NAME:
;     valid_date
;
; :PURPOSE:
;     The VALID_DATE function check if given date in (YYYYMMDD format)
;     is a valid calendar date and returns 1 if true, 0 otherwise.
;
; :SYNTAX:
;     Result = valid_date( YYYYMMDD )
;
;  :PARAMS:
;    yyyymmdd (IN:String) YearMonthDay in YYYYMMDD format.
;
;
; :REQUIRES:
;
;
; :EXAMPLES:
;    IDL> print, valid_date(20090631)
;         0
;    IDL> print, valid_date(20091255)
;         0
;    IDL> print, valid_date([20080229])
;         1
;    IDL> print, valid_date([20090229])
;         0
;    IDL> print,valid_date(['20080229','20120229'])
;         1   1
;    IDL> print,valid_date([20080229,20100229,20111232])
;         1   0   0
;
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  15-Mar-2010 15:47:16 Created. Yaswant Pradhan.
;  03-May-2011 Vectorisation. YP.
;-

function valid_date, yyyymmdd

    syntax  = 'Result = valid_date( YyyyMmDd )'
    if N_PARAMS() lt 1 then message, syntax

    date  = STRTRIM(yyyymmdd, 2)
    ;if strlen(date) lt 8 then message,' Date should be in YYYYMMDD form'
    if (PRODUCT( STRLEN(date) eq 8) eq 0) then $
    message,' Date must be in YYYYMMDD form'

    iy  = FIX( STRMID(date,0,4) )
    im  = FIX( STRMID(date,4,2) )
    id  = FIX( STRMID(date,6,2) )

    jd  = JULDAY(im, id, iy)
    CALDAT, jd, m,d,y

    return,(id eq d AND im eq m AND iy eq y)

end