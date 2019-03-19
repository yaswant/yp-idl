;+
; :NAME:
;       LONTS (or Longitude Ticks)
;
; :PURPOSE:
;     LONTS callback function is used to display the tick values
;     with an additional 'W' or 'E' for West or East
;     representation of Longitude values.
;
;
; :SYNTAX:
;     [XYZ]TICKFORMAT='LONTS'
;
;    :PARAMS:
;    axis   :is the axis number: 0 for X axis, 1 for Y axis, 2 for Z axis.
;    index  :is the tick mark index (indices start at 0).
;    value  :is the data value at the tick mark
;            (a double-precision floating point value).
;
;
; :REQUIRES:
;     None
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;     Plotting, TickValue Formatting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  05-Jul-2010 11:29:11 Created. Yaswant Pradhan.
;
;-

FUNCTION LONTS, axis, index, value

  null = ''
  form = (abs(value mod 1) eq 0) ? '(I0)' : '(F6.1)'

  if (value gt 0.) then ind=string(value,FORMAT=form)+string(176b)+'E'
  if (value lt 0.) then ind=string(abs(value),FORMAT=form)+string(176b)+'W'
  if (value eq 0.) then ind='0'
  fmt = '(A,"'+ind+'")'

  return, string(null, FORMAT=fmt)

END
