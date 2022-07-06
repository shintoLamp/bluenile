* Encoding: UTF-8.
Insert file = "/conf/sourcedev/TableauUpdates/Matrix/Source/Syntax/00-folder_macros.sps" Error = Stop.

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

save outfile = !sourcdev_matrix_final + !version + "_TDE_temp_split.zsav"
    /zcompressed.

select if any(Partnership, "Clackmannanshire", "Stirling").

Compute Partnership = "Clackmannanshire and Stirling".
Compute LA_Code = "S12000005".

aggregate outfile = *
    /Break Year Partnership LA_Code Locality Service_Use_Cohort Demographic_Cohort SIMD_Quintile
    ResourceGroup AgeBand Urban_Rural LTC_Total gender HHG_Risk_Group Data Service_Area LTC_Name Demograph_Name
    /NoPatients Total_Cost Total_Beddays Total_Attendances Total_Admissions Unplanned_Beddays AE2_Attendances Outpatient_Attendances
    Comm_Living Adult_Major Child_Major Low_CC Medium_CC High_CC Substance MH Maternity Frailty End_of_Life
    ZeroLTC OneLTC TwoLTC ThreeLTC FourLTC FiveLTC
    arth asthma atrialfib cancer copd cvd dementia diabetes epilepsy chd hefailure liver ms parkinsons refailure
    Delayed_Episodes Delayed_Beddays Delayed_Patients Preventable_Admissions Preventable_Beddays = Sum(
    NoPatients Total_Cost Total_Beddays Total_Attendances Total_Admissions Unplanned_Beddays AE2_Attendances Outpatient_Attendances
    Comm_Living Adult_Major Child_Major Low_CC Medium_CC High_CC Substance MH Maternity Frailty End_of_Life
    ZeroLTC OneLTC TwoLTC ThreeLTC FourLTC FiveLTC
    arth asthma atrialfib cancer copd cvd dementia diabetes epilepsy chd hefailure liver ms parkinsons refailure
    Delayed_Episodes Delayed_Beddays Delayed_Patients Preventable_Admissions Preventable_Beddays).

add files 
    /file = *
    /file =  !sourcdev_matrix_final + !version + "_TDE_temp_split.zsav".

* Trim strings to save space (Tableau doesn't care).
Alter Type
    Partnership
    Locality
    Service_Use_Cohort
    Demographic_Cohort
    SIMD_Quintile
    ResourceGroup
    AgeBand
    Urban_Rural
    LTC_Total
    gender
    HHG_Risk_Group (Amin).

* Remove Value Labels.
Value Labels SIMD_Quintile.
Value Labels Urban_Rural.
Value Labels gender.

* Remove variable Labels.
Variable Labels Locality.
Variable Labels Service_Use_Cohort.
Variable Labels Demographic_Cohort.
Variable Labels SIMD_Quintile.
Variable Labels Urban_Rural.
Variable Labels gender.

* Tableau cannot read any compressed files from SPSS.
xsave outfile = !sourcdev_matrix_final + !version + "_TDE.sav".

* Check data looks correct for all breakdowns.
crosstabs Partnership Locality Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total gender HHG_Risk_Group
    by Year
    by Data.

* Check all partnerships have a security filter.
Crosstabs Partnership by LA_code.

* Get saved file.
get file = !sourcdev_matrix_final + !version + "_TDE.sav".