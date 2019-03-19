function mode, array, BINSIZE=binsz, DIAG=diag, NAN=nan
    ;+
    ; :NAME:
    ;    	mode
    ;
    ; :PURPOSE:
    ;       Calculate statitical mode of an array.
    ;       Warning! Be careful with floating-point arrays. Binsize can be used
    ;       to deal with floating-point arrays, bu the result will be picked 
    ;       from the binned array rather than the original array.
    ;
    ; :SYNTAX:
    ;       Result = mode( Array [,BINSIZE=value] )
    ;
    ; :PARAMS:
    ;    array (in:array) Integer (or floating-point) array to get the mode.
    ;
    ;
    ; :KEYWORDS:
    ;    BINSIZE (in:value) Bin the original data array into equally spaced bins.
    ;           useful for floating-point arrays
    ;    /DIAG - Set this keyword in conjunction with BINSIZE to plot data
    ;           distribution
    ;
    ; :REQUIRES:
    ;
    ;
    ; :EXAMPLES:
    ;
    ;
    ; :CATEGORIES:
    ;   Stat
    ; :
    ; - - - - - - - - - - - - - - - - - - - - - - - - - -
    ; :COPYRIGHT: (c) Crown Copyright Met Office
    ; :HISTORY:
    ;  17-Jul-2014 14:00:20 Created. Yaswant Pradhan.
    ;
    ;-

    
    if KEYWORD_SET(nan) then begin
        w = WHERE(FINITE(array), nw)
        if (nw eq 0) then return,!values.f_nan
        arrayf =  array[w]
    endif else arrayf = array
    
    
    if KEYWORD_SET(binsz) then begin    
        hist = HISTOGRAM([arrayf], BINSIZE=binsz, LOCATIONS=loc)
        wh = WHERE(hist eq MAX(hist))
        md = loc[wh]
        
        if KEYWORD_SET(diag) then begin
            plot, loc, hist, xtitle='Value', ytitle='Frequency'
            for i=0,N_ELEMENTS(md)-1 do begin
                oplot, REPLICATE(md[i],2), !y.crange, LINESTYLE=1
                xyouts, md[i], (hist[wh])[i],$
                    STRING(md[i],(hist[wh])[i],'("(",f0.3,", ",i0,")")')
            endfor
        endif        
    endif else begin            
        f = INTARR(MAX(arrayf) - MIN(arrayf)+1)
        f[arrayf - MIN(arrayf)]++
        void = MAX(f, idx)
        md = idx + MIN(arrayf)
    endelse
    return, md
    
end

