;+
; :NAME:
;       orifit
;
; :PURPOSE:
;       The ORIFIT function fits the paired data {xi, yi} to the linear model,
;       y = Mx + 0. Result returns a 4 element vector containing the linear
;       model parameters [0, M, r2, rms].
;
; :SYNTAX:
;       Result = ORIFIT(X, Y [,YFIT=variable] [,/VERB])
;
; :PARAMS:
;    X (in:array) An n-element vector containing the independent variable
;           values. X may be of type integer, floating point, or double-
;           precision floating-point.
;    Y (in:array) An n-element integer, single-, or double-precision
;           floating-point vector.
;
;
; :KEYWORDS:
;    YFIT (out:variable) Set this keyword equal to a named variable that will
;           contain the vector of calculated Y values.
;
;    /VERBOSE Verbose mode
;
; :REQUIRES:
;
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
;  Oct 13, 2006 19:25:13 Created. Yaswant Pradhan. @UoP
;  Jan 2008 Imported to myidl library at Met Office. YP
;
;-

FUNCTION orifit, X, Y, YFIT=est, VERBOSE=verbose


    ; Parse input
    syntax='Result = ORIFIT( X, Y [,YFIT=variable] [,/VERB] )'

    if (N_PARAMS() ne 2) then message, syntax

    if (N_ELEMENTS(X) ne N_ELEMENTS(Y)) then $
        message,'Error! X and Y must be vectors of equal length.'

    if (N_ELEMENTS(X) LT 2.) then $
        message,'Error! X and Y must be arrays of at least 2 elements'


    ; Calculate fit parameters
    nPts    = N_ELEMENTS(X)
    offset  = 0.
    slope   = TOTAL(Y * X) / TOTAL(X * X)
    est     = slope*X + offset                  ; Predicted Y
    SStot   = TOTAL((Y - MEAN(Y))^2.)           ; Sum square
    SSreg   = TOTAL((Y - est)^2.)               ; Regression Sum square
    rsq     = (SStot-SSreg) / SStot             ; Coefficient of determination
    rms     = SQRT(TOTAL((Y-est)^2.) / nPts)    ; RMS of estimation


    ; Print out stats
    if KEYWORD_SET(verbose) then begin
        print, REPLICATE('-',40)
        print, STRING(['N','Slope','Offset','TotalSS','RegSS','r^2','rmse'], $
            FORM='(a10)')
        print, STRING([nPts,slope,offset,SStot,SSreg,rsq,rms], FORM='(a10)')
        print, REPLICATE('-',40)
    endif


    ; Return fit parameters and regression result
    return, [offset, slope, rsq, rms]

END