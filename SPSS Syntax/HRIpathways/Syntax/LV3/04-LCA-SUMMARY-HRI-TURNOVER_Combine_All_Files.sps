* Encoding: UTF-8.

* File save location.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Summary_DB3/'
!Enddefine.


**********************************************************************************************************************.
get file = !OFilesL + 'Sankey_Link_dataset_LCAFINALT1.zsav'.

add files file = *
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT2.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT3.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT4.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT5.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT6.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT7.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT8.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT9.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT10.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT11.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT12.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT13.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT14.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT15.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT16.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT17.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT18.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT19.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT20.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT21.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT22.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT23.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT24.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT25.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT26.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT27.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT28.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT29.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT30.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT31.zsav'
/file =!OFilesL + 'Sankey_Link_dataset_LCAFINALT32.zsav'.
EXE.

* Temp fix need to correct in main prog.
*RENAME VARIABLES (dementia = dementia_old).
*compute dementia = dementia_OLD = alzheimers.
*EXECUTE.

rename variables Neurodegenerative = Neurodegenerative_Grp Cardio = Cardio_Grp Respiratory =  Respiratory_Grp OtherOrgan = OtherOrgan_Grp.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=LCA_Select year GenderSTR AgeBand TNum_LTC HRI_Group1617 HRI_Group1718 HRI_Group1819 HRI_Group1920 PathwayLKP
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

*RH May 2021. Add Clackmannanshire & Stirling.
String Clacks(a30).
IF LCAname="Clackmannanshire" or LCAname="Stirling" Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE LCAname FROM LCAname Clacks.

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
exe.

aggregate outfile = *
/break Link Data LCAname LA_CODE
/number = n.
exe.

add files file =*
/file = !OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'.
exe.

select if link ne ''.
exe.

SAVE OUTFILE=!OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'
  /drop number alzheimers HRI_Group1011 HRI_Group1112 HRI_Group1213 HRI_Group1314 PathwayLabel
 /zcompressed.


get file = !OFilesL + 'Summary_Link_dataset_LCAFINAL.zsav'.


select if tnum_ltc = 'All'.
exe.

*produce blank columns to match with Sankey dataset.
compute health_net_cost1617=0.
compute health_net_cost1718=0.
compute health_net_cost1819=0.
compute health_net_cost1920=0.
compute health_net_cost1617_min=0.
compute health_net_cost1617_max=0.
compute health_net_cost1718_min=0.
compute health_net_cost1718_max=0.
compute health_net_cost1819_min=0.
compute health_net_cost1819_max=0.
compute health_net_cost1920_min=0.
compute health_net_cost1920_max=0. 
compute Size = 0.
exe.


****Save final Summary dataset.
save outfile = !OFilesL + '/Summary_Link_dataset_LCAFINAL.zsav'
    /drop mentalh_episodes mentalh_inpatient_beddays mentalh_cost
   /zcompressed.


* Sorting data to combine Summary_link data with Sankey_link data for Tableau.
get file = !OFilesL + '/Summary_Link_dataset_LCAFINAL.zsav'.

save outfile = !OFilesL + '/Summary_Link_dataset_LCAFINAL_Tableau_sorted.zsav'
  /keep Link Data LCAname LA_CODE GenderSTR AgeBand HRI_Group1819 HRI_Group1920 HRI_Group1617 HRI_Group1718 
           PathwayLKP health_net_cost1819 health_net_cost1920 health_net_cost1617 health_net_cost1718 
           health_net_cost1819_min health_net_cost1819_max health_net_cost1920_min  health_net_cost1920_max health_net_cost1617_min
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

save outfile = !OFilesL + '/Summary_Link_dataset_LCAFINAL_Tableau_sorted.zsav'
  /zcompressed.

get file = !OFilesL + '/Summary_Link_dataset_LCAFINAL_Tableau_sorted.zsav'.

save translate outfile = !OFilesL + 'Summary_Link_dataset_LCAFINAL_Tableau_sorted.csv' 
       /type = csv/map/replace/fieldnames/cells = values.

