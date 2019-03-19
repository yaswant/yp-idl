;+
; NAME
;     msg_land2fd
;
; PURPOSE
;     Convert msg land only data to a full disc [3712x3712] array
;     in satellite projection
;
; ARGUMENTS
;     data (IN:FLTARR) Land (masked) data
;     index (IN:LONARR)Land index data (position of landmask on
;                     SEVIRI disc)
;
; KEYWORDS
;     MISSING (IN:VALUE) Fillvalue for locations outside data index
;
; $Id: msg_land2fd.pro,v 1.0 10/08/2010 09:59:45 yaswant Exp $
; msg_land2fd.pro Yaswant Pradhan (c) Crown Copyright Met Office
; Last modification: Aug 10
;-

function msg_land2fd, data, index, MISSING=missing

  syntax = ' Result = msg_land2fd( Data, Index)'

  if N_PARAMS() lt 2 then message, syntax
  if N_ELEMENTS(data) ne N_ELEMENTS(index) then $
     MESSAGE, ' Data and Index have different length.'

  out = MAKE_ARRAY( 3712,3712, $
        VALUE=(is_defined(missing) ? missing : !VALUES.F_NAN) )

  out[index] = data

  ;RETURN, REVERSE(out)
  RETURN, out

end
