* Encoding: UTF-8.
* Encoding: .
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Sankey_DB2/EastLothian/'
!Enddefine.


********************************************

* Attempt to match on Individual level data to PathwayLKP.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.


**** LA12 *****.

get file =!OFilesL + 'temp_HRI_LA_ALLYR_CHI12.zsav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
exe.

sort cases by chi.

AGGREGATE
  /OUTFILE=*
  /BREAK= CHI LCA_select PathwayLKP PathwayLabel HRI_Group1516 HRI_Group1617 HRI_Group1718 HRI_Group1819 
  /Recs = N.
exe.

save outfile  = !OFilesL + 'Sankey_IndLKP1.zsav'
/drop Recs
/zcompressed.


Define !year()
'201819'
!Enddefine.

get file = '/conf/hscdiip/01-Source-linkage-files/source-individual-file-' + !year + '.zsav'.
select if gender ne 0.
select if hri_scot ne 9.

*Mar. 2019 FC. 
*Non-Service Users must be excluded by the calculations (only for health activities from 2015/16 onwards)
 Otherwise, these users will be counted in the 'Low Users' category.
select if NSU ne 1.
exe.

*Select East Lothian data only.
select if lca='12'.
***Check for outlier previously for 2016/17, 2017/18 FYs.
***If the following individual is associated with an inflated cost, he/she must be excluded from the dataset.
select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.


*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
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
exe.


*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

*save outfile = !OFilesL + 'temp_file.sav'.

*get file = !OFilesL + 'temp_file.sav'.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.zsav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
exe.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp1.zsav'
  /DROP= dob dob_num acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile
   /zcompressed.



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

*Select East Lothian data only.
select if lca='12'.
***Check for outlier previously for 2016/17, 2017/18 FYs.
***If the following individual is associated with an inflated cost, he/she must be excluded from the dataset.
select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.

*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
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
compute age_num = age_num + 1.
exe.


*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

*save outfile = !OFilesL + 'temp_file.sav'.

*get file = !OFilesL + 'temp_file.sav'.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.zsav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
exe.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.zsav'
  /DROP= dob dob_num acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile
  /zcompressed.


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

*Select East Lothian data only.
select if lca='12'.
***Check for outlier previously for 2016/17, 2017/18 FYs.
***If the following individual is associated with an inflated cost, he/she must be excluded from the dataset.
select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.

*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.

* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
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
compute age_num = age_num + 2.
exe.


*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.

* Adjust age to base year of 2016/17.
*compute Age = Age + 1.


rename variables Anon_CHI = chi. 

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.zsav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
exe.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp3.zsav'
  /DROP= dob dob_num acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    SIMD2016_HB2014_quintile SIMD2016_HB2014_decile
  /zcompressed.


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

*Select East Lothian data only.
select if lca='12'.
***Check for outlier previously for 2016/17, 2017/18 FYs.
***If the following individual is associated with an inflated cost, he/she must be excluded from the dataset.
select if Anon_CHI ne 'MDMwNTM2MTEzOQ=='.
exe.

*FC Nov 19 - Create Numeric 'date_death' consistently with the rest of the sysntax.
Compute date_death = xdate.mday(death_date) + 100*xdate.month(death_date) + 10000*xdate.year(death_date).
exe.


* Remove any individuals who died before start of FY.
ALTER TYPE date_death (F8).
compute deceased_flag = 0.
if date_death < 20150401 deceased_flag = 1.
exe.

*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20150930-dob_num)/10000).
alter type age_num (F3.0).
compute age_num = age_num + 3.
exe.

*FREQUENCIES VARIABLES=deceased_flag
  /ORDER=ANALYSIS.

select if deceased_flag = 0.
exe.


rename variables Anon_CHI = chi. 


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.zsav'
/by CHI.
exe.

select if PathwayLKP NE ' ' .
EXE.

SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp4.zsav'
  /DROP= dob dob_num acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
      SIMD2016_HB2014_quintile SIMD2016_HB2014_decile
  /zcompressed.
.
  

*Bring Files together.
add files file =!OFilesL + 'Sankey_Link_dataset_Temp1.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp2.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp3.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_Temp4.zsav'.
execute.

* Currently Dropping Age group from data file but may want to add in the future as provides 5 year age bands.
*rename variables (AgeBand = AgeGroup).

* Create required agebands.
string AgeBand (A8).
If (age_num lt 18) AgeBand = '<18'.
If (age_num ge 18 and age_num le 44) AgeBand = '18-44'.
If (age_num ge 45 and age_num le 64) AgeBand = '45-64'.
If (age_num ge 65 and age_num le 74) AgeBand = '65-74'.
If (age_num ge 75 and age_num le 84) AgeBand = '75-84'.
If (age_num ge 85) AgeBand = '85+'.
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
exe.
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
exe.

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
if date_death < 20180401 deceased_flag = 1.
if HRI_Group1819 = 'Not in LA' deceased_flag = 0.
if date_death ge 20180401 and HRI_Group1819 = 'Died' deceased_flag = 1.
if date_death ge 20180401 and date_death le 20190331 deceased_flag_inYR = 1.
exe.


* Now agg file to produce basic output file.
AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1516 HRI_Group1617 HRI_Group1718 HRI_Group1819 
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

* Now need to create totals - Gender, Age and Number LTC.

Compute AgeBand = 'All ages'.
exe.

AGGREGATE
  /OUTFILE=!OFilesL + 'Sankey_Link_dataset_LCATemp2.zsav'
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1516 HRI_Group1617 HRI_Group1718 HRI_Group1819 
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
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1516 HRI_Group1617 HRI_Group1718 HRI_Group1819 
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
  /BREAK=LCA_Select year GenderSTR PathwayLKP PathwayLabel AgeBand TNum_LTC HRI_Group1516 HRI_Group1617 HRI_Group1718 HRI_Group1819 
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


SAVE OUTFILE= !OFilesL + 'Sankey_Link_dataset_LCAFINALT12.zsav'
   /drop PathwayLKP_old TLA_Label
  /zcompressed.


