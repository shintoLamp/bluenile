* Encoding: UTF-8.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV1/DB3_Summary/'
!Enddefine.




get file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT1.zsav'.


* Temp fix need to correct in main prog.
*RENAME VARIABLES (dementia = dementia_old).
*compute dementia = dementia_OLD = alzheimers.
*exe.

rename variables Neurodegenerative = Neurodegenerative_Grp Cardio = Cardio_Grp Respiratory =  Respiratory_Grp OtherOrgan = OtherOrgan_Grp.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK= year GenderSTR AgeBand TNum_LTC HRI_Group1819 HRI_Group1718 HRI_Group1617 HRI_Group1516 PathwayLKP
  /health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
  op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag deceased_flag_inYR Acute_Ind Mat_Ind MH_Ind GLS_Ind OUT_Ind AE_Ind PIS_Ind
=SUM(health_net_cost acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost gls_episodes gls_inpatient_beddays gls_cost 
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
/file = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'.
*exe.

*select if link ne ''.
*exe.




save outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'
  /drop PathwayLabel
  /zcompressed.

get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT.zsav'.

string LCAname (a10).
compute LCAname eq 'Scotland'.
EXE.



select if tnum_ltc = 'All'.
exe.

*produce blank columns to match with Summary dataset.
compute health_net_cost1718=0.
compute health_net_cost1819=0.
compute health_net_cost1516=0.
compute health_net_cost1617=0.
compute health_net_cost1819_min=0.
compute health_net_cost1819_max=0.
compute health_net_cost1718_min=0.
compute health_net_cost1718_max=0.
compute health_net_cost1516_min=0.
compute health_net_cost1516_max=0.
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

alter type Link(a7).

compute link='no link'.
execute.


save outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT_Tableau_sorted.zsav'
   /keep Link Data LCAname LA_CODE GenderSTR AgeBand HRI_Group1819 HRI_Group1516 HRI_Group1617 HRI_Group1718 
           PathwayLKP health_net_cost1819 health_net_cost1516 health_net_cost1617 health_net_cost1718 
           health_net_cost1819_min health_net_cost1819_max health_net_cost1516_min  health_net_cost1516_max health_net_cost1617_min
           health_net_cost1617_max health_net_cost1718_min  health_net_cost1718_max  health_net_cost Size Year TNum_LTC TNum_LTC_GRP
           acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost
           gls_episodes gls_inpatient_beddays gls_cost op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag
           diabetes epilepsy cancer arth Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp Num_Ind Acute_Ind AE_Ind GLS_Ind Mat_Ind MH_Ind
           No_LTC OUT_Ind PIS_Ind
  /zcompressed.

save translate outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_SCOT_Tableau_sorted.csv' 
       /type =csv/map/replace/fieldnames/cells = values.

