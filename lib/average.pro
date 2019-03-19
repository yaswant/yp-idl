FUNCTION average, array, dim, MISSING=missing, _EXTRA=_extra

;+
; NAME:      
;         average                                                                 
;
; PURPOSE:   
;         Returns the average value of an array in a sepcified dimention          
;         (see all arguments as in 'total')                                       
;
; SYNTAX:    
;         result = average(array [,dim] [,MISSING=Value] [,/DOUBLE][,/NaN])                         
;
; ARGUMENTS: 
;         array (IN)  array to be averaged, any type except string                
;         dim   (IN)  dimension over which the average is to be performed;        
;                     average=mean when dim=0 (see 'total' documentation)         
;
; KEYWORDS:  
;         missing (IN : Array or Scalar)  - Values to ignore in averaging         
;                     (Use /NAN while using this keyword not required anymore)
;         _extra    - all keywords passed to 'total'                              
;
; EXTERNAL ROUTINES:
;         match.pro
;
; $Id: average.pro,v 1.0 29/05/2005 19:25:13 yaswant Exp $           
; average.pro Yaswant Pradhan University of Plymouth, now at Met Office     
; Last modification:
;   19 May 2009 (yp) added missing keyword
;   20 Jan 2011 (yp) /NaN not required with Missing keyword                        
;-



  if(n_params() lt 1 ) then $
  message,'Syntax Error: result = average(array [,dim] [,MISSING=Value] [,/DOUBLE] [,/NaN])'

  if( n_elements(dim) eq 0 ) then dim = 0
    
  if( n_elements(missing) ne 0 OR  arg_present(missing) ) then begin    
    ;m = where( array eq missing, nm )    
    match, array, missing, m, count=nm
    
    if( nm gt 0 ) then begin
      array    = float(array)
      array[m] = !values.f_nan
    endif  
  endif
  
  return, total(array, dim, /NaN, _extra=_extra) / (total(finite(array), dim)>1)

END

