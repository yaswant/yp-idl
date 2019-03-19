function get_msg_cloudmask, SlotstoreFile, ObjectPath, $
          START=start, COUNT=count, STRIDE=stride, $
          CLOUD_BIT=cb, EXCLUDE_DUST=nodust, DUST_BIT=db, $
          INVERT=invert, STATUS=status
;+
; :NAME:
;     get_msg_cloudmask
;
; :PURPOSE:
;     Extract SEVIRI cloud mask from Slotstore file. The result is
;     a 2 byte mask where 1:true, 0:false
;
; :SYNTAX:
;     Result = GET_MSG_CLOUDMASK( SlotstoreFile [,ObjectPath]
;               [,START=Array] [,COUNT=Array] [,STRIDE=Array]
;               [,CLOUD_BIT=Value] [,/EXCLUDE_DUST [,DUST_BIT=Value]]
;               [,/INVERT] )
;
;
;  :PARAMS:
;    SlotstoreFile (IN:String) MSG Slotstore (h5) file containing SEVIRI
;               Cloudmask.
;    ObjectPath (IN:String) HDF Path to SEVIRI Cloudmask. If this argument is
;               absent, the program sets the path to '/Product/GM/CloudMask'
;               or '/Product/GM/CloudMask32' whichever is available in
;               the Slotstore File.
;
;
;  :KEYWORDS:
;    START (IN:Array) A 2-element array indicating the starting position of
;               MSG data to be extracted; def [0,0].
;    COUNT (IN:Array) A 2-element array indicating the number of pixels to
;               extract along X and Y; def read in all pixels.
;    STRIDE (IN:Array) A 2-element array indicating the number of pixels to
;               skip along X and Y dimension; def [1,1].
;    CLOUD_BIT (IN:Value) Bit number for SEVIRI cloud Mask; def 30.
;    /EXCLUDE_DUST - Exclude dusty pixels from Cloud Mask 
;               (Only in 32bit CldMsk).
;    DUST_BIT (IN:Value) Bit number for SEVIRI Dust Mask; def 28.
;    /INVERT - Inverts the result mask so that cloudy=0; nocloud=1.
;    STATUS (OUT:Variable) A named variable to store status.
;
; :REQUIRES:
;   h5d_test.pro
;   get_msg_h5.pro
;   get_sps_constants.pro
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;     MSG Slotstore File handling, Cloud Mask
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  18-May-2011 15:41:33 Created. Yaswant Pradhan.
;
;-


  COMPILE_OPT idl2

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Parse Arguments/Keywords
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  syntax ='Result = GET_MSG_CLOUDMASK( SlotstoreFile [,ObjectPath] '+$
                    '[,START=Array] [,COUNT=Array] [,STRIDE=Array] '+$
                    '[,CLOUD_BIT=Value] [,/EXCLUDE_DUST [,DUST_BIT=Value]] '+$
                    '[,/INVERT] )'
  if N_PARAMS() lt 1 then message,' Syntax: '+ syntax  
  inv = KEYWORD_SET(invert)
  ndu = KEYWORD_SET(nodust)
  cb = KEYWORD_SET(cb) ? cb : 30 ;30th bit in New Cloud Mask
  db = KEYWORD_SET(db) ? db : 28 ;28th bit is Dust in New Cloud Mask


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Check whether 32bit or 16bit cloudmask exists in the
; Slotstore file and adjust keywords accordingly
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if N_PARAMS() lt 2 then begin

    v16 = h5d_test(SlotstoreFile, '/Product/GM/CloudMask')
    v32 = h5d_test(SlotstoreFile, '/Product/GM/CloudMask32')

    if v16 then begin
      print,' Reading Old (16bit) cloudmask.. ',FORM='(A,$)'
      ObjectPath = '/Product/GM/CloudMask'
      cb = KEYWORD_SET(cb) ? cb : 14 ;14th bit in Old Oprational Cloud Mask
      db = KEYWORD_SET(db) ? db : 14 ;No dust flag in old Cloud Mask
    endif else $
    if v32 then begin
      print,' Reading New (32bit) cloudmask.. ',FORM='(A,$)'
      ObjectPath = '/Product/GM/CloudMask32'

    endif else begin
      print,' Cloudmask path not defined correctly.'
      status = -1
      return, -1
    endelse

  endif else begin

    if ~h5d_test(SlotstoreFile, ObjectPath) then begin
      print, ObjectPath +' does not exist in '+ SlotstoreFile
      status = -1
      return, -1
    endif

    print,' Reading '+ObjectPath+'.. ',FORM='(A,$)'

  endelse


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Get CloudMask array from Slotstore File
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cm = get_msg_h5(SlotstoreFile, ObjectPath, $
                  START=start, COUNT=count, STRIDE=stride, $                              
                  STATUS=status)
  print,'done.'


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Create Inverted Dust mask (dust=0, nodust=1)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if ndu then ndust = v16 ? ((cm and 2^db) < 1) : ~((cm and 2^db) < 1)


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Cloud Mask returns:
;   1b=Cloud, 0b:Cloud Free
;   1b=Cloud, 0b:Dust Free (with EXCLUDE_DUST keyword)
;   0b=Cloud, 1b:Cloud Free (with INVERT keyword)
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  res = inv ? ( ndu ? (~byte((cm and 2^cb) < 1)*ndust) : $
                       ~byte((cm and 2^cb) < 1) ) : $
              ( ndu ? ( byte((cm and 2^cb) < 1)*ndust) : $
                        byte((cm and 2^cb) < 1) )


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Check out-of-disc pixels (assigned IMDI in Slotstore File) and
; mask those pixels as 0
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  x = WHERE(cm eq get_sps_constants('IMDI'), nx)
  if (nx gt 0) then res[x] = 0
  return, res

end