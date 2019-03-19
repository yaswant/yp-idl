function grid_xyz, x,y,z, $
        XIN=xin,              $
        YIN=yin,              $
        XBOUND=xb,            $
        YBOUND=yb,            $
        DELTA=del,            $
        DIMENSION=dim,        $
        DUPLICATES=dups,      $
        COUNT=cntr,           $
        EPSILON=epsi,         $
        FILTER=filter,        $
        XOUT=grid_X,          $
        YOUT=grid_Y,          $
        XVOUT=Xs, YVOUT=Ys,   $
        CLIP_EDGE=clip_edge,  $
        DOUBLE=double,        $
        FAST=fast,            $
        INTERP=interp
;+
; NAME:
;   grid_xyz
;
; PURPOSE:
;   Simple and fast gridding of irregular data to regular space
;   (NO interpolation)
;
; SYNTAX:
;   Result = grid_xyz( x, y, z [,XBOUND=[xmin,xmax]] [,YBOUND=[ymin,ymax]]
;               [,DELTA=[dx,dy]] [,DIMENSION=[nX,nY]] [,DUPLICATES=string]
;               [,COUNT=variable] [,EPSILON=value] [,FILTER=Value]
;               [,XOUT=variable] [,YOUT=variable] [,XVOUT=variable]
;               [,YVOUT=variable] [,/DOUBLE] [,/FAST] )
;
; INPUTS:
;   x - longitude (or x) vector
;   y - latitude (or y) vector
;   z - f(x,y) (or value at x,y) vector
;
; KEYWORDS:
;   XIN (IN:Array) Regularly-spaced Longitude vector (x-grid of output data)
;   YIN (IN:Array) Regularly-spaced Latitude (Y) vector (x-grid of output data)
;   XBOUND (IN:Array) A two element array for the output grid longitude (or x)
;               boundary; default is [-180, 180]
;   YBOUND (IN:Array) A two element array for the output grid latitude (or y)
;               boundary; default is [-90, 90]
;   DELTA (IN:Array) A two element array defining the grid resolution in
;               longitude,latitude (x,y) direction
;   DIMENSION (IN:Array) A two element array specifying the grid dimensions in
;               X and Y. Default value (XBOUND[1]-XBOUND[0])/DELTA,
;               (YBOUND[1]-YBOUND[0])/DELTA. This Keyword will override /DELTA
;   DUPLICATES (IN:String) A scalar string to handle duplicate values at output
;               grids; default is averaging
;       "First" Retain only the first encounter of the duplicate locations.
;       "Last"  Retain only the last encounter of the duplicate locations.
;       "Avg"   Retain the average F value of the duplicate locations.
;       "Min"   Retain the minimum of the duplicate locations (Min(F)).
;       "Max"   Retain the maximum of the duplicate locations (Max(F)).
;       "Total" Returns the sum of the duplicate locations (Total(F)).
;   EPSILON (IN:Array) A two element array for spatial tolerance to handle
;               duplicates; default is delta/2.
;   /CLIP_EDGE - Include [XY]BOUND values as the edge pixels; Default is to add
;               half pixel to [XY]BOUND so that the pixel edge align with
;               [XY]BOUND. Take caution while using this keyword output data
;               to a Global grid where 180W = 180E.
;   /INTERP -   Use IMSL function to surface interpolation from scattered data
;   /DOUBLE -   Output array in double
;   /FAST -     For fast gridding using VALUE_LOCATE(). Caution!- has
;               non-integer limitations as in VALUE_LOCATE()
;   FILTER (IN:Value) Value to filter out from the input "Z" before griding
;
;   COUNT (OUT:Variable) A named variable to return number samples falling in
;               output grid.
;   XOUT (OUT:Variable) A named variable to store regularly spaced rectangular
;               output X grids (2D array)
;   YOUT (OOT:Variable) A named variable to store regularly spaced rectangular
;               output Y grids (2D array)
;   XVOUT (OUT:Variable) A named variable to store regularly spaced X vector
;   YVOUT (OOT:Variable) A named variable to store regularly spaced Y vector
;   RESULT - 2D array (XOUT, YOUT and RESULT have same size)
;
; EXTERNAL CALLS:
;   FLTSCL.pro
;   V_LOCATE.pro
;   IS_DEFINED.pro
;
; LIMITATIONS:
;   As in VALUE_LOCATE() function (not recommended for fine resolution grids)
;
; $Id: GRID_XYZ.pro,v 1.0 02/04/2008 15:07:29 yaswant Exp $
; GRID_XYZ.pro Yaswant Pradhan
; Last modification: Apr 08    
;   Jun 2009 - added filter keyword. YP
;   Oct 2010 - added CLIP_EDGE keyword. YP
;   Oct 2010 - added INTERP keyword. YP
;   Nov 2010 - bug fix in average method. YP (29Nov10)
;   Jun 2013 -
;-
        
    syntax  = 'Result = grid_xyz( X, Y, Z [,XBOUND=vector] [,YBOUND=vector]'+$
        ' [,DELTA=vector] [,DIMENSION=vector] [,DUPLICATES=string]'+$
        ' [,COUNT=variable] [,EPSILON=vector] [,XOUT=variable]'+$
        ' [,YOUT=variable] [,/DOUBLE] [/FAST])'
        
    ; Parse Input --
    if n_params() lt 3 then message,'Syntax Error! '+string(10b)+syntax
    n_x   = n_elements(x) ;number if elements in x vector
    n_y   = n_elements(y) ;number if elements in y vector
    n_z   = n_elements(z) ;number if elements in z vector
    
    if ( ((n_x eq n_y) * (n_y eq n_z) * (n_z eq n_x)) eq 0 ) then $
        message,'X, Y, Z array must have equal number of elements.'
        
        
    dbl   = keyword_set(double)
    fst   = keyword_set(fast)
    filt  = is_defined(filter)
    xyin  = 0b
    
    if (N_ELEMENTS(xin) gt 1 and N_ELEMENTS(yin) gt 1) then begin
        xyin = 1b
        xb  = [MIN(xin,/NaN), MAX(xin)]
        yb  = [MIN(yin,/NaN), MAX(yin)]
        nX  = N_ELEMENTS(xin)
        nY  = N_ELEMENTS(yin)
        del = [xin[1]-xin[0], yin[1]-yin[0]]
    endif
    
    xb    = is_defined(xb)  ? xb  : [-180., 180.]         ; LON (X) Limit
    yb    = is_defined(yb)  ? yb  : [-90., 90.]           ; LAT (Y) Limit
    del   = is_defined(del) ? del : [1., 1.]              ; Output Grid Resolution
    del   = n_elements(del) eq 1 ? replicate(del,2) : del ; Parse del
    
    ; Number of grid points along X and Y
    nX    = xyin ? nX $
        : is_defined(dim) $
        ? round(dim[0]) $
        : round((xb[1]-xb[0]) / del[0])
        
    nY    = xyin ? nY $
        : is_defined(dim) $
        ? round(dim[1]) $
        : round((yb[1]-yb[0]) / del[1])
        
    epsi  = is_defined(epsi) ? epsi : del/2.            ; Resample Tolerance
    epsi  = n_elements(epsi) eq 1 ? replicate(epsi,2) : epsi  ; Parse epsi
    dups  = is_defined(dups) ? strlowcase(dups) : 'avg' ; Sampling Method
    
    ; --------------
    
    
    if filt then begin
        print,' Filter Z : ', filter
        mask = where( z eq filter, n_mask)
        print,' Points excluded : ', n_mask
        if( n_mask gt 0 ) then z[mask] = !values.f_nan
    endif
    
    
    
    ; Lower-left and Upper-right pixel centre
    minX  = KEYWORD_SET(clip_edge) ? xb[0] : xb[0] + del[0]/2.
    maxX  = KEYWORD_SET(clip_edge) ? xb[1] : xb[1] - del[0]/2.
    minY  = KEYWORD_SET(clip_edge) ? yb[0] : yb[0] + del[1]/2.
    maxY  = KEYWORD_SET(clip_edge) ? yb[1] : yb[1] - del[1]/2.
    
    
    ; Rescale X and Y vector and Construct X, Y, Z arrays (2D)
    Xs = xyin ? xin : fltscl( findgen(nX), low=minX, high=maxX )
    Ys = xyin ? yin : fltscl( findgen(nY), low=minY, high=maxY )
    grid_X = Xs # replicate(1.,nY)
    grid_Y = replicate(1.,nX) # Ys
    grid_Z = dbl ? make_array( nX,nY, /double, value=!values.d_nan ) : $
        make_array( nX,nY, value=!values.f_nan )
    cntr = fltarr(nX,nY)
    
    ; Redefine x,y,z based on XBOUND and YBOUND
    w = WHERE(x ge xb[0] and x le xb[1] and y ge yb[0] and y le yb[1], n_z)
    if (n_z eq 0) then begin
        message,'Not enough data within the extent',/CONTINUE,/NOPREFIX
        return, grid_Z
    endif
    ; Shrink data to X and Y extent:
    x = x[w]
    y = y[w]
    z = z[w]
    n_x=(n_y=n_z)
    
    
    if KEYWORD_SET(interp) then begin
    
        ; Define the grid used to evaluate the computed surface.
        xydata = [REFORM(x,1,n_x), REFORM(y,1,n_y)]
        grid_Z = IMSL_SCAT2DINTERP(xydata, z, Xs, Ys)
        
    endif else begin
    
        ; Loop through all input elements
        message,'Resampling '+strtrim(n_z,2)+' scattered points to ['+$
            strtrim(nX,2)+','+strtrim(nY,2)+'] grid...',/CONT,/NOPREF
            
        for i=0L,n_z-1 do begin
            px = fst ? value_locate(Xs, x[i]) : v_locate(Xs, x[i])
            py = fst ? value_locate(Ys, y[i]) : v_locate(Ys, y[i])
            
            
            if(px ne -1 and py ne -1) then begin
                if(abs(Xs[px] - x[i]) le epsi[0] and $
                    abs(Ys[py] - y[i]) le epsi[1]) then begin
                    
                    ; Total number of samples in output grid
                    if finite(z[i]) then ++cntr[px,py]
                    
                    case dups of
                        ; Save first value falling in the output grid
                        'first':  grid_Z[px,py] = finite(grid_Z[px,py]) $
                            ? grid_Z[px,py] : z[i]
                            
                        ; Save last value falling in the output grid
                        'last':   grid_Z[px,py] = finite(z[i]) ? z[i] : grid_Z[px,py]
                        
                        ; Save minimum of values falling in the output grid
                        'min':    grid_Z[px,py] = min([ grid_Z[px,py], z[i] ],  /NaN)
                        
                        ; Save maximum of values falling in the output grid
                        'max':    grid_Z[px,py] = max([ grid_Z[px,py], z[i] ],  /NaN)
                        
                        ; Save sum of values falling in the output grid
                        'total':  grid_Z[px,py] = total([ grid_Z[px,py], z[i] ],/NaN)
                        
                    ; Keep sum of values falling in the output grid to
                    ; compute average later
                    else :    grid_Z[px,py] = total([ grid_Z[px,py], z[i] ],/NaN)
                    
                endcase
                
            endif
        endif
        
    endfor  ; for i=0,n_z-1 do begin
    ; Compute average of all samples in each grid
    if (dups eq 'avg') then grid_Z /= cntr
    
endelse

return, grid_Z

end
