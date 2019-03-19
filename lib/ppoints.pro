FUNCTION PPOINTS, N, LOW=lo, HIGH=hi, FIXED_BOUNDS=fixed_bounds

;+
;NAME:
; PPOINTS

;PURPOSE:
; Returns an array of N probability points between 0 and 1 
;       or to any given bounds (exclusive or inclusive).


;SYNTAX:
; result = PPOINTS ( N [,LOW=value] [,HIGH=value] [,/FIX_BOUNDS])

;INPUTS:
; N: number of desired points, must be > 1
; LOW: Lower limit of the array
; HIGH: Upper limit of the array

;KEYWORDS:
; /FIXED_BOUNDS: to include the low and high values in the output.

;OUTPUTS:
; An array of N probability points

;KEYWORDS:
; None

;EXAMPLE: (results on a 32bit linux operating system)
;IDL> print, ppoints(5)
;           0.10000000      0.30000000      0.50000000      0.70000000      0.90000000
 
;IDL> print, ppoints(5, /FIX)
;           0.0000000      0.25000000      0.50000000      0.75000000       1.0000000

;IDL> print, ppoints(5, LOW=10., HIGH=11.3)
;           10.100000       10.375000       10.650000       10.925000       11.200000


;CATEGORY:
;   Statistics & Probability

;   $Id: PPOINTS.pro,v 1.0 29/05/2007 19:25:13 yaswant Exp $
; PPOINTS.pro	Yaswant Pradhan	University of Plymouth
;   Last modification:
;   Apr 2008 - added HIGH, LOW, FIXED_BOUND keywords
;-

;parse error
	if (n_params() ne 1) then begin
		print,'Syntax: result = ppoints(N)'
		retall
	endif
	if (N lt 2) then begin
		print,'Error! N must be greater than 1'
		retall
	endif    
    
    if not keyword_set(lo) then lo=0.0D
    if not keyword_set(hi) then hi=1.0D
    if hi lt lo then stop,'Error! HIGH should be greater than LOW.'
    fb = keyword_set(fixed_bounds)

;set bounds; default is [0,1] exclusive
    bound = fb ? [double(lo), double(hi)] : [double(lo)+0.5/N, double(hi)-(0.5/N)]
          

;linear increment
	inc = (bound[1]-bound[0])/(N-1)


	result = dblarr(N)
	result[0] = bound[0]
	for i=1L,N-1 do result[i] = result[i-1]+inc

	return, result

END