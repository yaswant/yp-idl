;+
; :NAME:
;       loadmyct
;
; :PURPOSE:
;   The LOADMYCT procedure is a wrapper to loadcy that loads one of 68
;   (and growing) predefined IDL color tables. These color tables are
;   defined in the file '~fra6/myidl_lib/myct/mycolors.tbl', unless the
;   FILE keyword is specified with another table.
;
; :SYNTAX:
;   LOADMYCT [,index] [,BOTTOM=value] [,FILE=string] [,NCOLORS=value]
;            [,/BREWER] [,/SILENT]
;
;    :PARAMS:
;    index (IN:Value) The number of the pre-defined color table to load,
;           (New color palletes start from 41). If this value is omitted,
;           a menu of the available tables is printed and the user is
;           prompted to enter a table number.
;
;  :KEYWORDS:
;    BOTTOM (IN:Value) The first color index to use. LOADCT will use color
;             indices from BOTTOM to BOTTOM+NCOLORS-1. Default 0.
;    FILE (IN:String) Set this keyword to the name of a colortable file to
;             be used instead of the file colors1.tbl. See MODIFYCT to create
;             and modify colortable files.
;    NCOLORS (IN:Value) The number of colors to use. The default is all
;             available colors (this number is stored in the system variable
;             !D.TABLE_SIZE).
;    /BREWER - Use Brewer colour table located at
;             "~fra6/myidl_lib/myct/brewer/brewer.tbl"
;    /SILENT - If this keyword is set, the Color Table message is suppressed.
;
; :REQUIRES:
;
;
; :EXAMPLES:
;   1.View a list of IDL's tables and their related indices by calling
;   LOADCT without an argument:
; IDL> LOADMYCT
;   The list of color tables appears in the Output Log:
; % Compiled module: LOADMYCT.
; % Compiled module: LOADCT.
;  0-        B-W LINEAR
;  1-        BLUE/WHITE
;  2-   GRN-RED-BLU-WHT
;  3-   RED TEMPERATURE
;  4- BLUE/GREEN/RED/YE
;  5-      STD GAMMA-II
;  6-             PRISM
;  7-        RED-PURPLE
;  8- GREEN/WHITE LINEA
;  9- GRN/WHT EXPONENTI
; 10-        GREEN-PINK
; 11-          BLUE-RED
; 12-          16 LEVEL
; 13-           RAINBOW
; 14-             STEPS
; 15-     STERN SPECIAL
; 16-              Haze
; 17- Blue - Pastel - R
; 18-           Pastels
; 19- Hue Sat Lightness
; 20- Hue Sat Lightness
; 21-   Hue Sat Value 1
; 22-   Hue Sat Value 2
; 23- Purple-Red + Stri
; 24-             Beach
; 25-         Mac Style
; 26-             Eos A
; 27-             Eos B
; 28-         Hardcandy
; 29-            Nature
; 30-             Ocean
; 31-        Peppermint
; 32-            Plasma
; 33-          Blue-Red
; 34-           Rainbow
; 35-        Blue Waves
; 36-           Volcano
; 37-             Waves
; 38-         Rainbow18
; 39-   Rainbow + white
; 40- Rainbow + black
; 41- Split Rainbow B-W
; 42- Split B-W Linear Rainbow
; 43- NASA NDVI Palette
; 44- GLC2000 Globe v1.1
; 45- GLC2000 Africa v5
; 46- MetOffice CAM AOD
; 47- NASA Euphotic Depth
; 48- NASA SST Rainbow
; 49- Split Reverse Rainbow/B-W Linear
; 50- Split B-W Linear/
; 51- white + Blue-Red
; 52- Split W-B Linear/Reverse Rainbow
; 53- Split W-B Linear/Rainbow
; 54- MetOffice FRP
; 55- Anomaly Blue-Red
; 56- SEVIRI AOD
; 57- OMI Aerosol Index
; 58- Dust Index
; 59- Dust Index 2
; 60- Dust Index 3
; 61- W-B Linear
; 62- Soil Moisture
; 63- Anomaly BR Continuous
; 64- Anomaly BR Split
; 65- Soil Moisture Anomaly
; 66- MetOffice Brand
; 67- SSM Noise
;
; When running LOADCT without an argument,
; it will prompt you to enter the number of one of the color tables at the
; IDL command line. Enter in the number 53 at the Enter table number: prompt:
;
; Enter table number: 53
;
; The following text is displayed in the Output Log:
; % LOADCT: Loading table Split W-B Linear/Rainbow
;
; 2.If you already know the number of the pre-defined color table you want,
; you can load a color table by providing that number as the first input
; argument to LOADMYCT.
;
; Load in color table number 13 (RAINBOW):
;   IDL> LOADMYCT, 13
;
; The following text is displayed in the Output Log:
;   % LOADCT: Loading table RAINBOW
;
; :CATEGORIES:
;   Plotting
; :
; - - - - - - - - - - - - - - - - - - - - - - - - - -
; :HISTORY:
;  03-Apr-2008 09:53:37 Created. Yaswant Pradhan.
;  11-Dec-2010 Added Brewer keyword. YP.
;  07-Jul-2011 Added Silent keyword. YP.
;  10-Oct-2011 Decompose device by default. YP.
;-

PRO loadmyct, index, BOTTOM=bottom, FILE=ct_file, NCOLORS=ncolors, $
              BREWER=brewer, SILENT=silent


    ; Get old system settings:
    __quiet = !QUIET
    __dName = strupcase(!d.NAME)

    device, GET_DECOMPOSED=__decomp
    ;  __dRetn = (__dName eq 'WIN') ? pref_get('IDL_GR_WIN_RETAIN') : $
    ;                                 pref_get('IDL_GR_X_RETAIN')

    ; Parse keywords:
    s = keyword_set(silent)
    !QUIET  = s ? 1 : 0


    ; Set color table:
    ct_file = (n_elements(ct_file) ne 0) $
              ? strtrim(ct_file[0],2) $
              : keyword_set(brewer) $
                ? '/home/h05/fra6/myidl_lib/myct/brewer/brewer.tbl' $
                : '/home/h05/fra6/myidl_lib/myct/mycolors.tbl'


    ; Decomposed colour (all):
    device, DECOMPOSED=0


    ; Backing store for (X Windows system):
    if (__dName eq 'X') then device, RETAIN=2
    if ~keyword_set(ncolors) then ncolors=!d.table_size
    if ~keyword_set(bottom) then bottom=0


    ; Load colour table:
    case n_params() of
        1   : loadct, index, FILE=ct_file, BOTTOM=bottom, NCOLORS=ncolors, SILENT=s
        else: loadct, FILE=ct_file, BOTTOM=bottom, NCOLORS=ncolors, SILENT=s
    endcase

    !QUIET = __quiet

END
