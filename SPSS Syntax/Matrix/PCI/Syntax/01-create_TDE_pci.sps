* Encoding: UTF-8.
Insert file = "/conf/sourcedev/TableauUpdates/Matrix/PCI/Syntax/00-folder_macros.sps" Error = Stop.

* Financial Year.
Define !FY()
    @FY
!Enddefine.
echo "Running year: " + !FY.

* Get individual file for cohort and since it has most variables.
get file = !hscdiip_slf + "source-individual-file-20" + !FY + ".zsav"
    /Drop Year DoB Postcode Cluster health_net_costincDNAs health_net_costincIncomplete HL1_in_FY
    deceased death_date  congen bloodbfo endomet digestive
    arth_date asthma_date atrialfib_date cancer_date cvd_date liver_date copd_date dementia_date diabetes_date epilepsy_date chd_date
    hefailure_date ms_date parkinsons_date refailure_date congen_date bloodbfo_date endomet_date digestive_date
    hbrescode HSCP2018 CA2018 DataZone2011 hbpraccode
    SIMD2020v2_rank SIMD2020v2_sc_decile SIMD2020v2_sc_quintile SIMD2020v2_HB2019_decile SIMD2020v2_HB2019_quintile SIMD2020v2_HSCP2019_decile
    UR6_2016 UR3_2016 UR2_2016 HB2019 HSCP2019 CA2019
    HRI_lca HRI_lca_incDN HRI_hb HRI_scot HRI_lcaP_incDN HRI_hbP HRI_scotP SPARRA_Start_FY SPARRA_End_FY HHG_Start_FY.

* Remove non-Scottish and non-registered.
select if lca NE "".
select if Not(sysmis(gpprac)).

* Rename and compute some variables.
Rename Variables
    Health_Net_Cost = Total_cost
    ae_cost = AE2_Cost
    ae_attendances = AE2_Attendances
    pis_cost = Prescribing_Cost
    op_newcons_attendances = Outpatient_Attendances
    op_cost_attend = Outpatient_Cost
    mat_inpatient_beddays = Maternity_Beddays.

compute Total_Beddays = Acute_Inpatient_Beddays + Maternity_Beddays + MH_Inpatient_Beddays + GLS_Inpatient_Beddays.
compute Unplanned_Beddays = Acute_non_el_Inpatient_Beddays + MH_non_el_Inpatient_Beddays + GLS_non_el_Inpatient_Beddays.
compute Hospital_Elective_Cost = acute_daycase_cost + acute_el_inpatient_cost + MH_el_inpatient_cost + gls_el_inpatient_cost .
compute Hospital_Emergency_Cost = acute_non_el_inpatient_cost + MH_non_el_inpatient_cost + gls_non_el_inpatient_cost.
compute Maternity_Cost = mat_inpatient_cost + mat_daycase_cost.
compute Hospital_Elective_Beddays = acute_el_inpatient_beddays + MH_el_inpatient_beddays + gls_el_inpatient_beddays.
compute Hospital_Emergency_Beddays = acute_non_el_inpatient_beddays + MH_non_el_inpatient_beddays + gls_non_el_inpatient_beddays.

* Categorise patients.
if (acute_daycase_episodes GT 0
    OR acute_el_inpatient_episodes GT 0
    OR MH_el_inpatient_episodes GT 0
    OR gls_el_inpatient_episodes GT 0)
    Hospital_Elective_Patients = 1.
if (acute_non_el_inpatient_episodes GT 0
    OR MH_non_el_inpatient_episodes GT 0
    OR gls_non_el_inpatient_episodes GT 0)
    Hospital_Emergency_Patients = 1.
if (mat_episodes GT 0) Maternity_Patients = 1.
if (AE2_Attendances GT 0) AE2_Patients = 1.
if (Outpatient_Attendances GT 0) Outpatients = 1.
if (pis_dispensed_items GT 0) Prescribing_Patients = 1.

* Count how many LTCs a person has, note we are excluding congen, bloodbfo, endomet, digestive.
Numeric LTC_Total (F2.0).
compute LTC_Total = Sum(arth to refailure).

* Cap the count at 5.
Recode LTC_Total (5 Thru Hi = 5).

* Flag if people have 0, 1, 2 etc. LTCs.
Numeric ZeroLTC OneLTC TwoLTC ThreeLTC FourLTC FiveLTC (F1.0).

Do Repeat Num_LTCs = 0 to 5
    /LTC_Flag = ZeroLTC to FiveLTC.
    Do if LTC_Total = Num_LTCs.
        Compute  LTC_Flag = 1.
    Else.
        Compute LTC_Flag = 0.
    End if.
End Repeat.

*  Allocate people to a resource group based on their HRI score (within the LCA) - we exclude the DN costs.
string ResourceGroup (A50).
Do if HRI_lcaP LE 50.
    Compute ResourceGroup = "High (Top 50%)".
Else if (HRI_lcaP GT 50 AND HRI_lcaP LE 65).
    Compute ResourceGroup = "Moderately High (50-65%)".
Else if (HRI_lcaP GT 65 AND HRI_lcaP LE 80).
    Compute ResourceGroup = "Moderate (65-80%)".
Else if (HRI_lcaP GT 80 AND HRI_lcaP LE 95).
    Compute ResourceGroup = "Moderately Low (80-95%)".
Else if HRI_lcaP GT 95.
    Compute ResourceGroup = "Low (95-100%)".
End if.

* Divide into age-groups.
string AgeBand (A20).
Do if age LE 17.
    Compute AgeBand = "0 to 17".
Else if (age GE 18 AND age LE 64).
    Compute AgeBand = "18 to 64".
Else if (age GE 65 AND age LE 74).
    Compute AgeBand = "65 to 74".
Else if (age GE 75 AND age LE 84).
    Compute AgeBand = "75 to 84".
Else if age GE 85.
    Compute AgeBand = "85+".
End if.

rename variables
    UR8_2016 = Urban_Rural
    SIMD2020v2_HSCP2019_quintile = SIMD_Quintile.

rename variables
    CIJ_non_el = Hospital_Emergency_Attendance
    CIJ_el = Hospital_Elective_Attendance
    CIJ_mat = Maternity_Attendance.

compute Total_Admissions = Hospital_Elective_Attendance + Hospital_Emergency_Attendance + Maternity_Attendance.

* Match on cohort flags.
match files file = *
    /table = !hscdiip_slf + "Anon-to-CHI-lookup.zsav"
    /by  Anon_CHI.

sort cases by chi.
Alter type Demographic_Cohort (A32).

match files file = *
    /table = !hscdiip_cohorts + "Demographic_Cohorts_" + !FY + ".zsav"
    /by CHI Demographic_Cohort.

if NSU = 1 AND Demographic_Cohort = "Healthy and Low User" Demographic_Cohort = "Non-Service User".

* Match on GP Practice details.
alter type gpprac (F11.0).
sort cases by gpprac.
match files file = *
    /table = !hscdiip_slf_lookups + "practice_details_" + !slf_latest_update + ".zsav"
    /Rename (Cluster = ClusterName)
    /by gpprac.

Alter Type gpprac (A5).
Alter Type gpprac (A152).

Do if gpprac = "99942".
    Compute gpprac = "Private practices (99942)".
Else if gpprac = "99957".
    Compute gpprac = "Unregistered (99957)".
