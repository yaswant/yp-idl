;+
; NAME:
;       PWD
; PURPOSE:
;       Print working directory
; CALLING SEQUENCE:
;       PWD
; KEYWORD PARAMETERS:
;       None
; INPUT PARAMETERS:
;       None
; MODIFICATION HISTORY:
;       See FCM
; NOTES:
;-
;      $URL: svn://fcm9/idl_svn/trans/trunk/lib/pwd.pro $
;   $Author: itkt $
;     $Date: 2008-02-19 13:18:59 +0000 (Tue, 19 Feb 2008) $
; $Revision: 744 $
;       $Id

PRO PWD
   CD, Current = c
   PRINT, c
END
