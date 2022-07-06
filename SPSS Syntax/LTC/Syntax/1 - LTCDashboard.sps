* Encoding: UTF-8.
* LTC Syntax 1: Main data for dashboard. 
* Jamie Munro 7/03/2016.
* Last updated by Rachael Bainbridge 22/01/2019 - 17/18 update.
* Updated by Bateman McBride April 2020, 18/19 update.
* Updated by Federico Centoni May 2021, 19/20 update; added Clackmannanshire and Stirling data. 

* Macros to define year.
* Need to run for four financial years.
Define !year()
'202021'
!Enddefine. 

* Run on Source Dev.
Define !file()
'/conf/sourcedev/TableauUpdates/LTC/Outputs/202021/'
!Enddefine. 

****************************.

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
If char.substr(tadm,1,1) = '3' patient_type = 'Unplanned'.
If char.substr(tadm,1,1) <> '3' patient_type = 'Planned'.
if char.substr(tadm,1,1) = '4' patient_type = 'Maternity'.
end if.
*frequencies Patient_Type.

*aggregate outfile to have one row per chi (ish).
aggregate outfile=* 
 /break CHI HBRESCODE lca gender sex agegroup Patient_Type recid
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

save outfile= !file + 'LTC' + !year +'.sav'
/zcompressed.

get file= !file + 'LTC' + !year +'.sav'. 

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

save outfile= !file + 'LTC' + !year +'.sav'
/zcompressed.

get file= !file + 'LTC' + !year +'.sav'. 

*Now aggregate again to obtain patient type and recid  'All' value.
temporary.
Compute Patient_Type = 'All'.
aggregate outfile=  !file + 'temp1.sav' 
 /break CHI HBRESCODE lca gender sex agegroup Patient_Type recid 
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
 
temporary.
Compute recid = 'All'.
aggregate outfile= !file + 'temp2.sav' 
 /break CHI HBRESCODE lca gender sex agegroup Patient_Type recid 
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
execute. 

temporary.
Compute Patient_Type = 'All'.
Compute recid = 'All'.
aggregate outfile= !file + 'temp3.sav' 
 /break CHI HBRESCODE lca gender sex agegroup Patient_Type recid 
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
execute. 

*Add files together. File still has multiple rows per CHI but these should feed into diifferent breakdowns. 

add files file=* 
 /file= !file + 'temp1.sav' 
 /file= !file + 'temp2.sav' 
 /file= !file + 'temp3.sav'.
execute.

*Create variable equal to 1 if person has at least one LTC, otherwise equals 0. 
compute LTC=0.
if (cvd=1 or copd=1 or dementia=1 or diabetes=1 or chd=1 or hefailure=1 or refailure=1 or epilepsy=1 or asthma=1 or atrialfib=1 or cancer=1 or arth=1 or parkinsons=1 or liver=1 or ms=1) LTC=1. 

string type (A18).

********

save outfile= !file + !year +'.sav'
/zcompressed.

get file= !file + !year +'.sav'.

*******
Aggregate on variables of interest and then add together into one file.

*All LTCs.
temporary.
select if LTC=1.
compute type='Any1+'.
aggregate outfile = !file + 'temp1.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type 
 /count= sum(LTC)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*Cvd.
temporary.
select if cvd=1.
compute type='cvd'.
aggregate outfile =  !file + 'temp2.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(cvd)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*copd.
temporary.
select if copd=1.
compute type='copd'.
aggregate outfile = !file + 'temp3.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(copd)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*dementia.
temporary.
select if dementia=1.
compute type='dementia'.
aggregate outfile = !file + 'temp4.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(dementia)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*diabetes.
temporary.
select if diabetes=1.
compute type='diabetes'.
aggregate outfile = !file + 'temp5.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(diabetes)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*chd.
temporary.
select if chd=1.
compute type='chd'.
aggregate outfile =  !file + 'temp6.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(chd)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*hefailure.
temporary.
select if hefailure=1.
compute type='hefailure'.
aggregate outfile = !file + 'temp7.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(hefailure)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*refailure.
temporary.
select if refailure=1.
compute type='refailure'.
aggregate outfile = !file + 'temp8.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(refailure)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*epilepsy.
temporary.
select if epilepsy=1.
compute type='epilepsy'.
aggregate outfile = !file + 'temp9.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(epilepsy)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*asthma.
temporary.
select if asthma=1.
compute type='asthma'.
aggregate outfile = !file + 'temp10.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(asthma)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*atrialfib.
temporary.
select if atrialfib=1.
compute type='atrialfib'.
aggregate outfile =  !file + 'temp11.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(atrialfib)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*cancer.
temporary.
select if cancer=1.
compute type='cancer'.
aggregate outfile = !file + 'temp12.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(cancer)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*arth.
temporary.
select if arth=1.
compute type='arth'.
aggregate outfile = !file + 'temp13.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(arth)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*parkinsons.
temporary.
select if parkinsons=1.
compute type='parkinsons'.
aggregate outfile =  !file + 'temp14.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(parkinsons)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*liver.
temporary.
select if liver=1.
compute type='liver'.
aggregate outfile =  !file + 'temp15.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(liver)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*ms.
temporary.
select if ms=1.
compute type='ms'.
aggregate outfile = !file + 'temp16.sav' 
 /break HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(ms)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.


