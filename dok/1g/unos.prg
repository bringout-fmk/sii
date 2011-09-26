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


function Unos()
*{
private cId:=space(10),cIdRj:=space(4)

Box(,19,77)
do while .t.

O_K1
O_OS
O_RJ
O_KONTO
O_AMORT
O_REVAL
O_PROMJ
set cursor on

 IF gIBJ=="D"

   @ m_x+1,m_y+2 SAY "UNOS PROMJENA NAD SITNIM INVENTAROM"
   @ m_x+3,m_y+2 SAY "Sitan inventar:" GET cId  VALID P_OS(@CID,3,35)
   @ m_x+4,m_y+2 SAY "Radna jednica: " GET cIdRj  ;
      WHEN {|| cIdRj:=os->idrj,.t. }  ;
      VALID P_RJ(@CIDRJ,4,35)
   read; ESC_BCR

 ELSE

   DO WHILE .t.

     @ m_x+1,m_y+2 SAY "UNOS PROMJENA NAD SITNIM INVENTAROM"
     @ m_x+3,m_y+2 SAY "Sitan inventar:" GET cId
     @ m_x+4,m_y+2 SAY "Radna jednica: " GET cIdRj
     read; ESC_BCR
     SELECT OS
     SEEK cId
     DO WHILE !EOF() .and. cId==OS->ID .and. cIdRJ!=OS->IDRJ
       SKIP 1
     ENDDO
     IF cID!=OS->ID .or. cIdRJ!=OS->IDRJ
       Msg("Izabrani sitan inventar ne postoji!",5)
     ELSE
       SELECT RJ
       SEEK cIdRj
       @ m_x+3,m_y+30 SAY OS->naz
       @ m_x+4,m_y+30 SAY RJ->naz
       EXIT
     ENDIF

   ENDDO

 ENDIF

 select os
 if cidrj<>os->idrj
   replace idrj with cidrj
 endif
 @ m_x+5,m_y+2 SAY "Datum nabavke: "; ?? os->datum
 if !empty(os->datotp)
   @ m_x+5,m_y+38 SAY "Datum otpisa: "; ?? os->datotp
 endif
 @ m_x+6,m_y+2 SAY "Nabavna vr.:"; ?? transform(nabvr,gpici)
 @ m_x+6,col()+2 SAY "Ispravka vr.:"; ?? transform(otpvr,gpici)
 private dDatNab:=os->datum
 private dDatOtp:=os->datotp,cOpisOtp:=os->opisotp
 select promj

ImeKol:={}
AADD(ImeKol,{ "DATUM",         {|| DATUM}                          })
AADD(ImeKol,{ "OPIS",          {|| OPIS}                          })
//AADD(ImeKol,{ "tip",           {|| tip}                          })
AADD(ImeKol,{ PADR("Nabvr",15), {|| transform(nabvr,gpici)}     })
AADD(ImeKol,{ PADR("OtpVr",15), {|| transform(otpvr,gpici)}     })
Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on

@ m_x+20,m_y+2 SAY "<ENT> Ispravka, <c-T> Brisi, <c-N> Nove prom, <c-O> Otpis, <c-I> Novi ID"

BrowseKey(m_x+8,m_y+1,m_x+19,m_y+77,ImeKol,{|Ch| Edos(Ch)},"id==cid",cid,2,)

close all
enddo
BoxC()

closeret
return
*}



function EdOS(Ch)
local cDn:="N",nRet:=DE_CONT
do case
  case Ch==K_ENTER .or. Ch==K_CTRL_N
     IF CH=K_CTRL_N
       APPEND BLANK
     ENDIF
     Scatter()
     Box(,5,50)
       @ m_x+1,m_y+2 SAY "Datum:"  get _datum valid V_Datum()
       @ m_x+2,m_y+2 SAY "Opis:"  get _opis
       @ m_x+4,m_y+2 SAY "nab vr" get _nabvr
       @ m_x+5,m_y+2 SAY "OTP vr" get _otpvr
       read
     BoxC()
     _ID:=cid
     Gather()
     nRet:=DE_REFRESH
  case Ch==K_CTRL_T
     if pitanje(,"Sigurno zelite izbrisati promjenu ?","N")=="D"
       delete
     endif
     return DE_REFRESH
  case Ch==K_CTRL_O
     select os
     nKolotp:=kolicina
     Box(,5,50)
       @ m_x+1,m_y+2 SAY "Otpis sitnog inventara"
       @ m_x+3,m_y+2 SAY "Datum: " GET dDatOtp  valid dDatOtp>dDatNab .or. empty(dDatOtp)
       @ m_x+4,m_y+2 SAY "Opis : " GET cOpisOtp
       if kolicina>1
        @ m_x+5,m_y+2 SAY "Kolicina koja se otpisuje:" GET nkolotp pict "999999.99" valid nkolotp<=kolicina .and. nkolotp>=1
       endif
       read
     BoxC()
     ESC_RETURN  DE_CONT
     fRastavljeno:=.f.
     if nkolotp<kolicina
       select os
       scatter()
       nNabVrJ:=_nabvr/_kolicina
       nOtpVrJ:=_otpvr/_kolicina

       // postojeci inv broj
       _kolicina:=_kolicina-nkolotp
       _nabvr:=nnabvrj*_kolicina
       _otpvr:=notpvrj*_kolicina
       gather()

       // novi inv broj
       appblank2(.f.,.t.)  //NC DL
       _kolicina:=nkolotp
       _nabvr:=nnabvrj*nkolotp
       _otpvr:=notpvrj*nkolotp
       _id:=left(_id,9)+"O"
       _datotp:=ddatotp
       _opisotp:=copisotp
       gather()

       fRastavljeno:=.t.
     else
      select os
      replace datotp with ddatotp,opisotp with cOpisOtp
     endif
     select promj
     @ m_x+5,m_y+38 SAY "Datum otpisa: "; ?? os->datotp
     if frastavljeno
         Msg("Postojeci inv broj je rastavljen na dva-otpisani i neotpisani")
         return DE_ABORT
     else
        RETURN DE_REFRESH
     endif
  case Ch==K_CTRL_I
     Box(,4,50)
       private cNovi:=space(10)
       @ m_x+1,m_y+2 SAY "Promjena inventurnog broja:"
       @ m_x+3,m_y+2 SAY "Novi inventurni broj:" GET cnovi valid !empty(cnovi)
       read
     BoxC()
     ESC_RETURN DE_CONT

       select os
       seek cnovi
       if found()
         Beep(1)
         Msg("Vec postoji inventar sa istim inventurnim brojem !")
       else
         select promj
         seek cid
         private nRec:=0
         do while !eof() .and. cid==id
           skip; nRec:=recno(); skip -1
           replace id with cnovi
           go nRec
         enddo
         seek cnovi

         select os
         seek cid
         replace id with cnovi
         cId:=cnovi
       endif
       select promj
       RETURN DE_REFRESH
  otherwise
     return DE_CONT
endcase
return nRet
*}


function V_Datum()
local nRet:=.t.

if _datum<=dDatNab
 Beep(1)
 Msg("Datum promjene mora biti veci od datuma nabavke !")
 nRet:=.f.
endif
if !empty(dDatOtp) .and. _Datum>=dDatOtp
 Beep(1)
 Msg("Datum promjene mora biti manji od datuma otpisa !")
 nRet:=.f.
endif
return nRet


function Pars0()

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





