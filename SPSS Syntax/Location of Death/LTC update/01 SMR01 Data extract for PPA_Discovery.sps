****************************************************
SMR01 data for UAT of PPA Indicator
***************************************************.
*******************************************
SMR01 Data
Source: Linked catalogue
*******************************************.
********************************************
This program is run locally on your pc
********************************************.
***********************************************************************************************************************************************************************************************************.
*** This program is a modified version of that created at the same time that the indicator was built and redefines the definition of spells. I think this is a more correct code but may not be ***.
*** doing the same as Navigator currently does (Aug 2010). Investigations are ongoing as to how Navigator actually defines spells etc. as the results are never exactly the same ***.
*** and it cannot all be down to population differences ***.
***********************************************************************************************************************************************************************************************************.

Input program.
data list file= '/conf/linkage/catalog/catalog_12012016.cis'
 	/recid 25-27(a) dodyy 17-20 error 750 deleted 784(a) dod 17-24.

* READ IN COPPISH SMR01.
do if (recid eq '01B' and error = 0 and deleted <> 'D') and dod ge 20120401.
reread.
DATA LIST / patid 1-8 cis 94-98 doa 9-16 doayy 9-12 doamm 13-14 doadd 15-16 dodyy 17-20 dodmm 21-22 doddd 23-24 
       spec 290-292(a) sigfac 294-295(a) hosp 285-289(a) cons 302-309(a) 
       d1c13 388-390(a) d2c13 394-396(a) d3c13 400-402(a) d4c13 406-408(a) d5c13 412-414(a) d6c13 418-420(a)
       d1c14 388-391(a) d2c14 394-397(a) d3c14 400-403(a) d4c14 406-409(a) d5c14 412-415(a) d6c14 418-421(a)
       op1a13 424-426(a) op1a14 424-427(a) op1b13 428-430(a) op1b14 428-431(a)
       op2a13 448-450(a) op2a14 448-451(a) op2b13 452-454(a) op2b14 452-455(a)
       op3a13 472-474(a) op3a14 472-475(a) op3b13 476-478(a) op3b14 476-479(a)
       op4a13 496-498(a) op4a14 496-499(a) op4b13 500-502(a) op4b14 500-503(a)
       hrg35 746-748(a) hrg4 692-696(a) ipdc 559(a) tadm 562 hbres 100(a) hbrescode 541-549(a) council 713-714 age 729-731
       admt 352-353 hbt 285(a) hbtcode 656-664(a) sex 205 praccode 261-266(a) hbpraccode 674-682(a) 
       stay 741-745 distype 379-380(a) diag1 388-393(a) CHP_Code 523-531(a). 
end case.
end if.
end input program.
*n of cases 100000.
EXECUTE.

*save outfile='/conf/discovery/02_Developing/SMR01/PPA/Data/Temp/temp1.sav'
        keep=patid cis dod hbt hbtcode hbrescode CHP_Code ipdc tadm d1c14 d2c14 d3c14 d4c14 d5c14 d6c14 op1a13.

* Remove any leading blanks from consultant codes  *.
if substr(cons,1,1)=' ' cons=substr(cons,2,7).
*exe.

*** PPA includes activity from all HBRES. Long stayers (>90 days) are included. ***

*get file='\\stats\navigator\Extract prog\outputs\UAT_extract_for SMR01 indicators_Feb14.sav'
 /keep doa dod doayy doamm doadd dodyy dodmm doddd  patid cis ipdc tadm age sex hbres council praccode hosp d1c14 to d6c14 op1a13 stay.
*EXECUTE .

string admtype (a8).
recode tadm (0 thru 2 = 'elec') (else = 'non-elec') into admtype.

*** keep=1 flags the record should be kept ***.
compute keep=0.

**** creating a counter for the episodes in the CIS ***.
compute episinspell = 1.

if patid = lag (patid) and cis = lag(cis) episinspell=lag(episinspell)+1.

*** looking for CISs that begin with a transfer or emergency admission only, within timeframe of interest ***.

*if episinspell = 1 and dod>=20080401 and dod<=20130630 and admtype='non-elec' and ipdc = 'I' keep = 1.
if episinspell = 1 and admtype='non-elec' and ipdc = 'I' keep = 1.

*** selects rest of CIS to keep ***.

if episinspell >1 keep = lag(keep).
*exe.

