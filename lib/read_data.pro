;+
; :NAME:
;     read_data
;
; :PURPOSE:
;     To read unformatted "binary data" from a file. The result is an array or
;     structure containing all of the entities read from the file.
;     This function uses IDL's READU routine, but the benefit of this function
;     is that program execution does not stopp on IO error.
;
;     See read_lines.pro for reading unformatted text files.
;
;
; :SYNTAX:
;     result = read_data( filename [,STRUCTURE=structure] [DATA_START=byte],
;                        [,DIMENSION=value|array] [,TYPE=value|string]
;                        [,/QUIET] [_REF_EXTRA=ex]
;
;  :PARAMS:
;    filename (IN:string) Input filename from which the data to be read.
;
;
;  :KEYWORDS:
;    STRUCTURE (IN:structure) Set this keyword to a template structure
;                         describing the file to be read.
;    DATA_START (IN:value) Set this keyword to specify where to begin
;                         reading in a file. This value is as an offset,
;                         in bytes, that will be applied to the initial
;                         position in the file. The default is 0.
;    DIMENSION (IN:value|array) Set this keyword to a scalar or array of
;                         up to eight elements specifying the size of the
;                         data to be read and returned. For example,
;                         DIMENSION=[512,512] specifies that a two-dimensional,
;                         512 by 512 array be read and returned. def:1
;    GET_DIMENSION (out:varianle) Named variable to store data dimenstion.
;    TYPE (IN:value|string) Set this keyword to an IDL typecode of the data
;                         to be read. See documentation for the SIZE function
;                         for a listing of typecodes. Default is 4
;                         (IDL's FLOAT typecode).
;    /AUTOMATIC           Automatically update structure dimension from first
;                         record (experimental)
;    /QUIET               Quiet mode
;
;    _REF_EXTRA           Inherrited keywords from OPENR (See below)
;   BUFSIZE - Set this keyword to a value greater than 512 to specify the size
;             of the I/O buffer (in bytes) used when reading and writing files.
;             Setting BUFSIZE=1 (or any other value less than 512) sets the
;             buffer to the default size, which is platform-specific. Set
;             BUFSIZE=0 to disable I/O buffering. Note that the buffer size is
;             only changeable when reading and writing stream files. Under
;             UNIX, the RAWIO keyword must not be set. Also note that the
;             system stdio may choose to ignore the buffer size setting.
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
;             SWAP_ENDIAN; it only takes effect if the current system has
;             little endian byte ordering. This keyword does not refer to the
;             byte ordering of the input data, but to the computer hardware.
;   VAX_FLOAT - The opened file contains VAX format floating point values.
;             This keyword implies little endian byte ordering for all data
;             contained in the file, and supersedes any setting of the
;             SWAP_ENDIAN, SWAP_IF_BIG_ENDIAN, or SWAP_IF_LITTLE_ENDIAN
;             keywords. The default setting for this keyword is FALSE.
;
; :REQUIRES:
;       file_sufix.pro
;
; :EXAMPLES:
;   IDL> openw,1,'test.dat'
;   IDL> writeu,1,findgen(200,200)
;   IDL> close,1 & spawn,'gzip test.dat'
;   IDL> data = READ_DATA( 'test.dat.gz', DIM=[200,200], /compress)
;
;
; :CATEGORIES:
;       File IO
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  Mar 1, 2012 3:34:34 PM Adapted from readu_data. Yaswant Pradhan.
;
;-

FUNCTION read_data, filename,     $
          STRUCTURE=struct,       $
          DATA_START=data_start,  $
          DIMENSION=dim,          $
          TYPE=type,              $
          QUIET=quiet,            $
          AUTOMATIC=automatic,    $
          GET_DIMENSION=get_dims, $
          _REF_EXTRA=ex


  ; Parse Argumants:
  syntax =' Result = READ_DATA( Filename [,STRUCTURE=structure]'          + $
          ' [,DATA_START=value] [,/AUTOMATIC] [,GET_DIMENSION=variable]'  + $
          ' [,DIMENSION=Value|Array] [,Type=Value|String] [,/COMPRESS]'   + $
          ' [,BUFSIZE={0 | 1 | Value>512}] [,/DELETE] [,/F77_UNFORMATTED]'+ $
          ' [,/NOEXPAND_PATH] [,/SWAP_ENDIAN] [,/SWAP_IF_BIG_ENDIAN]'     + $
          ' [,/SWAP_IF_LITTLE_ENDIAN] [,/VAX_FLOAT] [,/XDR] [,/QUIET])'

  if (N_PARAMS() lt 1) then message,'Missing Filename'+STRING(10b)+syntax

  if ~(FILE_TEST(filename)) then message,"'"+filename+"' doesnot exist."


  ; Parse Keywords
  ; ---------------------------------------------------------------------------
  ; Check if any bytes to skip from begining of record, def:0
  skip = KEYWORD_SET(data_start) ? data_start : 0
  dim  = KEYWORD_SET(dim) ? dim : 1                 ; dimension/length of data
  verb = ~KEYWORD_SET(quiet)                        ; verbose mode


  ; Warn for compressed file error message
  ; ---------------------------------------------------------------------------
  gz   = STRCMP(file_suffix(filename),'gz',/FOLD) ; compressed file?
  gzk  = 0b               ; initialise value for compress keyword
  nref = N_ELEMENTS(ex)

  if (nref gt 0) then begin
      ex = STRUPCASE(ex)
      for i=0,nref-1 do gzk = (gzk > STREGEX(ex[i],'COMP',/BOOL))
  endif

  if (gz gt gzk) then $
    print,'** Wrning! Looks like a compressed file. Hint: Use /COMPRESS'

  ; Check if a structure template is provided to read the data
  ; ---------------------------------------------------------------------------
  if KEYWORD_SET(struct) then begin
      tc = SIZE(struct,/TYPE)
      if (tc ne 8) then message,'Not a valid structure.'
      type = 'STRUCT'
  endif


  ; Get data typecode, def: 4 (float)
  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if KEYWORD_SET(type) then begin
      type = STRUPCASE(STRTRIM(type,2))
      if (STREGEX(type,'BYT',/BOOL)>STRMATCH(type,'1')) then tc =  1
      if (STREGEX(type,'INT',/BOOL)>STRMATCH(type,'2')) then tc =  2
      if (STREGEX(type,'LON',/BOOL)>STRMATCH(type,'3')) then tc =  3
      if (STREGEX(type,'FLO',/BOOL)>STRMATCH(type,'4')) then tc =  4
      if (STREGEX(type,'FLT',/BOOL)>STRMATCH(type,'4')) then tc =  4
      if (STREGEX(type,'DOU',/BOOL)>STRMATCH(type,'5')) then tc =  5
      if (STREGEX(type,'DBL',/BOOL)>STRMATCH(type,'5')) then tc =  5
      if (STREGEX(type,'COM',/BOOL)>STRMATCH(type,'6')) then tc =  6
      if (STREGEX(type,'STRI',/BOOL)>STRMATCH(type,'7')) then tc = 7
      if (STREGEX(type,'DCOM',/BOOL)>STRMATCH(type,'9')) then tc = 9
      if (STREGEX(type,'UINT',/BOOL)>STRMATCH(type,'12')) then tc = 12
      if (STREGEX(type,'ULON',/BOOL)>STRMATCH(type,'13')) then tc = 13
      if (STREGEX(type,'LONG6',/BOOL)>STRMATCH(type,'14')) then tc = 14
      if (STREGEX(type,'ULONG6',/BOOL)>STRMATCH(type,'15')) then tc = 15
  endif else tc = 4


  ; Define data array based on typecode (tc)
  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  case tc of
      1 : A = BYTARR(dim)
      2 : A = INTARR(dim)
      3 : A = LONARR(dim)
      4 : A = FLTARR(dim)
      5 : A = DBLARR(dim)
      6 : A = COMPLEXARR(dim)
      7 : A = STRARR(dim)
      8 : A = REPLICATE(struct,dim)
      9 : A = DCOMPLEXARR(dim)
      12: A = UINTARR(dim)
      13: A = ULONARR(dim)
      14: A = LON64ARR(dim)
      15: A = ULON64ARR(dim)
      else: message,'Unrecognised data type.'
  endcase


  ; Read data
  ; ---------------------------------------------------------------------------
  if verb then print,' Reading: '+ filename

  on_ioerror, BAD_DATA              ; Declare error label
  OPENR, lun, filename, /get_lun, _EXTRA=ex

  ; Experimental: Automatically update structure dimension read from first record
  ; This assumes that the first record is stored as unsigned long (4byte).
  ; Dimension will be only updated if DIMENSION keyword is absent or less than 2.
  if (KEYWORD_SET(automatic) and tc eq 8) then begin
      if (SIZE(A,/DIMENSIONS) lt 2) then begin
          nrecs = 0ul
          READU, lun, nrecs
          if verb then PRINT,' Updated dim: ',nrecs
          A = REPLICATE(A, nrecs)
      endif
  endif

  POINT_LUN, lun, skip              ; Skip byes from start of data
  READU, lun, A                     ; Read the data array
  goto, GOOD_DATA                   ; Clean up and return

BAD_DATA: PRINT, !err_string        ; Exception label. Print error message
GOOD_DATA: FREE_LUN, lun            ; Close and free the input/output unit
  get_dims = SIZE(A, /DIMENSIONS)

  RETURN, A                         ; Return result. undefined with error

END
