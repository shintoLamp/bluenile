* Encoding: UTF-8.
Define !DateSyntaxRun()
'2018_12_05'
!Enddefine. 

*** Update with the date at which data is extracted
*** Date Format: YYYY_MM_DD

Define !DateExtracted()
'_extracted_2018_12_05'
!Enddefine. 

*** Update with the financial year of interest

Define !FinYearUpdate()
'201718'
!Enddefine. 


DEFINE  !pathExtracts()
'/conf/sourcedev/TableauUpdates/PEoLC/Data Extracts/'
!enddefine.

DEFINE !pathout()
'/conf/sourcedev/TableauUpdates/PEoLC/LTC update/output/'
!enddefine.


*****LTC approach - OLD method****
******************************************

get file = !pathExtracts + 'All patients ready for matching LTC information_' + !FinYearUpdate + !DateExtracted + '.zsav'.

select if Financial_Year_of_Death = '2017/18'.
exe.
 
Match files file = *
 /table= !pathExtracts + 'SLF LTC flag 1718 lookup'+ !DateExtracted + '.zsav'
 /by chi.
exe.

string LTC (A60).
if cancer=1 LTC = 'Cancer'.
if cvd=1 LTC='CVD'.
if chd=1 LTC='CHD'.
if copd=1 LTC='COPD'.
if arth=1 LTC='Arthritis'.
if diabetes=1 LTC='Diabetes'.
if atrialfib=1 LTC='Atrial Fibrilliation'.
if refailure=1 LTC='Renal failure'.
if hefailure=1 LTC='Heart failure'.
if liver=1 LTC='Liver Disease'.
if asthma=1 LTC='Asthma'.
if epilepsy=1 LTC='Epilepsy'.
if dementia=1 LTC='Dementia'.
if parkinsons=1 LTC= 'Parkinsons'.
if ms=1 LTC='MS'.
IF LTC = ' ' LTC = 'No LTC'.
EXE.
 
frequencies LTC.
 
* create variable which holds the total number of LTCs per patient who has died.
compute LTC_Total=arth+asthma+atrialfib+cancer+cvd+liver+copd+dementia+diabetes+epilepsy+chd+hefailure+ms+parkinsons+refailure.
 
* create flags for number of LTCs - possibly use this later
 
*if LTC_Total gt 5 LTC_Total=5.
compute ZeroLTC=0.
compute OneLTC=0.
compute TwoLTC=0.
compute ThreeLTC=0.
compute FourLTC=0.
compute FiveLTC=0.
compute SixLTC=0.
compute SevenLTC=0.
compute EightLTC=0.
compute NineLTC=0.
compute TenLTC=0.
compute ElevenLTC=0.
compute TwelveLTC=0.
compute LTCUnknown=0.
exe.
 
if LTC_Total=0 ZeroLTC=1.
if LTC_Total=1 OneLTC=1.
if LTC_Total=2 TwoLTC=1.
if LTC_Total=3 ThreeLTC=1.
if LTC_Total=4 FourLTC=1.
if LTC_Total=5 FiveLTC=1.
if LTC_Total=6 SixLTC=1.
if LTC_Total=7 SevenLTC=1.
if LTC_Total=8 EightLTC=1.
if LTC_Total=9 NineLTC=1.
if LTC_Total=10 TenLTC=1.
if LTC_Total=11 ElevenLTC=1.
if LTC_Total=12 TwelveLTC=1.
if missing(LTC_Total) LTCUnknown =1.
exe.

If LTCUnknown = 1 LTC = 'LTC Information Unknown'.
exe.

frequencies LTC.

frequencies LTC_Total.

save outfile = !pathout + '201718 deaths including LTCs_OLD-method' + !DateSyntaxRun + '.zsav'
 /zcompressed.


*****LTC approach - NEW method****
******************************************

get file = !pathExtracts + 'All patients ready for matching LTC information_' + !FinYearUpdate + !DateExtracted + '.zsav'.

select if Financial_Year_of_Death = '2017/18'.
exe.
 
Match files file = *
 /table= !pathExtracts + 'SLF LTC flag 1718 lookup'+ !DateExtracted + '.zsav'
 /by chi.
exe.

