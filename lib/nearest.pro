FUNCTION nearest, xArr, yArr, x, y, $    
    SEARCHRADIUS=SearchRadius,  $
    NPOINTS=nPoints,            $
    REGULAR=regular,            $
    COUNT=cnt,                  $
    FAIL=fail,                  $
    VERBOSE=verbose
;+
; :NAME:
;    	nearest
;
; :PURPOSE:
;       Returns the nearest point of a given (x,y) pair from a set of
;       (X,Y) arrays on a Cartesian plane. 
;       For 2D X and Y:
;           returns the column and row indices indicating the 
;           [left,right,bottom,top] position
;       For vector X and Y:
;           returns the indices of (nPoints) nearest points
;
; :SYNTAX:
;       Result = nearest(xArr, yArr, x, y [,SEARCHRADIUS=value]
;                       [,NPOINTS=value] [,/REGULAR] [,COUNT=variable]
;                       [,FAIL=variable] [/VERBOSE])
;
; :PARAMS:
;    xArr (in:array) 1D or 2D arrays indicating x grid values
;    yArr (in:array) 1D or 2D arrays indicating x grid values
;    x (in:value) zonal (x) position of search point
;    y (in:value) meridional (y) position of search point
;
;
; :KEYWORDS:
;    SEARCHRADIUS (in:value) Search reaiud from (x,y) search position 
;                   (def: 0.5)
;    NPOINTS (in:value) number of nearest samples to search (def: 0 which 
;                   returns first nearest point)
;    /REGULAR - Set this keyword if xArr and yArr are vectors of inequal length,
;               but representing regularly spaced grid point values.
;    COUNT (out:variable) Named variable to store the number of nearest points
;               found in the xArr,yArr
;    FAIL (out:variable) Named variable to store fails status 
;               (1: Fail, 0:Success)
;    /VERBOSE - Verbose mode
;
; :REQUIRES:
;       ll_vec2arr.pro
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
;  Aug 15, 2012 2:41:59 PM Created. Yaswant Pradhan.
;
;-


fail = 0b
cnt  = 0
if (n_params() lt 4) then begin
    message,'Result = nearest(xArr, yArr, x, y [,SEARCHRADIUS=value]'+$
                     '[,NPOINTS=value] [,/REGULAR] [,COUNT=variable]'+$
                     '[,FAIL=variable] [/VERBOSE])',/CONTINUE
    fail  = 1b
    return,-901
endif

_v   = KEYWORD_SET(verbose)
_r   = KEYWORD_SET(regular)
xV   = xArr
yV   = yArr
xSiz = SIZE(xArr)
xDim = SIZE(xArr, /N_DIM)
yDim = SIZE(yArr, /N_DIM)
xNel = N_ELEMENTS(xArr)
yNel = N_ELEMENTS(yArr)
nEq  = (xNel ne yNel)
if ~(keyword_set(nPoints)) then nPoints = 0
if ~(keyword_set(SearchRadius)) then SearchRadius = 0.5


if (xDim gt 2 or yDim gt 2 or (xDim ne yDim)) then begin
    message,'Incompatible dimension in search arrays',/CONT
    fail  = 1b
    return,-901
endif

; Parse regularly spaced arrays
if _r then begin
    if nEq then begin
        nX  = xNel
        nY  = yNel 
        ll_vec2arr, xArr, yArr, xx,yy
        xV  = REFORM(xx, N_ELEMENTS(xx))
        yV  = REFORM(yy, N_ELEMENTS(yy))
    endif else begin
        nX  = xSiz[1]
        nY  = xSiz[2]
        xV  = REFORM(xArr, xNel)
        yV  = REFORM(yArr, yNel)
    endelse
endif

; Check final x and Y arrays have equal length:
if (N_ELEMENTS(xV) ne N_ELEMENTS(yV)) then begin
    message,'Search arrays should be of equal lengths'+string(10b)+$
        'For regularly-spaced data see /REGULAR keyword.',/CONT
    fail  = 1b
    return,-902
endif



; Caculate cartesian distance from each points in the array
; and get position of nearest point:
distance = SQRT((x-xV)^2 + (y-yV)^2)
min_dis = MIN(distance)
pos = WHERE(distance eq min_dis) ; Nearest Points



if (min_dis gt SearchRadius) then begin
    if _v then begin    
        print,'Minimum Distance: ',min_dis
        message,'No points found within SearchRadius='+$
            STRTRIM(SearchRadius,2),/CONT
    endif
    fail = 1b
    return,-903
endif

if (_r or (xDim eq 2 and yDim eq 2)) then begin
    ; Centre or nearest position:
    ctr    = LONARR(2)
    ctr[0] = pos[0] mod nX
    ctr[1] = pos[0] / nX
    
    ret = (nPoints eq 0) ? LONARR(2) : LONARR(4)  ; [x0,y0]  OR [x1,x2, y1,y2]
    npr = [1,-1,1,-1]*nPoints
    ret = (nPoints eq 0) $
          ? ctr $
          : ([ctr[[0,0]],ctr[[1,1]]] - npr) > [0,0,0,0] < [nX,nX,nY,nY]
    cnt = (nPoints eq 0) ? 1 : (ret[1]-ret[0]+1)*(ret[3]-ret[2]+1)
    
;    print,'X/Y',x,y,cnt
;    print,xArr[ret[0]:ret[1],ret[2]:ret[3]]
;    print,yArr[ret[0]:ret[1],ret[2]:ret[3]]
endif else begin
    sPos = SORT(distance)
    pos  = WHERE(distance le SearchRadius, cnt)
    cnt  = (1>nPoints)<cnt
    ret  = (cnt gt 0) ? sPos[0:cnt-1] : -903
    fail = PRODUCT(ret) lt 0
endelse

return, ret

END