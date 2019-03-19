;+
; :NAME:
;       stat1
;
; :PURPOSE:
;       Simple statistics from a univariate sample.
;
; :SYNTAX:
;
;
; :PARAMS:
;    array
;
;
; :KEYWORDS:
;    NORMALISED (out:variable) returns the normalised (0-1) form of input array
;    STANDARDISED (out:variable) returns the standardised form of input array
;    RANGE (out:variable) returns [min,max] value of the input array
;    NOBS (out:variable) returns the total number of finite observations
;    MEAN (out:vraiable) returns mean of the input array
;    MEDIAN (out:variable) returns median of the input array
;    STD (out:variable) returns the standard deviation of the input array
;    MAD (out:variable) returns the mean absolute deviation of the input array
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
;  Sep 13, 2012 1:13:50 PM Created. Yaswant Pradhan.
;
;-
pro stat1, array,       $
        NORMALISED=norm1,   $
        STANDARDISED=stand1,$
        RANGE=range,        $
        NOBS=nEl,           $
        MEAN=mean1,         $
        MEDIAN=med1,        $
        STD=stdv1,          $
        MAD=madv1,          $
        QUIET=quiet
        
        
        
    stntax = 'stat1, array [,..]'
    if (N_PARAMS() eq 0) then message, syntax
    
    w = WHERE(FINITE(array),nEl)
    if (nEl eq 0) then message,'No finite data in the array.'
    
    range = [MIN(array,/NaN), MAX(array,/NaN)]
    momnt = MOMENT(array,/NaN, SDEV=stdv1, MDEV=madv1)
    mean1 = momnt[0]
    med1  = MEDIAN(array[w])
    if ~FINITE(stdv1) then message,'Warning! NaN STDDEV.',/CONTINUE
    
    if ARG_PRESENT(norm1) then begin
        norm1 = array
        norm1[w] = (array[w]-range[0]) / (range[1]-range[0])
    endif

    if ARG_PRESENT(stand1) then begin
        stand1 = array
        stand1[w] = (array[w]-mean1[w]) / stdv1
    endif

    if ~KEYWORD_SET(quiet) then begin
        print,[' Nobs','Min','Max','Mean','Med','SDev','MDev','Skew','Kurt']+$
            STRING([nEl, range, mean1, med1, stdv1, madv1, momnt[2], momnt[3]],$
            FORMAT='(2X,G0)')+STRING(10b)
    endif
    
end