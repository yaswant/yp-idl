function msg_extract, slotstorefile, field, $
        LONLIM=lonlim, $
        LATLIM=latlim, $
        OUTFILE=outfile
        
    if N_PARAMS() lt 2 then begin
        message,'SYNTAX: msg_extract, slotstorefile, field [,LONLIM=lonlim] '+$
            '[,LATLIM=latlim] [,OUTFILE=outfile]'
    endif
    
    lonlim = is_defined(lonlim) ? lonlim : [-60, 60]
    latlim = is_defined(latlim) ? latlim : [-60, 60]
    xy = msg_geo2pix_vector(lonlim, latlim)
    start = [xy[1,0], xy[0,1]]
    count = [xy[0,0], xy[1,1]] - start
    
    ; extract field subset
    x = get_h5(slotstorefile,field,START=start, COUNT=count)
    
    
    
    ; Write extraction to h5 file
    if KEYWORD_SET(outfile) then begin
        colv = INDGEN(count[0])+start[0]
        rowv = INDGEN(count[1])+start[1]
        ll_vec2arr, colv, rowv, cols, rows
        
        lonlat = msg_pix2geo_vector(cols,rows)
        lon = REFORM(lonlat[*,0],count)
        lat = REFORM(lonlat[*,1],count)
        
        ;outfile=getenv('LOCALDATA')+'/sps/slotstore/test_extract.h5'
        write_h5, x, outfile, VARNAME=field,/OVERWRITE,/FORCE
        write_h5, lon, outfile, VARNAME='/Ancillary/Longitude',/APPEND
        write_h5, lat, outfile, VARNAME='/Ancillary/Latitude',/APPEND
    endif
    
    return, x
    
;    ; verify extraction
;    loadmyct,0
;    map_xyz,lon,lat,bytscl(x,min=273,max=321),/QUICK,/noborder
;
;    ; OR this way
;    window,1
;    tv, reverse(x)
    
    
end