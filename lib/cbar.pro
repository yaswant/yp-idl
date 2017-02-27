pro cbar,                       $
    BOTTOM=bottom,              $
    CHARSIZE=charsize,          $
    COLOR=color,                $
    DIVISIONS=divisions,        $
    FORMAT=format,              $
    MAXRANGE=maxrange,          $
    MINRANGE=minrange,          $
    NCOLORS=ncolors,            $
    TITLE=title,                $
    VERTICAL=vertical,          $
    TOP=top,                    $
    RIGHT=right,                $
    MINOR=minor,                $
    RANGE=range,                $
    FONT=font,                  $
    TICKLEN=ticklen,            $
    INVERTCOLORS=invertcolors,  $
    TICKNAMES=ticknames,        $
    REVERSE=reverse,            $
    ANNOTATECOLOR=annotatecolor,$
    XLOG=xlog,                  $
    YLOG=ylog,                  $
    WIDTH=width,                $
    XOFFSET=xoff,               $
    YOFFSET=yoff,               $
    XMARGIN=xmar,               $
    YMARGIN=ymar,               $
    TAPERED=tapered,            $
    _EXTRA=extra

;+
; :NAME:
;     cbar
;
; :PURPOSE:
;     The purpose of this routine is to add a colourbar to the current graphics
;     window at a suitable position (configurable) adjacent to the plot area.
;     
;
; :SYNTAX:
;     cbar [,BOTTOM=Value] [,CHARSIZE=Value] [,COLOR=Value] [,DIVISIONS=Value] 
;          [,FORMAT=String] [,MAXRANGE=Value] [,MINRANGE=Value] [,NCOLORS=Value]
;          [,TITLE=String] [,/VERTICAL] [,/TOP] [,/RIGHT] [,MINOR=Value]
;          [,RANGE=Array] [,FONT=Value] [,TICKLEN=Value] [,_EXTRA=extra]
;          [,/INVERTCOLORS] [,TICKNAMES=StringArray] [,/REVERSE]
;          [,ANNOTATECOLOR=string] [,/XLOG] [,/YLOG]
;          [,WIDTH=Value] [,XOFFSET=Value] [,YOFFSET=Value]
;          [,XMARGIN=Value] [,YMARGIN=Value] [,TAPERED=Value] 
;
;  :KEYWORDS:
;    BOTTOM   (IN:Value) The lowest color index of the colors to be loaded 
;                 in the bar.
;    CHARSIZE (IN:VALUE) The character size of the color bar annotations. 
;                 Default is 1.0.
;    COLOR    (IN:VALUE) The color index of the bar outline and characters. 
;                 Default is !P.Color.
;    DIVISIONS(IN:VALUE) The number of divisions to divide the bar into. 
;                 There will be (divisions + 1) annotations. 
;                 The default is 6.
;    FONT     (IN:VALUE) Sets the font of the annotation. Hershey: -1,
;                 Hardware:0, True-Type: 1.
;    FORMAT  (IN:STRING) The format of the bar annotations. Default is '(I0)'.
;    MAXRANGE (IN:VALUE) The maximum data value for the bar annotation. 
;                 Default is NCOLORS.
;    MINRANGE (IN:VALUE) The minimum data value for the bar annotation. 
;                 Default is 0.
;    MINOR    (IN:VALUE) The number of minor tick divisions. Default is 2.
;    NCOLORS  (IN:VALUE) This is the number of colors in the color bar.
;    TITLE   (IN:STRING) This is title for the color bar. The default is 
;                 to have no title.
;    VERTICAL:  Setting this keyword give a vertical color bar. The default 
;                 is a horizontal color bar.
;    TOP:       This puts the labels on top of the bar rather than under it.
;                 The keyword only applies if a horizontal color bar 
;                 is rendered.
;    RIGHT:     This puts the labels on the right-hand side of a vertical 
;                 color bar. It applies only to vertical color bars. 
;    RANGE    (IN:ARRAY) A two-element vector of the form [min, max]. 
;                 Provides an alternative way of setting the MINRANGE 
;                 and MAXRANGE keywords. If a data array is provided, the 
;                 MIN and MAX of the data array are set as range.
;    TICKLEN  (IN:VALUE) Colorbar Ticklength 
;    _EXTRA   (See colorbar.pro)
;    INVERTCOLORS: Setting this keyword inverts the colors in the color bar. 
;    TICKNAMES (IN:STRARR) A string array of names or values for the tick marks.
;    REVERSE:   Setting this keyword reverses the colors in the colorbar.
;    ANNOTATECOLOR (IN:STRING) see colorbar.pro
;    XLOG:    Show log transformed values of colorbar x-axis.
;    YLOG:    Show log transformed values of colorbar y-axis.
;    WIDTH    (IN:VALUE) Width of the colourbar in normalised coordinate    
;    XOFFSET  (IN:VALUE) Horizontal offset from the current plot in normalised
;                 coordinate. Applicable for vertical colorbar.
;    YOFFSET  (IN:VALUE) Vertical offset from the current plot in normalised 
;                 coordinate.
;                 Applicable for horizontal colorbar.
;    XMARGIN  (IN:Value) Margin offset from left and right (def: [0,0].
;                 This is use ful to shrink the horizontal colorbar length
;    YMARGIN  (IN:Value) Margin offset from bottom and top (def: [0,0].
;                 This is use ful to shrink the vertical colorbar length
;    TAPERED (IN:Value) make the bar pointed
;    
; :REQUIRES:
;     colorbar.pro from Coyote library has been embedded to this code.
;
; :EXAMPLES: See how cbar keywords can be used to manipulate the bar position
;   IDL> !p.multi = [0,2,2]
;   IDL> !x.margin=[6,8] 
;   IDL> !y.margin=[8,4]
;   IDL> x = dist(400,400)
;   IDL> device,decomposed=0
;   IDL> loadct, 39
;   IDL> contour,x,/fill,nlev=60
;   IDL> cbar,range=[min(x),max(x)],/vertical,/right
;   IDL> contour,x,/fill,nlev=60
;   IDL> cbar,range=[min(x),max(x)]
;   IDL> contour,x,/fill,nlev=60
;   IDL> cbar,range=[min(x),max(x)],yoff=-0.3,/top
;   IDL> contour,x,/fill,nlev=60
;   IDL> cbar,range=[min(x),max(x)],/vertical,xoff=-0.45
;
; :CATEGORIES:
;     plotting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  20-Jul-2010 12:11:24 Created. Yaswant Pradhan.
;  17-Feb-2012 Add XMargin, Y Margin keywords. YP. 
;-

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Set input parametrs for colorbar position  
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if TOTAL(!x.window) eq 0 then !x.window=[0.1,0.9]
  if TOTAL(!y.window) eq 0 then !y.window=[0.2,0.9]
  
  xoff  = KEYWORD_SET(xoff) ? xoff : 0.01
  yoff  = KEYWORD_SET(yoff) ? yoff : 0.06
  xmar  = is_defined(xmar) ? xmar : [0,0]
  ymar  = is_defined(ymar) ? ymar : [0,0]
  width = KEYWORD_SET(width) ? width : 0.03
  
  ppos  = [!x.window+(xmar*[1,-1]), !y.window+(ymar*[1,-1])]
  
  if KEYWORD_SET(range) then begin
    prange = N_ELEMENTS(range) gt 2 $
              ? [min(range,/NaN),max(range,/NaN)] $
              : range
  endif
  vert  = KEYWORD_SET(vertical)

  if KEYWORD_SET(tapered) then begin
    
    tw = 4./100
    case tapered of
      
      1:  begin
            npos = ppos + (vert ? [0,0,tw,0] : [tw,0,0,0])
            
            x1  = vert $
                  ? [xoff+width/2.,xoff+width,xoff,xoff+width/2]+ppos[1] $
                  : [ppos[0],npos[0],npos[0],ppos[0]]
            
            y1  = vert $
                  ? [ppos[2],npos[2],npos[2],ppos[2]] $ 
                  : [-(yoff+width/2.),-(yoff+width),-yoff,-(yoff+width/2.)]+$
                    ppos[2]
          end
      2:  begin
            npos = ppos + (vert ? [0,0,0,-tw] : [0,-tw,0,0])
            
            x2  = vert $
                  ? [xoff+width/2.,xoff+width,xoff,xoff+width/2]+ppos[1] $
                  : [ppos[1],npos[1],npos[1],ppos[1]]
            
            y2  = vert $
                  ? [ppos[3],npos[3],npos[3],ppos[3]] $
                  : [-(yoff+width/2.),-(yoff+width),-yoff,-(yoff+width/2.)]+$
                    ppos[2]
          end
      3:  begin
            npos = ppos + (vert ? [0,0,tw,-tw] : [tw,-tw,0,0])
            
            x1  = vert $
                  ? [xoff+width/2.,xoff+width,xoff,xoff+width/2]+ppos[1] $
                  : [ppos[0],npos[0],npos[0],ppos[0]]
            
            y1  = vert $
                  ? [ppos[2],npos[2],npos[2],ppos[2]] $
                  : [-(yoff+width/2.),-(yoff+width),-yoff,-(yoff+width/2.)]+$
                    ppos[2]
                   
            x2  = vert $
                  ? [xoff+width/2.,xoff+width,xoff,xoff+width/2]+ppos[1] $
                  : [ppos[1],npos[1],npos[1],ppos[1]]
            
            y2  = vert $
                  ? [ppos[3],npos[3],npos[3],ppos[3]] $
                  : [-(yoff+width/2.),-(yoff+width),-yoff,-(yoff+width/2.)]+$
                    ppos[2]
          end
          
    endcase
    
  endif else npos=ppos
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Estimate Colourbar position in the Plot window
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  cbpos = vert  $
          ? [npos[1]+xoff, npos[2], npos[1]+(xoff+width), npos[3]] $
          : [npos[0], npos[2]-(yoff+width), npos[1], npos[2]-yoff]

  
  
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Sanity check for colourbar position
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if total(cbpos gt 1) or total(cbpos lt 0) then begin
    print,'[cbar]: Colorbar position can not be reconciled.'+$
          ' Check Colorbar WIDTH and OFFSET parameters or'+$
          ' increase the plot margin.'
    print,'[cbar]:',cbpos
    goto, FINISH
  endif


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Call colorbar procedure    
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  colorbar, POSITION=cbpos, BOTTOM=bottom, CHARSIZE=charsize, COLOR=color,  $
            DIVISIONS=divisions, FORMAT=format, MAXRANGE=maxrange,          $
            MINRANGE=minrange, NCOLORS=ncolors, TITLE=title,                $
            VERTICAL=vertical, TOP=top, RIGHT=right, MINOR=minor,           $
            RANGE=prange, FONT=font, TICKLEN=ticklen, _EXTRA=extra,         $
            INVERTCOLORS=invertcolors, TICKNAMES=ticknames, REVERSE=reverse,$
            ANNOTATECOLOR=annotatecolor, XLOG=xlog, YLOG=ylog


  if KEYWORD_SET(tapered) then begin
    case tapered of
      1: begin
          POLYFILL,x1,y1,COLOR=bottom,/NORMAL
          PLOTS, SHIFT(x1,2),SHIFT(y1,2),COLOR=color,/NORMAL,_EXTRA=extra
         end
      2: begin
          POLYFILL,x2,y2,COLOR=bottom+ncolors-1,/NORMAL
          PLOTS, SHIFT(x2,2),SHIFT(y2,2),COLOR=color,/NORMAL,_EXTRA=extra
         end
      3:  begin
            POLYFILL,x1,y1,COLOR=bottom,/NORMAL
            POLYFILL,x2,y2,COLOR=bottom+ncolors-1,/NORMAL
            PLOTS, SHIFT(x1,2),SHIFT(y1,2),COLOR=color,/NORMAL,_EXTRA=extra
            PLOTS, SHIFT(x2,2),SHIFT(y2,2),COLOR=color,/NORMAL,_EXTRA=extra
          end
    endcase
  endif
  
  
FINISH:
end
