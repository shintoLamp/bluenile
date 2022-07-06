* Encoding: UTF-8.

*Define input/ouput file path.
Define !file()
'/conf/sourcedev/TableauUpdates/A&E/Outputs/'
!Enddefine.


****The syntax below is for adding A&E for the various years together (2016/17 to 2019/20).
****Read in only one file if combining (Part 1,2,3) syntax output files for one financial year only. 

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/202021/AEpart2202021.zsav'.

add files file =*
 /file=  '/conf/sourcedev/TableauUpdates/A&E/Outputs/201920/AEpart2201920.zsav'
 /file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/201819/AEpart2201819.zsav'
 /file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/201718/AEpart2201718.zsav'.
execute. 

String Data (A8).
compute data = 'Data'.
exe.

Save outfile = !file + 'AEprogram.zsav'
/zcompressed.

*The syntax below is for adding *A&E data including locality breakdrown for the various years together (2016/17 to 2019/20).

get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/202021/Locality/AElocality202021.zsav'. 

add files file = *
 /file=  '/conf/sourcedev/TableauUpdates/A&E/Outputs/201920/Locality/AElocality201920.zsav'
 /file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/201819/Locality/AElocality201819.zsav'
 /file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/201718/Locality/AElocality201718.zsav'.
execute. 

select if lcacode ne ''.
exe.

*String Data (A8).
compute Data = 'Loc'.
exe.

Alter type year (A6).
exe. 

Save outfile = !file + 'AElocality.zsav'
/zcompressed.


*Adding all A&E parts (main, mapped by datazone for 2019/20 only and localities for all the various years) together to output the final file

Get file = '/conf/sourcedev/TableauUpdates/A&E/Outputs/202021/AEpart4202021.zsav'.

Alter type year (A6).
exe.  

String Data (A8).
compute Data = 'map'.
exe.

alter type Locname (A70) Postcode (A8).

add files file = *
    /file = !file + 'AEprogram.zsav'
    /file = !file + 'AElocality.zsav'.
Execute.

*Correct variable name format for locality files.

Alter type lcacode (F2).
execute.

If sysmis(lca) lca=lcacode.
execute.  

*Remove datazone data for datazones assigned to wrong lca. 

Compute flag=0.
if datazone = 'S01011696' and lca = 17 flag=1. 
if datazone = 'S01008416' and lca = 17 flag=1.  
if datazone = 'S01006959' and lca = 1 flag=1.  
if datazone = 'S01006950' and lca = 1 flag=1.   
if datazone = 'S01006927' and lca = 1 flag=1.   
if datazone = 'S01006506' and lca = 2 flag=1.    
if datazone = 'S01011974' and lca = 3 flag=1.    
if datazone = 'S01007774' and lca = 3 flag=1.  
if datazone = 'S01007133' and lca = 9 flag=1.   
if datazone = 'S01007141' and lca = 9 flag=1.  
if datazone = 'S01007137' and lca = 9 flag=1.    
if datazone = 'S01012539' and lca = 10 flag=1.  
if datazone = 'S01009763' and lca = 11 flag=1.  
if datazone = 'S01009960' and lca = 11 flag=1.   
if datazone = 'S01013298' and lca = 14 flag=1.   
if datazone = 'S01008029' and lca = 22 flag=1.   
if datazone = 'S01007129' and lca = 25 flag=1.  
if datazone = 'S01010816' and lca = 26 flag=1.  
if datazone = 'S01008303' and lca = 26 flag=1.  
if datazone = 'S01007875' and lca = 28 flag=1.   
if datazone = 'S01007358' and lca = 7 flag=1.  
if datazone = 'S01008099' and lca = 17 flag=1.  
if datazone = 'S01006946' and lca = 1 flag=1.  
if datazone = 'S01006608' and lca = 1 flag=1.  
if datazone = 'S01006931' and lca = 1 flag=1.  
if datazone = 'S01011059' and lca = 1 flag=1.  
if datazone = 'S01007133' and lca = 9 flag=1.  
if datazone = 'S01007137' and lca = 9 flag=1.  
if datazone = 'S01012823' and lca = 17 flag=1.  
if datazone = 'S01011701' and lca = 17 flag=1.  
if datazone = 'S01008107' and lca = 17 flag=1.  
if datazone = 'S01010930' and lca = 5 flag=1.  
if datazone = 'S01012820' and lca = 29 flag=1.  
if datazone = 'S01009071' and lca = 23 flag=1.  
if datazone = 'S01010153' and lca = 23 flag=1.  
if datazone = 'S01011703' and lca = 23 flag=1.  
if datazone = 'S01007141' and lca = 9 flag=1.  
if datazone = 'S01007134' and lca = 9 flag=1.  
if datazone = 'S01009763' and lca = 13 flag=1.  
if datazone = 'S01007358' and lca = 7 flag=1.  
execute.

