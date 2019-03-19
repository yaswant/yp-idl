;+
; NAME:
;     helps
; PURPOSE:
;     shortcut to display information on structure-type variables
; SYNTAX:
;     helps, Expression
; LAST MODIFICATION:
;     2009-12-02 13:46:51. Created. Yaswant Pradhan
;-

pro helps, Expression

  if n_params() lt 1 then help, /STRUCT

  case size(Expression, /TYPE) of
      8 : begin
            help, size(Expression,/STRUCT),/STRUCT, OUTPUT=str
            print, replicate('-',40)
            print,' Structure Attributes:'
            print, str[6]
            print, str[7]
            print, replicate('-',40)
            print,' Variables: '
            help, Expression, /STRUCT
            print, replicate('-',40)
          end
      else: help, Expression
  endcase

end