Else if gpprac = "99961" or gpprac = "99999".
    Compute gpprac = "Unknown (99961 or 99999)".
Else if gpprac = "99976".
    Compute gpprac = "British Armed Forces not registered in UK (99976)".
Else if gpprac = "99981".
    Compute gpprac = "Foreign Visitors not registered in Scotland (99981)".
Else if gpprac = "99995".
    Compute gpprac = "Patients registered in RUK (99995)".
Else.
    Compute gpprac = concat(practice_name, " (", gpprac, ")").
End if.

if Partnership = "" Partnership = "Unknown".

Do if gender = 1.
    Compute Male = 1.
Else if gender = 2.
    Compute Female = 1.
End if.

Do if arth = 1.
    Compute arth_cost = Total_cost.
    Compute arth_admission = Total_admissions.
    Compute arth_beddays = Total_beddays.
    Compute arth_unplanned_beddays = Unplanned_beddays.
    Compute arth_ae2_attendance = AE2_Attendances.
    Compute arth_outpatient_attendance = Outpatient_Attendances.
End if.

Do if asthma = 1.
    Compute asthma_cost = Total_cost.
    Compute asthma_admission = Total_admissions.
    Compute asthma_beddays = Total_beddays.
    Compute asthma_unplanned_beddays = Unplanned_beddays.
    Compute asthma_ae2_attendance = AE2_Attendances.
    Compute asthma_outpatient_attendance = Outpatient_Attendances.
End if.

Do if atrialfib = 1.
    Compute atrialfib_cost = Total_cost.
    Compute atrialfib_admission = Total_admissions.
    Compute atrialfib_beddays = Total_beddays.
    Compute atrialfib_unplanned_beddays = Unplanned_beddays.
    Compute atrialfib_ae2_attendance = AE2_Attendances.
    Compute atrialfib_outpatient_attendance = Outpatient_Attendances.
End if.

Do if cancer = 1.
    Compute cancer_cost = Total_cost.
    Compute cancer_admission = Total_admissions.
    Compute cancer_beddays = Total_beddays.
    Compute cancer_unplanned_beddays = Unplanned_beddays.
    Compute cancer_ae2_attendance = AE2_Attendances.
    Compute cancer_outpatient_attendance = Outpatient_Attendances.
End if.

Do if cvd = 1.
    Compute cvd_cost = Total_cost.
    Compute cvd_admission = Total_admissions.
    Compute cvd_beddays = Total_beddays.
    Compute cvd_unplanned_beddays = Unplanned_beddays.
    Compute cvd_ae2_attendance = AE2_Attendances.
    Compute cvd_outpatient_attendance = Outpatient_Attendances.
End if.

Do if liver = 1.
    Compute liver_cost = Total_cost.
    Compute liver_admission = Total_admissions.
    Compute liver_beddays = Total_beddays.
    Compute liver_unplanned_beddays = Unplanned_beddays.
    Compute liver_ae2_attendance = AE2_Attendances.
    Compute liver_outpatient_attendance = Outpatient_Attendances.
End if.

Do if copd = 1.
    Compute copd_cost = Total_cost.
    Compute copd_admission = Total_admissions.
    Compute copd_beddays = Total_beddays.
    Compute copd_unplanned_beddays = Unplanned_beddays.
    Compute copd_ae2_attendance = AE2_Attendances.
    Compute copd_outpatient_attendance = Outpatient_Attendances.
End if.

Do if dementia = 1.
    Compute dementia_cost = Total_cost.
    Compute dementia_admission = Total_admissions.
    Compute dementia_beddays = Total_beddays.
    Compute dementia_unplanned_beddays = Unplanned_beddays.
    Compute dementia_ae2_attendance = AE2_Attendances.
    Compute dementia_outpatient_attendance = Outpatient_Attendances.
End if.

Do if diabetes = 1.
    Compute diabetes_cost = Total_cost.
    Compute diabetes_admission = Total_admissions.
    Compute diabetes_beddays = Total_beddays.
    Compute diabetes_unplanned_beddays = Unplanned_beddays.
    Compute diabetes_ae2_attendance = AE2_Attendances.
    Compute diabetes_outpatient_attendance = Outpatient_Attendances.
End if.

Do if epilepsy = 1.
    Compute epilepsy_cost = Total_cost.
    Compute epilepsy_admission = Total_admissions.
    Compute epilepsy_beddays = Total_beddays.
    Compute epilepsy_unplanned_beddays = Unplanned_beddays.
    Compute epilepsy_ae2_attendance = AE2_Attendances.
    Compute epilepsy_outpatient_attendance = Outpatient_Attendances.
End if.

Do if chd = 1.
    Compute chd_cost = Total_cost.
    Compute chd_admission = Total_admissions.
    Compute chd_beddays = Total_beddays.
    Compute chd_unplanned_beddays = Unplanned_beddays.
    Compute chd_ae2_attendance = AE2_Attendances.
    Compute chd_outpatient_attendance = Outpatient_Attendances.
End if.

Do if hefailure = 1.
    Compute hefailure_cost = Total_cost.
    Compute hefailure_admission = Total_admissions.
    Compute hefailure_beddays = Total_beddays.
    Compute hefailure_unplanned_beddays = Unplanned_beddays.
    Compute hefailure_ae2_attendance = AE2_Attendances.
    Compute hefailure_outpatient_attendance = Outpatient_Attendances.
End if.

Do if ms = 1.
    Compute ms_cost = Total_cost.
    Compute ms_admission = Total_admissions.
    Compute ms_beddays = Total_beddays.
    Compute ms_unplanned_beddays = Unplanned_beddays.
    Compute ms_ae2_attendance = AE2_Attendances.
    Compute ms_outpatient_attendance = Outpatient_Attendances.
End if.

Do if parkinsons = 1.
    Compute parkinsons_cost = Total_cost.
    Compute parkinsons_admission = Total_admissions.
    Compute parkinsons_beddays = Total_beddays.
    Compute parkinsons_unplanned_beddays = Unplanned_beddays.
    Compute parkinsons_ae2_attendance = AE2_Attendances.
    Compute parkinsons_outpatient_attendance = Outpatient_Attendances.
End if.

Do if refailure = 1.
    Compute refailure_cost = Total_cost.
    Compute refailure_admission = Total_admissions.
    Compute refailure_beddays = Total_beddays.
    Compute refailure_unplanned_beddays = Unplanned_beddays.
    Compute refailure_ae2_attendance = AE2_Attendances.
    Compute refailure_outpatient_attendance = Outpatient_Attendances.
End if.

Recode arth_cost to refailure_outpatient_attendance (sysmis = 0).

Do if Comm_Living = 1.
    Compute Comm_Living_cost = Total_cost.
    Compute Comm_Living_admission = Total_admissions.
    Compute Comm_Living_beddays = Total_beddays.
    Compute Comm_Living_unplanned_beddays = Unplanned_beddays.
    Compute Comm_Living_ae2_attendance = AE2_Attendances.
    Compute Comm_Living_outpatient_attendance = Outpatient_Attendances.
End if.

