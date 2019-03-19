function dt_num2name, number, $
    TYPE=type, $        ; Options: Weekday, Month
    LONG=long           ; Output in long week name and month name
;+
; :NAME:
;    dt_num2name
;
; :PURPOSE:
;    Translate weekday number or month number to name. Eg, 
;       Weekday 1, 2,.. = Monday, Tuesday,.. (week begins on Monday)
;       Month 1, 2,.. = January, February,.. (month begins on Jan)
;
; :SYNTAX:
;    Result = dt_num2name( Number [,/WEEKDAY] [,/MONTH] [,/LONG])
;
;
; :PARAMS:
;    number (in:integer) 
;
;
; :KEYWORDS:
;    TYPE (in:string) Week or Month
;    LONG Set this keyword to return long names of week or month
;
; :REQUIRES:
;
;
; :EXAMPLES:
;   IDL> print,dt_num2name([1,2,3,7])
;   Mon Tue Wed Sun
;   
;   IDL> print,dt_num2name([1,2,3,7], TYPE='month')
;   Jan Feb Mar Jul   
;   
;   IDL> print,dt_num2name([1,2,3,7,13],/long)
;   % DT_NUM2NAME: Invalid Week Number Found. This will be cycled..
;   Monday Tuesday Wednesday Sunday Saturday
;
; :CATEGORIES:
;   Date and Time
;
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  10-Dec-2013 11:13:52 Created. Yaswant Pradhan.
;
;------------------------------------------------------------------------------

    syntax = 'Result = dt_num2name(number [,TYPE=Weekday|Month] [,/LONG])'
    type = KEYWORD_SET(type) ? STRUPCASE(type) : 'WEEK'
    if ((STREGEX(type,'W')>STREGEX(type,'WEEK')>STREGEX(type,'WEEKDAY')> $
        (-1)) ge 0) then type='WEEK'
    if ((STREGEX(type,'M')>STREGEX(type,'MO')>STREGEX(type,'MONTH')> $
        (-1)) ge 0) then type='MONTH'
    
    
    case (type) of
        'MONTH': begin
            if (MAX(number) gt 12 or MIN(number) lt 1) then $
            message,'Invalid Month Number Found. This will be cycled..',/CONTI,/NOPREF
            
            fmt = KEYWORD_SET(long) ? '(C(CMoA0))' : '(C(CMoA))'
            return, STRING(JULDAY(number,1,2000), FORMAT=fmt)
        end        
        'WEEK': begin
            if (MAX(number) gt 7 or MIN(number) lt 1) then $
            message,'Invalid Week Number Found. This will be cycled..',/CONTI,/NOPREF
            
            fmt = KEYWORD_SET(long) ? '(C(CDwA0))' : '(C(CDwA))'
            return, STRING(number-1, FORMAT=fmt)
        end
        else: begin
            message,'Unknown DT Type',/CONTI,/NOPREF
            message,syntax
        end
    endcase
    
end
