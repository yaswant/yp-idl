;+
; NAME:
;       WRAP_LON
;
; PURPOSE:
;       Converts Longitude values in an array range from [-180:180]
;       to [0-360] and vice-versa.
;
; SYNTAX:
;       Result = WRAP_LON( Longitude [,/HEMISPHERE] [,INDEX=Variable] )
;
; ARGUMENTS:
;       Longitude (IN:Array) Input Longitude Array
;
; KEYWORDS:
;       /HEMISPHERE - Keep array in -180-180 range
;       INDEX (OUT:Variable) - A named variable that will contain
;                   sorted index of converted Longitude array.
;
; EXAMPLE:
;   IDL> lon=[-179.,20.,-20,177]
;   IDL> print,wrap_lon(lon)
;       181.000      20.0000      340.000      177.000
;
; EXTERNAL ROUTINES:
;       None
;
; CATEGORY:
;       Lat-Lon manipulation in Cartesian Coordinate System
;
;
; -----------------------------------------------------------------------------
; $Id: wrap_lon.pro,v0.1 2010-03-01 15:10:38 yaswant Exp $
; WRAP_LON.pro Yaswant Pradhan (c) Crown Copyright Met Office
; Last modification:
; -----------------------------------------------------------------------------
;-

FUNCTION wrap_lon, Longitude, HEMISPHERE=hemsphere, INDEX=idx

  Syntax = 'Result = WRAP_LON( Longitude [,/HEMISPHERE] [,INDEX=Variable])'
  if n_params() lt 1 then message, Syntax

; Valid ranges of Longitudes in hemispheric and spherical format
  val_hem = [-180, 180]
  val_sph = [0, 360]

  flag = [min(Longitude,/NaN) ge val_hem[0] and $
          max(Longitude,/NaN) le val_hem[1],    $
          min(Longitude,/NaN) ge val_sph[0] and $
          max(Longitude,/NaN) le val_sph[1]]
  if total(flag) eq 0 then begin
    print,' Longitude Range: ',[min(Longitude,/NaN),max(Longitude,/NaN)]
    message,' Conflicting or out-of-range values in Longitude array.'
  endif


  hem = flag[1] or keyword_set(hemsphere)

  out = hem ? ((Longitude + 180) mod 360) - 180 $
            :  (Longitude + 360) mod 360

  if arg_present(idx) then idx = sort(out)
  return, out

END