save outfile = !pathExtracts + 'All patients LTC information_' + !FinYearUpdate + !DateExtracted + '.zsav'
  /zcompressed.



get file = !pathExtracts + 'All patients LTC information_' + !FinYearUpdate + !DateExtracted + '.zsav'.

*Attach multiple LTCs to individuals.

string LTC1 to LTC12 (a20).

compute l=1.

*ARTH.
do if arth=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='Arth'.
   if l=2 LTC2='Arth'.
   if l=3 LTC3='Arth'.
   if l=4 LTC4='Arth'.
   if l=5 LTC5='Arth'.
   if l=6 LTC6='Arth'.
   if l=7 LTC7='Arth'.
   if l=8 LTC8='Arth'.
   if l=9 LTC9='Arth'.
   if l=10 LTC10='Arth'.
   if l=11 LTC11='Arth'.
   if l=12 LTC12='Arth'.
end if.

compute l=1.

*ASTHMA.
do if asthma=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='Asthma'.
   if l=2 LTC2='Asthma'.
   if l=3 LTC3='Asthma'.
   if l=4 LTC4='Asthma'.
   if l=5 LTC5='Asthma'.
   if l=6 LTC6='Asthma'.
   if l=7 LTC7='Asthma'.
   if l=8 LTC8='Asthma'.
   if l=9 LTC9='Asthma'.
   if l=10 LTC10='Asthma'.
   if l=11 LTC11='Asthma'.
   if l=12 LTC12='Asthma'.
end if.

compute l=1.

*ATRIALFIB.
do if atrialfib=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='Atrialfib'.
   if l=2 LTC2='Atrialfib'.
   if l=3 LTC3='Atrialfib'.
   if l=4 LTC4='Atrialfib'.
   if l=5 LTC5='Atrialfib'.
   if l=6 LTC6='Atrialfib'.
   if l=7 LTC7='Atrialfib'.
   if l=8 LTC8='Atrialfib'.
   if l=9 LTC9='Atrialfib'.
   if l=10 LTC10='Atrialfib'.
   if l=11 LTC11='Atrialfib'.
   if l=12 LTC12='Atrialfib'.
end if.

compute l=1.

*CANCER.
do if cancer=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='cancer'.
   if l=2 LTC2='cancer'.
   if l=3 LTC3='cancer'.
   if l=4 LTC4='cancer'.
   if l=5 LTC5='cancer'.
   if l=6 LTC6='cancer'.
   if l=7 LTC7='cancer'.
   if l=8 LTC8='cancer'.
   if l=9 LTC9='cancer'.
   if l=10 LTC10='cancer'.
   if l=11 LTC11='cancer'.
   if l=12 LTC12='cancer'.
end if.

compute l=1.

*CVD.
do if cvd=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='cvd'.
   if l=2 LTC2='cvd'.
   if l=3 LTC3='cvd'.
   if l=4 LTC4='cvd'.
   if l=5 LTC5='cvd'.
   if l=6 LTC6='cvd'.
   if l=7 LTC7='cvd'.
   if l=8 LTC8='cvd'.
   if l=9 LTC9='cvd'.
   if l=10 LTC10='cvd'.
   if l=11 LTC11='cvd'.
   if l=12 LTC12='cvd'.
end if.

compute l=1.

*LIVER.
do if liver=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='liver'.
   if l=2 LTC2='liver'.
   if l=3 LTC3='liver'.
   if l=4 LTC4='liver'.
   if l=5 LTC5='liver'.
   if l=6 LTC6='liver'.
   if l=7 LTC7='liver'.
   if l=8 LTC8='liver'.
   if l=9 LTC9='liver'.
   if l=10 LTC10='liver'.
   if l=11 LTC11='liver'.
   if l=12 LTC12='liver'.
end if.

compute l=1.

*COPD.
do if copd=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='copd'.
   if l=2 LTC2='copd'.
   if l=3 LTC3='copd'.
   if l=4 LTC4='copd'.
   if l=5 LTC5='copd'.
   if l=6 LTC6='copd'.
   if l=7 LTC7='copd'.
   if l=8 LTC8='copd'.
   if l=9 LTC9='copd'.
   if l=10 LTC10='copd'.
   if l=11 LTC11='copd'.
   if l=12 LTC12='copd'.
