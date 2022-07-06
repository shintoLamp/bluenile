* Encoding: UTF-8.
*Syntax for National Indicators
*This syntax is to be run to produce expenditure for patients aged 18+ broken by HSCP.
*Complete syntax files 1, 1a, 2 and 3 as normal to produce final LFR file and combined mapping file.

*combine NHS and LFR mapped expenditure.
Get file =!pathname3 + 'LFR3_'+!Year+'_Final.sav'.

IF Service="Social Care" Service="02-Social Care".
execute.

*/drop detailed_level_for_match.
*Make variables same length as in All_chps_final (for adding files).
Alter type Sub_Sector(a41).
Alter type HSCP_NAME (a141).
Alter type AGEGROUP (a15).
alter type service (a20).
alter type sector (a37).
alter type Detail_Sector (a36).

aggregate outfile = *
 /break Year hbr HSCP_NAME AGEGROUP service sector Sub_Sector Detail_Sector
 /Expenditure = sum(Expenditure).
execute. 

 * RENAME VARIABLES detailed_level_for_match = Detail_Sector.
 * alter type Detail_Sector (A60).

SAVE OUTFILE =!pathname3 + 'LFR3_'+!Year+'_Final.sav'.

add files file=!pathname3 + 'LFR3_'+!Year+'_Final.sav'
/file =!pathname3 + '/All-chps-Final-'+!year+'.sav'. 
execute.

 * select if Detail_Sector ne 'General Dental Services' and Detail_Sector ne 'General Ophthalmic Services'.
 * execute.

select if char.substr(HSCP_NAME,1,3)<>"NHS".
select if HSCP_NAME ne 'N/A' and HSCP_NAME ne 'Non HSCP' and HSCP_NAME ne ''.
select if agegroup ne '<18' and agegroup ne 'All' and agegroup ne 'Missing'.
execute.

aggregate outfile=*
/break Year HSCP_NAME
/Expenditure=sum(expenditure).
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/HSCP_Totals_Nov20.sav'.

add files file=!pathname3 + 'LFR3_'+!Year+'_Final.sav'
/file =!pathname3 + '/All-chps-Final-'+!year+'.sav'. 
execute.

 * select if Detail_Sector ne 'General Dental Services' and Detail_Sector ne 'General Ophthalmic Services'.
 * execute.

select if char.substr(HSCP_NAME,1,3)<>"NHS".
select if HSCP_NAME ne 'N/A' and HSCP_NAME ne 'Non HSCP' and HSCP_NAME ne ''.
select if agegroup ne '<18' and agegroup ne 'All' and agegroup ne 'Missing'.
execute.

aggregate outfile=*
/break Year
/Expenditure=sum(expenditure).
execute.

string HSCP_NAME (a141).
compute HSCP_NAME='Scotland'.
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/Scotland_Total_Nov20.sav'.

add files file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/HSCP_Totals_Nov20.sav'
/file = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/Scotland_Total_Nov20.sav'.
execute.

save outfile = '/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/Indicator20Totals_Nov20.sav'.

SAVE TRANSLATE OUTFILE='/conf/irf/09-Tableau-Outputs/01-Development/02-SPSS-Outputs/01-HSC-Expenditure/Final_data/'+!Year+'/Indicator20Totals_Nov20.xlsx'
  /TYPE=XLS
  /VERSION=12
  /MAP
  /REPLACE
  /FIELDNAMES
  /CELLS=VALUES.
