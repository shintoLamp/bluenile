* Encoding: UTF-8.
define !OFilesL()
           '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV1/DB2_Sankey/'
!Enddefine.


get file  = !OFilesL + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR NE "Both".
select if AgeBand NE "All".
exe.


string PathwayLKP (A100).
compute PathwayLKP = concat(rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT2.zsav'
  /zcompressed.

* Agg Age.
get file  = !OFilesL + 'temp_HRI_LAT1.zsav'.

select if AgeBand = "All".
select if  GenderSTR NE "Both".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT3.zsav'
  /zcompressed.

* Agg Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.zsav'.

select if GenderSTR = "Both".
select if AgeBand NE "All".
exe.

string PathwayLKP (A100).
compute PathwayLKP = concat(rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT4.zsav'
  /zcompressed.

* Agg Age & Gender.
get file  = !OFilesL + 'temp_HRI_LAT1.zsav'.

select if  GenderSTR = "Both".
select if AgeBand = "All".
exe.

string PathwayLKP (A100).

compute PathwayLKP = concat(rtrim(HRI_Group1516), rtrim(HRI_Group1617), rtrim(HRI_Group1718), rtrim(HRI_Group1819)).
exe. 

save outfile  = !OFilesL + 'temp_HRI_LAT5.zsav'
  /zcompressed.

*bring files togther.
add files file = !OFilesL + 'temp_HRI_LAT2.zsav'
/file = !OFilesL + 'temp_HRI_LAT3.zsav'
/file = !OFilesL + 'temp_HRI_LAT4.zsav'
/file = !OFilesL + 'temp_HRI_LAT5.zsav'.
execute.

*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.

* Each individuals pathway should be recorded 6 times, if valid. There are issues with mapping CHI over years therefore mismatches which need to be removed.
string PathwayXCheck (A100).
Compute PathwayXCheck = CONCAT(CHI, PathwayLKP).
exe.

sort cases by PathwayXCheck.

compute check = 1.
if (lag(PathwayXCheck)=PathwayXCheck) check=lag(check)+1. 
exe.

AGGREGATE
  /OUTFILE=* MODE=ADDVARIABLES
  /BREAK=PathwayXCheck
  /check_max=MAX(check).

compute Remove = 0.
if check_max < 4 Remove = 1.
exe.

* Modify PathwayLKP to include LA details.
*compute PathwayLKP = concat(STRING ('Scotland',F8),PathwayLKP).
*EXECUTE.
*Remove all spaces from PathwayLKP.
COMPUTE PathwayLKP = REPLACE(PathwayLKP, " ", "").
EXE.
* Create a Pathway Label for use in Tableau.
string PathwayLabel (A100).

compute PathwayLabel = concat(HRI_Group1516, ' - ', HRI_Group1617, ' - ', HRI_Group1718, ' - ', HRI_Group1819).
exe. 

* Need to save out Pathway lookup to match on the original CHIMASTER level data.
save outfile  = !OFilesL + 'temp_HRI_LA_ALLYR_CHI1.zsav'
  /keep chi PathwayLKP PathwayLabel HRI_Group1516 HRI_Group1617 HRI_Group1718 HRI_Group1819 remove
  /zcompressed.