Do if Adult_Major = 1.
    Compute Adult_Major_cost = Total_cost.
    Compute Adult_Major_admission = Total_admissions.
    Compute Adult_Major_beddays = Total_beddays.
    Compute Adult_Major_unplanned_beddays = Unplanned_beddays.
    Compute Adult_Major_ae2_attendance = AE2_Attendances.
    Compute Adult_Major_outpatient_attendance = Outpatient_Attendances.
End if.

Do if Child_Major = 1.
    Compute Child_Major_cost = Total_cost.
    Compute Child_Major_admission = Total_admissions.
    Compute Child_Major_beddays = Total_beddays.
    Compute Child_Major_unplanned_beddays = Unplanned_beddays.
    Compute Child_Major_ae2_attendance = AE2_Attendances.
    Compute Child_Major_outpatient_attendance = Outpatient_Attendances.
End if.

Do if Low_CC = 1.
    Compute Low_CC_cost = Total_cost.
    Compute Low_CC_admission = Total_admissions.
    Compute Low_CC_beddays = Total_beddays.
    Compute Low_CC_unplanned_beddays = Unplanned_beddays.
    Compute Low_CC_ae2_attendance = AE2_Attendances.
    Compute Low_CC_outpatient_attendance = Outpatient_Attendances.
End if.

Do if Medium_CC = 1.
    Compute Medium_CC_cost = Total_cost.
    Compute Medium_CC_admission = Total_admissions.
    Compute Medium_CC_beddays = Total_beddays.
    Compute Medium_CC_unplanned_beddays = Unplanned_beddays.
    Compute Medium_CC_ae2_attendance = AE2_Attendances.
    Compute Medium_CC_outpatient_attendance = Outpatient_Attendances.
End if.

Do if High_CC = 1.
    Compute High_CC_cost = Total_cost.
    Compute High_CC_admission = Total_admissions.
    Compute High_CC_beddays = Total_beddays.
    Compute High_CC_unplanned_beddays = Unplanned_beddays.
    Compute High_CC_ae2_attendance = AE2_Attendances.
    Compute High_CC_outpatient_attendance = Outpatient_Attendances.
End if.

Do if Substance = 1.
    Compute Substance_cost = Total_cost.
    Compute Substance_admission = Total_admissions.
    Compute Substance_beddays = Total_beddays.
    Compute Substance_unplanned_beddays = Unplanned_beddays.
    Compute Substance_ae2_attendance = AE2_Attendances.
    Compute Substance_outpatient_attendance = Outpatient_Attendances.
End if.

Do if MH = 1.
    Compute MH_cost = Total_cost.
    Compute MH_admission = Total_admissions.
    Compute MH_beddays = Total_beddays.
    Compute MH_unplanned_beddays = Unplanned_beddays.
    Compute MH_ae2_attendance = AE2_Attendances.
    Compute MH_outpatient_attendance = Outpatient_Attendances.
End if.

Do if Maternity = 1.
    Compute Maternity_cohort_cost = Total_cost.
    Compute Maternity_cohort_admission = Total_admissions.
    Compute Maternity_cohort_beddays = Total_beddays.
    Compute Maternity_cohort_unplanned_beddays = Unplanned_beddays.
    Compute Maternity_cohort_ae2_attendance = AE2_Attendances.
    Compute Maternity_cohort_outpatient_attendance = Outpatient_Attendances.
End if.

Do if Frailty = 1.
    Compute Frailty_cost = Total_cost.
    Compute Frailty_admission = Total_admissions.
    Compute Frailty_beddays = Total_beddays.
    Compute Frailty_unplanned_beddays = Unplanned_beddays.
    Compute Frailty_ae2_attendance = AE2_Attendances.
    Compute Frailty_outpatient_attendance = Outpatient_Attendances.
End if.

Do if End_of_Life = 1.
    Compute End_of_Life_cost = Total_cost.
    Compute End_of_Life_admission = Total_admissions.
    Compute End_of_Life_beddays = Total_beddays.
    Compute End_of_Life_unplanned_beddays = Unplanned_beddays.
    Compute End_of_Life_ae2_attendance = AE2_Attendances.
    Compute End_of_Life_outpatient_attendance = Outpatient_Attendances.
End if.
Recode Comm_Living_cost to End_of_Life_outpatient_attendance (sysmis = 0).

