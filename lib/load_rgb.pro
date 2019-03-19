;+
; :NAME:
;       load_rgb
;
; :PURPOSE:
;       Load a new colour table with given R,G,B palette
;
; :SYNTAX:
;       load_rgb, R, G, B
;
; :PARAMS:
;    r (in:array) Array of Red palette
;    g (in:array) array of Green palette
;    b (in:array) Aeeay of Blue palette
;
;
; :REQUIRES:
;    None,.
;
; :EXAMPLES:
;   The following is synonymous to loadct, 0 (i.e., B-W Linear)
;    load_rgb, indgen(256), indegn(256),indgen(256)
;
; :CATEGORIES:
;   Plotting, colour management
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  12-Oct-2011 09:58:34 Created. Yaswant Pradhan.
;
;-

pro load_rgb, r,g,b

    if (N_PARAMS() lt 3) then message,"Syntax: load_rgb, R, G, B"
    nlr = N_ELEMENTS(r)
    nlg = N_ELEMENTS(g)
    nlb = N_ELEMENTS(b)

    rr = (nlr lt 256) ? [r, BYTSCL(INDGEN(256-nlr))] : r
    gg = (nlg lt 256) ? [g, BYTSCL(INDGEN(256-nlg))] : g
    bb = (nlb lt 256) ? [b, BYTSCL(INDGEN(256-nlb))] : b
    tvlct, rr,gg,bb

end
