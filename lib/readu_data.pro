FUNCTION readu_data, filename,  $
          DIMENSION=dim,        $          
          TYPE=type,            $          
          QUIET=quiet,          $
          _REF_EXTRA=ex     

;+
;NAME:
;   readu_data
; 
;PURPOSE:
;   To read unformatted binary data from a file. This function uses
;   IDL's READU routine, but the benefit of this function is that
;   program execution does not stopp on IO error
;
;SYNTAX:
;   Result = READU_DATA( Filename ,DIMENSION=Value|Array [,Type=Value|String]
;             [,/COMPRESS] [,BUFSIZE={0 | 1 | Value>512}]
;             [,/DELETE] [,/F77_UNFORMATTED] [,/NOEXPAND_PATH] [,/SWAP_ENDIAN]
;             [,/SWAP_IF_BIG_ENDIAN] [,/SWAP_IF_LITTLE_ENDIAN] [,/VAX_FLOAT]
;             [,/XDR] [,/QUIET])
;
;ARGUMENTS:
;   filename (IN: String) - Input filename from where the data to be read
;
;KEYWORDS:
;   DIMENSION (IN: Value|Array) - Integer value or array Data size to be read
;   TYPE (IN: String) - Input data type; default is floating point or '3'.
;             Valid strings are - 'BYT' or 'BYTE', 'INT' or 'INTEGER',
;             'FLT' or 'FLOAT', 'LON' or LONG, 'DBL' or 'DOUBLE'
;Inherrited keywords from OPENR
;   BUFSIZE - Set this keyword to a value greater than 512 to specify the size
;             of the I/O buffer (in bytes) used when reading and writing files.
;             Setting BUFSIZE=1 (or any other value less than 512) sets the
;             buffer to the default size, which is platform-specific. Set
;             BUFSIZE=0 to disable I/O buffering. Note that the buffer size is
;             only changeable when reading and writing stream files. Under
;             UNIX, the RAWIO keyword must not be set. Also note that the system
;             stdio may choose to ignore the buffer size setting.
;   COMPRESS- If COMPRESS is set, IDL reads and writes all data to the file in
;             the standard GZIP format.  COMPRESS cannot be used with the
;             APPEND keyword.
;   DELETE -  Set this keyword to delete the file when it is closed.
;   F77_UNFORMATTED - Unformatted variable-length record files produced by 
;             FORTRAN programs running on platforms that use stream files 
;             (UNIX and Microsoft Windows) contain extra information along with
;             the data in order to allow the data to be properly recovered.
;             This method is necessary because FORTRAN input/output is based on
;             record-oriented files, while files that are simple byte streams
;             do not impose any record structure. Set the F77_UNFORMATTED 
;             keyword to read and write this extra information in the same 
;             manner as f77(1), so that data can be processed by both IDL and 
;             FORTRAN. See Reading and Writing FORTRAN Data (Application 
;             Programming) for further details. Note: On 64-bit machines, some 
;             Fortran compilers will insert record markers that are 64-bit 
;             integers instead of the standard 32-bit integers. When reading 
;             FORTRAN data, IDL will attempt to recognize the presence of 
;             64-bit record markers and switch to the appropriate format.
;             When writing unformatted Fortran files, IDL will continue to use
;             32-bit record markers.
;       NOTE: /F77 and /COMPRESS are conflicting keywords, therefore should 
;             not be used together.
;   SWAP_ENDIAN- Set this keyword to swap byte ordering for multi-byte data 
;             when performing binary I/O on the specified file. This is useful 
;             when accessing files also used by another system with byte 
;             ordering different than that of the current host.
;   SWAP_IF_BIG_ENDIAN - Setting this keyword is equivalent to setting 
;             SWAP_ENDIAN; it only takes effect if the current system has big 
;             endian byte ordering. This keyword does not refer to the byte 
;             ordering of the input data, but to the computer hardware. 
;   SWAP_IF_LITTLE_ENDIAN - Setting this keyword is equivalent to setting 
;             SWAP_ENDIAN; it only takes effect if the current system has little
;             endian byte ordering. This keyword does not refer to the byte
;             ordering of the input data, but to the computer hardware.
;   VAX_FLOAT - The opened file contains VAX format floating point values.
;             This keyword implies little endian byte ordering for all data 
;             contained in the file, and supersedes any setting of the 
;             SWAP_ENDIAN, SWAP_IF_BIG_ENDIAN, or SWAP_IF_LITTLE_ENDIAN 
;             keywords. The default setting for this keyword is FALSE.                 
; 
;OUTPUT:
;   RESULT - retuned data array                                                         
; 
;EXAMPLE:
;   IDL> openw,1,'test.dat'
;   IDL> writeu,1,findgen(200,200)
;   IDL> close,1 & spawn,'gzip test.dat'
;   IDL> data = READU_DATA( 'test.dat.gz', DIM=[200,200], /compress)                    
; 
; EXTERNAL ROUTINE:
;     file_suffix.pro
; 
; $Id: READU_DATA.pro,v 1.0 22/05/2009 11:53:21 yaswant Exp $
; READU_DATA.pro Yaswant Pradhan (c) Crown Copyright Met Office 
; Last modification: May 09
; 01.07.09 - added _Extra keyword. YP
; 2010-02-11 16:32:57 Added Compressed file error message block. YP
;- 