aggregate outfile = *
    /BREAK Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    /NoPatients = n
    /Total_Cost = sum(Total_Cost)
    /Total_Beddays = sum(Total_Beddays)
    /Unplanned_Beddays = sum(Unplanned_Beddays)
    /Total_Admissions = sum(Total_Admissions)
    /AE2_Attendances = sum(AE2_Attendances)
    /Outpatient_Attendances = sum(Outpatient_Attendances)
    /Male=sum(Male)
    /Female=sum(Female)
    /Comm_Living = sum(Comm_Living)
    /Adult_Major = sum(Adult_Major)
    /Child_Major = sum(Child_Major)
    /Low_CC = sum(Low_CC)
    /Medium_CC = sum(Medium_CC)
    /High_CC = sum(High_CC)
    /Substance = sum(Substance)
    /MH = sum(MH)
    /Maternity = sum(Maternity)
    /Frailty = sum(Frailty)
    /End_of_Life = sum(End_of_Life)
    /Hospital_Elective_Cost = sum(Hospital_Elective_Cost)
    /Hospital_Emergency_Cost = sum(Hospital_Emergency_Cost)
    /Maternity_Cost = sum(Maternity_Cost)
    /AE2_Cost = sum(AE2_Cost)
    /Prescribing_Cost = sum(Prescribing_Cost)
    /Outpatient_Cost = sum(Outpatient_Cost)
    /Hospital_Elective_Attendance = sum(Hospital_Elective_Attendance)
    /Hospital_Emergency_Attendance = sum(Hospital_Emergency_Attendance)
    /Maternity_Attendance = sum(Maternity_Attendance)
    /Hospital_Elective_Beddays = sum(Hospital_Elective_Beddays)
    /Hospital_Emergency_Beddays = sum(Hospital_Emergency_Beddays)
    /Maternity_Beddays = sum(Maternity_Beddays)
    /AE2_Patients = sum(AE2_Patients)
    /Hospital_Elective_Patients = sum(Hospital_Elective_Patients)
    /Hospital_Emergency_Patients = sum(Hospital_Emergency_Patients)
    /Maternity_Patients = sum(Maternity_Patients)
    /Outpatients = sum(Outpatients)
    /Prescribing_Patients = sum(Prescribing_Patients)
    /ZeroLTC = sum(ZeroLTC)
    /OneLTC = sum(OneLTC)
    /TwoLTC = sum(TwoLTC)
    /ThreeLTC = sum(ThreeLTC)
    /FourLTC = sum(FourLTC)
    /FiveLTC = sum(FiveLTC)
    /arth = sum(arth)
    /asthma = sum(asthma)
    /atrialfib = sum(atrialfib)
    /cancer = sum(cancer)
    /copd = sum(copd)
    /cvd = sum(cvd)
    /dementia = sum(dementia)
    /diabetes = sum(diabetes)
    /epilepsy = sum(epilepsy)
    /chd = sum(chd)
    /hefailure = sum(hefailure)
    /liver = sum(liver)
    /ms = sum(ms)
    /parkinsons = sum(parkinsons)
    /refailure = sum(refailure)
    /arth_cost = sum(arth_cost)
    /asthma_cost = sum(asthma_cost)
    /atrialfib_cost = sum(atrialfib_cost)
    /cancer_cost = sum(cancer_cost)
    /cvd_cost = sum(cvd_cost)
    /liver_cost = sum(liver_cost)
    /copd_cost = sum(copd_cost)
    /dementia_cost = sum(dementia_cost)
    /diabetes_cost = sum(diabetes_cost)
    /epilepsy_cost = sum(epilepsy_cost)
    /chd_cost = sum(chd_cost)
    /hefailure_cost = sum(hefailure_cost)
    /ms_cost = sum(ms_cost)
    /parkinsons_cost = sum(parkinsons_cost)
    /refailure_cost = sum(refailure_cost)
    /arth_admission = sum(arth_admission)
    /asthma_admission = sum(asthma_admission)
    /atrialfib_admission = sum(atrialfib_admission)
    /cancer_admission = sum(cancer_admission)
    /cvd_admission = sum(cvd_admission)
    /liver_admission = sum(liver_admission)
    /copd_admission = sum(copd_admission)
    /dementia_admission = sum(dementia_admission)
    /diabetes_admission = sum(diabetes_admission)
    /epilepsy_admission = sum(epilepsy_admission)
    /chd_admission = sum(chd_admission)
    /hefailure_admission = sum(hefailure_admission)
    /ms_admission = sum(ms_admission)
    /parkinsons_admission = sum(parkinsons_admission)
    /refailure_admission = sum(refailure_admission)
    /arth_beddays = sum(arth_beddays)
    /asthma_beddays = sum(asthma_beddays)
    /atrialfib_beddays = sum(atrialfib_beddays)
    /cancer_beddays = sum(cancer_beddays)
    /cvd_beddays = sum(cvd_beddays)
    /liver_beddays = sum(liver_beddays)
    /copd_beddays = sum(copd_beddays)
    /dementia_beddays = sum(dementia_beddays)
    /diabetes_beddays = sum(diabetes_beddays)
    /epilepsy_beddays = sum(epilepsy_beddays)
    /chd_beddays = sum(chd_beddays)
    /hefailure_beddays = sum(hefailure_beddays)
    /ms_beddays = sum(ms_beddays)
    /parkinsons_beddays = sum(parkinsons_beddays)
    /refailure_beddays = sum(refailure_beddays)
    /arth_unplanned_beddays = sum(arth_unplanned_beddays)
    /asthma_unplanned_beddays = sum(asthma_unplanned_beddays)
    /atrialfib_unplanned_beddays = sum(atrialfib_unplanned_beddays)
    /cancer_unplanned_beddays = sum(cancer_unplanned_beddays)
    /cvd_unplanned_beddays = sum(cvd_unplanned_beddays)
    /liver_unplanned_beddays = sum(liver_unplanned_beddays)
    /copd_unplanned_beddays = sum(copd_unplanned_beddays)
    /dementia_unplanned_beddays = sum(dementia_unplanned_beddays)
    /diabetes_unplanned_beddays = sum(diabetes_unplanned_beddays)
    /epilepsy_unplanned_beddays = sum(epilepsy_unplanned_beddays)
    /chd_unplanned_beddays = sum(chd_unplanned_beddays)
    /hefailure_unplanned_beddays = sum(hefailure_unplanned_beddays)
    /ms_unplanned_beddays = sum(ms_unplanned_beddays)
    /parkinsons_unplanned_beddays = sum(parkinsons_unplanned_beddays)
    /refailure_unplanned_beddays = sum(refailure_unplanned_beddays)
    /arth_ae2_attendance = sum(arth_ae2_attendance)
    /asthma_ae2_attendance = sum(asthma_ae2_attendance)
    /atrialfib_ae2_attendance = sum(atrialfib_ae2_attendance)
    /cancer_ae2_attendance = sum(cancer_ae2_attendance)
    /cvd_ae2_attendance = sum(cvd_ae2_attendance)
    /liver_ae2_attendance = sum(liver_ae2_attendance)
    /copd_ae2_attendance = sum(copd_ae2_attendance)
    /dementia_ae2_attendance = sum(dementia_ae2_attendance)
    /diabetes_ae2_attendance = sum(diabetes_ae2_attendance)
    /epilepsy_ae2_attendance = sum(epilepsy_ae2_attendance)
    /chd_ae2_attendance = sum(chd_ae2_attendance)
    /hefailure_ae2_attendance = sum(hefailure_ae2_attendance)
    /ms_ae2_attendance = sum(ms_ae2_attendance)
    /parkinsons_ae2_attendance = sum(parkinsons_ae2_attendance)
    /refailure_ae2_attendance = sum(refailure_ae2_attendance)
    /arth_outpatient_attendance = sum(arth_outpatient_attendance)
    /asthma_outpatient_attendance = sum(asthma_outpatient_attendance)
    /atrialfib_outpatient_attendance = sum(atrialfib_outpatient_attendance)
    /cancer_outpatient_attendance = sum(cancer_outpatient_attendance)
    /cvd_outpatient_attendance = sum(cvd_outpatient_attendance)
    /liver_outpatient_attendance = sum(liver_outpatient_attendance)
    /copd_outpatient_attendance = sum(copd_outpatient_attendance)
    /dementia_outpatient_attendance = sum(dementia_outpatient_attendance)
    /diabetes_outpatient_attendance = sum(diabetes_outpatient_attendance)
    /epilepsy_outpatient_attendance = sum(epilepsy_outpatient_attendance)
    /chd_outpatient_attendance = sum(chd_outpatient_attendance)
    /hefailure_outpatient_attendance = sum(hefailure_outpatient_attendance)
    /ms_outpatient_attendance = sum(ms_outpatient_attendance)
    /parkinsons_outpatient_attendance = sum(parkinsons_outpatient_attendance)
    /refailure_outpatient_attendance = sum(refailure_outpatient_attendance)
    /Comm_Living_cost = sum(Comm_Living_cost)
    /Adult_Major_cost = sum(Adult_Major_cost)
    /Child_Major_cost = sum(Child_Major_cost)
    /Low_CC_cost = sum(Low_CC_cost)
    /Medium_CC_cost = sum(Medium_CC_cost)
    /High_CC_cost = sum(High_CC_cost)
    /Substance_cost = sum(Substance_cost)
    /MH_cost = sum(MH_cost)
    /Maternity_cohort_cost = sum(Maternity_cohort_cost)
    /Frailty_cost = sum(Frailty_cost)
    /End_of_Life_cost = sum(End_of_Life_cost)
    /Comm_Living_admission = sum(Comm_Living_admission)
    /Adult_Major_admission = sum(Adult_Major_admission)
    /Child_Major_admission = sum(Child_Major_admission)
    /Low_CC_admission = sum(Low_CC_admission)
    /Medium_CC_admission = sum(Medium_CC_admission)
    /High_CC_admission = sum(High_CC_admission)
    /Substance_admission = sum(Substance_admission)
    /MH_admission = sum(MH_admission)
    /Maternity_cohort_admission = sum(Maternity_cohort_admission)
    /Frailty_admission = sum(Frailty_admission)
    /End_of_Life_admission = sum(End_of_Life_admission)
    /Comm_Living_beddays = sum(Comm_Living_beddays)
    /Adult_Major_beddays = sum(Adult_Major_beddays)
    /Child_Major_beddays = sum(Child_Major_beddays)
    /Low_CC_beddays = sum(Low_CC_beddays)
    /Medium_CC_beddays = sum(Medium_CC_beddays)
    /High_CC_beddays = sum(High_CC_beddays)
    /Substance_beddays = sum(Substance_beddays)
    /MH_beddays = sum(MH_beddays)
    /Maternity_cohort_beddays = sum(Maternity_cohort_beddays)
    /Frailty_beddays = sum(Frailty_beddays)
    /End_of_Life_beddays = sum(End_of_Life_beddays)
    /Comm_Living_unplanned_beddays = sum(Comm_Living_unplanned_beddays)
    /Adult_Major_unplanned_beddays = sum(Adult_Major_unplanned_beddays)
    /Child_Major_unplanned_beddays = sum(Child_Major_unplanned_beddays)
    /Low_CC_unplanned_beddays = sum(Low_CC_unplanned_beddays)
    /Medium_CC_unplanned_beddays = sum(Medium_CC_unplanned_beddays)
    /High_CC_unplanned_beddays = sum(High_CC_unplanned_beddays)
    /Substance_unplanned_beddays = sum(Substance_unplanned_beddays)
    /MH_unplanned_beddays = sum(MH_unplanned_beddays)
    /Maternity_cohort_unplanned_beddays = sum(Maternity_cohort_unplanned_beddays)
    /Frailty_unplanned_beddays = sum(Frailty_unplanned_beddays)
    /End_of_Life_unplanned_beddays = sum(End_of_Life_unplanned_beddays)
    /Comm_Living_ae2_attendance = sum(Comm_Living_ae2_attendance)
    /Adult_Major_ae2_attendance = sum(Adult_Major_ae2_attendance)
    /Child_Major_ae2_attendance = sum(Child_Major_ae2_attendance)
    /Low_CC_ae2_attendance = sum(Low_CC_ae2_attendance)
    /Medium_CC_ae2_attendance = sum(Medium_CC_ae2_attendance)
    /High_CC_ae2_attendance = sum(High_CC_ae2_attendance)
    /Substance_ae2_attendance = sum(Substance_ae2_attendance)
    /MH_ae2_attendance = sum(MH_ae2_attendance)
    /Maternity_cohort_ae2_attendance = sum(Maternity_cohort_ae2_attendance)
    /Frailty_ae2_attendance = sum(Frailty_ae2_attendance)
    /End_of_Life_ae2_attendance = sum(End_of_Life_ae2_attendance)
    /Comm_Living_outpatient_attendance = sum(Comm_Living_outpatient_attendance)
    /Adult_Major_outpatient_attendance = sum(Adult_Major_outpatient_attendance)
    /Child_Major_outpatient_attendance = sum(Child_Major_outpatient_attendance)
    /Low_CC_outpatient_attendance = sum(Low_CC_outpatient_attendance)
    /Medium_CC_outpatient_attendance = sum(Medium_CC_outpatient_attendance)
    /High_CC_outpatient_attendance = sum(High_CC_outpatient_attendance)
    /Substance_outpatient_attendance = sum(Substance_outpatient_attendance)
    /MH_outpatient_attendance = sum(MH_outpatient_attendance)
    /Maternity_cohort_outpatient_attendance = sum(Maternity_cohort_outpatient_attendance)
    /Frailty_outpatient_attendance = sum(Frailty_outpatient_attendance)
    /End_of_Life_outpatient_attendance = sum(End_of_Life_outpatient_attendance).

