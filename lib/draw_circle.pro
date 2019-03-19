pro draw_circle, x0, y0, radius, NPTS=npts, _REF_EXTRA=rex
;+
; :NAME:
;    	draw_circle
;
; :PURPOSE:
;       Draw a circle.
;
; :SYNTAX:
;       draw_circle, x0, y0, radius [,NPTS=value] 
;           [,CLIP=[X0, Y0, X1, Y1]] [,COLOR=value] [,/DATA|,/DEVICE|,/NORMAL]
;           [,LINESTYLE={0 | 1 | 2 | 3 | 4 | 5}] [,/NOCLIP] [,/T3D]
;           [,THICK=value] [,Z=value]
;           [,PSYM=integer{0 to 10}] [,SYMSIZE=value]
;           [/LINE_FILL] [,PATTERN=array] [,ORIENTATION=ccw_degrees_from_horiz]
;
; :PARAMS:
;    x0 (in:value) Central x coordinate of the circle
;    y0 (in:value) Central y coordinate of the circle
;    radius (in:value) Radius of the circle
;
;
; :KEYWORDS:
;    NPTS (in:value) Number of points (default = 10000)
;    
; :INHERITED KEYWORDS:
;   Common Graphics Keywords:
;       CLIP=[X0, Y0, X1, Y1]
;       COLOR=value
;       /DATA|,/DEVICE|,/NORMAL
;       LINESTYLE={0 | 1 | 2 | 3 | 4 | 5}
;       /NOCLIP
;       /T3D
;       THICK=value
;       Z=value
;              
;   PLOTS specific:
;       PSYM=integer{0 to 10}
;       SYMSIZE=value
;   
;   POLYFILL specific:       
;       /LINE_FILL
;       PATTERN=array
;       ORIENTATION=ccw_degrees_from_horiz
;
; :REQUIRES:
;
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  22-Aug-2013 10:16:11 Created. Yaswant Pradhan.
;
;-

    ; Set default number of points to draw the circle
    npts = KEYWORD_SET(npts) ? npts : 0
    
    case npts of
        3   : message,/CON,'Insufficient NPTS; Drawing a triangle instead.'
        4   : message,/CON,'Insufficient NPTS; Drawing a rectangle instead.'
        5   : message,/CON,'Insufficient NPTS; Drawing a pentagon instead.'
        6   : message,/CON,'Insufficient NPTS; Drawing a hexagon instead.'
        7   : message,/CON,'Insufficient NPTS; Drawing a heptagon instead.'
        8   : message,/CON,'Insufficient NPTS; Drawing an octagon instead.'
        9   : message,/CON,'Insufficient NPTS; Drawing a nonaagon instead.'
        10  : message,/CON,'Insufficient NPTS; Drawing a decagon instead.'
        else: npts = 10000L
    endcase
    
    theta = INDGEN(npts)*2*!pi / npts
    xx = radius * SIN(theta) + x0
    yy = radius * COS(theta) + y0
    xx = [xx, xx[0]]
    yy = [yy, yy[0]]
    
    ; Parse fill using inherited keyword 
    fill = N_ELEMENTS(rex) gt 0 ? FIX(TOTAL(STRMATCH(rex,'FILL',/FOLD))) : 0
    
    case fill of    
        1   : polyfill, xx, yy, _EXTRA=rex
        
        else: plots, xx, yy, _EXTRA=rex        
    endcase    
    return
    
end