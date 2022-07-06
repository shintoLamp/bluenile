* Encoding: UTF-8.
* LTC datazone data
* Last updated by Rachael Bainbridge 16/01/2019 - 17/18 update.
* Updated by Bateman McBride, April 2020, 18/19 update.
* Updated by F. Centoni. May 2021, 19/20 update, added Clackmannanshire and Stirling data. 

*Macros to define year.
* need to run for four financial years.
Define !year()
'202021'
!Enddefine. 

* Run on Source Dev ?.
Define !file()
'/conf/sourcedev/TableauUpdates/LTC/Outputs/202021/'
!Enddefine. 

*Create amended SLF file.
get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year +'.zsav'. 

rename variables Anon_CHI = chi.

*Select record types needed.
select if any(recid, '00B', '01B', '02B', '04B', 'GLS', 'AE2', 'PIS').

*Select valid LCA codes.
select if lca ne ''.

* remove blank chi's.
select if chi ne ''.

*Create age groups. 
String agegroup (a6).
recode age (0 thru 17='0-17')(18 thru 44='18-44')(45 thru 64= '45-64')(65 thru 74= '65-74')(75 thru 84='75-84')(85 thru hi = '85+')(sysmis='UnKn') into agegroup.
*if age eq 999 agegroup eq 'Unknown'.
*frequencies agegroup. 

* remove those with missing age group.
select if agegroup ne ''.

*create gender variable.
rename variables gender=sex.
string gender (A8).
if sex =1 gender = 'Male'.
if sex=2 gender='Female'.

*remove those with missing gender.
select if sex=1 or sex=2.
*frequencies gender.

* create Patient Type variable.
string Patient_Type (A12).
if (cij_pattype = 'Non-Elective') Patient_Type = 'Unplanned'.
if (cij_pattype = 'Elective') Patient_Type = 'Planned'.
if (recid= '00B') and (cij_pattype ne 'Non Elective') Patient_Type = 'Planned'.
if (recid= 'AE2') Patient_Type = 'Unplanned'.
if (recid= 'PIS') Patient_Type = 'Prescribing'.
if (cij_pattype = 'Maternity') Patient_Type = 'Maternity'.

*still some blank patient types due to missing pattype_cis.  Use Admission Type to fix.
do if patient_type eq ''.
if char.substr(tadm,1,1) = '3' patient_type = 'Unplanned'.
if char.substr(tadm,1,1) <> '3' patient_type = 'Planned'.
if char.substr(tadm,1,1) = '4' patient_type = 'Maternity'.
end if.
*frequencies Patient_Type

*rename simd.
rename variables simd2020v2_hb2019_quintile = simd.

*aggregate outfile to have one row per chi (ish).
aggregate outfile=* 
 /break CHI HBRESCODE lca gender sex agegroup Patient_Type Datazone2011 simd 
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= max(cvd)
 /copd= max(copd)
 /dementia= max(dementia)
 /diabetes= max(diabetes)
 /chd= max(chd)
 /hefailure= max(hefailure)
 /refailure= max(refailure)
 /epilepsy= max(epilepsy)
 /asthma= max(asthma)
 /atrialfib= max(atrialfib)
 /cancer= max(cancer)
 /arth= max(arth) 
 /parkinsons= max(parkinsons) 
 /liver= max(liver)
 /ms= max(ms).
EXECUTE.

*Lanarkshire correction.
if LCA = '23' or LCA = '29' hbrescode='S08000023'.

*remove rows with mismatching LCA and HBRES codes.
if hbrescode= 'S08000001' and (LCA ne '10' and LCA ne '22' and LCA ne '28')   LCA ='99'.    
if hbrescode= 'S08000015' and (LCA ne '10' and LCA ne '22' and LCA ne '28')   LCA ='99'.                                                    
if hbrescode ='S08000002' and LCA ne '05'  LCA='99'.
if hbrescode ='S08000016' and LCA ne '05'  LCA='99'.
if hbrescode ='S08000004' and (LCA ne '16')   LCA='99'.                   
if hbrescode ='S08000018' and (LCA ne '16')   LCA='99'.                                     
if hbrescode ='S08000007' and (LCA ne '07'  and LCA ne '11' and LCA ne  '13' and LCA ne '17' 
and LCA ne '19'  and LCA ne '26')  LCA ='99'.             
if hbrescode ='S08000021' and (LCA ne '07'  and LCA ne '11' and LCA ne  '13' and LCA ne '17' 
and LCA ne '19'  and LCA ne '26')  LCA ='99'.                          
if hbrescode ='S08000008' and (LCA ne '04' and LCA ne '18')  LCA='99'.    
if hbrescode ='S08000022' and (LCA ne '04' and LCA ne '18')  LCA='99'.                      
if hbrescode='S08000009' and (LCA ne '23' and LCA ne  '29')  LCA='99'.    
if hbrescode='S08000023' and (LCA ne '23' and LCA ne  '29')  LCA='99'.                                                                   
if hbrescode ='S08000006' and (LCA ne '01' and LCA ne  '02' and LCA ne '21')    LCA='99'.            
if hbrescode ='S08000020' and (LCA ne '01' and LCA ne  '02' and LCA ne '21')    LCA='99'.                                                           
if hbrescode ='S08000011' and LCA ne '24' LCA='99'.          
if hbrescode ='S08000025' and LCA ne '24' LCA='99'.                                                                                                           
if hbrescode ='S08000012' and LCA ne '27' LCA='99'.      
if hbrescode ='S08000026' and LCA ne '27' LCA='99'.                                                                                                   
if hbrescode ='S08000010' and (LCA ne '12' and LCA ne '14' and LCA ne '20' and LCA ne '31')  LCA='99'.        
if hbrescode ='S08000024' and (LCA ne '12' and LCA ne '14' and LCA ne '20' and LCA ne '31')  LCA='99'.                                
if hbrescode ='S08000013' and (LCA ne '03' and LCA ne '09' and LCA ne '25')   LCA='99'.         
if hbrescode ='S08000027' and (LCA ne '03' and LCA ne '09' and LCA ne '25')   LCA='99'.                                            
if hbrescode ='S08000005' and (LCA ne '06'   and LCA ne '15' and LCA ne '30')  LCA='99'.     
if hbrescode ='S080000019' and (LCA ne '06'   and LCA ne '15' and LCA ne '30')  LCA='99'.                                   
if hbrescode ='S08000014' and LCA ne '32'  LCA='99'.              
if hbrescode ='S08000028' and LCA ne '32'  LCA='99'.                                                                                             
if hbrescode ='S08000003' and LCA ne '08' LCA='99'.            
if hbrescode ='S08000017' and LCA ne '08' LCA='99'.                                                                                                