string Data (A10).
compute Data = "Main".

string Gender_Name (A6).
Compute Gender_Name = ValueLabel(Gender).

alter type LTC_Total SIMD_Quintile Urban_Rural Gender (A1).
alter type LTC_Total (A3) SIMD_Quintile Urban_Rural (A30) Gender (A6).

Recode LTC_Total ("5" = "5+").

Recode SIMD_Quintile
    ("1" = "1 - Most Deprived")
    ("5" = "5 - Least Deprived")
    ("" = "N/A").

Recode Urban_Rural
    ("1" = "1 - Large Urban Areas")
    ("2" = "2 - Other Urban Areas")
    ("3" = "3 - Accessible Small Towns")
    ("4" = "4 - Remote Small Towns")
    ("5" = "5 - Very Remote Small Towns")
    ("6" = "6 - Accessible Rural")
    ("7" = "7 - Remote Rural")
    ("8" = "8 - Very Remote Rural")
    ("" = "N/A").

Compute Gender = ValueLabel(Gender).

save outfile = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav"
    /zcompressed.

*****A&E*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Service".

select if AE2_Cost GT 0 OR AE2_Patients GT 0 OR AE2_Attendances GT 0.

compute Total_Cost = AE2_Cost.
compute Total_Beddays = $sysmis.
compute Total_Attendances = AE2_Attendances.
compute NoPatients = AE2_Patients.

string Service_Area (A30).
compute Service_Area = "A&E".

save outfile =  !sourcdev_matrix_temp + "National_TDE_AE2_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Total_Attendances Data Service_Area.

*****Elective*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Service".

select if Hospital_Elective_Cost GT 0 OR Hospital_Elective_Patients GT 0 OR Hospital_Elective_Attendance GT 0 OR Hospital_Elective_Beddays GT 0.

compute Total_Cost = Hospital_Elective_Cost.
compute Total_Beddays = Hospital_Elective_Beddays.
compute Total_Attendances = Hospital_Elective_Attendance.
compute NoPatients = Hospital_Elective_Patients.

string Service_Area (A30).
compute Service_Area = "Elective".

save outfile =  !sourcdev_matrix_temp + "National_TDE_Elective_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Total_Attendances Data Service_Area.

*****Emergency*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Service".

select if Hospital_Emergency_Cost GT 0 OR Hospital_Emergency_Patients GT 0 OR Hospital_Emergency_Attendance GT 0 OR Hospital_Emergency_Beddays GT 0.

compute Total_Cost = Hospital_Emergency_Cost.
compute Total_Beddays = Hospital_Emergency_Beddays.
compute Total_Attendances = Hospital_Emergency_Attendance.
compute NoPatients = Hospital_Emergency_Patients.

string Service_Area (A30).
compute Service_Area = "Emergency".

save outfile =  !sourcdev_matrix_temp + "National_TDE_Emergency_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Total_Attendances Data Service_Area.

*****Maternity*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Service".

select if Maternity_Cost GT 0 OR Maternity_Patients GT 0 OR Maternity_Attendance GT 0 OR Maternity_Beddays GT 0.

compute Total_Cost = Maternity_Cost.
compute Total_Beddays = Maternity_Beddays.
compute Total_Attendances = Maternity_Attendance.
compute NoPatients = Maternity_Patients.

string Service_Area (A30).
compute Service_Area = "Maternity".

save outfile =  !sourcdev_matrix_temp + "National_TDE_Maternity_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Total_Attendances Data Service_Area.

*****Prescribing*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Service".

select if Prescribing_Cost GT 0 OR Prescribing_Patients GT 0.

compute Total_Cost = Prescribing_Cost.
compute Total_Beddays = $sysmis.
compute Total_Attendances = $sysmis.
compute NoPatients = Prescribing_Patients.

string Service_Area (A30).
compute Service_Area = "Prescribing".

save outfile =  !sourcdev_matrix_temp + "National_TDE_Prescribing_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Total_Attendances Data Service_Area.

