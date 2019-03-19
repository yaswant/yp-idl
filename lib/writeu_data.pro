;+
; NAME:
;     writeu_data
;
; PURPOSE:
;     The WRITEU_DATA procedure writes unformatted binary data from an
;     expression into a file. This procedure performs a direct transfer
;     with no processing of any kind being done to the data. This procedure
;     uses IDL's WRITEU routine, but the IO error is hadled more efficiently
;
; SYNTAX:
;     WRITEU_DATA, Data, Filename [, /APPEND | , /COMPRESS] [, /DELETE]
;                  [, BUFSIZE={0 | 1 | value>512}] [, ERROR=variable] [,/FORCE]
;                  [, /F77_UNFORMATTED] [, /GET_LUN] [, /MORE]
;                  [, /NOEXPAND_PATH] [, /STDIO] [, /SWAP_ENDIAN]
;                  [, /SWAP_IF_BIG_ENDIAN] [, /SWAP_IF_LITTLE_ENDIAN]
;                  [, /VAX_FLOAT] [, WIDTH=value] [, /XDR]
;
; ARGUMENTS:
;     Data (IN) - expression holding unformatted binary data
;     Filename (IN: String) - Input filename to put the data in
;
; KEYWORDS:
; Inherited keywords from OPENW (See IDL help)
;   /OVERWRITE - Overwrites existing file.
;   /APPEND - Set this keyword to open the file with the file pointer at the
;             end of the file ready for data to be appended. Normally, the file
;             is opened with the file pointer at the beginning of the file.
;             Under UNIX, use of APPEND prevents OPENW from truncating existing
;             file contents. The APPEND and COMPRESS keywords are mutually
;             exclusive and cannot be specified together.
;   BUFSIZE (IN:Value)- Set this keyword to a value greater than 512 to specify
;             the size of the I/O buffer (in bytes) used when reading and
;             writing files. Setting BUFSIZE=1 (or any other value less than
;             512) sets the buffer to the default size, which is platform-
;             specific. Set BUFSIZE=0 to disable I/O buffering.
;             Note that the buffer size is only changeable when reading and
;             writing stream files. Under UNIX, the RAWIO keyword must not be
;             set. Also note that the system stdio may choose to ignore the
;             buffer size setting.
;   /COMPRESS- If COMPRESS is set, IDL reads and writes all data to the file in
;             the standard GZIP format. COMPRESS cannot be used with the APPEND
;             keyword.
;   /DELETE -  Set this keyword to delete the file when it is closed.
;   ERROR (IN:Variable) - A named variable to place the error status in. If an
;             error occurs in the attempt to open File, IDL normally takes the
;             error handling action defined by the ON_ERROR and/or ON_IOERROR
;             procedures. OPEN always returns to the caller without generating
;             an error message when ERROR is present.
;             A nonzero error status indicates that an error occurred.
;   /FORCE - Force writing output file if path does not exist.
;   /F77_UNFORMATTED - Unformatted variable-length record files produced by
;             FORTRAN programs running on platforms that use stream files
;             (UNIX and Microsoft Windows) contain extra information along with
;             the data in order to allow the data to be properly recovered.
;             This method is necessary because FORTRAN input/output is based on
;             record-oriented files, while files that are simple byte streams do
;             not impose any record structure. Set the F77_UNFORMATTED keyword
;             to read and write this extra information in the same manner as
;             f77(1), so that data can be processed by both IDL and FORTRAN.
;             See Reading and Writing FORTRAN Data (Application Programming) for
;             further details.
;             Note: On 64-bit machines, some Fortran compilers will insert
;             record markers that are 64-bit integers instead of the standard
;             32-bit integers. When reading FORTRAN data, IDL will attempt to
;             recognize the presence of 64-bit record markers and switch to the
;             appropriate format. When writing unformatted Fortran files, IDL
;             will continue to use 32-bit record markers.
;       NOTE: /F77 and /COMPRESS are conflicting keywords, therefore should not
;             be used together.
;   /SWAP_ENDIAN- Set this keyword to swap byte ordering for multi-byte data
;             when performing binary I/O on the specified file. This is useful
;             when accessing files also used by another system with byte
;             ordering different than that of the current host.
;   /SWAP_IF_BIG_ENDIAN - Setting this keyword is equivalent to setting
;             SWAP_ENDIAN; it only takes effect if the current system has #
;             big endian byte ordering. This keyword does not refer to the byte
;             ordering of the input data, but to the computer hardware.
;   /SWAP_IF_LITTLE_ENDIAN - Setting this keyword is equivalent to setting
;             SWAP_ENDIAN; it only takes effect if the current system has
;             little endian byte ordering. This keyword does not refer to the
;             byte ordering of the input data, but to the computer hardware.
;   /VAX_FLOAT - The opened file contains VAX format floating point values.
;             This keyword implies little endian byte ordering for all data
;             contained in the file, and supersedes any setting of the
;             SWAP_ENDIAN, SWAP_IF_BIG_ENDIAN, or SWAP_IF_LITTLE_ENDIAN
;             keywords. The default setting for this keyword is FALSE.
;   WIDTH (IN:Value) - The desired output width. If no output width is
;             specified, IDL uses the following rules to determine where to
;             break lines:
;             * If the output file is a terminal, the terminal width is used.
;             * Otherwise, a default of 80 columns is used.
;   /XDR  - Set this keyword to open the file for unformatted XDR (eXternal
;             Data Representation) I/O via the READU and WRITEU procedures.
;             Use XDR to make binary data portable between different machine
;             architectures by reading and writing all data in a standard
;             format. When a file is open for XDR access, the only I/O data
;             transfer procedures that can be used with it are READU and WRITEU.
;             XDR is described in Portable Unformatted Input/Output
;             (Application Programming).
;
; OUTPUT:
;     A file as input "Filename"
;
;EXAMPLE: To write a unformatted fltsrr(200,200) to a filename and compress it
;   IDL> writeu_data, fltarr(200,200), "filename",/compress
;   File suffix modified for clarity <filename.gz>
;
; $Id: WRITEU_DATA.pro,v 1.0 2010-02-11 16:36:53 yaswant Exp $
; WRITEU_DATA.pro Yaswant Pradhan
; Last modification:
; 11/02/2010 16:36:44 - Written. YP
; 10/08/2010 Added OVERWRITE keyword. YP
; 31/01/2011 Added FORCE keyword. YP
; 11/03/2011
;-