select if LCA ne '99'.
exe.

save outfile= !file + !year +'.sav'
/zcompressed.

get file= !file + !year +'.sav'. 

*exclude 1% with null simd.
alter type simd (A1).
select if simd ne ''.
exe.

*Now aggregate again to obtain patient type 'All' value.
temporary.
Compute Patient_Type = 'All'.
aggregate outfile= !file + 'tempM1.sav' 
 /break CHI HBRESCODE lca gender sex agegroup Patient_Type Datazone2011 simd
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= max(cvd)
 /copd= max(copd)
 /dementia= max(dementia)
 /diabetes= max(diabetes)
 /chd= max(chd)
 /hefailure= max(hefailure)
 /refailure= max(refailure)
 /epilepsy= max(epilepsy)
 /asthma= max(asthma)
 /atrialfib= max(atrialfib)
 /cancer= max(cancer)
 /arth= max(arth) 
 /parkinsons= max(parkinsons) 
 /liver= max(liver)
 /ms= max(ms).
 
*Add files together. File still has multiple rows per CHI but these should feed into diifferent breakdowns. 
add files file=* 
 /file= !file + 'tempM1.sav'.
execute.  

*Create variable equal to 1 if person has at least one LTC, otherwise equals 0. 
compute LTC=0.
if (cvd=1 or copd=1 or dementia=1 or diabetes=1 or chd=1 or hefailure=1 or refailure=1 or epilepsy=1 or asthma=1 or atrialfib=1 or cancer=1 or arth=1 or parkinsons=1 or liver=1 or ms=1) LTC=1. 
select if LTC=1. 
string type (A18).

********

save outfile= !file + !year +'.sav'
/zcompressed.

get file= !file + !year +'.sav'.

*Part 1 all LTCs.
temporary.
compute type= 'Any1+'.
aggregate outfile = !file + 'tempM1.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(LTC)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

*Other LTCs.

temporary.
select if cvd = 1.
compute type= 'cvd'.
aggregate outfile = !file + 'tempM2.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(cvd)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if copd = 1.
compute type= 'copd'.
aggregate outfile = !file + 'tempM3.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(copd)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if dementia = 1.
compute type= 'dementia'.
aggregate outfile = !file + 'tempM4.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(dementia)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if diabetes = 1.
compute type= 'diabetes'.
aggregate outfile = !file + 'tempM5.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(diabetes)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if chd = 1.
compute type= 'chd'.
aggregate outfile = !file + 'tempM6.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(chd)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if hefailure = 1.
compute type= 'hefailure'.
aggregate outfile = !file + 'tempM7.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(hefailure)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if refailure = 1.
compute type= 'refailure'.
aggregate outfile =!file + 'tempM8.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(refailure)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if epilepsy = 1.
compute type= 'epilepsy'.
aggregate outfile = !file + 'tempM9.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(epilepsy)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if asthma = 1.
compute type= 'asthma'.
aggregate outfile = !file + 'tempM10.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(asthma)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if atrialfib= 1.
compute type= 'atrialfib'.
aggregate outfile = !file + 'tempM11.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(atrialfib)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if cancer = 1.
compute type= 'cancer'.
aggregate outfile = !file + 'tempM12.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(cancer)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if arth= 1.
compute type= 'arth'.
aggregate outfile = !file + 'tempM13.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(arth)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if parkinsons= 1.
compute type= 'parkinsons'.
aggregate outfile = !file + 'tempM14.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(parkinsons)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if liver= 1.
compute type= 'liver'.
aggregate outfile = !file + 'tempM15.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(liver)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

