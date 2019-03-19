pro stat2, reference, model, outs, FILTER=filter, LOG=log, SILENT=silent
    ;+
    ; :NAME:
    ;    	stat2
    ;
    ; :PURPOSE:
    ;
    ;
    ; :SYNTAX:
    ;       stat2, X, Y, out [,FILTER=value] [,/LOG] [,/SILENT]
    ;
    ; :PARAMS:
    ;    reference (in:array)
    ;    model (in:array)
    ;    outs (out:struct)
    ;
    ;
    ; :KEYWORDS:
    ;    FILTER (in:value)
    ;    /LOG Log transfor data
    ;    /SILENT Quiet mode
    ;
    ; :REQUIRES:
    ;   is_defined.pro
    ;   rmafit.pro
    ;   helps.pro
    ;
    ; :EXAMPLES:
    ;
    ;
    ; :CATEGORIES:
    ;
    ; :NOTE:
    ; To get Fractional Gross Error use the following formula
    ;   FGE = URMSP / 100.
    ;
    ; :
    ; - - - - - - - - - - - - - - - - - - - - - - - - - -
    ; :COPYRIGHT: (c) Crown Copyright Met Office
    ; :HISTORY:
    ;  03-Dec-2012 18:07:03 Created. Yaswant Pradhan.
    ;
    ;-


    if (N_PARAMS() lt 2) then begin
        MESSAGE,'stat2, x, y [,/LOG] [,FILTER=value]',/CONTINUE
        return
    endif
    
    _nan = !values.f_nan
    if is_defined(filter) then begin
        w = WHERE(reference ne filter and model ne filter, nw)
        x = KEYWORD_SET(log) ? ALOG10(reference[w]) : reference[w]
        y = KEYWORD_SET(log) ? ALOG10(model[w]) : model[w]
    endif else begin
        x = KEYWORD_SET(log) ? ALOG10(reference) : reference
        y = KEYWORD_SET(log) ? ALOG10(model) : model
    endelse
    ny = N_ELEMENTS(y)
    
    outs = {$
        rmse: _nan,$    ; Root Mean Square Error (RMSE)
        urmse: _nan,$   ; Unbiased RMSE (usually indicates model precision)
        bias: _nan,$    ; Bias (indicates model accuracy)
        rmsp: _nan,$    ; Relative percentage RMSE
        urmsp: _nan,$   ; Unbiased relative percentage RMSE (/100 = Fractional
        ; Gross Error)
        ;        fge: _nan,$     ; Fractional Gross Error (FGE) = urmsp/100.
        amep: _nan,$    ; Relative percent Absolute Mean Error, also known as
        ; Normalised Mean Error (NME)
        mnrat: _nan,$   ; Mean Ratio
        mdrat: _nan,$   ; Median Ratio
        r: _nan,$       ; Linear correlation (Pearsons)
        rho: _nan,$     ; Rank Correlation (Spearmans)
        slope: _nan,$   ; slope using reduced-major axis model
        offset: _nan,$  ; offset using reduced-major axis model
        N: ny,   $      ; Number of Obs
        rho_sig: _nan,$ ; Significance of ank Correlation (Spearmans)
        minx: _nan, $   ; Minimum value of X
        miny: _nan, $   ; Minimum value of Y
        maxx: _nan, $   ; Maximum value of X
        maxy: _nan, $   ; Maximum value of Y
        medx: _nan, $   ; Median value of X
        medy: _nan, $   ; Median value of Y
        avgx: _nan, $   ; Average value of X
        avgy: _nan, $   ; Average value of Y
        stdx: _nan, $   ; Standard deviation of X
        stdy: _nan, $   ; Standard deviation of Y
        madx: _nan, $   ; Mean absolute deviation of X
        mady: _nan, $   ; Mean absolute deviation of Y
        skewx: _nan, $
        skewy: _nan, $
        kurtx: _nan, $
        kurty: _nan $
        }
        
    mom_x = MOMENT( x, MEAN=av_x, SDEV=sd_x, MDEV=mad_x, $
        SKEWNESS=skew_x, KURTOSIS=kurt_x, /NAN )
    mom_y = MOMENT( y, MEAN=av_y, SDEV=sd_y, MDEV=mad_y, $
        SKEWNESS=skew_y, KURTOSIS=kurt_y, /NAN )
    ; av_x = MEAN(x, /NAN)
    ; av_y = MEAN(y, /NAN)
        
    fits = rmafit(x,y, /SILENT)  ; linear fit parametrs using type-2 regression
    outs.rmse = SQRT(MEAN((y-x)^2, /NAN))
    outs.urmse = SQRT(MEAN( ((y-av_y) - (x-av_x))^2 ))
    outs.bias = MEAN(y-x, /NaN)
    outs.rmsp = SQRT(MEAN((y-x)^2, /NAN))/av_x * 100     ; this?
    ;    outs.rmsp = MEAN(SQRT(((y-x)/x)^2), /NaN) * 100.     ; Or this?
    outs.urmsp = MEAN(SQRT(((y-x)/(0.5*y + 0.5*x))^2), /NAN) * 100.
    outs.amep = MEAN(ABS(y-x), /NAN)/av_x * 100          ; this?
    ;    outs.amep = MEAN(ABS((y-x)/x), /NAN) * 100.          ; Or this?
    outs.mnrat = MEAN(y/x, /NAN)
    outs.mdrat = MEDIAN(y/x)
    outs.r = CORRELATE(x,y)
    if (ny gt 1) then begin
        rc = R_CORRELATE(x, y)
        outs.rho = rc[0]
        outs.rho_sig = rc[1]
    endif
    outs.slope = fits[1]
    outs.offset = fits[0]
    ;    outs.fge = 2 * MEAN( ABS((y-x)/(y+x)),/NAN )
    
    ;; Individual Variable Stats:
    outs.minx = MIN(x, /NAN)
    outs.miny = MIN(y, /NAN)
    outs.maxx = MAX(x, /NAN)
    outs.maxy = MAX(y, /NAN)
    outs.medx = MEDIAN(x)
    outs.medy = MEDIAN(y)
    outs.avgx = av_x
    outs.avgy = av_y
    outs.stdx = sd_x
    outs.stdy = sd_y
    outs.madx = mad_x
    outs.mady = mad_y
    outs.skewx = skew_x
    outs.skewy = skew_y
    outs.kurtx = kurt_x
    outs.kurty = kurt_y
    
    if ~KEYWORD_SET(silent) then HELP,outs,/STRUCT
end