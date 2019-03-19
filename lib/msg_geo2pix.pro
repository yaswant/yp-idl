FUNCTION msg_geo2pix, longitude, latitude, VERBOSE=verbose, STATUS=status

;+
;;NAME:
;   msg_geo2pix
; 
;PURPOSE:
;   return the pixel cloumn and line of an MSG image     
;   for a given pair of latitude/longitude. 
;   (based on the formulae given in Ref. [1]) 
; 
;SYNTAX:
;   result = msg_geo2pix( Longitude, Latitude [,Status=variable] [,/verbose] )
; 
;INPUT:
;   Longitude - In decimal degrees
;              an IDL variable, scalar, usually floating or double
;   Latitude - In decimal degrees
;              an IDL variable, scalar, usually floating or double
; 
;OUTPUT
;   RESULT - converted pixel column and row number
; 
;OPTIONAL KEYWORD INPUT:
;   STATUS - 0: Success, 1: Fail (not in MSG FOV)
;   VERBOSE - Prints error/misc messages 
; 
;EXAMPLE:
;   IDL> print, msg_geo2pix(70.,20.)
;       192    2494
;   IDL> print, msg_geo2pix(0.,0.)
;       1856    1856
; 
; $Id: MSG_GEO2PIX.pro,v 1.0 14/02/2008 10:52:51 yaswant Exp $
; MSG_GEO2PIX.pro Yaswant Pradhan (c) Crown Copyright Met Office
; Last modification: Feb 08
;- 
;
;--------------------------------------------------------------------
;This function "msg_geo2pix.pro" was replicated from a prototype Program 
; "MSG_navigation.c" which is an example code provided to give the users
; guidance for a possible implementation of the equations given in the
; LRIT/HRIT Global Specification [1] to navigate MSG ;(METEOSAT 8 onwards)
; data, i.e. to link the pixel coordinates column and line to the
; corresponding geograhical coordinates latitude and longitude.
;
;Users should take note, however, that it does NOT provide software
; for reading MSG data either in LRIT/HRIT, in native or any other
; format and that EUMETSAT cannot guarantee the accuracy of this
; software. The software is for use with MSG data only and will not
; work in the given implementation for Meteosat first generation data.
; 
;NOTE: Please be aware, that the program assumes the MSG image is
; ordered in the operational scanning direction which means from south
; to north and from east to west. With that the VIS/IR channels contains
; of 3712 x 3712 pixels, start to count on the most southern line and the
; most eastern column with pixel number 1,1.
; 
;
;NOTE on CFAC/LFAC and COFF/LOFF: 
; The parameters CFAC/LFAC and COFF/LOFF are the scaling coefficients
; provided by the navigation record of the LRIT/HRIT header and used
; by the scaling function given in Ref [1], page 28.
;
; COFF/LOFF are the offsets for column and line which are basically 1856
; and 1856 for the VIS/IR channels and refer to the middle of the image 
; (centre pixel). The values regarding the High Resolution Visible Channel 
; (HRVis) will be made available in a later issue of this software.
;
; CFAC/LFAC are responsible for the image "spread" in the NS and EW
; directions. They are calculated as follows:
; CFAC = LFAC = 2^16 / delta
; with
; delta = 83.843 micro Radian (size of one VIS/IR MSG pixel)
; 
; CFAC     = LFAC     =  781648343.404  rad^-1 for VIS/IR
;
; which should be rounded to the nearest integer as stated in Ref [1].
; 
; CFAC     = LFAC     =  781648343  rad^-1 for VIS/IR
;
; The sign of CFAC/LFAC gives the orientation of the image.
; Negative sign give data scanned from south to north as in the
; operational scanning. Positive sign vice versa.
;
; The terms "line" and "row" are used interchangeable.
;
; PLEASE NOTE that the values of CFAC/LFAC which are given in the
; Header of the LRIT/HRIT Level 1.5 Data (see [2]) are actually in 
; Degrees and should be converted in Radians for use with these 
; routines (see example and values above).
;
; The other parameters are given in Ref [1].
;
; Further information may be found in either Ref [1], Ref [2] or 
; Ref [3] or on the Eumetsat website http://www.eumetsat.de/ .
;
;  REFERENCE:                                            
;  [1] LRIT/HRIT Global Specification (CGMS 03, Issue 2.6, 12.08.1999)
;      for the parameters used in the program.
;  [2] MSG Ground Segment LRIT/HRIT Mission Specific Implementation,
;      EUMETSAT Document, (EUM/MSG/SPE/057, Issue 5, 4. February 2005).
;  [3] MSG Level 1.5 Image Data Format Description
;      (EUM/PS-MSG/ICD/04/0730, Issue 3, 4. February 2005).
;--------------------------------------------------------------------
;-


