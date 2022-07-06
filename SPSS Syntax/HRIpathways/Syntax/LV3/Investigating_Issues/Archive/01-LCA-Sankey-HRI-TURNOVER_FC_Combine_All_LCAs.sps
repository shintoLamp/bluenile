* Encoding: UTF-8.
define !OFilesL()
       '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Checks/Tableau_Data/'
!Enddefine.


*Combine data for all LCAs being tested (Aberdeen City, Glasgow City, Edinburgh City).
get file = !OFilesL + 'temp_HRI_LA_ALLYR17_Sorted.sav'. 

add files file = *
  /file = !OFilesL + 'temp_HRI_LA_ALLYR14_Sorted.sav'
  /file = !OFilesL + 'temp_HRI_LA_ALLYR17_Sorted.sav'.
execute.

*alter type LCA_Select (a2).
*alter type ageband (a8).

add files file = *
  /file= '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy.sav'.
execute.

get file = '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy.sav'.

string Link (a4).
Compute Link = "link".
exe.

if AgeBand = All AgeBand = All ages.
exe.


compute Data = "Sankey".
exe.

Select if PathwayLabel NE "Remove".
exe.

SAVE OUTFILE = !OFilesL + 'Sankey_Link_dataset_FINAL.zsav'
  /drop  PathwayLabel
  /zcompressed.

 
get FILE=  !OFilesL + 'Sankey_Link_dataset_FINAL.zsav'.

rename variables (LCA_select = lca).

alter type lca (A2).
*add LA Name.
string LCAname (a25).
if lca eq ' 1' LCAname eq 'Aberdeen City'.
if lca eq '14' LCAname eq 'City of Edinburgh'.
if lca eq '17' LCAname eq 'Glasgow City'.
if LCAname = '' LCAname = 'Non LCA'.

frequencies variables = LCAname.

String LA_CODE (a9).
if LCAname = 'Glasgow City' LA_CODE = 'S12000046'.
if LCAname = 'Aberdeen City' LA_CODE = 'S12000033'.
if LCAname = 'City of Edinburgh' LA_CODE = 'S12000036'.
exe.


SAVE OUTFILE=  !OFilesL+ 'Sankey_Link_dataset_FINAL.zsav'
  /drop lca
  /zcompressed.


get file =  !OFilesL+ 'Sankey_Link_dataset_FINAL.zsav'.


compute Link = link.
compute Data = 'Sankey'.
compute LCAname = 'Please Select Partnership'.
compute LA_CODE = 'DummyPAR0'.

aggregate outfile = *
/break  Link Data LCAname LA_CODE
/number = n.

add files file =*
/file = !OFilesL+ 'Sankey_Link_dataset_FINAL.zsav'.
exe.

SAVE OUTFILE= !OFilesL + 'Sankey_Link_dataset_FINAL.zsav'
    /drop number
   /zcompressed.

get file = !OFilesL + 'Sankey_Link_dataset_FINAL.zsav'.

save outfile =!OFilesL + '/Sankey_Link_dataset_FINAL.zsav'
     /drop cvd copd dementia chd hefailure refailure asthma atrialfib parkinsons liver No_LTC
    /zcompressed.

get file =  !OFilesL + '/Sankey_Link_dataset_FINAL.zsav'.

*produce blank columns to match with Summary dataset.
compute Acute_Ind = 0.
compute AE_Ind = 0.
compute GLS_Ind = 0.
compute Mat_Ind = 0.
compute MH_Ind = 0.
compute No_LTC = 0.
compute OUT_Ind = 0.
compute PIS_Ind = 0.


save outfile =  !OFilesL + '/Sankey_Link_dataset_FINAL.zsav'
  /zcompressed.

get file = !OFilesL + '/Sankey_Link_dataset_FINAL.zsav'.


****Save final Sankey dataset.
save outfile = !OFilesL + 'Sankey_Link_dataset_FINAL.zsav'
   /drop HRI_group1011 HRI_group1112 HRI_group1213 HRI_group1314 
   /zcompressed.

get file =!OFilesL + 'Sankey_Link_dataset_FINAL.zsav'.

rename variables mentalh_episodes = MH_episodes.

rename variables mentalh_inpatient_beddays = MH_inpatient_beddays.

rename variables mentalh_cost = MH_cost.

save outfile = !OFilesL + 'Sankey_Link_dataset_FINAL_Tableau_sorted.zsav'
 /keep Link Data LCAname LA_CODE GenderSTR AgeBand HRI_Group1415 HRI_Group1516 HRI_Group1617 HRI_Group1718 
           PathwayLKP health_net_cost1415 health_net_cost1516 health_net_cost1617 health_net_cost1718 
           health_net_cost1415_min health_net_cost1415_max health_net_cost1516_min  health_net_cost1516_max health_net_cost1617_min
           health_net_cost1617_max health_net_cost1718_min  health_net_cost1718_max  health_net_cost Size Year TNum_LTC TNum_LTC_GRP
           acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost
           gls_episodes gls_inpatient_beddays gls_cost op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag
           diabetes epilepsy cancer arth Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp Num_Ind Acute_Ind AE_Ind GLS_Ind Mat_Ind MH_Ind
           No_LTC OUT_Ind PIS_Ind
 /zcompressed.

save translate outfile = !OFilesL + 'Sankey_Link_dataset_FINAL_Tableau_sorted.csv' 
       /type =csv/map/replace/fieldnames/cells = values.

