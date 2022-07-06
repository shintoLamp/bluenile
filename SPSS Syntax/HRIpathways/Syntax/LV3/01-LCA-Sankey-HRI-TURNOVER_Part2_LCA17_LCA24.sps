
* Encoding: UTF-8.
**********************************************************************************************************************************************************************
*******************************Syntax to produce data for Sankey chart for Dashboard 2 of HRI Pathways workbook***********************************.
*******************************BEWARE - Running time of 1+ days - Please ensure large file space before running**********************************.

***FC Oct. 2018. Updated variables which have been renamed/reformatted to reflect changes in Source Linkage Files
    Renamed variables: 'death_date' back to 'date_death', pc7 to postcode
    Reformatted variables: dob (from date to numeric), gpprac (from date back to numeric)
    Changed codes:  lca codes for 'Fife' and 'Perth & Kinross'.

* File save location.
define !OFilesL()
       '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Sankey_DB2/'
!Enddefine.

define !data()
      '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Sankey_DB2/'
!enddefine.



** Now need to create individual LA records to track individuals overtime.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.

*Set LA.
compute x = 17.
exe.

* Identify selected individuals in selected LA.
compute lcaFlag = 0.
if LCA1819 = x lcaFlag = 1.
if LCA1920 = x lcaFlag = 1.
if LCA1617 = x lcaFlag = 1.
if LCA1718 = x lcaFlag = 1.

select if lcaFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if LCA1819 ne x HRI_Group1819 = 'Not in LA'.
if LCA1920 ne x HRI_Group1920 = 'Not in LA'.
if LCA1617 ne x HRI_Group1617 = 'Not in LA'.
if LCA1718 ne x HRI_Group1718 = 'Not in LA'.
exe.


* Add death marker.
if date_death < 20190401 HRI_Group1920 = 'Died'.
if date_death < 20180401 HRI_Group1819 = 'Died'.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death > 20190401 and HRI_Group1920 = ' ' HRI_Group1920 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
if HRI_Group1920 = ' ' HRI_Group1920 = 'No Contact'.
if HRI_Group1819 = ' ' HRI_Group1819 = 'No Contact'.
exe.

* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
if HRI_Group1819 = "Died" and HRI_Group1718 = "Not in LA" HRI_Group1819 = "Not in LA".
if HRI_Group1920 = "Died" and HRI_Group1819 = "Not in LA" HRI_Group1920 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1920 = "Not in LA" health_net_cost1920 = 0.
if HRI_Group1819 = "Not in LA" health_net_cost1819 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1920 = "Died" health_net_cost1920 = 0.
if HRI_Group1819 = "Died" health_net_cost1819 = 0.
exe.


compute lca_Select = x.
exe.

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !data  + 'temp_HRI_LAT1.zsav'
  /zcompressed.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe.

save outfile  = !data  + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data  + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data  + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data  + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !data + 'temp_HRI_LAT2.zsav'
/file = !data + 'temp_HRI_LAT3.zsav'
/file = !data + 'temp_HRI_LAT4.zsav'
/file = !data + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).


sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 