*** removes elective components of CISs as their associated stays should not contribute to the bed day calculation***.
*** CH the selection below is incorrect, as patient admitted as an elective may have a PPA condition within a subsequent transfer.

*select if keep=1 and admtype='non-elec'.
select if admtype='non-elec'.
*EXECUTE .

save outfile='/conf/discovery/02_Developing/SMR01/PPA/Data/Temp/PPA_Extract.sav'/COMPRESSED.

*Switch to local server.

get file='\\Stats\discovery\02_Developing\SMR01\PPA\Data\Temp\PPA_Extract.sav'.

*select if dod >=20130401 and dod <=20140331.
*select if ipdc ne 'D'.

*Set op exlusions for selection below.

*Hyper / CHF main ops.
if range (op1a13, 'K01', 'K50') or any (op1a13, 'K56', 'K60', 'K61') opexc=1.
recode opexc (missing=0).

string cond1 to cond5 (a47).

compute I=1.

*Attach conditions to episodes. With syntax below, patient can have up to five different conditions per episode.

*ENT.
do if any (d1c13, 'H66', 'J06') or any (d1c14, 'J028', 'J029', 'J038', 'J039', 'J321').
. compute cond1='Ear, nose and throat infections'.
end if.

*Dental.
do if range (d1c13, 'K02', 'K06') or d1c13='K08'.
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Dental conditions'.
. if I=2 cond2='Dental conditions'.
. if I=3 cond3='Dental conditions'.
. if I=4 cond4='Dental conditions'.
. if I=5 cond5='Dental conditions'.
end if.

compute I=1.

*Conv.
do if any (d1c13, 'G40', 'G41', 'R56', 'O15').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Convulsions and epilepsy'.
. if I=2 cond2='Convulsions and epilepsy'.
. if I=3 cond3='Convulsions and epilepsy'.
. if I=4 cond4='Convulsions and epilepsy'.
. if I=5 cond5='Convulsions and epilepsy'.
end if.

compute I=1.

*Gang.
do if (d1c13='R02' or d2c13='R02' or d3c13='R02' or d4c13='R02' or d5c13='R02' or d6c13='R02').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Gangrene'.
. if I=2 cond2='Gangrene'.
. if I=3 cond3='Gangrene'.
. if I=4 cond4='Gangrene'.
. if I=5 cond5='Gangrene'.
end if.

compute I=1.

*Nutridef.
do if any (d1c13, 'E40', 'E41', 'E43') or any (d1c14, 'E550', 'E643', 'M833').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Nutritional deficiencies'.
. if I=2 cond2='Nutritional deficiencies'.
. if I=3 cond3='Nutritional deficiencies'.
. if I=4 cond4='Nutritional deficiencies'.
. if I=5 cond5='Nutritional deficiencies'.
end if.

compute I=1.

*Dehyd.
do if d1c13='E86' or any (d1c14, 'K522', 'K528', 'K529').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Dehydration and gastroenteritis'.
. if I=2 cond2='Dehydration and gastroenteritis'.
. if I=3 cond3='Dehydration and gastroenteritis'.
. if I=4 cond4='Dehydration and gastroenteritis'.
. if I=5 cond5='Dehydration and gastroenteritis'.
end if.

compute I=1.

*Pyelon.
do if range (d1c13, 'N10', 'N12').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Pyelonephritis'.
. if I=2 cond2='Pyelonephritis'.
. if I=3 cond3='Pyelonephritis'.
. if I=4 cond4='Pyelonephritis'.
. if I=5 cond5='Pyelonephritis'.
end if.

compute I=1.

*Perf.
do if any (d1c14,'K250', 'K251', 'K252', 'K254', 'K255', 'K256', 'K260', 'K261',
                 'K262', 'K264', 'K265', 'K266', 'K270', 'K271', 'K272', 'K274',
                 'K275', 'K276', 'K280', 'K281', 'K282', 'K284', 'K285', 'K286').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Perforated bleeding ulcer'.
. if I=2 cond2='Perforated bleeding ulcer'.
. if I=3 cond3='Perforated bleeding ulcer'.
. if I=4 cond4='Perforated bleeding ulcer'.
. if I=5 cond5='Perforated bleeding ulcer'.
end if.

compute I=1.

*Cell.
do if (any (d1c13, 'L03', 'L04') or any (d1c14, 'L080', 'L088', 'L089', 'L980'))
         and not any (op1a13, 'S06', 'S57', 'S68', 'S70', 'W90', 'X11').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Cellulitis'.
