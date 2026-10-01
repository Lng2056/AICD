;;
;; Get the Library Path
;;
  libPath = ddGetObjReadPath( ddGetObj( "gpdk045" ) )

;;; Sets the specified environment variable if it hasn't been already set 
;;; differently from its default value
procedure( envSetValIfDefault( tool var type value "ttsg" )
    when( and( envIsVal( tool var ) envGetVal( tool var ) == envGetDefVal( tool var ) )
	envSetVal( tool var type value )
    )
)

printf("\tLoading Environment Settings ...\n")
envSetValIfDefault("layoutXL" "setPPConn" 'boolean nil)
envSetValIfDefault("layout" "mppTemplate" 'string "N-Tap")
envSetValIfDefault("layout" "xSnapSpacing" 'float 0.005)
envSetValIfDefault("layout" "ySnapSpacing" 'float 0.005)
envSetValIfDefault("layoutXL" "initIOPinLayer" 'string "Metal1 drawing")
envSetValIfDefault("spectre.envOpts" "useAltergroup" 'boolean nil)
envSetValIfDefault("hspiceD.envOpts" "autoDisplay" 'boolean nil)
envSetValIfDefault("layoutXL" "lxGenerateInBoundary" 'boolean t)
envSetValIfDefault("layoutXL" "lxPositionMinSep" 'float 0.12)
envSetValIfDefault("layoutXL" "extractVerifyWellSubstrateConnections" 'boolean t)

when( rexMatchp("6.1.5" getVersion(t)) 
     printf("\tLoading Fluid Guard Ring Set Up ... \n")
     vfoInstallFluidDeviceFiles()
    )
when( rexMatchp("6.1.4" getVersion(t)) 
        isrDotNum = rindex(rindex(getVersion(t) ".") ".")
        isrNum = evalstring(substring(isrDotNum 2 strlen(isrDotNum)))
          if( (isrNum < 5) then 
             printf("\tLoading Fluid Guard Ring Set Up ... \n")
             envSetVal("layout" "enableFluidGuardRing" 'boolean t)
             installFluidDeviceFiles()
          else 
             printf("\tLoading Fluid Guard Ring Set Up ... \n")
             envSetVal("layout" "enableFluidGuardRing" 'boolean t)
             vfoInstallFluidDeviceFiles()
          )
    )

;;
;; Append Simulator Model Paths
;;
when(isContextLoaded("schView") 
    file = strcat( libPath "/gpdk045_ModelMgmt.il" )
    ;;; Load required skill code
    when( and( !getd( 'gpdk045_AppendModelFile ) isReadable( file ) )
        printf("\tLoading Model Management File ...\n", file)
	load( file )
    )
    gpdk045_AppendModelFile( 
	'( "spectre" "UltraSim" "ams" )
	strcat( libPath "/../models/spectre/gpdk045.scs")
	"mc"
    )
)

;;
;; Set the Simulator Model Paths
;;
;;  if(isContextLoaded("schView") then
;;    envSetVal("asimenv.startup" "simulator" 'string "spectre")
;;      asiSetEnvOptionVal(asiGetTool('spectre) "modelFiles"
;;         list(
;;            list(strcat( libPath "/../models/spectre/gpdk045.scs") "tt")
;;      ))
;;      asiSetEnvOptionVal(asiGetTool('UltraSim) "modelFiles"
;;         list(
;;            list(strcat( libPath "/../models/spectre/gpdk045.scs") "tt")
;;     ))
;;      asiSetEnvOptionVal(asiGetTool('ams) "modelFiles"
;;         list(
;;            list(strcat( libPath "/../models/spectre/gpdk045.scs") "tt")
;;      ))
;;    )
;;
;; Set the display units variable
;;
gLabelsNumNotation = 'suffix

;;
;; Set the circuit prospector pdk defualts
;;

;; For additional detailed information about Circuit Prospector, please see
;; the Cadence online help or SourceLink:
;;
;;     Virtuoso Unified Custom Constraints User Guide, Reference Manual
;;     Virtuoso Unified Custom Constraints Reference Manual
;;     Virtuoso Unified Custom Constraints SKILL API Commands
;;       
     ;; load custom library initialization file
     when( ddObj = ddGetObj(libName nil nil "gpdk045_PDKRegistrations.il")
    printf("\tLoading %s/%s ... " libName ddObj~>name)
    if( errset(load(ddGetObjReadPath(ddObj))) then
       printf("done!\n")
    else
       success = nil
       printf("failed!\n")
    )
     ) ; ** when ddObj **

;;
;; Print this header in the CIW
;;
  printf("\n  *************************************************************
          \n  *              Cadence Design Systems, Inc.                 *
          \n  *                                                           *
          \n  *                    Generic 45nm PDK                       *
          \n  *                        (gpdk045)                          *
          \n  *                                                           *
          \n  *************************************************************
          \n")

fp=infile(strcat(libPath "/../docs/VERSION"))
if(fp then
    while(gets(line fp) printf("\t%s\n" line))
    close(fp)
else
    printf("\tVersion File is not available\n")
)
