* Encoding: UTF-8.
*A&E Workbook Syntax. 
*Part 1 - Main program. Produce aggregated A&E information (Attendances, Cost, Number of Individuals) down to Hospital level.
*Developed by Jamie Munro 18/04/2016.
*Updated by Federico Centoni 25/05/2021. 

*Macros to define year and location of folder.

Define !year()
'201718'
!Enddefine.

Define !file()
'/conf/sourcedev/TableauUpdates/A&E/Outputs/201718/'
!Enddefine.

Get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year +'.zsav'.

*Select only A&E admissions.
Select if recid = 'AE2'.
exe. 

rename variables Datazone2011 = datazone.
rename variables Anon_CHI = chi.
exe. 

********************
*Data Cleaning:

*Check date of birth.
*alter type dob (a8).
*string date_check_1 (a6).
*string date_check_2 (a6).
*exe.

*compute date_check_1 = substr(chi,1,6).
*compute date_check_2 = concat(char.substr(dob,7,2),char.substr(dob,5,2),char.substr(dob,3,2)).
*exe.

*Flag any issues.
*compute dob_flag = 0.
*if date_check_1 ne date_check_2 dob_flag eq 1.
*exe.

*frequencies variables dob_flag.
* (627 cases, 0.041% found invalid).

*Remove any issues.
*select if dob_flag ne 1.
*exe.

if hbrescode eq 'S08000001' hbrescode eq 'S08000015'.
if hbrescode eq 'S08000002' hbrescode eq 'S08000016'.
if hbrescode eq 'S08000003' hbrescode eq 'S08000029'.
if hbrescode eq 'S08000004' hbrescode eq 'S08000018'.
if hbrescode eq 'S08000005' hbrescode eq 'S08000019'.
if hbrescode eq 'S08000006' hbrescode eq 'S08000020'.
if hbrescode eq 'S08000007' hbrescode eq 'S08000021'.
if hbrescode eq 'S08000008' hbrescode eq 'S08000022'.
if hbrescode eq 'S08000009' hbrescode eq 'S08000023'.
if hbrescode eq 'S08000010' hbrescode eq 'S08000024'.
if hbrescode eq 'S08000011' hbrescode eq 'S08000025'.
if hbrescode eq 'S08000012' hbrescode eq 'S08000026'.
if hbrescode eq 'S08000013' hbrescode eq 'S08000030'.
if hbrescode eq 'S08000014' hbrescode eq 'S08000028'.
exe.

*Recode South and North Lanarkshire residents.

if LCA = '23' or LCA = '29' hbrescode='S08000023'.
exe.

*remove rows with mismatching LCA and HBRES codes.
if hbrescode= 'S08000001' and (LCA ne '10' and LCA ne '22' and LCA ne '28')   LCA ='99'.    
if hbrescode= 'S08000015' and (LCA ne '10' and LCA ne '22' and LCA ne '28')   LCA ='99'.                                                    
if hbrescode ='S08000002' and LCA ne '05'  LCA='99'.
if hbrescode ='S08000016' and LCA ne '05'  LCA='99'.
if hbrescode ='S08000004' and (LCA ne '16')   LCA='99'.                   
if hbrescode ='S08000029' and (LCA ne '16')   LCA='99'.                                     
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
if hbrescode ='S08000030' and (LCA ne '03' and LCA ne '09' and LCA ne '25')   LCA='99'.                                            
if hbrescode ='S08000005' and (LCA ne '06'   and LCA ne '15' and LCA ne '30')  LCA='99'.     
if hbrescode ='S080000019' and (LCA ne '06'   and LCA ne '15' and LCA ne '30')  LCA='99'.                                   
if hbrescode ='S08000014' and LCA ne '32'  LCA='99'.              
if hbrescode ='S08000028' and LCA ne '32'  LCA='99'.                                                                                             
if hbrescode ='S08000003' and LCA ne '08' LCA='99'.            
if hbrescode ='S08000017' and LCA ne '08' LCA='99'.                                                                                                
exe.

select if LCA ne '99'.
exe.

********************************
*Create amended PLICS file;

*Create agegroupings. 

String agegroup (a6).
recode age (0 thru 17='0-17')(18 thru 44='18-44')(45 thru 64= '45-64')(65 thru 74= '65-74')(75 thru 84='75-84')(85 thru hi = '85+') into agegroup.
exe.