. if I=2 cond2='Cellulitis'.
. if I=3 cond3='Cellulitis'.
. if I=4 cond4='Cellulitis'.
. if I=5 cond5='Cellulitis'.
end if.

compute I=1.

*Pelvic.
do if any (d1c13, 'N70', 'N73').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Pelvic inflamatory disease'.
. if I=2 cond2='Pelvic inflamatory disease'.
. if I=3 cond3='Pelvic inflamatory disease'.
. if I=4 cond4='Pelvic inflamatory disease'.
. if I=5 cond5='Pelvic inflamatory disease'.
end if.

compute I=1.

*Flu.
do if any (d1c13, 'J10', 'J11', 'J13') or any (d2c13, 'J10', 'J11', 'J13') or any (d3c13, 'J10', 'J11', 'J13') or any (d4c13, 'J10', 'J11', 'J13') or 
        any (d5c13, 'J10', 'J11', 'J13') or any (d6c13, 'J10', 'J11', 'J13') or (d1c14='J181' or d2c14='J181' or d3c14='J181' or d4c14='J181' or d5c14='J181' or d6c14='J181').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Influenza and pneumonia'.
. if I=2 cond2='Influenza and pneumonia'.
. if I=3 cond3='Influenza and pneumonia'.
. if I=4 cond4='Influenza and pneumonia'.
. if I=5 cond5='Influenza and pneumonia'.
end if.

compute I=1.

*Othvacc.
do if any (d1c13, 'A35', 'A36', 'A80', 'B05', 'B06', 'B26') or any (d2c13, 'A35', 'A36', 'A80', 'B05', 'B06', 'B26') or any (d3c13, 'A35', 'A36', 'A80', 'B05', 'B06', 'B26') or 
        any (d4c13, 'A35', 'A36', 'A80', 'B05', 'B06', 'B26') or any (d5c13, 'A35', 'A36', 'A80', 'B05', 'B06', 'B26') or any (d6c13, 'A35', 'A36', 'A80', 'B05', 'B06', 'B26') or
        any (d1c14, 'A370', 'A379','B161', 'B169') or any (d2c14, 'A370', 'A379','B161', 'B169') or any (d3c14, 'A370', 'A379','B161', 'B169') or any (d4c14, 'A370', 'A379','B161', 'B169') or 
        any (d5c14, 'A370', 'A379','B161', 'B169') or any (d6c14, 'A370', 'A379','B161', 'B169').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Other vaccine preventable'.
. if I=2 cond2='Other vaccine preventable'.
. if I=3 cond3='Other vaccine preventable'.
. if I=4 cond4='Other vaccine preventable'.
. if I=5 cond5='Other vaccine preventable'.
end if.

compute I=1.

*Iron.
do if any (d1c14, 'D501', 'D508', 'D509').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Iron deficiency anaemia'.
. if I=2 cond2='Iron deficiency anaemia'.
. if I=3 cond3='Iron deficiency anaemia'.
. if I=4 cond4='Iron deficiency anaemia'.
. if I=5 cond5='Iron deficiency anaemia'.
end if.

compute I=1.

*Asthma.
do if any (d1c13, 'J45', 'J46').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Asthma'.
. if I=2 cond2='Asthma'.
. if I=3 cond3='Asthma'.
. if I=4 cond4='Asthma'.
. if I=5 cond5='Asthma'.
end if.

compute I=1.

*Diabetes.
do if any (d1c14, 'E100', 'E101', 'E102', 'E103', 'E104', 'E105', 'E106', 'E107', 'E108', 'E110',
 'E111', 'E112', 'E113', 'E114', 'E115', 'E116', 'E117', 'E118', 'E120', 'E121',
 'E122', 'E123', 'E124', 'E125', 'E126', 'E127', 'E128', 'E130', 'E131', 'E132',
 'E133', 'E134', 'E135', 'E136', 'E137', 'E138', 'E140', 'E141', 'E142', 'E143',
 'E144', 'E145', 'E146', 'E147', 'E148')
or any (d2c14, 'E100', 'E101', 'E102', 'E103', 'E104', 'E105', 'E106', 'E107', 'E108', 'E110',
 'E111', 'E112', 'E113', 'E114', 'E115', 'E116', 'E117', 'E118', 'E120', 'E121',
 'E122', 'E123', 'E124', 'E125', 'E126', 'E127', 'E128', 'E130', 'E131', 'E132',
 'E133', 'E134', 'E135', 'E136', 'E137', 'E138', 'E140', 'E141', 'E142', 'E143',
 'E144', 'E145', 'E146', 'E147', 'E148')
