* Encoding: UTF-8.
*Combine 2017/18 and 2018/19 data files
*Modify 2017/18 file, string lengths and remove variables no longer required before adding to 2018/19.

dataset close all.

get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201718/SocialCare.sav'.

*Populate denominator variable so clients_denominator can be deleted as it's no longer required.
if File='Home Care' and Type='Percentage of clients with one or more LTCs' Denominator=Clients_denominator.
execute.

*Insert period variable for additional dropdown in workbooks.
string period (a10).
compute period='2017/18 Q4'.
execute.

get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201718/SocialCare_Modified.sav'.

*Rename diagnosis description variables to exactly match that of 2018/19.
if diagdescript='Gastritis,Gastro Noninfec' diagdescript='Gastritis, Gastro Noninfec'.
if diagdescript='Migraine & Headache' diagdescript='Migraine and Headache'.
if diagdescript='Nausea Vomiting & Acute Abdomen Pain' diagdescript='Nausea Vomiting and Acute Abdomen Pain'.
if diagdescript='Renal & Urological Disorders' diagdescript='Renal and Urological Disorders'.
if diagdescript='UI -Falls' diagdescript='UI - Falls'.
execute.

*Rename SIMD variable to match 2018/19.
rename variables simd2016_HSCP2016_quintile=simd2020v2_HSCP2019_quintile.

*Delete variables no longer required in workbooks and to match the 2018/19 data.
delete variables Clients_denominator.
delete variables Area.
delete variables SupportfromUnpaidCarer.
delete variables SocialWorker.
delete variables Per_dementia.
delete variables EQ_File.
delete variables SDS.
delete variables SPARRA.
delete variables LocalityCareHomePopulation.
delete variables ClientTypeBreakdownCount.
delete variables ClientTypeBreakdown.
delete variables Per_LivingAlone.
delete variables Per_SupportfromUnpaidCarer.
delete variables Per_SocialWorker.
delete variables Dementia.

*Alter string types to match 2018/19 so data adds correctly.
alter type Locality (a70).
alter type sending_location (a35).
alter type Type (a50).
alter type Sex (a15).
alter type Age_Band (a12).
alter type LivingAlone (a20).
alter type File (a30).
alter type hours_band (a25).
alter type Servicetype (a50).
alter type HC (a25).
alter type breakdown_2 (a40).
alter type breakdown_type_2 (a40).
alter type AEReferralSource (a25).
alter type diag (a50).
alter type urbanrural (a6).
alter type diagdescript (a50).
alter type LTCTypeBreakdown (a50).
alter type OutofHoursType (a80).
alter type CareHomeName (a73).
alter type simd2020v2_HSCP2019_quintile (a20).

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201718/SocialCare_Modified.sav'.

get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare_1819.sav'.

if Type='EA_Reason_top5' diagdescript=diag.
execute.

*Modify descriptions to match 2017/18 file and for display on dashboards.
if diagdescript='Gastritis,Gastro Noninfec' diagdescript='Gastritis, Gastro Noninfec'.
if diagdescript='Migraine & Headache' diagdescript='Migraine and Headache'.
if diagdescript='Nausea Vomiting & Acute Abdomen Pain' diagdescript='Nausea Vomiting and Acute Abdomen Pain'.
if diagdescript='Renal & Urological Disorders' diagdescript='Renal and Urological Disorders'.
if diagdescript='UI -Falls' diagdescript='UI - Falls'.
if diagdescript='Unknown' diagdescript='Other/Unknown'.
execute.

*As locality is used in dashboards, this is used to make the variable as complete as possible.
if File='Care Home' and Locality='Unknown' Locality=LocalityCH.
execute.

*Fix for both charts on Demography/Geography 2 of HC workbook, so Clacks locality displays instead of just Outside Partnership.
if File='Home Care' and Type='Living Alone' and Locality='Clackmannanshire HSCP' Locality='Clackmannanshire'.
if File='Home Care' and Type='Weekly hours' and Locality='Clackmannanshire HSCP' Locality='Clackmannanshire'.
execute.

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare_1819.sav'.

*Add 2018/19 file to original 2017/18 data source. 
add files file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201718/SocialCare_Modified.sav'
/file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare_1819.sav'.
execute.

freq var period.

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare.sav'.


*get file = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare_1819.sav'.

