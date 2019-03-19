function h5d_test, FileName, Name, GROUP=group
;+
; :NAME:
;     h5d_test
;
; :PURPOSE:
;     The H5D_TEST function checks if a DATASET exists in H5 files. 
;     H5D_TEST returns: 
;       1 (true), if the specified dataset exists 
;       0 (false), if the specified dataset exists
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
; :COPYRIGHT: (c) Crown Copyright Met Office
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


pro write_h5, Data, Filename, $
              VARNAME=vname, $
              ATTRIBUTES=attributes, $
              ATTRNAMES=attrNames, $
              APPEND=append, $
              OVERWRITE=overwrite, $
              FORCE=force

;+
; :NAME:
;     write_h5
;
; :PURPOSE:
;     The WRITE_H5 procedure writes or appends plain or structured dataset 
;     to an HDF5 file.
;
; :SYNTAX:
;     write_h5, Data, Filename [,VARNAME=String] [,ATTRIBUTES=Structure] 
;               [,ATTRNAMES=Array] [,/APPEND |,/OVERWRITE] [,/FORCE]
;
;  :PARAMS:
;    Data (IN:Array) Input data array to write or append to h5 file.
;    Filename (OUT:String) Output h5 filename.
;
;
;  :KEYWORDS:
;    VARNAME    (IN:String) Variable name of the dataset. 
;    ATTRIBUTES (IN:Structure) Data Attributes to attach with the dataset.
;    ATTRNAMES  (IN:String|Array) Modified names of the Attributes given 
;               in Attributes. 
;    /APPEND    Add data to existing h5 File (Filename)
;    /OVERWRITE Write a fresh h5 file (if a Filename already exists).
;               Make sure you do not accidentally delete an important file.  
;    /FORCE     Filename can contain full directory. If a directory tree 
;               does not exists in path, this keyword will force creation
;               of the directory to h5 file first. 
;
; :REQUIRES:
;     IDL 7.0 and above 
;
; :EXAMPLES:     
;     To write a fltarr(20,20) in my/group/data tree and name it testdata
;     IDL> write_h5, fltarr(20,20), 'test.h5', VARNAME='my/test/data/testdata'
;     
;     To add another array intarr(101) to the existing file's top level and 
;     name it topdata
;     IDL> write_h5, intarr(101), 'test.h5', VARNAME='topdata', /APPEND
;     
;     To overwrite topdata to the same file but in a different group newgroup
;     IDL> write_h5, intarr(101), 'test.h5', /over, VARNAME='newgroup/topdata'
;
; :CATEGORIES:
;     File I/O
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  03-Feb-2011 16:18:48 Created. Yaswant Pradhan. v-0.1
;  07-Feb-2011 Added functionality to accept group names via 
;              VARNAME keyword (See example). YP.
;  07-Apr-2011 Major revision. v-1.0
;              Added data append functionality. YP.
;              Added data attribute keyword. YP.            
;  15-Apr-2011 Error handling for existing dataset in /Append mode. YP.
;  08-Jun-2011 Added expand_path to handle full path for Filename. YP.
;-
   
  compile_opt idl2;, strictarrsubs
  
  syntax = 'write_h5, Data, Filename [,VARNAME=String] '+$
           '[,ATTRIBUTES=Structure] [,ATTRNAMES=Array] '+$
           '[,/APPEND |,/OVERWRITE] [,/FORCE]'

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Parse Arguments and Keywords
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
  if N_PARAMS() lt 2 then begin
    print, 'Syntax: '+syntax
    return
  endif  
  
; Check conflicting Keywords:
  app = KEYWORD_SET(append)
  ovr = KEYWORD_SET(overwrite)
  if (app and ovr) then begin
    print,'[write_h5]: Conflicting keywords - /APPEND and /OVERWRITE.'
    return
  endif  


; Check if the file exists to handle Append and Overwrite keywords:
  FileName = EXPAND_PATH(FileName)
  if (app and ~FILE_TEST(Filename) ) then begin    
    print,'[write_h5]: '+ Filename +$
          ' does not exist for append.'
    return    
  endif


; Check what to do if Filename already exists:    
  if (FILE_TEST(Filename) and (app+ovr eq 0)) then begin    
    print,'[write_h5]: '+ Filename +$
          ' exists. Use Keywords '+$
          '[/OVERWRITE] to replce existing file] OR '+$
          '[/APPEND] to add new data to existing file'
    return    
  endif


; Check if the file path is valid. Create if force keyword is provided:   
  if ~FILE_TEST(FILE_DIRNAME(Filename),/DIR) then begin
    if KEYWORD_SET(force) then FILE_MKDIR, FILE_DIRNAME(Filename) else $
    begin
      print,'[write_h5]: '+ FILE_DIRNAME(Filename) +' does not exist. '+$
            'Use Force keyword to create path.'
      return      
    endelse
  endif 


; Parse Group/Dataset names:  
  vName = KEYWORD_SET(vname) ? vname : 'DATA'  ; Dataset full path
  grps  = STRSPLIT(vName, '/', /EXTRACT, COUNT=n_grps) ; Group Names
  
