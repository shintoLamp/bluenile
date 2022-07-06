* Encoding: UTF-8.
* SOURCE / PCI - affects names of files.
Define !version()
    "PCI"
!Enddefine.

Define !slf_latest_update()
    "Mar_2022"
!enddefine.

* Source Linkage files folder.
Define !hscdiip_slf()
    "/conf/hscdiip/01-Source-linkage-files/"
!Enddefine.

* Location of full cohort lookups.
Define !hscdiip_cohorts()
    "/conf/hscdiip/SLF_Extracts/Cohorts/"
!EndDefine.

* Location of GP Practice details (and Clusters) lookup.
Define !hscdiip_slf_lookups()
    "/conf/hscdiip/SLF_Extracts/Lookups/"
!EndDefine.

* Matrix sourcedev folder (for temp files).
Define !sourcdev_matrix_temp()
    "/conf/sourcedev/TableauUpdates/Matrix/PCI/Output/Temp/"
!Enddefine.

* Final output Location.
Define !sourcdev_matrix_final()
    "/conf/sourcedev/TableauUpdates/Matrix/PCI/Output/Final/"
!Enddefine.