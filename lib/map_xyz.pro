;+
; :NAME:
;     map_xyz
;
; :PURPOSE:
;     map_xyz is a wrapper to IDL's mapping system.
;     Plots scattered data [x,y,z triplets] as filled polygons on map system.
;     The z array indicate the colour index using current color palette.
;
; :SYNTAX:
;     map_xyz, x,y,z [,DX=Value] [,DY=Value] [,NODE_RES=Value] $
;             [,PLON=Value] [,PLAT=Value] [,ROTATE=Value] [,_EXTRA=_extra]
;
;  :PARAMS:
;    x (IN:Array) Input array corresponding X (zonal or longitude) positions.
;    y (IN:Array) Input array corresponding Y (meridional or latitide)
;                 positions.
;    z (IN:Array) Input array of values corresponding to positions [X,Y].
;
;
;  :KEYWORDS:
;    DX (IN:Value) Polygon (cell) width; default vaue 1
;    DY (IN:Value) Polygon (cell) height; default vaue 1
;    NODE_RES (IN:Value) Distance between each nodes of the polygon; def 1.
;                    Useful for large DX and DY with non-PC grids. Smaller
;                    NODE_RES means finer rendering.
;    PLON (IN:Value) The longitude of the point on the earth's surface to be
;                    mapped to the center of the map projection.
;                    Longitude is measured in degrees east of the Greenwich
;                    meridian and P0lon must be in the range:
;                    -180° ≤ P0lon ≤ 180°.
;                    If P0lon is not set, the default value is zero.
;    PLAT (IN:Value) The latitude of the point on the earth's surface to be
;                    mapped to the center of the projection plane.
;                    Latitude is measured in degrees North of the equator and
;                    P0lat must be in the range: -90° ≤ P0lat ≤ 90°. If P0lat
;                    is not set, the default value is zero.
;    ROTATE (IN:Value) Rotate is the angle through which the North direction
;                    should be rotated around the line L between the Earth's
;                    center and the point (P0lat, P0lon). Rotate is measured in
;                    degrees with the positive direction being clockwise
;                    rotation around line L. Rot can have values from -180 to
;                    to 180. If the center of the map is at the North pole,
;                    North is in the direction P0lon + 180°. If the origin is
;                    at the South pole, North is in the direction P0lon. The
;                    default value of Rot is 0 degrees.
;    CCOLOR (IN:Value) Colour index for continent boundaries
;    PBCOLOR (IN:Value) Polygon border colour index from current color table
;    PBTHICK (IN:Value) Polygon border thickness
;    /NOMAP          Do not overlay continent, use plot system instead of map
;                    system. Using this option will enable all PLOT keywords.
;    ADD_LOGO (IN:Array) Add metoffice logo (white background) position and size
;                    position values: (1: top-left, 2: top-right,
;                                      3: bottom-right, 4: bottom-left)
;                    size in normalised co-odinate, def: 0.1
;    /QUICK         Usually map_xyz does a polygon filling over the plot area
;                   which can be time consuming if the x,y,z arrays are huge.
;                   Setting this keyword will force employ plots using dots
;                   (i.e., psym=3)
;    /COUNTRIES *   Set this keyword to draw political boundaries on top of
;                   the plot
;    /COASTS    *   Set this keyword to draw coastlines, islands, and lakes
;                   instead of the default continent outlines. Note that if
;                   you are using the low-resolution map database (if the
;                   HIRES keyword is not set), many islands are drawn even
;                   when COASTS is not set. If you are using the high-resolution
;                   map database (if the HIRES keyword is set), no islands are
;                   drawn unless COASTS is set
;    _EXTRA         See valid keywords for MAP_SET (nomap=0) or
;                   PLOT (nomap=1) procedure.
;
;   * To plot the countries/coastlines below the plot use
;       E_CONTINENTS=e_conStr (See example below on how to define e_conStr)
;
; :REQUIRES:
;     ll_vec2poly.pro
;     is_defined.pro
;
; :EXAMPLES:
;   IDL> map_xyz, [50,0,80], [-20,50,20], [100,150,200], $
;                   dx=40, dy=40, NAME='Robinson',/iso
;
;
;   Modify grid parameters:
;   IDL> gd = {label:1, lonlab:-80, latlab:0}
;   IDL> map_xyz, [50,0,80], [-20,50,20], [100,150,200], $
;                 dx=40, dy=40, NAME='Robinson',/iso, E_GRID=gd
;
;   IDL> gd ={LABEL:2, LONLAB:-80, LATLAB:0, $
;             LONS:     indgen(19)*20-180, $
;             LONNAMES: append_hem(indgen(19)*20-180,/lon), $
;             LATS:     indgen(19)*10-90, $
;             LATNAMES: append_hem(indgen(19)*10-90,/lat), $
;             COLOR:    253 }
;   IDL> map_xyz, [50,0,80], [-20,50,20], [100,150,200], $
;                 dx=40, dy=40, NAME='Robinson',/iso, E_GRID=gd
;
;   To limit the plot to specific geographic domain pass in keyword parameters:
;       LIMIT = [Latmin, Lonmin, Latmax, Lonmax]
;
; Modify continents parameters (e.g.,fill continents with solid color):
; IDL> con = {FILL:1, COLOR:0}
; IDL>  map_xyz, [50,0,80], [-20,50,20], [100,150,200], $
;                 dx=40, dy=40, /GRIDON, E_CONTINENTS=con, /NOBORDER
;
; :CATEGORIES:
;     Plot, Mapping system
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  17-Nov-2010 13:54:00 Created. Yaswant Pradhan.
;  28-Nov-2011 Add NOMAP keyword. YP
;  20-Feb-2012 Add ADD_LOGO keyword. YP
;  06-Mar-2012 Add QUICK keyword. YP
;-

