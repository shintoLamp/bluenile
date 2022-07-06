* Encoding: UTF-8.
**********************************************************************************************************************************************************************
*******************************Syntax to produce data for Summary charts for Dashboard 3 of HRI Pathways workbook***********************************.
*******************************BEWARE - Running time of 1+ days - Please ensure large file space before running**********************************.

* File save location.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/'
!Enddefine.


********************************************

* Attempt to match on Individual level data to PathwayLKP.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file =!OFilesL + 'temp_HRI_LA_ALLYR_CHI1.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT1.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.

************************************************************************************************************************************************************************.
**** LA2 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI2.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT2.zsav'
  /drop PathwayLKP_old TLA_Label
 /zcompressed.


************************************************************************************************************************************************************************.
**** LA3 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI3.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT3.zsav'
  /drop PathwayLKP_old TLA_Label
  /zcompressed.

************************************************************************************************************************************************************************.
**** LA4 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI4.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT4.zsav'
    /drop PathwayLKP_old TLA_Label
    /zcompressed.

************************************************************************************************************************************************************************.
**** LA5 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI5.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT5.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.

************************************************************************************************************************************************************************.
**** LA6 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI6.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT6.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.   


************************************************************************************************************************************************************************.
**** LA7 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI7.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT7.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.

************************************************************************************************************************************************************************.
**** LA8 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI8.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT8.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.

************************************************************************************************************************************************************************.
**** LA9 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI9.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT9.zsav'
  /drop PathwayLKP_old TLA_Label
  /zcompressed.

************************************************************************************************************************************************************************.
**** LA10 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI10.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT10.zsav'
   /drop PathwayLKP_old TLA_Label
  /zcompressed.

************************************************************************************************************************************************************************.
**** LA11 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI11.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT11.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.


************************************************************************************************************************************************************************.
**** LA12 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI12.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT12.zsav'
     /drop PathwayLKP_old TLA_Label
     /zcompressed.

************************************************************************************************************************************************************************.
**** LA13 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI13.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT13.zsav'
  /drop PathwayLKP_old TLA_Label
  /zcompressed.

************************************************************************************************************************************************************************.
**** LA14 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI14.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT14.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.

************************************************************************************************************************************************************************.
**** LA15 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI15.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT15.zsav'
  /drop PathwayLKP_old TLA_Label
  /zcompressed.


************************************************************************************************************************************************************************.
**** LA16 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI16.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT16.zsav'
  /drop PathwayLKP_old TLA_Label
  /zcompressed.

************************************************************************************************************************************************************************.
**** LA17 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI17.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT17.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.

************************************************************************************************************************************************************************.
**** LA18 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI18.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT18.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.


************************************************************************************************************************************************************************.
**** LA19 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI19.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT20.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.


************************************************************************************************************************************************************************.
**** LA21 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI21.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT22.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.

************************************************************************************************************************************************************************.
**** LA23 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI23.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT23.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.

************************************************************************************************************************************************************************.
**** LA24 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI24.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT24.zsav'
  /drop PathwayLKP_old TLA_Label
  /zcompressed.


************************************************************************************************************************************************************************.
**** LA25 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI25.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT25.zsav'
   /drop PathwayLKP_old TLA_Label
   /zcompressed.

************************************************************************************************************************************************************************.
**** LA26 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI26.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT26.zsav'
/drop PathwayLKP_old TLA_Label
/zcompressed.

************************************************************************************************************************************************************************.
**** LA27 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI27.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT27.zsav'
/drop PathwayLKP_old TLA_Label
/zcompressed.


************************************************************************************************************************************************************************.
**** LA28 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI28.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT28.zsav'
/drop PathwayLKP_old TLA_Label
/zcompressed.

************************************************************************************************************************************************************************.
**** LA29 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI29.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT29.zsav'
/drop PathwayLKP_old TLA_Label
/zcompressed.


************************************************************************************************************************************************************************.
**** LA30 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI30.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT30.sav'
/drop PathwayLKP_old TLA_Label.

************************************************************************************************************************************************************************.
**** LA31 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI31.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT31.zsav'
/drop PathwayLKP_old TLA_Label
/zcompressed.

************************************************************************************************************************************************************************.
**** LA32 *****.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI32.sav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.sav'
/drop Recs.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20160930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20150930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.



Define !year()
'201516'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

Rename variables death_date = date_death.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20140930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 2.
exe.

rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
.

Define !year()
'201415'
!Enddefine.

get file =  '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


Rename variables death_date = date_death.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20140401 deceased_flag = 1.
exe.