AGGREGATE 
  /OUTFILE=*  MODE=ADDVARIABLES
  /BREAK=PathwayXCheck 
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
compute PathwayLKP = concat(STRING (lca_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).
exe.

compute PathwayLabel = concat(HRI_Group1920, ' - ', HRI_Group1617, ' - ', HRI_Group1718, HRI_Group1819, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !data  + 'temp_HRI_LA_ALLYR_CHI17.zsav'
  /keep chi lca_select PathwayLKP PathwayLabel HRI_Group1819 HRI_Group1718 HRI_Group1920 HRI_Group1617 Remove
  /zcompressed.


* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=lca_Select genderSTR AgeBand HRI_Group1718 HRI_Group1819 HRI_Group1920 HRI_Group1617 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1718=SUM(health_net_cost1718)
  /health_net_cost1819=SUM(health_net_cost1819) 
  /health_net_cost1920=SUM(health_net_cost1920) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1718_min=MIN(health_net_cost1718_min) 
  /health_net_cost1718_max=MAX(health_net_cost1718_max)
  /health_net_cost1819_min=MIN(health_net_cost1819_min) 
  /health_net_cost1819_max=MAX(health_net_cost1819_max)
  /health_net_cost1920_min=MIN(health_net_cost1920_min) 
  /health_net_cost1920_max=MAX(health_net_cost1920_max)
  /Size=N.

save outfile  = !data  + 'temp_HRI_LA_ALLYR17.zsav'
  /zcompressed.


** Now need to create individual LA records to track individuals overtime.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.

*Set LA.
compute x = 18.
exe.

* Identify selected individuals in selected LA.

compute lcaFlag = 0.
if LCA1819 = x lcaFlag = 1.
if LCA1920 = x lcaFlag = 1.
if LCA1617 = x lcaFlag = 1.
if LCA1718 = x lcaFlag = 1.

select if lcaFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if LCA1819 ne x HRI_Group1819 = 'Not in LA'.
if LCA1920 ne x HRI_Group1920 = 'Not in LA'.
if LCA1617 ne x HRI_Group1617 = 'Not in LA'.
if LCA1718 ne x HRI_Group1718 = 'Not in LA'.
exe.


* Add death marker.
if date_death < 20190401 HRI_Group1920 = 'Died'.
if date_death < 20180401 HRI_Group1819 = 'Died'.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death > 20190401 and HRI_Group1920 = ' ' HRI_Group1920 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
if HRI_Group1920 = ' ' HRI_Group1920 = 'No Contact'.
if HRI_Group1819 = ' ' HRI_Group1819 = 'No Contact'.
exe.

* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
if HRI_Group1819 = "Died" and HRI_Group1718 = "Not in LA" HRI_Group1819 = "Not in LA".
if HRI_Group1920 = "Died" and HRI_Group1819 = "Not in LA" HRI_Group1920 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1920 = "Not in LA" health_net_cost1920 = 0.
if HRI_Group1819 = "Not in LA" health_net_cost1819 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1920 = "Died" health_net_cost1920 = 0.
if HRI_Group1819 = "Died" health_net_cost1819 = 0.
exe.



compute lca_Select = x.
exe.

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !data  + 'temp_HRI_LAT1.zsav'
  /zcompressed.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe.

save outfile  = !data  + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data  + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data  + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data  + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !data + 'temp_HRI_LAT2.zsav'
/file = !data + 'temp_HRI_LAT3.zsav'
/file = !data + 'temp_HRI_LAT4.zsav'
/file = !data + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).


sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 


AGGREGATE 
  /OUTFILE=*  MODE=ADDVARIABLES
  /BREAK=PathwayXCheck 
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
compute PathwayLKP = concat(STRING (lca_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).
exe.

compute PathwayLabel = concat(HRI_Group1920, ' - ', HRI_Group1617, ' - ', HRI_Group1718, HRI_Group1819, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !data + 'temp_HRI_LA_ALLYR_CHI18.zsav'
  /keep chi lca_select PathwayLKP PathwayLabel HRI_Group1819 HRI_Group1718 HRI_Group1920 HRI_Group1617 Remove
  /zcompressed.


* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=lca_Select genderSTR AgeBand HRI_Group1718 HRI_Group1819 HRI_Group1920 HRI_Group1617 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1718=SUM(health_net_cost1718)
  /health_net_cost1819=SUM(health_net_cost1819) 
  /health_net_cost1920=SUM(health_net_cost1920) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1718_min=MIN(health_net_cost1718_min) 
  /health_net_cost1718_max=MAX(health_net_cost1718_max)
  /health_net_cost1819_min=MIN(health_net_cost1819_min) 
  /health_net_cost1819_max=MAX(health_net_cost1819_max)
  /health_net_cost1920_min=MIN(health_net_cost1920_min) 
  /health_net_cost1920_max=MAX(health_net_cost1920_max)
  /Size=N.

save outfile  = !data  + 'temp_HRI_LA_ALLYR18.zsav'
  /zcompressed.


** Now need to create individual LA records to track individuals overtime.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.

*Set LA.
compute x = 19.
exe.

* Identify selected individuals in selected LA.

* Identify selected individuals in selected LA.
compute lcaFlag = 0.
if LCA1819 = x lcaFlag = 1.
if LCA1920 = x lcaFlag = 1.
if LCA1617 = x lcaFlag = 1.
if LCA1718 = x lcaFlag = 1.

select if lcaFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if LCA1819 ne x HRI_Group1819 = 'Not in LA'.
if LCA1920 ne x HRI_Group1920 = 'Not in LA'.
if LCA1617 ne x HRI_Group1617 = 'Not in LA'.
if LCA1718 ne x HRI_Group1718 = 'Not in LA'.
exe.


* Add death marker.
if date_death < 20190401 HRI_Group1920 = 'Died'.
if date_death < 20180401 HRI_Group1819 = 'Died'.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death > 20190401 and HRI_Group1920 = ' ' HRI_Group1920 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
if HRI_Group1920 = ' ' HRI_Group1920 = 'No Contact'.
if HRI_Group1819 = ' ' HRI_Group1819 = 'No Contact'.
exe.

* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
if HRI_Group1819 = "Died" and HRI_Group1718 = "Not in LA" HRI_Group1819 = "Not in LA".
if HRI_Group1920 = "Died" and HRI_Group1819 = "Not in LA" HRI_Group1920 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1920 = "Not in LA" health_net_cost1920 = 0.
if HRI_Group1819 = "Not in LA" health_net_cost1819 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1920 = "Died" health_net_cost1920 = 0.
if HRI_Group1819 = "Died" health_net_cost1819 = 0.
exe.


compute lca_Select = x.
exe.

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !data  + 'temp_HRI_LAT1.zsav'
  /zcompressed.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe.

save outfile  = !data + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data  + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data  + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !data + 'temp_HRI_LAT2.zsav'
/file = !data + 'temp_HRI_LAT3.zsav'
/file = !data + 'temp_HRI_LAT4.zsav'
/file = !data + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).


sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 


AGGREGATE 
  /OUTFILE=*  MODE=ADDVARIABLES
  /BREAK=PathwayXCheck 
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
compute PathwayLKP = concat(STRING (lca_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).
exe.

compute PathwayLabel = concat(HRI_Group1920, ' - ', HRI_Group1617, ' - ', HRI_Group1718, HRI_Group1819, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !data + 'temp_HRI_LA_ALLYR_CHI19.zsav'
  /keep chi lca_select PathwayLKP PathwayLabel HRI_Group1819 HRI_Group1718 HRI_Group1920 HRI_Group1617 Remove
  /zcompressed.


* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=lca_Select genderSTR AgeBand HRI_Group1718 HRI_Group1819 HRI_Group1920 HRI_Group1617 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1718=SUM(health_net_cost1718)
  /health_net_cost1819=SUM(health_net_cost1819) 
  /health_net_cost1920=SUM(health_net_cost1920) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1718_min=MIN(health_net_cost1718_min) 
  /health_net_cost1718_max=MAX(health_net_cost1718_max)
  /health_net_cost1819_min=MIN(health_net_cost1819_min) 
  /health_net_cost1819_max=MAX(health_net_cost1819_max)
  /health_net_cost1920_min=MIN(health_net_cost1920_min) 
  /health_net_cost1920_max=MAX(health_net_cost1920_max)
  /Size=N.

save outfile  = !data + 'temp_HRI_LA_ALLYR19.zsav'
  /zcompressed.



** Now need to create individual LA records to track individuals overtime.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.

*Set LA.
compute x = 20.
exe.

* Identify selected individuals in selected LA.
compute lcaFlag = 0.
if LCA1819 = x lcaFlag = 1.
if LCA1920 = x lcaFlag = 1.
if LCA1617 = x lcaFlag = 1.
if LCA1718 = x lcaFlag = 1.

select if lcaFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if LCA1819 ne x HRI_Group1819 = 'Not in LA'.
if LCA1920 ne x HRI_Group1920 = 'Not in LA'.
if LCA1617 ne x HRI_Group1617 = 'Not in LA'.
if LCA1718 ne x HRI_Group1718 = 'Not in LA'.
exe.


* Add death marker.
if date_death < 20190401 HRI_Group1920 = 'Died'.
if date_death < 20180401 HRI_Group1819 = 'Died'.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death > 20190401 and HRI_Group1920 = ' ' HRI_Group1920 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
if HRI_Group1920 = ' ' HRI_Group1920 = 'No Contact'.
if HRI_Group1819 = ' ' HRI_Group1819 = 'No Contact'.
exe.

* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
if HRI_Group1819 = "Died" and HRI_Group1718 = "Not in LA" HRI_Group1819 = "Not in LA".
if HRI_Group1920 = "Died" and HRI_Group1819 = "Not in LA" HRI_Group1920 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1920 = "Not in LA" health_net_cost1920 = 0.
if HRI_Group1819 = "Not in LA" health_net_cost1819 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1920 = "Died" health_net_cost1920 = 0.
if HRI_Group1819 = "Died" health_net_cost1819 = 0.
exe.


compute lca_Select = x.
exe.

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !data  + 'temp_HRI_LAT1.zsav'
  /zcompressed.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe.

save outfile  = !data + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data  + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !data + 'temp_HRI_LAT2.zsav'
/file = !data + 'temp_HRI_LAT3.zsav'
/file = !data + 'temp_HRI_LAT4.zsav'
/file = !data + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).


sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 


AGGREGATE 
  /OUTFILE=*  MODE=ADDVARIABLES
  /BREAK=PathwayXCheck 
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
compute PathwayLKP = concat(STRING (lca_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).
exe.

compute PathwayLabel = concat(HRI_Group1920, ' - ', HRI_Group1617, ' - ', HRI_Group1718, HRI_Group1819, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !data + 'temp_HRI_LA_ALLYR_CHI20.zsav'
  /keep chi lca_select PathwayLKP PathwayLabel HRI_Group1819 HRI_Group1718 HRI_Group1920 HRI_Group1617 Remove
  /zcompressed.


* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=lca_Select genderSTR AgeBand HRI_Group1718 HRI_Group1819 HRI_Group1920 HRI_Group1617 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1718=SUM(health_net_cost1718)
  /health_net_cost1819=SUM(health_net_cost1819) 
  /health_net_cost1920=SUM(health_net_cost1920) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1718_min=MIN(health_net_cost1718_min) 
  /health_net_cost1718_max=MAX(health_net_cost1718_max)
  /health_net_cost1819_min=MIN(health_net_cost1819_min) 
  /health_net_cost1819_max=MAX(health_net_cost1819_max)
  /health_net_cost1920_min=MIN(health_net_cost1920_min) 
  /health_net_cost1920_max=MAX(health_net_cost1920_max)
  /Size=N.

save outfile  = !data + 'temp_HRI_LA_ALLYR20.zsav'
  /zcompressed.



** Now need to create individual LA records to track individuals overtime.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.

*Set LA.
compute x = 21.
exe.

* Identify selected individuals in selected LA.
compute lcaFlag = 0.
if LCA1819 = x lcaFlag = 1.
if LCA1920 = x lcaFlag = 1.
if LCA1617 = x lcaFlag = 1.
if LCA1718 = x lcaFlag = 1.

select if lcaFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if LCA1819 ne x HRI_Group1819 = 'Not in LA'.
if LCA1920 ne x HRI_Group1920 = 'Not in LA'.
if LCA1617 ne x HRI_Group1617 = 'Not in LA'.
if LCA1718 ne x HRI_Group1718 = 'Not in LA'.
exe.


* Add death marker.
if date_death < 20190401 HRI_Group1920 = 'Died'.
if date_death < 20180401 HRI_Group1819 = 'Died'.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death > 20190401 and HRI_Group1920 = ' ' HRI_Group1920 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
if HRI_Group1920 = ' ' HRI_Group1920 = 'No Contact'.
if HRI_Group1819 = ' ' HRI_Group1819 = 'No Contact'.
exe.

* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
if HRI_Group1819 = "Died" and HRI_Group1718 = "Not in LA" HRI_Group1819 = "Not in LA".
if HRI_Group1920 = "Died" and HRI_Group1819 = "Not in LA" HRI_Group1920 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1920 = "Not in LA" health_net_cost1920 = 0.
if HRI_Group1819 = "Not in LA" health_net_cost1819 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1920 = "Died" health_net_cost1920 = 0.
if HRI_Group1819 = "Died" health_net_cost1819 = 0.
exe.


compute lca_Select = x.
exe.

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !data + 'temp_HRI_LAT1.zsav'
  /zcompressed.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe.

save outfile  = !data + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !data + 'temp_HRI_LAT2.zsav'
/file = !data + 'temp_HRI_LAT3.zsav'
/file = !data + 'temp_HRI_LAT4.zsav'
/file = !data + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).


sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 


AGGREGATE 
  /OUTFILE=*  MODE=ADDVARIABLES
  /BREAK=PathwayXCheck 
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
compute PathwayLKP = concat(STRING (lca_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).
exe.

compute PathwayLabel = concat(HRI_Group1920, ' - ', HRI_Group1617, ' - ', HRI_Group1718, HRI_Group1819, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !data + 'temp_HRI_LA_ALLYR_CHI21.zsav'
  /keep chi lca_select PathwayLKP PathwayLabel HRI_Group1819 HRI_Group1718 HRI_Group1920 HRI_Group1617 Remove
  /zcompressed.


* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=lca_Select genderSTR AgeBand HRI_Group1718 HRI_Group1819 HRI_Group1920 HRI_Group1617 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1718=SUM(health_net_cost1718)
  /health_net_cost1819=SUM(health_net_cost1819) 
  /health_net_cost1920=SUM(health_net_cost1920) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1718_min=MIN(health_net_cost1718_min) 
  /health_net_cost1718_max=MAX(health_net_cost1718_max)
  /health_net_cost1819_min=MIN(health_net_cost1819_min) 
  /health_net_cost1819_max=MAX(health_net_cost1819_max)
  /health_net_cost1920_min=MIN(health_net_cost1920_min) 
  /health_net_cost1920_max=MAX(health_net_cost1920_max)
  /Size=N.

save outfile  = !data + 'temp_HRI_LA_ALLYR21.zsav'
  /zcompressed.


** Now need to create individual LA records to track individuals overtime.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.

*Set LA.
compute x = 22.
exe.

* Identify selected individuals in selected LA.
compute lcaFlag = 0.
if LCA1819 = x lcaFlag = 1.
if LCA1920 = x lcaFlag = 1.
if LCA1617 = x lcaFlag = 1.
if LCA1718 = x lcaFlag = 1.

select if lcaFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if LCA1819 ne x HRI_Group1819 = 'Not in LA'.
if LCA1920 ne x HRI_Group1920 = 'Not in LA'.
if LCA1617 ne x HRI_Group1617 = 'Not in LA'.
if LCA1718 ne x HRI_Group1718 = 'Not in LA'.
exe.


* Add death marker.
if date_death < 20190401 HRI_Group1920 = 'Died'.
if date_death < 20180401 HRI_Group1819 = 'Died'.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death > 20190401 and HRI_Group1920 = ' ' HRI_Group1920 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
if HRI_Group1920 = ' ' HRI_Group1920 = 'No Contact'.
if HRI_Group1819 = ' ' HRI_Group1819 = 'No Contact'.
exe.

* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
if HRI_Group1819 = "Died" and HRI_Group1718 = "Not in LA" HRI_Group1819 = "Not in LA".
if HRI_Group1920 = "Died" and HRI_Group1819 = "Not in LA" HRI_Group1920 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1920 = "Not in LA" health_net_cost1920 = 0.
if HRI_Group1819 = "Not in LA" health_net_cost1819 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1920 = "Died" health_net_cost1920 = 0.
if HRI_Group1819 = "Died" health_net_cost1819 = 0.
exe.


compute lca_Select = x.
exe.

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !data + 'temp_HRI_LAT1.zsav'
  /zcompressed.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe.

save outfile  = !data + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !data + 'temp_HRI_LAT2.zsav'
/file = !data + 'temp_HRI_LAT3.zsav'
/file = !data + 'temp_HRI_LAT4.zsav'
/file = !data + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).


sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 


AGGREGATE 
  /OUTFILE=*  MODE=ADDVARIABLES
  /BREAK=PathwayXCheck 
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
compute PathwayLKP = concat(STRING (lca_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).
exe.

compute PathwayLabel = concat(HRI_Group1920, ' - ', HRI_Group1617, ' - ', HRI_Group1718, HRI_Group1819, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !data + 'temp_HRI_LA_ALLYR_CHI22.zsav'
  /keep chi lca_select PathwayLKP PathwayLabel HRI_Group1819 HRI_Group1718 HRI_Group1920 HRI_Group1617 Remove
  /zcompressed.


* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=lca_Select genderSTR AgeBand HRI_Group1718 HRI_Group1819 HRI_Group1920 HRI_Group1617 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1718=SUM(health_net_cost1718)
  /health_net_cost1819=SUM(health_net_cost1819) 
  /health_net_cost1920=SUM(health_net_cost1920) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1718_min=MIN(health_net_cost1718_min) 
  /health_net_cost1718_max=MAX(health_net_cost1718_max)
  /health_net_cost1819_min=MIN(health_net_cost1819_min) 
  /health_net_cost1819_max=MAX(health_net_cost1819_max)
  /health_net_cost1920_min=MIN(health_net_cost1920_min) 
  /health_net_cost1920_max=MAX(health_net_cost1920_max)
  /Size=N.

save outfile  = !data + 'temp_HRI_LA_ALLYR22.zsav'
  /zcompressed.


** Now need to create individual LA records to track individuals overtime.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.

*Set LA.
compute x = 23.
exe.

* Identify selected individuals in selected LA.
compute lcaFlag = 0.
if LCA1819 = x lcaFlag = 1.
if LCA1920 = x lcaFlag = 1.
if LCA1617 = x lcaFlag = 1.
if LCA1718 = x lcaFlag = 1.

select if lcaFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if LCA1819 ne x HRI_Group1819 = 'Not in LA'.
if LCA1920 ne x HRI_Group1920 = 'Not in LA'.
if LCA1617 ne x HRI_Group1617 = 'Not in LA'.
if LCA1718 ne x HRI_Group1718 = 'Not in LA'.
exe.


* Add death marker.
if date_death < 20190401 HRI_Group1920 = 'Died'.
if date_death < 20180401 HRI_Group1819 = 'Died'.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death > 20190401 and HRI_Group1920 = ' ' HRI_Group1920 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
if HRI_Group1920 = ' ' HRI_Group1920 = 'No Contact'.
if HRI_Group1819 = ' ' HRI_Group1819 = 'No Contact'.
exe.

* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
if HRI_Group1819 = "Died" and HRI_Group1718 = "Not in LA" HRI_Group1819 = "Not in LA".
if HRI_Group1920 = "Died" and HRI_Group1819 = "Not in LA" HRI_Group1920 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1920 = "Not in LA" health_net_cost1920 = 0.
if HRI_Group1819 = "Not in LA" health_net_cost1819 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1920 = "Died" health_net_cost1920 = 0.
if HRI_Group1819 = "Died" health_net_cost1819 = 0.
exe.


compute lca_Select = x.
exe.

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !data  + 'temp_HRI_LAT1.zsav'
  /zcompressed.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe.

save outfile  = !data + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !data + 'temp_HRI_LAT2.zsav'
/file = !data + 'temp_HRI_LAT3.zsav'
/file = !data + 'temp_HRI_LAT4.zsav'
/file = !data + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).


sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 


AGGREGATE 
  /OUTFILE=*  MODE=ADDVARIABLES
  /BREAK=PathwayXCheck 
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
compute PathwayLKP = concat(STRING (lca_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).
exe.

compute PathwayLabel = concat(HRI_Group1920, ' - ', HRI_Group1617, ' - ', HRI_Group1718, HRI_Group1819, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !data + 'temp_HRI_LA_ALLYR_CHI23.zsav'
  /keep chi lca_select PathwayLKP PathwayLabel HRI_Group1819 HRI_Group1718 HRI_Group1920 HRI_Group1617 Remove
  /zcompressed.


* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=lca_Select genderSTR AgeBand HRI_Group1718 HRI_Group1819 HRI_Group1920 HRI_Group1617 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1718=SUM(health_net_cost1718)
  /health_net_cost1819=SUM(health_net_cost1819) 
  /health_net_cost1920=SUM(health_net_cost1920) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1718_min=MIN(health_net_cost1718_min) 
  /health_net_cost1718_max=MAX(health_net_cost1718_max)
  /health_net_cost1819_min=MIN(health_net_cost1819_min) 
  /health_net_cost1819_max=MAX(health_net_cost1819_max)
  /health_net_cost1920_min=MIN(health_net_cost1920_min) 
  /health_net_cost1920_max=MAX(health_net_cost1920_max)
  /Size=N.


save outfile  = !data + 'temp_HRI_LA_ALLYR23.zsav'
  /zcompressed.


** Now need to create individual LA records to track individuals overtime.
get file  = !OFilesL + 'temp_HRI_LA_MASTER_ALLYR.zsav'.

*Set LA.
compute x = 24.
exe.

* Identify selected individuals in selected LA.
compute lcaFlag = 0.
if LCA1819 = x lcaFlag = 1.
if LCA1920 = x lcaFlag = 1.
if LCA1617 = x lcaFlag = 1.
if LCA1718 = x lcaFlag = 1.

select if lcaFlag = 1.
exe.
 
* Identify any individuals that wheren't in selected area.
if LCA1819 ne x HRI_Group1819 = 'Not in LA'.
if LCA1920 ne x HRI_Group1920 = 'Not in LA'.
if LCA1617 ne x HRI_Group1617 = 'Not in LA'.
if LCA1718 ne x HRI_Group1718 = 'Not in LA'.
exe.


* Add death marker.
if date_death < 20190401 HRI_Group1920 = 'Died'.
if date_death < 20180401 HRI_Group1819 = 'Died'.
if date_death < 20170401 HRI_Group1718 = 'Died'.
if date_death > 20190401 and HRI_Group1920 = ' ' HRI_Group1920 = 'Died'.
exe.


* Assume any blanks are now showing no contact in year.
if HRI_Group1718 = ' ' HRI_Group1718 = 'No Contact'.
if HRI_Group1617 = ' ' HRI_Group1617 = 'No Contact'.
if HRI_Group1920 = ' ' HRI_Group1920 = 'No Contact'.
if HRI_Group1819 = ' ' HRI_Group1819 = 'No Contact'.
exe.

* Correct some codings where individuals dies after moving LA. If no contact can assume stayed in same LA..
if HRI_Group1718 = "Died" and HRI_Group1617 = "Not in LA" HRI_Group1718 = "Not in LA".
if HRI_Group1819 = "Died" and HRI_Group1718 = "Not in LA" HRI_Group1819 = "Not in LA".
if HRI_Group1920 = "Died" and HRI_Group1819 = "Not in LA" HRI_Group1920 = "Not in LA".
exe.


* Remove Costs data for those not in LA.
if HRI_Group1718 = "Not in LA" health_net_cost1718 = 0.
if HRI_Group1617 = "Not in LA" health_net_cost1617 = 0.
if HRI_Group1920 = "Not in LA" health_net_cost1920 = 0.
if HRI_Group1819 = "Not in LA" health_net_cost1819 = 0.
exe.

* Remove Costs data for those Died before start of FY.
if HRI_Group1718 = "Died" health_net_cost1718 = 0.
if HRI_Group1617 = "Died" health_net_cost1617 = 0.
if HRI_Group1920 = "Died" health_net_cost1920 = 0.
if HRI_Group1819 = "Died" health_net_cost1819 = 0.
exe.


compute lca_Select = x.
exe.

* Convert gender to a string.
String GenderSTR (A6).
if gender = 1 GenderSTR = "Male".
if gender = 2 GenderSTR = "Female".
if gender = 0 GenderSTR = "Both".
exe.

save outfile  = !data + 'temp_HRI_LAT1.zsav'
  /zcompressed.

* Need to create a PathwayID for each level within the data.
* Individual - Lowest level.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe.

save outfile  = !data + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !data + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1920), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !data + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !data + 'temp_HRI_LAT2.zsav'
/file = !data + 'temp_HRI_LAT3.zsav'
/file = !data + 'temp_HRI_LAT4.zsav'
/file = !data + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).


sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 


AGGREGATE 
  /OUTFILE=*  MODE=ADDVARIABLES
  /BREAK=PathwayXCheck 
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
compute PathwayLKP = concat(STRING (lca_Select,F8),PathwayLKP).
exe.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
exe.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).
exe.

compute PathwayLabel = concat(HRI_Group1920, ' - ', HRI_Group1617, ' - ', HRI_Group1718, HRI_Group1819, ' - ').
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !data + 'temp_HRI_LA_ALLYR_CHI24.zsav'
  /keep chi lca_select PathwayLKP PathwayLabel HRI_Group1819 HRI_Group1718 HRI_Group1920 HRI_Group1617 Remove
  /zcompressed.


* Remove mis-match records.
select if Remove NE 1.
exe.

AGGREGATE
  /OUTFILE=*
  /BREAK=lca_Select genderSTR AgeBand HRI_Group1718 HRI_Group1819 HRI_Group1920 HRI_Group1617 PathwayLKP PathwayLabel
  /health_net_cost1617=SUM(health_net_cost1617) 
  /health_net_cost1718=SUM(health_net_cost1718)
  /health_net_cost1819=SUM(health_net_cost1819) 
  /health_net_cost1920=SUM(health_net_cost1920) 
  /health_net_cost1617_min=MIN(health_net_cost1617_min) 
  /health_net_cost1617_max=MAX(health_net_cost1617_max)
  /health_net_cost1718_min=MIN(health_net_cost1718_min) 
  /health_net_cost1718_max=MAX(health_net_cost1718_max)
  /health_net_cost1819_min=MIN(health_net_cost1819_min) 
  /health_net_cost1819_max=MAX(health_net_cost1819_max)
  /health_net_cost1920_min=MIN(health_net_cost1920_min) 
  /health_net_cost1920_max=MAX(health_net_cost1920_max)
  /Size=N.

save outfile  = !data + 'temp_HRI_LA_ALLYR24.zsav'
  /zcompressed.








************************************Aggregate Non-HRIs for Alternative Chart*****************************************.  
*****************Chart just looks at HRIs/Non-HRIs/Died for demo purposes - Not Part of Main Output**********.

