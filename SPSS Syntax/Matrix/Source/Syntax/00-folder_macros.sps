* Encoding: UTF-8.
* SOURCE / PCI - affects names of files.
Define !version()
    "SOURCE"
!Enddefine.

* Source Linkage files folder.
Define !hscdiip_slf()
    "/conf/hscdiip/01-Source-linkage-files/"
!Enddefine.

* Location of full cohort lookups.
Define !hscdiip_cohorts()
    "/conf/hscdiip/SLF_Extracts/Cohorts/"
!EndDefine.

* Matrix sourcedev folder (for temp files).
Define !sourcdev_matrix_temp()
    "/conf/sourcedev/TableauUpdates/Matrix/Source/Output/Temp/"
!Enddefine.

* Final output Location.
Define !sourcdev_matrix_final()
    "/conf/sourcedev/TableauUpdates/Matrix/Source/Output/Final/"
!Enddefine.