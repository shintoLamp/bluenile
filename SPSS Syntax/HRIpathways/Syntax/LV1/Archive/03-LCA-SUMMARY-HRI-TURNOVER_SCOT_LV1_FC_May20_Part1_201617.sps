* Encoding: UTF-8.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV1/DB3_Summary/'
!Enddefine.


Define !year()
'201617'
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

rename variables anon_chi = chi.


SORT CASES BY CHI.

match files file = *
/table = !OFilesL + 'Sankey_IndLKP1.zsav'
/by CHI.
execute.

select if PathwayLKP NE ' ' .
exe.

select if hri_group1617 ne 'No Contact'.
exe.


SAVE OUTFILE=!OFilesL + 'Sankey_Link_dataset_Temp2.zsav'
  /DROP= dob acute_daycase_episodes acute_inpatient_episodes
    acute_el_inpatient_episodes acute_non_el_inpatient_episodes acute_daycase_cost acute_inpatient_cost
    acute_el_inpatient_cost acute_non_el_inpatient_cost acute_el_inpatient_beddays acute_non_el_inpatient_beddays mat_daycase_episodes
    mat_inpatient_episodes mat_daycase_cost mat_inpatient_cost  MH_inpatient_episodes MH_el_inpatient_episodes
    MH_non_el_inpatient_episodes  MH_inpatient_cost MH_el_inpatient_cost MH_non_el_inpatient_cost 
    MH_el_inpatient_beddays MH_non_el_inpatient_beddays  gls_inpatient_episodes gls_el_inpatient_episodes 
    gls_non_el_inpatient_episodes  gls_inpatient_cost gls_el_inpatient_cost gls_non_el_inpatient_cost 
    gls_el_inpatient_beddays gls_non_el_inpatient_beddays op_newcons_dnas op_cost_dnas hbrescode lca 
    simd2020_hb2019_quintile simd2020_hb2019_decile
  /zcompressed.
