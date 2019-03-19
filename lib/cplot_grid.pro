;+
; :NAME:
;       cplot_grid
;
; :PURPOSE:
;       Render customised full grid lines for a plot (over or under depending
;       on when the procedure is called and what the current plot position is)
;
; :SYNTAX:
;       cplot_grid, xrange, yrange [,POSITION=Array] [,XTICKS=Value]
;                   [,YTICKS=Value] [,COLOR=Value|Array]
;
;
; :PARAMS:
;    xrange (in:array) [Min,Max] values of X-array
;    yrange (in:array) [Min,Max] values of Y-array
;
;
; :KEYWORDS:
;    POSITION (in:array) Plot position in [x0,y0,x1,y1] normalised coordinate
;    XGRIDS (in:value) Number of X-grid lines (def: plot default)
;    YGRIDS (in:value) numver of Y-grid lines (def: plot default)
;    COLOR (in:value|array) Colour index (scalar) or RGB array. A scalar value
;               represnets the colour index of already loaded color table.
;               An [R,G,B] array will redefine the colour of the grid lines
;    /PLOT11 Plot 1:1 line
;
; :REQUIRES:
;       None
;
; :EXAMPLES:
;       IDL> cplot_grid, [0,10],[0,10], XGRIDS=10, YGRIDS=10
;       IDL> plot, findgen(10), /noerase
;
; :CATEGORIES:
;       Plotting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Jul 25, 2012 11:14:11 AM Created. Yaswant Pradhan.
;  Jul 31, 2012 Added customised color (R,G,B) input. YP.
;-

pro cplot_grid,         $
    xrange,             $
    yrange,             $
    POSITION=position,  $
    XGRIDS=xgrids,      $
    YGRIDS=ygrids,      $
    COLOR=color,        $
    PLOT11=plot11,      $
    P11COLOR=p11color,  $
    _EXTRA=_extra

syntax = 'cplot_grid, xrange, yrange [,POSITION=Array] '+$
         '[,XGRIDS=Value] [,YGRIDS=Value] [,COLOR=Value]'

if (N_PARAMS() lt 2) then begin
    message, syntax,/CONTINUE
    return
endif
tnames = REPLICATE(' ',60)

tvlct,_rr,_gg,_bb, /GET
if (!d.NAME eq 'X' and !d.WINDOW eq -1) then window
if (N_ELEMENTS(color) eq 3) then begin
    tvlct, color[0],color[1],color[2]
    color = 0
endif

plot, xrange,yrange,POSITION=position, COLOR=color, /NODATA,/NOERASE,/NORM, $
    XTICKLEN=1, XTICKS=xgrids, XRANGE=xrange, XSTYLE=1, XTICKNAME=tnames,   $
    YTICKLEN=1, YTICKS=ygrids, YRANGE=yrange, YSTYLE=1, YTICKNAME=tnames,   $
    _EXTRA=_Extra
tvlct,_rr,_gg,_bb


if KEYWORD_SET(plot11) then oplot,xrange,yrange,COLOR=p11color
end