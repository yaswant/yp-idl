;+
; :NAME:
;       rot_xy
;
;
; :PURPOSE:
;   Rotate plane coordinates around a pre-defined centre
;   In graphical programming one might want to rotate things at some point.
;   To carry out a rotation using matrices the point (x, y) to be rotated is
;   written as a vector, then multiplied by a matrix calculated from the angle
;   theta, like so:;
;       |x'|      |cos(theta)  -sin(theta)| |x|
;       |  |  =   |                       | | |
;       |y'|      |sin(theta)   cos(theta)| |y|
;
;   where (x', y') are the co-ordinates of the point after rotation,
;   and the formulae for x' and y' (wrt 0 as origin centre) can be written as:
;       x' = x cos(theta) - y sin(theta)
;       y' = y cos(theta) + x sin(theta)
;
;   For rotation around an arbitray centre (xCentre,yCentre)
;       xRot = xCentre + cos(Angle) * (x - xCentre) - sin(Angle) * (y - yCentre)
;       yRot = yCentre + sin(Angle) * (x - xCentre) + cos(Angle) * (y - yCentre)
;
;   xRot and yRot give the rotated point, xCenter and yCenter mark the point
;   that you want to rotate around, x and y mark the original point.
;
; :SYNTAX:
;       rot_xy, xin, yin, xout, yout [,CENTRE=array] [,ANGLE=value] [,/VECTOR]
;
; :PARAMS:
;    xin (in:array) 2D array of X values, xin must conform with yin
;    yin (in:array) 2D array of Y values, yin must conform with xin
;    xout (out:variable) Named variable to store rotated-X (x') array
;    yout (out:variable) Named variable to store rotated-Y (y') array
;
;
; :KEYWORDS:
;    CENTRE (in:array) Position of centre around with the rotation is desired;
;                       default behaviour is to rotate around bottm-left corner
;    ANGLE (in:value) Angle in degrees to rotate the coordinates
;    /VECTOR - If set, the Xin and Yin values are treated as 1D vectors and the
;               2D plane was calculated from the inputs values.
;
; :REQUIRES:
;       is_defined.pro
;       ll_vec2arr.pro
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
;  28-Jun-2013 16:10:29 Created. Yaswant Pradhan.
;
;-

pro rot_xy, xin, yin, xout, yout, CENTRE=centre, ANGLE=angle, VECTOR=vector

    syntax='Syntax: rot_xy, xin, yin, xout, yout [,CENTRE=array] [,ANGLE=value]'

    if N_PARAMS() lt 2 then begin
        MESSAGE,/INFO, syntax
        RETURN
    endif

    angle = is_defined(angle) ? angle : 0.
    if (angle eq 0) then begin
        xout = xin
        yout = yin
    endif else begin
        xc = (N_ELEMENTS(centre) eq 2) ? centre[0] : MIN(xin,/NaN)
        yc = (N_ELEMENTS(centre) eq 2) ? centre[1] : MIN(yin,/NAN)

        if (SIZE(xin,/N_DIM) eq 2) and (SIZE(yin,/N_DIM) eq 2) then begin
            xx = xin
            yy = yin
        endif else ll_vec2arr, xin,yin, xx,yy

        ; xo = xx*COS(angle*!DTOR) - yy*SIN(angle*!DTOR)
        ; yo = yy*COS(angle*!DTOR) + xx*SIN(angle*!DTOR)
        xout = xc + (xx-xc)*COS(angle*!DTOR) - (yy-yc)*SIN(angle*!DTOR)
        yout = yc + (xx-xc)*SIN(angle*!DTOR) + (yy-yc)*COS(angle*!DTOR)


        if KEYWORD_SET(vector) then begin
            xout = REFORM(xout[*,0])
            yout = REFORM(yout[0,*])
        endif

    endelse
end