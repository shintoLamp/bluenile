* Encoding: UTF-8.
*A&E Workbook Syntax.
*Part 3 produces aggregated A&E information to locality level.  
*Developed by Jamie Munro 22/04/2016.
*Updated by Federico Centoni 10/07/2018.

*Macros to define year.

Define !year()
'201718'
!Enddefine.

define !file()
'/conf/sourcedev/TableauUpdates/A&E/Output/'
!enddefine.

Get file = '/conf/hscdiip/01-Source-linkage-files/source-episode-file-' + !year +'.zsav'. 


rename variables Datazone2011 = datazone.
execute. 

*Select only A&E admissions;

Select if recid = 'AE2'.
execute. 


*rename variables datazone2011 = datazone.
*execute.

********************

*Data Cleaning:

RENAME VARIABLES Anon_chi=chi.

*Check date of birth.
alter type dob (a8).
string date_check_1 (a6).
string date_check_2 (a6).
compute date_check_1 = substr(chi,1,6).
compute date_check_2 = concat(substr(dob,7,2),substr(dob,5,2),substr(dob,3,2)).
exe.

*Flag any issues.
compute dob_flag = 0.
if date_check_1 ne date_check_2 dob_flag eq 1.
exe.

*Remove any issues.
select if dob_flag ne 1.
exe.

if hbrescode eq 'S08000001' hbrescode eq 'S08000015'.
if hbrescode eq 'S08000002' hbrescode eq 'S08000016'.
if hbrescode eq 'S08000003' hbrescode eq 'S08000017'.
if hbrescode eq 'S08000004' hbrescode eq 'S08000018'.
if hbrescode eq 'S08000005' hbrescode eq 'S08000019'.
if hbrescode eq 'S08000006' hbrescode eq 'S08000020'.
if hbrescode eq 'S08000007' hbrescode eq 'S08000021'.
if hbrescode eq 'S08000008' hbrescode eq 'S08000022'.
if hbrescode eq 'S08000009' hbrescode eq 'S08000023'.
if hbrescode eq 'S08000010' hbrescode eq 'S08000024'.
if hbrescode eq 'S08000011' hbrescode eq 'S08000025'.
if hbrescode eq 'S08000012' hbrescode eq 'S08000026'.
if hbrescode eq 'S08000013' hbrescode eq 'S08000027'.
if hbrescode eq 'S08000014' hbrescode eq 'S08000028'.
exe.

*Recode South and North Lanarkshire residents.

if LCA = '23' or LCA = '29' hbrescode='S08000023'.
execute.

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
exe.

select if LCA ne '99'.
execute.

********************************
*Create amended PLICS file;

*Add in localities.

sort cases by datazone.
exe.

rename variables  datazone=Datazone2011.

match files file = *
 /table = '/conf/sourcedev/TableauUpdates/LTC/HSCP Localities_DZ11_Lookup_20180903.sav'
 /by Datazone2011.
EXECUTE.

if locality = '' locality = 'No Locality Information'.
execute.

*Create agegroupings. 

String agegroup (a6).
recode age (0 thru 17='0-17')(18 thru 44='18-44')(45 thru 64= '45-64')(65 thru 74= '65-74')(75 thru 84='75-84')(85 thru hi = '85+') into agegroup.
execute.


*Create variable equal to 1 if person has at least one LTC, otherwise equals 0. 

COMPUTE LTC=0.
IF (cvd=1 or copd=1 or dementia=1 or diabetes=1 or chd=1 or hefailure=1 or refailure=1 or epilepsy=1 or asthma=1 or atrialfib=1 or cancer=1 or arth=1 or parkinsons=1 or liver=1 or ms=1) LTC=1. 
Execute. 

*Create variable showing number of LTCs a person has;

Compute Num_LTC = sum(cvd, copd, dementia, diabetes, chd, hefailure, refailure, epilepsy, asthma, atrialfib, cancer, arth, parkinsons, liver, ms).
execute. 

String LTC_Num (A2).
If (Num_LTC= 0) LTC_Num= '0'.
If (Num_LTC= 1) LTC_Num='1'.
If (Num_LTC ge 2) LTC_Num='2+'.
execute.

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
execute. 

Compute No_LTC=0.
If (LTC=0) No_LTC=1.
execute.

string LTCgroup (A18).
execute. 

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
execute.

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
execute.

If (ae_arrivalmode = '01' and Ref_source = 'Self referral') Ref_source = 'Ambulance'.
If (ae_arrivalmode = '02' and Ref_source = 'Self referral') Ref_source = 'Ambulance'.
If (ae_arrivalmode = '03' and Ref_source = 'Self referral') Ref_source = 'Ambulance'.
execute.

select if Ref_source ne ''.
execute. 

sort cases by chi. 
execute. 

save outfile= !file + 'AE' + !year +'.zsav'
 /keep CHI HBRESCODE HBTREATCODE lca locality  agegroup LTC_Num cost_total_net episodes
