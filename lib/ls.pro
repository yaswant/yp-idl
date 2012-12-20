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
;      $URL: svn://fcm9/idl_svn/trans/trunk/lib/ls.pro $
;   $Author: itkt $
;     $Date: 2008-02-19 13:18:59 +0000 (Tue, 19 Feb 2008) $
; $Revision: 744 $
;       $Id: ls.pro 744 2008-02-19 13:18:59Z itkt $
;

PRO ls, dir
    IF (N_ELEMENTS(dir) EQ 0) THEN dir=''

    SPAWN, 'ls'+dir
END
