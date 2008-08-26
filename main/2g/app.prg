#include "sii.ch"

/*! \fn TOsModNew()
 *  \brief
 */

function TSiiModNew()
*{
local oObj

#ifdef CLIP

#else
	oObj:=TSiiMod():new()
#endif

oObj:self:=oObj
return oObj
*}


#ifdef CPP
/*! \class TSiiMod
 *  \brief SII aplikacijski modul
 */

class TSiiMod: public TAppMod
{
	public:
	*void dummy();
	*void setGVars();
	*void mMenu();
	*void mMenuStandard();
	*void sRegg();
	*void initdb();
	*void srv();
	
#endif

#ifndef CPP
#include "class(y).ch"
CREATE CLASS TSiiMod INHERIT TAppMod
	EXPORTED:
	method dummy 
	method setGVars
	method mMenu
	method mMenuStandard
	method sRegg
	method initdb
	method srv
END CLASS
#endif


/*! \fn TSiiMod::dummy()
 *  \brief dummy
 */

*void TSiiMod::dummy()
*{
method dummy()
return
*}


*void TSiiMod::initdb()
*{
method initdb()

::oDatabase:=TDBSiiNew()

return nil
*}


/*! \fn *void TSiiMod::mMenu()
 *  \brief Osnovni meni SII modula
 */
*void TSiiMod::mMenu()
*{
method mMenu()

private Izbor
private lPodBugom

say_fmk_ver()

nPom:=VAL(IzFmkIni("SET","Epoch","1945",KUMPATH))
IF nPom>0
	SET EPOCH TO (nPom)
ENDIF

PUBLIC gSQL:="N"
PUBLIC gCentOn:=IzFmkIni("SET","CenturyOn","N",KUMPATH)

IF gCentOn=="D"
	SET CENTURY ON
ELSE
  	SET CENTURY OFF
ENDIF

Pars0()

SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

O_OS
select os

TrebaRegistrovati(10)
use

#ifdef PROBA
	KEYBOARD "213"
#endif

@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")
@ 4,5 SAY ""

::mMenuStandard()

::quit()

return nil
*}


*void TSiiMod::srv()
*{
method srv()
? "Pokrecem SII aplikacijski server"
if (MPar37("/KONVERT", goModul))
	if LEFT(self:cP5,3)=="/S="
		cKonvSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cKonvSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cKonvSez)
		endif
	endif
	goModul:oDataBase:KonvZN()
	goModul:quit(.f.)
endif
// modifikacija struktura
if (MPar37("/MODSTRU", goModul))
	if LEFT(self:cP5,3)=="/S="
		cSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cSez)
		endif
	endif
	cMsFile:=goModul:oDataBase:cName
	if LEFT(self:cP6,3)=="/M="
		cMSFile:=SUBSTR(self:cP6,4)
	endif
	AppModS(cMsFile)
	goModul:quit(.f.)
endif



return
*}



*void TSiiMod::mMenuStandard()
*{
method mMenuStandard

private opc:={}
private opcexe:={}

AADD(opc, "1. unos promjena na postojecem sredstvu                       ")
AADD(opcexe, {|| Unos()})
AADD(opc, "2. obracuni")
AADD(opcexe, {|| Obrac()})
AADD(opc, "3. izvjestaji")
AADD(opcexe, {|| Izvj()})
AADD(opc, "--------------")
AADD(opcexe, {|| RazdvojiDupleInvBr()})
//4. inventura"
AADD(opc, "5. sifrarnici")
AADD(opcexe, {|| Sifre()})
AADD(opc, "6. parametri")
AADD(opcexe, {|| Pars()})
AADD(opc, "7. zavrsio unose u sezonskom podrucju, prenesi u tekucu")
AADD(opcexe, {|| PrenosPodatakaUTekucePodrucje()})
AADD(opc, "8. generacija podataka za novu sezonu")
AADD(opcexe, {|| GenerisanjePodatakaZaNovuSezonu()})
AADD(opc, "A. administracija baze podataka")
AADD(opcexe, {|| MnuAdminDB()})

private Izbor:=1

Menu_SC("gsi",.t.,lPodBugom)

return
*}

*void TSiiMod::sRegg()
*{
method sRegg()
sreg("SII.EXE","SII")
return
*}



/*! \fn *void TSiiMod::setGVars()
 *  \brief opste funkcije SII modula
 */
*void TSiiMod::setGVars()
*{
method setGVars()
O_PARAMS

//::super:setGVars()

SetFmkSGVars()

SetSpecifVars()

O_PARAMS

private cSection:="1",cHistory:=" "; aHistory:={}
public gFirma:="10", gTS:="Preduzece"
public gNFirma:=space(20)  // naziv firme
public gNW:="D"  // new vawe
public gRJ:="00"
public gDatObr:=date()
public gValuta:="KM "
public gPicI:="99999999.99"
public gPickol:="99999.99"
public gVObracun:="2"
public gIBJ:="D"
public gVarDio:="N", gDatDio:=CTOD("01.01.1999")

Rpar("ff",@gFirma)
Rpar("ts",@gTS)
Rpar("fn",@gNFirma)
Rpar("ib",@gIBJ)
Rpar("nw",@gNW)
Rpar("rj",@gRj)
Rpar("do",@gDatObr)
Rpar("va",@gValuta)
Rpar("pi",@gPicI)
Rpar("vd",@gVarDio)
Rpar("dd",@gDatDio)

return
*}


function RazdvojiDupleInvBr()
       if sigmasif("UNIF")
         if pitanje(,"Razdvojiti duple inv.brojeve ?","N")=="D"
           UnifId()
         endif
       endif
return

function PrenosPodatakaUTekucePodrucje()
        if empty(goModul:oDataBase:cSezonDir)
          Msgbeep("Ovo se radi u sezonskom podrucju !")
        else
          PrenesiUtekucu()
        endif
return

function GenerisanjePodatakaZaNovuSezonu()
        if empty(goModul:oDataBase:cSezonDir)  // nalazim se u radnom podrucju
          if val(goModul:oDataBase:cSezona)<>year(date())
             MsgBeep("U radnom podrucju se nalaze podaci iz protekle godine !")
          else
              PrenosOs()
          endif
        else
             MsgBeep("Ovo se radi u radnom podrucju !")
        endif
return