*frequencies flag.


select if flag ne 1.
exe.
** 4300 cases (0.02%) with wrong LCA were excluded **

**96 cases excluded - JN**

DELETE VARIABLES flag.
exe.

*FC February 2021. The Links Health Centre GP has been added to the A&E data set in error. 
*Therefore the A&E activities improperly recorded with this GP have been removed.   
select if locname ne 'Links Health Centre'.
exe.


save outfile =  !file + 'AE_Final.zsav'
 /zcompressed.


******Add dummy row (add option 'Please select partnership' to LCA dropdown menu)*******

compute lca =0.
compute AE_Num=''.
compute Discharge_Dest=''.
compute agegroup=''.
compute LTCgroup=''.
compute location=''.
compute Ref_source=''.
compute Hbres=''.
compute LCAname= 'Please select partnership'. 
compute attendances=0.
compute individuals=0.
compute cost=0.
compute population=0.
compute scot_population=0.
compute datazone=''.
compute scot_attendances=0.
compute scot_individuals=0.
compute scot_cost=0.
compute Locname=''.
compute Postcode=''.
compute LA_CODE= 'DummyPAR0'.
compute Hb_Treatment=''.
compute year=''.
compute lcacode=0.
compute LTC_Num=''.
compute simd=0.

Aggregate outfile= * 
 /break lca AE_Num Discharge_Dest agegroup LTCgroup location Ref_source Hbres LCAname attendances individuals cost population scot_population datazone
scot_attendances scot_individuals scot_cost Locname Postcode LA_CODE Hb_Treatment year lcacode LTC_Num 
 /simd =sum(simd).
execute. 

Save outfile =  !file + 'temp1.sav'. 

Get file = !file + 'AE_Final.zsav'.

Add files file =*
 /file =   !file + 'temp1.sav'. 
Execute.

save outfile  =  !file + 'AE_Final.sav'.

get file = !file + 'AE_Final.sav'.

alter type year (a7).

if year='201718' year='2017/18'.
if year='201819' year='2018/19'.
if year='201920' year='2019/20'.
if year='202021' year='2020/21'.
execute.

alter type agegroup (a10).

if agegroup='' agegroup='Not Known'.
execute.

save outfile  =  !file + 'AE_Final.sav'.

get file = !file + 'AE_Final.sav'.

*Remove unknown and All age group categories as these aren't required for the final output.
select if agegroup ne 'All' and agegroup ne 'Not Known'.
execute.

save outfile  =  !file + 'AE_Final.sav'.

*The existing Tableau data source (currently connected to AE_Final.sav' can be refreshed by PreProd server by 
*copying the updated AE data source from Source Tabstore.

*The following code to be used only to refresh data from a new Tableau data extract.
 * get file = !file + 'AE_Final.sav'.

 * sort cases by LCAname.
 * match files file=*
/by LCAname
/first TableauFlag.
 * Select if TableauFlag = 1.
 * execute.

 * save outfile = '/conf/sourcedev/TableauUpdates/A&E/AE_Final.sav'
/drop TableauFlag.




