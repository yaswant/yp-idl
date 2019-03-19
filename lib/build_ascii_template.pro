pro build_ascii_template, FILE=file, FHEADER=fheader, $
                          FIELD_NAMES=field_names, SAVE_TFILE=stf

;+
; Name:     
;           BUILD_ASCII_TEMPLATE
; Purpose:  
;           Build an ASCII template for a data file which can be used alongside READ_ASCII. 
;           This is particularly very useful while reading a large number of formatted 
;           ascii files in loop.
; Syntax:   
;           build_ascii_template [,FILE=String] [,/FHEADER] [,FIELD_NAMES=Strarr] [,SAVE_TFILE=String]
; Arguments:
;           None
; Keywords: 
;           File (IN:String) Input ascii file name
;           /FHEADER  Read field names from input file (1st row)
;           FIELD_NAMES (IN:Strarr) Field names 
;           SAVE_TFILE (IN:String) Save the template as an IDL function file 
;                                 that can be used later
; Example:  
;           IDL> build_ascii_template ,FILE='myFile.csv' ,/FHEAD ,SAVE_TFILE='myTemplate'
;           This will save the template as an IDL function myTemplate.pro which can be called as
;           IDL> data = read_ascii( 'myFile.csv', Template=myTemplate() )
; Output:   
;           ASCII Template printed to IDL stdout and optionally saved as an IDL function
; Warning:  
;           Be careful when providing the field_names as a variable or reading from 
;           the input file - Check there are no illegal character strings 
;           (e.g., . / \ * ! # @, etc) in the Fieldnames array.
; Author: Yaswant Pradhan, University of Plymouth, Feb 06
; Last modified: 31/07/2009 Rewritten to save structure to a file (YP)
;-

; ---------------------------------------------------------------------------------
  t     = keyword_set(file) ? ascii_template(file) : ascii_template()
  tags  = tag_names(t)
  n     = n_tags(t)
    
  template    = strarr(n+1)
  template[0] = 'template={$'
  
  print,'template={$'
  for i=0,n-1 do begin
    
    if size(t.(i),/type) eq 7 then s="'"+t.(i)+"'" $
    else if size(t.(i),/type) eq 1 then s=string(fix(byte(t.(i))))+"b" $
    else s=strtrim(t.(i),2)
    
; Work out how the fieldnames should be created
    if( strcmp(tags[i],'FIELDNAMES',/fold_case) ) then begin
; i- Fieldnames from a given string array 
      if( keyword_set(field_names) and n_elements(field_names) eq t.FIELDCOUNT )then begin
        s = "'"+field_names+"'"
      endif
; ii- Fieldnames from the input ascii file's first row; overrides option i
      if( keyword_set(fheader) and keyword_set(file) )then begin
        dummy   = ' '
        openr,1, file
        readf,1, dummy
        close,1
        field_names = strsplit(dummy, t.DELIMITER, /extract)
        s = "'"+strtrim(field_names,2)+"'"
      endif      
    endif
    
; Add commas to string arrays
    s=strjoin(s,',')
    if n_elements(t.(i)) gt 1 then s='['+s+']'
    if (strcmp(s,'NaN',/fold_case) ) then s='!values.f_NaN'
    
; Print tagnames and elements to stdout
    print,' ',tags[i],' : ',s,(i lt n-1)?',$':'}'

; Store structure values in a string array in order to save as a template function
    template[i+1] = (i lt n-1) ? tags[i]+' : '+s+',$' : $
                                 tags[i]+' : '+s+'}'   
  endfor


; ---------------------------------------------------------------------------------
; Save Ascii tamplate as an IDL function; once build, the function can be called 
; from any IDL procedure 
; ---------------------------------------------------------------------------------
  if keyword_set(stf) then begin    
    
    temp      = strtrim(stf,2)
    temp_file = temp+'.pro'
    
    openw,1 , temp_file
    printf,1, 'function '+strtrim(string(stf),2)
    printf,1, ';+'
    printf,1, '; Name:    '+temp
    printf,1, '; Purpose: Ascii template created using build_ascii_template to read user-specific data.'
    printf,1, '; Syntax:  asciiTemplate = '+temp+'()'
    printf,1, '; Usage:   data = read_ascii(ASCII_File, template=asciiTemplate )  OR'+string(10b)+$
              ';          data = read_ascii(ASCII_File, template='+temp+'()'
    printf,1, '; Created: '+systime(/utc)
    printf,1, '; Questions: Yaswant.Pradhan@metoffice.gov.uk'
    printf,1, ';-'+string(10b)
    
    for i=0,n do begin
      printf,1, template[i]
    endfor
    printf,1, 'return, template'
    printf,1, 'end'
    close,1
    
  endif
  
end