RENAME VARIABLES simd2020v2_hb2019_quintile = simd.
exe. 

*Create variable equal to 1 if person has at least one LTC, otherwise equals 0. 

COMPUTE LTC=0.
IF (cvd=1 or copd=1 or dementia=1 or diabetes=1 or chd=1 or hefailure=1 or refailure=1 or epilepsy=1 or asthma=1 or atrialfib=1 or cancer=1 or arth=1 or parkinsons=1 or liver=1 or ms=1) LTC=1. 
exe. 

*Create variable showing number of LTCs a person has;

Compute Num_LTC = sum(cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy, asthma, atrialfib, cancer, arth, parkinsons, liver, ms).
exe. 

String LTC_Num (A2).
If (Num_LTC= 0) LTC_Num= '0'.
If (Num_LTC= 1) LTC_Num='1'.
If (Num_LTC ge 2) LTC_Num='2+'.
exe.

*Create LTC categories; 

Compute Cardiovascular = 0.
If (atrialfib=1) or (chd=1) or (cvd=1) or (hefailure =1) Cardiovascular =1.

Compute Neurodegenerative =0.
If (dementia=1) or (ms=1) or (parkinsons=1) Neurodegenerative =1.

Compute Respiratory =0.
If (asthma=1) or (copd=1) Respiratory =1.

Compute Other_Organs=0.
If (liver=1) or (refailure=1) Other_Organs=1.

Compute Other_LTCs=0.
If (arth=1) or (cancer=1) or (diabetes=1) or (epilepsy=1) Other_LTCs =1.
exe. 

Compute No_LTC=0.
If (LTC=0) No_LTC=1.
exe.

string LTCgroup (A18).
exe. 

*Add variable for episode count.
compute episodes = 1.
exe.

*Simplify AE discharge destination.

String Destination (A60).
If (ae_disdest = '00') Destination = 'Death'.
If (ae_disdest = '01') Destination = 'Private Residence'.
If (ae_disdest = '01A') Destination = 'Private Residence'. 
If (ae_disdest = '01B') Destination = 'Private Residence'.
If (ae_disdest = '02') Destination = 'Residential institution'.
If (ae_disdest = '02A') Destination = 'Residential institution'.
If (ae_disdest = '02B') Destination = 'Residential institution'. 
If (ae_disdest = '03') Destination = 'Other'.
If (ae_disdest = '03A') Destination = 'Other'. 
If (ae_disdest = '03B') Destination = 'Other'.
If (ae_disdest = '03C') Destination = 'Other'.
If (ae_disdest = '03D') Destination = 'Other'.
If (ae_disdest = '03Z') Destination = 'Other'. 
If (ae_disdest = '04') Destination = 'Admission'.
If (ae_disdest = '04A') Destination = 'Admission'.
If (ae_disdest = '04B') Destination = 'Admission'. 
If (ae_disdest = '04C') Destination = 'Admission'.
If (ae_disdest = '04D') Destination = 'Admission'.
If (ae_disdest = '04Z') Destination = 'Admission'.
If (ae_disdest = '05') Destination = 'Transfer'.
If (ae_disdest = '05A') Destination = 'Transfer'.
If (ae_disdest = '05B') Destination = 'Transfer'.
If (ae_disdest = '05C') Destination = 'Transfer'.
If (ae_disdest = '05D') Destination = 'Transfer'. 
If (ae_disdest = '05E') Destination = 'Transfer'.
If (ae_disdest = '05F') Destination = 'Transfer'.
If (ae_disdest = '05G') Destination = 'Transfer'.
If (ae_disdest = '05H') Destination = 'Transfer'.
If (ae_disdest = '05Z') Destination = 'Transfer'.
If (ae_disdest = '06') Destination = 'Other'.
If (ae_disdest = '98') Destination = 'Other'.
If (ae_disdest = '99') Destination = 'Other'.
If (ae_disdest = '') Destination = 'Unknown'.
exe.

