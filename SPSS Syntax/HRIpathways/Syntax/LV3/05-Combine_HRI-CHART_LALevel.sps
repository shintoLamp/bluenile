* Encoding: UTF-8.
**Add HRI Files together - LA level.
*Program by EP June 2015.
* Updated Sept 15 to for new HRI Thresholds.


Define !file()
     '/conf/sourcedev/TableauUpdates/HRI/Outputs/'
!Enddefine.

*********************************************************************

*Create data for Overview chart.

Add files file = !file+ '/1920/TDE_201920_Final.zsav'  
 /file = !file+ '/1617/TDE_201617_Final.zsav' 
 /file = !file+ '/1718/TDE_201718_Final.zsav'
 /file = !file+ '/1819/TDE_201819_Final.zsav'. 
execute.

*RH May 2021. Add CLackmannanshire & Stirling.
String Clacks(a30).
IF (LCAname = "Clackmannanshire") or (LCAname = "Stirling") Clacks="Clackmannanshire & Stirling".
VARSTOCASES
 /MAKE LCAname FROM LCAname Clacks.

alter type Population (f8.2).

SAVE OUTFILE= '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Tableau_Final_Data/DB1/HRI_chart_All.sav'.

*Modified HRI chart data source provided by Bateman with correct Clacks & Stirling data.
get file = '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Tableau_Final_Data/DB1/HRI_chart_All_CS.sav'.

alter type Population (f8.2).

save outfile = '/conf/sourcedev/TableauUpdates/HRIpathways/Outputs/LV3/Tableau_Final_Data/DB1/HRI_chart_All_CS.sav'.

