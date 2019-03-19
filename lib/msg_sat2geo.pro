function  msg_sat2geo, msgdata, FILENAME=filename, $
          LONLIM=lonlim, LATLIM=latlim, $
          LONDEL=londel, LATDEL=latdel, $
          PLOTOUT=plotout, PRANGE=prng, $
          CUTOFF=cutoff, MISSING=missing, $
          DUST=dust, CT=ct, NO_SCALE=no_scale, $
          LONOUT=londata, LATOUT=latdata
          VERBOSE=verbose
;+
; NAME:      
;   msg_sat2geo                                                               
; 
; PURPOSE:   
;   Returns MSG image data an un-projected Lat-Lon grid of specified dimension
;   /resolution from an input disk [3712x3712] in satellite projection.       
; 
; SYNTAX:    
;   result = MSG_SAT2GEO( msgdata | FILENAME=String [,LONLIM=Array]       $   
;            [,LATLIM=Array] [,LONDEL=Value] [,LATDEL=Value]              $
;            [,/PLOTOUT] [,PRANGE=Array] [,MISSING=Value] [,/VERB] )       
; 
; ARGUMENTS: 
;   msgdata (IN : fltarr(3712, 3712)) Input MSG data in satellite projection  
; 
; KEYWORDS:  
;   FILENAME (IN : String)  - A filename (headerless flat biary) containing   
;                             msgdata; msgdata arg overrides this keyword.    
;   LONLIM (IN : fltarr(2)) - Desired Longitude Limit [minLon, maxLon] for    
;                             output data; Default value = [-60.,60.]         
;   LATLIM (IN : fltarr(2)) - Desired Latitude Limit [minLat, maxLat] for     
;                             output data; Default value = [-45.,65.]         
;   LONDEL (IN : Value)     - Desired Longitude interval (non-zero) in        
;                             degrees for output data; Default = 0.5          
;   LATDEL (IN : Value)     - Desired Latitude interval (non-zero) in         
;                             degrees for output data; Default = 0.5          
;   /PLOTOUT                - Plots the output data in X graphics             
;   PRANGE (IN : Array(2))  - Scale output (only for plotting) data to valid  
;                             Min-Max range; default is [0.01, 2.]            
;   MISSING (IN : Value)    - Real missing data indicator (non-zero);         
;                             Default = NaN                                   
;   /VERBOSE                - Verbose mode                                    
; 
; OUTPUT:
;   RESULT - Resampled un-projected data 2D Array of dimension                
;            [ (lonlim[1]-lonlim[0])/londel, (latlim[1]-latlim[0])/latdel ]   
; 
; 
; EXTERNAL MODULES REQUIRED:
;   FLTSCL.pro
;   MSG_GEO2PIX_VECTOR.pro
;   IS_DEFINED.pro
;   DECOMP.pro    (if using /PLOTOUT keyword)
;   LOADMYCT.pro  (if using /PLOTOUT keyword)
;   COLORBAR.pro  (if using /PLOTOUT keyword)
; 
; EXAMPLE (1):
; IDL> newData=msg_sat2geo(FILENAME='MSG_200907031000_AOD_3712x3712.dat.gz',/verb)
; % Compiled module: MSG_SAT2GEO.
; 
; LONDATA         FLOAT     = Array[240, 220]
; LATDATA         FLOAT     = Array[240, 220]
; --------------------------------------------------------------
; GEODATA         FLOAT     = Array[240, 220]
;  Missing Data Indicator :                 NaN
;  Adjusted Longitude Limit :           -60.000    60.000
;  Adjusted Latitude Limit  :           -45.000    65.000
;  LATLIM (in degrees) :                -45.000    65.000
;  LONLIM (in degrees) :                -60.000    60.000
;  LATDEL (in degrees) :                  0.500
;  LONDEL (in degrees) :                  0.500
;  Number of valid out grid points :        9334
;  Resampling time (sec):                 0.055
; --------------------------------------------------------------
;  [MSG_SAT2GEO] Finish.
; 
; EXAMPLE (2):
; IDL> newData=msg_sat2geo(FILENAME='MSG_200907031000_AOD_3712x3712.dat.gz',LONDEL=0.2,LATDEL=0.2,/verb)
; 
; LONDATA         FLOAT     = Array[600, 550]
; LATDATA         FLOAT     = Array[600, 550]
; --------------------------------------------------------------
; GEODATA         FLOAT     = Array[600, 550]
;  Missing Data Indicator :                 NaN
;  Adjusted Longitude Limit :           -60.000    60.000
;  Adjusted Latitude Limit  :           -45.000    65.000
;  LATLIM (in degrees) :                -45.000    65.000
;  LONLIM (in degrees) :                -60.000    60.000
;  LATDEL (in degrees) :                  0.200
;  LONDEL (in degrees) :                  0.200
;  Number of valid out grid points :       58744
;  Resampling time (sec):                 0.119
; --------------------------------------------------------------
;  [MSG_SAT2GEO] Finish.
;  
; $Id: MSG_SAT2GEO.pro, v1.0 27/03/2009 12:15:47 yaswant Exp $    
; MSG_SAT2GEO.pro Yaswant Pradhan (c) Crown Copyright Met Office  
; 
; Bug report: yaswant.pradhan@metoffice.gov.uk
; Modification history: 
; Mar 2009 - Created (YP)
; July 2009 - Cleaned unnecessary bits (YP)
;- 

