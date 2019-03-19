;+
; :NAME:
;     ll_vec2poly
;
; :PURPOSE:
;     Construct Polygon array for given Lon(X) Lat(Y) 1D arrays
;
; :SYNTAX:
;     ll_vec2poly, lon, lat [,ll_poly] [,DX=Value] [,DY=Value]
;     [,NODE_RES=Value] [,/CENTRE] [,/RELAX] [,/HEXAGONS]
;
;  :PARAMS:
;    lon (IN:Array) Longitude (X) array
;    lat (IN:Array) Latitude (Y) array
;    ll_poly (OUT:Structure)
;
;
;  :KEYWORDS:
;    DX (IN:Value) Delta X of output polygons (horizontal length of polygons)
;    DY (IN:Value) Delta Y of output polygons (vertical length of polygons)
;    NODE_RESOLUTION (IN:Value) Polygon resolution or the separation distance
;       betwen two adjacent nodes of the output polygon. This keyword will be
;       required on IDL's map system, if DX and DY are too large (say > 20deg)
;    /CENTRE - Centre output polygons around Lon/Lat arrays; default is input
;       Lon/Lat values -> bottom left corner of output polygons
;    /RELAX - Relax polygon values beyong geographic limits
;    /HEXAGONS - Return hexagonal instead of rectangular polygons
;
; :REQUIRES:
;    fltscl.pro [file:///home/h05/fra6/myidl_lib/fltscl.pro]
;
; :EXAMPLES:
;   To plot two filled polygons centred at lon/lat with grid
;   resolution of 10x10 degrees
;
;   IDL> lon   = [-90., 90.]
;   IDL> lat   = [45., -20.]
;   IDL> value = [100, 200]
;   IDL> ll_vec2poly, lon, lat, llp, DX=10,DY=10,NODE_RES=1, /CENTRE
;
;   IDL> MAP_SET, /MOLLWEIDE, /CONTINENTS, COLOR=255
;   IDL> MAP_GRID
;
;   IDL> for i=0l,1 do POLYFILL, llp.lon[*,i], llp.lat[*,i], color=value[i]
;
; :CATEGORIES:
;     Plotting/Mapping
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  10-Aug-2010 15:51:56 Created. Yaswant Pradhan.
;  12-Nov-2010 Added FLTSCL patch (/RELAX). YP.
;  15-Nov-2010 Bug fix with CENTRE keyword. YP.
;  31-Jan-2012 Added Relax keyword. YP.
;  16-Apr-2013 Added hexagon (experiemental) keyword. YP.
;
;-

pro ll_vec2poly, lon, lat, ll_poly, $   ; inArr, inArr, outStruct
        DX=delx, $              ; Length of polygon (rect)
        DY=dely, $              ; Height of polygon (rect)
        NODE_RESOLUTION=nres,$  ; Add more nodes between sides of polygons
        CENTRE=centre, $        ; Centre polygon around Lon,Lat coordinate
        RELAX=relax, $          ; Relax beyon valid Lon-Lat range
        HEXAGONS=hexagons       ; Experimental

    ; Parse inputs
    syntax = 'Syntax: LL_VEC2POLY, Longitude, Latitude [,ll_poly] '+$
        '[,DX=Value] [,DY=Value] [,NODE_RES=Value] [,/CENTRE]'

    if N_PARAMS() lt 2 then message, syntax

    if N_ELEMENTS(lon) ne N_ELEMENTS(lat) then $
        message, 'Unequal Lon/Lat array.'

    rr    = KEYWORD_SET(relax)
    nl    = N_ELEMENTS(lon)
    _hex   = KEYWORD_SET(hexagons)
    delx  = KEYWORD_SET(delx) ? delx < (rr ? delx : 179.9999) : 1.
    dely  = KEYWORD_SET(dely) ? dely < (rr ? dely : 089.9999) : 1.

    ; - - - - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -
    ; Calculate bottom-left corner of each polygon
    ; - - - - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -
    blat  = KEYWORD_SET(centre) ? (lat - dely/2.) : lat
    llon  = KEYWORD_SET(centre) ? (lon - delx/2.) : lon


    ; - - - - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -
    ; Initialise output polygon structure
    ; - - - - - - - - - - - - - - - - - - - - - - -- - - - - - - - - - - - - -
    nodes = _hex ? 7 : 5
    ll_poly = {LON:FLTARR(nodes,nl), LAT:FLTARR(nodes,nl)}


    ; Get nodes for each polygon:
    for i=0L,nl-1 do begin
        lons4 = [llon[i],llon[i]+delx,llon[i]+delx,llon[i],llon[i]]
        lats4 = [blat[i],blat[i],blat[i]+dely,blat[i]+dely,blat[i]]
        mlon = MEAN(lons4[0:1])
        mlat = [lats4[1]+(lats4[2]-lats4[1])/4.,$
            lats4[1]+3*(lats4[2]-lats4[1])/4.]

        lons6 = [mlon,REPLICATE(lons4[1],2),mlon,REPLICATE(lons4[0],2),mlon]
        lats6 = [lats4[0],mlat[[0,1]],lats4[2],mlat[[1,0]],lats4[0]]
        lons = _hex ? lons6 : lons4
        lats = _hex ? lats6 : lats4

        ll_poly.LON[*,i] =  rr ? lons : (lons > (-180.) < 180.)
        ll_poly.LAT[*,i] =  rr ? lats : (lats > (-90.) < 90.)

        ; ll_poly.LON[*,i] =  rr ? $
        ;    [llon[i],llon[i]+delx,llon[i]+delx,llon[i],llon[i]] : $
        ;    [llon[i],llon[i]+delx,llon[i]+delx,llon[i],llon[i]] > $
        ;    (-180.) < 180.
        ; ll_poly.LAT[*,i] =  rr ? $
        ;    [blat[i],blat[i],blat[i]+dely,blat[i]+dely,blat[i]] : $
        ;    [blat[i],blat[i],blat[i]+dely,blat[i]+dely,blat[i]] > $
        ;    (-90.) < 90.
    endfor


    ; - -  - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - - - -
    ; Increase polygon resolution for smooth edge, useful for
    ; plotting large polygons on non-planar projections, i.e.,
    ; when DX and DY are > 10-20 degrees and positioned at
    ; high latitudes
    ; - -  - - - - - - - - - - -  - - - - - - - - - - - - - - - - - - - - - - -
    if KEYWORD_SET(nres) and ~KEYWORD_SET(hexagons) then begin

        ; At least 2 points for each side of the polygon:
        delhi = CEIL(delx/nres) > CEIL(delx/nres) > 2
        llon  = ll_poly.LON
        llat  = ll_poly.LAT

        ll_poly = {LON: FLTARR(delhi*4,nl), LAT:FLTARR(delhi*4,nl)}

        for i=0L,nl-1 do begin

            xh  = (llon[*,i] - SHIFT(llon[*,i],1))[1:*]
            yh  = (llat[*,i] - SHIFT(llat[*,i],1))[1:*]

            for s=0L,N_ELEMENTS(xh)-1 do begin
                ll_poly.LON[s*delhi:s*delhi+delhi-1, i] = (xh[s] eq 0)  $
                    ? REPLICATE(llon[s,i], delhi)                         $
                    : fltscl(FINDGEN(delhi), LOW=llon[s,i], HIGH=llon[s+1,i],$
                             /RELAX)
            endfor

            for s=0L,N_ELEMENTS(yh)-1 do begin
                ll_poly.LAT[s*delhi:s*delhi+delhi-1, i] = (yh[s] eq 0)  $
                    ? REPLICATE(llat[s,i], delhi)                         $
                    : fltscl(FINDGEN(delhi), LOW=llat[s,i], HIGH=llat[s+1,i],$
                             /RELAX)
            endfor

        endfor ; i=0L,nl-1

    endif

    return

end