or any (d3c14, 'E100', 'E101', 'E102', 'E103', 'E104', 'E105', 'E106', 'E107', 'E108', 'E110',
 'E111', 'E112', 'E113', 'E114', 'E115', 'E116', 'E117', 'E118', 'E120', 'E121',
 'E122', 'E123', 'E124', 'E125', 'E126', 'E127', 'E128', 'E130', 'E131', 'E132',
 'E133', 'E134', 'E135', 'E136', 'E137', 'E138', 'E140', 'E141', 'E142', 'E143',
 'E144', 'E145', 'E146', 'E147', 'E148')
or any (d4c14, 'E100', 'E101', 'E102', 'E103', 'E104', 'E105', 'E106', 'E107', 'E108', 'E110',
 'E111', 'E112', 'E113', 'E114', 'E115', 'E116', 'E117', 'E118', 'E120', 'E121',
 'E122', 'E123', 'E124', 'E125', 'E126', 'E127', 'E128', 'E130', 'E131', 'E132',
 'E133', 'E134', 'E135', 'E136', 'E137', 'E138', 'E140', 'E141', 'E142', 'E143',
 'E144', 'E145', 'E146', 'E147', 'E148')
or any (d5c14, 'E100', 'E101', 'E102', 'E103', 'E104', 'E105', 'E106', 'E107', 'E108', 'E110',
 'E111', 'E112', 'E113', 'E114', 'E115', 'E116', 'E117', 'E118', 'E120', 'E121',
 'E122', 'E123', 'E124', 'E125', 'E126', 'E127', 'E128', 'E130', 'E131', 'E132',
 'E133', 'E134', 'E135', 'E136', 'E137', 'E138', 'E140', 'E141', 'E142', 'E143',
 'E144', 'E145', 'E146', 'E147', 'E148')
or any (d6c14, 'E100', 'E101', 'E102', 'E103', 'E104', 'E105', 'E106', 'E107', 'E108', 'E110',
 'E111', 'E112', 'E113', 'E114', 'E115', 'E116', 'E117', 'E118', 'E120', 'E121',
 'E122', 'E123', 'E124', 'E125', 'E126', 'E127', 'E128', 'E130', 'E131', 'E132',
 'E133', 'E134', 'E135', 'E136', 'E137', 'E138', 'E140', 'E141', 'E142', 'E143',
 'E144', 'E145', 'E146', 'E147', 'E148').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Diabetes complications'.
. if I=2 cond2='Diabetes complications'.
. if I=3 cond3='Diabetes complications'.
. if I=4 cond4='Diabetes complications'.
. if I=5 cond5='Diabetes complications'.
end if.

compute I=1.

*Hypert.
do if (d1c13='I10' or d1c14='I119') and opexc = 0.
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Hypertension'.
. if I=2 cond2='Hypertension'.
. if I=3 cond3='Hypertension'.
. if I=4 cond4='Hypertension'.
. if I=5 cond5='Hypertension'.
end if.

compute I=1.

*Angina.
do if (d1c13='I20') and not any (op1a13, 'K40', 'K45', 'K49', 'K60', 'K65', 'K66').
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Angina'.
. if I=2 cond2='Angina'.
. if I=3 cond3='Angina'.
. if I=4 cond4='Angina'.
. if I=5 cond5='Angina'.
end if.

compute I=1.

*Copd.
do if (range (d1c13, 'J41', 'J44') or d1c13='J47') or (d1c13='J20' and (range (d2c13, 'J41', 'J44') or d2c13='J47')).
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='COPD'.
. if I=2 cond2='COPD'.
. if I=3 cond3='COPD'.
. if I=4 cond4='COPD'.
. if I=5 cond5='COPD'.
end if.

compute I=1.

*Chf.
do if (d1c13='I50' or d1c13='J81' or d1c14='I110') and opexc = 0.
. do repeat x=cond1 to cond5.
. if x<>'' I=(I+1).
. end repeat. 
. if I=1 cond1='Congestive Heart Failure'.
. if I=2 cond2='Congestive Heart Failure'.
. if I=3 cond3='Congestive Heart Failure'.
. if I=4 cond4='Congestive Heart Failure'.
. if I=5 cond5='Congestive Heart Failure'.
end if.

