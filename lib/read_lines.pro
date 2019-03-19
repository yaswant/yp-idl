;+
; :NAME:
;     read_lines
;
; :PURPOSE:
;     READ_LINES function reads lines from an ASCII file and text outputs
;     as result.
;
;
; :SYNTAX:
;     Result = read_lines( Filename [,firstLine] [,lastLine] [,SKIPPED=varaible]
;                          [,/COMPRESS] [,STAUTS=variable] )
;
; :PARAMS:
;    Filename (IN:String) Input ASCII filename to read in.
;    firstLine (IN:Value) Fist line to read; def: 1.
;    lastLine (IN:Value) Last line to read; def: Last line in the file.
;
; :KEYWORDS:
;    SKIPPED (out:variable) Named variable to store skipped lines; def:[' ']
;    STAUTS (out:variable) Named variale to store error status. 0=OK
;    /COMPRESS Read from compressed ascii file.
;
; :REQUIRES:
;     None.
;
; :EXAMPLES:
;
;
; :CATEGORIES:
;   File I/O
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  05-Sep-2011 10:53:31 Created. Yaswant Pradhan.
;  05-Mar-2012 Code optimised. YP.
;  22-Jun-2012 Add compress keyword. YP
;-

function read_lines, Filename, $
    firstLine, lastLine, $
    SKIPPED=skip,        $
    COMPRESS=compress,   $
    STAUTS=status

  status = 0b
  syntax =' Result = read_lines(Filename [,LINES=Array])'

  ; Parse error:
  catch, err
  if (err ne 0) then begin
      catch, /CANCEL
      help,  /LAST_MESSAGE, OUTPUT=errMsg
      print, errMsg[0: N_ELEMENTS(errMsg)-2], FORMAT='(A)'
      status = err ne 0
      return, -1
  endif


  ; Parse inputs:
  narg = N_PARAMS()
  gz   = KEYWORD_SET(compress)
  if (narg lt 1) then message,'Syntax: '+syntax
  if ~(FILE_TEST(Filename)) then message,Filename +' doesnot exist.'
  nlines = FILE_LINES(Filename, COMPRESS=gz)
  if (nlines eq 0) then message,Filename +' is empty.'



  ; Issue warning if firstLine or lastLine exceed nlines:
  if (narg ge 3) then if (firstLine gt nlines or lastLine gt nlines) then begin
      print,'** Warning: [read_lines] Input argument exceeded EOF *'+$
             STRING(10b)+'  Max Lines in the file: '+STRTRIM(nlines,2)
  endif


  ; Adjust firstLine/lastLine within valid limit:
  firstLine = (N_ELEMENTS(firstLine) ne 0) ? (firstLine < nlines > 1) : 1
  lastLine  = (N_ELEMENTS(lastLine) ne 0) ? lastLine < nlines : nlines
  nL        = lastLine - firstLine

  if (nL lt 0) then message,' FirstLine > LastLine '


  ; Read appropriate lines and return:
  str   = STRARR(nL+1)
  skip  = REPLICATE(' ',(firstLine-1)>1)

  openr, lun, Filename, /GET_LUN, COMPRESS=gz
  if (firstLine gt 1) then readf, lun, skip
  readf, lun, str
  free_lun, lun

  return, str

end
