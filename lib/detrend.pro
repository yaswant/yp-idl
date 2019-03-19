FUNCTION detrend, Y, X, RANGE=range, ANOMALY=rmean, $
         STANDARDISE=standardise, DIAGNOSE=diagnose

;+
; :NAME:
;     detrend
;
; :PURPOSE:
;     To remove "linear trend" from a time-series data
;
; :SYNTAX:
;     Result = DETREND( Y [,X] [,RANGE=Array] [,ANOMALY=variable]
;                         [,/STANDARDISE] [,/DIAG] )
;
;
;  :PARAMS:
;    Y (IN:Array) 1D time-series aray of any type except string
;    X (IN:Array) Corresponding time data (optional)
;
;
;  :KEYWORDS:
;    RANGE (IN:Array) A 2-element array to restrict the range of time-series data Y
;    ANOMALY (OUT:Variable) A named variable to contain the Original data - mean(Original data) 
;    /STANDARDISE - Detrend series mean will be subtracted from the detrend series and then divided by
;                   the stddev of detrend series. Standardised data will have 0 mean unit variance.
;    /DIAGNOSE - Plot actual and detrend series for diagnosis purpose
;
; :REQUIRES:
;   is_defined.pro
;
; :EXAMPLES:
;   IDL> Y = randomn(seed,50)+findgen(50)+1
;   IDL> result = detrend(Y ,/stand ,/verb)
;   IDL> print, mean(result,/NaN), stddev(result,NaN)
;           -3.98221e-009      1.00000
;
; :CATEGORIES:
;     Statistics, Time-series analysis
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  29/01/2007 19:25:13 Created. Yaswant Pradhan University of Plymouth
;  14-Dec-2010 11:33:14 Clean Code. YP.
;-

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Parse Input
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  syntax = 'Result = DETREND( Y [,X] [,RANGE=Array] ' +$
           '[,ANOMALY=Variable] [,/STANDARDISE] [,/DIAG] )'

  if ( n_params() lt 1 ) then message,syntax

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Set-up default values/keywords
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  X   = (n_params() eq 1) ? dindgen(n_elements(Y))+1 : X
  st  = keyword_set(standardise)
  d   = keyword_set(diagnose)
  nan = !values.f_nan
  range = is_defined(range) ? range : [min(Y,/NaN), max(Y,/NaN)]
  !p.multi  = d ? [0,2,2] : 0



; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Intialise the output array with NaNs
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  result=( rmean = make_array( n_elements(Y), value=nan ) )


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Consider data within the prescribed range, if given     
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  p = where( (Y lt range[0]) or (Y gt range[1]), np )
  if (np gt 0) then Y[p] = nan
  

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Check for sufficient number of finite values in the data
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  wh = where( FINITE(Y), nwh, COMPLEMENT=undef, NCOMPLEMENT=nundef )
  if( nwh lt 1 ) then message,'Insufficient number of finite elements in the series'
  vy = Y[wh]
  
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
; Remove mean from the original data to get anomaly
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  rmean[wh] = vy - MEAN(vy)


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Step 1 Estimate the linear fit and subtract from the 
;        actual time series
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  fit         = LINFIT( X[wh], vy, YFIT=vyfit, /DOUBLE )
  result[wh]  = vy - vyfit

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Plot original, original-mean and detrend data data       
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if d then begin
    print,' Range : ',range
    print,' Mean  : ',MEAN(vy)
    
    plot, X[wh], vy, title='Original data (restrictions applied)', psym=-4
    oplot,X[wh], vyfit, linestyle=3
    
    plot, X[wh], rmean[wh], title='Anomaly (Original - Mean)'
    oplot,X[wh], MAKE_ARRAY(nwh, value=MEAN(vy)), linestyle=3
    
    plot, X[wh], result[wh],title='Detrend (Original - Trend)'
  endif


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Step 2 Standardise the detrend data (0 mean unit variance)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if st then begin    
    result[wh]  = STANDARDIZE(REFORM(result[wh], 1,nwh))
;    result[wh]  = ( result[wh] - MEAN(result[wh])) / STDDEV(result[wh])
  ; Plot standardise detrend data
    if d then plot, X[wh], result[wh], title='Standardised Detrend'
  endif
  
  if d then !p.multi=0
  return, result

END