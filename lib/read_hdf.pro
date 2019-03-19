;+
; :NAME:
;       read_hdf
;
; :PURPOSE:
;    The READ_HDF routine recursively descends through an HDF4/SD file
;    and reads the Dataset and Attributes to an output  structure.
;
;    Note:
;    Not to confuse with files in HDF5 format (.h5,.he5), for which H5_PARSE
;    function could be used.
;
;    The Dataset in the output structure are of different types
;    1. If only one SDS is requires to be read (passed via SDSLIST keyword),
;       then the output DATA is a plain variable
;    2. If more than 1 SDS (or the all datasets in the file) requires to be
;       read then the DATA stored as pointer variables in the outoput
;       structure array, meaning the user needs to free the heap variables
;       manually to avoid any memory leak.
;
; :SYNTAX:
;    read_hdf, filename [,out] [, attribute] [,status] $
;              [,SDSLIST=Array] [,/SCALE_DATA] [,/FREE] $
;              [,/VERBOSE] [,/INFO] [,/QUIET]
;
;    :PARAMS:
;    filename (in:string) Input HDF4(SDS) filename
;    out (out:variable) A named variable to store the dataset/attributes.
;    attr (out:variable) A named variable to store the Global attributes.
;    status (out:variable) A named variable to store the output status
;            0: OK
;           -1: Invalid HDH4/SDS file.
;           -2: No valid Scientific dataset in the file.
;
;
;  :KEYWORDS:
;    SDSLIST (in:array) String array containing Scientific Dataset list to
;           read from the file; Def: read all valid datasets in the file.
;           Note: These are CaseSensitive strings, so provide exact sds
;           names.
;    /SCALE_DATA  Apply scaling to the output data. Please use this keyword
;           carefully. The default method applied is
;           scaled = scale * (data - offset)
;           This may not be true for all datasets. Check the Global/
;           dataset attributes to confirm/change this.
;    /FREE Set this keyword to read data to a structure containing plain
;           data array instead of pointer array. In this case no need to
;           manually free the heap variable
;    /VERBOSE Verbose mode.
;    /INFO Set this keyword to view available Datasets and Attributes
;    /QUIET Quiet mode
;
;
; :REQUIRES:
;    Routine_Names.pro from
;    http://www.physics.wisc.edu/~craigm/idl/down/routine_names.pro
;
; :EXAMPLES:
;
; :NOTE:
;   Always use heap_free, out to free memory occupied by heap variables.
;   For interactive application consider read_hdf_sd function
;
; :CATEGORIES:
;    File I/O, HDF4
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  11-Apr-2011 14:24:50 Created. Yaswant Pradhan.
;  03-Jun-2014 Addedd free keyword. YP
;-

