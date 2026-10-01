;;
;; Get the Library Path
;;
  libPath = ddGetObjReadPath( ddGetObj( "gpdk090" ) )

;;
;; Set the Simulator Model Paths
;;
  if(isContextLoaded("schView") then
;;    envSetVal("asimenv.startup" "simulator" 'string "spectre")
      asiSetEnvOptionVal(asiGetTool('spectre) "modelFiles"
         list(
            list(strcat( libPath "/../../models/spectre/gpdk090.scs") "NN")
      ))
      asiSetEnvOptionVal(asiGetTool('UltraSim) "modelFiles"
         list(
            list(strcat( libPath "/../../models/spectre/gpdk090.scs") "NN")
      ))
      asiSetEnvOptionVal(asiGetTool('ams) "modelFiles"
         list(
            list(strcat( libPath "/../../models/spectre/gpdk090.scs") "NN")
      ))
    )
;;
;; Set the display units variable
;;
gLabelsNumNotation = 'suffix

;;
;; Set the circuit prospector pdk defualts
;;
when( isCallable('ciRegisterDevice)
 ciRegisterDevice("fet"
                  append(ciGetDeviceNames("fet")
                  '( '("gpdk090" "nmos1v" nil)
                     '("gpdk090" "nmos1v_3" nil)
                     '("gpdk090" "nmos1v_hvt" nil)
                     '("gpdk090" "nmos1v_hvt_3" nil)
                     '("gpdk090" "nmos1v_iso" nil)
                     '("gpdk090" "nmos1v_nat" nil)
                     '("gpdk090" "nmos2v" nil)
                     '("gpdk090" "nmos2v_3" nil)
                     '("gpdk090" "nmos2v_nat" nil)
                     '("gpdk090" "pmos1v" nil)
                     '("gpdk090" "pmos1v_3" nil)
                     '("gpdk090" "pmos1v_hvt" nil)
	             '("gpdk090" "pmos1v_hvt_3" nil)
                     '("gpdk090" "pmos2v" nil)
		     '("gpdk090" "pmos2v_3" nil)
 )))
 ciRegisterDevice("nfet"
                  append(ciGetDeviceNames("nfet")
                  '( '("gpdk090" "nmos1v" nil)
                     '("gpdk090" "nmos1v_3" nil)
                     '("gpdk090" "nmos1v_hvt" nil)
                     '("gpdk090" "nmos1v_hvt_3" nil)
                     '("gpdk090" "nmos1v_iso" nil)
                     '("gpdk090" "nmos1v_nat" nil)
                     '("gpdk090" "nmos2v" nil)
                     '("gpdk090" "nmos2v_3" nil)
                     '("gpdk090" "nmos2v_nat" nil)
 )))
 ciRegisterDevice("pfet"
 			append(ciGetDeviceNames("pfet")
		  	'( '("gpdk090" "pmos1v" nil)
			   '("gpdk090" "pmos1v_3" nil)
			   '("gpdk090" "pmos1v_hvt" nil)
			   '("gpdk090" "pmos1v_hvt_3" nil)
			   '("gpdk090" "pmos2v" nil)
			   '("gpdk090" "pmos2v_3" nil)
 )))
 ciRegisterDevice("bjt"
 			append(ciGetDeviceNames("bjt")
		  	'( '("gpdk090" "npn" nil)
			   '("gpdk090" "pnp" nil)
			   '("gpdk090" "vpnp2" nil)
			   '("gpdk090" "vpnp5" nil)
			   '("gpdk090" "vpnp10" nil)
 )))
 ciRegisterDevice("npn"
 			append(ciGetDeviceNames("npn")
		  	'( '("gpdk090" "npn" nil)
 )))
 ciRegisterDevice("pnp"
 			append(ciGetDeviceNames("pnp")
		  	'( '("gpdk090" "pnp" nil)
			   '("gpdk090" "vpnp2" nil)
			   '("gpdk090" "vpnp5" nil)
			   '("gpdk090" "vpnp10" nil)
 )))
 ciRegisterDevice("diode"
 			append(ciGetDeviceNames("diode")
		  	'( '("gpdk090" "ndio" nil)
			   '("gpdk090" "pdio" nil)
 )))
 ciRegisterDevice("passive"
 			append(ciGetDeviceNames("passive")
			'( '("gpdk090" "mimcap" nil)
			   '("gpdk090" "resm1" nil)
			   '("gpdk090" "resm2" nil)
			   '("gpdk090" "resm3" nil)
			   '("gpdk090" "resm4" nil)
			   '("gpdk090" "resm6" nil)
			   '("gpdk090" "resm6" nil)
			   '("gpdk090" "resm7" nil)
			   '("gpdk090" "resm8" nil)
			   '("gpdk090" "resm9" nil)
			   '("gpdk090" "resnsndiff" nil)
			   '("gpdk090" "resnsndiff_2" nil)
			   '("gpdk090" "resnspoly" nil)
			   '("gpdk090" "resnspoly_2" nil)
			   '("gpdk090" "resnspdiff" nil)
			   '("gpdk090" "resnspdiff_2" nil)
			   '("gpdk090" "resnspdiff" nil)
			   '("gpdk090" "resnspdiff_2" nil)
			   '("gpdk090" "resnsppoly" nil)
			   '("gpdk090" "resnsppoly_2" nil)
			   '("gpdk090" "resnwoxide" nil)
			   '("gpdk090" "resnwoxide_2" nil)
			   '("gpdk090" "resnwsti" nil)
			   '("gpdk090" "resnwsti_2" nil)
			   '("gpdk090" "ressndiff" nil)
			   '("gpdk090" "ressndiff_2" nil)
			   '("gpdk090" "ressnpoly" nil)
			   '("gpdk090" "ressnpoly_2" nil)
 			   '("gpdk090" "resspdiff" nil)
 			   '("gpdk090" "resspdiff_2" nil)
 			   '("gpdk090" "ressppoly" nil)
 			   '("gpdk090" "ressppoly_2" nil)
 )))
 ciRegisterDevice("resistor"
 			append(ciGetDeviceNames("resistor")
			'( '("gpdk090" "resm1" nil)
			   '("gpdk090" "resm2" nil)
			   '("gpdk090" "resm3" nil)
			   '("gpdk090" "resm4" nil)
			   '("gpdk090" "resm6" nil)
			   '("gpdk090" "resm6" nil)
			   '("gpdk090" "resm7" nil)
			   '("gpdk090" "resm8" nil)
			   '("gpdk090" "resm9" nil)
			   '("gpdk090" "resnsndiff" nil)
			   '("gpdk090" "resnsndiff_2" nil)
			   '("gpdk090" "resnspoly" nil)
			   '("gpdk090" "resnspoly_2" nil)
			   '("gpdk090" "resnspdiff" nil)
			   '("gpdk090" "resnspdiff_2" nil)
			   '("gpdk090" "resnspdiff" nil)
			   '("gpdk090" "resnspdiff_2" nil)
			   '("gpdk090" "resnsppoly" nil)
			   '("gpdk090" "resnsppoly_2" nil)
			   '("gpdk090" "resnwoxide" nil)
			   '("gpdk090" "resnwoxide_2" nil)
			   '("gpdk090" "resnwsti" nil)
			   '("gpdk090" "resnwsti_2" nil)
			   '("gpdk090" "ressndiff" nil)
			   '("gpdk090" "ressndiff_2" nil)
			   '("gpdk090" "ressnpoly" nil)
			   '("gpdk090" "ressnpoly_2" nil)
 			   '("gpdk090" "resspdiff" nil)
 			   '("gpdk090" "resspdiff_2" nil)
 			   '("gpdk090" "ressppoly" nil)
 			   '("gpdk090" "ressppoly_2" nil)
 )))
 ciRegisterDevice("capacitor"
 			append(ciGetDeviceNames("capacitor")
			'( '("gpdk090" "mimcap" nil)
 )))

 ciMapParam("width"        append(ciGetParamMapping("width")        '("w")))
 ciMapParam("length"       append(ciGetParamMapping("length")       '("l")))
 ciMapParam("fingerCount"  append(ciGetParamMapping("fingerCount")  '("fingers")))
 ciMapParam("fingerWidth"  append(ciGetParamMapping("fingerWidth")  '("fw")))
 ciMapParam("mFactor"      append(ciGetParamMapping("mFactor")      '("m")))
 ciMapParam("resValue"     append(ciGetParamMapping("resValue")     '("r")))
 ciMapParam("capValue"     append(ciGetParamMapping("capValue")     '("c")))
 ciMapParam("indValue"     append(ciGetParamMapping("indValue")     '("l")))
 ciMapParam("area"         append(ciGetParamMapping("area")         '("area")))
 ciMapParam("perimeter"    append(ciGetParamMapping("perimeter")    '("perim")))

 ciMapTerm("gate"      append(ciGetTermNames("gate")      '("G")))
 ciMapTerm("source"    append(ciGetTermNames("source")    '("S")))
 ciMapTerm("drain"     append(ciGetTermNames("drain")     '("D")))
 ciMapTerm("bulk"      append(ciGetTermNames("bulk")      '("B")))
 ciMapTerm("base"      append(ciGetTermNames("base")      '("B")))
 ciMapTerm("emitter"   append(ciGetTermNames("emitter")   '("E")))
 ciMapTerm("collector" append(ciGetTermNames("collector") '("C")))
) ; when 

;;
;; Print this header in the CIW
;;
  printf("\n  *************************************************************
          \n  *              Cadence Design Systems, Inc.                 *
          \n  *                                                           *
          \n  *                    Generic 90nm PDK                       *
          \n  *                        (gpdk090)                          *
          \n  *                                                           *
          \n  *************************************************************
          \n")

fp=infile(strcat(libPath "/../../docs/VERSION"))
while(gets(line fp) printf("%s\n" line))
close(fp)

