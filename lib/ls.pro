;+
; NAME:
;       LS
; PURPOSE:
;       List directory contents
; CALLING SEQUENCE:
;       LS [,directory]
; KEYWORD PARAMETERS:
;       None
; INPUT PARAMETERS:
;       directory - Directory to list.  Default is current directory.
; MODIFICATION HISTORY:
;       See FCM
; NOTES:
;-

PRO ls, dir
    IF (N_ELEMENTS(dir) EQ 0) THEN dir=''

    SPAWN, 'ls'+dir
END
