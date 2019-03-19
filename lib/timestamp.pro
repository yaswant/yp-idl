;+
; :NAME:
;       TimeStamp
;
; :PURPOSE:
;     The TimeStamp function returns the current system (or UTC) time
;     in nice hh:mm:dd format
;
; :SYNTAX:
;     Result = TimeStamp( [,/UTC] [,/TIC] [,/TOC] [,/SHORT] [,/DATE] [,/ISO])
;
;
;  :KEYWORDS:
;    UTC - Return UTC time
;    TIC - Marks Initial time
;    TOC - Prints Time lapsed from TIC
;    SHORT - Result in short hh:mm format
;    DATE - Adds date to time stamp
;    ISO - ISO8601 format (yyyy-mm-ddThh:mn:ssZ)
;
;
; :REQUIRES:
;    tic.pro
;    toc.pro
;
; :EXAMPLES:
;    IDL> print, TimeStamp()
;         16:05:01
;    IDL> print, TimeStamp(/UTC)
;         15:05:07
;    IDL> print, TimeStamp(/UTC,/SHORT)
;         15:05
;    IDL> print, TimeStamp(/UTC,/tic)
;         15:05:32
;    IDL> print, TimeStamp(/UTC,/toc)
;         Elapsed time: 00:00:03.17
;         15:05:35
;
;
; :CATEGORIES:
;     Date and Time
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  06-May-2011 16:00:04 Created. Yaswant Pradhan.
;  06-Oct-2011 Add date keyword. YP.
;  26-Nov-2012 Add ISO keyword. YP.
;-

function TimeStamp, UTC=utc, TIC=tic, TOC=toc, SHORT=short, DATE=date, ISO=iso

    date_fmt = "(2(i02,'.'),i04)"
    iso_fmt = KEYWORD_SET(iso)
    if iso_fmt then begin
        utc = 1b
        date_fmt = "(i04,2('-',i02))"
    endif

    caldat, (KEYWORD_SET(utc) ? SYSTIME(/JULIAN,/UTC) : SYSTIME(/JULIAN)), $
        month, day, year, hour, minute, second

    if KEYWORD_SET(tic) then tic
    if KEYWORD_SET(toc) then toc

    time  = KEYWORD_SET(short) $
          ? STRJOIN(STRING([hour,minute],FORM='(i02)'),':') $
          : STRJOIN(STRING([hour,minute,second],FORM='(i02)'),':')

    if KEYWORD_SET(date) then $
    time = iso_fmt ? STRING([year,month,day],FORM=date_fmt)+'T'+time $
               : STRING([day,month,year],FORM="(2(i02,'.'),i04)") +' '+ time

    return, KEYWORD_SET(utc) ? time+'Z' : time

end
