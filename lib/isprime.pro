;+
; :NAME:
;       isprime
;
; :PURPOSE:
;       Check if a number (integer) is prime.  Returns:
;           1: number is prime
;           0: number is not prime
;          -1: invalid number
;
; :SYNTAX:
;       Result = isprime(n)
;
; :PARAMS:
;    n (in:int) a positive integer greater than 1 (2 is the first prime number)
;
;
; :REQUIRES:
;
;
; :EXAMPLES:
;   IDL> print,isprime(2)
;       1
;   IDL> print,isprime(1)
;       0
;   IDL> print,isprime(0)
;      -1
;
; :CATEGORIES:
;   numerical
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :COPYRIGHT: (c) Crown Copyright Met Office
; :HISTORY:
;  10-Jan-2014 15:01:37 Created. Yaswant Pradhan.
;
;-

function isprime, n

    i = 2
    if (n lt 1) then return, -1 else nsqrt = sqrt(n)
    case fix(n) of
        1:  return, 0
        else: begin
            ; Checking against the interval [2, n/2 -1] isn't the optimal
            ; solution; A better approach is to check against [2, sqrt(n)]
            while (i le nsqrt) do if (fix(n) mod i eq 0) then return, 0 else i++
            return, 1
        end
    endcase

end