*****Outpatient*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Service".

select if Outpatient_Cost GT 0 OR Outpatients GT 0 OR Outpatient_Attendances GT 0.

compute Total_Cost = Outpatient_Cost.
compute Total_Beddays = $sysmis.
compute Total_Attendances = Outpatient_Attendances.
compute NoPatients = Outpatients.

string Service_Area (A30).
compute Service_Area = "Outpatient".

save outfile =  !sourcdev_matrix_temp + "National_TDE_Outpatient_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Total_Attendances Data Service_Area.

***************************************************************************************************************************.
add files file =  !sourcdev_matrix_temp + "National_TDE_AE2_" + !version + "_20" + !FY + ".zsav"
    /file =  !sourcdev_matrix_temp + "National_TDE_Elective_" + !version + "_20" + !FY + ".zsav"
    /file =  !sourcdev_matrix_temp + "National_TDE_Emergency_" + !version + "_20" + !FY + ".zsav"
    /file =  !sourcdev_matrix_temp + "National_TDE_Maternity_" + !version + "_20" + !FY + ".zsav"
    /file =  !sourcdev_matrix_temp + "National_TDE_Prescribing_" + !version + "_20" + !FY + ".zsav"
    /file =  !sourcdev_matrix_temp + "National_TDE_Outpatient_" + !version + "_20" + !FY + ".zsav".

save outfile = !sourcdev_matrix_temp + "National_TDE_Services_" + !version + "_20" + !FY + ".zsav"
    /keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup
    AgeBand Urban_Rural LTC_Total Gender NoPatients Total_Cost Total_Beddays Total_Attendances Data Service_Area
    /zcompressed.

get file = !sourcdev_matrix_temp + "National_TDE_Services_" + !version + "_20" + !FY + ".zsav".

* Housekeeping.
Erase file =  !sourcdev_matrix_temp + "National_TDE_AE2_" + !version + "_20" + !FY + ".zsav".
Erase file =  !sourcdev_matrix_temp + "National_TDE_Elective_" + !version + "_20" + !FY + ".zsav".
Erase file =  !sourcdev_matrix_temp + "National_TDE_Emergency_" + !version + "_20" + !FY + ".zsav".
Erase file =  !sourcdev_matrix_temp + "National_TDE_Maternity_" + !version + "_20" + !FY + ".zsav".
Erase file =  !sourcdev_matrix_temp + "National_TDE_Prescribing_" + !version + "_20" + !FY + ".zsav".
Erase file =  !sourcdev_matrix_temp + "National_TDE_Outpatient_" + !version + "_20" + !FY + ".zsav".

***************************************************************************************************************************.
***************************************************************************************************************************.
***************************************************************************************************************************.
*Long Term Conditions.
*New row for each LTC to include cost, admissions, beddays etc.

*****Arthritis*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if arth GT 0.

compute Total_Cost = arth_Cost.
compute Total_Beddays = arth_beddays.
compute Unplanned_Beddays = arth_unplanned_beddays.
compute Total_Admissions = arth_admission.
compute AE2_Attendances = arth_ae2_attendance.
compute Outpatient_Attendances = arth_outpatient_attendance.
compute NoPatients = arth.

string LTC_Name (A30).
compute LTC_Name = "Arthritis".

save outfile = !sourcdev_matrix_temp + "National_Arthritis_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Asthma*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if asthma GT 0.

compute Total_Cost = asthma_Cost.
compute Total_Beddays = asthma_beddays.
compute Unplanned_Beddays = asthma_unplanned_beddays.
compute Total_Admissions = arth_admission.
compute AE2_Attendances = asthma_ae2_attendance.
compute Outpatient_Attendances = asthma_outpatient_attendance.
compute NoPatients = asthma.

string LTC_Name (A30).
compute LTC_Name = "Asthma".

save outfile = !sourcdev_matrix_temp + "National_Asthma_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Atrial Fib*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if atrialfib GT 0.

compute Total_Cost = atrialfib_Cost.
compute Total_Beddays = atrialfib_beddays.
compute Unplanned_Beddays = atrialfib_unplanned_beddays.
compute Total_Admissions = atrialfib_admission.
compute AE2_Attendances = atrialfib_ae2_attendance.
compute Outpatient_Attendances = atrialfib_outpatient_attendance.
compute NoPatients = atrialfib.

string LTC_Name (A30).
compute LTC_Name = "Atrial Fibrillation".

save outfile = !sourcdev_matrix_temp + "National_Atrialfib_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Cancer*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if cancer GT 0.

compute Total_Cost = cancer_Cost.
compute Total_Beddays = cancer_beddays.
compute Unplanned_Beddays = cancer_unplanned_beddays.
compute Total_Admissions = cancer_admission.
compute AE2_Attendances = cancer_ae2_attendance.
compute Outpatient_Attendances = cancer_outpatient_attendance.
compute NoPatients = cancer.

string LTC_Name (A30).
compute LTC_Name = "Cancer".

save outfile = !sourcdev_matrix_temp + "National_Cancer_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****CVD*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if cvd GT 0.

compute Total_Cost = cvd_Cost.
compute Total_Beddays = cvd_beddays.
compute Unplanned_Beddays = cvd_unplanned_beddays.
compute Total_Admissions = cvd_admission.
compute AE2_Attendances = cvd_ae2_attendance.
compute Outpatient_Attendances = cvd_outpatient_attendance.
compute NoPatients = cvd.

string LTC_Name (A30).
compute LTC_Name = "CVD".

save outfile = !sourcdev_matrix_temp + "National_cvd_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Liver*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if liver GT 0.

compute Total_Cost = liver_Cost.
compute Total_Beddays = liver_beddays.
compute Unplanned_Beddays = liver_unplanned_beddays.
compute Total_Admissions = liver_admission.
compute AE2_Attendances = liver_ae2_attendance.
compute Outpatient_Attendances = liver_outpatient_attendance.
compute NoPatients = liver.

string LTC_Name (A30).
compute LTC_Name = "Liver".

save outfile = !sourcdev_matrix_temp + "National_Liver_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****COPD*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if copd GT 0.

compute Total_Cost = copd_Cost.
compute Total_Beddays = copd_beddays.
compute Unplanned_Beddays = copd_unplanned_beddays.
compute Total_Admissions = copd_admission.
compute AE2_Attendances = copd_ae2_attendance.
compute Outpatient_Attendances = copd_outpatient_attendance.
compute NoPatients = copd.

string LTC_Name (A30).
compute LTC_Name = "COPD".

save outfile = !sourcdev_matrix_temp + "National_copd_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Dementia*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if dementia GT 0.

compute Total_Cost = dementia_Cost.
compute Total_Beddays = dementia_beddays.
compute Unplanned_Beddays = dementia_unplanned_beddays.
compute Total_Admissions = dementia_admission.
compute AE2_Attendances = dementia_ae2_attendance.
compute Outpatient_Attendances = dementia_outpatient_attendance.
compute NoPatients = dementia.

string LTC_Name (A30).
compute LTC_Name = "Dementia".

save outfile = !sourcdev_matrix_temp + "National_Dementia_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Diabetes*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if diabetes GT 0.

