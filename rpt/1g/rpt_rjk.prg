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


function PregRjKon()
local cIdKonto:=qidkonto:=space(7), cidsk:="", ndug:=ndug2:=npot:=npot2:=ndug3:=npot3:=0
local nCol1:=10
O_KONTO
O_RJ
O_PROMJ
O_OS

cIdrj:=space(4)

cON:="N"
cPromj:="2"
cDodaj:="1"
cPocinju:="N"
dDatOd:=ctod("")
dDatDo:=date()
cDatper:="N"
cFiltSadVr:="0"
cFiltK1:=SPACE(40)

Box(,18,77)
 DO WHILE .t.
  @ m_x+1,m_y+2 SAY "Radna jednica (prazno - svi):" get cidrj valid empty(cIdRj) .or. p_rj(@cIdrj)
  @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
  @ m_x+2,m_y+2 SAY "Konto (prazno - svi):" get qIdKonto pict "@!" valid empty(qidkonto) .or. P_Konto(@qIdKonto)
  @ m_x+3,m_y+2 SAY "Prikaz svog sit.inv.( )   /   neotpisanog (N)   / otpisanog  (O) "
  @ m_x+4,m_y+2 SAY "/novonabavljenog  (B) / iz proteklih godina (G)" get cON valid con $ "ONBG " pict "@!"
  @ m_x+5,m_y+2 SAY "Za sitan inventar prikazati vrijednost:"
  @ m_x+6,m_y+2 SAY "1 - bez promjena"
  @ m_x+7,m_y+2 SAY "2 - osnovni iznos + promjene"
  @ m_x+8,m_y+2 SAY "3 - samo promjene           " GET cPromj valid cpromj $ "123"
  @ m_x+10, m_y+2 SAY "1 - prikaz bez uracunate amortizacije i revalor:"
  @ m_x+11,m_y+2 SAY "2 - sa uracunatom amortizacijom i revalor      :"
  @ m_x+12,m_y+2 SAY "3 - samo amortizacije                          :"
  @ m_x+13,m_y+2 SAY "4 - samo revalorizacije                        :"  GET cDodaj valid cDodaj $ "1234"
  @ m_x+15,m_y+2 SAY "Pregled za datumski period :" GET cDatPer valid cdatper $ "DN" pict "@!"
  @ m_x+16,m_y+2 SAY "Filter po sadasnjoj vr.(0-sve,1-samo koja je imaju,2-samo koja je nemaju):" GET cFiltSadVr valid cFiltSadVr $ "012" pict "9"
  @ m_x+17,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
  read; ESC_BCR
  if cDatPer=="D"
    @ m_x+18,m_y+2 SAY "Od datuma " GET dDatOd
    @ m_x+18,col()+2 Say "do" GET dDatDo
    read; ESC_BCR
  endif
  aUsl1:=Parsiraj(cFiltK1,"K1")
  if aUsl1<>NIL; exit; endif
 ENDDO
BoxC()

if cDatPer=="D"
  select promj
  PRIVATE cFilt1 := "DATUM>="+cm2str(dDatOd)+".and.DATUM<="+cm2str(dDatDo)
  set filter to &cFilt1
  select os
endif
if !EMPTY(cFiltK1)
  select os
  set filter to &aUsl1
endif

if empty(qidkonto); qidkonto:=""; endif
if empty(cIdrj); cidrj:=""; endif
if cpocinju=="D"
  cIdRj:=trim(cidrj)
endif

start print cret
private nStr:=0  // strana
select rj; hseek cidrj; select os
P_10CPI
? gTS+":",gnFirma
if !empty(cidrj)
 ? "Radna jedinica:",cidrj,rj->naz
endif
P_COND
? "SII: Pregled sitnog inventara po kontima "
if cDodaj=="1"
  ?? "(BEZ uracunate Am. i Rev.)"
elseif cdodaj=="2"
  ?? "(SA uracunatom Am. i Rev)"
elseif cdodaj=="3"
  ?? "(samo efekata amortizacije)"
elseif cdodaj=="4"
  ?? "(samo efekata revalorizacije)"
endif
?? "     Datum:",gDatObr

if !EMPTY(cFiltK1); ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"; endif


private m:="----- ---------- ---- -------- ------------------------------ --- ------"+REPL(" "+REPL("-",LEN(gPicI)),3)


