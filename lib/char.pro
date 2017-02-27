;+
; :NAME:
;     char
;
; :PURPOSE:
;     Translates and draw device independent math,
;     special characters, and symbols. 
;     Note: Some characters are not available in the IDL font table - in 
;     those cases either the letter names are displayed or a tweaked
;     version (not perfect) of the characters are displayed. 
;     
;
; :SYNTAX:
;     Result = char( LetterName [,/HELP] )
;
;  :PARAMS:
;    LetterName (IN:String) Letter or symbol name, CASE SENSITIVE.
;
;
;  :KEYWORDS:
;    HELP - Plots list of letteres, sybols and special characters 
;
; :REQUIRES:
;     
;
; :EXAMPLES:
;   IDL> h = char(/help)
;   
; - For math type symbols follow latex rules without the backslash (\),
;   for example to output \nabla
;   IDL> sym = char('nabla')
; 
; - Similarly, for ISO 8859-1 symbols and characters, standard HTML 
;   rule can be applied without the (&) and (;), for example, to 
;   output &ntilde; as in El Nino in a plot title:
;   IDL> plot, indgen(10), psym=4, title='El Ni'+char('ntilde')+'o'
;   IDL> xyouts, 0.9,0.1, char('copy')+' Met Office', align=1,/normal
;   
; - Greek alphabets:
;   IDL> plot, indgen(10), psym=4, title=char('tau')+'!d550!n'
;
; :CATEGORIES:
;     String manipulation
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  Jan 28, 2012 4:45:46 PM Created. Yaswant Pradhan.
;
;-


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Example/help procedure
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PRO char_help

  Compile_Opt hidden
    
; The 24 Greek letters.
  small   = [ 'alpha','beta','gamma','delta','epsilon','zeta',  $
              'eta','theta','iota','kappa','lambda','mu',       $
              'nu','xi','omicron','pi','rho','sigma','tau',     $
              'upsilon','phi','chi','psi','omega' ]
              
  Capital = [ 'Alpha','Beta','Gamma','Delta','Epsilon','Zeta',  $
              'Eta','Theta','Iota','Kappa','Lambda','Mu',       $
              'Nu','Xi','Omicron','Pi','Rho','Sigma','Tau',     $
              'Upsilon','Phi','Chi','Psi','Omega' ]
; #27
  symbol  = [ 'iexcl','cent','pound','curren','yen','brvbar',   $
              'sect','copy','ordf','laquo','not','shy','reg',   $
              'deg','plusmn','sup2','sup3','micro','para',      $
              'middot','sup1','ordm','raquo','frac14','frac12', $
              'frac34','iquest','dagger','ddagger','natural',   $
              'flat','sharp' ]
; #31
  special1= [ 'Agrave','Aacute','Acirc','Atilde','Auml','Aring',$
              'AElig','Ccedil','Egrave','Eacute','Ecirc','Euml',$
              'Igrave','Iacute','Icirc','Iuml','ETH','Ntilde',  $
              'Ograve','Oacute','Ocirc','Otilde','Ouml',        $
              'Oslash','Ugrave','Uacute','Ucirc','Uuml',        $
              'Yacute','THORN','szlig']
  
  special2= [ 'agrave','aacute','acirc','atilde','auml','aring',$
              'aelig','ccedil','egrave','eacute','ecirc','euml',$
              'igrave','iacute','icirc','iuml','eth','ntilde',  $
              'ograve','oacute','ocirc','otilde','ouml',        $
              'oslash','ugrave','uacute','ucirc','uuml',        $
              'yacute','thorn','yuml']
              
; #61                
  math    = [ 'aleph','Im','Re','wp','sum','prod','varpi',      $
              'vartheta','varphi','varsigma','partial','oplus', $
              'odot','otimes','cdot','forall','times','div',    $
              'pm','mp','geq','leq','neq','sim','approx',       $
              'cong','equiv','propto','circ','bullet','sqrt',   $
              'surd','ldots','infty','exists','S','nabla',      $
              'hence','notsubset','subset','subseteq','supset', $
              'supseteq','in','notin','Box','oint','cup','cap', $
              '|','bot','angle','lceil','lfloor','rceil',       $
              'rfloor','club','spade','heart','diamond',        $
              'copyright' ]          
