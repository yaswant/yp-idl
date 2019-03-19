PRO plot_density, array1, array2, $
        BIN1=bn1, $
        BIN2=bn2, $
        RANGE1=mnmx1, $
        RANGE2=mnmx2, $
        ZOOM=zm, $
        TITLE=titl, $
        XTITLE=xtitl, $
        YTITLE=ytitl, $
        ONEONE=oneone, $
        CONTOUR_PLOT=contour_plot, $
        CB_COLOUR=cb_clr, $
        CB_WIDTH=cbw, $
        C_LEVEL=c_lev, $
        C_COLOUR=c_clr, $
        POSITION=pos, $
        CT=ct, $
        STATISTIC=statistic, $
        XFORMAT=xformat, $
        YFORMAT=yformat,$
        _EXTRA=_extra
        
;+
; NAME:
;         plot_density
; PURPOSE:
;         Plots 2d histogram as scatter/contour plot a.k.a density plot (PDF)
; ARGUMENTS:
;         Array1
;         Array2
; KEYWORDS:
;         BIN1 (IN:Value) Bin interval for input array1, default value 1.
;         BIN1 (IN:Value) Bin interval for input array2, default value 1.
;         RANGE1 (IN:Array) [Min, Max] Range of input array1
;         RANGE2 (IN:Array) [Min, Max] Range of input array2
;         ZOOM (IN:Value) Zoom factor to enlagre display (overridden by POSITION)
;         TITLE (IN:String) Custom Plot Title
;         XTITLE (IN:String) Title for X axis
;         YTITLE (IN:String) Title for Y axis
;         /ONEONE Adds 1:1 line to plot
;         /CONTOUR_PLOT Adds contour lines to plot
;         CB_COLOUR (IN:Value) Colorbar annotaion color
;         CB_WIDTH (IN:Value) Colorbar width
;         C_LEVEL (IN:Value) Number of Contour levels; default is 20
;         C_COLOUR (IN:Value) Contour colour
;         POSITION (IN:Array) Position [x0,y0, x1,y1] (in normal coordinate)
;               to place the plot on an  already opened device/window.
;         /STAT Prints data stats on plot (top-left corner)
; LIMITATION:
;
; DEPENDENCY:
;         is_defined.pro
;         minmax.pro
;         fltscl.pro
;         decomp.pro
;         loadmyct.pro
;         colorbar.pro
; EXAMPLE:
;        x=randomn(seed,200,200) & y=randomn(seed,200,200)
;   To plots with default setting (bins=1)
;        plot_density,x,y
;   To plot increased number of bins
;        plot_density,x,y, BIN1=0.2, BIN2=0.2
;   To plot increased number of bins and add 5 contour lines
;        plot_density,x,y, BIN1=0.2, BIN2=0.2, /CONT, C_LEV=5
;   Annotation:
;        plot_density,x,y,bin1=0.2,bin2=0.2,CHARSIZE=1.5, TITLE='Test Plot', $
;        XTIT='Random1', YTIT='Random2'
;   Multiplot:
;        Using P_ADVANCE to get the plot position will help doing multiple
;        density plots.
;        !P.MULTI=[0,2,2]
;        p_advance, pos
;        plot_density,x,y,bin1=0.2,bin2=0.2,TITLE='Test Plot', XTIT='Random1',$
;        YTIT='Random2',/CONT,POS=pos
;        p_advance, pos
;        plot_density,x,y,bin1=0.2,bin2=0.2,TITLE='Test Plot', XTIT='Random1',$
;        YTIT='Random2',/CONT,POS=pos
;        and so on...
; CATEGORY:
;    Data visualisation, Plotting
;
; ------------------------------------------------------------------------------
; $Id: plot_density.pro,v0.1 2010-03-01 11:10:38 yaswant Exp $
; PLOT_DENSITY.pro Yaswant Pradhan (c) Crown Copyright Met Office
; Last modification:
; 05/08/2010  Report error message when hist_2d returns insufficient
;             number of points for contour (YP).
;             Now works for PS device (YP).
; 14/12/2010  Add STATISTICS keyword (YP).
;
; ------------------------------------------------------------------------------
;-
        
        
    ; --------------------------------------------------------------------------
    ; Parse input
    ; --------------------------------------------------------------------------
    syntax='Syntax: plot_density, ARRAY1, ARRAY2 [,BIN1=Value] [,BIN2=Value] '+$
        '[,RANGE1=Array] [,RANGE2=Array] [,ZOOM=Value] '+$
        '[,TITLE=String] [,XTITLE=String] [,YTITLE=String] '+$
        '[,/ONEONE] [,/CONTOUR_PLOT] [,C_LEVEL=Value] [,C_COLOUR=Value] '+$
        '[,POSITION=Array] [,_EXTRA=_extra]
    
    if n_params() lt 2 then begin
        print, syntax
        goto, FINISH
    endif
    
    
    ; --------------------------------------------------------------------------
    ; Default Settings
    ; --------------------------------------------------------------------------
    mn1   = is_defined(mnmx1) ? float(mnmx1[0]) : min(array1, /nan)
    mx1   = is_defined(mnmx1) ? float(mnmx1[1]) : max(array1, /nan)
    mn2   = is_defined(mnmx2) ? float(mnmx2[0]) : min(array2, /nan)
    mx2   = is_defined(mnmx2) ? float(mnmx2[1]) : max(array2, /nan)
    bn1   = is_defined(bn1)   ? bn1 : 1.
    bn2   = is_defined(bn2)   ? bn2 : 1.
    cb_clr= is_defined(cb_clr)? cb_clr : 255
    c_lev = is_defined(c_lev) ? c_lev : 20
    c_clr = is_defined(c_clr) ? c_clr : 0
    zm    = keyword_set(zm)   ? zm : 1.
    ct    = is_defined(ct)    ? ct : 56
    
    titl  = keyword_set(titl)  ? strtrim(string(titl),2)  : ' '
    xtitl = keyword_set(xtitl) ? strtrim(string(xtitl),2) : ' '
    ytitl = keyword_set(ytitl) ? strtrim(string(ytitl),2) : ' '
    
    
    ; --------------------------------------------------------------------------
    ; Bin input arrays to create 2D array for contouring
    ; --------------------------------------------------------------------------
    h2d = hist_2d( array1, array2, MIN1=mn1, MIN2=mn2, $
        MAX1=mx1, MAX2=mx2, BIN1=bn1, BIN2=bn2 )
        
        
    xyl = (size(h2d))[1:2]
    if (xyl[0] lt 2 or xyl[1] lt 2) then begin
        print,' Array1 Range: ['+strjoin(strtrim(minmax(array1),2),', ')+']'
        print,' Array1 Range: ['+strjoin(strtrim(minmax(array2),2),', ')+']'
        print,' Number if elements in Output Array: ['+$
                strjoin(strtrim(xyl,2),', ')+']'
        print,' Not enough elements in Output Array.'+$
            ' Consider changing BIN values.'
        goto, FINISH
    endif
    
    ; --------------------------------------------------------------------------
    ; Get Default Plot window size
    ; --------------------------------------------------------------------------
    s = size( h2d, /DIM )
    x = s[0]    &   y = s[1]
    xs  = fltscl(findgen(s[0]), LOW=mn1, HIGH=mx1)
    ys  = fltscl(findgen(s[1]), LOW=mn2, HIGH=mx2)
    
    loadmyct, ct, /SILENT
    if !d.name eq 'X' then begin
        decomp
        !p.background=0
    endif
    
    cbw = is_defined(cbw) ? cbw : (!d.name eq 'PS' ? 150. : 10.) ; Cbar width
    
    if keyword_set(pos) then begin
        ppos  = pos-[0,0,0.05,0]                      ; normal coordinates
        zm    = 1.                                    ; default zoom factor
        xd    = !d.x_size                             ; device x
        yd    = !d.y_size                             ; device y
        buf   = ceil([ppos[0]*xd, ppos[1]*yd])        ; in device coord
        xf    = ceil((ppos[2]-ppos[0])*xd)            ; Congrid factor (device)
        yf    = ceil((ppos[3]-ppos[1])*yd)            ; Congrid factor (device)
        cbpos = [ppos[2],ppos[1],ppos[2]+cbw/xd,ppos[3]]  ; colourbar position
    endif else begin
        buf   = [50.,50.]     ; plot window buffer
        if (x > y lt 50) then begin
            zm = 200./(x < y)
        endif
        xd    = x*zm+2*buf[0]
        yd    = y*zm+2*buf[1]
        ; Plot position:
        ppos  = [buf[0]/xd, buf[1]/yd, (x*zm+buf[0])/xd, (y*zm+buf[1])/yd]
        ; Colorbar position:
        cbpos = [(x*zm+buf[0])/xd, (buf[1]/yd), $
                (x*zm+buf[0]+cbw)/xd, (y*zm+buf[1])/yd]
        xf    = x*zm
        yf    = y*zm
        window, XSIZE=xd, YSIZE=yd
    endelse
    
    
    ; --------------------------------------------------------------------------
    ; Plot data, contour, colorbar, 1:1 line etc...
    ; --------------------------------------------------------------------------
    contour, h2d, xs, ys, XST=1, YST=1, /NODATA, /NOERASE, $
        POSITION=ppos, _EXTRA=_extra
        
    tv, bytscl(congrid(h2d, xf, yf),MIN=min(h2d),MAX=max(h2d),TOP=252),$
        buf[0], buf[1], XSIZE=xf, YSIZE=yf
    
