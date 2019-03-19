function dechr2hrmn, dechr
    ; Function to convert decimal hour to hhmm format
    ; e.g. dechr2hrmn(22.5) = 2230
    
    hr = fix(dechr)*100
    mn = fix((dechr mod 1)*60)
    return, hr+mn
end