if empty(cidrj)
  select os; set order to 4 //"OSi4","idkonto+idrj+id"
  seek qidkonto
else
  select os; set order to  3 //"OSi3","idrj+idkonto+id"
  seek cidrj+qidkonto
endif

private nrbr:=0
nDug:=nPot:=0
Zagl2()
n1:=n2:=0
do while !eof() .and. (idrj=cidrj .or. empty(cidrj))
   cIdSK:=left(idkonto,3)
   nDug2:=nPot2:=0
   do while !eof() .and. (idrj=cidrj .or. empty(cidrj))  .and. left(idkonto,3)==cidsk
      cIdKonto:=idkonto
      nDug3:=nPot3:=0
      do while !eof() .and. (idrj=cidrj .or. empty(cidrj))  .and. idkonto==cidkonto
         if datum>gDatObr // preskoci sredstva van obracuna
            skip; loop
         endif
         if prow()>63; FF; Zagl2(); endif
         if (cON=="N" .and. empty(datotp)) .or. ;
            (con=="O"  .and. !empty(datotp)) .or. ;
            (con=="B"  .and. year(datum)=year(gdatobr)) .or.;
            (con=="G"  .and. year(datum)<year(gdatobr)) .or.;
             empty(con)

           fIma:=.t.
           if cDatPer=="D"
              if datum>=dDatOd .and. datum<=dDatDo
               fIma:=.t.
              else
               fIma:=.f.
              endif
              select promj  // provjeri promjene unutar datuma
              hseek os->id
              do while !eof() .and. os->id=id
                if datum>=dDatOd .and. datum<=dDatDo
                  fIma:=.t.
                endif
                skip
              enddo
              select os
           endif

           if cpromj=="3"  // ako zelim samo promjene vidi ima li za sr.
                          // uopste promjena
               select promj; hseek os->id
               fIma:=.f.
               do while !eof() .and. id==os->id .and. datum<=gDatObr
                if (cON=="N" .and. empty(os->datotp)) .or. ;
                  (con="O"  .and. !empty(os->datotp)) .or. ;
                  (con=="B"  .and. year(os->datum)=year(gdatobr)) .or. ;
                  (con=="G"  .and. year(datum)<year(gdatobr)) .or.;
                  empty(con)
                 fIma:=.t.
                endif
                skip
               enddo
               select os
           endif


           // ovaj dio nam sad slu§i samo da saznamo ima li sredstvo
           // sadaçnju vrijednost
           // ------------------------------------------------------
           lImaSadVr:=.f.
           if cPromj <> "3"
            if cDatPer="N"  .or. (cDatPer="D" .and. datum>=dDatOd .and. datum<=dDatDo)
             if cdodaj=="1"
                n1:=nabvr; n2:=otpvr
             elseif cdodaj=="2"
                n1:=nabvr+revd; n2:=otpvr+amp+revp
             elseif cdodaj=="3"
                n1:=0; n2:=amp
             elseif cdodaj=="4"
                n1:=revd; n2:=revp
             endif
             if n1-n2>0
               lImaSadVr:=.t.
             endif
            endif // prikaz za datumski period, a OS ne pripada tom periodu
           endif
           if cPromj $ "23"  // prikaz promjena
              select promj; hseek os->id
              do while !eof() .and. id==os->id .and. datum<=gDatObr
                if (cON=="N" .and. empty(os->datotp)) .or. ;
                  (con="O"  .and. !empty(os->datotp)) .or.;
                  (con=="B"  .and. year(os->datum)=year(gdatobr)) .or. ;
                  (con=="G"  .and. year(datum)<year(gdatobr)) .or.;
                  empty(con)
                 if cdodaj=="1"
                    n1:=nabvr; n2:=otpvr
                 elseif cdodaj=="2"
                    n1:=nabvr+revd; n2:=otpvr+amp+revp
                 elseif cdodaj=="3"
                    n1:=0; n2:=amp
                 elseif cdodaj=="4"
                    n1:=revd; n2:=revp
                 endif
                 if n1-n2>0
                   lImaSadVr:=.t.
                 endif
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
              if cDatPer="N"  .or. (cDatPer="D" .and. datum>=dDatOd .and. datum<=dDatDo)
               if cdodaj=="1"
                  n1:=nabvr; n2:=otpvr
               elseif cdodaj=="2"
                  n1:=nabvr+revd; n2:=otpvr+amp+revp
               elseif cdodaj=="3"
                  n1:=0; n2:=amp
               elseif cdodaj=="4"
                  n1:=revd; n2:=revp
               endif
               @ prow(),pcol()+1 SAY n1 pict gpici
               @ prow(),pcol()+1 SAY n2 pict gpici
               @ prow(),pcol()+1 SAY n1-n2 pict gpici
               nDug3+=n1; nPot3+=n2
              endif // prikaz za datumski period, a OS ne pripada tom periodu
             endif
             if cPromj $ "23"  // prikaz promjena
                select promj; hseek os->id
                do while !eof() .and. id==os->id .and. datum<=gDatObr
                  if (cON=="N" .and. empty(os->datotp)) .or. ;
                    (con="O"  .and. !empty(os->datotp)) .or.;
                    (con=="B"  .and. year(os->datum)=year(gdatobr)) .or. ;
                    (con=="G"  .and. year(datum)<year(gdatobr)) .or.;
                    empty(con)
                   ? space(5),space(len(id)),space(len(os->idrj)),datum,opis
                   if cdodaj=="1"
                      n1:=nabvr; n2:=otpvr
                   elseif cdodaj=="2"
                      n1:=nabvr+revd; n2:=otpvr+amp+revp
                   elseif cdodaj=="3"
                      n1:=0; n2:=amp
                   elseif cdodaj=="4"
                      n1:=revd; n2:=revp
                   endif
                   @ prow(),ncol1  SAY n1  pict gpici
                   @ prow(),pcol()+1 SAY n2  pict gpici
                   @ prow(),pcol()+1 SAY n1-n2  pict gpici
                   nDug3+=n1; nPot3+=n2
                  endif
                  skip
                enddo
                select os
             endif
           endif

         endif
         ** (cON=="N" .and. empty(datotp)) .or. ;
         ** (con=="O"  .and. !empty(datotp)) .or. ;
         ** (con=="B"  .and. year(datum)=year(gdatobr)) .or.;
         **  empty(con)
         skip
      enddo
      if prow()>62; FF; Zagl2(); endif
      ? m
      ? " ukupno ",cidkonto
      @ prow(),ncol1 SAY nDug3 pict gpici
      @ prow(),pcol()+1 SAY npot3 pict gpici
      @ prow(),pcol()+1 SAY ndug3-npot3 pict gpici
      ? m
      nDug2+=nDug3; nPot2+=nPot3
      if !empty(qidkonto); exit; endif
    enddo
    if !empty(qidkonto); exit; endif
    if prow()>62; FF; Zagl2(); endif
    ? m
    ? " UKUPNO ",cidsk
    @ prow(),ncol1 SAY nDug2 pict gpici
    @ prow(),pcol()+1 SAY npot2 pict gpici
    @ prow(),pcol()+1 SAY ndug2-npot2 pict gpici
    ? m
     nDug+=nDug2; nPot+=nPot2
