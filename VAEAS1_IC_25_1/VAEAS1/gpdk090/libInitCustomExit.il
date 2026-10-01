;;
;; Set the Spectre Model Path
;;
;;__  if(isContextLoaded("schView") then
;;__      envSetVal("asimenv.startup" "simulator" 'string "spectre")
;;__      libPath = ddGetObjReadPath( ddGetObj( "gpdk090" ) )
;;__      asiSetEnvOptionVal(asiGetTool('spectre) "modelFiles"
;;__         list(
;;__            list(strcat( libPath "/../../models/spectre/gpdk090.scs") "NN")
;;__      ))
;;__    )

  printf("\n  *************************************************************
          \n  *              Cadence Design Systems, Inc.                 *
          \n  *                                                           *
          \n  *                    Generic 90nm PDK                       *
          \n  *                        (gpdk090)                          *
          \n  *                                                           *
          \n  *************************************************************
          \n")

