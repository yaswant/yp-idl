FUNCTION SIGTEST, r, N
;+
; :NAME:
;     SIGTEST
;
; :PURPOSE:
;     Significance Test of correlation r and sample size N.
;
; :SYNTAX:
;     Result = SIGTEST(r, N)
;
;  :PARAMS:
;    r (IN:Value) Correlation coefficient between -1 and 1
;    N (IN:Value) Sample size
;
;
; :REQUIRES:
;
;
; :EXAMPLES:
;   IDL> result = SIGTEST(0.67, 23)
;   IDL> print, result
;     99.000000    0.0013126156
;
; :CATEGORIES:
;   Statistics
;
;
; :THEORY and INTERPRETATION:
;   Prob: Probability that random noise could produce the result (correlation) 
;       with N samples, Prob = ERFC(r*sqrt(N/2))
;       ERFC: Complementary Error Function
;   rsig: At which we have 100*(1-limit) chance that random data would produce 
;       this result (r) rsig = INVERF(limit)*sqrt(2/N)
;       Any "r" value greater than "rsig" are significant at "limit*100" level
;
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  28-Feb-2006 12:12:43 Created. Yaswant Pradhan. University of Plymouth.
;  07-Dec-2010 15:56:22 Updated for version compatibility. YP.
;  24-May-2016 Finer steps, wider ci. YP. 
;-


    if (n_params() LT 2) then RETURN, [0.,0.]
    r = DOUBLE(r)
    N = DOUBLE(N)
    Prob = 0D
    rsig = !VALUES.D_NAN
    i = 0.999 ; confidence interval
    step = 0.001
    
    if (r gt 1.0 or r lt -1.0) then begin
        MESSAGE, 'r value should be between -1.0 and 1.0. Input r, N again!'        
    endif
    
    r = ABS(r)
    Prob = ERFC(r*SQRT(N/2.))
    
    if (!version.RELEASE lt 6.4) then begin
        while (INVERF(i)*SQRT(2./N) gt r) do begin
            i = i - step
            rsig = INVERF(i)*SQRT(2./N)
        endwhile        
    endif else begin        
        while (IMSL_ERF(i, /INVERSE)*SQRT(2./N) gt r) do begin
            i = i - step
            rsig = IMSL_ERF(i,/INVERSE)*SQRT(2./N)
        endwhile        
    endelse
    
    ptable = [0.001, 0.01, 0.05, 0.1, 1]        
    print,replicate('-', 20)
    print,' Correlation Significance Test Summary'
    print,replicate('-', 20)
    print,' corr. coeff r (input)  : ',r, FORM='(a, g0)'
    print,' num. samples n (input) : ',N, FORM='(a, g0)'
    print,' Confidence Limit       : '+string(i*100,FORM='(g0)')+'%'
    print,' Probability            : ',Prob, FORM='(a,g0)'
    if FINITE(rsig) then $ 
    print,' r threshold*           : ',rsig,FORM='(a,g0)'
    print,' p <= ',ptable[(where(Prob le ptable))[0]],FORM='(a,g0)'
    print,replicate('-', 20)
    
    RETURN, [i*100, Prob]
    
END