compute I=1.
exe.

freq var cond1.
freq var cond2.
freq var cond3.
freq var cond4.
freq var cond5.

*Select only episodes with PPA condition.
select if cond1 <> ''.

save outfile='\\Stats\discovery\02_Developing\SMR01\PPA\Data\Temp\PPA_Extract1.sav'/COMPRESSED.

get file='\\Stats\discovery\02_Developing\SMR01\PPA\Data\Temp\PPA_Extract1.sav'/
    keep=patid cis dod episinspell stay cond1 cond2 cond3 cond4 cond5.

*if patient has more than 1 ppa condition per episode, los is the same for both conditions.

if (cond1 <> '') los1=stay.
if (cond2 <> '') los2=stay.
if (cond3 <> '') los3=stay.
if (cond4 <> '') los4=stay.
if (cond5 <> '') los5=stay.

recode los1 to los5 (missing=0). 

rename variables (patid=LINK_NUMBER) (cis=CONTINUOUS_INPATIENT_STAY).

*This routine creates output in the format required for checking the data.

VARSTOCASES
  /MAKE ppa_cond FROM cond1 to cond5
  /MAKE ppa_stay FROM los1 to los5
  /KEEP=LINK_NUMBER CONTINUOUS_INPATIENT_STAY dod.

select if ppa_cond <> ''.
exe.

compute ppa_episode=1.

*Discharge date is last PPA episode in CIS.
aggregate outfile=*
             mode=addvariables/
             break=LINK_NUMBER CONTINUOUS_INPATIENT_STAY/ldod=max(dod).

delete variables dod.
exe.

aggregate outfile=*/
            break=LINK_NUMBER CONTINUOUS_INPATIENT_STAY ppa_cond /
            ppa_episode ppa_stay=sum(ppa_episode ppa_stay) / dod=max(ldod).

*CIS.
compute ppa_spell=1.

**** creating a counter for the episodes in the CIS ***.
compute episinspell = 1.

if LINK_NUMBER = lag (LINK_NUMBER) and CONTINUOUS_INPATIENT_STAY = lag(CONTINUOUS_INPATIENT_STAY) episinspell=lag(episinspell)+1.
exe.

sort cases by LINK_NUMBER CONTINUOUS_INPATIENT_STAY ppa_cond.

*select if dod >=20130401 and dod <=20140331.

*File for comparing with TDE.
save outfile='\\Stats\discovery\02_Developing\SMR01\PPA\Data\Temp\PPA_LINK_SPSS_Extract.sav'/COMPRESSED.

*********************************************************************************************************************************.
*Syntax to add CIS details back in to PPA records.
*********************************************************************************************************************************.

get file='\\Stats\discovery\02_Developing\SMR01\PPA\Data\Temp\PPA_Extract1.sav'/
    keep=patid cis doa dod spec sigfac hosp cons hrg35 hrg4 ipdc tadm hbres hbrescode
         council age admt hbt hbtcode sex praccode hbpraccode stay distype
         admtype doayy doamm doadd dodyy dodmm doddd CHP_Code.

sort cases by patid cis dod.

aggregate outfile=*/
            break=patid cis /
                  doa ipdc tadm age admt sex admtype doayy doamm doadd=first(doa ipdc tadm age admt sex admtype doayy doamm doadd) /
                  dod spec sigfac hosp cons hrg35 hrg4 hbres hbrescode hbpraccode council hbt hbtcode distype dodyy dodmm doddd CHP_Code
                  =last(dod spec sigfac hosp cons hrg35 hrg4 hbres hbrescode hbpraccode council hbt hbtcode distype dodyy dodmm doddd CHP_Code).

*** allocates financial year and population year (for population file matching) ***.

string finyear (a5).
do if (dod>=20120401 and dod<=20130331).
compute finyear='12/13'.
else if (dod>=20130401 and dod<=20140331).
compute finyear='13/14'.
else if (dod>=20140401 and dod<=20150331).
compute finyear='14/15'.
else if (dod>=20150401 and dod<=20160331).
compute finyear='15/16'.
end if.

freq var finyear.

*** allocates financial quarters ***.
numeric finqnum (f1).
recode dodmm (4 thru 6 = 1) (7 thru 9 = 2) (10 thru 12 = 3) (1 thru 3 = 4) into finqnum.