pro read_hdf, filename, out, attr, status, $
        SDSLIST=sdsList, SCALE_DATA=scale_data, $
        FREE=free, VERBOSE=verbose, INFO=info, $
        QUIET=quiet

    v  = KEYWORD_SET(verbose) or KEYWORD_SET(info)
    qt = KEYWORD_SET(quiet)
    hr = STRJOIN(REPLICATE('_',80))
    br = STRING(10b)

    status = 0

    syntax  = ' read_hdf, filename, out [,attribute] [,status]'+$
        ' [,SDSLIST=Array] [,/SCALE_DATA] [,/FREE] [,/VERBOSE]'+$
        ' [,/INFO] [,/QUIET]'

    ; Select File via dialog pick if no hdf file prescribed.
    if N_ELEMENTS(filename) eq 0 then begin
        PRINT,'Syntax:'+br+syntax
        filename = DIALOG_PICKFILE()
    endif

    hdfinfo = (FILEINFO(filename)).HDF


    if ~qt then PRINT,' '+FILE_BASENAME(filename)

    if (HDF_ISHDF(filename) eq 0 or hdfinfo eq 0) then begin
        PRINT, FILE_BASENAME(filename)+' --Invalid hdf file--'

        FILE_DELETE,filename
        status = -1
        RETURN
    endif

    ; helps,FILEINFO(filename)
    ; Open HDF and read datasets, attributes and palettes.
    fileId = HDF_SD_START(filename, /READ)

    ; Get Number of Datasets, Global attributes and Palettes
    ; Each Palette is a [3,256] bytarr
    HDF_SD_FILEINFO, fileId, nDatasets, nGlobalAttr
    nPalettes = HDF_DFP_NPALS(filename)
    if nPalettes gt 0 then HDF_DFP_GETPAL, filename, Palettes

    if v then help, nDatasets, nGlobalAttr, nPalettes


    ; Read Global attributes
    if (nGlobalAttr gt 0) then begin
        attr = STRARR(nGlobalAttr)

        for j=0, nGlobalAttr-1 do begin
            HDF_SD_ATTRINFO, fileId, j, NAME=thisAttr
            HDF_SD_ATTRINFO, fileId, j, DATA=thisValue

            attr[j] = hr+ br+thisAttr+': '+STRING(thisValue)+br +hr
            if v then PRINT,' Global Attribute ',STRTRIM(j+1,2),': ',thisAttr

            scaling_info = STRCMP(thisAttr,'Slope_and_Offset_Usage',/FOLD) $
                ? KEYWORD_SET(scale_data) ? 'Scaled Data' : thisValue $
                : 'Undefined'
        endfor

    endif else attr = 'No Global Attributes found in the File!'


    ; -------------------------------------------------------------------------
    ; Get name of each SDS and associated data attributes.
    ; If SDSLIST keyword is not passed, then read all SDS in the file.
    ; -------------------------------------------------------------------------
    if nDatasets le 0 then begin
        PRINT,' No Datasets found in the File.'
        status = -2
        RETURN
    endif

    if KEYWORD_SET(sdsList) then begin
        nDatasets = N_ELEMENTS(sdsList)
    endif else begin
        sdsList = STRARR(nDatasets)

        for j=0,nDatasets-1 do begin
            sdsId = HDF_SD_SELECT(fileId, j)
            HDF_SD_GETINFO, sdsId, NAME=sdsName, NATTS=nAtts
            sdsList[j] = sdsName
            if v then PRINT,' Dataset No. ',STRTRIM(j+1,2),': ',sdsName
            HDF_SD_ENDACCESS, sdsId
        endfor ;for j=0, datasets-1 do begin

    endelse ;if not KEYWORD_SET(sdsList) then begin


    if KEYWORD_SET(info) then return


    ; -------------------------------------------------------------------------
    ; Loop through each Dataset and get data
    ; -------------------------------------------------------------------------
    ; Output structure:
    out = REPLICATE( {$
        FileName: FILE_BASENAME(filename), $
        Name: ' ', $
        Data: PTR_NEW(), $
        Scale_Factor: 1., $
        Add_Offset: 0., $
        Valid_Range: [-9999.,-9999.], $
        Units:' ', $
        Scaling_Usage: scaling_info, $
        _FillValue: -9999 }, N_ELEMENTS(sdsList) )

    ; Get Data attributes:
    for k=0,nDatasets-1 do begin

        index = HDF_SD_NAMETOINDEX(fileId, sdsList[k])
        if (index ne -1) then begin
            sdsId = HDF_SD_SELECT(fileId, index)

            ; Get the dataset
            HDF_SD_GETDATA, sdsId, sData
            out[k].Name = sdsList[k]
            out[k].Data = PTR_NEW(sData)

            ; Get Data Attributes
            HDF_SD_GETINFO, sdsId, NATTS=nAtts

            if v then begin
                print,hr
                print,' Dataset '+STRTRIM(k+1,2)+': '+ sdsList[k] +$
                    ' ['+ STRJOIN(STRTRIM(SIZE(sData,/DIMENSIONS),2),',') +']'
                print,'  Number of Data attributes: '+ STRTRIM(nAtts,2)
            endif

            ; Get Attribute Names and Values
            for j=0,nAtts-1 do begin

                HDF_SD_ATTRINFO, sdsId, j, NAME=attName, DATA=attData
                if v then PRINT,'   Attribute '+ STRTRIM(j+1, 2) +': '+$
                    attName +' ['+ STRJOIN(STRTRIM(attData,2),',')+']'

                case STRUPCASE(attName) of
                    'SCALE_FACTOR': out[k].Scale_Factor = attData
                    'ADD_OFFSET': out[k].Add_Offset = attData
                    'VALID_RANGE': out[k].Valid_Range = attData
                    'UNITS': out[k].Units = attData
                    '_FILLVALUE': out[k]._FillValue = attData
                    else: if v then dummy=0b ;print,'  ^^ Not used ^^'
                endcase

            endfor ;for j=0,nAtts-1 do begin
            HDF_SD_ENDACCESS, sdsId


            ; Scale data (apply scaling factor and offets)
            if KEYWORD_SET(scale_data) then begin

                *out[k].Data = out[k].Scale_Factor * (sData - out[k].Add_Offset)
                out[k].Valid_Range = out[k].Scale_Factor * $
                    (out[k].Valid_Range - out[k].Add_Offset)

                ; Put Fill value back to filling (no data) area
                fill = WHERE(sData eq (out[k]._FillValue), n_fill)
                if n_fill gt 0 then $
                    (*out[k].Data)[fill] =  (out[k]._FillValue)[fill]

                ; Modify scling factors (no scaling required as is done already)
                out[k].Scale_Factor = 1.
                out[k].Add_Offset   = 0.
            endif


        endif else $
            print,'WARNING: Invalid SDS Name '+strtrim(k,2)+' ['+sdsList[k]+']'

    endfor  ; for k=0,N_ELEMENTS(sdsList)-1

    HDF_SD_END, fileId


    ; -------------------------------------------------------------------------
    ; Return Simple data array (rather than pointer) in a structure
    ; No need to free pointers in this case
    ; -------------------------------------------------------------------------
    if KEYWORD_SET(free) then begin
        outs = {FILENAME : FILE_BASENAME(Filename)}
        for k=0,N_ELEMENTS(out)-1 do begin
            tmp = {$
                Data: *out[k].Data, $
                Scale_Factor: out[k].Scale_Factor, $
                Add_Offset: out[k].Add_Offset, $
                Valid_Range: out[k].Valid_Range, $
                Units: out[k].Units, $
                Scaling_Usage: out[k].Scaling_Usage, $
                _FillValue: out[k]._FillValue $
                }

            sdsName = IDL_VALIDNAME(out[k].Name,/CONVERT_ALL)
            result = EXECUTE('outs=CREATE_STRUCT(outs, "'+sdsName+'", tmp)')
        endfor
        HEAP_FREE, out
        out = outs
        return
    endif


    ; -------------------------------------------------------------------------
    ; Print warning message if returning data with pointers to heap variables
    ; -------------------------------------------------------------------------
    if (nDatasets ge 1 and N_PARAMS() gt 1) then  begin
        var_name = Routine_Names(out, Arg_Name=(-1))

        if ~qt then PRINT,'WARNING! Multiple SDS read into pointers. '+$
            'To free heap variables type:'+br+' HEAP_FREE, '+ var_name
    endif

    if (nDatasets gt 1 and N_PARAMS() eq 1) then HEAP_FREE, out

end
