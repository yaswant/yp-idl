;Nearest Integer Function
FUNCTION nint, x, LONG=long
;+
;NAME:
;   NINT
;
;PURPOSE:
;   Nearest integer function.
;
;EXPLANATION:
;   NINT() is similar to the intrinsic ROUND function, with the following
;   two differences:
;   (1) if no absolute value exceeds 32767, then the array is returned as
;       as a type INTEGER instead of LONG
;   (2) NINT will work on strings, e.g. print,nint(['3.4','-0.9']) will
;       give [3,-1]
;
;CALLING SEQUENCE:
;   result = NINT( x, [ /LONG] )
;
;INPUT:
;   x - An IDL variable, scalar or vector, usually floating or double
;       Unless the LONG keyword is set, X must be between -32767.5 and
;       32767.5 to avoid integer overflow
;
;OUTPUT
;   RESULT - Nearest integer to x
;
;OPTIONAL KEYWORD INPUT:
;   LONG - If this keyword is set and non-zero, then the result of NINT
;       is of type LONG.   Otherwise, the result is of type LONG if
;       any absolute values exceed 32767, and type INTEGER if all
;       all absolute values are less than 32767.
;EXAMPLE:
;   If x = [-0.9,-0.1,0.1,0.9] then NINT(x) = [-1,0,0,1]
;
;PROCEDURE CALL:
;   None:
;
;REVISION HISTORY:
;   Use ROUND if since V3.1.0  June 1993
;   Always start with ROUND function    April 1995
;   Return LONG values, if some input value exceed 32767
;       and accept string values   February 1998
;       Use size(/TNAME) instead of DATATYPE()      October 2001
;-

    xmax = MAX(x, MIN=xmin)
    xmax = ABS(xmax) > ABS(xmin)
    
    if (xmax gt 32767) or KEYWORD_SET(long) then begin
        b = (SIZE(x,/TNAME) eq 'STRING') ? ROUND(FLOAT(x)) : ROUND(x)
    end else begin
        b = (SIZE(x,/TNAME) eq 'STRING') ? FIX(ROUND(FLOAT(x))) : FIX(ROUND(x))
    endelse
    
    return, b
    
END