; -----------------------------------------------------------------------------

  syntax =' Result = READU_DATA( Filename ,DIMENSION=Value|Array'+$
          ' [,Type=Value|String] [,/COMPRESS] [,BUFSIZE={0 | 1 | Value>512}]'+$
          ' [,/DELETE] [,/F77_UNFORMATTED] [,/NOEXPAND_PATH] [,/SWAP_ENDIAN]'+$
          ' [,/SWAP_IF_BIG_ENDIAN] [,/SWAP_IF_LITTLE_ENDIAN] [,/VAX_FLOAT]'+$
          ' [,/XDR] [,/QUIET])'

  if n_params() lt 1 then message,' Filename is missing.'+string(10b)+syntax
  if ~keyword_set(dim) then message,' DIMENSION is missing.'+string(10b)+syntax
  verb = ~KEYWORD_SET(quiet)
  
; Check if input file exists:
  if file_test(filename) then begin

  ; Define default data type:
    type = keyword_set(type) ? strupcase(strtrim(string(type),2)) : 'FLOAT'

  ; Warning for compressed file error message:
    ex = n_elements(ex) ne 0 ? strupcase(ex) : ' '
    compress = -1
    for i=0,n_elements(ex)-1 do compress = compress > stregex(ex[i],'COMP')

    if (STRCMP(file_suffix(filename),'gz',/FOLD) and compress eq (-1)) then $
    print,'** Wrning! Looks like a compressed file. Hints: Use /COMPRESS'


  ; Declare error label:
    on_ioerror, BAD_DATA
 
  ; Use the GET_LUN keyword to allocate a logical file unit:
    if verb then print,' Reading: '+ filename
    openr, lun, filename, /get_lun, _EXTRA=ex

  ; Define data array:
    if (stregex(type,'BYT')>stregex(type,'BYTE')>(-1)) ge 0 $
        then A = bytarr(dim) else $
    if (stregex(type,'INT')>stregex(type,'INTEGER')>(-1)) ge 0 $
        then A = intarr(dim) else $
    if (stregex(type,'FLT')>stregex(type,'FLOAT')>(-1)) ge 0 $
        then A = fltarr(dim) else $
    if (stregex(type,'LON')>stregex(type,'LONG')>(-1)) ge 0 $
        then A = lonarr(dim) else $
    if (stregex(type,'DBL')>stregex(type,'DOUBLE')>(-1)) ge 0 $
        then A = dblarr(dim) $
    else message,' Unrecognised data type.'

  ; Read the data array:
    readu, lun, A
 
  ; Clean up and return: 
    goto, GOOD_DATA
 
  ; Exception label. Print the error message: 
    BAD_DATA:   print, !err_string
 
  ; Close and free the input/output unit:
    GOOD_DATA:  free_lun, lun
 
; Return the result. This will be undefined if an error occurred: 
    return, A

  endif else message,' File: '+filename+' does not exist.'
 
END
