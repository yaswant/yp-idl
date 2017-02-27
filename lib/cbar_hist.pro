pro cbar_hist, DATA=data, RANGE=range, POSITION=position, PTITLE=ptitle, $
               BINSIZE=binsize, COLOR=color, HRANGE=hrange, THICK=thick, $
               YTFMT=ytfmt, YCHARSIZE=ycsz, HIST_XY=hist_xy, NOBAR=nobar, $
               CBHEIGHT=cbh, PLOT0LINE=plot0line, GET_HRANGE=get_hrange, $
               BOX_AXES=box_axes, ADD_GAUSSIAN=add_gaussian, $
               YTICKS=yticks, ADD_CUMULATIVE=add_cumulative, $
               FILL=fill, BRAND=brand, FCOLOR=fclr, LCOLOR=lclr, $
               RELATIVE=relative, XTITLE=xtit, YTITLE=ytit, $
               XTICKS=xticks, XTICKNAME=xtickname, _EXTRA=extra
;+
; NAME:       CBAR_HIST 
;
; PURPOSE:    Draw a stacked colourbar and simple histogram 
;
; ARGUMENTS:  None 
;
; KEYWORDS:   Data (IN:array) except string array; default is bytarr(256)
;             Range (IN:array)- MinMax range; default is [0,255]
;             Position (IN:array) - bottom left and top right potisions [x0,y0,x1,y1]
;                                   in normal coordinate
;             PTITLE (IN:String) - Plot title                      
;             Binsize (IN:array) - Bin size for histogram; default is 1
;             Color (IN:value) - annotaion colour
;             Hrange (IN:array) - MinMax range of histogram frequency
;             THICK (IN:Value) - Histogram line thickness
;             YTfmt (IN:string) - Ytick format; default is '(e7.0)'
;             YCHARSIZE (IN:Value) - CHARSIZE for Y label
;             HIST_XY (OUT:variable) - To store X and Y (frequency) of  the histogram
;             NOBAR - Exclude colour bar, plot histogram only.
;             CBHEIGHT (IN:Value) - Reduction factor of colorbar height
;             /PLOT0LINE - Add a vertical at xvlaue=0
;             GET_HRANGE (OUT:Variable) Store actual histogram min max frequency. 
;             /BOX_AXES - Use box style for axes
;             /ADD_GAUSSIAN - Adds normal distribution line acsled to histogram frequency 
;                             range using data stats (mean and sdev)
;             /ADD_CUMUL - Adds a cumulative frequency line to plot.
;             /FILL - Fill histogram bars
;             FCOLOR (IN:Value) Color Index for Filled polygons
;             LCOLOR (IN:Value) Color Index for polygon outline
;             /RELATIVE - Display relative units for frequency
;             _Extra - Inherits plot and colorbar proerties
;
; SYNTAX:     cbar_hist [,Data=Array] [,Range=[Min,Max]] [,Position=[X0,Y0, X1,Y1]]
;                       [,Binsize=Value] [,Color=Value] [,Hrange=[Min,Max]] 
;			[,YFMT=String] [,HIST_XY=Variable] [,/NOBAR]
;
; DEPENDECY:  colorbar.pro from Coyote's library
;
; EXAMPLE:  h |     __          
;           i |  __|  |_        
;           s |_|       |__     
;           t |____________|__ 
;             |_______________|  
;               color bar      
;
; $Id: CBAR_HIST.pro,v 1.0 24/02/2009 12:30:03 yaswant Exp $
; CBAR_HIST.pro Yaswant Pradhan
; Last modification: 
; 21.09.2010  : Add keyword YCHARSIZE (YP)
;             : Add keyword CBHEIGHT (YP)
; 28.10.2010  : Add keyword BOX_AXES (YP)
; 03.11.2010  : Add keyword PTITLE (YP)
; 10.11.2010  : Add keyword ADD_GAUSSIAN (YP)   
; 23.11.2010  : Add keyword ADD_CUMULATIVE (YP)
;             : Add keyword RELATIVE (YP)         
;-
; #######################################################################################
 

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Parse inputs 
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  data      = keyword_set(data) ? data : bindgen(256)
  range     = keyword_set(range) ? range : [min(data),max(data)]    
  position  = keyword_set(position)? position : [.2, .04, .8, .2]
  binsize   = keyword_set(binsize) ? binsize : 1.
  cbh       = is_defined(cbh) ? cbh : 1
  ycsz      = is_defined(ycsz) ? ycsz : 1
  width     = position[3]-position[1]
  cbtop     = position[1]+width/4.
  cbpos     = [position[0:2],cbtop]
  cbheight  = cbpos[3]-cbpos[1]
  cbpos[1]  = cbtop-cbheight/cbh
  hgpos     = [position[0],cbtop,position[2:3]]
  nob       = keyword_set(nobar)
  box       = keyword_set(box_axes)
  ptit      = keyword_set(ptitle) ? ptitle : ' '
  cumul     = keyword_set(add_cumulative)
  thick     = is_defined(thick) ? thick : 1
  yt        = KEYWORD_SET(yticks) ? yticks : 3
  xt        = KEYWORD_SET(xticks) ? xticks : 0
  xtn       = is_defined(xtickname) ? xtickname : ' '
  tvlct,    r,g,b,/GET ; preloaded RGB table
  
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
; Compute histogram 
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  h = histogram(data, BINSIZE=binsize, MIN=range[0], MAX=range[1], LOCATIONS=x)    
  uni = ( min(h) eq max(h) ) ? 1b : 0b ; Check if distribution is uniform 
  
