* Encoding: UTF-8.
* Written by Bateman McBride.
* Level 2 data creation written October 2020.
* Added small Tableau extract code January 2021.

* Use Outputs directory.
cd '/conf/sourcedev/TableauUpdates/HRI/Outputs/'.

* Get the main file and aggregate to the map level.
GET FILE=  'HRI_All.sav'.
select if (data = 'Map') and (locality = 'Map').
aggregate outfile = *
/break year LCAname LA_Code HB_Code HBname AgeBand UserType ServiceType HB_Tab_Code LA_TAB_Code gender
/Total_cost = sum(total_cost)
/Episodes_Attendances = sum(Episodes_Attendances)
/Beddays = sum(beddays)
/NumberPatients = sum(numberpatients)
/simddecile = mean(simddecile)
/simdquintile = mean(simdquintile)
/Allpatient_flag = max(Allpatient_flag)
/HRI50_flag = max(HRI50_Flag)
/HRI65_flag = max(HRI65_Flag)
/HRI80_flag = max(HRI80_Flag)
/HRI95_flag = max(HRI95_Flag).
save outfile = 'HRI_All_Level2_Temp.sav' /zcompressed.

* Get back the main file and add the new locality-less map data to the main data.
get file = 'HRI_All.sav'.
select if data ne 'Map'.
add files file = *
    /file =  'HRI_All_Level2_Temp.sav'.
save outfile = 'HRI_All_Level2.sav'.

* No changes to the Chart data except the population has a leading space.
get file = 'HRI_chart_All.sav'.
compute population=ltrim(population).
save outfile = 'HRI_chart_All_Level2.sav'.

* Create small extracts for Tableau.

Define !SmallExtract(filename = !TOKENS (1))
    get file = !filename.
    sort cases by LCAname.
    match files file=*
        /by LCAname
        /first TableauFlag.
    Select if TableauFlag = 1.
!Enddefine.

!SmallExtract filename = 'HRI_All.sav'.
save outfile = 'HRI_All_Tableau.sav' /drop TableauFlag.
!SmallExtract filename = 'HRI_chart_All.sav'.
save outfile = 'HRI_chart_All_Tableau.sav' /drop TableauFlag.

* HRI_Scot_All is very small already and therefore doesn't need a smaller extract.
* HRI_Suppressed_All has suppressed LCA names as the name suggests, so we do this by LA_TAB_Code instead.

get file = 'HRI_suppressed_All.sav'.
sort cases by LA_TAB_Code.
match files file=*
    /by LA_TAB_Code
    /first TableauFlag.
Select if TableauFlag = 1.
save outfile = 'HRI_suppressed_All_Tableau.sav' /drop TableauFlag.
