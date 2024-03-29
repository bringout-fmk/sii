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

function PrRjAmSt()
*{
local cIdAmort:=space(8), cidsk:="", ndug:=ndug2:=npot:=npot2:=ndug3:=npot3:=0
local nCol1:=10, qIdAm:=SPACE(8)
O_AMORT
O_RJ
O_PROMJ
O_OS

cIdrj:=space(4)
cPromj:="2"
cPocinju:="N"
cFiltSadVr:="0"
cFiltK1:=SPACE(40)

Box(,9,77)
 DO WHILE .t.
  @ m_x+1,m_y+2 SAY "Radna jednica (prazno - svi):" get cidrj valid empty(cIdRj) .or. p_rj(@cIdrj)
  @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
  @ m_x+2,m_y+2 SAY "Grupa amort.stope (prazno - sve):" get qIdAm pict "@!" valid empty(qidAm) .or. P_Amort(@qIdAm)
  @ m_x+4,m_y+2 SAY "Za sitan inventar prikazati vrijednost:"
  @ m_x+5,m_y+2 SAY "1 - bez promjena"
  @ m_x+6,m_y+2 SAY "2 - osnovni iznos + promjene"
  @ m_x+7,m_y+2 SAY "3 - samo promjene           " GET cPromj valid cpromj $ "123"
  @ m_x+8,m_y+2 SAY "Filter po sadasnjoj vr.(0-sve,1-samo koja je imaju,2-samo koja je nemaju):" GET cFiltSadVr valid cFiltSadVr $ "012" pict "9"
  @ m_x+9,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
  read; ESC_BCR
  aUsl1:=Parsiraj(cFiltK1,"K1")
  if aUsl1<>NIL; exit; endif
 ENDDO
BoxC()

if empty(qidAm); qidAm:=""; endif
if empty(cIdrj); cidrj:=""; endif
if cpocinju=="D"
  cIdRj:=trim(cidrj)
endif

if empty(cidrj)
  select os
  cSort1:="idam+idrj+id"
  INDEX ON &cSort1 TO "TMPOS" FOR &aUsl1
  seek qidAm
else
  select os
  cSort1:="idrj+idam+id"
  INDEX ON &cSort1 TO "TMPOS" FOR &aUsl1
  seek cidrj+qidAm
endif
IF !EMPTY(qIdAm) .and. !(idam==qIdAm)
  MsgBeep("Ne postoje trazeni podaci!")
  CLOSERET
ENDIF

start print cret
private nStr:=0  // strana
select rj; hseek cidrj; select os
P_10CPI
? gTS+":",gnFirma
if !empty(cidrj)
 ? "Radna jedinica:",cidrj,rj->naz
endif
? "SII: Pregled obracuna amortizacije po grupama amortizacionih stopa"
?? "     Datum:",gDatObr
if !EMPTY(cFiltK1); ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"; endif
P_COND2

private m:="----- ---------- ---- -------- ------------------------------ --- ------"+REPL(" "+REPL("-",LEN(gPicI)),5)

private nrbr:=0
nDug:=nPot1:=nPot2:=0
Zagl3()
n1:=n2:=0
do while !eof() .and. (idrj=cidrj .or. empty(cidrj))
   cIdAm:=idam
   nDug2:=nPot21:=nPot22:=0
   do while !eof() .and. (idrj=cidrj .or. empty(cidrj)) .and. idam==cidam
      cIdAmort:=idam
      nDug3:=nPot31:=nPot32:=0
      do while !eof() .and. (idrj=cidrj .or. empty(cidrj))  .and. idam==cidamort
         if prow()>63; FF; Zagl3(); endif

           fIma:=.t.
           if cpromj=="3"  // ako zelim samo promjene vidi ima li za sr.
                          // uopste promjena
               select promj; hseek os->id
               fIma:=.f.
               do while !eof() .and. id==os->id .and. datum<=gDatObr
                 fIma:=.t.
                skip
               enddo
               select os
           endif


           // utvr�ivanje da li sredstvo ima sada�nju vrijednost
           // --------------------------------------------------
           lImaSadVr:=.f.
           if cPromj <> "3"
             if nabvr-otpvr-amp>0
               lImaSadVr:=.t.
             endif
           endif
           if cPromj $ "23"  // prikaz promjena
              select promj; hseek os->id
              do while !eof() .and. id==os->id .and. datum<=gDatObr
                 n1:=0; n2:=amp
                 if nabvr-otpvr-amp>0
                   lImaSadVr:=.t.
                 endif
                skip
              enddo
              select os
           endif

           // ispis stavki
           // ------------
           if cFiltSadVr=="1" .and. !(lImaSadVr) .or.;
              cFiltSadVr=="2" .and. lImaSadVr
             skip; loop
           else
             if fIma
                ? str(++nrbr,4)+".",id,idrj,datum,naz,jmj,str(kolicina,6,1)
                nCol1:=pcol()+1
             endif
             if cPromj <> "3"
               @ prow(),ncol1    SAY nabvr pict gpici
               @ prow(),pcol()+1 SAY otpvr pict gpici
               @ prow(),pcol()+1 SAY amp pict gpici
               @ prow(),pcol()+1 SAY otpvr+amp pict gpici
               @ prow(),pcol()+1 SAY nabvr-otpvr-amp pict gpici
               nDug3+=nabvr; nPot31+=otpvr
               nPot32+=amp
             endif
             if cPromj $ "23"  // prikaz promjena
                select promj; hseek os->id
                do while !eof() .and. id==os->id .and. datum<=gDatObr
                   ? space(5),space(len(id)),space(len(os->idrj)),datum,opis
                      n1:=0; n2:=amp
                   @ prow(),ncol1    SAY nabvr pict gpici
                   @ prow(),pcol()+1 SAY otpvr pict gpici
                   @ prow(),pcol()+1 SAY amp pict gpici
                   @ prow(),pcol()+1 SAY otpvr+amp pict gpici
                   @ prow(),pcol()+1 SAY nabvr-amp-otpvr pict gpici
                   nDug3+=nabvr; nPot31+=otpvr
                   nPot32+=amp
                  skip
                enddo
                select os
             endif
           endif


         skip
      enddo
      if prow()>62; FF; Zagl3(); endif
      ? m
      ? " ukupno ",cidamort
      @ prow(),ncol1    SAY ndug3 pict gpici
      @ prow(),pcol()+1 SAY npot31 pict gpici
      @ prow(),pcol()+1 SAY npot32 pict gpici
      @ prow(),pcol()+1 SAY npot31+npot32 pict gpici
      @ prow(),pcol()+1 SAY ndug3-npot31-npot32 pict gpici
      ? m
      nDug2+=nDug3; nPot21+=nPot31; nPot22+=nPot32
      if !empty(qidAm); exit; endif
    enddo
    if !empty(qidAm); exit; endif
    // if prow()>62; FF; Zagl3(); endif
    // ? m
    // ? " UKUPNO ",cidam
    // @ prow(),ncol1    SAY ndug2 pict gpici
    // @ prow(),pcol()+1 SAY npot21 pict gpici
    // @ prow(),pcol()+1 SAY npot22 pict gpici
    // @ prow(),pcol()+1 SAY npot21+npot22 pict gpici
    // @ prow(),pcol()+1 SAY ndug2-npot21-npot22 pict gpici
    // ? m
    nDug+=nDug2; nPot1+=nPot21; nPot2+=nPot22
enddo
if empty(qidAm)
if prow()>60; FF; Zagl3(); endif
?
? m
? " U K U P N O :"
@ prow(),ncol1    SAY ndug pict gpici
@ prow(),pcol()+1 SAY npot1 pict gpici
@ prow(),pcol()+1 SAY npot2 pict gpici
@ prow(),pcol()+1 SAY npot1+npot2 pict gpici
@ prow(),pcol()+1 SAY ndug-npot1-npot2 pict gpici
? m
endif
FF
end print

closeret
*}
