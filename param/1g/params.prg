/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "sii.ch"

function Pars0()
*{
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}

Box(,3,50)
 set cursor on
 //@ m_x+1,m_y+2 SAY "Radna jedinica" GET gRJ
 @ m_x+2,m_y+2 SAY "Datum obrade  " GET gDatObr
 read
BoxC()
if lastkey()<>K_ESC
 Wpar("rj",@gRJ)
 Wpar("do",@gDatObr)
 select params; use
endif
closeret
*}


*****************************
*****************************
function Pars()

O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
gPicI:=PADR(gPicI,15)
Box(,20,70)
 set cursor on
 @ m_x+1,m_y+2 SAY "Firma" GET gFirma
 @ m_x+1,col()+2 SAY "Naziv:" get gNFirma
 @ m_x+1,col()+2 SAY "TIP SUBJ.:" get gTS

 @ m_x+3,m_y+2 SAY "Radna jedinica" GET gRJ
 @ m_x+4,m_y+2 SAY "Datum obrade  " GET gDatObr

 @ m_x+5,m_y+2 SAY "Prikaz iznosa " GET gPicI

 @ m_x+7,m_y+2 SAY "Inv. broj je unikatan(jedinstven) D/N" GET gIBJ valid gIBJ $ "DN" pict "@!"

 @ m_x+13,m_y+2 SAY "Novi korisnicki interfejs D/N" GET gNW valid gNW $ "DN" pict "@!"
 @ m_x+15,m_y+2 SAY "Varijanta 1 - inventar rashodovan npr 10.05, "
 @ m_x+16,m_y+2 SAY "              obracun se NE vrsi za 05 mjesec"
 @ m_x+17,m_y+2 SAY "Varijanta 2 - obracun se vrsi za 05. mjesec  " GET gVObracun  valid gVObracun $ "12" pict "@!"
 @ m_x+19,m_y+2 SAY "Obracun pocinje od datuma razlicitog od 01.01. tekuce godine (D/N)" GET gVarDio valid gVarDio $ "DN" pict "@!"
 @ m_x+20,m_y+2 SAY "Obracun pocinje od datuma" GET gDatDio WHEN gVarDio=="D"
 read
 gPicI:=ALLTRIM(gPicI)
BoxC()

if lastkey()<>K_ESC
 WPar("ff",gFirma)
 WPar("ts",gTS)
 Wpar("fn",gNFirma)
 Wpar("ib",gIBJ)
 Wpar("nw",gNW)
 Wpar("rj",gRJ)
 Wpar("do",gDatObr)
 Wpar("pi",gPicI)
 Wpar("vd",gVarDio)
 Wpar("dd",gDatDio)
 select params; use
endif
closeret
*}