add files file =  !file + 'temp1.sav' 
 /file=  !file + 'temp2.sav'  
 /file=   !file + 'temp3.sav'  
 /file=  !file + 'temp4.sav'  
 /file=   !file + 'temp5.sav'  
 /file=  !file + 'temp6.sav'  
 /file=   !file + 'temp7.sav'  
 /file=  !file + 'temp8.sav'  
 /file=  !file + 'temp9.sav'  
 /file=  !file + 'temp10.sav'  
 /file=   !file + 'temp11.sav'  
 /file=  !file + 'temp12.sav'  
 /file=  !file + 'temp13.sav'  
 /file=  !file + 'temp14.sav'  
 /file=  !file + 'temp15.sav'  
 /file=  !file + 'temp16.sav'.  
execute.

save outfile=  !file + 'LTCprogram1.sav'
/zcompressed.

get file=  !file + 'LTCprogram1.sav'.  

*Aggregate file again to obtain age and gender 'All' value. 
temporary.
compute agegroup ='All'. 
aggregate outfile= !file + 'temp1.sav' 
 /BREAK HBRESCODE lca gender sex agegroup recid Patient_Type type
 /count= sum(count)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

temporary.
compute gender= 'All'.
compute sex=3. 
aggregate outfile=  !file + 'temp2.sav' 
 /BREAK HBRESCODE lca gender sex agegroup recid Patient_Type type
 /count= sum(count)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

temporary.
compute gender= 'All'.
compute sex=3. 
compute agegroup ='All'. 
aggregate outfile= !file + 'temp3.sav' 
 /BREAK HBRESCODE lca gender sex agegroup recid Patient_Type type
 /count= sum(count)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

add files file = *
 /file = !file + 'temp1.sav' 
 /file = !file + 'temp2.sav' 
 /file =  !file + 'temp3.sav'.
execute.

**to update link**.
*Match on populations.
alter type lca (f2.0).
sort cases by lca sex agegroup.
match files file=* 
 /table = !file + 'agegroups' + !year +'.sav' 
 /by lca sex agegroup.
exe. 

*Match on council area descriptions.
rename variables lca=lcacode.
alter type lcacode (A2).
sort cases by lcacode.
match files file=*
 /table '/conf/irf/05-lookups/04-geography/LCA_lookup.sav'
 /by lcacode.
exe.

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

*Create count totals for Health Board.
aggregate outfile = * mode=addvariables
 /break HBRESCODE agegroup gender type recid Patient_Type
 /hbres_count = sum(count). 

*Create count total for scotland.
aggregate outfile = * mode=addvariables
 /break agegroup gender type recid Patient_Type
 /scot_count = sum(count). 

save outfile=  !file + 'LTCprogram1.sav'
/zcompressed.

*********

*Now create file with LTC categories to add onto the above file. 
get file=  !file + !year +'.sav'.

compute Cardiovascular = 0.
if (atrialfib=1) or (chd=1) or (cvd=1) or (hefailure =1) Cardiovascular =1.

compute Neurodegenerative =0.
if (dementia=1) or (ms=1) or (parkinsons=1) Neurodegenerative =1.

compute Respiratory =0.
if (asthma=1) or (copd=1) Respiratory =1.

compute Other_Organs=0.
if (liver=1) or (refailure=1) Other_Organs=1.

compute Other_LTCs=0.
if (arth=1) or (cancer=1) or (diabetes=1) or (epilepsy=1) Other_LTCs =1.
execute. 

compute No_LTC=0.
if (LTC=0) No_LTC=1.
execute.

*Aggregate out for each category. 

*Cardiovascular.
temporary.
select if Cardiovascular=1.
compute type='Cardiovascular'.
aggregate outfile = !file + 'temp1.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(Cardiovascular)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*Neurodegenerative.
temporary.
select if Neurodegenerative=1.
compute type='Neurodegenerative'.
aggregate outfile =  !file + 'temp2.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(Neurodegenerative)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*Respiratory.
temporary.
select if Respiratory=1.
compute type='Respiratory'.
aggregate outfile = !file + 'temp3.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(Respiratory)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*Other_Organs.
temporary.
select if Other_Organs=1.
compute type='Other_Organs'.
aggregate outfile =  !file + 'temp4.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(Other_Organs)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*Other_LTCs.
temporary.
select if Other_LTCs=1.
compute type='Other_LTCs'.
aggregate outfile =  !file + 'temp5.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(Other_LTCs)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

