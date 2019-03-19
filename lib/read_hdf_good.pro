;+
; :Name:
;     read_hdf_good
;
; :Purpose:
;     Read HDF4 filesinto a structure
;
; :Syntax:
;
; :Params:
;    filename
;
;
;
; :Requires:
;
; :Example:
;
; :Author: Elizabeth Good
; :History:
;   09-Apr-2012 updated. yp.
;-

FUNCTION read_hdf_good, filename

  outdata={filename : filename}


  ; Input argument checks
  if hdf_ishdf(filename) ne 1 or n_elements(filename) eq 0 then begin
    print, 'invalid hdf file ...'
    return, create_struct(outdata, 'error', 1)
  endif


  ; Get ID for HDF file we are trying to read - we need this to do
  ; anything with the file.
  newFileID = HDF_SD_START(filename, /READ)


  ; Establish the number of data sets and attributes (global vars?) in file.
  HDF_SD_FILEINFO, newFileID, datasets, attributes


  ; Loop through data sets and extract data and their attributes.
  for j=0,datasets-1 do begin

    ; Get SDS name and the number of data set attributes.
    thisSDS = HDF_SD_SELECT(newFileID, j)
    HDF_SD_GETINFO, thisSDS, NAME=thisSDSName, NATTS=numAttributes

    ; Replace '.' with '_' in SDS names, if exists (YP)
    thisSDSName = strjoin(strsplit(thisSDSName,'.',/extract),'_')

    ; Read in the data set.
    HDF_SD_GETDATA, thissds, thisdata

    ; Create a structure with this data set name and add these data.
    result = execute(thisSDSName+'={data : thisdata}')

    ; Read in each attribute and add to the structure created for this data set
    for k=0,numAttributes-1 do begin
      HDF_SD_ATTRINFO, thisSDS, k, NAME=thisAttrName, DATA=thisdata
      result = execute(thisSDSName+$
                        '=CREATE_STRUCT('+thisSDSName+', "'+$
                        thisAttrName+'", thisdata)')
    endfor


    ; now add this SDS data structure to the main structure
    result = execute('outdata=CREATE_STRUCT(outdata, "'+$
                      thisSDSName+'", '+thisSDSName+')')

  endfor

  ; Close the HDF file and return data structure
  HDF_SD_END, newFileID
  RETURN, create_struct(outdata, 'error', 0)

END