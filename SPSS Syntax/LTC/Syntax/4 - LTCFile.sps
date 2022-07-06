* Encoding: UTF-8.
* LTC Syntax 4: Bring together data files from programs 1-3 and create final file for Tableau.
* Original syntax by Jamie Munro.
* Updated by Rachael Bainbridge 24/01/2019
* Updated by Federico Centoni May 2021, 19/20 update; added Clackmannanshire & Stirling data.

*********************.

* Run on Source Dev.
Define !file()
'/conf/sourcedev/TableauUpdates/LTC/Outputs/'
!Enddefine. 

**************************.

* Bring all years data together from syntax 1,2 & 3.

*Add years together from syntax 1.
add files file=  !file + '201718/LTCprogram201718.sav'  
 /file=  !file + '201819/LTCprogram201819.sav'
 /file=  !file + '201920/LTCprogram201920.sav'
 /file = !file + '202021/LTCprogram202021.sav'.
exe.

string Data (A8).
compute data = 'data'.

save outfile = !file + 'LTCprogram.sav'
/zcompressed.

* Localities.

*Add four years together from syntax 3 localities:.
add files file=  !file + '201718/LTClocality201718.sav'
 /file=  !file + '201819/LTClocality201819.sav'  
 /file=  !file + '201920/LTClocality201920.sav'
 /file=  !file + '202021/LTClocality202021.sav'.
execute.

alter type lcacode (F2).
alter type lcacode (A2).
alter type lcaname (A25).

*Match on council area descriptions.
sort cases by lcacode.
match files file=*
 /table '/conf/irf/05-lookups/04-geography/LCA_lookup.sav'
 /by lcacode.
execute.

*Add 9 digit LA Code.
 string LA_CODE (a9).
 if LCAname = 'Scottish Borders' LA_CODE = 'S12000026'.
 if LCAname = 'Fife' LA_CODE = 'S12000015'.
 if LCAname = 'Orkney Islands' LA_CODE = 'S12000023'.
 if LCAname = 'Comhairle nan Eilean Siar' LA_CODE = 'S12000013'.
 if LCAname = 'Dumfries & Galloway' LA_CODE = 'S12000006'.
 if LCAname = 'Shetland Islands' LA_CODE = 'S12000027'.
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
 if LCAname = 'Edinburgh City' LA_CODE = 'S12000036'.
 if LCAname = 'Perth & Kinross' LA_CODE = 'S12000024'.
 if LCAname = 'Dundee City' LA_CODE = 'S12000042'.
 if LCAname = 'Angus' LA_CODE = 'S12000041'.
 if LCAname = 'Clackmannanshire' LA_CODE = 'S12000005'.
 if LCAname = 'Falkirk' LA_CODE = 'S12000014'.
 if LCAname = 'Stirling' LA_CODE = 'S12000030'.

* FC May 2021. Add Clackmannanshire & Stirling.
String Clacks(a30).
IF (LCAname = "Clackmannanshire") or (LCAname = "Stirling") Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE LCAname FROM LCAname Clacks.

string Data (A8).
compute data = 'Loc'.

alter type year (A6).
alter type agegroup(a7).

save outfile = !file + 'LTCLoc.sav'
/zcompressed.

* Mapping data.

*Add years from syntax 2: map data.
add files file=  !file + '201718/LTCmap201718.sav'
 /file=  !file + '201819/LTCmap201819.sav'  
 /file=  !file + '201920/LTCmap201920.sav'
 /file=  !file + '202021/LTCmap202021.sav'.
execute.

string Data (A8).
compute data = 'map'.

alter type year (A6).

save outfile=  !file + 'LTCmap.sav'
/zcompressed.

*bring together 3 files.
get file=  !file + 'LTCprogram.sav'.  

alter type agegroup(a7).
execute.

* change made just to add all three files together - check this works okay.
* if space is an issue when saving the map file may have to amend this.
add files file=* 
 /file =   !file + 'LTCmap.sav'
 /file = !file + 'LTCLoc.sav'.
execute. 

* recode GLS - assume Tableau picks up 50B.
if (recid = 'GLS') recid = '50B'.

string Hbres (A35).
if hbrescode eq 'S08000015' hbres eq 'Ayrshire & Arran Region'.
if hbrescode eq 'S08000016' hbres eq 'Borders Region'.
if hbrescode eq 'S08000017' hbres eq 'Dumfries & Galloway Region'.
if hbrescode eq 'S08000019' hbres eq 'Forth Valley Region'.
if hbrescode eq 'S08000020' hbres eq 'Grampian Region'.
if hbrescode eq 'S08000021' hbres eq 'Greater Glasgow & Clyde Region'.
if hbrescode eq 'S08000022' hbres eq 'Highland Region'.
if hbrescode eq 'S08000023' hbres eq 'Lanarkshire Region'.
if hbrescode eq 'S08000024' hbres eq 'Lothian Region'.
if hbrescode eq 'S08000025' hbres eq 'Orkney Region'.
if hbrescode eq 'S08000026' hbres eq 'Shetland Region'.
if hbrescode eq 'S08000028' hbres eq 'Western Isles Region'.
if hbrescode eq 'S08000029' hbres eq 'Fife Region'.
if hbrescode eq 'S08000030' hbres eq 'Tayside Region'.
exe.