*No_LTC.
temporary.
select if No_LTC=1.
compute type='No_LTC'.
aggregate outfile = !file + 'temp6.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(No_LTC)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

add files file =  !file + 'temp1.sav' 
 /file=   !file + 'temp2.sav' 
 /file=  !file + 'temp3.sav' 
 /file=  !file + 'temp4.sav' 
 /file=   !file + 'temp5.sav' 
 /file=   !file + 'temp6.sav'. 

*Aggegate file again to obtain age and gender 'All' value. 
temporary.
compute agegroup ='All'. 
aggregate outfile= !file + 'temp1.sav' 
 /BREAK HBRESCODE lca gender sex agegroup recid Patient_Type type
 /count= sum(count)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

temporary.
compute gender= 'All'.
compute sex=3. 
aggregate outfile= !file + 'temp2.sav' 
 /BREAK HBRESCODE lca gender sex agegroup recid Patient_Type type
 /count= sum(count)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

temporary.
compute gender= 'All'.
compute sex=3. 
compute agegroup ='All'. 
aggregate outfile=  !file + 'temp3.sav' 
 /BREAK HBRESCODE lca gender sex agegroup type recid Patient_Type
 /count= sum(count)
 /Cost_Total_Net= sum(Cost_Total_Net)
 /yearstay= sum(yearstay)
 /cvd= sum(cvd)
 /copd= sum(copd)
 /dementia= sum(dementia)
 /diabetes= sum(diabetes)
 /chd= sum(chd)
 /hefailure= sum(hefailure)
 /refailure= sum(refailure)
 /epilepsy= sum(epilepsy)
 /asthma= sum(asthma)
 /atrialfib= sum(atrialfib)
 /cancer= sum(cancer)
 /arth= sum(arth) 
 /parkinsons= sum(parkinsons) 
 /liver= sum(liver)
 /ms= sum(ms).
execute.

add files file = *
 /file =  !file + 'temp1.sav' 
 /file =  !file + 'temp2.sav' 
 /file =  !file + 'temp3.sav'.
exe.

*Match on populations.
alter type lca (f2.0).
sort cases by lca sex agegroup.
match files file=* 
 /table = !file + 'agegroups' + !year +'.sav' 
 /by lca sex agegroup.
execute. 

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
exe.

*FC May 2021. Add Clackmannashire & Stirling.
String Clacks(a30).
IF (LCAname = "Clackmannanshire") or (LCAname = "Stirling") Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE LCAname FROM LCAname Clacks.

*Create count totals for Health Board.
aggregate outfile = * mode=addvariables
 /break HBRESCODE agegroup gender type recid Patient_Type
 /hbres_count = sum(count). 

*Create count total for scotland.
aggregate outfile = * mode=addvariables
 /break agegroup gender type recid Patient_Type
 /scot_count = sum(count). 

save outfile=  !file + 'LTCprogram2.sav'
/zcompressed.

get file=  !file + 'LTCprogram2.sav'. 

*Add 2 files together to creat final extract;

add files file= !file + 'LTCprogram1.sav'
 /file=  !file + 'LTCprogram2.sav'.
execute.

alter type year (A6).
compute year= !year.

select if type ne ''.
select if lcacode ne ''.
select if HBRESCODE ne ''.
alter type agegroup(a7).
if agegroup = 'UnKn' agegroup = 'Unknown'.

save outfile= !file + 'LTCprogram' + !year + '.sav'
/zcompressed.

get file=  !file + 'LTCprogram' + !year + '.sav'. 

*********************
*Housekeeping;.
erase file=  !file + 'LTC' + !year +'.sav'.
erase file=  !file + 'LTCprogram1.sav'.
erase file=  !file + 'LTCprogram2.sav'.
erase file= !file + 'temp1.sav'.
erase file= !file + 'temp2.sav'.
erase file= !file + 'temp3.sav'.
erase file= !file + 'temp4.sav'.
erase file= !file + 'temp5.sav'.
erase file= !file + 'temp6.sav'.
erase file= !file + 'temp7.sav'.
erase file= !file + 'temp8.sav'.
erase file= !file + 'temp9.sav'.
erase file= !file + 'temp10.sav'.
erase file= !file + 'temp11.sav'.
erase file= !file + 'temp12.sav'.
erase file= !file + 'temp13.sav'.
erase file= !file + 'temp14.sav'.
erase file= !file + 'temp15.sav'.
erase file= !file + 'temp16.sav'.

frequencies agegroup.







