;+
; :NAME:
;     get_msg_h5
;
; :PURPOSE:
;     GET_MSG_H5 function extracts a single dataset from a valid HDF5 file. The
;     extracted data can be sub-sampled on-the-fly (see Start/Stride/Count
;     keywords). IDL has intrinsic function (h5_parse) to read in full content
;     of an HDF5 file; however, given the huge size of MSG Slotstire files
;     (>5GB) the intrinsic functions will be limited to the type of OS and IDL
;     version (fail to read a slotstore file in 32-bit systems).
;
; :SYNTAX:
;     Result = GET_MSG_H5( Filename, Object [,START=Array] [,COUNT=Array]
;                          [,STRIDE=Array] [,STATUS=Variable] [,/VERBOSE])
;
;  :PARAMS:
;    Filename (IN:String) HDF5 Filename.
;    Object (IN:String) Full Dataset Path in the h5 file to read.
;
;
;  :KEYWORDS:
;    START (IN:Array) An m-element vector of integers, where m is the number of
;               dataspace dimensions, containing the starting location for the
;               hyperslab.
;    COUNT (IN:Array) An m-element vector of integers containing the number of
;               blocks to select in each dimension.
;    STRIDE (IN:ARRAY) Set this keyword to an m-element vector of integers
;               containing the number of elements to move in each dimension
;               when selecting blocks. The default is to move a single element
;               in each dimension (for example STRIDE is set to a vector of all
;               1's). STRIDE values must be greater than zero.
;    /VERBOSE   Verbose Mode.
;    STATUS (OUT:Variable) Named variable to store Status code:
;                0: No error,
;               -1: File is not valid h5,
;               -2: Input object is a Group intead of Dataset,
;               -3: Input object doesnot exist in the h5 file.
;
; :REQUIRES:
;     h5d_test.pro
;
; :EXAMPLES:
;     To extract a sub-area (100x100 pixels subsampled at 4x4 pixels) of Raw
;     SEVIRI IR039 counts, starting from equator at 0-Lon (i.e., starting
;     position 1856, 1856), from MSG_200802111015_lite.h5 file
;
; IDL> data = get_msg_h5('MSG_200802111015_lite.h5', '/MSG/IR_039/Raw', $
;             START=[1856, 1856], COUNT=[100,100], STRIDE=[4,4] )
;
; IDL> HELP, data
;       DATA    INT = Array[100, 100]
;
;
; :LIMITATIONS:
;     Can not read data from Externally linked Objects. (now sorted)
;
; :CATEGORIES:
;     HDF5, Large Data handling
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  20-Jun-2011 Created after get_msg_ssd was made redundant. Yaswant Pradhan.
;  21-Jun-2011 Removed dependecies on HDF5 system command ('h5ls'). YP.
;  23-Jun-2011 Can read externally linked objects. YP.
;
;-

FUNCTION get_msg_h5, Filename, Object, $
         START=start, COUNT=count, STRIDE=stride, $
         VERBOSE=verbose, STATUS=status



  !QUIET=1
  syntax ='Result = GET_MSG_H5( Filename, Object '+$
          '[,START=Array] [,COUNT=Array] [,STRIDE=Array] '+$
          '[,STATUS=Variable] )'

  ; Parse inputs
  if (N_PARAMS() lt 1) then message, syntax

  status = 0
  v = KEYWORD_SET(verbose)

  ; Valid Hdf File? Status Code: -1
  if ~H5F_IS_HDF5(Filename) then begin
    print,'Not a Valid H5 File.'
    status = -1
    return, status
  endif


  ; Insufficient arguments? Status Code: 0
  if (N_PARAMS() lt 2) then begin
    Object ='/'
    status = 0
    print, string(10b)+'Syntax:'+string(10b)+' '+syntax
  endif


  ; Object is a Group instead of Data? Status Code: -2
  if h5d_test(Filename, Object,/GROUP) then begin
    print,' ['+ Object + '] is a Group containing the following objects:'

    fId = H5F_OPEN(Filename)
    gId = H5G_OPEN(fId, Object)
    for i=0,H5G_GET_NMEMBERS(fId, Object)-1 do begin
      mName = H5G_GET_OBJ_NAME_BY_IDX(gId, i)
      print,' ['+strtrim(i+1,2)+'] '+mName
      if v then help, /STRUCTURES, H5G_GET_OBJINFO(gId, mName, /FOLLOW_LINK)
    endfor
    H5G_CLOSE, gId
    H5F_CLOSE, fId

    status = -2
    return, status
  endif


  ; Dataset is absent? Status Code: -3
  if not h5d_test(Filename, Object) then begin
    print,' ['+ Object + '] is not a valid Dataset.'
    status = -3
    return, status
  endif



  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ; Read data from h5 file
  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ; Open the SSD H5 File
  fId = H5F_OPEN(Filename)

  if v then print,'Reading '+$
      STRJOIN(STRSPLIT(Filename+'/'+Object,'/',/ext),'/')+'..'

  ;helps, H5I_GET_TYPE(H5D_OPEN(fId, Object))
  ;print, H5G_GET_LINKVAL(fId, Object)

  ; Get data id for H5 Object
  dataId  = H5D_OPEN(fId, Object)
  dSpaceId= H5D_GET_SPACE(dataId)
  dataDim = H5S_GET_SIMPLE_EXTENT_DIMS(dSpaceId)
  nDims   = H5S_GET_SIMPLE_EXTENT_NDIMS(dSpaceId)

  if v then print,'Actual Dim: ['+STRJOIN(STRTRIM(dataDim,2),',')+']'


  ; Return data
  if (nDims lt 1) then return, H5D_READ(dataId) else begin

    start  = KEYWORD_SET(start)  ? start  : LONARR(nDims)
    stride = KEYWORD_SET(stride) ? stride : LONARR(nDims)+1
    count  = KEYWORD_SET(count)  ? count/stride : (dataDim-start)/stride

    if v then begin
      print,'Start:      ['+STRJOIN(STRTRIM(start,2),',')+']'
      print,'Stride:     ['+STRJOIN(STRTRIM(stride,2),',')+']'
      print,'Result Dim: ['+STRJOIN(STRTRIM(count,2),',')+']'
    endif

    H5S_SELECT_HYPERSLAB, dSpaceId, start, count, STRIDE=stride, /RESET

    memSpaceId = H5S_CREATE_SIMPLE(count)

    data = H5D_READ( dataId, FILE_SPACE=dSpaceId, $
                     MEMORY_SPACE=memSpaceId )

    H5S_CLOSE, memSpaceId
    H5S_CLOSE, dSpaceId
    H5D_CLOSE, dataId
    H5F_CLOSE, fId

    return, data

  endelse

END
