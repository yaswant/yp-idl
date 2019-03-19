;+
; Function to determine if running on tidl (1) or not(0)
; 2009-12-22 15:29:10 Yaswant Pradhan
;-

function waveon_tidl
  if strcmp(!prompt, 'WAVEON-TIDL> ') then return,1b $
  else return,0b
end
