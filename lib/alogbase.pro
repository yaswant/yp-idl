;+
;NAME
;   alogbase
;
;PURPOSE:
;   Calculate logarithm of a value to a given base
;
;SYNTAX:
;   result = alogbase(base, Array)
;
;ARGUMENTS:
;   base    (IN) non-zero, non-negative scalar
;   value   (IN) scalar or vector or array of any data type except string/complex
;
;KEYWORDS:
;   none
;
;EXAMPLE:
;   calculates log2(10)
;   IDL> print, alogbase(2,10)
;           3.3219280
;
;   $Id: alogbase.pro,v 1.0 29/05/2004 12:12:33 yaswant Exp $
; alogbase.pro  Yaswant Pradhan University of Plymouth
;   Last modification:
; yaswant.pradhan@plymouth.ac.uk 2004.
;-
FUNCTION alogbase, base, value

	if (n_params() ne 2) then $
  		message,' ERROR! incorrect number of arguments'+string(10b)+' USAGE: result = alogbase(	base, value )'

  	if( n_elements(base) gt 1) then message,' Base must be a "scalar".'
	if( base le 0.) then message,' Base must be a "positive" scalar.'

  return, double(alog(value)/alog(base))

END

