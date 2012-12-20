pro toc, t1, HOURS=hours, MINUTES=minutes, SECONDS=seconds, $
    GET=res, QUIET=quiet
;+
; :NAME:
;    	toc
;
; :PURPOSE:
;     Measure elapsed time using stopwatch timer.
;     tic starts a stopwatch timer. 
;     toc prints or stores the elapsed time since tic was used and if "t1" is
;     not explicitly defined.
;
; :SYNTAX:
;     tic
;       ...
;       Operations
;       ... 
;     toc [,/HOURS | ,/MINUTES | ,/SECONDS] [,GET=Variable] [,/QUIET]
;     toc, GET=t
;     
;
;	 :PARAMS:
;    t1 (IN:Value) Optional tic value (systime) in seconds. Elapse time is 
;         calculated from t1 if present. def: from tic call.   
;
;
;  :KEYWORDS:
;    /HOURS     Print and Return elapsed time in Hours.
;    /MINUTES   Print and Return elapsed time in Minutes.
;    /SECONDS   Print and Return elapsed time in Seconds.
;    GET (OUT:Variable) A named variable to store the elapsed time.
;    /QUIET     Quiet mode.
;
; :REQUIRES:
;     tic.pro
;
; :EXAMPLES:
;   it  = 200
;   t   = fltarr(it)
;   for n=1L,it do begin
;     tic
;     x = fltarr(n,n,n)
;     toc,GET=i,/quiet & t[n-1]=i
;   endfor
;   plot,t
;  
; 
; :REMARKS:
;     The tic and toc procedures work together to measure elapsed time. 
;     tic saves the current time that toc uses later to measure the elapsed time. 
;     The sequence of commands
;   IDL>  tic
;   IDL>  operations
;   IDL>  toc
;     measures the amount of time IDL takes to complete one or more operations, 
;     and displays the time in seconds.
; 
; WARNING:
;     The tic procedure will attempt to define a system variable !T 
;     ** Structure TIMER, 2 tags [TIC,TOC], length=16, data length=16
;     This might conflict if such a system variable of different structure
;     is already pre-defined in the current IDL session.
; 
;
; :CATEGORIES:
;     Date and Time
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  27-Nov-2009 18:17:13 Created. Yaswant Pradhan.
;  20-Jul-2011 Clean Formatting. YP.
;
;-

  defsysv, '!T', EXISTS=exist
  if (exist NE 1) then message,'!T doesnot exist; tic must be called before toc'
  !T.toc = systime(1)
  verb   = ~keyword_set(quiet)
  
; Elapsed time in seconds:  
  tdiff = !T.toc - (arg_present(t1) ? t1 : !T.tic) 
  hh    = string( fix(tdiff/3600), format='(I02)' )
  mm    = string( fix(tdiff - hh*3600)/60, format='(I02)' )
  ss    = string( tdiff - hh*3600 - mm*60, format='(F05.2)' )
  
  if keyword_set(seconds) then begin
    res = strtrim(string(tdiff, FORM='(f0.4)'),2) 
    if verb then print,'Elapsed time: '+res+' seconds.'
  endif else $
  
  if keyword_set(minutes) then begin
    res = strtrim(string(tdiff/60., FORM='(f0.4)'),2)
    if verb then print,'Elapsed time: '+res+' minutes.' 
  endif else $
  
  if keyword_set(hours) then begin
    res = strtrim(string(tdiff/3600., FORM='(f0.4)'),2)
    if verb then print,'Elapsed time: '+res+' hours.' 
  endif else begin
  
    res = hh+':'+mm+':'+ss
    if verb then print,'Elapsed time: '+res 
  endelse  

end
