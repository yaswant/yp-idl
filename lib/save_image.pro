pro save_image, filename, format
;+
; :NAME:
;    	save_image
;
; :PURPOSE:
;     Procedure saves an image to a file of a specified type.
;     SAVE_IMAGE can write most types of image files supported by IDL.
;
; :SYNTAX:
;     save_image [,filename] [,format]
;
;	 :PARAMS:
;    filename (IN:string) Output filename (def: figure.png)
;    format (IN:string)   Output file format
;                         Usually derived from output filename, but using
;                         format option overrides derived format from filename
;
; :REQUIRES:
;
;
; :EXAMPLES:
;     IDL> tvscl, dist(200,200)
;     IDL> save_image, 'image.jpg'
;
; LIMITATIONS:
;   Not supported on PS device
;
; :CATEGORIES:
;     Plotting
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Mar 23, 2009 11:29:58 AM Created. Yaswant Pradhan.
;
;-

    ; --------------------------------------------------------------------------
    ; Get device name (and exit if PS) output filename
    ; --------------------------------------------------------------------------
    
    _dev = !d.NAME
    zbuf = strcmp(_dev, 'Z', /FOLD)
    
    if strcmp(_dev,'PS',/FOLD) then message,' PNG cant be saved on PS device.'
        
    filename = keyword_set(filename) ? filename : 'figure.png'
    
    form = keyword_set(format) ? format : $
        (reverse(strsplit(filename,'.',count=n,/extract)))[0]
        
    filename = keyword_set(format) ? $
        (strsplit(filename,'.',/extract))[0]+strlowcase('.'+form) : $
        filename
        
    form = strupcase(form)    
    if strcmp(form, 'JPEG') then form = 'JPG'
    
    
    ; --------------------------------------------------------------------------
    ; Load RGB channels from window
    ; --------------------------------------------------------------------------
    tvlct, r,g,b, /get
    
    case form of
        'BMP' : begin
            img = zbuf ? tvrd() : tvrd(true=1)
            write_image, filename, form, img
        end
        
        'GIF' : begin
            img = zbuf ? tvrd() : tvrd(true=1)
            write_image, filename, form, img
        end
        
        'JPG' : begin
            img = zbuf ? tvrd() : transpose(tvrd(true=1), [1,2,0])            
            write_jpeg, filename, img, quality=100, $
                true=(zbuf ? 0 : 3), _extra=extra
        end
        
        'PPM' : begin
            img = zbuf ? tvrd(/order) : tvrd(true=1, /order)
            write_image, filename, form, img  ; <>
        end
        
        'SRF' : begin
            img = zbuf ? tvrd(/order) : tvrd(true=1, /order)
            write_image, filename, form, img  ; <>
        end
        
        'TIFF': begin
            img = zbuf ? tvrd(/order) : tvrd(true=1, /order)
            write_image, filename, form, img  ; <>
        end
        
        'PNG' : begin
            img = zbuf ? tvrd() : tvrd(true=1)
            write_png, filename, img, r,g,b, _extra=extra
        end
        
    else  : message,' Error! Unreognised format.'
endcase
message,'File saved: '+filename,/CONTINUE,/NOPREFIX

end