compute Total_Cost = diabetes_Cost.
compute Total_Beddays = diabetes_beddays.
compute Unplanned_Beddays = diabetes_unplanned_beddays.
compute Total_Admissions = diabetes_admission.
compute AE2_Attendances = diabetes_ae2_attendance.
compute Outpatient_Attendances = diabetes_outpatient_attendance.
compute NoPatients = diabetes.

string LTC_Name (A30).
compute LTC_Name = "Diabetes".

save outfile = !sourcdev_matrix_temp + "National_Diabetes_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Epilepsy*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if epilepsy GT 0.

compute Total_Cost = epilepsy_Cost.
compute Total_Beddays = epilepsy_beddays.
compute Unplanned_Beddays = epilepsy_unplanned_beddays.
compute Total_Admissions = epilepsy_admission.
compute AE2_Attendances = epilepsy_ae2_attendance.
compute Outpatient_Attendances = epilepsy_outpatient_attendance.
compute NoPatients = epilepsy.

string LTC_Name (A30).
compute LTC_Name = "Epilepsy".

save outfile = !sourcdev_matrix_temp + "National_Epilepsy_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.


*****CHD*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if chd GT 0.

compute Total_Cost = chd_Cost.
compute Total_Beddays = chd_beddays.
compute Unplanned_Beddays = chd_unplanned_beddays.
compute Total_Admissions = chd_admission.
compute AE2_Attendances = chd_ae2_attendance.
compute Outpatient_Attendances = chd_outpatient_attendance.
compute NoPatients = chd.

string LTC_Name (A30).
compute LTC_Name = "CHD".

save outfile = !sourcdev_matrix_temp + "National_CHD_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Heart Failure*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if hefailure GT 0.

compute Total_Cost = hefailure_Cost.
compute Total_Beddays = hefailure_beddays.
compute Unplanned_Beddays = hefailure_unplanned_beddays.
compute Total_Admissions = hefailure_admission.
compute AE2_Attendances = hefailure_ae2_attendance.
compute Outpatient_Attendances = hefailure_outpatient_attendance.
compute NoPatients = hefailure.

string LTC_Name (A30).
compute LTC_Name = "Heart Failure".

save outfile = !sourcdev_matrix_temp + "National_hefailure_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****MS*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if ms GT 0.

compute Total_Cost = ms_Cost.
compute Total_Beddays = ms_beddays.
compute Unplanned_Beddays = ms_unplanned_beddays.
compute Total_Admissions = ms_admission.
compute AE2_Attendances = ms_ae2_attendance.
compute Outpatient_Attendances = ms_outpatient_attendance.
compute NoPatients = ms.

string LTC_Name (A30).
compute LTC_Name = "MS".

save outfile = !sourcdev_matrix_temp + "National_ms_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Parkinsons*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if parkinsons GT 0.

compute Total_Cost = parkinsons_Cost.
compute Total_Beddays = parkinsons_beddays.
compute Unplanned_Beddays = parkinsons_unplanned_beddays.
compute Total_Admissions = parkinsons_admission.
compute AE2_Attendances = parkinsons_ae2_attendance.
compute Outpatient_Attendances = parkinsons_outpatient_attendance.
compute NoPatients = parkinsons.

string LTC_Name (A30).
compute LTC_Name = "Parkinsons".

save outfile = !sourcdev_matrix_temp + "National_Parkinsons_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

*****Renal Failure*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "LTC".

select if refailure GT 0.

compute Total_Cost = refailure_Cost.
compute Total_Beddays = refailure_beddays.
compute Unplanned_Beddays = refailure_unplanned_beddays.
compute Total_Admissions = refailure_admission.
compute AE2_Attendances = refailure_ae2_attendance.
compute Outpatient_Attendances = refailure_outpatient_attendance.
compute NoPatients = refailure.

string LTC_Name (A30).
compute LTC_Name = "Renal Failure".

save outfile = !sourcdev_matrix_temp + "National_refailure_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.

***************************************************************************************************************************.
add files file = !sourcdev_matrix_temp + "National_Arthritis_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Asthma_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Atrialfib_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Cancer_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_cvd_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Liver_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_copd_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Dementia_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Diabetes_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_hefailure_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Epilepsy_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_CHD_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_ms_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Parkinsons_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_refailure_" + !version + "_20" + !FY + ".zsav".

save outfile = !sourcdev_matrix_temp + "National_TDE_LTCs_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data LTC_Name.
get file = !sourcdev_matrix_temp + "National_TDE_LTCs_" + !version + "_20" + !FY + ".zsav".

* Housekeeping.
Erase file = !sourcdev_matrix_temp + "National_Arthritis_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Asthma_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Atrialfib_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Cancer_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_cvd_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Liver_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_copd_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Dementia_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Diabetes_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_hefailure_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Epilepsy_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_CHD_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_ms_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Parkinsons_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_refailure_" + !version + "_20" + !FY + ".zsav".

***************************************************************************************************************************.
***************************************************************************************************************************.
***************************************************************************************************************************.
*Demographic Cohort.
*New row for each demographic cohort to include cost, admissions, beddays etc.

*****Community Living*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if Comm_Living GT 0.

compute Total_Cost = Comm_Living_Cost.
compute Total_Beddays = Comm_Living_beddays.
compute Unplanned_Beddays = Comm_Living_unplanned_beddays.
compute Total_Admissions = Comm_Living_admission.
compute AE2_Attendances = Comm_Living_ae2_attendance.
compute Outpatient_Attendances = Comm_Living_outpatient_attendance.
compute NoPatients = Comm_Living.

string Demograph_Name (A30).
compute Demograph_Name = "Community Assisted Living".

save outfile = !sourcdev_matrix_temp + "National_Comm_Living_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****Adult Major*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if Adult_Major GT 0.

compute Total_Cost = Adult_Major_Cost.
compute Total_Beddays = Adult_Major_beddays.
compute Unplanned_Beddays = Adult_Major_unplanned_beddays.
compute Total_Admissions = Adult_Major_admission.
compute AE2_Attendances = Adult_Major_ae2_attendance.
compute Outpatient_Attendances = Adult_Major_outpatient_attendance.
compute NoPatients = Adult_Major.

string Demograph_Name (A30).
compute Demograph_Name = "Adult Major Conditions".

save outfile = !sourcdev_matrix_temp + "National_Adult_Major_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****Child Major*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if Child_Major GT 0.

compute Total_Cost = Child_Major_Cost.
compute Total_Beddays = Child_Major_beddays.
compute Unplanned_Beddays = Child_Major_unplanned_beddays.
compute Total_Admissions = Child_Major_admission.
compute AE2_Attendances = Child_Major_ae2_attendance.
compute Outpatient_Attendances = Child_Major_outpatient_attendance.
compute NoPatients = Child_Major.

string Demograph_Name (A30).
compute Demograph_Name = "Child Major Conditions".

save outfile = !sourcdev_matrix_temp + "National_Child_Major_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****Low CC*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if Low_CC GT 0.

compute Total_Cost = Low_CC_Cost.
compute Total_Beddays = Low_CC_beddays.
compute Unplanned_Beddays = Low_CC_unplanned_beddays.
compute Total_Admissions = Low_CC_admission.
compute AE2_Attendances = Low_CC_ae2_attendance.
compute Outpatient_Attendances = Low_CC_outpatient_attendance.
compute NoPatients = Low_CC.