end if.

compute l=1.

*DEMENTIA.
do if dementia=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='dementia'.
   if l=2 LTC2='dementia'.
   if l=3 LTC3='dementia'.
   if l=4 LTC4='dementia'.
   if l=5 LTC5='dementia'.
   if l=6 LTC6='dementia'.
   if l=7 LTC7='dementia'.
   if l=8 LTC8='dementia'.
   if l=9 LTC9='dementia'.
   if l=10 LTC10='dementia'.
   if l=11 LTC11='dementia'.
   if l=12 LTC12='dementia'.
end if.

compute l=1.

*DIABETES.
do if diabetes=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='diabetes'.
   if l=2 LTC2='diabetes'.
   if l=3 LTC3='diabetes'.
   if l=4 LTC4='diabetes'.
   if l=5 LTC5='diabetes'.
   if l=6 LTC6='diabetes'.
   if l=7 LTC7='diabetes'.
   if l=8 LTC8='diabetes'.
   if l=9 LTC9='diabetes'.
   if l=10 LTC10='diabetes'.
   if l=11 LTC11='diabetes'.
   if l=12 LTC12='diabetes'.
end if.

compute l=1.

*EPILEPSY.
do if epilepsy=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='epilepsy'.
   if l=2 LTC2='epilepsy'.
   if l=3 LTC3='epilepsy'.
   if l=4 LTC4='epilepsy'.
   if l=5 LTC5='epilepsy'.
   if l=6 LTC6='epilepsy'.
   if l=7 LTC7='epilepsy'.
   if l=8 LTC8='epilepsy'.
   if l=9 LTC9='epilepsy'.
   if l=10 LTC10='epilepsy'.
   if l=11 LTC11='epilepsy'.
   if l=12 LTC12='epilepsy'.
end if.

compute l=1.

*CHD.
do if chd=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='chd'.
   if l=2 LTC2='chd'.
   if l=3 LTC3='chd'.
   if l=4 LTC4='chd'.
   if l=5 LTC5='chd'.
   if l=6 LTC6='chd'.
   if l=7 LTC7='chd'.
   if l=8 LTC8='chd'.
   if l=9 LTC9='chd'.
   if l=10 LTC10='chd'.
   if l=11 LTC11='chd'.
   if l=12 LTC12='chd'.
end if.

compute l=1.

*HEFAILURE.
do if hefailure=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='hefailure'.
   if l=2 LTC2='hefailure'.
   if l=3 LTC3='hefailure'.
   if l=4 LTC4='hefailure'.
   if l=5 LTC5='hefailure'.
   if l=6 LTC6='hefailure'.
   if l=7 LTC7='hefailure'.
   if l=8 LTC8='hefailure'.
   if l=9 LTC9='hefailure'.
   if l=10 LTC10='hefailure'.
   if l=11 LTC11='hefailure'.
   if l=12 LTC12='hefailure'.
end if.

compute l=1.

*MS.
do if ms=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='ms'.
   if l=2 LTC2='ms'.
   if l=3 LTC3='ms'.
   if l=4 LTC4='ms'.
   if l=5 LTC5='ms'.
   if l=6 LTC6='ms'.
   if l=7 LTC7='ms'.
   if l=8 LTC8='ms'.
   if l=9 LTC9='ms'.
   if l=10 LTC10='ms'.
   if l=11 LTC11='ms'.
   if l=12 LTC12='ms'.
end if.

compute l=1.

*PARKINSONS.
do if parkinsons=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='parkinsons'.
   if l=2 LTC2='parkinsons'.
   if l=3 LTC3='parkinsons'.
   if l=4 LTC4='parkinsons'.
   if l=5 LTC5='parkinsons'.
   if l=6 LTC6='parkinsons'.
   if l=7 LTC7='parkinsons'.
   if l=8 LTC8='parkinsons'.
   if l=9 LTC9='parkinsons'.
   if l=10 LTC10='parkinsons'.
   if l=11 LTC11='parkinsons'.
   if l=12 LTC12='parkinsons'.
end if.

compute l=1.

