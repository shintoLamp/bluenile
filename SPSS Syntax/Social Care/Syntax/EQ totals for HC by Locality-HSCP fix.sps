* Encoding: UTF-8.
*SYNTAX TO CREATE Total Community Alarms / Telecare for records where Locality = HSCP.
*Deanna Campbell 14/01/21.

*Get source file.
GET  FILE='/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare_1819.sav'. 
DATASET NAME SC1819 WINDOW=FRONT.
*n=883,477.

*Copy and select EQ and type = Home Care.
dataset copy CAT.
dataset activate CAT.
select if File = 'Equipment' and Type = 'Home Care'.
execute.

*Flag Locality values which include HSCP as these are the affected records.
compute LocalityHSCP=0.
if char.index(Locality,"HSCP")>0 LocalityHSCP=1.
execute.

temporary.
select if LocalityHSCP = 1.
freq var Locality.

select if LocalityHSCP = 1.
execute.

freq var Servicetype.

*Aggregate, dropping EQ Service Type, to get total - keep all other file variables for adding back to main source file.
dataset activate CAT.
dataset declare agg.
aggregate outfile = agg
/break 
sending_location
Locality
LocalityHSCP
LocalityCH
period
File
Type
Numerator
Denominator
Rate
Sex
Age_Band
AEReferralSource
NursingCareProvision
simd2020v2_HSCP2019_quintile
UR2_2016
hours_band
LivingAlone
HC
Option
NetCost
GrossCost
total
breakdown_2
Percentage_clients
breakdown_type_2
LTCNo
diag
urbanrural
diagdescript
LA
Adm
top5
Adm_all_top5
LTCTypeBreakdown
LTCTypeCount
OutOfHoursType
OutOfHoursCount
OutofHours_Doctor_NurseAdvice
OutofHours_HomeVisit
OutofHours_PrimaryCareEmergencyCentre_PrimaryCareCentre
LOOKUP
Top5_Adm_Perc
CareHomeName
OutOfHoursCount_CH
LA_CODE
/clients = sum(clients)
/clients_total = sum(clients_total).
execute.

*Create Service Type variable in aggregate.
dataset activate agg.
string Servicetype(a50).
compute Servicetype = 'Total Community alarms and Telecare'.
execute.

*Calculate with/without homecare proportions for Total Community Alarms/Telecare.
compute perc = (clients/clients_total)*100.
execute.

*Add aggregated data back to main file.
add files file = agg
/file = SC1819.
execute.
dataset name matched window = front.
*n=884,443.

sort cases by File Type period sending_location Locality.

*Confirm all file / types.
crosstabs Type by File.

save outfile = '/conf/sourcedev/TableauUpdates/Social Care/Outputs/201819/SocialCare_1819.sav'. 
execute.
