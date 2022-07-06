* Encoding: UTF-8.
Insert file = "/conf/sourcedev/TableauUpdates/Matrix/PCI/Syntax/00-folder_macros.sps" Error = Stop.

add files
    /file = !sourcdev_matrix_final + !version + "_TDE_201718.zsav"
    /file = !sourcdev_matrix_final + !version + "_TDE_201819.zsav"
    /file = !sourcdev_matrix_final + !version + "_TDE_201920.zsav"
    /file = !sourcdev_matrix_final + !version + "_TDE_202021.zsav".

* Add LA_Code variable which is used to apply security filters.
String LA_Code (A9).
Recode Partnership
    ('Aberdeen City' = 'S12000033')
    ('Aberdeenshire' = 'S12000034')
    ('Angus' = 'S12000041')
    ('Argyll and Bute' = 'S12000035')
    ('Clackmannanshire' = 'S12000005')
    ('Dumfries and Galloway' = 'S12000006')
    ('Dundee City' = 'S12000042')
    ('East Ayrshire' = 'S12000008')
    ('East Dunbartonshire' = 'S12000045')
    ('East Lothian' = 'S12000010')
    ('East Renfrewshire' = 'S12000011')
    ('City of Edinburgh' = 'S12000036')
    ('Falkirk' = 'S12000014')
    ('Fife' = 'S12000015')
    ('Glasgow City' = 'S12000046')
    ('Highland' = 'S12000017')
    ('Inverclyde' = 'S12000018')
    ('Midlothian' = 'S12000019')
    ('Moray' = 'S12000020')
    ('North Ayrshire' = 'S12000021')
    ('North Lanarkshire' = 'S12000044')
    ('Orkney Islands' = 'S12000023')
    ('Perth and Kinross' = 'S12000024')
    ('Renfrewshire' = 'S12000038')
    ('Scottish Borders' = 'S12000026')
    ('Shetland Islands' = 'S12000027')
    ('South Ayrshire' = 'S12000028')
    ('South Lanarkshire' = 'S12000029')
    ('Stirling' = 'S12000030')
    ('West Dunbartonshire' = 'S12000039')
    ('West Lothian' = 'S12000040')
    ('Na h-Eileanan Siar' = 'S12000013')
    Into LA_Code.

* Trim strings to save space (Tableau doesn't care).
Alter Type
    Partnership
    ClusterName
    gpprac
    Service_Use_Cohort
    Demographic_Cohort
    SIMD_Quintile
    ResourceGroup
    AgeBand
    Urban_Rural
    LTC_Total
    gender (Amin).

* Remove Value Labels.
Value Labels SIMD_Quintile.
Value Labels Urban_Rural.
Value Labels gender.

* Remove variable Labels.
Variable Labels gpprac.
Variable Labels Service_Use_Cohort.
Variable Labels Demographic_Cohort.
Variable Labels SIMD_Quintile.
Variable Labels Urban_Rural.
Variable Labels gender.

* Tableau can't handle zcompressed files.
xsave outfile = !sourcdev_matrix_final + !version + "_TDE.sav".

* Check data looks correct for all breakdowns.
crosstabs Partnership ClusterName Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total gender
    by Year
    by Data.

* Check all partnerships have a security filter.
Crosstabs Partnership by LA_code.

* Get saved file.
get file = !sourcdev_matrix_final + !version + "_TDE.sav".