*REFAILURE.
do if refailure=1.
   do repeat x=LTC1 to LTC12.
   if x <>'' l=(l+1).
   end repeat.  
   if l=1 LTC1='refailure'.
   if l=2 LTC2='refailure'.
   if l=3 LTC3='refailure'.
   if l=4 LTC4='refailure'.
   if l=5 LTC5='refailure'.
   if l=6 LTC6='refailure'.
   if l=7 LTC7='refailure'.
   if l=8 LTC8='refailure'.
   if l=9 LTC9='refailure'.
   if l=10 LTC10='refailure'.
   if l=11 LTC11='refailure'.
   if l=12 LTC12='refailure'.
end if.

Execute.

*Create variable which holds the total number of LTCs per patient who has died.
compute LTC_Total=arth+asthma+atrialfib+cancer+cvd+liver+copd+dementia+diabetes+epilepsy+chd+hefailure+ms+parkinsons+refailure.

save outfile = !pathout + '201718 deaths revised LTC_' + !DateSyntaxRun + '.zsav'
  /zcompressed.


get file =  !pathout + '201718 deaths revised LTC_' + !DateSyntaxRun + '.zsav'. 

*Create an aggregate version of the file to get to the total number of deaths and to keep only the variables of interest.
*Exclude patient records with missing Council Area information.

Select if councilarea NE 'Missing'.
exe.

aggregate outfile = *
  /break Financial_Year_of_Death chi HSCP councilarea CA2011 Age_Group Gender Location_Type Urban_Rural_Classification
            SIMD_Quintile LTC1 LTC2 LTC3 LTC4 LTC5 LTC6 LTC7 LTC8 LTC9 LTC10 LTC11 LTC12 LTC_Total LTC_UN Cause_of_Death
  /Total_Deaths=sum(death).
execute.

save outfile = !pathout + '1.All deaths aggreg file_LTC_revised_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'
   /zcompressed.

get file = !pathout + '1.All deaths aggreg file_LTC_revised_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'.

*Flag those patients with missing LTC information (LTC_Total = 999).  
if sysmis(LTC_Total) LTC_Total = 999.
execute.

save outfile = !pathout + '1.All deaths aggreg file_LTC_revised_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'
  /drop LTC_UN.
execute.

get file =  !pathout + '1.All deaths aggreg file_LTC_revised_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'.

*Tableau Formatting.

Alter type LTC_Total(A7).

if LTC_Total = ' 999.00' LTC_Total = 'Unknown'.
if LTC_Total = '   1.00' LTC_Total = '1'.
if LTC_Total = '   2.00' LTC_Total = '2'.
if LTC_Total = '   3.00' LTC_Total = '3'.
if LTC_Total = '   4.00' LTC_Total = '4'.
if LTC_Total = '   5.00' LTC_Total = '5'.
if LTC_Total = '   6.00' LTC_Total = '6'.
if LTC_Total = '   7.00' LTC_Total = '7'.
if LTC_Total = '   8.00' LTC_Total = '8'.
if LTC_Total = '   9.00' LTC_Total = '9'.
if LTC_Total = '   10.00' LTC_Total = '10'.
if LTC_Total = '   11.00' LTC_Total = '11'.
if LTC_Total = '   12.00' LTC_Total = '12'.
if LTC_Total = '    .00' LTC_Total = '0'.
execute.

frequencies LTC_Total.

Alter type SIMD_Quintile(A24).
execute.

IF SIMD_Quintile = '      1' SIMD_Quintile = '1 - Most deprived'.
IF SIMD_Quintile = '      2' SIMD_Quintile = '2'.
IF SIMD_Quintile = '      3' SIMD_Quintile = '3'.
IF SIMD_Quintile = '      4' SIMD_Quintile = '4'.
IF SIMD_Quintile = '      5' SIMD_Quintile = '5 - Least deprived'.
execute.

save outfile = !pathout + '2. Location of death_LTC_revised_TDE_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'
   /zcompressed.

get file = !pathout + '2. Location of death_LTC_revised_TDE_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'.
  
save outfile = !pathout + '2. Location of death_LTC_revised_TDE_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'
    /drop chi
   /zcompressed.

get file =  !pathout + '2. Location of death_LTC_revised_TDE_' + !FinYearUpdate + !DateSyntaxRun + '.zsav'.

