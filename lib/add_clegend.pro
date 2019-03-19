PRO add_clegend, Name, Colour,  $
    POSITION=position,          $
    LSIZE=lsize,                $
    BUFFER=buffer,              $
    CHARSIZE=charsize,          $
    TEXTCOLOR=textcolor,        $
    HSPACE=hspace,              $    
    BGCOLOR=bgcolor,            $
    BGWIDTH=bgwidth,            $
    BGBCOLOR=bgbcolor,          $
    BGBTHICK=bgbthick,          $
    _EXTRA=_extra
;+
; :NAME:
;    	add_clegend
;
; :PURPOSE:
;       Add a colour-legend (filled squares) on an existing plot. 
;       Note: all values in normalised units. 
;
; :SYNTAX:
;       add_clegend, Name, Colour [,POSITION=[TopLeft_X,TopLeftY]] 
;                   [,LSIZE=value] [,BUFFER=value] [,CHARSIZE=value] 
;                   [,TEXTCOLOR=value] [,HSPACE=value]
;
; :PARAMS:
;    Name (in:strarr) text array of legends  
;    Colour (in:array) colour indiced for legends
;
;
; :KEYWORDS:
;    POSITION (in:array) Top left corner (def: [!x.window[0],!y.window[1]]
;    LSIZE (in:value) Legend size in normal units (def: 0.03)
;    BUFFER (in:value) Buffer space around legend (def:0.01)
;    CHARSIZE (in:value) Legend text size (def: 1)
;    TEXTCOLOR (in:value) Legened text colour
;    HSPACE (in:value) Horizontal space between legends, when adding a 
;               horizontal legend. Adding this keyword itself modifies the
;               default nature of add_clegend (vertical). 
;    BGCOLOR(in:value) Supply colour index to fill legend background with colour
;    BGWIDTH (in:value) Background width in normal coordinate
;    BGBCOLOR (in:value) Background border colour of legend  
;    BGBTHICK (in:value) Background border thickness
;
; :REQUIRES:
;   ll_vec2poly.pro
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
;  Aug 10, 2012 5:25:36 PM Created. Yaswant Pradhan.
;  Mar 20, 2013 Added Fill Background functions. YP 
;
;-

    if (N_PARAMS() lt 2) then begin
        MESSAGE,'add_legend, X0, Y0, Name, Color',/CONTINUE
        RETURN
    endif
    
    nn = N_ELEMENTS(Name)
    nc = N_ELEMENTS(Colour)
    if (nn ne nc) then begin
        MESSAGE,'Length of Name and Colour must be of equal',/CONTINUE
        RETURN
    endif
    
    X0      = (N_ELEMENTS(position) eq 2) ? position[0] : !x.window[0]+0.01
    Y0      = (N_ELEMENTS(position) eq 2) ? position[1] : !y.window[1]-0.01
    lsize   = KEYWORD_SET(lsize) ? lsize : 0.03
    Charsize= KEYWORD_SET(charsize) ? charsize : 1
    Buffer  = KEYWORD_SET(buffer) ? buffer<lsize : 0.01
    hz      = KEYWORD_SET(hspace)
    
    case hz of
        1 : begin
            xpos = X0 + FINDGEN(nn)*(lsize+hspace) 
            ypos = REPLICATE(Y0,nn)-lsize
        end
        0 : begin
            xpos = REPLICATE(X0,nn)
            ypos = Y0 - (FINDGEN(nn)+1)*lsize
        end
    endcase
    
    yaspect = FLOAT(!d.X_SIZE)/!d.Y_SIZE
    
    ll_vec2poly, xpos, ypos, xyp, /RELAX, $
        DX=lsize-Buffer, DY=(lsize-Buffer)*yaspect
 
 ; Get legend background polygon:  
    xv = [xyp.Lon[0,0], xyp.Lon[0,0]+(is_defined(bgwidth) ? bgwidth : 0.1)]
    yv = [xyp.Lat[0,nn-1], xyp.Lat[2,0]]
 
 
 ; Fill background:
    if is_defined(bgcolor) then $          
        POLYFILL, xv[[0,1,1,0,0]], yv[[0,0,1,1,0]], COLOR=bgcolor,/NORMAL
    


; Draw background border color:
    if is_defined(bgbcolor) then $          
        overlay_box, POSITION=[xv[0], yv[0], xv[1],yv[1]], COLOR=bgbcolor, $
            THICK=bgbthick
    

; Fill legend:    
    for i=0,nn-1 do begin    
        POLYFILL, xyp.Lon[*,i], xyp.Lat[*,i], COLOR=Colour[i], /NORMAL
            
        XYOUTS, xyp.Lon[1,i]+Buffer/2, xyp.Lat[1,i]+Buffer/2, Name[i], $
            COLOR=textcolor, CHARSIZE=Charsize, /NORMAL,_EXTRA=_extra
    endfor

END