*** recodes age into 5 year agebands ***.
recode age (0 thru 4=1)(5 thru 9=2)(10 thru 14=3)(15 thru 19=4)
           (20 thru 24=5)(25 thru 29=6)(30 thru 34=7)(35 thru 39=8)
           (40 thru 44=9)(45 thru 49=10)(50 thru 54=11)(55 thru 59=12)
           (60 thru 64=13)(65 thru 69=14)(70 thru 74=15)(75 thru 79=16)
           (80 thru 84=17)(85 thru hi=18) into agegroup.

compute stay=0.
compute stay=yrmoda(dodyy,dodmm,doddd)-yrmoda(doayy,doamm,doadd).
exe.

rename variables (patid=LINK_NUMBER) (cis=CONTINUOUS_INPATIENT_STAY).

save outfile='\\Stats\discovery\02_Developing\SMR01\PPA\Data\Temp\PPA_Extract2.sav'/COMPRESSED.

get file='\\Stats\discovery\02_Developing\SMR01\PPA\Data\Temp\PPA_LINK_SPSS_Extract.sav'.

match files file=*/
           table='\\Stats\discovery\02_Developing\SMR01\PPA\Data\Temp\PPA_Extract2.sav'/
              by=LINK_NUMBER CONTINUOUS_INPATIENT_STAY.

save outfile='\\Stats\discovery\02_Developing\SMR01\PPA\Data\PPA_SPSS_Extract.sav'/COMPRESSED.

get file='\\Stats\discovery\02_Developing\SMR01\PPA\Data\PPA_SPSS_Extract.sav'.

*********************************************************************************************************************************.
*Add in Local Authority Lookup HBR.
*********************************************************************************************************************************.

get file='\\Stats\discovery\02_Developing\SMR01\PPA\Data\PPA_SPSS_Extract.sav'.

sort cases by council.

match files file=*/
           table='\\Stats\discovery\02_Developing\SMR01\PPA\Data\LA_HB_Lookup.sav'/
              by=council.

sort cases by LINK_NUMBER CONTINUOUS_INPATIENT_STAY dod.

save outfile='\\Stats\discovery\02_Developing\SMR01\PPA\Data\PPA_SPSS_Extract.sav'/COMPRESSED.

*********************************************************************************************************************************.
*Add in CHP HBR.
*********************************************************************************************************************************.

*GET FILE='\\Isdsf00d03\cl-out\lookups\Data Management\standard reference files\GP_CHP.sav'/
    keep=Health_Board_Name CHP_Code CHP_Name.

*aggregate outfile=*/
            break=CHP_Code CHP_Name Health_Board_Name /
                  nr=n.

*select if CHP_Code <> ''.
*select if CHP_Code <> 'N/A'.

*rename variables (Health_Board_Name=CHP_HBR).

*compute mrk=0.

*do if CHP_Code='S03000030' and CHP_HBR='NHS Greater Glasgow & C'.
*. compute mrk=1.
*end if.

*select if mrk = 0.

*save outfile='\\Stats\discovery\02_Developing\SMR01\PPA\Data\CHP_HBR_Lookup.sav'/
        keep=CHP_Code CHP_Name CHP_HBR /COMPRESSED.

*get file='\\Stats\discovery\02_Developing\SMR01\PPA\Data\CHP_HBR_Lookup.sav'.

*get file='\\Stats\discovery\02_Developing\SMR01\PPA\Data\PPA_SPSS_Extract.sav'.

*sort cases by CHP_Code.

*match files file=*/
           table='\\Stats\discovery\02_Developing\SMR01\PPA\Data\CHP_HBR_Lookup.sav'/
              by=CHP_Code.

*sort cases by LINK_NUMBER CONTINUOUS_INPATIENT_STAY doa.

*save outfile='\\Stats\discovery\02_Developing\SMR01\PPA\Data\PPA_SPSS_Extract.sav'/COMPRESSED.

*Syntax only needs run to the line above, syntax below is only required for further checks.
*********************************************************************************************************************************.
*The case to variables routine produces output in the same format as the tde file from the above extract.
*********************************************************************************************************************************.

get file='\\Stats\discovery\02_Developing\SMR01\PPA\Data\Temp\PPA_LINK_SPSS_Extract.sav'.

CASESTOVARS
  /ID=LINK_NUMBER CONTINUOUS_INPATIENT_STAY
  /INDEX=episinspell
  /GROUPBY=VARIABLE.
exe.







