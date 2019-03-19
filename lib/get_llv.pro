;+
; NAME:
;     get_llv
;
; PURPOSE:
;     Returns a Latitude or Longitude array from a given range with 0
;     included (we want to make sure that Equator or GMT line always present).
;
; SYNTAX:
;     Result = get_llv( llimit, delta [,/NO_CLIP] [,/VERBOSE] )
;
; ARGUMENTS:
;     llimit (IN:Array) 2-element array of Latitude or Longitude Limit
;     delta (IN:Value) Desired Latitude of Longitude interval
;
; KEYWORDS:
;     /NO_CLIP - Do not append the input llimit values to output. llimit values
;                are appended to the result by default.
;     /VERBOSE - Verbose mode
; EXAMPLE:
;     IDL> print,get_llv([-20,134], 13)
;     -26.0000     -13.0000      0.00000      13.0000      26.0000
;      39.0000      52.0000      65.0000      78.0000      91.0000
;      104.000      117.000      130.000
;
; EXTERNAL ROUTINES:
;     none
;
; CATEGORY:
;     Mapping, Plotting
;
;
; -------------------------------------------------------------------------
; $Id: get_llv.pro,v0.1 26/03/2010 12:30:06 yaswant Exp $
; get_llv.pro Yaswant Pradhan (c) Crown Copyright Met Office
; Last modification:
; -------------------------------------------------------------------------
;-

function get_llv, llimit, delta, NO_CLIP=no_clip, VERBOSE=verbose

  intervals = ceil(180./delta)
  tmp_array = [-findgen(intervals+1)*delta, findgen(intervals+1)*delta]
  srt_array = tmp_array[uniq(tmp_array, sort(tmp_array))]
  valid_idx = value_locate(srt_array,llimit)

 ; ---
 ; Make sure that the ll limits are included in the return array
  flag = 0
  if ( llimit[0] ge srt_array[valid_idx[0]] ) then flag=flag+1
  if ( llimit[1] le srt_array[valid_idx[1]] ) then flag=flag+2
  if keyword_set(no_clip) then flag=-1

  if KEYWORD_SET(verbose) then print,'[GET_LLV] Flag: ',flag
; FLAG meaning
;   0: append llimit values to either ends of llv
;   1: first value of llv is OK, append llimit[1] to llv tail
;   2: last value of llv is OK, append llimit[0] to llv head
;   3: both first and last values of llv are OK, do not append llimit to llv
;   other:  do not append even any of the above tests are valid, equivalent to
;           /NO_CLIP keyword

  case flag of
    0:    return, [llimit[0], srt_array[valid_idx[0]:valid_idx[1]], llimit[1]]
    1:    begin
            srt_array[valid_idx[0]] = llimit[0]
            return, [ srt_array[valid_idx[0]:valid_idx[1]], llimit[1] ]
          end
    2:    return, [llimit[1],  srt_array[valid_idx[0]:valid_idx[1]] ]
    3:    return, srt_array[valid_idx[0]:valid_idx[1]]
    else: return, srt_array[valid_idx[0]:valid_idx[1]]
  endcase
; ---
  ;return, [llimit[0], srt_array[valid_idx[0]:valid_idx[1]], llimit[1]]

end