PRO writeu_data, Data, Filename,        $
                 OVERWRITE=overwrite,   $
                 FORCE=force,           $
                 _REF_EXTRA=ex

; -----------------------------------------------------------------------------
  syntax =' WRITEU_DATA, Data, Filename [,/APPEND | ,/COMPRESS]'+string(10b)+$
          '  [,BUFSIZE={0 | 1 | value>512}] [,/DELETE]'+string(10b)+$
          '  [,ERROR=variable] [,/F77_UNFORMATTED] [,/FORCE]'+string(10b)+$
          '  [,/GET_LUN] [,/MORE] [,/NOEXPAND_PATH] [,/STDIO]'+string(10b)+$
          '  [,/SWAP_ENDIAN] [,/SWAP_IF_BIG_ENDIAN]'+string(10b)+$
          '  [,/SWAP_IF_LITTLE_ENDIAN] [,/VAX_FLOAT] [,WIDTH=value] [,/XDR]'

  if n_params() lt 2 then begin
      print, 'Insufficient arguments.'+string(10b)+syntax
      return
  endif


  ex  = n_elements(ex) ne 0 ? strupcase(ex) : ' '

  ; Initialise keyword parameters
  appendkey =(compress = -1)
  for i=0,n_elements(ex)-1 do begin
      appendkey = appendkey > stregex(ex[i],'APP')
      compress  = compress > stregex(ex[i],'COMP')
  endfor


  if compress gt (-1) and file_suffix(Filename) ne 'gz' then begin
      Filename = Filename+'.gz'
      print,' File suffix modified for brevity <'+Filename+'>'
  endif


  ; Check if input file exists.
  if (file_test(Filename) and appendkey eq (-1) and $
      ~keyword_set(overwrite)) then begin

      opt = ' '
      read,' A filename <'+Filename+$
           '> already exists. Replace existing file? (Yes | any key): ',opt

      if (stregex(opt,'y',/FOLD_CASE) eq (-1)) then goto, FINISH $
      else print,' Replacing file with new data.'
  endif

  ; Check if output directory exists.
  if KEYWORD_SET(force) then begin
      if ~FILE_TEST(FILE_DIRNAME(Filename),/DIR) $
      then FILE_MKDIR,FILE_DIRNAME(Filename)
  endif

  ; Declare error label.
  on_ioerror, BAD_DATA

  ; Use the GET_LUN keyword to allocate a logical file unit.
  ; Write the data array
  openw,  lun, Filename, /GET_LUN, _EXTRA=ex
  writeu, lun, Data

  ; Clean up and return.
  goto, GOOD_DATA

; Exception label. Print the error message.
BAD_DATA:   print, !err_string

; Close and free the input/output unit.
GOOD_DATA:  free_lun, lun

FINISH:

END
