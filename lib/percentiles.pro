;+
; NAME:
;        PERCENTILES
;
; PURPOSE:
;        compute percentiles of a data array
;
; CATEGORY:
;        statistical function
;
; CALLING SEQUENCE:
;        Y = PERCENTILES(DATA [,VALUE=value-array])
;
; INPUTS:
;        DATA --> the vector containing the data
;
; KEYWORD PARAMETERS:
;        VALUE --> compute specified percentiles
;        default is a standard set of min, 25%, median (=50%), 75%, and max
;        which can be used for box- and whisker plots.
;        The values in the VALUE array must lie between 0. and 1. !
;
; OUTPUTS:
;        The function returns an array with the percentile values or
;        -1 if no data was passed or value contains invalid numbers.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;      x = (findgen(31)-15.)*0.2     ; create sample data
;      y = exp(-x^2)/3.14159         ; compute some Gauss distribution
;      p = percentiles(y,value=[0.05,0.1,0.9,0.95])
;      print,p
;
;      IDL prints :  3.92826e-05  0.000125309     0.305829     0.318310

;
; MODIFICATION HISTORY:
;        mgs, 03 Aug 1997: VERSION 1.00
;        mgs, 20 Feb 1998: - improved speed and memory usage
;                (after tip from Stein Vidar on newsgroup)
;        mgs, 26 Aug 2000: - changed copyright to open source
;                          - median now correctly returned as average
;                            of two central values for data sets with
;                            even number of elements
;                          - modernized look and [] array notation
;        mgs, 09 Nov 2000: - bug fix: median didn't use sorted index!
;                            (thanks Andrew Slater)
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Martin Schultz
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################


FUNCTION percentiles,data,value=value

   result = -1L
   n = n_elements(data)
   IF n LE 0 THEN RETURN,result ;; error : data not defined

   ;; Check if speficic percentiles requested - if not: set standard
   IF NOT keyword_set(value) THEN value = [ 0., 0.25, 0.5, 0.75, 1.0 ]

   ;; Save the sorted index array
   ix = sort(data)

   ;; Loop through percentile values, get indices and add to result
   ;; This is all we need since computing percentiles is nothing more
   ;; than counting in a sorted array.
   FOR i=0L,n_elements(value)-1 DO BEGIN

      IF value[i] LT 0. OR value[i] GT 1. THEN RETURN,-1L

      IF value[i] LE 0.5 THEN ind = long(value[i]*n)    $
      ELSE ind = long(value[i]*(n+1)) < (n-1)

      ;; Special treatment for median of data sets with even number of
      ;; elements: compute average between two center values
      IF ABS(value[i]-0.5) LT 1.e-3 AND n MOD 2 EQ 0 AND n GT 1 THEN $
         thisresult = 0.5 * ( data[ix[long(n/2)]]+data[ix[long(n/2)+1]] )   $
      ELSE $
         thisresult = data[ix[ind]]

      IF i EQ 0 THEN result = thisresult  $
      ELSE result = [result, thisresult ]
   ENDFOR

   RETURN,result
END

