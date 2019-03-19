;+
; :NAME:
;       densityplot
;
; :PURPOSE:
;       Plot 2D scattergram (aka density plot) using two sets of records.
;       The density is calculated using hist_2d for each bin.
;
; :SYNTAX:
;       densityplot, xArr, yArr [,XBIN=Value] [,YBIN=Value] [,XMIN=Value]
;           [,XMAX=Value] [,YMIN=Value] [,YMAX=Value] [,XBUF=Value]
;           [,YBUF=Value] [,CT=Value] [,CUTOFF=Value] [,/CONTOUR]
;           [,NLEVELS=Value] [,/CFILL] [,/ONEONE] [,/NODOTS] [,/NOBAR]
;           [,BARS=Struct] [,_EXTRA=_extra]
;
; :PARAMS:
;    xArr (in:array) independent variable, X
;    yArr (in:array) dependent variable, Y
;
;
; :KEYWORDS:
;    XBIN (in:value) size of each bin in X direction (def: 1)
;    YBIN (in:value) size of each bin in Y direction (def: 1)
;    XMIN (in:value) minimum cutoff value for X (def: min(X))
;    XMAX (in:value) maximum cutoff value for X (def: max(X))
;    YMIN (in:value) minimum cutoff value for Y (def: max(Y))
;    YMAX (in:value) maximum cutoff value for Y (def: max(Y))
;    XBUF (in:array) white space around data in X dir in data unit
;    YBUF (in:array) white space around data in Y dir in data unit
;    CT (in:value) color table index to load (def: 39)
;    CUTOFF (in:value) Dont plot data below this density (def:1)
;    /CONTOUR - Set this keyword to overlay density contours
;    NLEVELS (in:value) number of contour levels (def: 10)
;    /CFILL - Set this keyword to fill contours
;    /ONEONE - Set this keyword to overlay 1:1 line
;    /NODOTS - Set this keyword to skip dot (symbol) plots
;    /NOBAR - Set this keyword to avoid plotting density colorbar
;    BARS (in:struct) cbar options to override default settings
;          {charsize:0.6,               -- cbar charsize
;          color:1,                     -- cbar annotation colour
;          divisions:6<max_density,     -- number of divisions
;          format:'(i0)',               -- number format
;          ncol:252,                    -- max number of colours
;          right:0,                     -- annotation on the right side?
;          vertical:1,                  -- verical bar?
;          width:0.01,                  -- cbar thickness
;          xoff:-0.01,                  -- offset from X (right hand side)
;          ymargin:0.02}                -- offset from Y (both direction)
;    /GRIDON - Set this keyword to plot full gridlines in grey colour
;       Note: setting [!XY]TICKLEN=1 in a densityplot call will override
;       this option and draw full grid in color defined by COLOR keyword.
;    GCOLOR (in:value) Fullgrid line (grey) colour index, 0=black, 255=white
;    /SILENT - Set this keyword to suppress INFO messages
;    /FIT - Add linear fit line
;    /STAT - Add Stats to the plot
;    SCHARSIZE (in:value) Chasracter size for stats
;    SCOLOR (in:value) Text colour for stats
;    _EXTRA - See inheritted keywords for PLOT and CONTOUR procedures
;
; :REQUIRES:
;   is_defined.pro
;   range.pro
;   ll_vec2arr.pro
;   loadmyct,pro
;   cbar.pro
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
;  30-Apr-2014 09:24:06 Created. Yaswant Pradhan.
;
;-

