pro tic, GET=t1

;+
; NAME:
;     tic, toc
; 
; PURPOSE:
;     Measure performance using stopwatch timer.
;     tic starts a stopwatch timer. 
;     toc prints the elapsed time since tic was used.
;     t = toc returns the elapsed time in t.
; 
; SYNTAX:
;     tic, GET=t1
;     any statements 
;     toc [,/HOURS | ,/MINUTES | ,/SECONDS] [,GET=Variable]
;     toc, GET=t2
; 
; KEYWORDS:
;     default print format - (STRING) hh:mm:ss.ss
;     default get format - (FLT) in second
;     HOURS:    prints and returns elapsed time in hours
;     MINUTES:  prints and returns elapsed time in minutes
;     SECOND:   prints and returns elapsed time in seconds
;     GET [var]:save elapsed time to a named variable (in hour|minutes|sec)
;     QUIET:    supress print to console
;     
; REMARKS:
;     The tic and toc procedures work together to measure elapsed time. 
;     tic saves the current time that toc uses later to measure the elapsed time. 
;     The sequence of commands
;   IDL>  tic
;   IDL>  operations
;   IDL>  toc
;     measures the amount of time IDL takes to complete one or more operations, 
;     and displays the time in seconds.
; 
; EXAMPLES:
;     
;     it  = 200
;     t   = fltarr(it)
;     for n=1L,it do begin
;       tic
;       x = fltarr(n,n,n)
;       toc,GET=i,/quiet & t[n-1]=i
;     endfor
;     plot,t
; 
; WARNING:
;     The tic procedure will attempt to define a system variable !T 
;     ** Structure TIMER, 2 tags [TIC,TOC], length=16, data length=16
;     This might conflict if such a system variable of different structure
;     is already pre-defined in the current IDL session.
; 
; $Id: tic.pro toc.pro,v 1.0 2009-11-27 18:17:22 yaswant Exp $
; Yaswant Pradhan (c) Crown copyright Met Office
; Last modification:
;   2009-11-27 18:17:13 - Created. YP
; 
;-

  defsysv,'!T', {Timer, tic: systime(1), toc: systime(1)} 
  t1 = !T.tic
  
end



; -----------------------------------------------------------------------------



;pro toc, HOURS=hours, MINUTES=minutes, SECONDS=seconds, GET=res, QUIET=quiet
;
;  defsysv, '!T', EXIST=exist
;  if (exist NE 1) then message,'!T doesnot exist; tic must be called before toc'
;  !T.toc = systime(1)
;  
;  verb    = ~keyword_set(quiet)  
;  tdiff   = !T.toc - !T.tic ; Elapsed time in seconds
;  hh      = string( fix(tdiff/3600), format='(I02)')
;  mm      = string( fix(tdiff - hh*3600)/60, format='(I02)')
;  ss      = string( tdiff - hh*3600 - mm*60, format='(F05.2)')
;
;    
;  
;  if keyword_set(seconds) then begin
;    res   = tdiff 
;    if verb then print,' Elapsed time:'+string( res, format='(f8.4)' )+' seconds'
;  endif else $
;  if keyword_set(minutes) then begin
;    res   = tdiff/60.
;    if verb then print,' Elapsed time:'+string( res, format='(f8.4)' )+' minutes' 
;  endif else $
;  if keyword_set(hours)   then begin
;    res   = tdiff/3600.
;    if verb then print,' Elapsed time:'+string( res, format='(f8.4)' )+' hours' 
;  endif else begin
;    res   = tdiff
;    if verb then print,' Elapsed time: '+hh+':'+mm+':'+ss 
;  endelse  
;
;end
