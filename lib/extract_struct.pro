;+
; :NAME:
;       extract_struct
;
; :PURPOSE:
;       Extract the subarrays of the members in a structure. It is assumed that
;       all members have equal number of elements.
;
; :SYNTAX:
;       Result = extract_struct(Struct, Indices [,/PURGE])
;
; :PARAMS:
;    Struct (in:struct) Input structure
;    Indices (in:array) Subarray positions in Structure to be extracted
;
;
; :KEYWORDS:
;    /PURGE - Set this keyword to clear the original structue from memory.
;               Note this is done by simply assigning Struct=0b. So be careful
;               when using this keyword.
;
; :REQUIRES:
;     None
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;       Data manipulation
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Feb 10, 2010 13:36 Created. Yaswant Pradhan.
;
;-

FUNCTION extract_struct, Struct, Indices, PURGE=purge

syntax ='Result = extract_struct(Structure, Indices)'
if (N_PARAMS() lt 2) then message, syntax
if (SIZE(Struct,/TYPE) ne 8) then message,'Arg1 shoould be a STRUCTURE'

Fields  = TAG_NAMES(Struct)
nElems  = N_ELEMENTS(Indices)
oStruct = CREATE_STRUCT(Fields[0], (Struct.(0))[indices])

for i=1,N_TAGS(Struct)-1 do begin
    oStruct = CREATE_STRUCT(oStruct,Fields[i],(Struct.(i))[indices])

    if (N_ELEMENTS(Struct.(i)) lt nElems) then $
        message,'Warning! Structure variable '+Fields[i]+$
                ' has fewer elements than Indices.'+$
                ' The array may contain clipped data.',/CONTINUE,/NOPREFIX
endfor


; Purge (to release memory) original structure if required:
if KEYWORD_SET(purge) then begin
    message,'INFO: Purging original structure.',/CONTI,/NOPREF
    Struct = 0b
endif

return, oStruct
END
