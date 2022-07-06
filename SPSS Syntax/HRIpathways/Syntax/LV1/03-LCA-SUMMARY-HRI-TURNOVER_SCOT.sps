* Encoding: UTF-8.
* File save location.
define !OFilesL1()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV1/DB2_Sankey/'
!Enddefine.

define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV1/DB3_Summary/'
!Enddefine.



get file = !OFilesL1 + 'temp_HRI_LA_ALLYR_CHI1.zsav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI PathwayLKP PathwayLabel HRI_Group1617 HRI_Group1718 HRI_Group1819 HRI_Group1920
  /Recs = N.
exe.


save outfile  = !OFilesL + 'Sankey_IndLKP1.zsav'
  /drop Recs
  /zcompressed.

Define !year()
'201920'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

* FC Jan 2020. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Check HRI cost outlier found for 2017/18 and 2016/17 activities.
*Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
*exe.

*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the syntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.

* Remove any individuals who died before start of FY.
 * ALTER TYPE date_death (F8).
 * compute deceased_flag = 0.
 * if date_death < 20190401 deceased_flag = 1.
 * exe.

*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20190930-dob_num)/10000).
alter type age_num (F3.0).
exe.

 * select if deceased_flag = 0.
 * exe.

rename variables anon_chi = chi.

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.zsav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
exe.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.zsav'
  /DROP= dob dob_num acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca CA2019
    SIMD2020v2_HB2019_quintile SIMD2020v2_HB2019_decile
/zcompressed.



Define !year()
'201819'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
exe.


*FC Jan 2020. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Check HRI cost outlier found for 2017/18 and 2016/17 activities.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.

*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.

* Remove any individuals who died before start of FY.
alter type date_death (F8).

compute deceased_flag = 0.
if date_death < 20180401 deceased_flag = 1.
exe.

*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20180930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 1.
exe.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables anon_chi = chi.

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.zsav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.zsav'
  /DROP= dob dob_num acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca CA2019
    SIMD2020v2_HB2019_quintile SIMD2020v2_HB2019_decile
  /zcompressed.


Define !year()
'201718'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
exe.

*FC Jan 2020. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Check HRI cost outlier found for 2017/18 and 2016/17 activities.
Select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.

*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.

ALTER TYPE date_death (F8).

* Remove any individuals who died before start of FY.
compute deceased_flag = 0.
if date_death < 20170401 deceased_flag = 1.
exe.

*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20170930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 2.
exe.



*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables anon_chi = chi.


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.zsav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
exe.

select if hri_group1718 ne 'No Contact'.
exe.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.zsav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca CA2019
      SIMD2020v2_HB2019_quintile SIMD2020v2_HB2019_decile
 /zcompressed.


Define !year()
'201617'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.
EXE.


*FC Jan 2020. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.


*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.

* Remove any individuals who died before start of FY.
alter type date_death (F8).

compute deceased_flag = 0.
if date_death < 20160401 deceased_flag = 1.
exe.

*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20160930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 3.
exe.


*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.


rename variables anon_chi=chi.

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.zsav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
exe.

select if hri_group1617 ne 'No Contact'.
exe.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.zsav'
  /DROP= dob dob_num acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca CA2019
    SIMD2020v2_HB2019_quintile SIMD2020v2_HB2019_decile
  /zcompressed.

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.zsav'.
execute.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
*rename variables (AgeBand = AgeGroup).
*exe.

* Create required agebands.
string AgeBand (A8).
If (Age_num lt 18) AgeBand = '<18'.
If (Age_num ge 18 and Age_num le 44) AgeBand = '18-44'.
If (Age_num ge 45 and Age_num le 64) AgeBand = '45-64'.
If (Age_num ge 65 and Age_num le 74) AgeBand = '65-74'.
If (Age_num ge 75 and Age_num le 84) AgeBand = '75-84'.
If (Age_num ge 85) AgeBand = '85+'.
Exe. 

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
exe.

*Update Dementia to include alzheimers.
 * if alzheimers = 1 dementia = 1.
 * EXE.
* add Long Term Condition Groups and Counts of Number of LTCs.
compute No_LTC = 0.
if (cvd	= 0 and copd = 0 and dementia	= 0 and diabetes = 0 and	chd	= 0 and hefailure = 0 and	refailure = 0 and	epilepsy = 0 and 	asthma = 0	
and atrialfib = 0 and	ms = 0 and cancer = 0 and arth = 0 and parkinsons = 0 and	liver = 0) No_LTC = 1.
execute.
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
execute.

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
*exe.

* Create counts for each service or individuals using the services.
if acute_episodes GE 1 Acute_Ind = 1.
if mat_episodes GE 1 Mat_Ind = 1.
if MH_episodes GE 1 MH_Ind = 1.
if gls_episodes GE 1 GLS_Ind = 1.
if op_newcons_attendances GE 1 OUT_Ind = 1.
if ae_attendances GE 1 AE_Ind = 1.
if pis_dispensed_items GE 1 PIS_Ind = 1.
exe.