; #7        
  arr1  =   ['leftarrow','rightarrow','leftrightarrow', $
             'uparrow','downarrow','updownarrow','int']
  arr2  =   ['Leftarrow','Rightarrow','Leftrightarrow', $
              'Uparrow','Downarrow','Updownarrow','Int']
    
; Output positions:
  nrow  = 35.
  ngrk  = N_ELEMENTS(small)
  nsym  = N_ELEMENTS(symbol)
  nspl  = N_ELEMENTS(special1)
  nmath = N_ELEMENTS(math)
  narr  = N_ELEMENTS(arr1) 
  
  x     = [0.01, 0.20, 0.4, 0.57, 0.76]
  y     = Reverse((Indgen(nrow) + 0) * (1.0 / (nrow+1)))   
  grk   = STRMID(small,0,1)+'/'+Capital  
  spl   = STRMID(special2,0,1)+'/'+special1
  arr   = STRMID(arr1,0,1)+'/'+arr2
  spl[6]      = 'ae/AElig'
  spl[16]     = 'eth/ETH'
  spl[29:30]  = ['thorn/THORN','yuml/szlig']
    
    
; Create a window, if needed:
  IF (!D.Flags AND 256) NE 0 THEN BEGIN
    thisWindow = !D.Window
    Window, XSIZE=900, YSIZE=700, /Free
    ERASE, COLOR=255
  ENDIF
    
; Output the letters:  
  !P.COLOR=0  
  !P.CHARSIZE = (!D.NAME EQ 'PS') ? 1.2 : 2
  XYOUTS, x[0], 0.97, 'GREEK',/NORMAL,COLOR=0, CHARTHICK=2   
  XYOUTS, x[1], 0.97, 'SPECIAL',/NORMAL,COLOR=0, CHARTHICK=2
  XYOUTS, x[2], 0.97, 'SYMBOLS',/NORMAL,COLOR=0, CHARTHICK=2
  XYOUTS, x[3], 0.97, 'MATH',/NORMAL,COLOR=0, CHARTHICK=2
  
  !P.CHARTHICK=1
   
  FOR j=0,nrow-2 DO BEGIN
    
  ; Greek:
    IF (j LE ngrk-1) THEN BEGIN
      XYOUTS, x[0],y[j],/NORMAL, grk[j] + ': ' + $
              char(small[j]) + char(Capital[j])              
    ENDIF
    
  ; Special
    IF (j LE nspl-1) THEN BEGIN
      XYOUTS, x[1],y[j],/NORMAL, spl[j] + ': ' + $
              char(special2[j]) + char(special1[j])
    ENDIF

  ; Symbol:    
    IF (j LE nsym-1) THEN BEGIN
      XYOUTS, x[2],y[j],/NORMAL, symbol[j] + ': ' + char(symbol[j])
    ENDIF
    
  ; Math:    
    XYOUTS, x[3],y[j], /NORMAL , math[j] +': '+ char(math[j])         
    
    IF (j LE (nmath-nrow)) THEN BEGIN      
      XYOUTS, x[4],y[j],/NORMAL, math[j+nrow-1] +': '+ char(math[j+nrow-1])
    ENDIF ELSE BEGIN  
  ; Arrows:
      XYOUTS, x[4],y[j],/NORMAL, arr[j-((nmath-nrow)+1)] + ': ' + $
              char(arr1[j-((nmath-nrow)+1)]) + char(arr2[j-((nmath-nrow)+1)])
              
    ENDELSE
    
  ENDFOR
    
; Restore the users window:
  IF N_Elements(thisWindow) NE 0 THEN BEGIN
    IF thisWindow GE 0 THEN WSet, thisWindow
  ENDIF    
END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Main Function 
; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION char, letter, HELP=help

  Compile_Opt idl2
    
; Return to caller on error.
  ON_Error, 2
    
; Do you wish to see an example?
  IF KEYWORD_SET(help) THEN BEGIN
    decomp
    loadct, 0
    char_help
    RETURN, ""
  ENDIF

; Parse input and predefined font style
  syntax = 'Result = char( LetterName [,/HELP] )'
  if N_PARAMS() lt 1 and ~KEYWORD_SET(help) then message,syntax
  letter = STRTRIM(letter,2)
  hershey = !P.FONT eq -1