Cardiovascular Neurodegenerative Respiratory Other_Organs Other_LTCs No_LTC LTCgroup location Destination Ref_source
 /zcompressed.

*Create variable for number of ae attendances.

get file= !file + 'AE' + !year +'.zsav'. 

aggregate outfile = *
 /break Chi
 /sum_episodes = sum(episodes).
execute. 

String AE_Num (A3).
If (sum_episodes = 1) AE_Num= '1'.
If (sum_episodes ge 2) and (sum_episodes le 4) AE_Num='2-4'.
If (sum_episodes ge 5) AE_Num= '5+'.
execute.

save outfile = !file + 'ae_num' + !year +'.sav'. 

get file= !file + 'AE' + !year +'.zsav'. 

match files file= * 
 /table = !file + 'ae_num' + !year +'.sav'
 /by chi. 
execute.  

*select if records have lca code.

select if lca ne ''.
execute. 

save outfile= !file + 'AE' + !year +'.zsav'
 /zcompressed. 

get file= !file + 'AE' + !year +'.zsav'. 


 *No LTC grouping i.e. 'All'. 
 
compute LTCgroup= 'N/A'.
aggregate outfile= *
 /break CHI HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location locality Ref_source
/attendances = sum(episodes)
/cost = sum(cost_total_net).
execute.


*alter format to allow 'All' category.

alter type LTC_Num (A3).
execute.  

save outfile= !file + 'AEpart3' + !year +'.zsav'
 /zcompressed. 

get file= !file + 'AEpart3' + !year +'.zsav'. 

*Create flag for each person to count numbers.

Compute individuals =1. 
execute.

aggregate outfile= *
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num  LTCgroup location locality Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

save outfile= !file +'AElocality' + !year +'.zsav'
  /zcompressed. 

get file= !file + 'AElocality' + !year +'.zsav'. 


*Now calculate "All" Location Category.

get file= !file + 'AEpart3' + !year +'.zsav'. 

compute location = 'All'.

aggregate outfile=*
 /break CHI HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location locality Ref_source
 /attendances = sum(attendances)
 /cost = sum(cost).
execute.

compute individuals = 1.
exe.

aggregate outfile=*
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location locality Ref_source
 /attendances = sum(attendances)
 /individuals= sum(individuals)
 /cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'AElocality' + !year +'.zsav'. 
execute.

save outfile = !file +'AElocality' + !year +'.zsav'
 /zcompressed. 

*Now calculate "All" Ref_source Category.

get file= !file + 'AEpart3' + !year +'.zsav'. 

compute Ref_source = 'All'.

aggregate outfile=*
 /break CHI HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location Ref_source locality  
 /attendances = sum(attendances)
 /cost = sum(cost).
execute.

compute individuals = 1.
exe.

aggregate outfile=*
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location Ref_source locality  
 /attendances = sum(attendances)
 /individuals= sum(individuals)
 /cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'AElocality' + !year +'.zsav'. 
execute.

save outfile = !file +'AElocality' + !year +'.zsav'
  /zcompressed. 

*Now calculate "All" location and "All" Ref_source.

get file= !file + 'AEpart3' + !year +'.zsav'. 

compute location = 'All'.
compute Ref_source = 'All'.

aggregate outfile= *
 /break CHI HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location Ref_source locality  
/attendances = sum(attendances)
/cost = sum(cost).
execute.

compute individuals = 1.
exe.

aggregate outfile=*
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location Ref_source locality  
 /attendances = sum(attendances)
 /individuals= sum(individuals)
 /cost = sum(cost).
execute.

Add files file = *
 /file= !file +'AElocality' + !year +'.zsav'. 
execute.

save outfile = !file +'AElocality' + !year +'.zsav'
  /zcompressed. 

get file= !file +'AElocality' + !year + '.zsav'.

*Aggregate file to get 'All' value for agegroup: 

Temporary.
compute Agegroup = 'all'.
aggregate outfile= !file + 'temp1.sav'
 /break HBRESCODE HBTREATCODE lca agegroup LTC_Num  LTCgroup ae_num location locality Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'temp1.sav'.
execute.

*Aggregate file to get 'All' value for LTC_num:  

Temporary.
compute LTC_Num = 'All'.
aggregate outfile= !file + 'temp1.sav'
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location locality Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'temp1.sav'.
execute.

save outfile = !file + 'AElocality' + !year +'.zsav'
  /zcompressed.

get file= !file + 'AElocality' + !year +'.zsav'. 

*Aggregate file to get 'All' value for ae_num:  

Temporary.
compute ae_num = 'All'.
aggregate outfile= !file + 'temp1.sav'
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location locality Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'temp1.sav'.
execute.

save outfile = !file + 'AElocality' + !year +'.zsav'
 /zcompressed.

get file= !file + 'AElocality' + !year +'.zsav'. 

Alter type lca (F2.0).
execute.

If agegroup = 'all' agegroup = 'All'. 
execute. 

