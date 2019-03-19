FUNCTION get_sps_constants, name, ALL=all

;+
; SYNTAX:
;   Result = get_sps_constants( [name] [,/all] )
; ARGUMENTS:
;   name (IN:STRING) - name of the sps_constants structure member
; EXAMPLE:
;   result = get_sps_constants('PLANCK_C1')
;   print, result
;   1.1910659e-05
;-	
	if( n_params() lt 1 or keyword_set(all) )then $
		return, sps_constants() $
	else begin	
		for i=0,n_tags(sps_constants())-1 do begin
			if ( (tag_names(sps_constants()))[i] eq strupcase(name) ) then begin
			;print, (sps_constants()).(i)
			return, (sps_constants()).(i)
			endif
		endfor	
	endelse
END
