;+
; :NAME:
;       vector_legend
;
; :PURPOSE:
;
;
; :SYNTAX:
;
;
; :PARAMS:
;    data_range
;
;
; :KEYWORDS:
;    POSITION
;    TITLE
;    GS
;    COLOR
;    FORMAT
;    _EXTRA
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
;  29-Apr-2013 13:57:40 Created. Yaswant Pradhan.
;
;-

pro vector_legend, $
    data_range, $
    POSITION=pos, $
    TITLE=title, $
    GS=grid_spacing, $
    COLOR=color, $
    FORMAT=form, $
    _EXTRA=_extra

    grid_spacing = is_defined(grid_spacing) ? grid_spacing : [1.,1.]
    title = KEYWORD_SET(title) ? STRTRIM(title,2) : ' '
    form = KEYWORD_SET(form) ? form : '(f0.2)'

    u =(v = MAKE_ARRAY(4,2, VALUE=!VALUES.F_NAN))
    u[0,0] = MAX(data_range)
    u[2,0] = MIN(data_range)
    v[0,0] =(v[2,0] = 0 )

    x = FINDGEN(4)*grid_spacing[0] + pos[0]
    y = FINDGEN(2)*grid_spacing[1] + pos[1]

    VELOVECT,u[0:2,*],v[0:2,*], x[0:2],y,/OVERPLOT,COLOR=color,_EXTRA=_extra
    XYOUTS, x[0],y[0],'!C!C'+STRING(u[0,0],FORM=form)+' '+title,COLOR=color,$
        _EXTRA=_extra
end