pro densityplot, xArr, yArr, XBIN=xbin,YBIN=ybin, XMIN=xmin,XMAX=xmax,  $
        YMIN=ymin,YMAX=ymax, XBUF=xbuf,YBUF=ybuf, CT=ct, CUTOFF=cutoff, $
        CONTOUR=contour, NLEVELS=nlevels, CFILL=cfill, ONEONE=oneone,   $
        NODOTS=nodots, NOBAR=nobar, BARS=bars, GRIDON=gon, GCOLOR=gcolor,$
        SILENT=silent,FIT=fit, STAT=stat, SCHARSIZE=scharsize, SCOLOR=scolor,$
        _EXTRA=_extra

    ; parse arguments
    if (N_PARAMS() lt 2) then begin
        message,'densityplot, xArray, yArray [,KEYWORDS..]', /CONTIN, /NOPREF
        return
    endif

    ; Parse input:
    xbf = is_defined(xbuf) ? [-1.,1.]*xbuf : [0,0]
    ybf = is_defined(ybuf) ? [-1.,1.]*ybuf : [0,0]
    min1 = is_defined(xmin) ? xmin : MIN(xArr,/NAN)
    min2 = is_defined(ymin) ? ymin : MIN(yArr,/NAN)
    max1 = is_defined(xmax) ? xmax : MAX(xArr,/NAN)
    max2 = is_defined(ymax) ? ymax : MAX(yArr,/NAN)
    bin1 = is_defined(xbin) ? xbin : 1.0
    bin2 = is_defined(ybin) ? ybin : 1.0
    schar = is_defined(scharsize) ? scharsize : 0.8
    scol = is_defined(scolor) ? scolor : 0
    _q = KEYWORD_SET(silent)

    ; Get the two dimensional density function (histogram) of two variables:
    h2d = HIST_2D(xArr, yArr, BIN1=bin1, BIN2=bin2, MIN1=min1, MIN2=min2, $
        MAX1=max1, MAX2=max2)

    h2drng = range(h2d)
    if ~_q then $
        message, 'DENSITY_RANGE: ['+STRING(h2drng,'(%"%d, %d]")'),/CONTI,/NOPREF

    w = WHERE(h2d ge (is_defined(cutoff) ? cutoff : 1), nw)
    if (nw le 1 or N_ELEMENTS(h2d) le 1) then begin
        message,'Not enough data to plot',/CONTINUE,/NOPREFIX
        return
    endif


    ; Now scatter-plot 2D density function:
    s = SIZE(h2d,/dim)
    x = min1+FINDGEN(s[0])*bin1
    y = min2+FINDGEN(s[1])*bin2
    ll_vec2arr,x,y,xx,yy

    loadct,0
    !p.BACKGROUND=255
    !p.COLOR=0
    gcol = is_defined(gcolor) ? gcolor : 200

    ; Grey grids black box
    ; Overlay grey full grid lines:
    PLOT, [min1,max1]+xbf, [min2,max2]+ybf, XST=1,YST=1, /NODATA, COLOR=gcol,$
        XTICKLEN=KEYWORD_SET(gon),YTICKLEN=KEYWORD_SET(gon),$
        XTHICK=0.1,YTHICK=0.1,_EXTRA=_extra
    ; Overlay black outer box:
    PLOT, [min1,max1]+xbf, [min2,max2]+ybf, XST=1,YST=1, /NODATA, COLOR=0,$
        /NOERASE, _EXTRA=_extra


    ; Plot Density Data:
    loadmyct,(KEYWORD_SET(ct) ? ct : 39),SILENT=_q
    if ~KEYWORD_SET(NODOTS) then begin

        sym_info = 'Assign PSYM and SYMSIZE to plot with symbols, '+$
            'eg: [,PSYM=2 ,SYMSIZE=0.3] to plot with astrisks'
        if ~_q then begin
            case N_ELEMENTS(_extra) of
                0: message,sym_info,/CONTI
                else: if TOTAL(STRMATCH(TAG_NAMES(_extra),'PSYM')) eq 0 then $
                    message,sym_info,/CONTI
            endcase
        endif

        PLOTS, xx[w],yy[w],COLOR=BYTSCL(h2d[w],top=252),NOCLIP=0,_EXTRA=_extra
    endif


    ; Add Desity Contour:
    if KEYWORD_SET(contour) then begin
        nlev = KEYWORD_SET(nlevels) ? nlevels : 10
        nlev = nlev < h2drng[1]
        levs = is_defined(levels) ? levels : BYTSCL(INDGEN(nlev),TOP=h2drng[1])

        if (N_ELEMENTS(levs) gt 2) then begin
            cols = FIX(PPOINTS(nlev,LOW=0,HIGH=252,/FIXED_BOUNDS))
            CONTOUR, h2d,x,y, C_COLORS=cols[1:*],LEVELS=levs[1:*],$
                FILL=KEYWORD_SET(cfill),/OVERPLOT,_EXTRA=_extra
        endif
    endif


    ; Add 1:1 line
    if KEYWORD_SET(oneone) then begin
        prange = [MIN([!x.crange,!y.crange]),MAX([!x.crange,!y.crange])]
        OPLOT, prange,prange,LINESTYLE=2,THICK=2
    endif

    ; Add fit
    if KEYWORD_SET(fit) then begin
        f = WHERE(xArr ge xmin and xArr le xmax and yArr ge ymin and $
            yArr le ymax, nf)
        if(nf gt 0) then begin
            fits = rmafit(xArr[f], yArr[f])
            ;fits = linfit(xArr[f], yArr[f])
            OPLOT, !x.crange, !x.crange*fits[1]+fits[0],THICK=2,COLOR=100
        endif
    endif


    ; Show Stats:
    if KEYWORD_SET(stat) then begin
        f = WHERE(xArr ge xmin and xArr le xmax and yArr ge ymin and $
            yArr le ymax, nf)
        if(nf gt 0) then begin
            stat2, xArr[f], yArr[f], out, SILENT=KEYWORD_SET(silent)
            xtl = !x.crange[0] + range(!x.crange,/DIFF)/20.
            yt = !y.crange[1] - range(!y.crange,/DIFF)/20.
            xtr = !x.crange[0] + range(!x.crange,/DIFF)/2.75
            XYOUTS, xtl,yt,/DATA, FONT=-1, CHARSIZE=schar, COLOR=scol,$
                '!CR'+'!CRho'+'!CBias'+'!CRMSE'+'!CRatio!dav!n'+$
                '!CRatio!dmd!n'+'!CSlope'+'!COffset'+'!CN'
            XYOUTS, xtr,yt,/DATA, FONT=-1,CHARSIZE=schar,ALIGN=1,COLOR=scol,$
                '!C'+STRING(out.r,'(f0.2)')+$
                '!C'+STRING(out.rho,'(f0.2)')+$
                '!C'+STRING(out.bias,'(f0.2)')+$
                '!C'+STRING(out.urmse,'(f0.2)')+$
                '!C'+STRING(out.mnrat,'(f0.2)')+$
                '!C'+STRING(out.mdrat,'(f0.2)')+$
                '!C'+STRING(out.slope,'(f0.2)')+$
                '!C'+STRING(out.offset,'(f0.2)')+$
                '!C'+STRING(out.n,'(i0)')
        endif
    endif


    ; Add colour bar
    if ~KEYWORD_SET(nobar) then begin
        divs = 6 < h2drng[1]
        cb = {charsize:0.6,color:1,divisions:divs,format:'(i0)',ncol:252,$
            right:0,vertical:1,width:0.01,xoff:-0.01,ymargin:[0.01,0.03]}

        if is_defined(bars) then begin
            if ~_q then print,'Updating cbar options..'
            for i=0,N_TAGS(cb)-1 do begin
                w = WHERE(STRMATCH(TAG_NAMES(bars),(TAG_NAMES(cb))[i]), nw)
                if (w ge 0) then begin
                    if ~_q then print,(TAG_NAMES(cb))[i],form='(" ",A,$)'
                    cb.(i) = bars.(w)
                endif
            endfor
            if ~_q then print,''
        endif

        cbar, RANGE=h2drng, VERTICAL=cb.vertical, RIGHT=cb.right,$
            XOFFSET=cb.xoff, WIDTH=cb.width, NCOLORS=cb.ncol,$
            COLOR=cb.color, CHARSIZE=cb.charsize, FORMAT=cb.format,$
            YMARGIN=cb.ymargin, DIVISIONS=cb.divisions, UNIT='N'
    endif

end
