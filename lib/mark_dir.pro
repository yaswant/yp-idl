;+
; :NAME:
;     mark_dir
;
; :PURPOSE:
;     MARK_DIR function adds a directory mark (or path separator mark) to
;     input string.
;
; :SYNTAX:
;     Result = mark_dir( Path )
;
;  :PARAMS:
;    path (IN:String) A scalar string or string array indicating input path name(s).
;                     (def: current working directory)
;
; :REQUIRES:
;     strrev.pro
;
; :EXAMPLES:
;   IDL> print,mark_dir()
;   Warning! No Input argument. Retruning Current Working Directory.
;   /net/home/h05/fra6/
;
;   IDL> print,mark_dir('/data/local')
;   /data/local/
;
;   IDL> print,mark_dir(['/unmarked/dir','/marked/dir/'])
;   /unmarked/dir/ /marked/dir/
;
; :CATEGORIES:
;   String manipulation
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  23-Aug-2010 11:53:21 Created. Yaswant Pradhan.
;  May 2011: Added null string error check. YP.
;-

function mark_dir, path

  compile_opt idl2
  cd, CURRENT=cwd


  ; Parse input argument
  if (N_PARAMS() lt 1) then begin
    print,'** Warning! No Input argument. Retruning Current Working Directory **'
    path = cwd
  endif

  ; Check presence of null string ('') in the input
  null1 = (PRODUCT(STRLEN(path)) eq 0)
  if null1 then begin
    npath = path[where(~STRCMP(path,''))]
    if (PRODUCT(STRLEN(npath)) eq 1) $
    then message,' Can not process null string.'
  endif

  out = path

  ; Check directory marked strings
  dmark   = PATH_SEP()
  lastc   = STRMID(strrev(path),0,1)
  marked  = WHERE(STRCMP(lastc,dmark), COMPLEMENT=mark, NCOMPLEMENT=n_mark)

  if (n_mark gt 0) then out[mark] = path[mark]+dmark

  return, out

end
