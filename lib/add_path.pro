pro add_path, Path, DLM=dlm, REVERT=revert, SILENT=silent
;+
; :NAME:
;    	add_path
;
; :PURPOSE:
;       Adds custom library or dlm path to IDL defaults 
;
; :SYNTAX:
;       add_path, Path [,/DLM] [,/REVERT]
;
; :PARAMS:
;    Path (in:strarr) Custom paths to add
;
;
; :KEYWORDS:
;    /DLM    Set this keyword to add path to IDL_DLM_PATH; def IDL_PATH 
;    /REVERT Revert changes to IDL default   
;    /SILENT Setting this keyword will ignore reporting invalid paths
;
; :REQUIRES:
;   None.
;
; :EXAMPLES:
;   Adding invalid path will warn and do nothing, e.g.,
;   IDL> add_path,['/this/path1','/that/path2']
;   % ADD_PATH: /this/path1 doesnot exist.
;   % ADD_PATH: /that/path2 doesnot exist.
;
;
; :CATEGORIES:
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  31-Aug-2011 16:10:17 Created. Yaswant Pradhan.
;  12-Dec-2012 Optimised, YP.
;
;-


    ; Parse keywords/arguments:
    if (N_ELEMENTS(Path) lt 1) then return 
    
    Pref = KEYWORD_SET(dlm) ? 'IDL_DLM_PATH' : 'IDL_PATH'  
    verb = ~KEYWORD_SET(silent)
    
    if KEYWORD_SET(revert) then begin
        PREF_SET, Pref, /DEFAULT
        return
    endif
    
    
    ; Default valid path:
    valid_path = '<IDL_DEFAULT>'
    
      
    ; Check for sub-directory inclusions (path with a + prefix):     
    fp = WHERE(STREGEX(path, '^[^+]') eq -1, nfp, $
        COMPLEMENT=dir, NCOMPLEMENT=ndir)
    
    ; Parse plain directories:
    if (ndir gt 0) then begin
        for i=0,ndir-1 do begin
            thisDir = EXPAND_PATH(path[dir[i]])
            if ~FILE_TEST(thisDir,/DIR) then begin
                if verb then message,"'"+thisDir+"'"+" doesnot exist.",/CONTI
                CONTINUE
            endif
            valid_path = [thisDir,valid_path]
        endfor
    endif        

    ; Parse directory tree:
    if (nfp gt 0) then begin
        for i=0,nfp-1 do begin
            thisDir = EXPAND_PATH(STRMID(path[fp[i]],1))
            if ~FILE_TEST(thisDir,/DIR) then begin
                if verb then message,"'"+thisDir+"'"+" doesnot exist.",/CONTI
                CONTINUE
            endif
            valid_path = ['+'+thisDir,valid_path]
        endfor
    endif
    

    ; Finally add valid paths:    
    PREF_SET, Pref, STRJOIN(valid_path,PATH_SEP(/SEARCH_PATH)), /COMMIT

end
