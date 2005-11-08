#include "\dev\fmk\sii\sii.ch"


function PregRj()
*{
O_RJ
O_OS

cIdrj:=space(4)
cON:="N"
cKolP:="N"
cPocinju:="N"

cBrojSobe:=space(6)
lBrojSobe:=.f.

Box(,6,77)
 @ m_x+1,m_y+2 SAY "Radna jednica:" get cidrj valid p_rj(@cIdrj)
 @ m_x+1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
 @ m_x+2,m_y+2 SAY "Prikaz svih neotpisanih (N) / otpisanih(O) /"
 @ m_x+3,m_y+2 SAY "samo novonabavljenih (B)    / iz proteklih godina (G)"   get cON pict "@!" valid con $ "ONBG"
 @ m_x+4,m_y+2 SAY "Prikazati kolicine na popisnoj listi D/N" GET cKolP valid cKolP $ "DN" pict "@!"

 if fieldpos("brsoba")<>0
  lBrojSobe:=.t.
  @ m_x+6,m_y+2 SAY "Broj sobe (prazno sve) " GET cBrojSobe  pict "@!"
 endif

 read; ESC_BCR
BoxC()

if lBrojSobe .and. EMPTY(cBrojSobe)
  lBrojSobe := ( Pitanje(,"Zelite li da bude prikazan broj sobe? (D/N)","N") == "D" )
endif

if cpocinju=="D"
  cIdRj:=trim(cidrj)
endif
start print cret

if lBrojSobe .and. EMPTY(cBrojSobe)
  m:="----- ------ ---------- ----------------------------  --- ------- -------------"
  select os; set order to  2 //idrj+id+dtos(datum)
  INDEX ON idrj+brsoba+id+dtos(datum) TO "TMPOS"
else
  m:="----- ---------- ----------------------------  --- ------- -------------"
  select os; set order to  2 //idrj+id+dtos(datum)
endif


ZglPrj()
seek cidrj
private nrbr:=0
do while !eof() .and. idrj=cidrj

 if (cON="B" .and. year(gdatobr)<>year(datum))  // nije novonabavljeno
   skip ; loop                                  // prikazi samo novonabavlj.
 endif

 if (cON="G" .and. year(gdatobr)=year(datum))  // iz protekle godine
   skip; loop                                   // prikazi samo novonabavlj.
 endif

 if (!empty(datotp) .and. year(datotp)=year(gdatobr)) .and. cON $ "NB"
     // otpisano sredstvo , a zelim prikaz neotpisanih
     skip ; loop
 endif

 if (empty(datotp) .or. year(datotp)<year(gdatobr)) .and. cON=="O"
     // neotpisano, a zelim prikaz otpisanih
     skip ; loop
 endif

 if !empty(cBrojsobe)
    if cbrojsobe<>os->brsoba
       skip; loop
    endif
 endif

 if prow()>62; FF; ZglPrj(); endif

 if lBrojSobe .and. EMPTY(cBrojSobe)
   ? str(++nrbr,4)+".",brsoba,id,naz,jmj
 else
   ? str(++nrbr,4)+".",id,naz,jmj
 endif

 if cKolP=="D"
  @  prow(),pcol()+1 SAY str(kolicina,6,1)
 else
  @  prow(),pcol()+1 SAY space(6)
 endif
 @ prow(),pcol()+1 SAY " ____________"
 skip
enddo

? m

if prow()>56; FF; ZglPrj(); endif
?
? "     Zaduzeno lice:                                     Clanovi komisije:"
?
? "     _______________                                  1.___________________"
?
? "                                                      2.___________________"
?
? "                                                      3.___________________"
FF
end print

closeret
return
*}



function ZglPrj()
*{
LOCAL nArr:=SELECT()
P_10CPI
?? UPPER(gTS)+":",gNFirma
?
? "SII: Pregled "
if cON=="N"
   ?? "sitnog inventara u upotrebi"
else
   ?? "sitnog inventara otpisanog u toku godine"
endif
select rj; seek cidrj; select (nArr)
?? "     Datum:",gDatObr
? "Radna jedinica:",cidrj,rj->naz
if cpocinju=="D"
  ?? space(6),"(SVEUKUPNO)"
endif

if !empty(cBrojSobe)
  ?
  ? "Prikaz za sobu br:", cBrojSobe
  ?
endif

? m
if lBrojSobe .and. EMPTY(cBrojSobe)
 ? " Rbr. Br.sobe Inv.broj        S.inventar              jmj  kol  "
else
 ? " Rbr.  Inv.broj        S.inventar              jmj  kol  "
endif
? m
return
*}

