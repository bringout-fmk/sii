#include "\dev\fmk\sii\sii.ch"

/*! \defgroup ini Parametri rada programa - fmk.ini
 *  @{
 *  @}
 */
 
/*! \defgroup params Parametri rada programa - *param.dbf
 *  @{
 *  @}
 */

/*! \defgroup TblZnacenjePolja Tabele - znacenje pojedinih polja
 *  @{
 *  @}
 */

/*! \file fmk/os/main/1g/e.prg
 *  \brief
 */


#ifndef CPP
EXTERNAL RIGHT,LEFT,FIELDPOS
#endif

#ifdef LIB

/*! \fn Main(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 */

function Main(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
	MainSii(cKorisn,cSifra,p3,p4,p5,p6,p7)
return
*}

#endif



/*! \fn MainOs(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 */

function MainSii(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
local oSii

oSii:=TSiiModNew()
cModul:="SII"

PUBLIC goModul

goModul:=oSii
oSii:init(NIL, cModul, D_SII_VERZIJA, D_SII_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)

oSii:run()

return 
*}

