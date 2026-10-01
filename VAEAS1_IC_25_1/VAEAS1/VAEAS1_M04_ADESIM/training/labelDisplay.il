
/****************************************************/
 LIBRARY = "training"
/****************************************************/

prog( ( libId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    cdfId = or(
        cdfGetUserLibCDF( libId )
        cdfCreateUserLibCDF( libId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "basic"
/****************************************************/

prog( ( libId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    cdfId = or(
        cdfGetUserLibCDF( libId )
        cdfCreateUserLibCDF( libId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "basic"
 CELL    = "ipin"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "basic"
 CELL    = "opin"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "analogLib"
/****************************************************/

prog( ( libId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    cdfId = or(
        cdfGetUserLibCDF( libId )
        cdfCreateUserLibCDF( libId )
    )
    cdfId->termSimType = "DC"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
    cdfId->termDisplayMode = "voltage"
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "vsin"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "res"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
    cdfId->instDisplayMode = "instName"
    cdfId->instNameType = "schematic"
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "vss"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "gnd"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "idc"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "cap"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "npn"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->opPointLabelSet = "betadc ic none"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "nmos4"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "pmos4"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "pnp"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)

/****************************************************/
 LIBRARY = "analogLib"
 CELL    = "vdd"
/****************************************************/

prog( ( libId cellId cdfId )
    unless( libId = ddGetObj( LIBRARY )
        warn( "Could not find library %s." LIBRARY)
        return( nil )
    )
    unless( cellId = ddGetObj( LIBRARY CELL )
        warn( "Could not find cell %s." CELL )
        return( nil )
    )
    cdfId = or(
        cdfGetUserCellCDF( cellId )
        cdfCreateUserCellCDF( cellId )
    )
    cdfId->termSimType = "DC"
    cdfId->termDisplayMode = "voltage"
    cdfId->paramSimType = "DC"
    cdfId->paramDisplayMode = "model"
)
