;+
; :NAME:
;       pmulti
;
; :PURPOSE:
;       retrun positions[X0,Y0,X1,Y1] (in normalised coordinates) for
;       multi-panel plots. See examples.
;
; :SYNTAX:
;       Result = pmulti(ncol, nrow [,XMARGIN=value] [.YMARGIN=value]
;                       [,BORDER=array] [,/ARRAY])
;
; :PARAMS:
;    ncol (in:value) Number of columns (def: 1)
;    nrow (in:value) Number of rows (def: 1)
;
;
; :KEYWORDS:
;    XMARGIN (in:value) horizontal spacing between panels (def: 0.05)
;    YMARGIN (in:value) vertical spaces between panels (def: 0.05)
;    BORDER (in:array) x and y border outside the plot area (def: [0,0])
;    ARRAY Set this keyword to return result as array (def: structure)
;
; :REQUIRES:
;   is_defined.pro
;
; :EXAMPLES:
;   Create 3-columns x 4-rows panels
;   IDL> p = pmulti(3,4)
;   Note: the tags in the output structure (p) are named as p1, p2, p3,... for
;   the first, second, third... panel positions respectively. The 0th tag is
;   deliberately kept as a string so that nth position can be retrieved as
;   pos = p.(n)
;
;
;   Get positions of 4th panel (that corresponds to array index [0,1])
;   Option # 1
;   IDL> print, p.(4)
;   0.0500000     0.525000     0.316667     0.712500
;   Option # 2
;   IDL> print, p.p4
;   0.0500000     0.525000     0.316667     0.712500
;
;   Option # 3 (Note: the index numbering starts at 0 unlike in the previous
;   example without the array keyword)
;   IDL> p = pmulti(3,4,/array)
;   IDL> print, p[*,3]
;   0.0500000     0.525000     0.316667     0.712500
;
; :CATEGORIES:
;   Plotting
;
; :WARNING:
;   Be aware of the indexing inconsistency between structured and array outputs.
;
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  May 16, 2012 1:25:38 PM Created. Yaswant Pradhan.
;
;-

function pmulti, ncol, nrow,$
         XMARGIN=xmargin,   $
         YMARGIN=ymargin,   $
         BORDER=border,     $
         ARRAY=array

    ; Parse inputs and Set-up defaults:
    ncol    = ~N_ELEMENTS(ncol) ? 1 : ncol
    nrow    = ~N_ELEMENTS(nrow) ? 1 : nrow
    xmargin = is_defined(xmargin) ? xmargin : 0.05
    ymargin = is_defined(ymargin) ? ymargin : 0.05
    border  = is_defined(border) ? border : [0., 0.]
    if (N_ELEMENTS(border) ne 2) then border = REPLICATE(border[0],2)

    ; Calculate width and height of each panel:
    xs  = (1. - (border[0] + xmargin))/ncol
    ys  = (1. - (border[1] + ymargin))/nrow

    xm  = xmargin/2.
    ym  = ymargin/2.

    xw  = xs - xmargin
    yw  = ys - ymargin

    x1  = INDGEN(ncol)*xs+xmargin+(border[0]/2.)
    x2  = x1+xw
    y1  = INDGEN(nrow)*ys+ymargin+(border[1]/2.)
    y2  = y1+yw


    ; Fill out structure:
    out = CREATE_STRUCT('Name','Plot Positions in normalised coordinates')
    arr = FLTARR(4,ncol*nrow)
    cnt = 0L

    for j=nrow-1,0,-1 do for i=0,ncol-1 do begin
        arr[*,cnt]=[x1[i],y1[j],x2[i],y2[j]]
        tname = 'p'+STRTRIM(cnt+1,2)
        out = CREATE_STRUCT(out, tname,arr[*,cnt])
        cnt++
    endfor


    ; Return result:
    return, KEYWORD_SET(array) ? arr : out

end