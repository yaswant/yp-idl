pro load_complement, r,g,b
;+
; :NAME:
;    	load_complement
;
; :PURPOSE:
;     The LOAD_COMPLEMET procedure loads the complement color translation 
;     tables from existing RGB color system.
;     
; :SYNTAX:
;   load_complement [r, g, b]
;
;	 :PARAMS:
;    r  (IN:Optional:Value) Original Red value
;    g  (IN:Optional:Value) Original Green value
;    b  (IN:Optional:Value) Original Blue value
;
;
; :REQUIRES:
;
;
; :EXAMPLES:
;   load_complemet
;   
; 
; :CATEGORIES:
;   plotting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Feb 16, 2012 3:36:03 PM Created. Yaswant Pradhan.
;
;-

  if N_PARAMS() lt 3 then tvlct, r,g,b,/GET  
  max = !d.TABLE_SIZE-1 
  TVLCT, max-r, max-g, max-b
  
end