*FC Mar. 2019**
** 'Age' information is included in the Source Linkage File, no need to calculate it based on dob as previously done.
*compute age.
*alter type dob (F8.0).
*compute age= trunc((20130930-dob)/10000).
*alter type age (F3.0).
*execute.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 3.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.sav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.sav'.
EXE.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (Age lt 18) AgeBand = '<18'.
If (Age ge 18 and Age le 44) AgeBand = '18-44'.
If (Age ge 45 and Age le 64) AgeBand = '45-64'.
If (Age ge 65 and Age le 74) AgeBand = '65-74'.
If (Age ge 75 and Age le 84) AgeBand = '75-84'.
If (Age ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.


* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
EXE.
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
EXE.

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
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
EXE.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20170401 deceased_flag = 1.
if HRI_Group1718 = 'Not in LA' deceased_flag = 0.
if date_death ge 20170401 and HRI_Group1718 = 'Died' deceased_flag = 1.
if date_death ge 20170401 and date_death le 20180331 deceased_flag_inYR = 1.
EXE.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'.

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'.
EXE.

Compute GenderSTR = 'Both'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'.
EXE.

Compute TNum_LTC = 'All'.
EXE.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.sav'.
EXE.


* Modify PathwayLKP for use in tableau.
RENAME VARIABLES (PathwayLKP = PathwayLKP_old).
alter type LCA_Select (A2).

* Create Temp LA Label.
String TLA_Label (A5).
compute TLA_Label = concat('P', RTRIM(LCA_Select)).
EXE.
*Remove all spaces from  TLA_Label.
COMPUTE  TLA_Label = REPLACE( TLA_Label, " ", "").
EXE.

string PathwayLKP (A100).
compute PathwayLKP = concat(PathwayLabel,' - ', TLA_Label).
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCAFINALT32.zsav'
/drop PathwayLKP_old TLA_Label
/zcompressed.

**********************************************************************************************************************.
get file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT1.sav'.

add files file = *
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT2.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT3.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT4.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT5.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT6.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT7.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT8.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT9.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT10.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT11.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT12.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT13.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT14.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT15.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT16.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT17.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT18.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT19.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT20.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT21.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT22.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT23.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT24.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT25.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT26.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT27.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT28.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT29.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT30.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT31.sav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT32.sav'.
EXE.

* Temp fix need to correct in main prog.
*RENAME VARIABLES (dementia = dementia_old).
*compute dementia = dementia_OLD = alzheimers.
*EXECUTE.

rename variables Neurodegenerative = Neurodegenerative_Grp Cardio = Cardio_Grp Respiratory =  Respiratory_Grp OtherOrgan = OtherOrgan_Grp.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR AgeBand TNum_LTC HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 PathwayLKP
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /diabetes epilepsy cancer arth cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver ms Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp No_LTC
=SUM(diabetes epilepsy cancer arth cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver ms Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp No_LTC)
  /Num_Ind = sum(Num_Ind).



ALTER TYPE LCA_Select (F2.0).
exe.

add files file = *
/file= '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy.sav'.

string Link (a4).
Compute Link = "link".
if AgeBand = "All" AgeBand = "All ages".
exe.

*string Data (a7).
compute Data = "Summary".
EXE.

Select if PathwayLabel NE "Remove".
EXE.


SAVE OUTFILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL.sav'
  /drop  deceased_flag_inYR cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver ms
  /COMPRESSED.


get FILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL.sav'.

rename variables (LCA_select = lca).
alter type lca (A2).
*add LA Name.
string LCAname (a25).
if lca eq ' 1' LCAname eq 'Aberdeen City'.
if lca eq ' 2' LCAname eq 'Aberdeenshire'.
if lca eq ' 3' LCAname eq 'Angus'.
if lca eq ' 4' LCAname eq 'Argyll & Bute'.
if lca eq ' 5' LCAname eq 'Scottish Borders'.
if lca eq ' 6' LCAname eq 'Clackmannanshire'.
if lca eq ' 7' LCAname eq 'West Dunbartonshire'.
if lca eq ' 8' LCAname eq 'Dumfries & Galloway'.
if lca eq ' 9' LCAname eq 'Dundee City'.
if lca eq '10' LCAname eq 'East Ayrshire'.
if lca eq '11' LCAname eq 'East Dunbartonshire'.
if lca eq '12' LCAname eq 'East Lothian'.
if lca eq '13' LCAname eq 'East Renfrewshire'.
if lca eq '14' LCAname eq 'City of Edinburgh'.
if lca eq '15' LCAname eq 'Falkirk'.
if lca eq '16' LCAname eq 'Fife'.
if lca eq '17' LCAname eq 'Glasgow City'.
if lca eq '18' LCAname eq 'Highland'.
if lca eq '19' LCAname eq 'Inverclyde'.
if lca eq '20' LCAname eq 'Midlothian'.
if lca eq '21' LCAname eq 'Moray'.
if lca eq '22' LCAname eq 'North Ayrshire'.
if lca eq '23' LCAname eq 'North Lanarkshire'.
if lca eq '24' LCAname eq 'Orkney'.
if lca eq '25' LCAname eq 'Perth & Kinross'.
if lca eq '26' LCAname eq 'Renfrewshire'.
if lca eq '27' LCAname eq 'Shetland'.
if lca eq '28' LCAname eq 'South Ayrshire'.
if lca eq '29' LCAname eq 'South Lanarkshire'.
if lca eq '30' LCAname eq 'Stirling'.
if lca eq '31' LCAname eq 'West Lothian'.
if lca eq '32' LCAname eq 'Western Isles'.
if LCAname = '' LCAname = 'Non LCA'.
frequency variables = LCAname.

String LA_CODE (a9).
if LCAname = 'Scottish Borders' LA_CODE = 'S12000026'.
if LCAname = 'Fife' LA_CODE = 'S12000015'.
if LCAname = 'Orkney' LA_CODE = 'S12000023'.
if LCAname = 'Western Isles' LA_CODE = 'S12000013'.
if LCAname = 'Dumfries & Galloway' LA_CODE = 'S12000006'.
if LCAname = 'Shetland' LA_CODE = 'S12000027'.
if LCAname = 'North Ayrshire' LA_CODE = 'S12000021'.
if LCAname = 'South Ayrshire' LA_CODE = 'S12000028'.
if LCAname = 'East Ayrshire' LA_CODE = 'S12000008'.
if LCAname = 'East Dunbartonshire' LA_CODE = 'S12000045'.
if LCAname = 'Glasgow City' LA_CODE = 'S12000046'.
if LCAname = 'East Renfrewshire' LA_CODE = 'S12000011'.
if LCAname = 'West Dunbartonshire' LA_CODE = 'S12000039'.
if LCAname = 'Renfrewshire' LA_CODE = 'S12000038'.
if LCAname = 'Inverclyde' LA_CODE = 'S12000018'.
if LCAname = 'Highland' LA_CODE = 'S12000017'.
if LCAname = 'Argyll & Bute' LA_CODE = 'S12000035'.
if LCAname = 'North Lanarkshire' LA_CODE = 'S12000044'.
if LCAname = 'South Lanarkshire' LA_CODE = 'S12000029'.
if LCAname = 'Aberdeen City' LA_CODE = 'S12000033'.
if LCAname = 'Aberdeenshire' LA_CODE = 'S12000034'.
if LCAname = 'Moray' LA_CODE = 'S12000020'.
if LCAname = 'East Lothian' LA_CODE = 'S12000010'.
if LCAname = 'West Lothian' LA_CODE = 'S12000040'.
if LCAname = 'Midlothian' LA_CODE = 'S12000019'.
if LCAname = 'City of Edinburgh' LA_CODE = 'S12000036'.
if LCAname = 'Perth & Kinross' LA_CODE = 'S12000024'.
if LCAname = 'Dundee City' LA_CODE = 'S12000042'.
if LCAname = 'Angus' LA_CODE = 'S12000041'.
if LCAname = 'Clackmannanshire' LA_CODE = 'S12000005'.
if LCAname = 'Falkirk' LA_CODE = 'S12000014'.
if LCAname = 'Stirling' LA_CODE = 'S12000030'.
EXE.

recode Neurodegenerative_Grp (sysmis = 0).
recode Cardio_Grp (sysmis = 0). 
recode Respiratory_Grp (sysmis = 0). 
recode OtherOrgan_Grp (sysmis = 0).
exe.


SAVE OUTFILE=!OFilesL + 'Summary_Link_dataset_LCAFINAL.sav'
  /drop  lca
  /COMPRESSED.

get FILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL.sav'.

compute LCAname = 'Please Select Partnership'.
compute LA_CODE = 'DummyPAR0'.
compute Link = 'link'.
compute Data = 'Summary'.
exe.

aggregate outfile = *
/break Link Data LCAname LA_CODE
/number = n.

add files file =*
/file = !OFilesL + 'Summary_Link_dataset_LCAFINAL.sav'.
exe.

select if link ne ''.
exe.

SAVE OUTFILE=!OFilesL + 'Summary_Link_dataset_LCAFINAL.sav'
/drop number alzheimers
  /COMPRESSED.


get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL.sav'.




save outfile = !OFilesL + '/Summary_Link_dataset_LCAFINAL.sav'
/drop PathwayLabel
/compressed.

get file = !OFilesL + '/Summary_Link_dataset_LCAFINAL.sav'.

select if tnum_ltc = 'All'.
exe.

*produce blank columns to match with Sankey dataset.
compute health_net_cost1617=0.
compute health_net_cost1718=0.
compute health_net_cost1415=0.
compute health_net_cost1516=0.
compute health_net_cost1617_min=0.
compute health_net_cost1617_max=0.
compute health_net_cost1718_min=0.
compute health_net_cost1718_max=0.
compute health_net_cost1415_min=0.
compute health_net_cost1415_max=0.
compute health_net_cost1516_min=0.
compute health_net_cost1516_max=0. 
compute Size = 0.
exe.


****Save final Summary dataset.
save outfile = !OFilesL + '/Summary_Link_dataset_LCAFINAL.zsav'
     /zcompressed.

