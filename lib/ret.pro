;+
; :NAME:
;       ret
;
; :PURPOSE:
;       Simple method to retrun to the caller level with a given message.
;
; :SYNTAX:
;       ret, ExplainedText
;
; :PARAMS:
;    text (in:string)
;       Message to print before returning to caller level
;
;
; :REQUIRES:
;       None
;
; :EXAMPLES:
;       ret, 'There was an error'
;
; :CATEGORIES:
;       Errror handling
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Sep 27, 2012 2:07:22 PM Created. Yaswant Pradhan.
;
;-
pro ret, text
    on_error, 2   ; Stop in caller
    message, LEVEL=-1, text, /CONTINUE
    retall
end