; Convert frequency to relative units [%] and get Cumulative frequency 
  rh  = h / total(h,/NaN)
  ch  = TOTAL(rh, /CUMULATIVE)
  h   = keyword_set(relative) ? rh * 100. : h
  

; Add histogram plot and get tick intervals for colorbar  
  hrange  = keyword_set(hrange) ? hrange : [min(h),max(h)]+[0,1]    
  ytfmt   = keyword_set(ytfmt) ? ytfmt : $
            keyword_set(relative) ? '(i0)' : '(e7.0)'
  get_hrange = [min(h),max(h)]+[0,1]
  
  
  if KEYWORD_SET(fill) then begin
    nx  = N_ELEMENTS(x)
    gap = 30. ; gap between bars as percent of binsize (-ve to overlap)
    dx  = binsize - gap*binsize/100
    
    blx = x - dx/2.         ; Bottom-Left X    
    bly = replicate(0, nx)  ; Bottom-Left Y
    
    poly = { X:FLTARR(5,nx), Y:FLTARR(5,nx) }  
    for i=0L,nx-1 do begin
      poly.X[*,i] = [ blx[i], blx[i]+dx, blx[i]+dx, blx[i], blx[i] ]
      poly.Y[*,i] = [ bly[i], bly[i], bly[i]+h[i], bly[i]+h[i], bly[i] ]
    endfor  
  endif

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Plot histogram
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  if (N_ELEMENTS(extra) gt 0) then begin
      xst = STREGEX(STRJOIN(TAG_NAMES(extra)),'XST',/BOOL,/FOLD_CASE) $
            ? extra.xstyle $
            : (nob ? (box ? 1 : 9) : (box ? 1 : 5))
              
      yst = STREGEX(STRJOIN(TAG_NAMES(extra)),'YST',/BOOL,/FOLD_CASE) $
            ? extra.ystyle $
            : (box ? (cumul ? 9 : 1) : 9)        
  endif
  
  
  if KEYWORD_SET(fill) then begin    
    
    plot, x, h, POSITION=hgpos,/NODATA, $
        XTICK_GET=xt, XSTYLE=xst, $;XSTYLE=(nob ? (box ? 1 : 9) : (box ? 1 : 5) ), $
        XRANGE=range, YRANGE=hrange, YSTYLE=yst, $ ;YSTYLE=(box ? (cumul ? 9 : 1) : 9), $
        /NOERASE, PSYM=10, /NORMAL, XTICKS=(nob ? xt : (box ? 1 : 0)), $
        XTICKNAME=(nob ? xtn : (box ? [' ',' '] : 0)), $
        YTICKLEN=.01, YMINOR=1, COLOR=color, YTICKS=(uni ? 0 : yt), $
        YTICKFORMAT=ytfmt, CHARSIZE=ycsz, THICK=thick, $
        XTITLE=(nob ? xtit : ''), YTITLE=ytit, TITLE=ptit
        
    if KEYWORD_SET(brand) then loadmyct, 66, /SILENT
    if ~is_defined(fclr) then fclr=250
    if ~is_defined(lclr) then lclr=253
    
    !P.NOCLIP=0
    polyfill, poly.X, poly.Y, COLOR=fclr, NOCLIP=0
    oplot,    poly.X, poly.Y, COLOR=lclr     
    tvlct,    r,g,b    
  endif else begin
   
    plot, x, h, POSITION=hgpos, $
        XTICK_GET=xt, XSTYLE=xst, $;XSTYLE=(nob ? (box ? 1 : 9) : (box ? 1 : 5) ), $
        XRANGE=range, YRANGE=hrange, YSTYLE=yst, $;YSTYLE=(box ? (cumul ? 9 : 1) : 9), $
        /NOERASE, PSYM=10, /NORMAL, XTICKS=(nob ? 0 : (box ? 1 : 0)), $
        XTICKNAME=(nob ? ' ' : (box ? [' ',' '] : 0)),$
        YTICKLEN=.01, YMINOR=1, COLOR=color, YTICKS=(uni ? 0 : yt), $
        YTICKFORMAT=ytfmt, CHARSIZE=ycsz, THICK=thick, $
        XTITLE=(nob ? xtit : ''), YTITLE=ytit, TITLE=ptit
  endelse
  
  
  if KEYWORD_SET(plot0line) then $
     oplot,    [0.,0.],[0.,hrange[1]], COLOR=color
  
  divs    = n_elements(xt)-1  
  hist_xy = [[x],[h]]
  
  if KEYWORD_SET(add_gaussian) then begin
    st  = MOMENT(data, SDEV=sd, /NAN)
    phi = (1./sqrt(2*!pi*sd*sd)) * exp(-((x-st[0])^2)/(2.*sd*sd))
    f   = fltscl( phi, HIGH=max(h,/NaN), LOW=min(h,/NaN) )
    oplot, x, f, COLOR=color, THICK=2      
  endif

; Add Cumulative frequency curve
  if cumul then begin
    AXIS, YAXIS=1, YRANGE=[min(ch),max(ch)]*100, YSTYLE=1, YTITLE='cumul. freq. [%]', $
          CHARSIZE=ycsz, YTICKLEN=.01, YMINOR=1, /SAVE
          
    oplot, x,ch*100
    p = value_locate(x,[0,0.5,0.75])  
    print, ch[p]*100
;    oplot, [0,x[n_elements(x)-1]],replicate(ch[p[0]]*100, 2),LINESTYLE=1
    xyouts, x[p[0]+1], ch[p[0]]*100+5, 'cf: '+string(ch[p[0]]*100,format='(i0)')+'%',CHARSIZE=1  
  endif
  
  
; Add a colorbar 
  if ~nob then begin
    colorbar, POSITION=cbpos, RANGE=range, DIVISIONS=divs, COLOR=color, _EXTRA=extra
    XYOUTS, mean([cbpos[0],cbpos[2]]), (cbpos[1]+cbpos[3])/2.01,(keyword_set(xtit) ? xtit : ''), $
            ALIGN=0.5,/NORMAL,CHARSIZE=0.8
  endif  
  
  
end
