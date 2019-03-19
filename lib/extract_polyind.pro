function extract_polyind, xarr, yarr, xrv, yrv, CLOSEV=closev, $
        COUNT=count, MASKRESULT=maskResult, SHOW=show, DIAG=diag
;+
; :NAME:
;    	extract_polyind
;
; :PURPOSE:
;       Extract array indices defined by a polygon vertices (xrv, yrv)
;       from a 2D image. The image (plane) coordientes (grid points) are 
;       defined by [xarr, yarr] vectors (e.g., xarr/yarr = monotonically 
;       increasing equally-spaced longitude/latitude vectors)
;
; :SYNTAX:
;       Result = extract_polyind(xarr, yarr, xrv, yrv [,MASK=Variable] 
;                   [,/CLOSEV] [,/SHOW] [,/DIAG])
;
; :PARAMS:
;    xarr (in: vector) X-grid points of the original image (monotonically 
;                       increasing vector) 
;    yarr (in: vector) Y-grid points of the original image (monotonically 
;                       increasing vector)
;    xrv (in: vector) X-coordinates of the vertices of the desired polygon
;    yrv (in: vector) Y-coordinates of the vertices of the desired polygon
;
;
; :KEYWORDS:
;    MASKRESULT (out:variable) Named variable to store the output mask (1: valid
;               0: otherwise)
;    CLOSEV - Close the vertices coordinates
;    SHOW - Show intermediate steps
;    DIAG - Print diagnostics and show output array
;
; :REQUIRES:
;    v_locate.pro
;    save_image.pro
;    ll_vec2arr.pro
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;    Data manipulation, ROI extraction   
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  30-Dec-2014 16:32:36 Created. Yaswant Pradhan.
;
;-
        
    ; Parse error:
    syntax = 'Result = extract_polyind( xarr, yarr, xrv, yrv)'
    if (N_PARAMS() lt 4) then MESSAGE,syntax
    if (SIZE(xarr,/N_DIM) ne 1 or SIZE(yarr,/N_DIM) ne 1) then begin
        PRINT,'N_DIM(xarr, yarr) = ',SIZE(xarr,/N_DIM),SIZE(yarr,/N_DIM)
        MESSAGE,'xarr and yarr must be monotonically increasing 1D arrays.'
    endif
    if (N_ELEMENTS(xrv) ne N_ELEMENTS(yrv)) then $
        MESSAGE,'number of elements in polygon vertices/coordinate arrays '+$
        '[xrv and yrv] should be equal.'
    if (MAX(xrv) gt MAX(xarr,/NAN) or MIN(xrv) lt MIN(xarr,/NAN)) then $
        MESSAGE,/CONTI,/NOPREF,'[W] Out-of-bound value(s) in xrv.'
    if (MAX(yrv) gt MAX(yarr,/NAN) or MIN(yrv) lt MIN(yarr,/NAN)) then $
        MESSAGE,/CONTI,/NOPREF,'[W] Out-of-bound value(s) in yrv.'
        
    _defdev = !d.NAME 
        
    ; Superset x and y grid spacings:
    dx = (xarr - SHIFT(xarr,1))[1]
    dy = (yarr - SHIFT(yarr,1))[1]
    nx = N_ELEMENTS(xarr)
    ny = N_ELEMENTS(yarr)
    
    ; Close vertices by simply appending the first elements of xrv and yrv,
    ; if xrv and yrv coordinated are given as open vertoces (i.e., keep the
    ; start and end points unique:
    xv = KEYWORD_SET(closev) ? [xrv, xrv[0]] : xrv
    yv = KEYWORD_SET(closev) ? [yrv, yrv[0]] : yrv
    
    ; Locate positions of ROI vertices in xarr and yarr:
    xp = v_locate(xarr, xv)
    yp = v_locate(yarr, yv)
    
    ; Construct a 2D plane from xarr and yarr:
    plane = MAKE_ARRAY(nx,ny,VALUE=1)
    thresh = 255b
    
    if KEYWORD_SET(show) then begin
        SET_PLOT, 'X'
        WINDOW,0, XSIZE=nx, YSIZE=ny 
    endif else begin
        SET_PLOT, 'Z'
        DEVICE, SET_RESOLUTION=[nx,ny], DECOMPOSED=0
    endelse
    
    loadct, 0, /SILENT
    TV, BYTSCL(plane)
    POLYFILL, xp, yp, COLOR=thresh,/DEVICE
    img = TVRD()
    
    threshImg = (img eq thresh)
    TVSCL, threshImg
    
    if KEYWORD_SET(diag) then $
        save_image,(KEYWORD_SET(show) ? 'im-x.png' : 'im-z.png')
        
    strucElem = REPLICATE(1, 3, 3)
    threshImg = ERODE(DILATE(TEMPORARY(threshImg), strucElem) , strucElem)
    
    CONTOUR, threshImg, LEVEL=1, XMARGIN=[0,0], YMARGIN=[0,0], $
        /NOERASE, PATH_INFO=pathInfo, PATH_XY=pathXY, $
        XSTYLE=5, YSTYLE=5, /PATH_DATA_COORDS
        
    line = [LINDGEN(PathInfo.N), 0]
    oROI = OBJ_NEW('IDLanROI', $
        (pathXY(*, pathInfo.OFFSET + line))[0, *], $
        (pathXY(*, pathInfo.OFFSET + line))[1, *])
    maskResult = oROI -> ComputeMask(DIMENSIONS=[nx, ny])
    OBJ_DESTROY, oROI
    
    ; Resulting output indices (non-zero) on 2D plane
    ind = WHERE(maskResult)
    SET_PLOT, _defdev
    
    ; Diag:
    if KEYWORD_SET(diag) then begin
        print,'Number of ROI pixels:',N_ELEMENTS(ind)
        print,'ROI indices on 2D plane:'
        print, ind
        ll_vec2arr, XARR, YARR, xx, yy
        print,'X-range of requested ROI: ['+STRING(range(xrv),'(i0,",",i0)')+']'
        print,'Extracted x-values on 2D plane:' 
        print, xx[ind]
        print,'Y-range of requested ROI: ['+STRING(range(yrv),'(i0,",",i0)')+']'
        print,'Extracted y-values on 2D plane:'
        print, yy[ind]
        
        SET_PLOT, 'X'
        window, 9, XSIZE=nx, YSIZE=ny, TITLE=(KEYWORD_SET(show) ? 'X' : 'Z')
        tvscl, maskResult
        SET_PLOT, _defdev        
    endif
    
    maskResult = maskResult eq thresh
    count = N_ELEMENTS(ind)
    return, ind    
end