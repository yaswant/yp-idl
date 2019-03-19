;+
; :NAME:
;    	append_h5 (Deprecated)
;
; :PURPOSE:
;     Add a new object to an existing h5 File.
;     This routine is now redundant. Please use write_h5 procedure
;     with /APPEND keyword (which is more effcient)
;
; :SYNTAX:
;     append_h5, Data, Filename [,VARNAME=String]
;
;	 :PARAMS:
;    Data (IN:ANY) Input data object to add
;    Filename (IN:STRING) Existing h5 filename
;
;
;  :KEYWORDS:
;    VARNAME (IN:STRING) Name of the new object; Default name is 'DATA'
;
; :REQUIRES:
;     write_h5.pro
;     h5admin (h5 utility)
;
; :EXAMPLES:
;     write_h5, fltarr(10), 'test.h5'
;     append_h5, randomn(seed,20,20),'test.h5',varname='Random/Data/Normal'
;     help, h5_parse('test.h5',/READ_DATA),/structure
;
; :CATEGORIES:
;     File I/O
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  03-Feb-2011 16:40:37 Created. Yaswant Pradhan.
;  23-May-2011 Bug fix and Deprecated. YP
;
;-
pro append_h5, Data, Filename, VARNAME=vname

  ; Parse arguments
  syntax = 'append_h5, Data, Filename [,VARNAME=String]'
  if N_PARAMS() lt 2 then begin
    print,' Syntax: '+ syntax
    return
  endif

  if ~FILE_TEST(Filename) then begin
    print,'[append_h5]: '+Filename+' doesnot exist.'
    return
  endif

  vname   = KEYWORD_SET(vname) ? vname : 'DATA'
  group   = FILE_DIRNAME(vname)
  object  = FILE_BASENAME(vname)


  ; Write Data to a temporary h5 file
  temp_h5 = 'temp_h5_file.h5'
  write_h5, Data, temp_h5, VARNAME=object


  ; Add group to original File if necessary
  if ~STRCMP(group,'.') and ~STRCMP(group,'/') then $
  spawn,'h5admin -g '+Filename+' '+group

  ; Add Data to original File using h5admin
  spawn, 'h5admin -v -c '+temp_h5+' '+object+' '+Filename+' '+vname


  ; Remove temporary file
  if FILE_TEST(temp_h5) then FILE_DELETE, temp_h5

end