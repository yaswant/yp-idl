;+
; :NAME:
;       append_hem
;
; :PURPOSE:
;     Append_hem function adds degree E, W, N, S (and EQ) characters to the
;     input value|array. Useful for plotting nice map grids (using lons/lats and
;     lonnames/latnames).
;
; :SYNTAX:
;     Result = append_hem(array [,/LATITUDE] [,/LONGITUDE] [,DP=Value]
;
;    :PARAMS:
;    array (IN:Array) Input array to add hemisphere tags.
;
;
;  :KEYWORDS:
;    /LATITUDE - Interpret input values as latitudes.
;    /LONGITUDE - Interpret input values as longitudes.
;    DP (IN:Value) Keep values upto dp decimal places in formatting.
;
; :REQUIRES:
;   is_defined.pro
;   format_values.pro
;
; :EXAMPLES:
; IDL> print,append_hem(indgen(11)*10-50, /LATITUDE)
; 50°S 40°S 30°S 20°S 10°S EQ 10°N 20°N 30°N 40°N 50°N
;
; IDL> print,append_hem(indgen(11)*10-50, /LONGITUDE)
; 50°W 40°W 30°W 20°W 10°W 0 10°E 20°E 30°E 40°E 50°E
;
; :CATEGORIES:
;   String manipulation, Plotting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  12-Jul-2010 14:40:56 Created. Yaswant Pradhan.
;
;-

function append_hem, array, LATITUDE=latitude, LONGITUDE=longitude, $
                     DP=dp, NODEG=nodeg

    dp  = is_defined(dp) ? (dp eq 0) ? -1:dp : 1
    deg = KEYWORD_SET(nodeg) ? '' : char('deg')
    out = strarr( n_elements(array) )

    if (keyword_set(longitude)) then begin
        ; Longitudes:
        east  = where(array gt 0, n_east, COMPLEMENT=west, NCOMPLEMENT=n_west)
        merid = where(array eq 0, n_merid)

        if (n_east gt 0) then out[east] = format_values(array[east], dp)+deg+'E'
        if (n_west gt 0) then out[west] = format_values(abs(array[west]), dp)+deg+'W'
        if (n_merid gt 0) then out[merid] = '0'

    endif else if (keyword_set(latitude)) then begin
        ; Latitudes:
        north = where(array gt 0 and array lt 90,n_north, $
                      COMPLEMENT=south, NCOMPLEMENT=n_south)
        equat = where(array eq 0,n_equat)
        inval = where(array lt (-90) or array gt 90, n_inval)

        if (n_north gt 0) then out[north] = format_values(array[north], dp)+deg+'N'
        if (n_south gt 0) then out[south] = format_values(abs(array[south]), dp)+deg+'S'
        if (n_equat gt 0) then out[equat] = 'EQ'
        if (n_inval gt 0) then out[inval] = ''
    endif else out = strtrim(string(array),2)

    return, out

end