pro map_xyz, x,y,z,         $ ; Polygon Parameters
    DX=dx,                  $ ; width of each polygon in x-unit
    DY=dy,                  $ ; height of each polygon in y-unit
    NODE_RES=nres,          $ ; distance between each nodes of the polygon
    PLON=plon,              $ ; centre longitude
    PLAT=plat,              $ ; centre latitude
    ROTATE=prot,            $ ; rotation
    CCOLOR=cColor,          $ ; continent baoundary colour
    PATTERN=pat,            $ ; polygon fill pattern
    PBCOLOR=pbColor,        $ ; polygon border colour
    PBTHICK=pbThick,        $ ; polygon borther thickness
    NOMAP=nomap,            $ ; do not use MAP (have PLOT system instead)
    OVERPLOT=overplot,      $ ; overplot on an exiting plot window
    LIMIT=limit,            $ ; map limit [lat1,lon1,lat2,lon2]
    ADD_LOGO=alogo,         $ ; add met office logo [position, size]
    GRIDON=gridon,          $ ; GRID PARAMETERS
    GLABEL=glabel,          $ ; grid label intervals (def:1)
    LONLAB=lonlab,          $ ; latitude value to put longitude labels
    LATLAB=latlab,          $ ; longitude value to put latitude labels
    GLONDEL=glondel,        $ ; spacing between meridians of longitude
    GLATDEL=glatdel,        $ ; spacing between parallels of latitude
    GLATALIGN=glatalign,    $ ; alignment of the text baseline for lat-label
    GLINESTYLE=glinestyle,  $ ; grid line style
    GORIENT=gorient,        $ ; grid annotation orientation
    GLINEOFF=glineoff,      $ ; do not display grid line (only annotate)
    GCOLOR=gcolor,          $ ; grid colour
    GCHARSIZE=gcharsize,    $ ; grid label character size
    GCLIP_TEXT=gclip_text,  $ ; 0 turns off clipping of text labels
    LONS=lons,              $ ; logitude array for grid
    LATS=lats,              $ ; latitude array for grid
    QUICK=quick,            $ ; Quickplot using plots
    COUNTRIES=countries,    $ ; Draw political boundaries as of 1993 over plot
    COASTS=coasts,          $ ; Draw coastlines, islands, and lakes over plot
    HEXAGONS=hexagons,      $ ; Draw hexagonal cells (def:rectangular)
    _REF_EXTRA=_extra         ; See MAP_SET


  ; Parse input
  syntax = 'Syntax: map_xyz, x,y,z, [,DX=Value] [,DY=Value] '+ $
           '[,NODE_RES=Value] [,PLON=Value] [,PLAT=Value] '+ $
           '[,ROTATE=Value] [,_EXTRA=_extra]'

  if (N_PARAMS() lt 3) then message, syntax

  nx  = N_ELEMENTS(x)
  ny  = N_ELEMENTS(y)
  nz  = N_ELEMENTS(z)
  if (nx-ny ne 0) or (ny-nz ne 0) then begin
      print,'[map_xyz]: Number of elements in X,Y,Z should be equal.'
      return
  endif