enddo
if empty(qidkonto)
if prow()>60; FF; Zagl2(); endif
?
? m
? " U K U P N O :"
@ prow(),ncol1 SAY nDug pict gpici
@ prow(),pcol()+1 SAY npot pict gpici
@ prow(),pcol()+1 SAY ndug-npot pict gpici
? m
endif
FF
end print

closeret
*}



function Zagl2()
P_12CPI
if con="N"
  ? "PRIKAZ NEOTPISANOG SITNOG INVENTARA:"
elseif con=="B"
  ? "PRIKAZ NOVONABAVLJENOG SITNOG INVENTARA:"
elseif con=="G"
  ? "PRIKAZ SITNOG INVENTARA IZ PROTEKLIH GODINA:"
elseif con=="O"
  ? "PRIKAZ OTPISANOG SITNOG INVENTARA:"
elseif   con==" "
  ? "PRIKAZ SVOG SITNOG INVENTARA:"
endif
P_COND
@ prow(),125 SAY "Str."+str(++nStr,3)
? m
? " Rbr.  Inv.broj   RJ    Datum    S.inventar                   jmj  kol  "+" "+PADC("NabVr",LEN(gPicI))+" "+PADC("OtpVr",LEN(gPicI))+" "+PADC("SadVr",LEN(gPicI))
? m
return
*}

