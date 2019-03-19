;*******************************************************************************
; NAME:
;	READ_H5
;
; PURPOSE:
;	This IDL program will read multi-dimensional arrays from a file stored
;	in the new version 5 Hierarchical Data Format (HDF5). Multi-dimensional
;   array data are stored in the HDF5 model known as a dataset. Users may
;	select a dataset along with the accompanying attribute information
;	by either specifying its name or full path.
;
;       If you don't know the name of the dataset you can use the list command
;       to display all the datasets found in the file with their full path.
;
;         READ_H5, FILE='foo.h5', /LIST
;
;       You can then choose one of those to read on a subsequent call.
;       Note the default will just list datasets, you can add the /GROUP
;       keyword to just list the groups in the file, or /ALL for everything.
;
;         READ_H5, data, FILE='foo.h5', NAME='/a/b/c/mydataset'
;
;      Or you can simply pass the name without the full path
;
;         READ_H5, data, FILE='foo.h5', NAME='mydataset'
;
;      But be warned if there are multiple datasets with the same name but
;      different paths, this call will only pick up the first dataset with
;      that name. That may not be the one you wanted. See /LIST above.
;
; CALLING SEQUENCE:
; 	READ_H5, data [, attr], FILE=file, NAME=name [ , /LIST, /GROUP, /ALL ]
;
; INPUTS:
;	file:	The name of the file.
;	name:	The name of the dataset to read.
;
; OUTPUTS:
;	data:	The array containing the data.
;
; OPTIONAL OUTPUT PARAMETERS:
;	attr:	Attributes belonging to the dataset.
;
; KEYWORDS Parameters:
;	File:	The name of the file to open.
;	Name:   The name of the dataset to read.
;	List:   List all the datasets in a file (optional).
;	Group:  Select just the groups (optional).
;	All:    Select all objects: dataset or group (optional).
;
; RESTRICTIONS:
;	None.
;
; AUTHOR:
;	Adopted from James Johnson, GES DISC DAAC
;
; MODIFICATION HISTORY:
;	Oct.  8, 2004 - Version 1.0. 
;	Dec. 12, 2006 - Can now list and find a dataset without path.
;	Jun 24, 2010 - Optimised. Yaswant Pradhan
;
;*******************************************************************************


FUNCTION list_objs, file_id, path, group=group, dataset=dataset
  
    ret = ""
    if (SIZE(path, /TYPE) eq 0) then path = ""	        ; Undefined
    new_path = (STRLEN(PATH) eq 0) ? "/" : path         ; Default path /
    group_id = H5G_OPEN(file_id, new_path)

    for i=0, H5G_GET_NMEMBERS(group_id, new_path)-1 do begin
        obj_name = H5G_GET_MEMBER_NAME(group_id, new_path, i)
        obj_info = H5G_GET_OBJINFO(group_id, obj_name, /FOLLOW_LINK)
        
        ; List Group:    
        if (obj_info.type EQ 'GROUP') then begin
          if not KEYWORD_SET(dataset) then print, path + "/" + obj_name
          
          ret = list_objs(file_id, path+"/"+obj_name, group=group, $
                          dataset=dataset)
        endif
        
        ; List Dataset:
        if (obj_info.type eq 'DATASET') then begin
          if not KEYWORD_SET(group) then print, path+"/"+obj_name
        endif    
    endfor

;    done:
    H5G_CLOSE, group_id
    RETURN, ret
END
; -----------------------------------------------------------------------------

FUNCTION find_object, file_id, name, path

    ret = ""
    if (SIZE(PATH,/TYPE) eq 0) then path=""	; Undefined
    new_path = (STRLEN(path) eq 0) ? "/" : path

    group_id = H5G_OPEN(file_id, new_path)

    for i=0, H5G_GET_NMEMBERS(group_id, new_path)-1 do begin
        obj_name = H5G_GET_MEMBER_NAME(group_id, new_path, i)
        obj_info = H5G_GET_OBJINFO(group_id, obj_name, /FOLLOW_LINK)
    
        if (obj_info.type eq 'GROUP') then begin
          ret = find_object(file_id, name, path + "/" + obj_name)
          if (STRLEN(ret) gt 0) then goto, done
        endif
    
        if (obj_info.type eq 'DATASET' and obj_name eq name) then begin
          ret = path
          goto, done
        endif
    endfor

    done:
    H5G_CLOSE, group_id
    RETURN, ret
END
; -----------------------------------------------------------------------------

PRO read_h5, data, attr, FILE=file, NAME=name, LIST=list, GROUP=group, ALL=all

    ON_ERROR, 1

    if not KEYWORD_SET(file) then begin		; Prompt user for file name
        file = DIALOG_PICKFILE(TITLE='Select h5 file', /READ, /FILE)
        if STRCMP(file,"") then return                
    endif

    if not H5F_IS_HDF5(file) then begin		; Check if this is an HDF5 file
        print, "Error: ", file, " is not a valid HDF5 file"
        goto, done
    endif

    file_id = H5F_OPEN(file)


    if KEYWORD_SET(list) then begin             ; List objects in the HDF file
        if KEYWORD_SET(all) then             $
            ret = list_objs(file_id)         $  ; Show all, or
        else if KEYWORD_SET(group) then      $
            ret = list_objs(file_id, /GROUP) $  ; Only show groups, or
        else                                 $
            ret = list_objs(file_id, /DATASET)	; Only show datasets
    
        H5F_CLOSE, file_id
        goto, done
    endif

    objpath = find_object(file_id, name)
    objname = objpath + "/" + name

    dataset_id = H5D_OPEN(file_id, objname)
    data = H5D_READ(dataset_id)
    
    n_attrs = H5A_GET_NUM_ATTRS(dataset_id)

    for i=0, n_attrs-1 do begin    
        attr_id = H5A_OPEN_IDX(dataset_id, i)
        attrname = H5A_GET_NAME(attr_id)
        value = H5A_READ(attr_id)
        if (SIZE(value,/N_DIMENSIONS) eq 1 and $
            SIZE(value,/N_ELEMENTS) eq 1) then value = value[0]
        
        attr = (i eq 0) $
                ? create_struct(attrname, value) $
                : create_struct(attr, attrname, value)
        
        H5A_CLOSE, attr_id
    endfor

  H5D_CLOSE, dataset_id
  H5F_CLOSE, file_id
  done:                                     ; End of program.

END
