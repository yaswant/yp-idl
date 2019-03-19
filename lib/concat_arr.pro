
function concat_arr, Arr1, Arr2, ConcatDim
;+
;
;     ConcatDim  -- Dimension to concatenate. 0 = first dimension.
;
;-


  ConcatDim = is_defined(ConcatDim) ? ConcatDim : 0
  Size1 = size(Arr1)
  Size2 = size(Arr2)

; make sure they are the same type
  if size(Arr1, /type) ne size(Arr2, /type) then begin
    message, 'Arrays are not the same type';, /info
    return, 0
  endif

; make sure they have the same number of dimensions
  if Size1[0] ne Size2[0] then begin
    message, 'number of dimensions do not match';, /info
    return, 0
  end

; we only need the dimension sizes now. makes the code tidier.
  NDims = Size1[0]
  Size1 = Size1[1:NDims]
  Size2 = Size2[1:NDims]

; check the dimensions are the same size, excpet the concat dimension
  SizeMisMatch = 0
  for d=0,NDims-1 do begin

  ; do we need to check this dimension matches?
    if d eq ConcatDim then continue

  ; does this dimension match?
    if Size1[d] ne Size2[d] then begin
      message, 'dimension ' + strtrim(string(d+1),2) + $
               ' of ' + strtrim(string(NDims),2) + ' mismatch';, /info
      return, 0
    endif

  endfor


; ok, they match up. concatenate.
; what is the new size?
  NewSize = Size1
  NewSize[ConcatDim] += Size2[ConcatDim]

; replicate Arr1[0] to make it the correct type
  Result = replicate(Arr1[0], NewSize)

; build a command to fill in the new array
  FillCommand1 = 'Result['
  FillCommand2 = 'Result['
  for d=0,NDims-1 do begin

    if d ne ConcatDim then begin

    ; add a star for this dim
      FillCommand1 += '*'
      FillCommand2 += '*'

    ;add a comma too?
      if d lt NDims-1 then begin
        FillCommand1 += ','
        FillCommand2 += ','
      endif

    endif else begin

    ; add a range specifier for this dimension
      FillCommand1 += '0:' + strtrim(string(Size1[ConcatDim]-1),2)
      FillCommand2 += strtrim(string(Size1[ConcatDim]),2) + ':' + $
                      strtrim(string(NewSize[ConcatDim]-1),2)

    ; add a comma too?
      if d lt NDims-1 then begin
        FillCommand1 += ','
        FillCommand2 += ','
      endif

    endelse

  endfor

  FillCommand1 += '] = Arr1'
  FillCommand2 += '] = Arr2'

;     help, FillCommand1
;     help, FillCommand2
    
  ok = execute(FillCommand1)
  ok = execute(FillCommand2)

;     help, Arr1
;     help, Arr2
;     help, Result

  return, Result

end

