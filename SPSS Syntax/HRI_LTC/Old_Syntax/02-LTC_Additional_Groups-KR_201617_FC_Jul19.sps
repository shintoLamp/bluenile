* Encoding: UTF-8.
*********************************************************Adds analysis for each specific LTC********************************************************.

Define !Working()
       '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/201617/'
!Enddefine.

Define !file()
     '/conf/sourcedev/TableauUpdates/HRI_LTC/Outputs/201617/'
!Enddefine.

******************************************************************
***** MUST UPDATE THESE BEFORE RUNNING ********.
*Macro 1.
Define !year()
'201617'
!Enddefine.


get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*CVD.
select if cvd =1.
exe.

string LTC (a10).
compute LTC = 'cvd'.
exe.


compute Additional_LTC = (copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.

save outfile = !Working + 'agg_plics_countCVD.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.


*COPD.
select if copd =1.
exe.

string LTC (a10).
compute LTC = 'copd'.
exe.


compute Additional_LTC = (cvd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countCOPD.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.


*Dementia.
select if dementia =1.
exe.

string LTC (a10).
compute LTC = 'dementia'.
exe.

compute Additional_LTC = (cvd + copd + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.



save outfile = !Working + 'agg_plics_countDEMENTIA.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.


*Diabetes.
select if diabetes =1.
exe.

string LTC (a10).
compute LTC = 'diabetes'.
exe.

compute Additional_LTC = (cvd + copd + dementia + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countDIABETES.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*CHD.
select if chd =1.
exe.

string LTC (a10).
compute LTC = 'chd'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countCHD.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.


*hefailure.
select if hefailure =1.
exe.

string LTC (a10).
compute LTC = 'hefailure'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countHEFAILURE.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*ReFailure.
select if refailure =1.
exe.

string LTC (a10).
compute LTC = 'refailure'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countREFAILURE.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*epilepsy.
select if epilepsy =1.
exe.

string LTC (a10).
compute LTC = 'epilepsy'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countEPILEPSY.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*asthma.
select if asthma =1.
exe.

string LTC (a10).
compute LTC = 'asthma'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.



save outfile = !Working + 'agg_plics_countASTHMA.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*atrialfib.
select if atrialfib =1.
exe.

string LTC (a10).
compute LTC = 'atrialfib'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countATRIALFIB.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*ms.
select if ms =1.
exe.

string LTC (a10).
compute LTC = 'ms'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countMS.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*cancer.
select if cancer =1.
exe.

string LTC (a10).
compute LTC = 'cancer'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countCANCER.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*arth.
select if arth =1.
exe.

string LTC (a10).
compute LTC = 'arth'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countARTH.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*parkinsons.
select if parkinsons =1.
exe.

string LTC (a10).
compute LTC = 'parkinsons'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countPARKINSONS.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.

*liver.
select if liver =1.
exe.

string LTC (a10).
compute LTC = 'liver'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countLIVER.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.



*No LTC.
select if No_LTC = 1.
exe.

string LTC (a10).
compute LTC = 'No LTC'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countNOLTC.sav'.

get file=!file+'/TAB-TDE-ALL-costs-HRI_LCA_LTC' + !year + '.sav'.



*Any LTC.
select if No_LTC ne 1.
exe.

string LTC (a10).
compute LTC = 'Any LTC'.
exe.

compute Additional_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver) - 1.
exe.


aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvdC copdC dementiaC diabetesC chdC hefailureC refailureC epilepsyC asthmaC atrialfibC cancerC arthC parkinsonsC liverC msC No_LTCC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


save outfile = !Working + 'agg_plics_countAnyLTC.sav'.


*Add LTC files together.
add files file =!Working + 'agg_plics_countCVD.sav'
/file = !Working + 'agg_plics_countCOPD.sav'
/file = !Working + 'agg_plics_countDEMENTIA.sav'
/file = !Working + 'agg_plics_countDIABETES.sav'
/file = !Working + 'agg_plics_countCHD.sav'
/file = !Working + 'agg_plics_countHEFAILURE.sav'
/file = !Working + 'agg_plics_countREFAILURE.sav'
/file = !Working + 'agg_plics_countEPILEPSY.sav'
/file = !Working + 'agg_plics_countASTHMA.sav'
/file = !Working + 'agg_plics_countATRIALFIB.sav'
/file = !Working + 'agg_plics_countMS.sav'
/file = !Working + 'agg_plics_countCANCER.sav'
/file = !Working + 'agg_plics_countARTH.sav'
/file = !Working + 'agg_plics_countPARKINSONS.sav'
/file = !Working + 'agg_plics_countLIVER.sav'
/file = !Working + 'agg_plics_countNOLTC.sav'
/file = !Working + 'agg_plics_countAnyLTC.sav'.
exe.


*To keep files size down rename Services with less activity as Other.
*****Tableau can now handle larger files - perhaps check is new potential and keep all services***************************.
if any(ServiceType, 'PIS', 'MAT', 'AE', 'OP') ServiceType eq 'Other'.
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib  cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost=sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.


alter type Additional_LTC (a3).
if Additional_LTC eq ' 10'  Additional_LTC eq '10'.
if  Additional_LTC eq '.00' Additional_LTC eq '0'.
if Additional_LTC eq '1.0' Additional_LTC eq '1'.
if Additional_LTC eq '2.0' Additional_LTC eq '2'.
if Additional_LTC eq '3.0' Additional_LTC eq '3'.
if Additional_LTC eq '4.0' Additional_LTC eq '4'.
if Additional_LTC eq '5.0' Additional_LTC eq '5'.
if Additional_LTC eq '6.0' Additional_LTC eq '6'.
if Additional_LTC eq '7.0' Additional_LTC eq '7'.
if Additional_LTC eq '8.0' Additional_LTC eq '8'.
if Additional_LTC eq '9.0' Additional_LTC eq '9'.
exe.

*To keep file size down rename any Additional_LTC count over 5 as >5.
if any (Additional_LTC, '5', '6', '7', '8', '9', '10') Additional_LTC eq '5+'.
exe. 
frequencies variables = Additional_LTC.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
/Total_Cost = sum(Total_Cost)
/Total_Beddays = sum(Total_Beddays).
exe.

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
exe.

*Create flags for all HR types.
compute HRI50_Flag = 0.
compute HRI65_Flag = 0.
compute HRI80_Flag = 0.
compute HRI95_Flag = 0.
exe.

if UserType = 'lca-HRI_50' HRI50_Flag = 1.
if UserType = 'lca-HRI_65' HRI65_Flag  = 1.
if UserType = 'lca-HRI_80' HRI80_Flag = 1.
if UserType = 'lca-HRI_95' HRI95_Flag = 1.
exe.

save outfile = !file+'/HRI_LTC_Totals.sav'.
get file =  !file+'/HRI_LTC_Totals.sav'.

frequencies variables = usertype.

************************For proper comparison with HRI user an "Other User" user type needs to be created*******************
*First total Pateitnt NUmber must be extracted, follewed by HRI patietns. HRI patients is subracted from total patients to get patient numbers for Other Users*.

select if UserType eq 'lca-HRI_ALL'.
exe.

RENAME VARIABLES (NumberPatients Total_Cost Total_Beddays cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms
Neurodegenerative Cardio Respiratory OtherOrgan No_LTC Any_LTC=
NumberPatients_ALL Total_Cost_ALL Total_Beddays_ALL cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL
cancer_ALL arth_ALL parkinsons_ALL liver_ALL ms_ALL Neurodegenerative_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL).
exe.


frequencies variables = servicetype.

aggregate outfile = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC
/cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL
cancer_ALL arth_ALL parkinsons_ALL liver_ALL ms_ALL NumberPatients_ALL Neurodegenerative_ALL Total_Cost_ALL Total_Beddays_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL = 
sum(cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL
cancer_ALL arth_ALL parkinsons_ALL liver_ALL ms_ALL NumberPatients_ALL Neurodegenerative_ALL Total_Cost_ALL Total_Beddays_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL).


sort cases by Year LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.

save outfile =  !file+'/HRI_LTC_All_Totals.sav'
/KEEP Year LCAname LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC
cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL
cancer_ALL arth_ALL parkinsons_ALL liver_ALL ms_ALL NumberPatients_ALL Total_Cost_ALL Total_Beddays_ALL Neurodegenerative_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL .


get file =  !file+'/HRI_LTC_Totals.sav'.

select if UserType ne 'lca-HRI_ALL'.
exe.

*Get HRI users only.
sort cases by Year LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.
MATCH FILES file = *
/Table = !file+'/HRI_LTC_All_Totals.sav'
/by Year LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.
exe. 
sort cases by LCAname.
exe.

RENAME VARIABLES (NumberPatients Total_Cost Total_Beddays cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms
Neurodegenerative Cardio Respiratory OtherOrgan No_LTC Any_LTC= 
NumberPatients_OLD Total_Cost_OLD Total_Beddays_OLD cvd_OLD copd_OLD dementia_OLD diabetes_OLD chd_OLD hefailure_OLD refailure_OLD epilepsy_OLD asthma_OLD atrialfib_OLD 
cancer_OLD arth_OLD parkinsons_OLD liver_OLD ms_OLD Neurodegenerative_OLD Cardio_OLD Respiratory_OLD OtherOrgan_OLD No_LTC_OLD Any_LTC_OLD).


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
exe.
compute UserType = 'Other Service Users'.
exe.

save outfile =  !file+'/HR_LTC_OtherUsers.sav'
/keep Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC NumberPatients Total_Cost Total_Beddays
cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC Neurodegenerative Cardio Respiratory OtherOrgan
HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag.


* Bring files togther and add Blank row for Tableau.
add files file =   !file+'/HRI_LTC_Totals.sav'
/file =  !file+'/HR_LTC_OtherUsers.sav'.
exe.

sort cases by Year LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.
MATCH FILES file = *
/Table = !file+'/HRI_LTC_All_Totals.sav'
/by Year LA_CODE HB_CODE Gender AgeBand ServiceType LTC Additional_LTC.
exe. 
sort cases by LCAname.
exe.

select if UserType ne 'All'.
select if UserType ne ''.
exe.

alter type LTC (a25).

save outfile = !file + 'LTC_Temp.sav'.
get file =  !file + 'LTC_Temp.sav'.

*Create LTC Group names.

if any(LTC, 'dementia', 'ms', 'parkinsons') LTC eq 'Neurodegenerative - Grp'.
if any(LTC, 'atrialfib', 'chd', 'cvd', 'hefailure') LTC eq 'Cardio - Grp'.
if any(LTC, 'asthma', 'copd') LTC eq 'Respiratory - Grp'.
if any(LTC, 'liver', 'refailure') LTC eq 'Other Organ - Grp'.
exe.

frequencies variables = LTC.

select if any (LTC, 'Neurodegenerative - Grp', 'Cardio - Grp', 'Respiratory - Grp', 'Other Organ - Grp').
exe.

aggregate outfile  = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag
/cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC NumberPatients NumberPatients_ALL Total_Cost Total_Cost_ALL Total_Beddays Total_Beddays_ALL
Neurodegenerative Cardio Respiratory OtherOrgan=
sum(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib cancer arth parkinsons liver ms No_LTC Any_LTC NumberPatients NumberPatients_ALL Total_Cost Total_Cost_ALL Total_Beddays Total_Beddays_ALL
 Neurodegenerative Cardio Respiratory OtherOrgan).
exe.


add files file = *
/file =  !file + 'LTC_Temp.sav'.
exe.

frequencies variables = UserType.

*Create points for Radar Chart.
string Point (a1).
if Additional_LTC eq '0' Point eq '1'.
if Additional_LTC eq '1' Point eq '2'.
if Additional_LTC eq '2' Point eq '3'.
if Additional_LTC eq '3' Point eq '4'.
if Additional_LTC eq '4' Point eq '5'.
if Additional_LTC eq '5+' Point eq '6'.
exe.

*Create X/Y coordinates for mapping on radar chart.
string X (A4) Y (A4).
if point eq '1'	X eq '0'.
if point eq '1' Y eq '9.9'.
if point eq '2'	X eq '8.7'.
if point eq '2' Y eq	'5'.
if point eq '3' X eq	'8.7'.
if point eq '3' Y eq	'-5'.
if point eq '4' X eq	'0'.
if point eq '4' Y eq	'-9.9'.
if point eq '5'	X eq '-8.7'.
if point eq '5' Y eq	'-5'.
if point eq '6' X eq	'-8.7'.
if point eq '6' Y eq	'5'.
exe.

alter type Point (f1.0) X(f4.2) Y(f4.2).
frequencies variables = Additional_LTC.

*select if NumberPatients ne 0.
*exe.

compute GroupLTC_Flag = 0.
compute IndividualLTC_Flag = 0.
if any (LTC, 'arth', 'cancer', 'diabetes', 'epilepsy', 'Cardio - Grp', 'Neurodegenerative - Grp', 'Other Organ - Grp', 'Respiratory - Grp') GroupLTC_Flag eq 1.
if any (LTC, 'ms', 'arth', 'asthma', 'atrialfib', 'cancer', 'chd', 'copd', 'cvd', 'dementia', 'diabetes', 'epilepsy', 'hefailure', 'liver', 'parkinsons', 'refailure', 'Any LTC') IndividualLTC_Flag eq 1.
exe.


select if usertype ne 'lca-HRI_ALL'.
alter type usertype (a20).
if usertype eq 'Other Servi' usertype eq 'Other Service Users'.
if usertype eq 'lca-HRI_50' usertype eq 'HRI 50%'.
if usertype eq 'lca-HRI_65' usertype eq 'HRI 65%'.
if usertype eq 'lca-HRI_80' usertype eq 'HRI 80%'.
if usertype eq 'lca-HRI_95' usertype eq 'HRI 95%'.
exe.


save outfile = !file + 'HRI_LTC_Radar_' + !year + '.sav'
/drop cvd_ALL copd_ALL dementia_ALL diabetes_ALL chd_ALL hefailure_ALL refailure_ALL epilepsy_ALL asthma_ALL atrialfib_ALL ms_ALL 
cancer_ALL arth_ALL parkinsons_ALL liver_ALL Neurodegenerative_ALL Cardio_ALL Respiratory_ALL OtherOrgan_ALL No_LTC_ALL Any_LTC_ALL.

get file= !file + 'HRI_LTC_Radar_' + !year + '.sav'.


*COMPUTE Random_Number=RV.UNIFORM(0.6,0.8).
exe.

*compute cvd = cvd * Random_Number.
*compute copd = copd * Random_Number.
*compute dementia = dementia * Random_Number.
*compute diabetes = diabetes * Random_Number.
*compute chd = chd * Random_Number.
*compute hefailure = hefailure * Random_Number.
*compute refailure = refailure * Random_Number.
*compute epilepsy = epilepsy * Random_Number.
*compute asthma = asthma * Random_Number.
*compute atrialfib = atrialfib * Random_Number.
*compute cancer = cancer * Random_Number.
*compute arth = arth * Random_Number.
*compute parkinsons = parkinsons * Random_Number.
*compute liver = liver * Random_Number.
*compute ms = ms * Random_Number.
*compute No_LTC = No_LTC * Random_Number.
*compute Any_LTC = Any_LTC * Random_Number.
*compute NumberPatients = NumberPatients * Random_Number.
*compute NumberPatients_ALL = NumberPatients_ALL * Random_Number.
*compute Total_Cost = Total_Cost * Random_Number.
*compute Total_Cost_ALL = Total_Cost_ALL * Random_Number.
*compute Total_Beddays = Total_Beddays * Random_Number.
*compute Total_Beddays_ALL = Total_Beddays_ALL * Random_Number.
*compute Neurodegenerative = Neurodegenerative * Random_Number.
*compute Cardio = Cardio * Random_Number.
*compute Respiratory = Respiratory * Random_Number.
*compute OtherOrgan = OtherOrgan * Random_Number.
exe.

*save outfile = !file + 'HRI_LTC_Radar_' + !year + '.sav'
/drop Random_Number.

get file = !file + 'HRI_LTC_Radar_' + !year + '.sav'.

compute AnyLTC_Flag = 0.
if LTC eq 'Any LTC' AnyLTC_Flag = 1.
exe.

aggregate outfile =* mode ADDVARIABLES
/break Year LCAname Gender AgeBand UserType ServiceType LTC HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag
/NumberPat_HRIGrp = sum(NumberPatients)
/Total_Cost_HRIGrp = sum(Total_Cost)
/Total_Beddays_HRIGrp = sum(Total_Beddays).

ALTER TYPE   ageband (A8).
if ageband eq 'All a' ageband eq 'All ages'.
exe.

save outfile = !file +'HRI_LTC_Radar_' + !year + '.sav'.

get file =  !file +'HRI_LTC_Radar_' + !year + '.sav'.



***Run the following lines once (only the most recent FY).

*compute Year = ''.
*compute LCAname = 'Please Select Partnership'.
*compute LA_CODE = 'DummyPAR0'.
*compute HB_CODE = 'DummyREG0'.
*compute Gender = ''.
*compute AgeBand = ''.
*compute UserType = ''.
*compute ServiceType = ''.
*compute LTC = ''.
*compute Additional_LTC = ''.
*compute HRI50_Flag = 0.
*compute HRI65_Flag = 0.
*compute HRI80_Flag = 0.
*compute HRI95_Flag = 0.
*compute cvd = 0.
*compute copd = 0.
*compute dementia = 0.
*compute diabetes = 0.
*compute chd = 0.
*compute hefailure = 0.
*compute refailure = 0.
*compute epilepsy = 0.
*compute asthma = 0.
*compute atrialfib = 0.
*compute ms = 0.
*compute cancer = 0.
*compute arth = 0.
*compute parkinsons = 0.
*compute liver = 0.
*compute No_LTC = 0.
*compute Any_LTC = 0.
*compute NumberPatients = 0.
*compute NumberPatients_ALL = 0.
*compute Total_Cost = 0.
*compute Total_Cost_ALL = 0.
*compute Total_Beddays = 0.
*compute Total_Beddays_ALL = 0.
*compute Neurodegenerative =0.
*compute Cardio = 0.
*compute Respiratory = 0.
*compute OtherOrgan = 0.
*compute Point = 0.
*compute X = 0.
*compute Y = 0.
*compute GroupLTC_Flag = 0.
*compute IndividualLTC_Flag = 0.
*compute AnyLTC_Flag = 0.

*aggregate outfile = *
/break Year LCAname LA_CODE HB_CODE Gender AgeBand UserType ServiceType LTC Additional_LTC
/HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Any_LTC
NumberPatients NumberPatients_ALL Total_Cost Total_Cost_ALL Total_Beddays Total_Beddays_ALL Neurodegenerative Cardio Respiratory OtherOrgan Point X Y GroupLTC_Flag IndividualLTC_Flag AnyLTC_Flag
=sum(HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Any_LTC
NumberPatients NumberPatients_ALL Total_Cost Total_Cost_ALL Total_Beddays Total_Beddays_ALL Neurodegenerative Cardio Respiratory OtherOrgan Point X Y GroupLTC_Flag IndividualLTC_Flag AnyLTC_Flag).

*add files file = *
/file = !file +'HRI_LTC_Radar_201718.sav'.
*exe.


*Add Group total for percentage calculations.
****These could potentially now be replaced by Level of Detail calculations within Tableau.
*aggregate outfile =* mode ADDVARIABLES
/break Year LCAname Gender AgeBand UserType ServiceType LTC HRI50_Flag HRI65_Flag HRI80_Flag HRI95_Flag
/NumberPat_HRIGrp = sum(NumberPatients)
/Total_Cost_HRIGrp = sum(Total_Cost)
/Total_Beddays_HRIGrp = sum(Total_Beddays).


*save outfile = !file +'HRI_LTC_Radar_201718.sav'.


erase file = !Working + 'agg_plics_countCVD.sav'.
erase file = !Working + 'agg_plics_countCOPD.sav'.
erase file = !Working + 'agg_plics_countDEMENTIA.sav'.
erase file = !Working + 'agg_plics_countDIABETES.sav'.
erase file = !Working + 'agg_plics_countCHD.sav'.
erase file = !Working + 'agg_plics_countHEFAILURE.sav'.
erase file = !Working + 'agg_plics_countREFAILURE.sav'.
erase file = !Working + 'agg_plics_countEPILEPSY.sav'.
erase file = !Working + 'agg_plics_countASTHMA.sav'.
erase file = !Working + 'agg_plics_countATRIALFIB.sav'.
erase file = !Working + 'agg_plics_countALZHEIMERS.sav'.
erase file = !Working + 'agg_plics_countCANCER.sav'.
erase file = !Working + 'agg_plics_countARTH.sav'.
erase file = !Working + 'agg_plics_countPARKINSONS.sav'.
erase file = !Working + 'agg_plics_countLIVER.sav'.
erase file = !Working + 'agg_plics_countNOLTC.sav'.
erase file = !Working + 'agg_plics_countAnyLTC.sav'.



