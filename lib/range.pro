function range, array, DIFF=diff, _EXTRA=_extra
    ;+
    ; :NAME:
    ;    	range
    ;
    ; :PURPOSE:
    ;       Get min, max values in an array
    ;
    ; :SYNTAX:
    ;       Result = range( Array )
    ;
    ; :PARAMS:
    ;    array (in:array) any numeric array
    ;
    ;
    ; :KEYWORDS:
    ;    DIFF If set returns Min-Max difference instead of range
    ;    _EXTRA (see keywords available to native MIN function)
    ;
    ; :REQUIRES:
    ;       None
    ;
    ; :EXAMPLES:
    ;   IDL> arr = FINDGEN(2,3,2)
    ;   IDL> print,range(arr)
    ;      0.00000      11.0000
    ;   IDL> print,range(arr,dim=1)     ; results in [6,2] array
    ;      0.00000      2.00000      4.00000      1.00000      3.00000      5.00000
    ;      6.00000      8.00000      10.0000      7.00000      9.00000      11.0000
    ;   IDL> print,range(arr,dim=2)     ; results in [4,2] array
    ;      0.00000      1.00000      4.00000      5.00000
    ;      6.00000      7.00000      10.0000      11.0000
    ;
    ; :CATEGORIES:
    ;   General stats
    ; :
    ; - - - - - - - - - - - - - - - - - - - - - - - - - -
    ; :COPYRIGHT: (c) Crown Copyright Met Office
    ; :HISTORY:
    ;  26-Oct-2010 16:10:54 Created. Yaswant Pradhan.
    ;
    ;-

    return, KEYWORD_SET(diff) ? $
        (MAX(array,_EXTRA=_extra) - MIN(array,_EXTRA=_extra))$
        : [min(array, MAX=mx, _EXTRA=_extra), mx]
end