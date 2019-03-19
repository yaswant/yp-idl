function get_nc, filename, attributes=attributes, status=status
; get_netcdf wrapper for compressed nc file.


    if N_PARAMS() lt 1 then begin
        message,"syntax: struct = get_nc('filename.nc' [,ATTRIBUTES=a]"+$
            " [,STATUS=s])"
    endif
    
    tmp = GETENV('TMPDIR/')+'get_nc/'
    FILE_MKDIR, tmp

    ; Parse filename from compressed file (if provided)    
    case STRUPCASE(file_suffix(filename)) of
        'GZ': begin
                ncf = tmp+FILE_BASENAME(filename,'.gz',/FOLD)
                SPAWN,'gzip -cd '+filename+' > '+ncf   
            end
         'BZ2': begin
                ncf = tmp+FILE_BASENAME(filename,'.bz2',/FOLD)
                SPAWN,'bzip2 -cdk '+filename+' > '+ncf   
            end
         'ZIP': begin
                ncf = tmp+FILE_BASENAME(filename,'.zip',/FOLD)
                SPAWN,'zcat -cd '+filename+' > '+ncf
            end
         'Z': begin
                ncf = tmp+FILE_BASENAME(filename,'.Z',/FOLD)
                SPAWN,'zcat -cd '+filename+' > '+ncf
            end      
         'NC': ncf = filename
         else: message,'Unknown file format'
    endcase 
    
    ; Read netcdf and delete temp area
    read_netcdf, ncf, data, attr, stat
    FILE_DELETE, tmp, /RECURSIVE
    
    if KEYWORD_SET(attributes) then attributes = attr
    if KEYWORD_SET(status) then status = stat
    
    return, data        

end