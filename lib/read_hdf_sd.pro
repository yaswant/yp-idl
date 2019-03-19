;+
; :NAME:
;       read_hdf_sd
;
;   Based on Lizzie Good's read_hdf
;   For large HDF files, the read time can be longer mainly due to
;   the EXECUTE overheads.
;
;
; :PURPOSE:
;   Read scientific data records from HDF4 HDFSD file
;
; :SYNTAX:
;   Result = read_hdf_sd( Filename [,SDSLIST=array] [,/VERBOSE] )
;
; :PARAMS:
;    Filename (in:string) HDF filename
;
;
; :KEYWORDS:
;    SDSLIST (in:strarr) String array of selected SDS to read; Defult is to
;           read all SDS
;    /VERBOSE Set this keyword to print SDS details
;
; :REQUIRES:
;
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;       I/O
;
; :SEE ALSO:
;       read_hdf.pro
;
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  04-Jun-2013 17:14:25 Created. Yaswant Pradhan.
;
;-
FUNCTION read_hdf_sd, Filename, SDSLIST=sdsList, VERBOSE=verbose

    ; Initilaise the output structure with a dummy variable to store
    ; the input filename:
    out = {FILENAME : Filename}
    _v = KEYWORD_SET(verbose)

    ; Parse input:
    if ~HDF_ISHDF(Filename) then begin
        print,'** ERROR: Invalid HDF file.**'
        return, CREATE_STRUCT(out, 'ERROR', -1)
    endif


    ; Initialise SD Interface, Open file in READ-only mode:
    sdId = HDF_SD_START(Filename, /READ)


    ; Retrieve number of datasets and global attributes in the HDF file:
    HDF_SD_FILEINFO, sdId, datasets, attributes


    ; Read in dataset and corresponding attributes:
    for sd=0, datasets-1 do begin
        ; Get SD dataset ID from for current dataset number and
        ; retrieve SD Name and number of Attributes:
        sds = HDF_SD_SELECT(sdId, sd)
        HDF_SD_GETINFO, sds, NAME=sdsName, NATTS=nAtts

        subSdsName = N_ELEMENTS(sdsList) gt 0 ? sdsList : sdsName

        if STRMATCH(subSdsName, sdsName,/FOLD) then begin
            if _v then print, sdsName

            ; Check for valid IDL names:
            sdsName = IDL_VALIDNAME(sdsName,/CONVERT_ALL)


            ; Read in the data set:
            HDF_SD_GETDATA, sds, sData

            ; Create a structure with this data set name and add these data:
            result = EXECUTE(sdsName+'={DATA : sData}')

            ; Read in each attribute and add to the structure created for
            ; this dataset:
            for k=0,nAtts-1 do begin
                HDF_SD_ATTRINFO, sds, k, NAME=AttrName, DATA=sData
                result = EXECUTE(sdsName+$
                    '=CREATE_STRUCT('+sdsName+', "'+AttrName+'", sData)')
            endfor


            ; Add SDS data structure to the main structure:
            result = EXECUTE('out=CREATE_STRUCT(out, "'+sdsName+'", '+$
                sdsName+')')
        endif

        HDF_SD_ENDACCESS, sds

    endfor


    ; Close the HDF file and return out structure:
    HDF_SD_END, sdId
    return, CREATE_STRUCT(out, 'ERROR',0)

END
