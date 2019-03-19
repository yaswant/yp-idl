FUNCTION LATTS, axis, index, value
;+
; :NAME:
;    	LATTS (or Latitude Ticks)
;
; :PURPOSE:
;     LATTS callback function is used to display the tick values 
;     with an additional 'N','S' or 'EQ' for North, South or Equator 
;     representation of Latitude values.
;    
;
; :SYNTAX:
;     [XYZ]TICKFORMAT='LATTS'
;
;	 :PARAMS:
;    axis   :is the axis number: 0 for X axis, 1 for Y axis, 2 for Z axis.
;    index  :is the tick mark index (indices start at 0).
;    value  :is the data value at the tick mark 
;            (a double-precision floating point value).
;
;
; :REQUIRES:
;     None
;
; :EXAMPLES:
;     
;
; :CATEGORIES:
;     Plotting, TickValue Formatting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  05-Jul-2010 11:29:11 Created. Yaswant Pradhan.
;
;-
  
  null = ''  
  form = (abs(value mod 1) eq 0) ? '(I0)' : '(F5.1)'
  
  if (value gt 0.) then ind=string(value,FORMAT=form)+string(176b)+'N'
  if (value lt 0.) then ind=string(abs(value),FORMAT=form)+string(176b)+'S'
  if (value eq 0.) then ind=null+'EQ'
  fmt = '(A,"'+ind+'")'
  
  return, string(null, FORMAT=fmt)
  
END
