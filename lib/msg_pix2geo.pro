;+
;NAME:
;   msg_pix2geo
;
;PURPOSE:
;   returns the longitude and latitude of an MSG image
;   for a given pair of pixel column and row.
;   (based on the formulae given in Ref. [1])
;
;SYNTAX:
;   result = msg_pix2geo( Column, Row, STATUS=variable )
;
;INPUT:
;   Column - Column number, an IDL variable, scalar, usually int or long
;   Row - Row number, an IDL variable, scalar, usually int or long
;
;OUTPUT:
;   RESULT - converted geographic Longitude and Latitude values
;       in decimal degrees
;
;OPTIONAL KEYWORD INPUT:
;   STATUS - 0: Success, 1: Fail (not in MSG FOV)
;   /QUIET - Suppress arithmatic error messages
;
;EXAMPLE:
;   IDL> print, msg_pix2geo( 192, 2494 )
;       69.959613       20.010373
;   IDL> print, msg_pix2geo( 1856, 1856 )
;       0.0000000       0.0000000
;
; $Id: MSG_PIX2GEO.pro,v 1.0 14/02/2008 10:52:51 yaswant Exp $
; MSG_PIX2GEO.pro Yaswant Pradhan (c) Crown Copyright Met Office
; Last modification: Feb 08
;-
;
;--------------------------------------------------------------------
;This function "geo2pix.pro" was replicated from a prototype Program
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
FUNCTION msg_pix2geo, column, row, QUIET=quiet, STATUS=status

  ; Parse error
  if( n_params() lt 2 ) then message,'Syntax: '+$
        'Result = msg_pix2geo( Column, Row [,STATUS=variable])'


  def = !except
  !except = keyword_set( quiet ) ? 0 : def

  ; Define MSG paramaters
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

  s1=(s2=(s3=(sn=(sd=(sxy=(sa=0.0D))))))
  x=(y=(longi=(lati=0.0D)))
  c=(l=0)

  c=column
  l=row;


  ; ---------------------------------------------------------------------------
  ; calculate viewing angle of the satellite by use of the equation
  ; on page 28, Ref [1].
  ; ---------------------------------------------------------------------------

  x = (2.^16.) * ( c - pMSG.COFF) / pMSG.CFAC
  y = (2.^16.) * ( l - pMSG.LOFF) / pMSG.LFAC


  ; ---------------------------------------------------------------------------
  ; now calculate the inverse projection
  ; first check for visibility, whether the pixel is located on the earth
  ; surface or in space.
  ; To do this calculate the argument to sqrt of "sd", which is named "sa".
  ; If it is negative then the sqrt will return NaN and the pixel will be
  ; located in space, otherwise all is fine and the pixel is located on the
  ; earth surface.
  ; ---------------------------------------------------------------------------

  sa = ((pMSG.SAT_HEIGHT * COS(x) * COS(y))^2.) - (COS(y)^2. + 1.006803 * SIN(y)^2.) * 1737121856.0D


  ; ---------------------------------------------------------------------------
  ; now calculate the rest of the formulas using equations on
  ; page 25, Ref. [1]
  ; ---------------------------------------------------------------------------

  sd = SQRT((((pMSG.SAT_HEIGHT * COS(x) * COS(y)))^2.) - (COS(y)^2. + 1.006803 * SIN(y)^2.) * 1737121856.0D )
  sn = (pMSG.SAT_HEIGHT * COS(x) * COS(y) - sd) / ( COS(y)^2. + 1.006803 * sin(y)^2. )

  s1 = pMSG.SAT_HEIGHT - sn * COS(x) * COS(y)
  s2 = sn * SIN(x) * COS(y)
  s3 = -sn * SIN(y)

  sxy = SQRT( s1*s1 + s2*s2 )


  ; ---------------------------------------------------------------------------
  ; Using the previous calculations the inverse projection can be
  ; calculated now, which means calculating the lat./long. from
  ; the pixel row and column by equations on page 25, Ref [1].
  ; Generate error status
  ; ---------------------------------------------------------------------------

    IF ( sa LE 0. ) THEN BEGIN
        lati    = -999.999*!DPI/180.
        longi   = -999.999*!DPI/180.
        status  = 1
    ENDIF ELSE BEGIN
        longi   = ATAN(s2/s1 + pMSG.SUB_LON)
        lati    = ATAN((1.006803*s3)/sxy)
        status  = 0
    ENDELSE

    ; -------------------------------------------------------------------------
    ; Convert from radians into degrees
    ; -------------------------------------------------------------------------

    latitude = lati*180./!DPI
    longitude = longi*180./!DPI

    IF (verb) THEN PRINT, 'LONGITUDE, LATITUDE : ',[Longitude, Latitude]
    RETURN, [Longitude, Latitude]

END