; Duplicate letter meanings
  if strmatch(letter,'therefore',/FOLD_CASE) then letter='hence'    
  if strmatch(letter,'larr') then letter='leftarrow'
  if strmatch(letter,'rarr') then letter='rightarrow'
  if strmatch(letter,'darr') then letter='downarrow'
  if strmatch(letter,'uarr') then letter='uparrow'
  if strmatch(letter,'udrr') then letter='updownarrow'
  if strmatch(letter,'lrarr') then letter='leftrightarrow'
  if strmatch(letter,'Larr') then letter='Leftarrow'
  if strmatch(letter,'Rarr') then letter='Rightarrow'
  if strmatch(letter,'Darr') then letter='Downarrow'
  if strmatch(letter,'Uarr') then letter='Uparrow'
  if strmatch(letter,'UDrr') then letter='Updownarrow'
  if strmatch(letter,'LRarr') then letter='Leftrightarrow'
  
; Make sure ISOLATIN1 encoding is turned on for PS device.
  IF !D.NAME EQ 'PS' THEN DEVICE, /ISOLATIN1


; Get the characters/symbols for the input letter:         
  CASE letter OF

; a. Greek alphabets:  
    'Alpha':  ret = (hershey ? '!4' : '!9') +STRING("101B)+'!X'
    'alpha':  ret = (hershey ? '!4' : '!9') +STRING("141B)+'!X'
    'Beta':   ret = (hershey ? '!4' : '!9') +STRING("102B)+'!X'
    'beta':   ret = (hershey ? '!4' : '!9') +STRING("142B)+'!X'
    'Gamma':  ret = (hershey ? '!4'+ STRING("103B) : '!9'+STRING("107B)) +'!X'
    'gamma':  ret = (hershey ? '!4'+ STRING("143B) : '!9'+STRING("147B)) +'!X'
    'Delta':  ret = (hershey ? '!4' : '!9') +STRING("104B)+'!X'
    'delta':  ret = (hershey ? '!4' : '!9') +STRING("144B)+'!X'
    'Epsilon':ret = (hershey ? '!4' : '!9') +STRING("105B)+'!X'
    'epsilon':ret = (hershey ? '!4' : '!9') +STRING("145B)+'!X'
    'Zeta':   ret = (hershey ? '!4'+ STRING("106B) : '!9'+STRING("132B)) +'!X'
    'zeta':   ret = (hershey ? '!4'+ STRING("146B) : '!9'+STRING("172B)) +'!X'
    'Eta':    ret = (hershey ? '!4'+ STRING("107B) : '!9'+STRING("110B)) +'!X'
    'eta':    ret = (hershey ? '!4'+ STRING("147B) : '!9'+STRING("150B)) +'!X'
    'Theta':  ret = (hershey ? '!4'+ STRING("110B) : '!9'+STRING("121B)) +'!X'
    'theta':  ret = (hershey ? '!4'+ STRING("150B) : '!9'+STRING("161B)) +'!X'
    'Iota':   ret = (hershey ? '!4' : '!9') +STRING("111B)+'!X'
    'iota':   ret = (hershey ? '!4' : '!9') +STRING("151B)+'!X'
    'Kappa':  ret = (hershey ? '!4'+ STRING("112B) : '!9'+STRING("113B)) +'!X'
    'kappa':  ret = (hershey ? '!4'+ STRING("152B) : '!9'+STRING("153B)) +'!X'
    'Lambda': ret = (hershey ? '!4'+ STRING("113B) : '!9'+STRING("114B)) +'!X'
    'lambda': ret = (hershey ? '!4'+ STRING("153B) : '!9'+STRING("154B)) +'!X'
    'Mu':     ret = (hershey ? '!4'+ STRING("114B) : '!9'+STRING("115B)) +'!X'
    'mu':     ret = (hershey ? '!4'+ STRING("154B) : '!9'+STRING("155B)) +'!X'
    'Nu':     ret = (hershey ? '!4'+ STRING("115B) : '!9'+STRING("116B)) +'!X'
    'nu':     ret = (hershey ? '!4'+ STRING("155B) : '!9'+STRING("156B)) +'!X'
    'Xi':     ret = (hershey ? '!4'+ STRING("116B) : '!9'+STRING("130B)) +'!X'
    'xi':     ret = (hershey ? '!4'+ STRING("156B) : '!9'+STRING("170B)) +'!X'
    'Omicron':ret = (hershey ? '!4' : '!9') +STRING("117B)+'!X'
    'omicron':ret = (hershey ? '!4' : '!9') +STRING("157B)+'!X'
    'Pi':     ret = (hershey ? '!4' : '!9') +STRING("120B)+'!X'
    'pi':     ret = (hershey ? '!4' : '!9') +STRING("160B)+'!X'
    'Rho':    ret = (hershey ? '!4'+ STRING("121B) : '!9'+STRING("122B)) +'!X'
    'rho':    ret = (hershey ? '!4'+ STRING("161B) : '!9'+STRING("162B)) +'!X'
    'Sigma':  ret = (hershey ? '!4'+ STRING("122B) : '!9'+STRING("123B)) +'!X'
    'sigma':  ret = (hershey ? '!4'+ STRING("162B) : '!9'+STRING("163B)) +'!X'
    'Tau':    ret = (hershey ? '!4'+ STRING("123B) : '!9'+STRING("124B)) +'!X'
    'tau':    ret = (hershey ? '!4'+ STRING("163B) : '!9'+STRING("164B)) +'!X'
    'Upsilon':ret = (hershey ? '!4'+ STRING("124B) : '!9'+STRING("125B)) +'!X'
    'upsilon':ret = (hershey ? '!4'+ STRING("164B) : '!9'+STRING("165B)) +'!X'
    'Phi':    ret = (hershey ? '!4'+ STRING("125B) : '!9'+STRING("106B)) +'!X'
    'phi':    ret = (hershey ? '!4'+ STRING("165B) : '!9'+STRING("146B)) +'!X'
    'Chi':    ret = (hershey ? '!4'+ STRING("126B) : '!9'+STRING("103B)) +'!X'
    'chi':    ret = (hershey ? '!4'+ STRING("166B) : '!9'+STRING("143B)) +'!X'
    'Psi':    ret = (hershey ? '!4'+ STRING("127B) : '!9'+STRING("131B)) +'!X'
    'psi':    ret = (hershey ? '!4'+ STRING("167B) : '!9'+STRING("171B)) +'!X'
    'Omega':  ret = (hershey ? '!4'+ STRING("130B) : '!9'+STRING("127B)) +'!X'
    'omega':  ret = (hershey ? '!4'+ STRING("170B) : '!9'+STRING("167B)) +'!X'

; b. Math and special symbols:
    'pm':     ret = (hershey ? '!3' : '!9') +STRING("261B)+'!X'
    'oplus':  ret = (hershey ? '!20'+ STRING("123B) : '!9'+STRING("305B)) +'!X'
    'cdot':   ret = (hershey ? '!3'+ STRING("267B) : '!3' +STRING("267B))+'!X'
    'bullet': ret = (hershey ? '!20'+ STRING("102B) : '!9'+ STRING("267B)) +'!X'
    'forall': ret = ( hershey $
                      ? '!3!S'+STRING("126B)+'!R'+STRING("255B)+'!N!X' $
                      : '!9'+STRING("42B) ) +'!X'
    'Im':     ret = (hershey ? '!15'+ STRING("111B) : '!9'+STRING("301B)) +'!X'
    'Re':     ret = (hershey ? '!15'+ STRING("122B) : '!9'+STRING("302B)) +'!X'
    'circ':   ret = '!9'+ (hershey ? STRING("45B) : STRING("260B)) +'!X'
    'times':  ret = '!9'+ (hershey ? STRING("130B) : STRING("264B)) +'!X'
    'div':    ret = '!9'+ (hershey ? STRING("57B) : STRING("270B)) +'!X'
    'geq':    ret = '!9'+ (hershey ? STRING("142B) : STRING("263B)) +'!X'
    'leq':    ret = '!9'+ (hershey ? STRING("154B) : STRING("243B)) +'!X'
    'neq':    ret = '!9'+ (hershey ? STRING("75B) : STRING("271B)) +'!X'
    'sim':    ret = '!9'+ (hershey ? STRING("101B) : STRING("176B)) +'!X'
    'equiv':  ret = '!9'+ (hershey ? STRING("72B) : STRING("272B)) +'!X'    
    'sqrt':   ret = '!9'+ (hershey ? STRING("123B) : STRING("326B)) +'!X'
    'surd':   ret = '!9'+ (hershey ? STRING("162B) : STRING("326B)) +'!X'
    'propto': ret = '!9'+ (hershey ? STRING("77B) : STRING("265B)) +'!X'
    'infty':  ret = '!9'+ (hershey ? STRING("44B) : STRING("245B)) +'!X'    
    'exists': ret = '!9'+ (hershey ? STRING("105B) : STRING("44B)) +'!X'
    'S':      ret = '!3'+ STRING("247B) +'!X'
    'bot':    ret = '!9'+ (hershey ? STRING("170B) : STRING("136B)) +'!X'
    'Int':    ret = '!9'+ (hershey ? STRING("111B) : $
                           '!S'+string("363b)+'!R!B'+string("365b)+'!N') +'!X'
    'int':    ret = '!9'+ (hershey ? STRING("151B) : STRING("362B)) +'!X'
    'nabla':  ret = '!9'+ (hershey ? STRING("107B) : STRING("321B)) +'!X'
    'hence':  ret = '!9'+ (hershey ? STRING("124B) : STRING("134B)) +'!X'
    'subset': ret = '!9'+ (hershey ? STRING("60B) : STRING("314B)) +'!X'
    'supset': ret = '!9'+ (hershey ? STRING("62B) : STRING("311B)) +'!X'
    'cup':    ret = '!9'+ (hershey ? STRING("61B) : STRING("310B)) +'!X'
    'cap':    ret = '!9'+ (hershey ? STRING("63B) : STRING("307B)) +'!X'
    'angle':  ret = '!9'+ (hershey ? STRING("141B) : STRING("320B)) +'!X'
    'aleph':  ret = '!9'+ (hershey ? STRING("100B) : STRING("300B)) +'!X'
    'club':       ret = '!9'+ (hershey ? STRING("166B) : STRING("247B)) +'!X'
    'spade':      ret = '!9'+ (hershey ? STRING("125B) : STRING("252B)) +'!X'
    'heart':      ret = '!9'+ (hershey ? STRING("165B) : STRING("251B)) +'!X'
    'diamond':    ret = '!9'+ (hershey ? STRING("126B) : STRING("340B)) +'!X'
    'copyright':  ret = '!3'+ STRING("251B) +'!X'
    'leftarrow':  ret = '!9'+ (hershey ? STRING("64B) : STRING("254B)) +'!X'
    'downarrow':  ret = '!9'+ (hershey ? STRING("65B) : STRING("257B)) +'!X'
    'rightarrow': ret = '!9'+ (hershey ? STRING("66B) : STRING("256B)) +'!X'
    'uparrow':    ret = '!9'+ (hershey ? STRING("67B) : STRING("255B)) +'!X'
    'vartheta':   ret = '!9'+ (hershey ? STRING("164B) : STRING("112B)) +'!X'
    'partial':    ret = '!9'+ (hershey ? STRING("144B) : STRING("266B)) +'!X'
    'lrarr':      ret = '!9'+ (hershey $
                              ? '!S'+STRING("64B)+'!R'+STRING("66B)+'!N!X' $
                              : STRING("253B)) +'!X'
    
    'in': ret = '!9'+(hershey ? STRING("145B) : STRING("316B)) +'!X'
    '|' :   ret = (hershey ? '!9'+ STRING("43B) : '||') +'!X'
    'mp':   ret = ( hershey $
                    ? '!9'+ STRING("55B) $
                    : '!9!S!U'+STRING("55B)+'!R'+STRING("53B) ) +'!X'
    'wp':   ret = (hershey ? 'wp' : '!9'+STRING("303B)) +'!X'
    'sum':  ret = (hershey ? '!4'+ STRING("122B) : '!9'+STRING("345B)) +'!X'
    'neg':  ret = (hershey ? '!3'+STRING("254B) : '!9'+STRING("330B)) +'!X'
    'Box':  ret = (hershey ? '!9'+ STRING("102B) : 'Box') +'!X'
    'oint': ret = (hershey ? '!9'+ STRING("112B) $
                           : '!9!S'+STRING("362B)+'!R!E!3'+STRING("117B)) +'!X'
    'flat': ret = (hershey ? '!20'+ STRING("51B) : 'flat') +'!X'
    'odot': ret = (hershey ? '!9'+ STRING("156B) : 'odot') +'!X'    
    'prod': ret = (hershey ? 'prod' : '!9'+STRING("325B)) +'!X'
    'cong': ret = (hershey ? '!9!S'+STRING("101B)+'!R!B!4'+STRING("75B) $
                           : '!9'+STRING("100B)) +'!X'
    'ldots':  ret = (hershey ? '...' : '!9'+STRING("274B)) +'!X'
    'varpi':  ret = (hershey ? 'varpi' : '!9'+STRING("166B)) +'!X'
    'sharp':  ret = (hershey ? '!20'+ STRING("57B) : 'sharp') +'!X'
    'varphi': ret = (hershey ? '!9'+ STRING("120B) : 'varphi') +'!X'
    'notin':  ret = (hershey ? '!9!S'+STRING("145B)+'!R!4'+STRING("57B) $
                             : '!9'+STRING("317B)) +'!X'
    'lceil':  ret = (hershey ? 'lceil' : '!9'+STRING("351B)) +'!X'
    'lfloor': ret = (hershey ? 'lfloor' : '!9'+STRING("353B)) +'!X'
    'rceil':  ret = (hershey ? 'rceil' : '!9'+STRING("371B)) +'!X'
    'rfloor': ret = (hershey ? 'rfloor' : '!9'+STRING("373B)) +'!X'    
    'dagger': ret = (hershey ? '!9'+ STRING("117B) : 'dagger') +'!X'
    
    'otimes': ret = (hershey ? '!9!S'+STRING("130B)+'!R!4'+STRING("117B)+'!N' $
                             : '!9'+STRING("304B)) +'!X'
    'approx': ret = (hershey ? '!9!S'+STRING("101B)+'!R!B'+STRING("101B) $
                             : '!9'+STRING("273B)) +'!X'
    'ddagger':  ret = (hershey ? '!9'+ STRING("157B) : 'ddagger') +'!X'
    'natural':  ret = (hershey ? '!20'+ STRING("50B) : 'natural') +'!X'
    'varsigma': ret = '!9'+(hershey ?  STRING("163B) : STRING("126B)) +'!X'
    'supseteq': ret = ( hershey $
                        ? '!9!S'+STRING("62B)+'!R!4'+STRING("137B) $
                        : '!9'+STRING("312B) ) +'!X'
    'subseteq': ret = ( hershey $
                        ? '!9!S'+STRING("60B)+'!R!4'+STRING("137B) $
                        : '!9'+STRING("315B) ) +'!X'
    'Leftarrow':  ret = (hershey ? 'Larr' : '!9'+STRING("334B)) +'!X'
    'Rightarrow': ret = (hershey ? 'Rarr' : '!9'+STRING("336B)) +'!X'
    'Uparrow':    ret = (hershey ? 'Uarr' : '!9'+STRING("335B)) +'!X'
    'Downarrow':  ret = (hershey ? 'Darr' : '!9'+STRING("337B)) +'!X'
    'notsubset':  ret = ( hershey $
                          ? '!9!S'+STRING("60B)+'!R!4'+STRING("57B) $
                          : '!9'+STRING("313B) ) +'!X'
    'Leftrightarrow': ret = (hershey ? 'LRarr' : '!9'+STRING("333B)) +'!X'
    'leftrightarrow': ret = '!9'+ ( hershey ? $
                            '!S'+STRING("64B)+'!R'+STRING("66B)+'!N!X' : $
                            STRING("253B)) +'!X'
    'updownarrow':  ret = '!9'+ (hershey ? $
                          '!S'+STRING("67b)+'!R!B'+STRING("65b)+'!N!X' : $
                          '!S'+STRING("255b)+'!R!B'+STRING("257b)+'!N') +'!X'
    'Updownarrow':  ret = (hershey ? $
                          'UDarr'  : '!9!S'+STRING("335B)+$
                                     '!R!B'+STRING("337B)+'!N')+'!X'

    
; c. ISO 8859-1 Symbols: See http://www.w3schools.com/tags/ref_entities.asp
    'iexcl':  ret = '!3'+STRING("241B)
    'cent':   ret = '!3'+STRING("242B)
    'pound':  ret = '!3'+STRING("243B)
    'curren': ret = '!3'+STRING("244B)
    'yen':    ret = '!3'+STRING("245B)
    'brvbar': ret = '!3'+STRING("246B)
    'sect':   ret = '!3'+STRING("247B)
    'copy':   ret = '!3'+STRING("251B)
    'ordf':   ret = '!3'+STRING("252B)
    'laquo':  ret = '!3'+STRING("253B)
    'not':    ret = '!3'+STRING("254B)
    'shy':    ret = '!3'+STRING("255B)
    'reg':    ret = '!3'+STRING("256B)
    'deg':    ret = '!3'+STRING("260B)    
    'plusmn': ret = '!3'+STRING("261B)
    'sup2':   ret = '!3'+STRING("262B)
    'sup3':   ret = '!3'+STRING("263B)
    'micro':  ret = '!3'+STRING("265B)
    'para':   ret = '!3'+STRING("266B)
    'middot': ret = '!3'+STRING("267B)
    'sup1':   ret = '!3'+STRING("271B)
    'ordm':   ret = '!3'+STRING("272B)
    'raquo':  ret = '!3'+STRING("273B)
    'frac14': ret = '!3'+STRING("274B)
    'frac12': ret = '!3'+STRING("275B)
    'frac34': ret = '!3'+STRING("276B)
    'iquest': ret = '!3'+STRING("277B)
  
; d. ISO 8859-1 Characters (Capital):
    'Agrave': ret = '!3'+STRING("300B)
    'Aacute': ret = '!3'+STRING("301B)
    'Acirc':  ret = '!3'+STRING("302B)
    'Atilde': ret = '!3'+STRING("303B)
    'Auml':   ret = '!3'+STRING("304B)
    'Aring':  ret = '!3'+STRING("305B)
    'AElig':  ret = '!3'+STRING("306B)
    'Ccedil': ret = '!3'+STRING("307B)
    'Egrave': ret = '!3'+STRING("310B)
    'Eacute': ret = '!3'+STRING("311B)
    'Ecirc':  ret = '!3'+STRING("312B)
    'Euml':   ret = '!3'+STRING("313B)    
    'Igrave': ret = '!3'+STRING("314B)
    'Iacute': ret = '!3'+STRING("315B)
    'Icirc':  ret = '!3'+STRING("316B)
    'Iuml':   ret = '!3'+STRING("317B)    
    'ETH':    ret = '!3'+STRING("320B)
    'Ntilde': ret = '!3'+STRING("321B)
    'Ograve': ret = '!3'+STRING("322B)
    'Oacute': ret = '!3'+STRING("323B)
    'Ocirc':  ret = '!3'+STRING("324B)
    'Otilde': ret = '!3'+STRING("325B)
    'Ouml':   ret = '!3'+STRING("326B)
    'Oslash': ret = '!3'+STRING("330B)
    'Ugrave': ret = '!3'+STRING("331B)
    'Uacute': ret = '!3'+STRING("332B)
    'Ucirc':  ret = '!3'+STRING("333B)
    'Uuml':   ret = '!3'+STRING("334B)
    'Yacute': ret = '!3'+STRING("335B)
    'THORN':  ret = '!3'+STRING("336B)
    'szlig':  ret = '!3'+STRING("337B)
        
; e. ISO 8859-1 Characters (small):
    'agrave': ret = '!3'+STRING("340B)
    'aacute': ret = '!3'+STRING("341B)
    'acirc':  ret = '!3'+STRING("342B)
    'atilde': ret = '!3'+STRING("343B)
    'auml':   ret = '!3'+STRING("344B)
    'aring':  ret = '!3'+STRING("345B)
    'aelig':  ret = '!3'+STRING("346B)
    'ccedil': ret = '!3'+STRING("347B)
    'egrave': ret = '!3'+STRING("350B)
    'eacute': ret = '!3'+STRING("351B)
    'ecirc':  ret = '!3'+STRING("352B)
    'euml':   ret = '!3'+STRING("353B)    
    'igrave': ret = '!3'+STRING("354B)
    'iacute': ret = '!3'+STRING("355B)
    'icirc':  ret = '!3'+STRING("356B)
    'iuml':   ret = '!3'+STRING("357B)    
    'eth':    ret = '!3'+STRING("360B)
    'ntilde': ret = '!3'+STRING("361B)
    'ograve': ret = '!3'+STRING("362B)
    'oacute': ret = '!3'+STRING("363B)
    'ocirc':  ret = '!3'+STRING("364B)
    'otilde': ret = '!3'+STRING("365B)
    'ouml':   ret = '!3'+STRING("366B)
    'oslash': ret = '!3'+STRING("370B)
    'ugrave': ret = '!3'+STRING("371B)
    'uacute': ret = '!3'+STRING("372B)
    'ucirc':  ret = '!3'+STRING("373B)
    'uuml':   ret = '!3'+STRING("374B)
    'yacute': ret = '!3'+STRING("375B)
    'thorn':  ret = '!3'+STRING("376B)
    'yuml':   ret = '!3'+STRING("377B)
    ELSE:     ret = letter   
  ENDCASE

  RETURN, ret  
  
END
