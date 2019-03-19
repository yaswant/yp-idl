pro overlay_box,    $
    POSITION=pos,   $
    COLOR=color,    $
    THICK=thick,    $
    XRANGE=xrange,  $
    YRANGE=yrange,  $
    BACKGROUND=background,$
    EXPANDBOX=expandbox, $
    GET_POS=pos2,   $
    _EXTRA=_extra
        
;+
; :NAME:
;    	overlay_box
;
; :PURPOSE:
;       Overlay box on a defined plot position
;
; :SYNTAX:
;       overlay_box [,POSITION=Array] [,COLOR=Value] [,THICK=Value]
;
;
; :KEYWORDS:
;    POSITION (in:array) Overlay position in normalised coordinates
;    COLOR (in:value) Color index for the box outline (borders)
;    THICK (in:value) Border thickness
;    XRANGE (in:array) Data X-range to plot tickmarks
;    XRANGE (in:array) Data Y-range to plot tickmarks
;    BACKGROUND (in:value) Fill background of box region
;    EXPANDBOX (in:array) exand the box by [x-left,y-bottom,x-right,y-top]
;               fraction. This will be added to position array
;    GET_POS (out:variable) named variable to return the Box position in
;               normalised coordinates           
;
;
; :REQUIRES:
;       None
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;       Plotting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Jul 4, 2012 3:07:09 PM Created. Yaswant Pradhan.
;  Apr 29, 2013 Added Xrange, Yrange, Get_Pos keywords. YP.
;
;-
        
    ; Parse overlay position:
    if (N_ELEMENTS(pos) lt 4) then $
        pos = [!x.window[0],!y.window[0], !x.window[1],!y.window[1]]
        
    pos2 = (N_ELEMENTS(expandbox) eq 4) ? pos+expandbox*[-1.,-1.,1.,1.] : pos
    
    tnames = REPLICATE(' ',2)
    
    
    ; Overlay box:
    if KEYWORD_SET(xrange) then begin
        plot, xrange, yrange, XST=1,YST=1, POSITION=pos2, COLOR=color,$
            XTHICK=thick, YTHICK=thick, /NODATA, /NOERASE, _EXTRA=_extra
    endif else begin
        plot, INDGEN(2), POSITION=pos2, COLOR=color, /NODATA, /NOERASE,/NORMAL,$
            XMINOR=1, XTICKINTERV=10, XTICKNAME=tnames, XTHICK=thick,          $
            YMINOR=1, YTICKINTERV=10, YTICKNAME=tnames, YTHICK=thick,_EXTRA=_extra
    endelse
    
    if is_defined(background) then begin
        POLYFILL,pos2[[0,2,2,0,0]],pos2[[1,1,3,3,1]],COLOR=background,/NORMAL
    endif
end
