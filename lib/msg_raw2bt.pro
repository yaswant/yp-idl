FUNCTION msg_raw2bt,  Filename, Channel=channel, RADIANCE=radiance, $
                      START=start, COUNT=count, STRIDE=stride, $
                      APPLY_IMAGE_CORR=apply_image_corr
                      
;+
; NAME:
;       msg_raw2bt
; PURPOSE:
;       Calculate brightness temperature/radiance for MSG thermal/visible
;       channels raw data. MSG raw data are read from SlotStore _lite files.
; SYNTAX:
;       Result = msg_raw2bt(Filename, Channel=value [,/RADIANCE]
;                           [START=array, COUNT=array, STRIDE=array])
; ARGUMENTS:
;       Filename (IN : string)- SEVIRI Slotstore lite Filename
;       Channel (IN : integer/string)- Seviri Channel name [01...12]
; KEYWORDS:
;       START: 'INTARR(2)' Starting position of MSG data to be extracted
;               (default is [0,0]) (MSG specific)
;       COUNT: 'INTARR(2)'Number of pixels to extract along Longitude and
;               Latitude (default is all pixels of the input files) (MSG 
;               specific)
;       STRIDE: 'INTARR(2)' Number of pixels to skip along Longitude and 
;               Latitude (default is [1,1]) (MSG specific)
;       /RADIANCE: return radiance in-stead of brightness temperature
;       /APPLY_IMAGE_CORR: Apply image correction increments to BT channels.
;              Ps: Refer to EUMETSAT notes on changes to MSG specrtal/effective
;              radiance.
;
; EXAMPLE:
;       Result = msg_raw2bt('MSG_200808181000_lite.h5', Channel=05)
; EXTERNAL ROUTINES:
;       get_msg_h5.pro
;       h5d_size.pro
;       sps_constants.pro
;       delvarx.pro
; TODO:
;       Apply bias corrections to BT (to compensate inter calibration issue 
;       between Met8 and Met9)
; $Id: MSG_RAW2BT.pro, v 1.0 15/08/2008 16:11 yaswant Exp $
; MSG_RAW2BT.pro Yaswant Pradhan (c) Crown copyright Met Office
; Last modification: 09/02/09 (yp) added keyword radiance
;   2009-12-18 17:03:15 (yp) added keyword apply_image_corr
;-


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Parse input
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  syntax=' Result = MSG_RAW2BT( Filename, Channel = value)'
  if (n_params() lt 1 or ~keyword_set(channel)) $
  then message,'Syntax: '+syntax	

  input_type = size( channel, /type )
  valid_type = ['2','3','7']
  input_type = strtrim( string(input_type),2 )
        
  if (total(strmatch(valid_type, input_type)) eq 0) then $
  message,'Channel value should be Integer Type.'
    
  channel = fix(channel)
  if ((channel gt 12) or (channel lt 1)) then message,'Channel not available.'
  i = channel-1
    
  chan    = 'Ch'+string(channel,format='(i2.2)')
  feature = 'MSG/'+chan+'/Raw'

; Get MSG raw data
  st      = keyword_set(start) ? start : [0,0]
  cnt     = keyword_set(count) ? count : h5d_size(Filename, feature, /dim)
  stride  = keyword_set(stride) ? stride : [1,1]    
  if (h5d_size(Filename, feature, /n_dim) ne 2) then $
  message,'Input data not a 2D array/image'
    
  raw = get_msg_h5( Filename, feature, START=st, COUNT=cnt, STRIDE=stride )
        
        
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 1. Convert Raw data to Radiance
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  print,string(10b)+' Computing Radiance for : '+chan
    
  cal_info = get_msg_h5( Filename, 'MSG/Prologue/RadiometricProcessing')
  cal_slope = (cal_info.LEVEL1_5IMAGECALIBRATION)[2*(i-1) +2]
  cal_offset = (cal_info.LEVEL1_5IMAGECALIBRATION)[2*(i-1)+3]

  col = (size(raw))[1]
  row = (size(raw))[2]
  rad = make_array(col, row, value=(sps_constants()).RMDI)
  val = where( raw gt 0. and raw le 1023, n_val)
    
  if (n_val gt 0) then rad[val] = raw[val] * cal_slope + cal_offset
    
  delvarx, raw
  if keyword_set(radiance) then return, rad


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; 2. Calculate brightness temperatures
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (i gt 2 and i lt 11) then begin
    
    print,' Calculating Brightness temperature for : '+chan
    cw          = (sps_constants()).central_wavenumber[i]
    bc_coeff_a  = (sps_constants()).planck_bc_coeff_a[i-3]
    bc_coeff_b  = (sps_constants()).planck_bc_coeff_b[i-3]
    p1          = (sps_constants()).Planck_c1*cw*cw*cw
    p2          = (sps_constants()).Planck_c2*cw

  ; Calculate using inverse Planck function (modified for instrument response)
    bt  = make_array( col, row, value=(sps_constants()).RMDI )
    val = where( rad GT 0.000002, n_val ) 

    if ( n_val GT 0 ) then $
    bt[val] = ( p2 / alog(1. + p1/rad[val]) - bc_coeff_a ) / bc_coeff_b

    delvarx, rad
      
      
    if keyword_set( apply_image_corr ) then begin
      img_corr_inc = get_sps_constants('IMAGE_CORR_INCR_EFFRAD')
      img_corr_inc1= get_sps_constants('IMAGE_CORR_INCR_SPECRAD')      
      proc_info    = get_msg_h5( Filename,'/MSG/Prologue/ImageHeader')
                                          
      key          = (proc_info.PLANNEDCHANPROCESSING)[3:10] ; channels 4 to 11
      p            = where( key eq 1, np )
      if ( np gt 0 ) then img_corr_inc[p] = img_corr_inc1[p]
      bt  = bt + img_corr_inc[channel-3]
    endif        
      
    return, bt

  endif else begin
    
    print,  string(9b)+'WARNING! NO BT computation for : '+chan+$
            string(9b)+' Returning Radiance instead.'

    return, rad

  endelse

END
