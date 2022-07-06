**************************************************************************************************************************************************************************************
*******************************Syntax to produce Scotland level data for Summary chart for Dashboard 3 of HRI Pathways workbook***********************************.
*******************************BEWARE - Running time of 1+ days - Please ensure large file space before running*******************************************************.



*define !CostedFiles()
'/conf/irf/10-PLICS-analysis-files/masterPLICS_Costed_201516.sav'
!enddefine.

*define !CHICostedFiles()
'/conf/irf/10-PLICS-analysis-files/CHImasterPLICS_Costed_201516.sav'
!enddefine.

* File save location.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/'
!Enddefine.


*Define !HRIfile255075()
     '/conf/linkage/output/keirro/01-HRI-1516-255075.sav'
!Enddefine.
* Attempt to match on Individual level data to PathwayLKP.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI1.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1314 HRI_Group1415 HRI_Group1516
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'.

Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.sav'.
select if gender ne 0.
select if hri_scot ne 9.
EXECUTE.


ALTER TYPE date_death (F8).

*compute age.
alter type dob (F8.0).
compute age= trunc((20160930-dob)/10000).
alter type age (F3.0).
execute.


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXECUTE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost mentalh_daycase_episodes mentalh_inpatient_episodes mentalh_el_inpatient_episodes
    mentalh_non_el_inpatient_episodes mentalh_daycase_cost mentalh_inpatient_cost mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost 
    mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbres lca CHP
      hbsimd2012quintile hbsimd2012decile
  /COMPRESSED.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.sav'.
select if gender ne 0.
select if hri_scot ne 9.
EXECUTE.



* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*compute age.
alter type dob (F8.0).
compute age= trunc((20150930-dob)/10000).
alter type age (F3.0).
execute.

* Adjust age to base year of 2013/14.
compute Age = Age + 1.
exe.

FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXECUTE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost mentalh_daycase_episodes mentalh_inpatient_episodes mentalh_el_inpatient_episodes
    mentalh_non_el_inpatient_episodes mentalh_daycase_cost mentalh_inpatient_cost mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost 
    mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbres lca CHP
      hbsimd2012quintile hbsimd2012decile
  /COMPRESSED.

get file = !OFilesL + 'Sankey_Link_dataset_Temp1.sav'.



Define !year()
'201415'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.sav'.
select if gender ne 0.
select if hri_scot ne 9.
EXECUTE.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*compute age.
alter type dob (F8.0).
compute age= trunc((20140930-dob)/10000).
alter type age (F3.0).
execute.

FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2013/14.
compute Age = Age + 2.
exe.

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXECUTE.

select if hri_group1415 ne 'No Contact'.
exe.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost mentalh_daycase_episodes mentalh_inpatient_episodes mentalh_el_inpatient_episodes
    mentalh_non_el_inpatient_episodes mentalh_daycase_cost mentalh_inpatient_cost mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost 
    mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbres lca CHP
      hbsimd2012quintile hbsimd2012decile
  /COMPRESSED.
get file = !OFilesL + 'Sankey_Link_dataset_Temp2.sav'.


Define !year()
'201314'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.sav'.
select if gender ne 0.
select if hri_scot ne 9.
EXECUTE.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20130401 deceased_flag = 1.
exe.

*compute age.
alter type dob (F8.0).
compute age= trunc((20130930-dob)/10000).
alter type age (F3.0).
execute.

FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.


* Adjust age to base year of 2013/14.
compute Age = Age + 3.
exe.

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXECUTE.

select if hri_group1314 ne 'No Contact'.
exe.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost mentalh_daycase_episodes mentalh_inpatient_episodes mentalh_el_inpatient_episodes
    mentalh_non_el_inpatient_episodes mentalh_daycase_cost mentalh_inpatient_cost mentalh_el_inpatient_cost mentalh_non_el_inpatient_cost 
    mentalh_el_inpatient_beddays mentalh_non_el_inpatient_beddays gls_daycase_episodes gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes gls_daycase_cost gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbres lca CHP
      hbsimd2012quintile hbsimd2012decile
  /COMPRESSED.




*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXECUTE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).
exe.

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Execute. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.

*Update Dementia to include alzheimers.
if alzheimers = 1 dementia = 1.
EXECUTE.
* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXECUTE.
* Drop groups due to size.
*compute Neurodegenerative = 0.
*compute Cardio = 0.
*compute Respiratory = 0.
*compute OtherOrgan = 0.
if (dementia eq 1 or ms eq 1 or parkinsons eq 1) Neurodegenerative = 1.
if (atrialfib eq 1 or chd eq 1 or cvd eq 1 or hefailure eq 1) Cardio = 1.
if (asthma eq 1 or copd eq 1) Respiratory = 1.
if (liver eq 1 or refailure eq 1) OtherOrgan = 1.
exe.

* Count of number of LTC.
compute Num_LTC = (cvd + copd + dementia + diabetes + chd + hefailure + refailure + epilepsy + asthma + atrialfib + ms + cancer + arth + parkinsons + liver).

string TNum_LTC (A3).
if Num_LTC < 1  TNum_LTC = '0'.
if Num_LTC = 1  TNum_LTC = '1'.
if Num_LTC = 2  TNum_LTC = '2'.
if Num_LTC = 3  TNum_LTC = '3'.
if Num_LTC = 4  TNum_LTC = '4'.
if Num_LTC = 5  TNum_LTC = '5'.
if Num_LTC ge 6  TNum_LTC = '6+'.
EXECUTE.

