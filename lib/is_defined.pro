function is_defined, expr

; NAME:         
;       IS_DEFINED                                                          
; PURPOSE:      
;       The IS_DEFINED function returns a Boolean value based on the value  
;       of the specified expression. It returns a True (1) if its argument  
;       is defined including zero, and False (0) otherwise. This function   
;       begaves similarly as KEYWORD_SET, but can accept zero values unlike 
;       KEYWORD_SET.                                                        
; SYNTAX:       
;       Result = IS_DEFINED( Expression )                                   
; RETURN VALUE: 
;       This function returns True (1) if:                                  
;         * Expression is a scalar or array.                                
;         * Expression is a structure.                                      
;         * Expression is an ASSOC file variable.                           
;       And returns False (0) if:                                           
;         * Expression is undefined.                                        
; ARGUMENTS:    
;       Expression                                                          
;       The expression to be tested. Expression is usually a named variable.
; KEYWORDS:     
;       None.                                                               
; EXAMPLES:     
;       Suppose that you are writing an IDL procedure that has the          
;       following procedure definition line:                                
;       PRO myproc, DEF1=def1                                               
;       The following command could be used to execute a set of commands    
;       only if the keyword DEF1 is set (i.e., it is present)               
; IDL> def1=0
; IDL> IF IS_DEFINED(def1) THEN PRINT, def1                                 
;     0
; IDL> IF KEYWORD_SET(def1) THEN PRINT, def1                                
;     IDL returns false, even though def has a defined value (0)            
;
; $Id: IS_DEFINED.pro,v1.0 03/06/2009 11:12:29 yaswant Exp $      
; IS_DEFINED.pro Yaswant Pradhan (c) Crown copyright Met Office   
; Last modification:                                              
;-
   
  return, ( n_elements(expr) ne 0 ) ? 1b : 0b 
;  if( n_elements(expr) ne 0 ) then return,1b else return,0b
    
end 