String Ref_source (A60).
If (refsource = '01') Ref_source = 'Self referral'.
If (refsource = '01A') Ref_source = 'Self referral'. 
If (refsource = '01B') Ref_source = 'Self referral'.
If (refsource = '02') Ref_source = 'Other'.
If (refsource = '02A') Ref_source = 'GP Referral'.
If (refsource = '02B') Ref_source = 'Other'. 
If (refsource = '02C') Ref_source = 'Ambulance'.
If (refsource = '02D') Ref_source = 'Other'.
If (refsource = '02E') Ref_source = 'Other'.
If (refsource = '02F') Ref_source = 'Other'. 
If (refsource = '02G') Ref_source = 'Other'.
If (refsource = '02H') Ref_source = 'Other'.
If (refsource = '02J') Ref_source = 'GP Referral'.
If (refsource = '03') Ref_source = 'Local Authority'. 
If (refsource = '03A') Ref_source = 'Local Authority'.
If (refsource = '03B') Ref_source = 'Local Authority'.
If (refsource = '03C') Ref_source = 'Local Authority'.
If (refsource = '03D') Ref_source = 'Local Authority'. 
If (refsource = '04') Ref_source = 'Private professional /agency /organisation'.
If (refsource = '05') Ref_source = 'Other'.
If (refsource = '05A') Ref_source = 'Other'.
If (refsource = '05B') Ref_source = 'Other'. 
If (refsource = '05C') Ref_source = 'Other'.
If (refsource = '05D') Ref_source = 'Other'.
If (refsource = '98') Ref_source = 'Other'.
If (refsource = '99') Ref_source = 'Not Known'. 
If (refsource = '') Ref_source = 'Not Known'.
exe.

If (ae_arrivalmode = '01' and Ref_source = 'Self referral') Ref_source = 'Ambulance'.
If (ae_arrivalmode = '02' and Ref_source = 'Self referral') Ref_source = 'Ambulance'.
If (ae_arrivalmode = '03' and Ref_source = 'Self referral') Ref_source = 'Ambulance'.
exe.

select if Ref_source ne ''.
exe. 

sort cases by chi. 
exe. 

save outfile= !file + 'AE' + !year +'.zsav'
 /keep CHI HBRESCODE HBTREATCODE lca datazone simd agegroup LTC_Num cost_total_net episodes
Cardiovascular Neurodegenerative Respiratory Other_Organs Other_LTCs No_LTC LTCgroup location Destination Ref_source
/zcompressed.

*Create variable for number of ae attendances.

get file= !file + 'AE' + !year +'.zsav'. 

aggregate outfile = *
 /break Chi
 /sum_episodes = sum(episodes).
exe. 

String AE_Num (A3).
If (sum_episodes = 1) AE_Num= '1'.
If (sum_episodes ge 2) and (sum_episodes le 4) AE_Num='2-4'.
If (sum_episodes ge 5) AE_Num= '5+'.
exe.

save outfile = !file + 'ae_num' + !year +'.zsav'
/zcompressed.

get file= !file + 'AE' + !year +'.zsav'. 

match files file= * 
 /table = !file + 'ae_num' + !year +'.zsav'
 /by chi. 
exe.  

*select if records have lca code.

select if lca ne ''.
exe. 

save outfile= !file + 'AE' + !year +'.zsav'
/zcompressed.

get file= !file + 'AE' + !year +'.zsav'. 

DELETE VARIABLES hbrescode.
exe.

*Change lca format to remove leading zero.

alter type lca (F2).
alter type lca (A2).
exe.

*Match on council area descriptions.
rename variables lca=lcacode.
sort cases by lcacode.
match files file=*
 /table '/conf/irf/05-lookups/04-geography/LCA_lookup.sav'
 /by lcacode.
exe. 

*Add Health Board names:

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

*aggregate outfile to get category info.

*Cardiovascular.
 
Temporary.
select if Cardiovascular=1.
compute LTCgroup= 'Cardiovascular'.
aggregate outfile= !file + 'temp1.sav'
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(episodes)
/cost = sum(cost_total_net).
exe.

 *Neurodegenerative
 
Temporary.
select if Neurodegenerative=1.
compute LTCgroup= 'Neurodegenerative'.
aggregate outfile= !file + 'temp2.sav'
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(episodes)
/cost = sum(cost_total_net).
exe.

 *Respiratory
 
Temporary.
select if Respiratory=1.
compute LTCgroup= 'Respiratory'.
aggregate outfile= !file + 'temp3.sav'
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(episodes)
/cost = sum(cost_total_net).
exe.

 *Other_Organs
 
Temporary.
select if Other_Organs=1.
compute LTCgroup= 'Other_Organs'.
aggregate outfile= !file + 'temp4.sav'
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(episodes)
/cost = sum(cost_total_net).
exe.

 *Other_LTCs
 
