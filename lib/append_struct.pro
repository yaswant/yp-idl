function append_struct, tx, ty
;+
; :NAME:
;    	append_struct
;
; :PURPOSE:
;
;
; :SYNTAX:
;
;
; :PARAMS:
;    tx (in: struct) Stucture One 
;    ty (in: struct) Structure Two
;
;
; :REQUIRES:
;
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  03-Jun-2014 14:00:02 Created. Yaswant Pradhan.
;
;-
    tags = TAG_NAMES(tx)
    tmp = CREATE_STRUCT(tags[0],[tx.(0),ty.(0)])
    
    for i=1,N_ELEMENTS(tags)-1 do $
        tmp = CREATE_STRUCT(tmp, tags[i], [tx.(i),ty.(i)])
    
    return, tmp
end