;    help,h2d,xf,yf,x,y,zm    
    plot, [mn1,mx1],[mn2,mx2], XST=1,YST=1, /NOERASE, /NODATA, $
        TITLE=titl, XTITLE=xtitl, YTITLE=ytitl, COLOR=255, $
        POSITION=ppos, XTICKFORMAT=xformat,YTICKFORMAT=yformat,$
        _EXTRA=_extra
        
    colorbar, RANGE=[min(h2d), max(h2d)], /VERTICAL, /RIGHT, $
        POSITION=cbpos, COLOR=cb_clr, NCOLORS=252,_EXTRA=_extra
        
    if KEYWORD_SET(oneone) then oplot, [mn1,mx1],[mn2,mx2]
    
    if KEYWORD_SET(contour_plot) then $
        contour,  h2d, xs, ys, XST=1,YST=1, COLOR=c_clr, NLEV=c_lev, $
        /OVER, POSITION=ppos
        
        
    ; --------------------------------------------------------------------------
    ; Print plot statistics (linear)
    ; --------------------------------------------------------------------------
    if KEYWORD_SET(statistic) then begin
        pltPos  = [ !x.window[0],!y.window[0], !x.window[1],!y.window[1] ]
        
        tlx=(blx = pltPos[0])
        bly=(bry = pltPos[1])
        trx=(brx = pltPos[2])
        tly=(try = pltPos[3])
        
        dx=0.02
        dy=0.05
        
        wh  = WHERE(FINITE(array1) and FINITE(array2), n_wh)
        X   = array1[wh]
        Y   = array2[wh]
        lfit = LINFIT(X,Y)
        r   = CORRELATE(X,Y)
        
        stats = { Equation:'y = mx + b', $
            m: lfit[1], b: lfit[0],  $
            n: n_wh, r:r[0] }
        form  = ['(A)', '(f6.2)', '(f7.2)', '(i6)', '(f7.2)']
        
        ;    !P.CHARSIZE=1.2
        XYOUTS, tlx+dx, tly-dy, stats.Equation, /NORMAL
        for i=1,N_TAGS(stats)-1 do begin
            XYOUTS, tlx+dx, tly-(i+1)*dy, STRLOWCASE((TAG_NAMES(stats))[i]) + $
                ' '+STRING(stats.(i),FORM=form[i]),/NORMAL
        endfor
    ;    y = mx + b
    ;    n, r2, slope, intcpt
        
        
    endif    
    FINISH:
    
END