Temporary.
select if Other_LTCs=1.
compute LTCgroup= 'Other_LTCs'.
aggregate outfile= !file + 'temp5.sav'
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(episodes)
/cost = sum(cost_total_net).
exe.

 *No_LTC
 
Temporary.
select if No_LTC=1.
compute LTCgroup= 'No_LTC'.
aggregate outfile= !file + 'temp6.sav'
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(episodes)
/cost = sum(cost_total_net).
exe.

 *No LTC grouping i.e. 'All'. 
 
Temporary.
compute LTCgroup= 'All'.
aggregate outfile= !file + 'temp7.sav'
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(episodes)
/cost = sum(cost_total_net).
exe.

add files file = !file +'temp1.sav'
 /file= !file + 'temp2.sav'
 /file= !file + 'temp3.sav'
 /file= !file + 'temp4.sav'
 /file= !file + 'temp5.sav'
 /file= !file + 'temp6.sav'
 /file= !file + 'temp7.sav'.
exe. 

save outfile= !file + 'AEpart1' + !year +'.zsav'
/zcompressed.

get file= !file + 'AEpart1' + !year +'.zsav'. 

*zsave file with various 'all' values and then aggregate. 

save outfile= !file +'AEpart2' + !year +'.zsav'
/zcompressed.

get file= !file + 'AEpart2' + !year +'.zsav'. 

*Now calculate "All" A&E Discharge destination.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute Destination= 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup  LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" Location Category.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute location = 'All'.

aggregate outfile=*
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
 /attendances = sum(attendances)
 /cost = sum(cost).
exe.

Add files file = *
 /file= !file + 'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" Ref_source Category.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute Ref_source = 'All'.

aggregate outfile=*
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
 /attendances = sum(attendances)
 /cost = sum(cost).
exe.

Add files file = *
 /file= !file + 'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate 'All' Hbtreatment.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute HBTREATCODE= 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup  LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" Destination and "All" location.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute Destination= 'All'.
compute location = 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" Destination and "All" Ref_source.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute Destination= 'All'.
compute Ref_source = 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" location and "All" Ref_source.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute location = 'All'.
compute Ref_source = 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" A&E Discharge destination and 'All' Hbtreatment.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute Destination= 'All'.
compute HBTREATCODE= 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" Location Category and 'All' Hbtreatment.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute location = 'All'.
compute HBTREATCODE= 'All'.

aggregate outfile=*
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
 /attendances = sum(attendances)
 /cost = sum(cost).
exe.

Add files file = *
 /file= !file + 'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" Ref_source Category and 'All' Hbtreatment.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute Ref_source = 'All'.
compute HBTREATCODE= 'All'.

aggregate outfile=*
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
 /attendances = sum(attendances)
 /cost = sum(cost).
exe.

Add files file = *
 /file= !file + 'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" location and "All" Ref_source and 'All' destination.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute location = 'All'.
compute Ref_source = 'All'.
compute destination = 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.


*Now calculate "All" Destination and "All" location and 'All' Hbtreatment.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute Destination= 'All'.
compute location = 'All'.
compute HBTREATCODE= 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" Destination and "All" Ref_source and 'All' Hbtreatment.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute Destination= 'All'.
compute Ref_source = 'All'.
compute HBTREATCODE= 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" location and "All" Ref_source and 'All' Hbtreatment.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute location = 'All'.
compute Ref_source = 'All'.
compute HBTREATCODE= 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Now calculate "All" location and "All" Ref_source and 'All' destination and 'All' Hbtreatment.

get file= !file + 'AEpart1' + !year +'.zsav'. 

compute location = 'All'.
compute Ref_source = 'All'.
compute destination = 'All'.
compute HBTREATCODE= 'All'.

aggregate outfile= *
 /break CHI HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file +'AEpart2' + !year +'.zsav'. 
exe.

save outfile = !file +'AEpart2' + !year +'.zsav'
/zcompressed.

*Aggregate up for CHI level. 

get file= !file +'AEpart2' + !year + '.zsav'.

compute individuals = 1.
exe.

aggregate outfile=*
 /break HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
 /attendances = sum(attendances)
 /individuals= sum(individuals)
 /cost = sum(cost).
exe.

******************
*Aggregate file to get 'All' value for agegroup: 

