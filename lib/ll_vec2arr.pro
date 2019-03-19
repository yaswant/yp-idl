;+
; :NAME:
;       ll_vec2arr
;
; :PURPOSE:
;     Convert 1D Lon Lat vector array to 2D grid array
;
; :SYNTAX:
;     ll_vec2arr, lon_1d, lat_1d [,lon_2d] [,lat_2d]
;
;    :PARAMS:
;    lon_1d (IN:Variable) 1D Longitude array
;    lat_1d (IN:Variable) 1D Latitude array
;    lon_2d (OUT:Variable) 2D Lontitude array
;    lat_2d (OUT:Variable) 2D Latitude array
;     If neither lon_2d or lat_2d present a
;     syntax message will be printed (does nothing)
;
; :REQUIRES:
;
;
; :EXAMPLES:
;    IDL> x = findgen(23) & y = findgen(10)
;    IDL> ll_vec2arr, x,y, xx,yy
;    IDL> help, xx,yy
;         XX   FLOAT  = Array[23, 10]
;         YY   FLOAT  = Array[23, 10]
;
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  10-Nov-2010 11:00:58 Created. Yaswant Pradhan.
;
;-

pro ll_vec2arr, lon_1d, lat_1d, lon_2d, lat_2d

  syntax ='ll_vec2arr, lon_1d, lat_1d [,lon_2d] [,lat_2d]'

  if N_PARAMS() gt 2 then begin

    if ARG_PRESENT(lat_2d) then $
       lat_2d = REPLICATE( 1,N_ELEMENTS(lon_1d) ) # lat_1d

    if ARG_PRESENT(lon_2d) then $
       lon_2d = lon_1d # REPLICATE( 1, N_ELEMENTS(lat_1d) )

  endif else print,'Syntax: '+syntax

end
