FUNCTION file_suffix, Path, PATTERN=patt, PREFIX=prefix, KEEP_PATH=keep_path
;+
; :NAME:
;    	file_suffix
;
; :PURPOSE:
;     The FILE_SUFFIX function returns the file suffix of a file path.
;     A file path is a string containing one or more segments consisting 
;     of names separated by file delimiter characters (period (.)). 
;     The suffix is the final rightmost segment of the file path.
;
; :SYNTAX:
;     Result = FILE_SUFIX( Path [,PATTERN=String] [,PREFIX=Variable] 
;                         [,/KEEP_PATH] )
;
;	 :PARAMS:
;    Path (IN:String|StrArr) Path containing the suffix for each element of 
;             the Path argument
;
;  :KEYWORDS:
;    PATTERN (IN:String) A scalar string as file suffix indicator    
;               default pattern is a period '.'           
;    PREFIX (OUT:Variable) A named variable to store prefix(es) for each 
;               element of the Path argument.
;    /KEEP_PATH Set this keyword to keep the full path with file PEFIX;
;               def: keep file basename.
;
; :REQUIRES:
;     None
;
; :EXAMPLES:
;   IDL> print,file_suffix('data.dat.gz')       
;        gz                                     
;   IDL> print,file_suffix(['a.b','c.d','p.ex'])
;        b d ex
;   IDL> print,file_suffix(['a.b','c.d','p.ex'],PATT='.ex',PREF=p)
;        ex 
;        [Note the output is still a 3-element array with null strings
;        where the pattern was not found]
;   IDL> print, p
;        a.b c.d p
;
; :CATEGORIES:
;     String manipulation
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  11-Oct-2010 12:23:54 Created. Yaswant Pradhan.
;  19-Jul-2011 Added KEEP_PATH keyword and bug fixes. YP.
;
;-

; Parse inputs:
  syntax =' Result = FILE_SUFIX( Path [,PATTERN=String] '+$
          ' [,PREFIX=Variable] [,/KEEP_PATH] )'

  if (n_params() lt 1) then message,'Syntax: '+syntax 
  
  patt = keyword_set(patt) ? strtrim(patt,2) : '.'
  n    = n_elements(Path)
  
; Construct a diagonal square matrix to handle strmid out for arrays:
  diag  = where( diag_matrix(replicate(1, n)) )

; Set the full path in file prefix if keep_path keyword is set:
  nPath  = keyword_set(keep_path) ? Path : file_basename(Path) 
  
  
; Get prefix:
  prefix  = n eq 1 ? $
            ((strmid(nPath,0,strpos(nPath,patt,/Reverse_Search)))[diag])[0] : $
             (strmid(nPath,0,strpos(nPath,patt,/Reverse_Search)))[diag]


; Get the suffix matrix [n,n], where the diagonal position holds
; suffixes of each input path string and return:
  suffix  = strmid( nPath, strpos(nPath, patt ,/REVERSE_SEARCH)+1 )

; Check if the extension pattern exists in the Path:
  noMatch = where(strpos(nPath,patt) lt 0, n_noMatch)

  if (n_noMatch gt 0) then begin    
    prefix[noMatch]=nPath[noMatch]
    suffix[diag[noMatch]] = ''
  endif   

; Return result:    
  return, n eq 1 ? (suffix[diag])[0] : suffix[diag]

END
