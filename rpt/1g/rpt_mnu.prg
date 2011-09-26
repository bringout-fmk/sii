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


function Izvj()
*{
private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. pregled sitnog inventara za rj                        ")
AADD(opcexe, {|| PregRJ()})
AADD(opc, "2. pregled sitnog inventara po kontima")
AADD(opcexe, {|| PregRjKon()})
AADD(opc, "3. amortizacija po kontima")
AADD(opcexe, {|| PregRjAm()})
AADD(opc, "4. revalorizacija po kontima")
AADD(opcexe, {|| PregRjRev()})
AADD(opc, "5. rekapitulacija kolicina po grupacijama - k1")
AADD(opcexe, {|| RekK1()})
AADD(opc, "6. amortizacija po grupama amortizacionih stopa")
AADD(opcexe, {|| PrRjAmSt()})
AADD(opc, "7. amortizacija po kontima i po grupama amort.stopa")
AADD(opcexe, {|| PrKiAs()})

Menu_SC("izv")

return
*}


