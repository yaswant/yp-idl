;+
; NAME:
;     p_advance
;
; PURPOSE:
;     Advances plot position in a MULTI plot window and returns the position of
;     next plot region. Useful for other plots accepting POSITION Keyword
;
; SYNTAX:
;     p_advance [,position]
;
; ARGUMENTS:
;     position (OUT:Variable) Returns [x0,y0,x1,x2] extent of plot panel in a multiplot window
;
; KEYWORDS:
;     None
;
; EXAMPLE:
;     IDL> !p.multi=[0,2,2]
;     IDL> plot,findgen(10)
;     IDL> p_advance, pos
;     IDL> print, pos
;     0.593755     0.578130     0.971880     0.960943
;     IDL> p_advance, pos
;     IDL> print, pos
;     0.0937550    0.0781300     0.471880     0.460943
; EXTERNAL ROUTINES:
;     none
;
; CATEGORY:
;     Plotting
;
;
; -------------------------------------------------------------------------
; $Id: p_advance.pro,v0.1 26/03/2010 12:30:06 yaswant Exp $
; p_advance.pro Yaswant Pradhan (c) Crown Copyright Met Office
; Last modification:
; -------------------------------------------------------------------------
;-

pro p_advance, position, _EXTRA=_extra
  if total(!p.multi[1],!p.multi[2]) gt 0 then $
  plot, indgen(10),/NODATA,XSTYLE=4,YSTYLE=4,_EXTRA=_extra ;,/NOERASE

  position = [!x.window[0],!y.window[0], !x.window[1],!y.window[1]]

end