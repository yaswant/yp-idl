function h5d_test, FileName, Name, GROUP=group
;+
; :NAME:
;    	h5d_test
;
; :PURPOSE:
;     The H5D_TEST function checks if a DATASET exists in H5 files. 
;     H5D_TEST returns: 
;       1 (true), i.e., the specified dataset exists 
;       0 (false), i.e., the specified dataset does not exist
;       -1 if the specified File doesnot exist
;      
; :SYNTAX:
;     Result = h5d_test(Filename, Name)
;
;  :PARAMS:
;    FileName (IN:string) Input hdf5 Filename
;    Name (IN:String) Input dataset name 
;         (full path of dataset e.g., 'Product/GM/CloudMask')
;
;  :KEYWORDS:
;    /GROUP Test for existence of Group instead of Dataset 
; 
; :REQUIRES:
;     IDL7.0
;
; :EXAMPLES:     
;
; :CATEGORIES:
;     HDF5
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  18-Apr-2011 11:46:18 Created. Yaswant Pradhan.
;
;-

  if ~FILE_TEST(FileName) then begin
    print,' Could not find file: '+FileName
    return,-1
  endif
  
  fId = H5F_OPEN(FileName)
    
  status=0b ; Initialise status  

  catch, err
  if err ne 0 then begin    
    catch, /CANCEL
    status = err ne 0              
    if (status eq 1) then goto, SKIP_H5D_OPEN       
  endif
           
  dId = KEYWORD_SET(group) ? $
        H5G_OPEN( fId, Name ) : $
        H5D_OPEN( fId, Name )
  SKIP_H5D_OPEN:

  if status eq 0 then begin
    if KEYWORD_SET(group) then H5G_CLOSE,dId $
    else H5D_CLOSE, dId
  endif
  H5F_CLOSE,fId
  
  return, ~status

end  