Temporary.
compute Agegroup = 'All'.
aggregate outfile= !file + 'temp1.sav'
 /break HBTREATCODE lcacode agegroup  LTCgroup ae_num Destination location Ref_source hbres LCAname
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file + 'temp1.sav'.
exe.

*Aggregate file to get 'All' value for ae_num:  

Temporary.
compute ae_num = 'All'.
aggregate outfile= !file + 'temp1.sav'
 /break HBTREATCODE lcacode ae_num Destination agegroup LTCgroup location Ref_source hbres LCAname
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
exe.

Add files file = *
 /file= !file + 'temp1.sav'.
exe.

save outfile = !file + 'AEpart2' + !year +'.zsav'
/zcompressed.

get file= !file + 'AEpart2' + !year +'.zsav'. 


*Match on populations:

Compute sex = 3. 
Alter type sex (F1).
exe.

RENAME VARIABLES lcacode = lca.

alter type lca (f2.0).
sort cases by lca sex agegroup.
match files file=* 
 /table = '/conf/sourcedev/TableauUpdates/A&E/Outputs/Population_Data/agegroups' + !year +'.sav' 
 /by lca sex agegroup.
exe. 


String datazone (A27).
Compute datazone = 'All'. 
exe.

save outfile= !file + 'AEpart2' + !year +'.zsav'
 /drop sex hbres_population
/zcompressed.

get file= !file + 'AEpart2' + !year +'.zsav'. 

*Create scottish counts. 

aggregate outfile = * mode=addvariables
 /break HBTREATCODE agegroup AE_Num LTCgroup Destination Ref_source location datazone 
 /scot_attendances = sum(attendances)
 /scot_individuals = sum(individuals)
 /scot_cost = sum(cost). 

*Match on Hospital names 

RENAME VARIABLES Destination = Discharge_Dest.

SORT CASES by location.
exe.

alter type location(a5).
exe.

Match files file= *
 /table = '/conf/linkage/output/lookups/Unicode/National Reference Files/location.sav' 
 /by location.    
exe. 

If (location = 'All') locname = 'All'. 
exe. 

*Add on missing Glasgow hospital.

If (location = 'G991Z') Locname = 'Stobhill ACH'.
If (location = 'G991Z') Postcode = 'G21 3UW'.  
exe. 

save outfile= !file + 'AEpart2' + !year +'.zsav'
 /drop Add1 Add2 Add3 Add4 Add5 Summary Start Close Destination GpSurgeryInd SMR00 SMR01 SMR02 SMR04 SMR06 SMR11 SMR20 SMR25 SMR30 SMR50 filler
/zcompressed.

get file= !file + 'AEpart2' + !year +'.zsav'.

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
exe.

*FC May 2021. Add Clackmannashire & Stirling.
String Clacks(a30).
IF (LCAname = "Clackmannanshire") or (LCAname = "Stirling") Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE LCAname FROM LCAname Clacks.

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

*Add year 

*String year (A8).
*compute year= !year.
*exe.  

If HBTREATCODE = 'All' Hb_Treatment = 'All'. 
exe.

save outfile= !file + 'AEpart2' + !year +'.zsav'
 /drop HBTREATCODE
/zcompressed.

get file= !file + 'AEpart2' + !year +'.zsav'.

*Create aggregated data for hospitals outside HBres.

Select if Hb_Treatment ne hbres.
Select if Hb_Treatment ne 'All'.
Select if location ne 'All'.
Compute location = 'Other'.
Compute Postcode = 'Other'.
Compute Locname = 'Hospital outside Health Board'.
Compute Hb_Treatment = hbres.
exe.

AGGREGATE outfile = * 
 /break hbres Hb_Treatment lca ae_num Discharge_Dest agegroup LTCgroup location Ref_source Postcode Locname year LA_CODE LCAname datazone
/attendances = sum(attendances)
/scot_attendances = sum(scot_attendances)
/scot_individuals = sum(scot_individuals)
/scot_cost = sum(scot_cost)
/individuals = sum(individuals)
/cost = sum(cost)
/population = max(population)
/scot_population = max(scot_population). 
exe.

save outfile= !file + 'AEtemp' + !year +'.zsav'
/zcompressed.

get file= !file + 'AEpart2' + !year +'.zsav'.

Add files file = * 
 /file =  !file + 'AEtemp' + !year +'.zsav'.

save outfile= !file + 'AEpart2' + !year +'.zsav'
/zcompressed.






















