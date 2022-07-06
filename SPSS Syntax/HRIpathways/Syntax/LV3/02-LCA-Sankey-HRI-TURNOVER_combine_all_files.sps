* Encoding: UTF-8.
* File zsave location.
define !OFilesL()
       '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Sankey_DB2/'
!Enddefine.



*Combine all files for Sankey datasets.

get file = !OFilesL + 'temp_HRI_LA_ALLYR1.zsav'.

add files file = *
/file = !OFilesL + 'temp_HRI_LA_ALLYR2.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR3.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR4.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR5.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR6.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR7.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR8.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR9.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR10.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR11.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR12.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR13.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR14.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR15.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR16.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR17.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR18.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR19.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR20.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR21.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR22.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR23.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR24.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR25.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR26.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR27.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR28.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR29.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR30.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR31.zsav'
/file = !OFilesL + 'temp_HRI_LA_ALLYR32.zsav'.
EXE.

alter type LCA_Select (a2).
alter type ageband (a8).

add files file = *
/file= '/conf/irf/09-Tableau-Outputs/01-Development/04-Source-Data/03-HRI/Sankey_Link_dataset_Dummy.sav'.
execute.


string Link (a4).
Compute Link = "link".
exe.

if AgeBand = "All" AgeBand = "All ages".
exe.


compute Data = "Sankey".
EXE.

Select if PathwayLabel NE "Remove".
EXE.

save OUTFILE = !OFilesL + 'Sankey_Link_dataset_FINAL.zsav'
  /drop  PathwayLabel
  /zcompressed.

 
get FILE=  !OFilesL + 'Sankey_Link_dataset_FINAL.zsav'.

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

*frequency variables = LCAname.

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

save OUTFILE=  !OFilesL+ 'Sankey_Link_dataset_FINAL.zsav'
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
execute.

save OUTFILE= !OFilesL + 'Sankey_Link_dataset_FINAL.zsav'
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


****zsave final Sankey dataset.
save outfile = !OFilesL + 'Sankey_Link_dataset_FINAL.zsav'
   /drop HRI_group1011 HRI_group1112 HRI_group1213 HRI_group1314
   /zcompressed.

get file =!OFilesL + 'Sankey_Link_dataset_FINAL.zsav'.

rename variables mentalh_episodes = MH_episodes.

rename variables mentalh_inpatient_beddays = MH_inpatient_beddays.

rename variables mentalh_cost = MH_cost.

save outfile = !OFilesL + 'Sankey_Link_dataset_FINAL_Tableau_sorted.zsav'
 /keep Link Data LCAname LA_CODE GenderSTR AgeBand HRI_Group1617 HRI_Group1718 HRI_Group1819 HRI_Group1920
           PathwayLKP health_net_cost1819 health_net_cost1920 health_net_cost1617 health_net_cost1718 
           health_net_cost1819_min health_net_cost1819_max health_net_cost1920_min  health_net_cost1920_max health_net_cost1617_min
           health_net_cost1617_max health_net_cost1718_min  health_net_cost1718_max  health_net_cost Size Year TNum_LTC TNum_LTC_GRP
           acute_episodes acute_inpatient_beddays acute_cost mat_episodes mat_inpatient_beddays mat_cost MH_episodes MH_inpatient_beddays MH_cost
           gls_episodes gls_inpatient_beddays gls_cost op_newcons_attendances op_cost_attend ae_attendances ae_cost pis_dispensed_items pis_cost deceased_flag
           diabetes epilepsy cancer arth Neurodegenerative_Grp Cardio_Grp Respiratory_Grp OtherOrgan_Grp Num_Ind Acute_Ind AE_Ind GLS_Ind Mat_Ind MH_Ind
           No_LTC OUT_Ind PIS_Ind
  /zcompressed.

get file = !OFilesL + 'Sankey_Link_dataset_FINAL_Tableau_sorted.zsav'.

save translate outfile = !OFilesL + 'Sankey_Link_dataset_FINAL_Tableau_sorted.csv' 
       /type =csv/map/replace/fieldnames/cells = values.

