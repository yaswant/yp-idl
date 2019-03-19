;+
; :NAME:
;       rmafit
;
; :PURPOSE:
;       The RMAFIT function fits the paired data {xi, yi} to the linear model,
;       y = mx + c, using reduced-major axis regression (or Model II) method*.
;       Optionally, it saves the linear regression statistics (see optional
;       keywords).
;
;      * It takes account of measurement errors in both X and Y.
;
; :SYNTAX:
;       Result = RMAFIT(X, Y [,SERROR=Variable] [,CONF95=Variable]
;                       [,R2=Variable] [,RANK_R=Variable])
;
; :PARAMS:
;    X (in:array) Independent variable array of any type except string
;    Y (in:array) Dependent variable array of any type except string
;
;
; :KEYWORDS:
;    SERROR (out:variable) A named variable to store estimated standard errors
;                   for slope and offset [c_error, m_error].
;
;    CONF95 (out:variable) A named variable to store 95% confidence limits
;                   for slope and offset [c95_0,c95_1,m95_0,m95_1].
;
;    R2 (out:variable) A named variable to store the coefficient of
;                   determination using Pearson's correlation coefficient.
;
;    RANK_R (out:variable) A named variable to store the correlation
;                   coefficient and significance of its deviation from 0 using
;                   Spearman's Rank correlation coefficient [rankR, rankSig].
;
;    YFIT (out:variable) Set this keyword equal to a named variable that will
;                   contain the vector of calculated Y values.
;
;    /DOUBLE  Set this keyword to force the computation to be done in
;                   double-precision arithmetic.
;    /SILENT  Set this keyoword to suppress warnings
;
; :REQUIRES:
;       none
;
; :EXAMPLES:
;   IDL> x=[14, 17, 24, 25, 27, 33, 34, 37, 40,  41, 42]
;   IDL> y=[61, 37, 65, 69, 54, 93, 87, 89, 100, 90, 97]
;   IDL> print, rmafit(x, y, SERROR=se, CONF95=cl, R2=rsq, RANK_R=rank,/DOUBLE)
;       12.193785       2.1193664
;   IDL> print,se
;       10.549750      0.33249586
;   IDL> print,cl
;      -11.671420       36.058990       1.3672081       2.8715247
;
;   IDL> print,rsq, rank
;      0.77848511     0.836364   0.00133318
;
;
; REFERENCE:
;   Sokal, R. R., and F. J. Rohlf. 1981. Biometry. 2nd edition. Freeman, NY.
;
;
; :CATEGORIES:
;   Statistics, Least-square estimation
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  July 18, 2007 18:47:01 Created. Yaswant Pradhan. @UoP
;  Aug 06, 2012 Replace garbage outputs values from -999 to NaN. YP @Met Office
;  Aug 02, 2012 Code optimised. Added yfit keyword. YP
;  May 16, 2014 Added silent keyword. YP
;
;-

FUNCTION rmafit, X, Y,  $
        SERROR=s_err,       $
        CONF95=conf_95,     $
        R2=r2,              $
        RANK_R=rank_r,      $
        YFIT=yfit,          $
        DOUBLE=double,      $
        SILENT=silent

    ON_ERROR, 2

    syntax = 'Result = RMAFIT( X, Y [,SERROR=Variable] [,CONF95=Variable] '+$
        '[,R2=Variable] [,RANK_R=Variable] [,YFIT=Varianle] [,/DOUBLE]'+$
        '[,/SILENT])'
    if (N_PARAMS() lt 2) then message, sytnax


    ; Parse input:
    _nan= !VALUES.F_NAN
    nx  = N_ELEMENTS(X)
    ny  = N_ELEMENTS(Y)
    dl  = KEYWORD_SET(double)
    if (nx NE ny) then begin
        message,' Input arrays (X and Y) must be of equal length'
    endif


    ; Sanity check:
    n   = nx
    n1  = n-1
    df  = n-2

    if (n le 2) then begin
        if ~KEYWORD_SET(silent) then $
            message,'RMAFIT Inadequate number of samples',/CONTINUE
        s_err   = REPLICATE(_nan,2)
        conf_95 = REPLICATE(_nan,4)
        rank_r  = REPLICATE(_nan,2)
        r2      = _nan
        return, REPLICATE(_nan,2)
    endif



    ; Calculate Slope and Intercept
    corr    = CORRELATE(X,Y,DOUBLE=dl)
    sign    = (corr GE 0) ? 1 : -1
    slope   = sign * SQRT(VARIANCE(Y,DOUBLE=dl) / VARIANCE(X,DOUBLE=dl))
    intercept = MEAN(Y,DOUBLE=dl) - slope*MEAN(X,DOUBLE=dl)


    ; Save Optional variables:
    if ARG_PRESENT(yfit) then yfit = slope*X + intercept
    if ARG_PRESENT(r2) then r2 = corr^2
    if ARG_PRESENT(rank_r) then rank_r = R_CORRELATE(X,Y)
    if (ARG_PRESENT(s_err) or ARG_PRESENT(conf_95)) then begin
        ; Caluculate Mean-squared Error:
        mse = (VARIANCE(Y,DOUBLE=dl) - CORRELATE(X,Y,DOUBLE=dl,/COVAR)^2 / $
            VARIANCE(X,DOUBLE=dl)) * n1/df


        ; Standard error and 95% confidence limits for intercept:
        SEintercept = SQRT(mse * ((1./n) + MEAN(X,DOUBLE=dl)^2 / $
            VARIANCE(X,DOUBLE=dl)/n1))
        intercept95 = intercept + [-1, 1]*T_CVF(0.025, df)*SEintercept


        ; Standard error and 95% confidence limits for slope:
        SEslope = SQRT( mse / VARIANCE(X,DOUBLE=dl)/n1 )
        slope95 = slope + [-1, 1]*T_CVF(0.025, df)*SEslope

        s_err   = [SEintercept, SEslope]
        conf_95 = [intercept95, slope95]
    endif


    ; Return fit parametrs:
    return,[intercept, slope]

END