; Parent groupname:
  parentGrp = (n_grps gt 1) ? STRJOIN(grps[0:n_grps-2],'/') : $
              grps
  

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Create or Append Group/Dataset to an existing File
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
  fId = app ? H5F_OPEN(Filename,/WRITE) : H5F_CREATE(Filename)  
  
  if (fId le 0 ) then begin
    print,'[write_h5]:: Failed to '+(app ? 'Open' : 'Create')+ Filename
    return
  endif

  if app then begin    
    Err = {Msg:'',Stat:0}    
        
    if h5d_test(Filename, vName) then begin
      Err.Msg = ' A Dataset ['+vName+'] already exists in the File.'
      ++Err.Stat
    endif
                   
    if h5d_test(Filename,vName,/GROUP) then begin
      Err.Msg = ' A Group ['+vName+'] already exists in the File.'
      ++Err.Stat      
    endif
      
    if h5d_test(Filename,parentGrp) then begin
      Err.Msg = ' Can not create group ['+parentGrp+$
                ']; a Dataset with same name already exists in the File.'
      ++Err.Stat
    endif                            
    
    if Err.Stat ne 0 then begin
      print, Err.Msg
      return
    endif                  
        
  endif  
    
;  status=1b  
;; Check if the dataset already exists in the file
;; Retrun meaningful message if so  
;  if app then begin
;    status=0b
;    catch, errExist    
;    
;    if errExist ne 0 then begin      
;      catch, /CANCEL
;      status = errExist ne 0      
;      if status eq 0 then return else goto, SKIP_INQ       
;    endif      
;           
;    dId = H5D_OPEN( fId, vName )
;    SKIP_INQ:
;  endif
;    
;  if status eq 0 then begin
;    print,' Dataset ['+vName+'] already exists in '+Filename
;    H5D_CLOSE, dId
;    return
;  endif
  
    
; 1.0. Create Groups if necessary
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  for i=0,n_grps-2 do begin    
    gName = (i eq 0) ? grps[i] : gName +'/'+ grps[i]
           
    catch, Error    
    if Error ne 0 then begin
      catch, /CANCEL
      gId = H5G_CREATE( fId, gName )      
    endif

    gId = H5G_OPEN( fId, gName )
    if (gId le 0 ) then begin
      print,'[write_h5]:: Failed to create group '+ gName
      return
    endif

    H5G_CLOSE, gId
    gId = -1        
  endfor ;for i=0,n_grps-2
  
  
; 1.1. Check if name ends with a forward slash, 
;      in this case only groups are created
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (STRMID(vName, 0,1, /REVERSE_OFFSET) eq "/" ) then begin
    gName = STRMID(vName, 0, strlen(vName)-1 )
    gId = H5G_CREATE( fId, gName )

    if (gId le 0 ) then begin
      print,"ERROR:: Failed to create group"+ gName
      return
    endif

    H5G_CLOSE, gId
    gId = -1
  endif
    
  
  
; 2.   Write/Append new Single data layer
; 2.0. Get data type and space again for the new dataset
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if N_ELEMENTS(Data) gt 0 then begin
    chunkDims = SIZE(Data,/DIMENSIONS)
    numDim    = SIZE(Data,/N_DIMENSIONS)
    
    if (numDim gt 2) then chunkDims[0:numDim-3] = 1
    dType_id = H5T_IDL_CREATE(Data)

    if SIZE(Data,/N_DIMENSIONS) eq N_ELEMENTS(extensible) then begin
    ; Note: This is a dummy block
    ; No method to extend the data as yet
      idx = WHERE(extensible, n_idx)
      sze = SIZE(Data,/DIMENSIONS)      
      if n_idx eq 1 then sze[idx] = -1
      dSpace_id = H5S_CREATE_SIMPLE(sze)
    endif else begin    
      dSpace_id = H5S_CREATE_SIMPLE(SIZE(Data,/DIMENSIONS))
    endelse


; 2.1. Create dataset in the output file
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    dSet_id = H5D_CREATE( fId, vName, dType_id, dSpace_id, $
                          CHUNK_DIMENSIONS=chunk_dimensions, $
                          GZIP=9, /SHUFFLE )


; 2.2. Write data to dataset
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    H5D_WRITE, dSet_id, Data
    H5S_CLOSE, dSpace_id
    H5T_CLOSE, dType_id
  endif else begin
    dSet_id = H5G_OPEN(fId, vName) ; No data, just groups
  endelse
  
  
; 3.   Write Attributes, if present 
; 3.0. if attributes are given, add them to the data.
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if N_ELEMENTS(attributes) gt 0 then begin
    names = N_ELEMENTS(AttrNames) eq N_TAGS(attributes) ? $
            AttrNames : STRLOWCASE(TAG_NAMES(attributes))

    for k=0,N_TAGS(attributes)-1 do begin
      case names[k] of
        '_fillvalue': name = '_FillValue'
        'missingvalue': name = 'MissingValue'
        'offset': name = 'Offset'
        'scalefactor': name = 'ScaleFactor'
        else: name = names[k]
      endcase

      dims = SIZE(attributes.(k), /DIMENSIONS)
      if dims eq 0 then dims = 1
      attr_dType_id   = H5T_IDL_CREATE(attributes.(k))
      attr_dSpace_id  = H5S_CREATE_SIMPLE(dims)

      attr_id = H5A_CREATE(dSet_id, name, attr_dType_id, attr_dSpace_id)
      if attr_id le 0 then begin
        print, "ERROR:: failed to create attribute"
        return
      endif
      
      H5A_WRITE, attr_id, attributes.(k)
      
      H5A_CLOSE, attr_id
      H5S_CLOSE, attr_dSpace_id
      H5T_CLOSE, attr_dType_id
    endfor ;for k=0,N_TAGS(attributes)-1
  endif


; 4. Close all open identifiers
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (N_ELEMENTS(Data) gt 0) $
  then H5D_CLOSE, dSet_id $
  else H5G_CLOSE, dSet_id
    
  H5F_CLOSE, fId
  
end