temporary.
select if ms= 1.
compute type= 'ms'.
aggregate outfile = !file + 'tempM16.sav' 
 /BREAK hbrescode lca agegroup gender type datazone2011 simd Patient_Type 
 /count= sum(ms)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

add files file =!file + 'tempM1.sav' 
 /file = !file + 'tempM2.sav' 
 /file = !file + 'tempM3.sav' 
 /file = !file + 'tempM4.sav'
 /file = !file + 'tempM5.sav' 
 /file =!file + 'tempM6.sav' 
 /file = !file + 'tempM7.sav' 
 /file = !file + 'tempM8.sav'
 /file = !file + 'tempM9.sav' 
 /file = !file + 'tempM10.sav' 
 /file = !file + 'tempM11.sav'
 /file =!file + 'tempM12.sav' 
 /file =!file + 'tempM13.sav' 
 /file = !file + 'tempM14.sav' 
 /file =!file + 'tempM15.sav'
 /file =!file + 'tempM16.sav'.
execute.
  
*aggregate to get 'all' values.
temporary.
compute gender='All'.
aggregate outfile= !file + 'tempM1.sav' 
 /break hbrescode lca gender agegroup type datazone2011 simd Patient_Type 
 /count= sum(count)
 /Cost_Total_Net= sum(Cost_Total_Net).
exe.

temporary.
compute gender='All'.
compute agegroup='All'.
aggregate outfile= !file + 'tempM2.sav' 
 /break hbrescode lca gender agegroup type datazone2011 simd Patient_Type 
 /count= sum(count)
 /Cost_Total_Net= sum(Cost_Total_Net).
exe.

temporary.
compute agegroup='All'.
aggregate outfile= !file + 'tempM3.sav' 
 /break hbrescode lca gender agegroup type datazone2011 simd Patient_Type 
 /count= sum(count)
 /Cost_Total_Net= sum(Cost_Total_Net).
exe.

add files file=* 
 /file= !file + 'tempM1.sav'  
 /file=!file + 'tempM2.sav'  
 /file=!file + 'tempM3.sav'.
execute.

compute sex = 0.
if (gender='Male') sex=1.
if (gender='Female') sex=2.
if (gender='All') sex=3.

alter type lca (A2).

*Match on council area descriptions.
rename variables lca=lcacode.
alter type lcacode (F8.2).
alter type lcacode (A2).
sort cases by lcacode.
match files file=*
 /table '/conf/irf/05-lookups/04-geography/LCA_lookup.sav'
 /by lcacode.
exe.

*match on populations.
**to update link**.
*rename variables datazone=datazone2011.
*alter type datazone2011 (A9).
sort cases by datazone2011 agegroup sex.
alter type agegroup (a6).
match files file=*
 /table = !file + 'Datazone' + !year + '.sav' 
 /by datazone2011 agegroup sex.
Execute. 

rename variables datazone2011= datazone.  
alter type datazone (A27).

select if datazone ne ' '. 

*Add 9 digit LA Code.
String LA_CODE (a9).
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

*FC May 2021. Add Clackmannashire & Stirling.
String Clacks(a30).
IF (LCAname = "Clackmannanshire") or (LCAname = "Stirling") Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE LCAname FROM LCAname Clacks.

string Year (A9).
compute Year= !year.

alter type year (A9).
alter type datazone (A9).

save outfile= !file + 'LTCmap' + !year + '.sav'
/zcompressed.

get file= !file + 'LTCmap' + !year + '.sav'.

**Aggregate on SIMD to get breakdown for Dashboard 4.
temporary.
compute datazone= 'N/A'.
aggregate outfile = !file + 'tempM1.sav'
 /BREAK hbrescode lcacode agegroup gender datazone type simd sex LCAname LA_CODE year Patient_Type 
 /count= sum(count)
 /population = sum(population)
 /Cost_Total_Net= sum(Cost_Total_Net).
execute.

add files file=*
 /file= !file + 'tempM1.sav'.
execute. 

alter type agegroup(a7).
if agegroup = 'UnKn' agegroup = 'Unknown'.

save outfile=  !file + 'LTCmap' + !year + '.sav'
/zcompressed.

get file=  !file + 'LTCmap' + !year + '.sav'. 

*Housekeeping;.
erase file=  !file + !year +'.sav'.
erase file= !file + 'tempM1.sav'.
erase file= !file + 'tempM2.sav'.
erase file= !file + 'tempM3.sav'.
erase file= !file + 'tempM4.sav'.
erase file= !file + 'tempM5.sav'.
erase file= !file + 'tempM6.sav'.
erase file= !file + 'tempM7.sav'.
erase file= !file + 'tempM8.sav'.
erase file= !file + 'tempM9.sav'.
erase file= !file + 'tempM10.sav'.
erase file= !file + 'tempM11.sav'.
erase file= !file + 'tempM12.sav'.
erase file= !file + 'tempM13.sav'.
erase file= !file + 'tempM14.sav'.
erase file= !file + 'tempM15.sav'.
erase file= !file + 'tempM16.sav'.



