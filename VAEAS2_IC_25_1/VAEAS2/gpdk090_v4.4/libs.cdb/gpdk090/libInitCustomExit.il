;;
;; Set the Spectre Model Path
;;
  if(isContextLoaded("schView") then
      envSetVal("asimenv.startup" "simulator" 'string "spectre")
      libPath = ddGetObjReadPath( ddGetObj( "gpdk090" ) )
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
;; Set the VXL chaining and folding library
;;
envSetVal("layoutXL" "compTypeRefLibs" 'string "gpdk090")

;;
;; Set the display units variable
;;
gLabelsNumNotation = 'suffix

;;
;; Set the VXL ignore parameters for 5141USR3
;;
envSetVal("layoutXL" "checkOldIgnoredParamsProps" 'boolean t)

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

