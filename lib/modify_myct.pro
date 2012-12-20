PRO modify_myct,  CtNumber,           $
                  CtName,             $
                  FILE=myColourTable, $
                  AddPalette=addLUT,  $
                  R=r, G=g, B=b,      $
                  WATCH=watch

;NAME: 
;     MODIFY_MYCT
;PURPOSE:
;     The MODIFY_MYCT procedure updates the color table file mycolors.tbl, 
;     located at E:\yp_idl\lib\ctbl\mycolors.tbl
;     or a user-designated file with a new, or modified, colortable.
;
;SYNTAX:
;     MODIFY_MYCT, CtNumber, CtName [,FILE=filename] ,AddPalette=filename | 
;                 (,R=vector ,G=vector ,B=vector) [,/WATCH]
;
;ARGUMENTS;
;     CtNumber - The index of the table to be updated, numbered from 0 to 255. 
;                If the specified entry is greater than the next available 
;                location in the table, the entry will be added to the table 
;                in the available location rather than the index specified by 
;                Itab. On return, Itab contains the index for the location that
;                was modified or extended. The modified table can be then be 
;                loaded with the IDL command: LOADMYCT, CtNumber.
;     CtName -   A string, up to 32 characters long, that contains the name for
;                the new color table.
;     AddPalette - Set this keyword to the name of a [R,G,B] color pallete file
;                   (3 column ascii file 256 index + 2 header lines)
;     R- A 256-element vector that contains the values for the red colortable.
;     G- A 256-element vector that contains the values for the green colortable.
;     B- A 256-element vector that contains the values for the blue colortable.
;  Note: Keywords [R,G,B] will override [AddPalette]
;  
;KEYWORDS:
;     FILE -  Set this keyword to the name of a colortable file to be modified 
;             instead of the file mycolors.tbl
;     WATCH - see available LUT indexes in the colour table
;     
;EXAMPLES:
;   To add a 256 grey-scale pallete
;     IDL> MODIFY_MYCT, 54, 'A New Greyscale Palette', R=findgen(256), 
;          G=findgen(256), B=findgen(256)
;   To add a predefined RGB palette from a text file (RGBfile.txt)
;     IDL> MODIFY_MYCT, 55, 'New Palette from File', AddPalette='RGBfile.txt'

; $Id: MODIFY_MYCT.pro,v 1.0 03/04/2008 12:15 yaswant Exp $
; MODIFY_MYCT.pro Yaswant Pradhan UK Met Office, (c) Crown Copyright
; Last modIFication: Apr 08
;-


; -----------------------------------------------------------------------------
if ~keyword_set(myColourTable) then begin
    which, 'mycolors.tbl', RES=coltab
    myColourTable = coltab
endif

; -----------------------------------------------------------------------------
;Change here
proceed  = ( keyword_set(addLUT) or $
            ( keyword_set(r) and keyword_set(g) and keyword_set(b) )) ? 1b : 0b
fromFile = keyword_set(addLUT) ? 1b : 0b
fromRGB  = (keyword_set(r) and keyword_set(g) and keyword_set(b)) ? 1b : 0b

; -----------------------------------------------------------------------------

watch = keyword_set(watch)
if watch then begin
    loadct,file=myColourTable
    return
endif
    
if (n_params() lt 2 and not proceed) then begin
    print,'Syntax: MODIFY_MYCT ,CtNumber ,CtName [,FILE=filename] '+$
          '[[,AddPalette=filename] | [,R=vector ,G=vector ,B=vector]] [,/WATCH]'
    return 
endif
     
        
if (fromFile and not fromRGB)then begin
    nlines  = file_lines(addLUT);total number of lines
    hlines  = 2 ;number of input header lines
    dlines  = nlines-hlines ;data lines to read in
    openr,lun,addLUT,/get_lun
    header  = strarr(hlines)    
    fmt     = '(3(I0,X),I0)'
    readf,lun,header    ;chuck 2 header lines from the new input color table
    
    index=(r1=(g1=(b1=intarr(256))))
    ti=(tr=(tg=(tb=0)))
    
    for i=0,dlines-1 do begin
        readf,lun,ti,tr,tg,tb,format=fmt
        index[i]=ti
        r1[i] = tr
        g1[i] = tg
        b1[i] = tb
    endfor    
    free_lun,lun

endif
    
if fromRGB then begin
    r1=(g1=(b1=intarr(256)))
    nr  = n_elements(r)
    ng  = n_elements(g)
    nb  = n_elements(b)
    if (nr gt 256 or ng gt 256 or nb gt 256) then begin
        print,'R G B vector length should be less than 256'
        retall
    endif else begin
        r1[0:nr-1] = r
        g1[0:ng-1] = g
        b1[0:nb-1] = b
    endelse    
endif
    
modifyct, CtNumber, CtName, r1, g1, b1, file=myColourTable    
END