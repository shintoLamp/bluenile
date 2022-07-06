* Encoding: UTF-8.
GET FILE='/conf/linkage/output/lookups/Unicode/Populations/Estimates/DataZone2011_pop_est_2011_2018.sav'.
select if Year=2018.
EXECUTE.
DELETE VARIABLES IntZone2011 HSCP2016 HB2014 CA2011 CA2018.
alter type DataZone2011 (A9).

match files file=*
/table ='/conf/linkage/output/lookups/Unicode/Deprivation/DataZone2011_simd2016.sav'
/by DataZone2011.
EXECUTE.
dataset name simd window=front.

VARSTOCASES
   /MAKE POP FROM 
age0 age1 age2 age3 age4 age5 age6 age7 age8 age9
age10 age11 age12 age13 age14 age15 age16 age17 age18 age19
age20 age21 age22 age23 age24 age25 age26 age27 age28 age29
age30 age31 age32 age33 age34 age35 age36 age37 age38 age39
age40 age41 age42 age43 age44 age45 age46 age47 age48 age49
age50 age51 age52 age53 age54 age55 age56 age57 age58 age59
age60 age61 age62 age63 age64 age65 age66 age67 age68 age69
age70 age71 age72 age73 age74 age75 age76 age77 age78 age79
age80 age81 age82 age83 age84 age85 age86 age87 age88 age89
age90plus
   /INDEX Age(Pop)
   /KEEP ALL.
EXECUTE.

COMPUTE Age = CHAR.SUBSTR(Age,4,2).
EXECUTE.

* Change age to numeric.
ALTER TYPE Age (F2.0).

* Recode age into age bands.
STRING Age_Band (A12).
RECODE age (Lowest thru 64='<65')  (65 thru 74='65-74') (75 thru 84='75-84') (85 thru Highest='85+') INTO Age_Band.
EXECUTE.

DATASET name simd.

GET FILE='/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_20191216.sav'.
dataset name Locality window=front.
rename vars (HSCPLocality HSCP2019Name =Locality Partnership).
alter type Locality (A70).

alter type DataZone2011 (A9).
sort cases DataZone2011 (A).

match files file=simd
/table ='Locality'
/table='/conf/linkage/output/lookups/Unicode/Geography/Urban Rural Classification/datazone2011_urban_rural_2016.sav'
/by DataZone2011.
EXECUTE.

dataset declare simd_UR.
aggregate outfile=simd_UR
   /break DataZone2011 Partnership simd2016_HSCP2016_quintile Age_Band sex UR2_2016
   /Pop=sum(POP).
execute.
dataset activate simd_UR.

select if Partnership ne "".
EXECUTE.

rename variables Partnership=Locality.
alter type Locality (a70).

save outfile = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/part_pop_age_urban_simd_sex_RH.sav'.

add files file = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/pop_age_urban_simd_sex.sav'
/file = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/part_pop_age_urban_simd_sex_RH.sav'.
execute.

save outfile = '/conf/social-care/05-Analysts/linked_outputs/2017_18 SOURCE/Outputs/pop_age_urban_simd_sex_RH.sav'.