* Encoding: UTF-8.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV1/DB3_Summary/'
!Enddefine.


*Define !HRIfile255075()
     '/conf/linkage/output/keirro/01-HRI-1516-255075.sav'
!Enddefine.
* Attempt to match on Individual level data to PathwayLKP.
* Need to save out Pathway lookup to match on the original CHIMASTER level data.

get file = !OFilesL + 'temp_HRI_LA_ALLYR_CHI1.zsav'.

* reduce file to those pathways with valid CHI's.
select if remove = 0.
execute.

sort cases by chi.
AGGREGATE
  /OUTFILE=*
  /BREAK= CHI PathwayLKP PathwayLabel HRI_Group1516 HRI_Group1617 HRI_Group1718 HRI_Group1819
  /Recs = N.
execute.


save outfile  = !OFilesL + 'Sankey_IndLKP1.zsav'
  /zcompressed.


Define !year()
'201819'
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


*FC Dec 19 - Create Numeric 'date of birth'.
Compute dob_num = xdate.mday(dob) + 100*xdate.month(dob) + 10000*xdate.year(dob).
exe.

*Adjust age (Numeric format) to base year of latest year.
alter type dob_num (F8.0).
compute age_num= trunc((20180930-dob_num)/10000).
alter type age_num (F3.0).
exe.



rename variables anon_chi = chi.

SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.sav'
/by CHI.
execute.

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
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    simd2020_hb2019_quintile simd2020_hb2019_decile
  /zcompressed.
