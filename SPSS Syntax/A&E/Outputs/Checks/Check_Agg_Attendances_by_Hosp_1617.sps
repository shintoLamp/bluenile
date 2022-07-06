* Encoding: UTF-8.
Define !year()
'201617'
!Enddefine.

Define !file()
'/conf/sourcedev/TableauUpdates/A&E/Outputs/Checks/'
!Enddefine.


Get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year +'.zsav'.

*Select only A&E admissions.
Select if recid = 'AE2'.
exe. 


sort cases by Anon_CHI. 
exe.

*Add variable for episode count.
compute episodes = 1.
exe.

save outfile = !file + 'AE_' + !year +'.zsav'
 /keep Anon_CHI hbrescode hbtreatcode lca location cost_total_net episodes
/zcompressed. 
 

get file = !file + 'AE_' + !year +'.zsav'.

*Select only episodes with CHI information.
select if Anon_CHI ne ''.
exe.

*Calculate aggregated attendances to the individual level by HB_treatment, HB_residence, LCA and Hospital code.
aggregate outfile =*
 /break Anon_CHI hbtreatcode lca location
 /cost = sum(cost_total_net)
 /attendances = sum(episodes). 
execute.

alter type lca (F2).
alter type lca (A2).
exe.

*Match on council area descriptions.
rename variables lca=lcacode.
sort cases by lcacode.
match files file=*
 /table '/conf/irf/05-lookups/04-geography/LCA_lookup.sav'
 /by lcacode.
execute. 

*Select only episodes with LCA information.
select if LCAname ne ''.
exe.

*Add Health Board Residence.
String Hbres (a35).
if LCAname = 'Scottish Borders' hbres eq 'Borders Region'.
if LCAname = 'Fife' hbres eq 'Fife Region'.
if LCAname = 'Orkney Islands' hbres eq 'Orkney Region'.
if LCAname = 'Comhairle nan Eilean Siar' hbres eq 'Western Isles Region'.
if LCAname = 'Dumfries & Galloway' hbres eq 'Dumfries & Galloway Region'.
if LCAname = 'Shetland Islands' hbres eq 'Shetland Region'.
if LCAname = 'North Ayrshire' hbres eq 'Ayrshire & Arran Region'.
if LCAname = 'South Ayrshire' hbres eq 'Ayrshire & Arran Region'.
if LCAname = 'East Ayrshire' hbres eq 'Ayrshire & Arran Region'.
if LCAname = 'East Dunbartonshire' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'Glasgow City' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'East Renfrewshire' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'West Dunbartonshire' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'Renfrewshire' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'Inverclyde' hbres eq 'Greater Glasgow & Clyde Region'.
if LCAname = 'Highland'  hbres eq 'Highland Region'.
if LCAname = 'Argyll & Bute'  hbres eq 'Highland Region'.
if LCAname = 'North Lanarkshire' hbres eq 'Lanarkshire Region'.
if LCAname = 'South Lanarkshire' hbres eq 'Lanarkshire Region'.
if LCAname = 'Aberdeen City' hbres eq 'Grampian Region'.
if LCAname = 'Aberdeenshire' hbres eq 'Grampian Region'.
if LCAname = 'Moray' hbres eq 'Grampian Region'.
if LCAname = 'East Lothian' hbres eq 'Lothian Region'.
if LCAname = 'West Lothian' hbres eq 'Lothian Region'.
if LCAname = 'Midlothian' hbres eq 'Lothian Region'.
if LCAname = 'Edinburgh City' hbres eq 'Lothian Region'.
if LCAname = 'Perth & Kinross' hbres eq 'Tayside Region'.
if LCAname = 'Dundee City' hbres eq 'Tayside Region'.
if LCAname = 'Angus' hbres eq 'Tayside Region'.
if LCAname = 'Clackmannanshire' hbres eq 'Forth Valley Region'.
if LCAname = 'Falkirk' hbres eq 'Forth Valley Region'.
if LCAname = 'Stirling' hbres eq 'Forth Valley Region'.
exe.

*Match location codes on Hospital names.
SORT CASES by location.
exe.

alter type location(a5).
exe.

Match files file= *
 /table = '/conf/linkage/output/lookups/Data Management/standard reference files/location.sav' 
 /by location.    
exe.

String Hb_Treatment (a35).
if HBTREATCODE eq 'S08000015' Hb_Treatment eq 'Ayrshire & Arran Region'.
if HBTREATCODE eq 'S08000016' Hb_Treatment eq 'Borders Region'.
if HBTREATCODE eq 'S08000017' Hb_Treatment eq 'Dumfries & Galloway Region'.
if HBTREATCODE eq 'S08000029' Hb_Treatment eq 'Fife Region'.
if HBTREATCODE eq 'S08000019' Hb_Treatment eq 'Forth Valley Region'.
if HBTREATCODE eq 'S08000020' Hb_Treatment eq 'Grampian Region'.
if HBTREATCODE eq 'S08000021' Hb_Treatment eq 'Greater Glasgow & Clyde Region'.
if HBTREATCODE eq 'S08000022' Hb_Treatment eq 'Highland Region'.
if HBTREATCODE eq 'S08000023' Hb_Treatment eq 'Lanarkshire Region'.
if HBTREATCODE eq 'S08000024' Hb_Treatment eq 'Lothian Region'.
if HBTREATCODE eq 'S08000025' Hb_Treatment eq 'Orkney Region'.
if HBTREATCODE eq 'S08000026' Hb_Treatment eq 'Shetland Region'.
if HBTREATCODE eq 'S08000030' Hb_Treatment eq 'Tayside Region'.
if HBTREATCODE eq 'S08000028' Hb_Treatment eq 'Western Isles Region'.
exe.

select if HB_treatment eq 'Orkney Region'.
exe.

frequencies location.
frequencies locname.

*Add variable for individuals count.
compute individuals = 1.
exe.

*Calculate aggregated Costs and Attendances by Hb_treatment, Hospital Location Code for each LCA.
aggregate outfile =*
 /break Hb_Treatment hbres LCAname locname
 /individuals = sum(individuals)
 /cost = sum(cost)
 /attendances = sum(attendances). 
execute.

frequencies HB_treatment.

String finyear(A12).
compute finyear ='2019/20'.

save outfile = !file + 'Agg_AE_' + !year +'.zsav'
  /zcompressed.


