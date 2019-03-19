FUNCTION Sps_Constants
;+
; NAME:
;       Sps_Constants
; PURPOSE:
;       Retruns pre-defined constants used in Autosat processing
;
; SYNTAX:
;       Result = Sps_Constants()
;
; ARGUMENTS:
;       None
;
; KEYWORDS:
;       None
;
; EXAMPLE:
;       Result = Sps_Constants()
;
; EXTERNAL ROUTINES:
;       None
;
; $Id: SPS_CONSTANTS.pro, v 1.0 15/08/2008 11:06 yaswant Exp $
; SPS_CONSTANTS.pro Yaswant Pradhan (c) Crown copyright Met Office
; Last modification:
;-

    const = { Sps_Constants, $
        NAME        : "PRE-DEFINED SPS CONSTANTS", $
        VERSION     : 1.0, $
        ;-----------------------------------------------------------------------
        ; Miscellaneous physical and mathematical constants
        ;-----------------------------------------------------------------------
        IMDI        : -32768, $             ;Integer missing data indicator
        RMDI        : -32768.0*32768.0, $   ;Real missing data indicator
        Planck_c1   : 0.000011910659d, $
        Planck_c2   : 1.438833d, $
        PI          : 3.141592654d, $
        SunRadius   : 695300.0d, $          ;Radius of the sun (km)
        EarthOrbit  : 149500000.0d, $       ;Mean distance Sun to Earth (km)
        ISDI        : 32767, $              ;Integer to indicate space
        RMDItol     : -0.000001*(-32768.0*32768.0), $ ; RMDI tolerance
        
        ;-----------------------------------------------------------------------
        ; Central wave numbers cm^-1 (and wavelength um) for each channel.
        ; Central wavelength in microns and central wavenumbers in cm^-1. Source:
        ; wavenumbers for channels 4-11 taken from the RTTOV coefficient file;
        ; wavelengths for channels 1-3, 12 taken from EUMETSAT documentation.
        ; taken from trunk/coeffs/Sps_Coeffs/channelinfo_msg2.nl
        ; Remember to calculate wave number for HRVis channel.
        ;-----------------------------------------------------------------------
        CentralWaveno : [$
            16666.67d, $   	;For Vis0_6
            12500.00d, $	;For Vis0_8
             6250.00d, $	;For IR1_6
             2555.73d, $	;For IR3_9
             1588.79d, $	;For IR6_2
             1359.93d, $	;For IR7_3
             1148.28d, $	;For IR8_7
             1034.05d, $	;For IR9_7
              927.76d, $	;For IR10_8
              837.82d, $	;For IR12_0
              749.70d, $	;For IR13_4
                1.0],  $    ;For HRVis
        
        central_wavenumber : [$
            0.1666667000E+05, 0.1250000000E+05, $
            0.6250000000E+04, 0.2557988564E+04, $
            0.1591160487E+04, 0.1358237134E+04, $
            0.1147808176E+04, 0.1035030870E+04, $
            0.9287465621E+03, 0.8345652274E+03, $
            0.7492118493E+03 ], $
        
        Central_Wavelength : [$
            0.635, 0.81, 1.64, 3.92, 6.25, 7.35, $
            8.70, 9.66, 10.80, 12.00, 13.40, 0.75],$
        
        ;-------------------------------------------------------------------------------
        ; Band correction coefficients. Source: channels 4-11 from the RTTOV
        ; coefficient file. Channels 1-3 and 12 have been ignored because BTs are not
        ; meaningful for visible channels.
        ;-------------------------------------------------------------------------------
        planck_bc_coeff_a : [$
            0.3146963026E+01, 0.1711082083E+01, $
            0.3227116301E+00, 0.1004878463E+00, $
            0.2614183403E-01, 0.2243063139E+00, $
            0.8851520711E-01, 0.3625667805E-01], $
        
        planck_bc_coeff_b : [0.9931645873E+00, 0.9942358527E+00, $
        0.9987464922E+00, 0.9995338073E+00, $
        0.9998609082E+00, 0.9985598859E+00, $
        0.9992192213E+00, 0.9991871851E+00], $
        
        
        ;-------------------------------------------------------------------------------
        ; Data for derived product bias correction increments:
        ; brightness temperature increments to be added to background calculations.
        ;-------------------------------------------------------------------------------
        ; There are 2 sets of values to match the 2 possible radiance definitions
        ; (spectral or effective radiance). The correct set of values will be selected
        ; when the namelist is read in.
        
        bias_corr_incr_specrad : [$
            0.3000000000E+00,  0.0000000000E+00, $
            0.0000000000E+00, -0.1000000000E+00, $
            0.0000000000E+00,  0.0000000000E+00, $
           -0.4000000000E+00, -0.7000000000E+00], $
        
        bias_corr_incr_effrad : [$
            0.6000000000E+00,  0.0000000000E+00, $
            0.0000000000E+00,  0.0000000000E+00, $
            0.0000000000E+00, -0.3000000000E+00, $
           -0.5000000000E+00, -0.9000000000E+00], $
        
        ;-----------------------------------------------------------------------
        ; Data for imagery product channel correction increments:
        ; brightness temperature increments to be added to measured values.
        ;-----------------------------------------------------------------------
        ; There are 2 sets of values to match the 2 possible radiance 
        ; definitions (spectral or effective radiance). The correct set of 
        ; values will be selected when the namelist is read in.
        
        image_corr_incr_specrad : [$
            -0.5000000000E+00, 0.0000000000E+00, $
             0.0000000000E+00, 0.2000000000E+00, $
             0.0000000000E+00, 0.0000000000E+00, $
             0.4500000000E+00, 0.0000000000E+00], $
        
        image_corr_incr_effrad : [$
            -0.8000000000E+00, 0.0000000000E+00, $
             0.0000000000E+00,-0.1000000000E+00, $
             0.0000000000E+00, 0.3000000000E+00, $
             0.5500000000E+00, 0.0000000000E+00], $
        
        ;-----------------------------------------------------------------------
        ; Channel-specific radiance emitted by the Sun in Wm(-2)sr(-1)(cm(-1)-1)
        ; Values provided by Eumetsat
        ;-----------------------------------------------------------------------
        RadianceSol : [430200.0d, 330000.0d, 259100.0d, 104100.0d, 430900.0d], $
        
        ;----------------------------------------------------------------
        ; Channels for MSG
        ; The channel names indicate both the Euemetsat channel numbering.
        ;----------------------------------------------------------------
        CHANNEL_MSG_1_006   : 1, $  ; MSG 0.6 ;micron (visible)
        CHANNEL_MSG_2_008   : 2, $  ; MSG 0.8 micron
        CHANNEL_MSG_3_016   : 3, $  ; MSG 1.6 micron
        CHANNEL_MSG_4_039   : 4, $  ; MSG 3.9 micron
        CHANNEL_MSG_5_062   : 5, $  ; MSG 6.2 micron (water vapour)
        CHANNEL_MSG_6_073  	: 6, $  ; MSG 7.3 micron
        CHANNEL_MSG_7_087  	: 7, $  ; MSG 8.7 micron
        CHANNEL_MSG_8_097  	: 8, $  ; MSG 9.7 micron
        CHANNEL_MSG_9_108  	: 9, $ 	; MSG 10.8 micron (infrared)
        CHANNEL_MSG_10_120  : 10,$ 	; MSG 12.0 micron
        CHANNEL_MSG_11_134  : 11,$ 	; MSG 13.4 micron
        CHANNEL_MSG_12_HRV  : 12,$ 	; MSG High Resolution Visible
        
        ;-------------------------------------------------------------------------------
        ; STASH codes
        ;-------------------------------------------------------------------------------
        ;Dummy STASH codes for derived fields:
        stash_satzen    : -1, $
        stash_latitude  : -2, $
        
        ;UM fields:
        stash_q         : 10, 	$ ; Specific humidity
        stash_snow      : 23, 	$ ; Snow amount
        stash_tstar     : 24, 	$ ; Surface skin temperature
        stash_lsm       : 30, 	$ ; Land-sea mask
        stash_seaice    : 31, 	$ ; Seaice fraction
        stash_orog      : 33, 	$ ; Orography
        stash_bclfr     : 266,	$ ; Bulk cloud fraction
        stash_p         : 408, 	$ ; Pressure
        stash_pstar     : 409, 	$ ; Surface pressure
        stash_t2        : 3236,	$ ; Screen-level temperature
        stash_q2        : 3237, $ ; Screen-level specific humidity
        stash_td2       : 3250, $ ; Screen-level dewpoint
        stash_cl_conv   : 5212, $ ; Convective cloud amount
        stash_rh        : 9229, $ ; Relative humidity
        stash_t         : 16004,$ ; Temperature
        stash_geo       : 16201,$ ; Geopotential height
        stash_pmsl      : 16222 $ ; PMSL        
    }
        
    return, const
END
