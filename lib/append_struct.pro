;+
; :NAME:
;       append_struct
;
; :PURPOSE:
;
;
; :SYNTAX:
;
;
; :PARAMS:
;    tx (in: struct) Structure One
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
function append_struct, tx, ty

    tags = TAG_NAMES(tx)
    tmp = CREATE_STRUCT(tags[0],[tx.(0),ty.(0)])

    for i=1,N_ELEMENTS(tags)-1 do $
        tmp = CREATE_STRUCT(tmp, tags[i], [tx.(i),ty.(i)])

    return, tmp
end
