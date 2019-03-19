pro abline, H=h, V=v, A=a, B=b, DEGREE=degree,$
        XLIMIT=xlim, YLIMIT=ylim, $
        XLOG=xlog, YLOG=ylog, REVERSE=reverse, $
        _EXTRA=_extra
        
;+
; :NAME:
;     abline
;
; :PURPOSE:
;     Adds one or more straight lines through the current plot
;
; :SYNTAX:
;     ABLINE [,H=Array] [,V=Array] [,A=Value] [,B=Value] [,/DEGREE] $
;            [,XLIMIT=Array] [,YLIMIT=Array] [,/XLOG] [,/YLOG] $
;            [,/REVERSE] ,_EXTRA=_extra
;
;
;  :KEYWORDS:
;    A (IN:Value) Offset/Intercept of the straight lines.
;    B (IN:Value) Slope of the straight lines.
;    H (IN:Array) Y-value(s) for horizontal line(s).
;    V (IN:Array) X-value(s) for vertical line(s).
;    /DEGREE The slope value is in degrees; default unit is radian
;    XLIMIT (IN:Array) Crop limits of the straght line in X direction;
;                      default is plot limit
;    YLIMIT (IN:Array) Crop limits of the straght line in Y direction;
;                      default is plot limit
;    /XLOG For logarithmic X-axis
;    /YLOG For logarithmic Y-axis
;    /REVERSE Plot line in reverse order (i.e, from Right->Left or Top->Bottom)
;    _EXTRA (See inherited keywords from PLOTS)
;
; :REQUIRES:
;     is_defined.pro
;
; :EXAMPLES:
;     IDL> plot,findgen(10),psym=4
;     IDL> abline,h=2,b=45,/deg
;     IDL> abline,h=2,b=1,xlim=[2,4],thick=2,color=200
;     IDL> abline,v=2,a=1,b=45,/deg,color=20,thick=2
;     IDL> abline,v=2,a=1,b=-1,color=100,thick=2
;
; :CATEGORIES:
;     Graphics, Plot
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;   23-Sep-2009 12:13:38 Created. Yaswant Pradhan.
;   12-Nov-2010 Add keywords XLIMIT, YLIMIT (YP)
;   12-Nov-2010 Add keywords XLOG, YLOG (YP)
;-
        
    ; --------------------------------------------------------------------------
    ; Parse input
    ; --------------------------------------------------------------------------
    aa    = is_defined(a) ? a : 0.  ; Offset
    bb    = is_defined(b) ? b : 0.  ; Slope
    if KEYWORD_SET(degree) then bb = tan(bb * !DTOR)
    xlim  = is_defined(xlim) ? xlim : [!X.CRANGE[0], !X.CRANGE[1]]
    ylim  = is_defined(ylim) ? ylim : [!Y.CRANGE[0], !Y.CRANGE[1]]
    xlg   = KEYWORD_SET(xlog)
    ylg   = KEYWORD_SET(ylog)
    clp   = [ (xlg ? 10.^xlim[0] : xlim[0]), $
        (ylg ? 10.^ylim[0] : ylim[0]), $
        (xlg ? 10.^xlim[1] : xlim[1]), $
        (ylg ? 10.^ylim[1] : ylim[1]) ]
        
        
    if N_ELEMENTS(h) eq 0 and N_ELEMENTS(v) eq 0 then begin
        print,'[abline] Syntax: ABLINE [,H=Array] [,V=Array]'+$
            ' [,A=Value] [,B=Value] [,/DEGREE] [,XLIMIT=Array]'+$
            ' [,YLIMIT=Array] [,/XLOG] [,/YLOG] [,/REVERSE], _EXTRA=_extra'
            
        print,'[abline] No input keywords given. Plot wont have any effects.'
        return
    endif
    
    ; --------------------------------------------------------------------------
    ; Horizontal line
    ; --------------------------------------------------------------------------
    if N_ELEMENTS(h) gt 0 then begin
        xArray  = [!X.CRANGE[0], !X.CRANGE[1]]
        if xlg then xArray = 10.^(xArray)
        
        for i=0, N_ELEMENTS(h)-1 do begin
            yArray = xArray*bb + aa     ; get the Y array from line eqn 
            dy = yArray[0] - h[i]       ; difference from h
            yArray = yArray-dy + aa     ; add offset again
            plots, (KEYWORD_SET(reverse) ? REVERSE(xArray) : xArray), yArray, $
                CLIP=clp, NOCLIP=0, _EXTRA=_extra
            
        endfor
    endif
    
    
    ; --------------------------------------------------------------------------
    ; Vertical line
    ; --------------------------------------------------------------------------
    if N_ELEMENTS(v) gt 0 then begin
        yArray  = [!Y.CRANGE[0], !Y.CRANGE[1]]
        if ylg then yArray = 10.^(yArray)
        
        for i=0, N_ELEMENTS(v)-1 do begin
            xArray = yArray*bb + aa     ; get the X array from line eqn
            dx = xArray[0] - v[i]       ; difference from v
            xArray = xArray-dx + aa     ; add offset again 
            plots, xArray, (KEYWORD_SET(reverse) ? reverse(yArray) : yArray), $
                CLIP=clp, NOCLIP=0, _EXTRA=_extra
                
        endfor
    endif

end
