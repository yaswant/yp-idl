FUNCTION POWTICKS, axis, index, value
;+
; :NAME:
;    	POWTICKS
;
; :PURPOSE:
;     PowTicks callback function is used to display the tick values 
;     as a power of base 10 (esp. when plotting in log10 scale). 
;     Default behaviour of IDL /[xy]log is inconsistent, i.e.,
;     sometimes the values are displayed as 10^n, and other times
;     as decimal values. POWTICKS can be used to create consistent
;     tickvalues (to be called as [XY]TICKFORMAT='POWTICKS'). 
;    
;
; :SYNTAX:
;     [XYZ]TICKFORMAT='POWTICKS'
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
;     IDL> data = RANDOMU(SEED,2000) 
;     IDL> PLOT, data ,/YLOG ,YTICKFORMAT='POWTICKS'
;     IDL> PLOT, data,data ,/XLOG ,/YLOG ,YTICKFORMAT='POWTICKS'
;     IDL> PLOT, data,data ,/XLOG, XTICKFORMAT='POWTICKS' ,/YLOG ,YTICKFORMAT='POWTICKS'
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

  expon = strtrim(fix(alog10(value)),2)
  fmt   = '(A,"!u'+expon+'!d")'
  return, string(10, FORMAT=fmt)
  
END
