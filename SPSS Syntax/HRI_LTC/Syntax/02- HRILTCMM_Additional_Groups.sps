* Encoding: UTF-8.
* Edited BM May 2020.

* This syntax adds analysis for each individual LTC in the LTC HRI Multi-Morbidity Source workbook.

* 0 - Macros.

Define !year()
'202021'
!Enddefine.

Define !file()
!QUOTE(!CONCAT('/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/', !UNQUOTE(!SUBSTR(!EVAL(!year), 4, 4)), '/'))
!Enddefine.

*CVD.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if cvd =1.
string LTC (a10).
compute LTC = 'cvd'.

compute Additional_LTC = (copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggCVD.sav' /zcompressed.

*COPD.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if copd =1.
string LTC (a10).
compute LTC = 'copd'.

compute Additional_LTC = (cvd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggCOPD.sav' /zcompressed.

*Dementia.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if dementia =1.
string LTC (a10).
compute LTC = 'dementia'.

compute Additional_LTC = (cvd + copd + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggDEMENTIA.sav' /zcompressed.

*Diabetes.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if diabetes =1.
string LTC (a10).
compute LTC = 'diabetes'.

compute Additional_LTC = (cvd + copd + dementia + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggDIABETES.sav' /zcompressed.

*CHD.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if chd =1.
string LTC (a10).
compute LTC = 'chd'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggCHD.sav' /zcompressed.

* Heart failure.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if hefailure =1.
string LTC (a10).
compute LTC = 'hefailure'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggHEFAILURE.sav' /zcompressed.

*Renal failure.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if refailure =1.
string LTC (a10).
compute LTC = 'refailure'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggREFAILURE.sav' /zcompressed.

*Epilepsy.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if epilepsy =1.
string LTC (a10).
compute LTC = 'epilepsy'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggEPILEPSY.sav' /zcompressed.

*Asthma.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if asthma =1.
string LTC (a10).
compute LTC = 'asthma'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggASTHMA.sav' /zcompressed.

*Atrial Fibrillation.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if atrialfib =1.
string LTC (a10).
compute LTC = 'atrialfib'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggATRIALFIB.sav' /zcompressed.

*MS.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if ms =1.
string LTC (a10).
compute LTC = 'ms'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggMS.sav' /zcompressed.

*Cancer.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if cancer =1.
string LTC (a10).
compute LTC = 'cancer'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggCANCER.sav' /zcompressed.

*Arthritis.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if arth =1.
string LTC (a10).
compute LTC = 'arth'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggARTH.sav' /zcompressed.

*Parkinsons.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if parkinsons =1.
string LTC (a10).
compute LTC = 'parkinsons'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggPARKINSONS.sav' /zcompressed.

*Liver disease.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if liver =1.
string LTC (a10).
compute LTC = 'liver'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggLIVER.sav' /zcompressed.

*No LTC.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if No_LTC = 1.
string LTC (a10).
compute LTC = 'No LTC'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggNOLTC.sav' /zcompressed.

*Any LTC.

get file = !file + 'HRI_LTC_MM_LCA_Costs' + !year + '.sav'.

select if No_LTC ne 1.
string LTC (a10).
compute LTC = 'Any LTC'.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver) - 1.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

save outfile = !file + 'aggAnyLTC.sav' /zcompressed.

*Add LTC files together.
add files file =!file + 'aggCVD.sav'
/file = !file + 'aggCOPD.sav'
/file = !file + 'aggDEMENTIA.sav'
/file = !file + 'aggDIABETES.sav'
/file = !file + 'aggCHD.sav'
/file = !file + 'aggHEFAILURE.sav'
/file = !file + 'aggREFAILURE.sav'
/file = !file + 'aggEPILEPSY.sav'
/file = !file + 'aggASTHMA.sav'
/file = !file + 'aggATRIALFIB.sav'
/file = !file + 'aggMS.sav'
/file = !file + 'aggCANCER.sav'
/file = !file + 'aggARTH.sav'
/file = !file + 'aggPARKINSONS.sav'
/file = !file + 'aggLIVER.sav'
/file = !file + 'aggNOLTC.sav'
/file = !file + 'aggAnyLTC.sav'.
execute.


*To keep files size down rename Services with less activity as Other.

if any(ServiceType, 'PIS', 'MAT', 'AE', 'OP') ServiceType eq 'Other'.
aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib  cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost=sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

alter type Additional_LTC (a3).
recode Additional_LTC ('.00' = '0')('1.0' = '1')('2.0' = '2')('3.0' = '3')('4.0' = '4')(else = '5+').
 
*frequencies Additional_LTC.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).

*To get correct Patients Numbers for a each LTC make NumberPatients equal to the LTC.
if LTC eq 'ms' NumberPatients eq ms.
if LTC eq 'arth' NumberPatients eq arth.
if LTC eq 'asthma' NumberPatients eq asthma.
if LTC eq 'atrialfib' NumberPatients eq atrialfib.
if LTC eq 'cancer' NumberPatients eq cancer.
if LTC eq 'chd' NumberPatients eq chd.
if LTC eq 'copd' NumberPatients eq copd.
if LTC eq 'cvd' NumberPatients eq cvd.
if LTC eq 'dementia' NumberPatients eq dementia.
if LTC eq 'diabetes' NumberPatients eq diabetes.
if LTC eq 'epilepsy' NumberPatients eq epilepsy.
if LTC eq 'hefailure' NumberPatients eq hefailure.
if LTC eq 'liver' NumberPatients eq liver.
if LTC eq 'parkinsons' NumberPatients eq parkinsons. 
if LTC eq 'refailure' NumberPatients eq refailure.
if LTC eq 'No LTC' NumberPatients eq No_LTC.
if LTC eq 'Any LTC' NumberPatients eq Any_LTC.

*Create flags for all HRI types.
compute HRI50_Flag = 0.
compute HRI65_Flag = 0.
compute HRI80_Flag = 0.
compute HRI95_Flag = 0.

if UserType = 'lca-HRI_50' HRI50_Flag = 1.
if UserType = 'lca-HRI_65' HRI65_Flag  = 1.
if UserType = 'lca-HRI_80' HRI80_Flag = 1.
if UserType = 'lca-HRI_95' HRI95_Flag = 1.

save outfile = !file + 'HRI_LTC_Totals.sav' /zcompressed.
get file = !file + 'HRI_LTC_Totals.sav'.

*frequencies NumberPatients.

*frequencies usertype.

************************For proper comparison with HRI user an "Other User" user type needs to be created*******************
*First total Patient Number must be extracted, follewed by HRI patients. HRI patients is subtracted from total patients to get patient numbers for Other Users*.

select if UserType eq 'lca-HRI_ALL'.

RENAME VARIABLES (NumberPatients Total_Cost Total_Beddays cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms
Neurodegenerative Cardio Respiratory OtherOrgan No_LTC Any_LTC=
NumberPatients_ALL Total_Cost_ALL Total_Beddays_ALL cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL
cancer_ALL arth_ALL parkinsons_ALL liver_ALL ms_ALL Neurodegenerative_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL).

aggregate outfile = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC
/cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL
cancer_ALL arth_ALL parkinsons_ALL liver_ALL ms_ALL NumberPatients_ALL Neurodegenerative_ALL Total_Cost_ALL Total_Beddays_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL = 
sum(cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL
cancer_ALL arth_ALL parkinsons_ALL liver_ALL ms_ALL NumberPatients_ALL Neurodegenerative_ALL Total_Cost_ALL Total_Beddays_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL).

sort cases by Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.

save outfile = !file + 'HRI_LTC_All_Totals.sav'
/KEEP Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC
cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL
cancer_ALL arth_ALL parkinsons_ALL liver_ALL ms_ALL NumberPatients_ALL Total_Cost_ALL Total_Beddays_ALL Neurodegenerative_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL
/zcompressed.

get file = !file + 'HRI_LTC_All_Totals.sav'.

*Using dummy LA codes for C&S to avoid duplicate key error at line 457.
if (LCAname='Clackmannanshire & Stirling') AND (LA_CODE='S12000005') LA_CODE='S12000098'.
if (LCAname='Clackmannanshire & Stirling') AND (LA_CODE='S12000030') LA_CODE='S12000099'.
execute.

sort cases by Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.

save outfile = !file + 'HRI_LTC_All_Totals.sav'
 /zcompressed.


get file =  !file + 'HRI_LTC_Totals.sav'. 

*Using dummy LA codes for C&S to avoid duplicate key error at line 457.
if (LCAname='Clackmannanshire & Stirling') AND (LA_CODE='S12000005') LA_CODE='S12000098'.
if (LCAname='Clackmannanshire & Stirling') AND (LA_CODE='S12000030') LA_CODE='S12000099'.
execute.


select if UserType ne 'lca-HRI_ALL'.

*Get HRI users only.
sort cases by Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.
MATCH FILES file = *
/Table = !file+'/HRI_LTC_All_Totals.sav'
/by Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.
sort cases by LCAname.

RENAME VARIABLES (NumberPatients Total_Cost Total_Beddays cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms
Neurodegenerative Cardio Respiratory OtherOrgan No_LTC Any_LTC= 
NumberPatients_OLD Total_Cost_OLD Total_Beddays_OLD cvd_OLD copd_OLD dementia_OLD diabetes_OLD chd_OLD hefailure_OLD refailure_OLD epilepsy_OLD asthma_OLD atrialfib_OLD 
cancer_OLD arth_OLD parkinsons_OLD liver_OLD ms_OLD Neurodegenerative_OLD Cardio_OLD Respiratory_OLD OtherOrgan_OLD No_LTC_OLD Any_LTC_OLD).
execute.

*Get Other users Patients Numbers.
compute NumberPatients = NumberPatients_ALL - NumberPatients_OLD.
compute Total_Cost = Total_Cost_ALL - Total_Cost_OLD.
compute Total_Beddays = Total_Beddays_ALL - Total_Beddays_OLD.
compute cvd = cvd_ALL - CVD_OLD.
compute copd = copd_ALL - copd_OLD. 
compute dementia = dementia_ALL - dementia_OLD. 
compute diabetes = diabetes_ALL - diabetes_OLD. 
compute chd = chd_ALL - CHD_OLD.
compute hefailure = hefailure_ALL - hefailure_OLD. 
compute refailure = refailure_ALL - refailure_OLD. 
compute epilepsy = epilepsy_ALL - epilepsy_OLD. 
compute asthma = asthma_ALL - asthma_OLD.
compute atrialfib = atrialfib_ALL - atrialfib_OLD. 
compute ms = ms_ALL- ms_OLD. 
compute cancer = cancer_ALL - cancer_OLD.
compute arth = arth_ALL - arth_OLD. 
compute parkinsons = parkinsons_ALL - parkinsons_OLD. 
compute liver = liver_ALL - liver_OLD.
compute Neurodegenerative = Neurodegenerative_ALL - Neurodegenerative_OLD.
compute Cardio = Cardio_ALL - Cardio_OLD.
compute Respiratory = Respiratory_ALL - Respiratory_OLD.
compute OtherOrgan = OtherOrgan_ALL - OtherOrgan_OLD.
compute No_LTC = No_LTC_ALL - No_LTC_OLD.
compute Any_LTC = Any_LTC_ALL - Any_LTC_OLD.
compute UserType = 'Other Service Users'.

save outfile = !file + 'HRI_LTC_OtherUsers.sav'
/keep Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC NumberPatients Total_Cost Total_Beddays
cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan
HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag
/zcompressed.

* Bring files together.

add files file = !file + 'HRI_LTC_Totals.sav'
/file =  !file + 'HRI_LTC_OtherUsers.sav'.
execute.

sort cases by Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.
MATCH FILES file = *
/Table = !file + 'HRI_LTC_All_Totals.sav'
/by Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.
sort cases by LCAname.

select if UserType ne 'All'.
select if UserType ne ''.

alter type LTC (a25).

*Assign the appropriate LA codes to C&S.
if (LCAname='Clackmannanshire & Stirling') AND (LA_CODE='S12000098') LA_CODE='S12000005'.
if (LCAname='Clackmannanshire & Stirling') AND (LA_CODE='S12000099') LA_CODE='S12000030'.
execute.

save outfile = !file + 'LTC_Temp.sav' /zcompressed.
get file =  !file + 'LTC_Temp.sav'.

*Create LTC Group names.

if any(LTC, 'dementia', 'ms', 'parkinsons') LTC eq 'Neurodegenerative - Grp'.
if any(LTC, 'atrialfib', 'chd', 'cvd', 'hefailure') LTC eq 'Cardio - Grp'.
if any(LTC, 'asthma', 'copd') LTC eq 'Respiratory - Grp'.
if any(LTC, 'liver', 'refailure') LTC eq 'Other Organ - Grp'.

select if any (LTC, 'Neurodegenerative - Grp', 'Cardio - Grp', 'Respiratory - Grp', 'Other Organ - Grp').

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC NumberPatients NumberPatients_ALL Total_Cost Total_Cost_ALL Total_Beddays Total_Beddays_ALL
Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC NumberPatients NumberPatients_ALL Total_Cost Total_Cost_ALL Total_Beddays Total_Beddays_ALL
 Neurodegenerative Cardio Respiratory OtherOrgan).

add files file = *
/file =  !file + 'LTC_Temp.sav'.
execute.

*Create points for Radar Chart.
string Point (a1).
if Additional_LTC eq '0' Point eq '1'.
if Additional_LTC eq '1' Point eq '2'.
if Additional_LTC eq '2' Point eq '3'.
if Additional_LTC eq '3' Point eq '4'.
if Additional_LTC eq '4' Point eq '5'.
if Additional_LTC eq '5+' Point eq '6'.

*Create X/Y coordinates for mapping on radar chart.
string X (A4) Y (A4).
if point eq '1'     X eq '0'.
if point eq '1'     Y eq '9.9'.
if point eq '2'     X eq '8.7'.
if point eq '2'     Y eq '5'.
if point eq '3'     X eq '8.7'.
if point eq '3'     Y eq '-5'.
if point eq '4'     X eq '0'.
if point eq '4'     Y eq '-9.9'.
if point eq '5'     X eq '-8.7'.
if point eq '5'     Y eq '-5'.
if point eq '6'     X eq '-8.7'.
if point eq '6'     Y eq '5'.

alter type Point (f1.0) X(f4.2) Y(f4.2).

*select if NumberPatients ne 0.
*exe.

compute GroupLTC_Flag = 0.
compute IndividualLTC_Flag = 0.
if any (LTC, 'arth', 'cancer', 'diabetes', 'epilepsy', 'Cardio - Grp', 'Neurodegenerative - Grp', 'Other Organ - Grp', 'Respiratory - Grp') GroupLTC_Flag eq 1.
if any (LTC, 'ms', 'arth', 'asthma', 'atrialfib', 'cancer', 'chd', 'copd', 'cvd', 'dementia', 'diabetes', 'epilepsy', 'hefailure', 'liver', 'parkinsons', 'refailure', 'Any LTC') IndividualLTC_Flag eq 1.

select if usertype ne 'lca-HRI_ALL'.
alter type usertype (a20).
if usertype eq 'Other Servi' usertype eq 'Other Service Users'.
if usertype eq 'lca-HRI_50' usertype eq 'HRI 50%'.
if usertype eq 'lca-HRI_65' usertype eq 'HRI 65%'.
if usertype eq 'lca-HRI_80' usertype eq 'HRI 80%'.
if usertype eq 'lca-HRI_95' usertype eq 'HRI 95%'.

save outfile = !file + 'HRI_LTC_Final' + !year + '.sav'
/drop cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL ms_ALL 
cancer_ALL arth_ALL parkinsons_ALL liver_ALL Neurodegenerative_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL
/zcompressed.

get file= !file + 'HRI_LTC_Final' + !year + '.sav'.

compute AnyLTC_Flag = 0.
if LTC eq 'Any LTC' AnyLTC_Flag = 1.

aggregate outfile =* mode ADDVARIABLES
/break Year LCAname Gender AgeBand UserType ServiceType LTC HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag
/NumberPat_HRIGrp = sum(NumberPatients)
/Total_Cost_HRIGrp = sum(Total_Cost)
/Total_Beddays_HRIGrp = sum(Total_Beddays).

*ALTER TYPE   ageband (A8).
*if ageband eq 'All a' ageband eq 'All ages'. 


save outfile = !file + 'HRI_LTC_Final' + !year + '.sav'.


erase file = !file + 'HRI_LTC_All_Totals.sav'.
erase file = !file + 'HRI_LTC_Totals.sav'.
erase file = !file + 'HRI_LTC_OtherUsers.sav'.
erase file = !file + 'LTC_Temp.sav'.
erase file = !file + 'aggCVD.sav'.
erase file = !file + 'aggCOPD.sav'.
erase file = !file + 'aggDEMENTIA.sav'.
erase file = !file + 'aggDIABETES.sav'.
erase file = !file + 'aggCHD.sav'.
erase file = !file + 'aggMS.sav'.
erase file = !file + 'aggHEFAILURE.sav'.
erase file = !file + 'aggREFAILURE.sav'.
erase file = !file + 'aggEPILEPSY.sav'.
erase file = !file + 'aggASTHMA.sav'.
erase file = !file + 'aggATRIALFIB.sav'.
erase file = !file + 'aggCANCER.sav'.
erase file = !file + 'aggARTH.sav'.
erase file = !file + 'aggPARKINSONS.sav'.
erase file = !file + 'aggLIVER.sav'.
erase file = !file + 'aggNOLTC.sav'.
erase file = !file + 'aggAnyLTC.sav'.



 