* Update death flag to replicate Pathway.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
compute deceased_flag_inYR = 0.
if date_death < 20190401 deceased_flag = 1.
if HRI_Group1920 = 'Not in LA' deceased_flag = 0.
if date_death ge 20190401 and HRI_Group1920 = 'Died' deceased_flag = 1.
if date_death ge 20190401 and date_death le 20200331 deceased_flag_inYR = 1.
execute.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK= year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1819 HRI_Group1718 HRI_Group1617 HRI_Group1920
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan
 =SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver Neurodegenerative Cardio Respiratory OtherOrgan) 
  /No_LTC=SUM(No_LTC)
  /Num_Ind = n.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp1.zsav'
  /zcompressed.

get file = !OFilesL + 'Sankey_Link_dataset_LCATemp1.zsav'.

Compute AgeBand = 'All ages'.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.zsav'
  /BREAK= year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1819 HRI_Group1718 HRI_Group1617 HRI_Group1920
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* Gender.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.zsav'.
exe.

Compute GenderSTR = 'Both'.
exe.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp3.zsav'
  /BREAK= year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1819 HRI_Group1718 HRI_Group1617 HRI_Group1920
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

* LTCs.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.zsav'.
exe.

Compute TNum_LTC = 'All'.
exe.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp4.zsav'
  /BREAK= year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1819 HRI_Group1718 HRI_Group1617 HRI_Group1920
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
  /cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan
=SUM(cvd copd dementia diabetes chd hefailure refailure epilepsy asthma atrialfib ms cancer arth parkinsons liver No_LTC Neurodegenerative Cardio Respiratory OtherOrgan)
  /Num_Ind = sum(Num_Ind).

*Produce final file.
add files file =!OFilesL + 'Sankey_Link_dataset_LCATemp1.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp2.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp3.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCATemp4.zsav'.
exe.

* Temp fix need to correct in main prog.
*RENAME VARIABLES (dementia = dementia_old).
*compute dementia = dementia_OLD = alzheimers.
*exe.

rename variables Neurodegenerative = Neurodegenerative_Grp Cardio = Cardio_Grp Respiratory =  Respiratory_Grp OtherOrgan = OtherOrgan_Grp.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK= year GenderSTR AgeBand TNum_LTC HRI_Group1819 HRI_Group1718 HRI_Group1617 HRI_Group1920 PathwayLKP
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind) 
 /diabetes epilepsy cancer arth cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver ms Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp No_LTC
=SUM(diabetes epilepsy cancer arth cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver ms Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp No_LTC)
  /Num_Ind = sum(Num_Ind).



add files file = *
/file= '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy.sav'.

string Link (a7).
Compute Link = "no link".
exe.
if AgeBand = "All" AgeBand = "All ages".
exe.

*string Data (a7).
compute Data = "Summary".
exe.

Select if PathwayLabel NE "Remove".
exe.


SAVE OUTFILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'
  /drop  deceased_flag_inYR
  /zcompressed.


get FILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'.

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


SAVE OUTFILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'
  /drop  lca
  /zcompressed.

get FILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'.

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




save outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'
  /drop PathwayLabel
  /zcompressed.

get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'.

string LCAname (a10).
compute LCAname eq 'Scotland'.
EXE.



 * select if tnum_ltc = 'All'.
 * exe.

*produce blank columns to match with Summary dataset.
compute health_net_cost1718=0.
compute health_net_cost1819=0.
compute health_net_cost1920=0.
compute health_net_cost1617=0.
compute health_net_cost1819_min=0.
compute health_net_cost1819_max=0.
compute health_net_cost1718_min=0.
compute health_net_cost1718_max=0.
compute health_net_cost1920_min=0.
compute health_net_cost1920_max=0.
compute health_net_cost1617_min=0.
compute health_net_cost1617_max=0.
compute Size = 0.
exe.

****Save final Summary dataset.
save outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'
  /drop HRI_group1112 HRI_group1213
  /zcompressed.

*Drop unnecessary variables.
get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'.

save outfile =  !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'
 /drop alzheimers HRI_Group1011 HRI_Group1314 mentalh_episodes mentalh_inpatient_beddays mentalh_cost 
         cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver ms
 /zcompressed.

*Now format data source as required for Tableau. 
get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'.

save outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT_Tableau_sorted.zsav'
   /keep Link Data LCAname LA_CODE GenderSTR AgeBand HRI_Group1819 HRI_Group1920 HRI_Group1617 HRI_Group1718 
           PathwayLKP health_net_cost1819 health_net_cost1920 health_net_cost1617 health_net_cost1718 
           health_net_cost1819_min health_net_cost1819_max health_net_cost1920_min  health_net_cost1920_max health_net_cost1617_min
           health_net_cost1617_max health_net_cost1718_min  health_net_cost1718_max  health_net_cost Size Year TNum_LTC TNum_LTC_GRP
           acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost
           gls_episodes gls_inpatient_beddays gls_cost op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag
           diabetes epilepsy cancer arth Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp Num_Ind Acute_Ind AE_Ind GLS_Ind Mat_Ind MH_Ind
           No_LTC OUT_Ind PIS_Ind
  /zcompressed.

get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT_Tableau_sorted.zsav'.


save translate outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT_Tableau_sorted.csv' 
       /type =csv/map/replace/fieldnames/cells = values.

