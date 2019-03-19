function is_defined, expr
;+
; :NAME:
;    	is_defined
;
; :PURPOSE:
;       The is_defined function returns a Boolean value based on the value
;       of the specified expression. It returns a True (1) if its argument
;       is defined including zero, and False (0) otherwise. This function
;       differs from KEYWORD_SET in the following way:
;       
;       is_defined function returns True (1b) if:
;           * Expression is a value.
;           * Expression is a scalar or array.
;           * Expression is a structure.
;           * Expression is an ASSOC file variable.
;           and returns False (0b) if:
;           * Expression is undefined.
;       keyword_set returns true (1):
;           * if expr is "defined and non-zero"
;
; :SYNTAX:
;       result = is_defined( Eexpression )
;
; :PARAMS:
;    expr (in:variable)
;       The expression to be tested. Expression is usually a named variable.
;
; :REQUIRES:
;       None.
;
; :EXAMPLES:
;       Suppose that you are writing an IDL procedure that has the          
;       following procedure definition line:                                
;       PRO myproc, DEF1=def1                                               
;       The following command could be used to execute a set of commands    
;       only if the keyword DEF1 is set (i.e., it is present)               
; IDL> def1=0
; IDL> print, IS_DEFINED(def1)                                 
;       1
; IDL> print, KEYWORD_SET(def1)
;       0                                
;     IDL returns false, even though def1 has a value (0)            
;
;
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Jun 3, 2009 11:12:29 Created. Yaswant Pradhan.
;  Jul 2010 Updated header. YP.
;
;-
   
  return, (n_elements(expr) ne 0) ? 1b : 0b
    
end 
