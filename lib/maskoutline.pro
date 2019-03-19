pro maskOutline, ClassifiedImage, VectorisedImage, SAVE2FILE=s2f
;+
; NAME:
;           maskOutline                                         
; PURPOSE:
;           Convert a classified Byte/Integer 2-dimensional Image 
;           (or mask) to a Vectorised Image (ouline of mask).                                 
; ARGUMENTS:
;           ClassifiedImage (IN:BYTARR|INTARR) Input Image Data   
;           VectorisedImage (OUT:BYTARR) Output Vectised image    
; KEYWORDS:
;           SAVE2FILE (OUT:String) Save VectorisedImage to a file 
;       or  /SAVE2FILE - Saves data as VectorisedImage.BYT file
; SYNTAX:
;           maskOutline ,CalssifiedImage ,VectorisedImage [,SAVE2FILE=String]       
; EXAMPLE:
;           See the example procedure at the end of this routine
; Last Modification:
; 2010-01-25 10:55:31. Yaswant Pradhan. Created
;-

  syntax  = 'maskOutline ,CalssifiedImage ,VectorisedImage [,SAVE2FILE=String]'
  if (n_params() lt 2) then message, syntax
  if (size(ClassifiedImage,/type) gt 3) then $
      message,'[maskOutline]: Classified Image should be of type Byte or Integer.'

  VectorisedImage = byte(ClassifiedImage*0)
  VectorisedImage[where( $
                  (ClassifiedImage - shift(ClassifiedImage,1,0) ne 0) or $
                  (ClassifiedImage - shift(ClassifiedImage,0,1) ne 0) )]=1b
  
  
  if keyword_set(s2f) then begin
    s2f = (size(s2f,/type) eq 7) ? s2f : 'VectorisedImage.BYT'
    print,' Writing output to file: <'+s2f+'>'
    openw,  1, s2f
    writeu, 1, VectorisedImage
    close,  1
  endif
  
end
;---------------------------------------------------------------------------------------

pro test_maskOutline
; Read in a Land mask file   
  mask  = readu_data('/data/nwp1/fra6/DeepBlue/L2_Collection5/YP_LANDMASK_4320x2160.8bit',$
                      DIM=[4320,2160], TYPE='byt')
  
; Get mask boundaries
  maskOutline, mask, outline
  
  window,xs=800,ys=400
  tvscl,mask(1900:1900+399,600:600+399),0,/order
  tvscl,outline(1900:1900+399,600:600+399),1,/order
  
end            
