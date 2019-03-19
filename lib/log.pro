;+
; :NAME:
;       log
;
; :PURPOSE:
;       Simple method to log or retrun to the caller level with a given message.
;
; :SYNTAX:
;       log, TextMessage [,/EXIT]
;
; :PARAMS:
;    TextMessage (in:string)
;       Message to print before returning to caller level
;
;
; :REQUIRES:
;       None
;
; :EXAMPLES:
;       log, 'There was an error'
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

pro log, TextMessage, EXIT=exit
    on_error, 2   ; Stop in caller
    message, LEVEL=-1, TextMessage, /CONTINUE, /NOPREFIX
    if KEYWORD_SET(exit) then retall

end