; -----------------------------------------------------------------------------
; Parse error
; -----------------------------------------------------------------------------
  if( n_params() lt 2 ) then message,'Syntax: '+$
        'Result = msg_geo2pix( Longitude, Latitude [,STATUS=variable])'
  

; -----------------------------------------------------------------------------
; Define MSG paramaters 
; -----------------------------------------------------------------------------
  pMSG={ $,
    SAT_HEIGHT  : 42164.0, $    ;distance from earth centre to satellite
    R_EQ        : 6378.169, $   ;radius from earth centre to equator
    R_POL       : 6356.5838, $  ;radius from earth centre to pol
    SUB_LON     : 0.0, $        ;longitude of sub-satellite point
    CFAC        : -781648343.,$ ;scaling coefficients (see note above)
    LFAC        : -781648343.,$ ;scaling coefficients (see note above) 
    COFF        : 1856, $       ;scaling coefficients (see note above)
    LOFF        : 1856 $        ;scaling coefficients (see note above)
  }
        
  IF(KEYWORD_SET(verbose)) THEN verb=1b ELSE verb=0b
  ccc     =(lll = 0)
  lati    =(longi=(c_lat=(lat=(lon = 0.0D))))
  r1      =(r2=(r3=(rn=(re=(rl= 0.0D)))))
  xx      =(yy=(cc=(ll = 0.0D)))
  dotprod = 0.0D
    
  lati    = latitude
  longi   = longitude


; -----------------------------------------------------------------------------
; Check if the values are sane, otherwise return error values
; -----------------------------------------------------------------------------
  IF ((lati LT (-90.)) OR (lati GT 90.) OR $
      (longi LT (-180.)) OR (longi GT 180.) ) THEN BEGIN 
        
    row     = -999
    column  = -999
    
    IF (verb) THEN PRINT,'ERROR! Provide a valid Earth coordinate.'
    
    status  = 1
    RETURN, -1
  ENDIF  


; -----------------------------------------------------------------------------
; Convert them to radians
; -----------------------------------------------------------------------------
  lat = lati*!DPI / 180.;
  lon = longi*!DPI / 180.;
    
  
; -----------------------------------------------------------------------------
; Calculate the geocentric latitude from the 
; geograhpic one using equations on page 24, Ref. [1]
; -----------------------------------------------------------------------------
  c_lat = ATAN ((0.993243*(sin(lat)/cos(lat))))


; -----------------------------------------------------------------------------
; Using c_lat calculate the length form the earth
; centre to the surface of the earth ellipsoid ;equations on page 24, Ref. [1]
; -----------------------------------------------------------------------------
  re = pMSG.R_POL / SQRT((1 - 0.00675701 * COS(c_lat) * COS(c_lat)))


; -----------------------------------------------------------------------------
;calculate the forward projection using equations on page 24, Ref. [1] 
; -----------------------------------------------------------------------------
  rl = re
  r1 = pMSG.SAT_HEIGHT - rl * COS(c_lat) * COS(lon - pMSG.SUB_LON)
  r2 = - rl *  COS(c_lat) * SIN(lon - pMSG.SUB_LON)
  r3 = rl * SIN(c_lat)
  rn = SQRT( r1*r1 + r2*r2 + r3*r3 )
  

; -----------------------------------------------------------------------------
; Check for visibility, whether the point on the earth given by the
; latitude/longitude pair is visible from the satellte or not. This 
; is given by the dot product between the vectors of:          
;  1) the point to the spacecraft, 
;  2) the point to the centre of the earth.
; If the dot product is positive the point is visible otherwise it is invisible.
; -----------------------------------------------------------------------------
  dotprod = r1* (rl * COS(c_lat) * cos(lon - pMSG.SUB_LON)) - r2^2. - r3^2. * ((pMSG.R_EQ/pMSG.R_POL)^2.)
     
  IF (dotprod LE 0.) THEN BEGIN
    column = -999
    row = -999
    
    IF (verb) THEN PRINT,'ERROR! Point out of visibility range.'
    
    status = 1
     RETURN, -1
  ENDIF    
  

; -----------------------------------------------------------------------------
; The forward projection is x and y
; -----------------------------------------------------------------------------
  xx = ATAN(-r2/r1)
  yy = ASIN(-r3/rn)


; -----------------------------------------------------------------------------
; Convert to pixel column and row using the scaling functions on
; page 28, Ref. [1]. And finding nearest integer value for them.
; -----------------------------------------------------------------------------
  cc    = pMSG.COFF + xx * 2.^(-16) * pMSG.CFAC 
  ll    = pMSG.LOFF + yy * 2.^(-16) * pMSG.LFAC 
  ccc   = nint(cc)
  lll   = nint(ll)     
  column= ccc
  row   = lll
    
  IF (verb) THEN PRINT, 'COLUMN, ROW : '  , [column, row]
    status = 0
    RETURN, [column,row]    

END