*remove datazone data for datazones assigned to wrong lca. 
compute flag=0.
if datazone = 'S01011696' and lcacode = '17' flag=1. 
if datazone = 'S01008416' and lcacode = '17' flag=1.  
if datazone = 'S01006959' and lcacode = '01' flag=1.  
if datazone = 'S01006950' and lcacode = '01' flag=1.   
if datazone = 'S01006927' and lcacode = '01' flag=1.   
if datazone = 'S01006506' and lcacode = '02' flag=1.    
if datazone = 'S01011974' and lcacode = '03' flag=1.    
if datazone = 'S01007774' and lcacode = '03' flag=1.  
if datazone = 'S01007133' and lcacode = '09' flag=1.   
if datazone = 'S01007141' and lcacode = '09' flag=1.  
if datazone = 'S01007137' and lcacode = '09' flag=1.    
if datazone = 'S01012539' and lcacode = '10' flag=1.  
if datazone = 'S01009763' and lcacode = '11' flag=1.  
if datazone = 'S01009960' and lcacode = '11' flag=1.   
if datazone = 'S01013298' and lcacode = '14' flag=1.   
if datazone = 'S01008029' and lcacode = '22' flag=1.   
if datazone = 'S01007129' and lcacode = '25' flag=1.  
if datazone = 'S01010816' and lcacode = '26' flag=1.  
if datazone = 'S01008303' and lcacode = '26' flag=1.  
if datazone = 'S01007875' and lcacode = '28' flag=1.   
if datazone = 'S01007358' and lcacode = '07' flag=1.  
if datazone = 'S01008099' and lcacode = '17' flag=1.  
if datazone = 'S01006946' and lcacode = '01' flag=1.  
if datazone = 'S01006608' and lcacode = '01' flag=1.  
if datazone = 'S01006931' and lcacode = '01' flag=1.  
if datazone = 'S01011059' and lcacode = '01' flag=1.  
if datazone = 'S01007133' and lcacode = '09' flag=1.  
if datazone = 'S01007137' and lcacode = '09' flag=1.  
if datazone = 'S01012823' and lcacode = '17' flag=1.  
if datazone = 'S01011701' and lcacode = '17' flag=1.  
if datazone = 'S01008107' and lcacode = '17' flag=1.  
if datazone = 'S01010930' and lcacode = '05' flag=1.  
if datazone = 'S01012820' and lcacode = '29' flag=1.  
if datazone = 'S01009071' and lcacode = '23' flag=1.  
if datazone = 'S01010153' and lcacode = '23' flag=1.  
if datazone = 'S01011703' and lcacode = '23' flag=1.  
if datazone = 'S01007141' and lcacode = '09' flag=1.  
if datazone = 'S01007134' and lcacode = '09' flag=1.  
if datazone = 'S01009763' and lcacode = '13' flag=1.  
if datazone = 'S01007358' and lcacode = ' 7' flag=1.  

* remove data assigned to wrong LCA.
select if flag ne 1.
execute.

delete variables flag.

save outfile=  !file + 'LTCfile.sav'
/zcompressed.

alter type year (a7).

if year='201617' year='2016/17'.
if year='201718' year='2017/18'.
if year='201819' year='2018/19'.
if year='201920' year='2019/20'.

* save out final file.
save outfile=   !file + 'LTCfile.sav'.

* Housekeeping:
* Tidy up - erase working files.
 * erase file=  !file + 'LTCprogram.sav'. 
 * erase file=  !file + 'LTCmap.sav'.
 * erase file=  !file + 'LTCLoc.sav'.

 * erase file= !file + 'LTCmap201415.sav'.
 * erase file= !file + 'LTCmap201516.sav'.
 * erase file= !file + 'LTCmap201617.sav'. 
 * erase file= !file + 'LTCmap201718.sav'.
 * erase file= !file + 'LTCmap201819.sav'.
 * erase file= !file + 'LTCprogram201415.sav'.
 * erase file= !file + 'LTCprogram201516.sav'.
 * erase file= !file + 'LTCprogram201617.sav'. 
 * erase file= !file + 'LTCprogram201718.sav'.
 * erase file= !file + 'LTCprogram201819.sav'.
 * erase file= !file + 'LTClocality201415.sav'.
 * erase file= !file + 'LTClocality201516.sav'.
*erase file= !file + 'LTClocality201617.sav'. 
*erase file= !file + 'LTClocality201718.sav'.
*erase file= !file + 'LTClocality201819.sav'.