* DROPPED Count of number of LTC.
*compute Num_LTC_GRP = (diabetes + epilepsy + cancer + arth +  Neurodegenerative + Cardio + Respiratory + OtherOrgan).

*string TNum_LTC_GRP (A3).
*if Num_LTC_GRP < 1  TNum_LTC_GRP = '0'.
*if Num_LTC_GRP = 1  TNum_LTC_GRP = '1'.
*if Num_LTC_GRP = 2  TNum_LTC_GRP = '2'.
*if Num_LTC_GRP = 3  TNum_LTC_GRP = '3'.
*if Num_LTC_GRP = 4  TNum_LTC_GRP = '4'.
*if Num_LTC_GRP = 5  TNum_LTC_GRP = '5'.
*if Num_LTC_GRP ge 6  TNum_LTC_GRP = '6+'.
*EXECUTE.

* Create counts for each service or individuals using the services.
if acute_episodes GE 1 Acute_Ind = 1.
if mat_episodes GE 1 Mat_Ind = 1.
if mentalh_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXECUTE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20160401 deceased_flag = 1.
if HRI_Group1617 = 'Not in LA' deceased_flag = 0.
if date_death ge 20160401 and HRI_Group1617 = 'Died' deceased_flag = 1.
if date_death ge 20160401 and date_death le 20170331 deceased_flag_inYR = 1.
EXECUTE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK= year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1617 HRI_Group1314 HRI_Group1415 HRI_Group1516
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.

EXECUTE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK= year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1617 HRI_Group1314 HRI_Group1415 HRI_Group1516
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXECUTE.

Compute GenderSTR = 'Both'.
EXECUTE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK= year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1617 HRI_Group1314 HRI_Group1415 HRI_Group1516
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXECUTE.

Compute TNum_LTC = 'All'.
EXECUTE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK= year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1617 HRI_Group1314 HRI_Group1415 HRI_Group1516
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXECUTE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXECUTE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXECUTE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXECUTE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT1.sav'
/drop PathwayLKP_old TLA_Label.

*
**********************************************************************************************************************.
get file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT1.sav'.


* Temp fix need to correct in main prog.
*RENAME VARIABLES (dementia = dementia_old).
*compute dementia = dementia_OLD = alzheimers.
*EXECUTE.

rename variables Neurodegenerative = Neurodegenerative_Grp Cardio = Cardio_Grp Respiratory =  Respiratory_Grp OtherOrgan = OtherOrgan_Grp.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK= year GenderSTR AgeBand TNum_LTC HRI_Group1617 HRI_Group1314 HRI_Group1415 HRI_Group1516 PathwayLKP
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost mentalh_episodes mentalh_inpatient_beddays mentalh_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /diabetes epilepsy cancer arth cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver ms Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp No_LTC
=SUM(diabetes epilepsy cancer arth cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver ms Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp No_LTC)
  /Num_Ind = sum(Num_Ind).




add files file = *
/file= '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy.sav'.

string Link (a4).
Compute Link = "link".
exe.
if AgeBand = "All" AgeBand = "All ages".
exe.

*string Data (a7).
compute Data = "Summary".
EXECUTE.

Select if PathwayLabel NE "Remove".
EXECUTE.


SAVE OUTFILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.sav'
  /drop  deceased_flag_inYR
  /COMPRESSED.


get FILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.sav'.

rename variables (LCA_select = lca).
alter type lca (A2).
*add LA Name.

String LA_CODE (a9).
compute LA_Code = 'SCOT'.
exe.

recode Neurodegenerative_Grp (sysmis = 0).
recode Cardio_Grp (sysmis = 0). 
recode Respiratory_Grp (sysmis = 0). 
recode OtherOrgan_Grp (sysmis = 0).
exe.


SAVE OUTFILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.sav'
  /drop  lca
  /COMPRESSED.
get FILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.sav'.

*compute LCAname = 'Please Select Partnership'.
*compute LA_CODE = 'DummyPAR0'.
*compute Link = 'link'.
*compute Data = 'Summary'.
*exe.

*aggregate outfile = *
/break Link Data LCAname LA_CODE
/number = n.

*add files file =*
/file = '/conf/linkage/output/euanpa01/Summary_Link_dataset_LCAFINAL_SCOT.sav'.
*exe.

select if link ne ''.
exe.




save outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.sav'
/drop PathwayLabel
/compressed.

get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.sav'.

string LCAname (a10).
compute LCAname eq 'Scotland'.
EXECUTE.



select if tnum_ltc = 'All'.
exe.

*produce blank columns to match with Summary dataset.
compute health_net_cost1617=0.
compute health_net_cost1314=0.
compute health_net_cost1415=0.
compute health_net_cost1516=0.
compute health_net_cost1617_min=0.
compute health_net_cost1617_max=0.
compute health_net_cost1314_min=0.
compute health_net_cost1314_max=0.
compute health_net_cost1415_min=0.
compute health_net_cost1415_max=0.
compute health_net_cost1516_min=0.
compute health_net_cost1516_max=0.
compute Size = 0.
exe.

****Save final Summary dataset.
save outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.sav'
/drop HRI_group1011 HRI_group1112
/compressed.

get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.sav'.