*Now aggegate for 'All' locality.

Temporary.
compute locality = 'Agg'.
aggregate outfile= !file + 'temp1.sav'
 /break HBRESCODE HBTREATCODE lca ae_num agegroup LTC_Num LTCgroup location locality Ref_source
/attendances = sum(attendances)
/individuals = sum(individuals)
/cost = sum(cost).
execute.

Add files file = *
 /file= !file + 'temp1.sav'.
execute.

save outfile = !file + 'AElocality' + !year +'.zsav'
 /zcompressed.

get file= !file + 'AElocality' + !year +'.zsav'. 

*Match on Hospital names 

SORT CASES by location.
execute.

alter type location (a5).

Match files file= *
 /table = '/conf/linkage/output/lookups/Data Management/standard reference files/location.sav' 
 /by location.    
execute.

If (location = 'All') locname = 'All'. 
execute. 

*Add on missing Glasgow hospital.

If (location = 'G991Z') Locname = 'Stobhill ACH'.
execute. 

save outfile= !file + 'AElocality' + !year +'.zsav'
 /drop Add1 Add2 Add3 Add4 Add5 Summary Start Close Destination GpSurgeryInd SMR00 SMR01 SMR02 SMR04 SMR06 SMR11 SMR20 SMR25 SMR30 SMR50 filler
 /zcompressed. 

get file= !file + 'AElocality' + !year +'.zsav'.  
 
*Match on council area descriptions.
rename variables lca=lcacode.
alter type lcacode (A2).
sort cases by lcacode.
match files file=*
 /table '/conf/irf/05-lookups/04-geography/LCA_lookup.sav'
 /by lcacode.
execute. 


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
EXECUTE.

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
EXECUTE.

String Hb_Treatment (a35).
if HBTREATCODE eq 'S08000001' Hb_Treatment eq 'Ayrshire & Arran Region'.
if HBTREATCODE eq 'S08000002' Hb_Treatment eq 'Borders Region'.
if HBTREATCODE eq 'S08000003' Hb_Treatment eq 'Dumfries & Galloway Region'.
if HBTREATCODE eq 'S08000004' Hb_Treatment eq 'Fife Region'.
if HBTREATCODE eq 'S08000005' Hb_Treatment eq 'Forth Valley Region'.
if HBTREATCODE eq 'S08000006' Hb_Treatment eq 'Grampian Region'.
if HBTREATCODE eq 'S08000007' Hb_Treatment eq 'Greater Glasgow & Clyde Region'.
if HBTREATCODE eq 'S08000008' Hb_Treatment eq 'Highland Region'.
if HBTREATCODE eq 'S08000009' Hb_Treatment eq 'Lanarkshire Region'.
if HBTREATCODE eq 'S08000010' Hb_Treatment eq 'Lothian Region'.
if HBTREATCODE eq 'S08000011' Hb_Treatment eq 'Orkney Region'.
if HBTREATCODE eq 'S08000012' Hb_Treatment eq 'Shetland Region'.
if HBTREATCODE eq 'S08000013' Hb_Treatment eq 'Tayside Region'.
if HBTREATCODE eq 'S08000014' Hb_Treatment eq 'Western Isles Region'.
if HBTREATCODE eq 'S08000015' Hb_Treatment eq 'Ayrshire & Arran Region'.
if HBTREATCODE eq 'S08000016' Hb_Treatment eq 'Borders Region'.
if HBTREATCODE eq 'S08000017' Hb_Treatment eq 'Dumfries & Galloway Region'.
if HBTREATCODE eq 'S08000018' Hb_Treatment eq 'Fife Region'.
if HBTREATCODE eq 'S08000019' Hb_Treatment eq 'Forth Valley Region'.
if HBTREATCODE eq 'S08000020' Hb_Treatment eq 'Grampian Region'.
if HBTREATCODE eq 'S08000021' Hb_Treatment eq 'Greater Glasgow & Clyde Region'.
if HBTREATCODE eq 'S08000022' Hb_Treatment eq 'Highland Region'.
if HBTREATCODE eq 'S08000023' Hb_Treatment eq 'Lanarkshire Region'.
if HBTREATCODE eq 'S08000024' Hb_Treatment eq 'Lothian Region'.
if HBTREATCODE eq 'S08000025' Hb_Treatment eq 'Orkney Region'.
if HBTREATCODE eq 'S08000026' Hb_Treatment eq 'Shetland Region'.
if HBTREATCODE eq 'S08000027' Hb_Treatment eq 'Tayside Region'.
if HBTREATCODE eq 'S08000028' Hb_Treatment eq 'Western Isles Region'.
execute.

*Add year 

String year (A8).
compute year= !year.
execute.  

String data (A8).
Compute data = 'Loc'.
execute.


save outfile= !file + 'AElocality' + !year +'.zsav'
 /drop HBTREATCODE HBRESCODE
 /zcompressed.

get file = !file +  'AElocality' + !year +'.zsav'.


****END.





