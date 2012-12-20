function int2bit, Value, nbit,  $
         CHECK_BITS=check_bits, $
         ALL=all
;+
; :NAME:
;    	int2bit
;
; :PURPOSE:
;     Convert interger values to bit arrays. This can be used to check binary 
;     bit-flags.
;
; :SYNTAX:
;     Result = INT2BIT( IntArray [,nBit] [,CHECK_BITS=array] [,/ALL]   
;
;	 :PARAMS:
;    Value (in:array) Input interger value or vector array 
;    nbit (in:value) number of bits, def: 16-bit
;
;
;  :KEYWORDS:
;    CHECK_BITS (in:array) Check if position of these bits are present. 
;    /ALL - Used in conjunction with CHECK_BITS keyword. If set, int2bit 
;           returns TRUE if all bits defined in the check_bits array are 
;           present in Value. Default is to check for any bit present in Value.
;
; :REQUIRES:
;     
;
; :EXAMPLES:
;   IDL> print, int2bit(250,8)
;   0   1   0   1   1   1   1   1
;   
;   IDL> print, int2bit(250,8, CHECK_BITS=[0])
;   0
;   
;   IDL> print, int2bit(250,8, CHECK_BITS=[0,3,7])
;   1
;
;   IDL> print, int2bit(250,8, CHECK_BITS=[0,3,7], /ALL)
;   0
;
;   Array operations:
;   IDL> print,int2bit([23,11],8)
;   1   1   1   0   1   0   0   0
;   1   1   0   1   0   0   0   0
;
;   IDL> print,int2bit([23,11],8, CHECK_BITS=[0,1,2,4])
;   1   1
;   
;   IDL> print,int2bit([23,11],8, CHECK_BITS=[0,1,2,4],/ALL)
;   1   0
;   
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  07-Mar-2011 Created. Yaswant Pradhan.
;  08-Mar-2012 Vectorised version. YP.
;  13-Mar-2012 Add check_bits keywords. YP. 
;
;-

; Parse arguments: 
  nbit  = (N_PARAMS() eq 2) ? nbit : 16
  xbits = N_ELEMENTS(check_bits)
  nv    = N_ELEMENTS(Value)
  out   = BYTARR(nbit,nv)


; Get bit positions recursively:
  for n=0L,nv-1 do begin
      for i=nbit-1,0,-1 do begin
      
          bitInt = ROUND(2d^i, /L64)
          if (Value[n] ge bitInt) then begin
              out[i,n]  = 1
              Value[n]  = Value[n] - bitInt
          endif
          
      endfor
  endfor

  
; Return true(1) or flase(0) if CHECK_BITS keyword is present
; otherwise return the output bit array: 
  return, (xbits gt 0) $
          ? (KEYWORD_SET(all)) $
            ? TOTAL(out[check_bits,*],1) eq REPLICATE(xbits,nv) $
            : TOTAL(out[check_bits,*],1) ne REPLICATE(0,nv) $
          : out
  
end