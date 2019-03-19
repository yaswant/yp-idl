;+
; The H5D_SIZE function returns size information for its argument if no keywords are set.
; If a keyword is set, H5D_SIZE returns the specified quantity.

; Arguments
;     h5file (IN:STRING) - h5 filename
;     h5data (IN:STRING) - h5 data feature
; Syntax
;     Result = H5D_SIZE( H5File, data [, /DIMENSIONS | , /N_DIMENSIONS | , /N_ELEMENTS ] )
; Keywords
;     DIMENSIONS - Set this keyword to return the dimensions of h5data.
;                  For arrays, the result is an array containing the array dimensions.
;                  The result is a 32-bit integer when possible, and 64-bit integer if
;                  the number of elements in h5data requires it.
;     N_DIMENSIONS - Set this keyword to return the number of dimension in h5data,
;                    if it is an array.
;     N_ELEMENTS - Set this keyword to return the number of data elements in h5data.
;                  Setting this keyword is equivalent to using the N_ELEMENTS function.
;                  The result will be 32-bit integer when possible, and 64-bit integer
;                  if the number of elements in Expression requires it.
; Example
;     Result = H5D_SIZE('MSG_200808181000_lite.h5', '/MSG/Ch09/Raw')
;
; $Id: H5D_SIZE.pro, v 1.0 12/03/2009 12:28 yaswant Exp $
; H5D_SIZE.pro Yaswant Pradhan (c) Crown copyright Met Office
;   Last modification:
;-

function h5d_size, h5file, h5data, SYNTAX=syntax, DIMENSIONS=dimensions, $
                   N_DIMENSIONS=n_dimensions, N_ELEMENTS=n_elements


  syn = 'Result = H5D_SIZE( h5File, h5data [, /DIMENSIONS | , /N_DIMENSIONS | ,/N_ELEMENTS] )'
  if keyword_set(syntax) then print, syn

  if ~(H5F_IS_HDF5(h5file)) then message,'Not a Valid H5 File.'

  fid = H5F_OPEN(h5file)                                      ; Open h5 file id
    data_id = H5D_OPEN(fid, h5data)                           ; Open h5 data id
      dataspace_id  = H5D_GET_SPACE(data_id)                  ; Get h5 dataspace id
        data_dims = H5S_GET_SIMPLE_EXTENT_DIMS(dataspace_id)  ;
        n_dims    = H5S_GET_SIMPLE_EXTENT_NDIMS(dataspace_id)
        n_points  = H5S_GET_SIMPLE_EXTENT_NPOINTS(dataspace_id)

  H5D_CLOSE, data_id
  H5F_CLOSE, fid

  if keyword_set(dimensions) then begin
    return, data_dims
  endif else if keyword_set(n_dimensions) then begin
    return, n_dims
  endif else if keyword_set(n_elements) then begin
    return, n_points
  endif else return, [n_dims, data_dims, n_points]

end