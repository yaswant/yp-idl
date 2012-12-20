pro wspd2uv, speed, direction, U, V, MISSING=missing
;+
; :Name:
;     wspd2uv
;     C:\RedSea\yp_idl\lib\wspd2uv.pro
;
; :Description:
;     Convert Windspeed and direction to u and v components of wind
;     rad = 4.0*atan(1.0)/180.
;     u = -spd*sin(rad*dir)
;     v = -spd*cos(rad*dir)
;
;
;  Conversely the Speed and Direction can be calculated from
;  u and v components as:
;     speed = SQRT(u*u + v*v)
;     direction = 360,      if u=0 and v < 0
;               = 180,      if u=0 and v > 0
;               = 270-Dc,   if u<0
;               = 90-Dc,    if u>0
;       where Dc= atan(v/u) * !RADEG
;
;
;
; :Syntax:
;
; :Params:
;    speed
;    direction
;    U
;    V
;
;
;
; :Requires:
;
; :Example:
;
; :Author: Yaswant Pradhan
; :History:
;   Apr 15, 2012 Created. YP
;-

  syntax = 'wspd2uv, speed, direction [,U] [,V]'
  if N_PARAMS() lt 2 then message, syntax

  if N_ELEMENTS(speed) ne N_ELEMENTS(direction) then $
  message, '[wspd2uv]: Warn! Speed and Direction should be equal in size.',/INFO

  U = -speed * SIN(direction*!DTOR)
  V = -speed * COS(direction*!DTOR)

  if is_defined(missing) then begin
      w = WHERE(speed eq missing, nw)
      if (nw gt 0) then U[w]=(V[w]=missing)
  endif


  return
end