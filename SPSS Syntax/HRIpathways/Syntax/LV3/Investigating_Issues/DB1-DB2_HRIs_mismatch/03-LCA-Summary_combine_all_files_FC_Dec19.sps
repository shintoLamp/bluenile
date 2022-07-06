* Encoding: UTF-8.

* File save location.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Checks/Tableau_Data/'
!Enddefine.


**********************************************************************************************************************.
get file = !OFilesL + 'Sankey_Link_dataset_LCAFINALT1.zsav'.

add files file = *
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT14.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT17.zsav'.
execute.

* Temp fix need to correct in main prog.
*RENAME VARIABLES (dementia = dementia_old).
*compute dementia = dementia_OLD = alzheimers.
*EXECUTE.

rename variables Neurodegenerative = Neurodegenerative_Grp Cardio = Cardio_Grp Respiratory =  Respiratory_Grp OtherOrgan = OtherOrgan_Grp.
execute.

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
execute.


*ALTER TYPE LCA_Select (F2.0).
*exe.


add files file = *
/file= '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy.sav'.
execute.

string Link (a4).
Compute Link = "link".
if AgeBand = "All" AgeBand = "All ages".
exe.

*string Data (a7).
compute Data = "Summary".
execute.

Select if PathwayLabel NE "Remove".
execute.


SAVE OUTFILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'
  /drop  deceased_flag_inYR cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver ms
  /zcompressed.


get FILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'.

rename variables (LCA_select = lca).
alter type lca (A2).
*add LA Name.
string LCAname (a25).
if lca eq ' 1' LCAname eq 'Aberdeen City'.
if lca eq '14' LCAname eq 'City of Edinburgh'.
if lca eq '17' LCAname eq 'Glasgow City'.
if LCAname = '' LCAname = 'Non LCA'.


String LA_CODE (a9).
if LCAname = 'Glasgow City' LA_CODE = 'S12000046'.
if LCAname = 'Aberdeen City' LA_CODE = 'S12000033'.
if LCAname = 'City of Edinburgh' LA_CODE = 'S12000036'.
EXE.

recode Neurodegenerative_Grp (sysmis = 0).
recode Cardio_Grp (sysmis = 0). 
recode Respiratory_Grp (sysmis = 0). 
recode OtherOrgan_Grp (sysmis = 0).
exe.


SAVE OUTFILE=!OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'
  /drop  lca
  /zcompressed.

get FILE= !OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'.

compute LCAname = 'Please Select Partnership'.
compute LA_CODE = 'DummyPAR0'.
compute Link = 'no link'.
compute Data = 'Summary'.
execute.

aggregate outfile = *
/break Link Data LCAname LA_CODE
/number = n.
execute.

add files file =*
/file = !OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'.
execute.

select if link ne ''.
execute.

SAVE OUTFILE=!OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'
  /drop number alzheimers HRI_Group1011 HRI_Group1112 HRI_Group1213 HRI_Group1314 PathwayLabel
  /zcompressed.


get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'.


select if tnum_ltc = 'All'.
execute.

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
execute.


****Save final Summary dataset.
save outfile = !OFilesL + '/Summary_Link_dataset_LCAFINAL.zsav'
    /drop mentalh_episodes mentalh_inpatient_beddays mentalh_cost
    /zcompressed.


* Sorting data to combine Summary_link data with Sankey_link data for Tableau.
get file = !OFilesL + '/Summary_Link_dataset_LCAFINAL.zsav'.

save outfile = !OFilesL + '/Summary_Link_dataset_LCAFINAL_Tableau_sorted.zsav'
  /keep Link Data LCAname LA_CODE GenderSTR AgeBand HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
           PathwayLKP health_net_cost1415 health_net_cost1516 health_net_cost1617 health_net_cost1718 
           health_net_cost1415_min health_net_cost1415_max health_net_cost1516_min  health_net_cost1516_max health_net_cost1617_min
           health_net_cost1617_max health_net_cost1718_min  health_net_cost1718_max  health_net_cost Size Year TNum_LTC TNum_LTC_GRP
           acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost
           gls_episodes gls_inpatient_beddays gls_cost op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag
           diabetes epilepsy cancer arth Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp Num_Ind Acute_Ind AE_Ind GLS_Ind Mat_Ind MH_Ind
           No_LTC OUT_Ind PIS_Ind
  /zcompressed.

get file =  !OFilesL + '/Summary_Link_dataset_LCAFINAL_Tableau_sorted.zsav'.

alter type link(A7).

compute Link = 'no link'.
exe.

save outfile = !OFilesL + '/Summary_Link_dataset_LCAFINAL_Tableau_sorted.zsav'.

get file = !OFilesL + '/Summary_Link_dataset_LCAFINAL_Tableau_sorted.zsav'.

save translate outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_Tableau_sorted.csv' 
       /type = csv/map/replace/fieldnames/cells = values.