; Parse _Ref_Extra keywords:
  mboff =(hr = -1)
  for i=0,N_ELEMENTS(_extra)-1 do begin
      mboff = mboff > STREGEX(_extra[i],'NOBO',/bool)
      hr    = hr > STREGEX(_extra[i],'HI',/bool)
  endfor


  ; ---------------------------------------------------------------------------
  ; Parse Polygon and map parameters
  ; ---------------------------------------------------------------------------
  dx    = is_defined(dx)   ? dx   : 1.  ; pixel/polygon width
  dy    = is_defined(dy)   ? dy   : 1.  ; pixel/polygon height
  nres  = is_defined(nres) ? nres : 1   ; distance betweeen each node

  plon  = is_defined(plon) ? plon : 0.
  plat  = is_defined(plat) ? plat : 0.
  prot  = is_defined(prot) ? prot : 0.

  if (is_defined(pbColor)) then begin
      if (N_ELEMENTS(pbColor) ne nz) then pbColor = REPLICATE(pbColor,nz)
  endif

  ; ---------------------------------------------------------------------------
  ; Parse keyword parameters
  ; ---------------------------------------------------------------------------
  oplt  = KEYWORD_SET(overplot)
  moff  = KEYWORD_SET(nomap)
  plogo = KEYWORD_SET(alogo)
  gon   = KEYWORD_SET(gridon)
  _hex  = KEYWORD_SET(hexagons)

  ; Set-up PLOT limit:
  limit = is_defined(limit) $
          ? limit $
          : ( (nx gt 1) $
            ? [MIN(y),MIN(x),MAX(y),MAX(x)] $
            : [y-dy,x-dx,y+dy,x+dx] )

  ; ---------------------------------------------------------------------------
  ; Create grid template if gridon is passed
  ; ---------------------------------------------------------------------------
  if (gon) then begin
      ngrd    = KEYWORD_SET(glineoff)
      glonres = KEYWORD_SET(glondel) ? glondel[0] : 20
      glatres = KEYWORD_SET(glatdel) ? glatdel[0] : 20
      glonn   = FIX((360./glonres) + 1)
      glatn   = FIX((200./glatres) + 1)
      lons    = is_defined(lons) ? lons : INDGEN(glonn)*glonres-180
      lats    = is_defined(lats) ? lats : INDGEN(glatn)*glatres-100

      ; Update lons and lonnames array according to LIMIT:
      j = WHERE(lons ge limit[1] and lons le limit[3], nj)
      if (nj gt 0) then lons = [limit[1],TEMPORARY(lons[j]),limit[3]]
      lons = lons[UNIQ(lons,SORT(lons))]
      lonnames = append_hem(lons,/lon)
      ni = N_ELEMENTS(lons)-1
      if ((lons-SHIFT(lons,1))[ni] ne glonres) then lonnames[ni]=''
      if ((lons-SHIFT(lons,-1))[0] ne glonres) then lonnames[0]=''

      ; Update lats and latnames array according to LIMIT:
      j = WHERE(lats ge limit[0] and lats le limit[2], nj)
      if (nj gt 0) then lats = [limit[0],TEMPORARY(lats[j]),limit[2]]
      lats = lats[UNIQ(lats,SORT(lats))]
      latnames = append_hem(lats,/lat)
      ni = N_ELEMENTS(lats)-1
      if ((lats-SHIFT(lats,1))[ni] ne glatres) then latnames[ni]=''
      if ((lats-SHIFT(lats,-1))[0] ne glatres) then latnames[0]=''


      orient  = is_defined(gorient) ? gorient : 0
      gclp    = is_defined(gclip_text) ? gclip_text : 1
      gtalign = is_defined(glatalign) ? glatalign : 0

      gd = { LABEL    : is_defined(glabel) ? glabel : 1,          $
             LONLAB   : is_defined(lonlab) ? lonlab : MIN(lats),  $
             LATLAB   : is_defined(latlab) ? latlab : MIN(lons),  $
             LINESTYLE: is_defined(glinestyle) ? glinestyle : 0,  $
             CHARSIZE : is_defined(gcharsize) ? gcharsize : 0.9,  $
             COLOR    : is_defined(gcolor) ? gcolor : 10,         $
             LONS       : lons,     $
             LONNAMES   : lonnames, $
             LATS       : lats,     $
             LATNAMES   : latnames, $
             TICKLEN    : 1,        $
             ORIENTATION: orient,   $
             CLIP_TEXT  : gclp,     $
             LATALIGN   : gtalign,  $
             NO_GRID    : ngrd }
  endif

  ; ---------------------------------------------------------------------------
  ; Initialise MAP or PLOT coordinate
  ; ---------------------------------------------------------------------------
  if moff then begin

      ; Set-up PLOT position:
      if (oplt) then p_advance, pos $
      else pos = [0.093755,0.07813,0.97188,0.960943]

      ; Plot PLOT outline:
      PLOT, (oplt ? !x.crange : limit[[1,3]]),          $
            (oplt ? !y.crange : limit[[0,2]]),          $
            XSTYLE=(oplt ? 5 :1), YSTYLE=(oplt ? 5 :1), $
            XGRIDSTYLE=(gon ? gd.LINESTYLE : 0),        $
            XTICKLEN=(gon ? gd.TICKLEN : 0),            $
            YGRIDSTYLE=(gon ? gd.LINESTYLE : 0),        $
            YTICKLEN=(gon ? gd.TICKLEN : 0),            $
            XTICKNAME=(oplt ? REPLICATE(' ',60) : ''),  $
            YTICKNAME=(oplt ? REPLICATE(' ',60) : ''),  $
            XMINOR=1, YMINOR=1, NOERASE=oplt,           $
            POSITION=pos, /NODATA, _EXTRA=_extra
  endif else begin

      if (N_ELEMENTS(_extra) eq 0) then _extra = ''
      ; Re-define moff on a mapped system where data needs to be overlaid only:
      moff = TOTAL(STREGEX(_extra,'NOER',/BOOLEAN)) and $
            KEYWORD_SET(overplot)

      ; Set-up MAP coordinates:
      MAP_SET, plat,plon,prot, LIMIT=limit,     $
               E_GRID=(gon ? gd : {no_grid:1}), $
               /NOBORDER, _EXTRA=_extra

      mp = [!x.window[0],!y.window[0], !x.window[1],!y.window[1]]

  endelse

  ; ---------------------------------------------------------------------------
  ; Plot actual data:
  ;   Create quickplot using plots (useful when number of elements in x,y,z are
  ;   huge, otherwise do the polygon filling
  ; ---------------------------------------------------------------------------
  if KEYWORD_SET(quick) then begin
      PLOTS, x, y, COLOR=z, PSYM=3, NOCLIP=0

  endif else begin
      ; Create Polygon structure for given X and Y array:
      ll_vec2poly, x,y,llp, DX=dx, DY=dy, NODE_RES=nres, $
                   /CENTRE, RELAX=moff, HEXAGONS=_hex

      ; Fill Map with input data (z):
      for i=0L,nz-1 do begin
          POLYFILL, llp.LON[*,i], llp.LAT[*,i], COLOR=z[i], $
                    PATTERN=pat

          ; Add polygon borders if required:
          if is_defined(pbColor) then $
          OPLOT, llp.LON[*,i], llp.LAT[*,i], COLOR=pbColor[i], $
                 THICK=(KEYWORD_SET(pbThick) ? pbThick : 1)

      endfor
  endelse


  ; Overlay Continet and grid:
  ; Overlay map border in dark-grey color and return map coordinates:
  if ~moff then begin
      MAP_CONTINENTS,/CONTINENTS, COUNTRIES=KEYWORD_SET(countries),$
          COASTS=KEYWORD_SET(coasts), COLOR=cColor, HIRES=hr
      TVLCT, rr,gg,bb, /GET
      TVLCT, BINDGEN(255),BINDGEN(255),BINDGEN(255)

      if ~mboff then begin
          boxDev = FIX(CONVERT_COORD(mp[[0,2,2,0,0]],mp[[1,1,3,3,1]],$
                                    /NORMAL,/TO_DEVICE))

          PLOT,  boxDev[0,*], boxDev[1,*], /DEVICE, /NOERASE, $
                 POSITION=[boxDev[0,0],boxDev[1,0],boxDev[0,1],boxDev[1,2]], $
                 THICK=2, COLOR=10, XSTYLE=5, YSTYLE=5

      endif

     ; PLOT,  mp[[0,2,2,0,0]], mp[[1,1,3,3,1]], /NORMAL, /NOERASE, $
     ;        POSITION=mp, THICK=1.5, COLOR=10, XST=5, YST=5
     ;        CLIP=[mp[1],mp[0],mp[3],mp[2]]

      TVLCT, rr,gg,bb


      MAP_SET, POSITION=mp, LIMIT=limit, /NOERASE, /NOBORDER
  endif

  ; ---------------------------------------------------------------------------
  ; Overlay Met Office Logo
  ; ---------------------------------------------------------------------------
  if (plogo) then begin
      p_advance, p
      if (N_ELEMENTS(alogo) lt 2) then alogo = [alogo[0], 0.1]
      xoff = alogo[1]-(alogo[1]*0.3)

      ; Cycle logo position TL, TR, BR, BL, TL, TR, ...
      case FIX((alogo[0]-1) mod 4)+1 of
          1: pl = [p[0], p[3]-alogo[1]]
          2: pl = [p[2]-xoff, p[3]-alogo[1]]
          3: pl = [p[2]-xoff, p[1]]
          4: pl = [p[0], p[1]]
       else: plogo = 0b
      endcase

      if (plogo) then logodraw, pl[0], pl[1], alogo[1], /NORMAL, /ONWHITE
  endif

end