__quiet = !QUIET
!QUIET  = 1

; -------------------------------------------------------------------
; Parse arguments   
; -------------------------------------------------------------------
  fin  = keyword_set(filename)  
  
  if( n_params() lt 1 and not fin ) then begin
    print,' Data Array or filename is missing'
    print,' Please select the filename containing data in satellite projection'    
    filename =  dialog_pickfile(/read,filter='*_3712x3712.dat*', $
                title='Please Select an MSG file')
    
    if( strcmp(filename[0],'') ) then begin
      print, ' Error! No File selected.'
      return, -1
    endif  
    
    ext = (reverse( strsplit(filename,'.',/extract) ))[0]
    if( strcmp(ext,'gz',/fold_case) ) then $
      openr,lun,filename,/compress,/get_lun else $
      openr,lun,filename,/get_lun      
      msgdata=fltarr(3712,3712)
      readu,lun,msgdata
      free_lun, lun
    
  endif else if( n_params() lt 1 and fin ) then begin 
    ext = (reverse( strsplit(filename,'.',/extract) ))[0]
    if( strcmp(ext,'gz',/fold_case) ) then $
      openr,lun,filename,/compress,/get_lun else $
      openr,lun,filename,/get_lun
      msgdata=fltarr(3712,3712)
      readu,lun,msgdata
      free_lun, lun
  endif else filename='msgdata'
  

; -------------------------------------------------------------------
; Parse keyword parametrs  
; -------------------------------------------------------------------
  lonlim  = keyword_set(lonlim) ? float(lonlim) : [-60.,60.]
  latlim  = keyword_set(latlim) ? float(latlim) : [-45.,65.]  
  londel  = keyword_set(londel) ? float(londel) : .5
  latdel  = keyword_set(latdel) ? float(latdel) : .5
  verb    = keyword_set(verbose) ? 1 : 0
  plt     = keyword_set(plotout) ? 1 : 0
  mdi     = is_defined(missing) ? float(missing) : !values.f_nan
  prng    = is_defined(prng) ? prng : [0., 2.] ; Scale data for plotting
  
  
; -------------------------------------------------------------------
; Estimate number of lat and lon points for the out grid  
; and pull msg nearest data for each out grid pixels      
; -------------------------------------------------------------------
  nlons   = round( (lonlim[1]-lonlim[0])/londel )
  nlats   = round( (latlim[1]-latlim[0])/latdel )
  lons    = fltscl(findgen(nlons),low=lonlim[0],high=lonlim[1])
  lats    = fltscl(findgen(nlats),low=latlim[0],high=latlim[1])
  
  
  geodata = make_array(nlons, nlats, value=mdi)
  londata = lons # replicate( 1,n_elements(lats) )
  latdata = replicate( 1,n_elements(lons) ) # lats
  npix    = nlons*nlats    
  if( verb ) then help,   londata, latdata
    
  tic=systime(1)  
  p       =  msg_geo2pix_vector( londata[*], latdata[*], status=st )
  if( st eq 0 ) then begin
    geodata = msgdata[p(*,0), p(*,1)]
    geodata = reform( geodata, nlons, nlats)
  endif  
    
  