string Demograph_Name (A30).
compute Demograph_Name = "Low Complex Conditions".

save outfile = !sourcdev_matrix_temp + "National_Low_CC_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****Medium CC*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if Medium_CC GT 0.

compute Total_Cost = Medium_CC_Cost.
compute Total_Beddays = Medium_CC_beddays.
compute Unplanned_Beddays = Medium_CC_unplanned_beddays.
compute Total_Admissions = Medium_CC_admission.
compute AE2_Attendances = Medium_CC_ae2_attendance.
compute Outpatient_Attendances = Medium_CC_outpatient_attendance.
compute NoPatients = Medium_CC.

string Demograph_Name (A30).
compute Demograph_Name = "Medium Complex Conditions".

save outfile = !sourcdev_matrix_temp + "National_Medium_CC_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****High CC*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if High_CC GT 0.

compute Total_Cost = High_CC_Cost.
compute Total_Beddays = High_CC_beddays.
compute Unplanned_Beddays = High_CC_unplanned_beddays.
compute Total_Admissions = High_CC_admission.
compute AE2_Attendances = High_CC_ae2_attendance.
compute Outpatient_Attendances = High_CC_outpatient_attendance.
compute NoPatients = High_CC.

string Demograph_Name (A30).
compute Demograph_Name = "High Complex Conditions".

save outfile = !sourcdev_matrix_temp + "National_High_CC_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****Substance Misuse*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if Substance GT 0.

compute Total_Cost = Substance_Cost.
compute Total_Beddays = Substance_beddays.
compute Unplanned_Beddays = Substance_unplanned_beddays.
compute Total_Admissions = Substance_admission.
compute AE2_Attendances = Substance_ae2_attendance.
compute Outpatient_Attendances = Substance_outpatient_attendance.
compute NoPatients = Substance.

string Demograph_Name (A30).
compute Demograph_Name = "Substance Misuse".

save outfile = !sourcdev_matrix_temp + "National_Substance_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****Mental Health*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if MH GT 0.

compute Total_Cost = MH_Cost.
compute Total_Beddays = MH_beddays.
compute Unplanned_Beddays = MH_unplanned_beddays.
compute Total_Admissions = MH_admission.
compute AE2_Attendances = MH_ae2_attendance.
compute Outpatient_Attendances = MH_outpatient_attendance.
compute NoPatients = MH.

string Demograph_Name (A30).
compute Demograph_Name = "Mental Health".

save outfile = !sourcdev_matrix_temp + "National_MH_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****Maternity*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if Maternity GT 0.

compute Total_Cost = Maternity_cohort_Cost.
compute Total_Beddays = Maternity_cohort_beddays.
compute Unplanned_Beddays = Maternity_cohort_unplanned_beddays.
compute Total_Admissions = Maternity_cohort_admission.
compute AE2_Attendances = Maternity_cohort_ae2_attendance.
compute Outpatient_Attendances = Maternity_cohort_outpatient_attendance.
compute NoPatients = Maternity.

string Demograph_Name (A30).
compute Demograph_Name = "Maternity".

save outfile = !sourcdev_matrix_temp + "National_Maternity_cohort_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****Frailty*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if Frailty GT 0.

compute Total_Cost = Frailty_Cost.
compute Total_Beddays = Frailty_beddays.
compute Unplanned_Beddays = Frailty_unplanned_beddays.
compute Total_Admissions = Frailty_admission.
compute AE2_Attendances = Frailty_ae2_attendance.
compute Outpatient_Attendances = Frailty_outpatient_attendance.
compute NoPatients = Frailty.

string Demograph_Name (A30).
compute Demograph_Name = "Frailty".

save outfile = !sourcdev_matrix_temp + "National_Frailty_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

*****End of Life*****.
get file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".

compute Data = "Demograph".

select if End_of_Life GT 0.

compute Total_Cost = End_of_Life_Cost.
compute Total_Beddays = End_of_Life_beddays.
compute Unplanned_Beddays = End_of_Life_unplanned_beddays.
compute Total_Admissions = End_of_Life_admission.
compute AE2_Attendances = End_of_Life_ae2_attendance.
compute Outpatient_Attendances = End_of_Life_outpatient_attendance.
compute NoPatients = End_of_Life.

string Demograph_Name (A30).
compute Demograph_Name = "End of Life".

save outfile = !sourcdev_matrix_temp + "National_End_of_Life_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances Data Demograph_Name.

***************************************************************************************************************************.
add files
    /file = !sourcdev_matrix_temp + "National_Adult_Major_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Child_Major_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Low_CC_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Medium_CC_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_High_CC_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Substance_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_MH_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Maternity_cohort_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_Frailty_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_End_of_Life_" + !version + "_20" + !FY + ".zsav".

* Comm living cohort has been removed temporarily.
* file = !sourcdev_matrix_temp + "National_Comm_Living_" + !version + "_20" + !FY + ".zsav".

save outfile = !sourcdev_matrix_temp + "National_TDE_Demographic_" + !version + "_20" + !FY + ".zsav"
    /zcompressed
    /Keep Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender  Data Demograph_Name
    NoPatients Total_Cost Total_Beddays Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances.
get file = !sourcdev_matrix_temp + "National_TDE_Demographic_" + !version + "_20" + !FY + ".zsav".

* Housekeeping.
Erase file = !sourcdev_matrix_temp + "National_Comm_Living_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Adult_Major_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Child_Major_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Low_CC_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Medium_CC_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_High_CC_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Substance_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_MH_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Maternity_cohort_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_Frailty_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_End_of_Life_" + !version + "_20" + !FY + ".zsav".

***************************************************************************************************************************.
***************************************************************************************************************************.

add files
    /file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_TDE_Services_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_TDE_LTCs_" + !version + "_20" + !FY + ".zsav"
    /file = !sourcdev_matrix_temp + "National_TDE_Demographic_" + !version + "_20" + !FY + ".zsav".
execute.

string Year (A7).
compute Year = concat("20", char.substr(!FY, 1, 2), "/", char.substr(!FY, 3, 2)).

save outfile = !sourcdev_matrix_final + !version + "_TDE_20" + !FY + ".zsav"
    /Keep Year Partnership ClusterName gpprac Service_Use_Cohort Demographic_Cohort SIMD_Quintile ResourceGroup AgeBand Urban_Rural LTC_Total Gender Data Service_Area LTC_Name Demograph_Name
    NoPatients Total_Cost Total_Beddays Total_Attendances Unplanned_Beddays Total_Admissions AE2_Attendances Outpatient_Attendances 
    Comm_Living Adult_Major Child_Major Low_CC Medium_CC High_CC Substance MH Maternity Frailty End_of_Life ZeroLTC OneLTC TwoLTC ThreeLTC FourLTC FiveLTC
    arth asthma atrialfib cancer copd cvd dementia diabetes epilepsy chd hefailure liver ms parkinsons refailure
    /zcompressed.
get file = !sourcdev_matrix_final + !version + "_TDE_20" + !FY + ".zsav".

* Housekeeping.
Erase file = !sourcdev_matrix_temp + "National_TDE_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_TDE_Services_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_TDE_LTCs_" + !version + "_20" + !FY + ".zsav".
Erase file = !sourcdev_matrix_temp + "National_TDE_Demographic_" + !version + "_20" + !FY + ".zsav".

