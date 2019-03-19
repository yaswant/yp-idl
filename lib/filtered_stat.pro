FUNCTION filtered_stat, Array, SIGMA=sd, CV=cv, MISSING=missing, VERBOSE=verbose
;+
; :NAME:
;    	filtered_stat
;
; :PURPOSE:
;       Estimates the average value from a univariate array with specific 
;       filters applied (Sigma and coefficient of variation threshold) to 
;       eliminate outliers in the array.
;        
;       Result is a 4-element vecotr containing [MEAN, MEDIAN, STDDEV, N] 
;       of the filtered array.  
;       Warning! If the array doesnot pass the filter criteria an array 
;       resulting [-99., -99., -99, 0] is returned.
;
; :SYNTAX:
;       Result = filtered_stat(Array [,SD=value] [,CV=value] [,MISSING=value]
;                                [,/VERBOSE])
;
; :PARAMS:
;    Array (in:array) 
;       Numeric array for average value calculation
;
; :KEYWORDS:
;    SIGMA (in:value) 
;       The cutoff threshold standard deviation, e.g., +/-2sigma (def: 1.5σ)
;    CV (in:value) 
;       Accepted percent of variation (def: 0.15 or 15%) 
;       Note: CV is computeds as (stdev/median) not (stdev/mean)
;    MISSING (in:value) 
;       Missing value to ignore in stats (def: RMDI)
;    /VERBOSE 
;       Verbose mode
;
; :REQUIRES:
;       get_sps_constants.pro
;       is_defined.pro
;
; :EXAMPLES:
; IDL> print,filtered_stat(findgen(11))
;      5.00000      5.00000      2.73861      9.00000
;
;
; IDL> print,filtered_stat(findgen(11), SIGMA=2)
;      5.00000      5.00000      3.31662      11.0000
;
; IDL> print,FILTERED_stat(findgen(11), CV=0.15)
;      -99.0000     -99.0000     -99.0000     -99.0000
;
;
; :CATEGORIES:
;       Statistical analysis
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  May 01, 2006 19:25 Created. Yaswant Pradhan.
;
;-


; Parse Inputs
if (n_params() LT 1) then begin
    message,'Result = comp_OBPG_avg ( Array [SD=value] [,CV=value] )',/CONTINUE
    RETURN, -1
endif

; Intialise Parameters:
missing = is_defined(missing) ? missing : get_sps_constants('RMDI')
_miss   = -99.
verb    = KEYWORD_SET(verbose)
sd      = is_defined(sd) ? sd : 1.5
x       = WHERE(FINITE(Array) and Array gt missing, nx)
nores   = [REPLICATE(_miss,3),0]
if (nx eq 0) then return, nores 


; simple stats of the original array:
avgArr  = mean(Array[x])
medArr  = median(Array[x])
stdArr  = (nx lt 2) ? 0: stddev(Array[x])

; Include all values within thresh range:
thresh  = [medArr-sd*stdArr, medArr+sd*stdArr] 
w = where(Array ge thresh[0] and Array le thresh[1], nw)


case nw of
    0   : result = nores                            ; No valid samples
    1   : result = [Array[w], Array[w], _miss, nw]  ; Too few samples
    else: begin
    ; Further check for homogenity of the already sigma-filtered samples    
    ; Get stats only if the ratio (STDEV/MEDIAN < CVAR) - this test is 
    ; performed only if CV keyword is defined, else the sigma-filtered stats
    ; are returned.
        result = is_defined(cv) $
                 ? (abs(stddev(Array[w]) / median(Array[w],/EVEN)) le cv) $
                   ? [mean(Array[w]),median(Array[w]),stddev(Array[w]),nw] $
                   : nores $
                 : [mean(Array[w]),median(Array[w]),stddev(Array[w]),nw]  
    end
endcase


;------------------------------------------------------------------------------
if verb then begin
    print,'-------------------------------------------------------'
    print,'ORIGINAL STAT (min, max, avg, med, std):'
    print, FORM='(%"(%f, %f, %f, %f, %f)\n")',$
           min(Array,/NAN),max(Array,/NAN),mean(Array,/NAN),$
           median(Array), stddev(Array,/NAN)
    
    print,'FILTERED STAT without CV (min,max,avg,med,std):'
    print, FORM='(%"(%f, %f, %f, %f, %f)")',$
           min(Array[w],/NAN),max(Array[w],/NAN),mean(Array[w],/NAN), $
           median(Array[w]), stddev(Array[w],/NAN)
    print,'-------------------------------------------------------'
    print,' Ratio    : ',strtrim(stddev(Array[w]) / median(Array[w],/EVEN),1)
    print,' Threshold: ',STRJOIN(strtrim(thresh,1),' to ')
    print,' Coeff Var: ',(KEYWORD_SET(cv) ? strtrim(cv,1) : 'Undefined')
    print,' Sigma    : ',strtrim(sd,1)    
    print,'-------------------------------------------------------'
endif
;------------------------------------------------------------------------------

return, result

END