;+  
  cutoff  = is_defined(cutoff) ? cutoff : 0. ; Valid data min
  nvp     = 25 ; Plot data if number of valid pixels in the output grid are more than this    
  vp  = where( geodata gt cutoff, cnt )    
  
  if( plt ) then begin    
    if( cnt ge nvp ) then begin
      lat0 = mean(latlim[0]+latlim[1])
      lon0 = mean(lonlim[0]+lonlim[1])
      lims = [latlim[0],lonlim[0], latlim[1],lonlim[1]]      
    
      decomp
      ct = is_defined(ct) ? ct : 51
      loadmyct,ct,/silent
      max_win_size = 600.
      scale_factor = max_win_size/nlons < max_win_size/nlats
      xs  = ceil(nlons*scale_factor)+100
      ys  = ceil(nlats*scale_factor)
            
      window, XSIZE=xs, YSIZE=ys, title=file_basename(filename)
      proj  = map_proj_init('Equirectangular', limit=lims, center_longitude=lon0, sphere_radius=1.0)
      plot,   proj.uv_box[[0,2]], proj.uv_box[[1,3]], /nodata, /isotropic, $
              xstyle=5, ystyle=5
      mdata = map_image(geodata, startx, starty, mapx, mapy,compress=1, MAP_STRUCTURE=proj, $
              latmin=latlim[0],lonmin=lonlim[0],latmax=latlim[1],lonmax=lonlim[1])
      
      if keyword_set(no_scale) then begin
        tv,   mdata,startx,starty,xsize=mapx,ysize=mapy,/device
        colorbar, position=[.9,.2,.95,.8], /vertical, /right, color=255
      endif else if(keyword_set(dust)) then begin
        loadmyct, 58, /SILENT
        tv,   bytscl(mdata, min=prng[0],max=prng[1],/nan, top=249), $
              startx,starty,xsize=mapx,ysize=mapy,/device
        colorbar, position=[.9,.2,.95,.8], range=prng, /vertical, /right, $
              ncolors=249, color=255, format='(f6.1)'
      endif else begin
        tv,   bytscl(mdata, min=prng[0],max=prng[1],/nan),startx,starty,xsize=mapx,ysize=mapy,/device
        colorbar, position=[.9,.2,.95,.8], range=prng, /vertical, /right, color=1, format='(f6.1)'
      endelse
      
      loadct,0
      map_continents, /coast,/countries,color=200,MAP_STRUCTURE=proj
      map_grid, MAP_STRUCTURE=proj, /box, color=100
;       print,startx,mapx
      
    endif else print,'<-- Number of valid pixels (value > 0) in the output data are fewer than 25, hence plotting is disabled.'+$
    string(10b)+'<-- To enable this option set `nvp` and/or `cutoff` values within PLOT section, suitably.'
      
  endif
;-  

  if( verb ) then begin
    print,'--------------------------------------------------------------'
    help, geodata
    print,' Missing Data Indicator :       ',mdi
    print,' Adjusted Longitude Limit :        ',minmax(lons), format='(a,2(f10.3))'
    print,' Adjusted Latitude Limit  :        ',minmax(lats), format='(a,2(f10.3))'      
    print,' LATLIM (in degrees) :             ',latlim, format='(a,2(f10.3))'
    print,' LONLIM (in degrees) :             ',lonlim, format='(a,2(f10.3))'
    print,' LATDEL (in degrees) :             ',latdel, format='(a, f10.3)'
    print,' LONDEL (in degrees) :             ',londel, format='(a, f10.3)'
    print,' Number of valid out grid points :',cnt
    print,' Resampling time (sec):            ',systime(1)-tic, format='(a, f10.3)'    
    print,'--------------------------------------------------------------'
    print,' [MSG_SAT2GEO] Finish.'+string(10b)
  endif

!QUIET  = __quiet
  
  return, geodata
end
