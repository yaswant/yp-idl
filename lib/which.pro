;+
; NAME: 
;	WHICH
; PURPOSE: 
;	Find occurences of the program (.pro) and prints it.
; CALLING SEQUENCE: 
;	which, 'procname'
;	which, 'procname.pro'
; KEYWORD PARAMETERS: 
;	/Res - Optional.  Place the directories in an array and do
;	       not display to the screen.
; INPUT PARAMETERS:
;	A .pro to search for (string).  An array is dealt with.
; MODIFICATION HISTORY: 
;	See FCM
; NOTES:
;	Added to replicate standard Wave routine.
;       /Res is additional functionality.
;-
;      $URL: svn://fcm9/idl_svn/trans/trunk/lib/which.pro $
;   $Author: itkt $
;     $Date: 2008-02-19 13:18:59 +0000 (Tue, 19 Feb 2008) $
; $Revision: 744 $
;       $Id: which.pro 744 2008-02-19 13:18:59Z itkt $
; 

PRO WHICH, c, Res=Res
	; If called with an array, then call ourselves for each element

	IF N_ELEMENTS(c) NE 1 THEN BEGIN
		FOR i = 0UL, N_ELEMENTS(c)-1 DO WHICH, c(i)
		RETURN
	ENDIF

	;look_arr=STRSPLIT( "./:"+EXPAND_PATH( getenv("IDL_PATH") ), ":", /Extract)
	look_arr=STRSPLIT( !PATH, ";", /Extract)
	r=""
	found=0b

	FOR i = 0UL, (N_ELEMENTS(look_arr)-1) DO BEGIN
		r=FILE_SEARCH(look_arr(i)+PATH_SEP()+c+".pro")

		IF r EQ "" THEN BEGIN
			r=FILE_SEARCH(look_arr(i)+PATH_SEP()+c)
			IF r NE "" THEN found=1b
		END ELSE found=1b

		IF found EQ 1 THEN BEGIN
			IF N_ELEMENTS(arrfound) EQ 0 THEN BEGIN
				arrfound=STRARR(1)
				arrfound(0)=r
			END ELSE BEGIN
				arrfound=[arrfound, r]
				found=1b
			END
		END

		found=0
	END

	; display to screen if wanted by the user

  IF N_ELEMENTS(arrfound) EQ 0 THEN BEGIN
	  PRINT, c +" not found in IDL_PATH."
	  res=''
	ENDIF	ELSE IF ARG_PRESENT(Res) THEN BEGIN
		res=arrfound
	END ELSE BEGIN
		FOR i=0UL, N_ELEMENTS(arrfound)-1 DO BEGIN
			PRINT, arrfound(i)
		END
	END
END

