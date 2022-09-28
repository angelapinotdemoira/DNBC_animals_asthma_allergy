*Type of bird or rodents
*Angela Pinot de Moira
*April 2022
***************************
*Open data and run ado files:


run "D:\Data\workdata\707796\Do files\allergic rhinitis_from age6.do" 

merge 1:m pnr using "D:\Data\workdata\707796\analysis_data.dta"
recode rhinitis6 .=0 if _merge==3 & outcome==1
drop _merge // merge is the same as merge_ad

*run "D:\Data\workdata\707796\Do files\Ado\tabout.ado"


*Allergy in the family
egen family_allergy_asthma = rowmax(asthma_bf asthma_m allergy_f allergy_inh_m)


*Rabbit, rodent and exotic variables:

run "D:\Data\workdata\707796\Do files\new rabbit, rodents and other_furry variables.do"


********************************************************************************
*Define population (note, this includes children with missing outcome)

keep if asthma!=. //liveborns with valid CPR
keep if flerfold==1 //singletons
 // n=5,677 (children not live born or with invalid cpr)
 // 4,183 multiples dropped
count
*Identify those with AD data:
replace AD=. if migration_m==1 // mother's who migrated before birth (n=166)
replace AD=. if inlist(migration,1,2) // children who immigrated after birth (n=91)
*Identify those with asthma data:
replace asthma=. if inlist(migration6,1,2) //n=1,204 excludes children who emigrated before 6th birthday
replace asthma=. if doddato< bday_6 & !mi(bday_6) //397 children died before 6th birthday
count // 85,096
*Identify those with rhinitis data:
replace rhinitis6=. if inlist(migration6,1,2) //n=1,393 excludes children who emigrated before 6th birthday
replace rhinitis6=. if doddato< bday_6 & !mi(bday_6) //501 children died before 6th birthday


*establish which children have information on all types of animal exposures in pregnancy:
egen pets_int1 = rowmiss(dog_int1 cat_int1 rabbit_int1 rodent_int1 exotic_int1 livestock_int1 bird_int1)

keep if pets_int1==0 // keep those that have complete information on pets (n=6,169)

drop if  doddato==eventda

count 

///////////////////////////////////////////////////////////////////////////////
*******************************************************************************
**BIRDS

*Pet exposures
gen bird_type = 0 if bird_int1!=.

*Bird - undefined
replace bird_type = 1 if a203_2==1 | inlist(a203a_str, 54, 70, 151, 262)

*Bird - poultry
replace bird_type= 3 if inlist(a203a_str, 7, 10, 13, 16, 17, 18, 34, 41, 42, ///
43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53,  55, 64,  79, 123, 124, ///
125, 134, 138, 141, 143, 144, 163, 176, 177, 178, 179, 180, 181, 182, 183, ///
184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, ///
201, 202, 203, 204, 205, 206, 207, 208, 211, 212, 217, 237, 241, 276, 285,  ///
 320, 329, 331,  346, 347, 163, ///
9, 38, 105, 107, 156, 162, 166, 168, 175, 200, 210, 218, 219, 224, 225, 227, ///
229, 240, 217, 230, 233)


*Sensitivity analysis: indoor birds:
replace bird_type = 2 if inlist(a203a_str, 78, 105, 107, ///
286, 288, ///
289, 290, 291, 292, 293, 333, 334, 345,  ///
9,  ///
152 )

********************************************************************************


*Farm exposures:

* birds - poultry
replace bird_type = 3 if a202_4==1 & bird_type!=2
replace bird_type = 3 if inlist(a202a_str, 14, 15, 19, 20, 21, 30, 34, 75, ///
83, 85, 86, 93, 94, 104, 109, 113, 117, 118, 119, 122, 125, 126, 127, 128, ///
129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, ///
144, 145, 146, 147, 152, 176, 177, 178, 179, 180, 182, 192, 209, 219, 224, ///
249, 259, 276, 279, 283, 7, 9, 11, 14, 18, 44, 45, 46, 57, ///
58, 60, 71, 84, 94, 101, 102, 103, 104, 105, 107, 108, ///
109, 110, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 127,  ///
131, 133, 136, 138, 140, 143, 146, 147, 178, 179, 180, 187, 192, ///
215, 228, 235, 238, 242, 243, 244, 253, 254, 255, 256,  272, 274, ///
275, 276, 277, 278, 279, 280, 283) & bird_type!=2


*birds - undefined
replace  bird_type=1  if inlist(a202a_str,  65, 66, 67,  106, 160,  196, ///
203) & bird_type==0

*Birds - pet
replace  bird_type=2 if inlist(a202a_str,  128, 269)

********************************************************************************

*Occupational:

*am095_4 = chickens
*am095_5 = turkey
*am101_3 = poultry abbatoir
*am105_3 = poultry

*Bird - poultry
replace bird_type = 3 if  (am101_3==1  | am101a_str==2 | am105_3==1 | inlist(am105a_str, 26, 44, 59)) & bird_type!=2
replace bird_type = 3 if (am095_4==1 | am095_5==1 |  inlist(am095b_str, 7) ) & bird_type!=2

*Bird - pet
replace  bird_type=2 if inlist(am105a_str, 1, 2, 3, 10, 18, 20, 21, 22, 23, 34, ///
35, 37, 42, 48, 52, 55, 71)


*******************************************************************************
label define bird_type 0 "none" 1 "undefined bird" 2 "indoor bird" 3 "poultry"
label values bird_type bird_type


//////////////////////////////////////////////////////////////////////////////
*****************************************************************************
*RODENTS


*Pet

gen hamster = 0 if rodent_int1!=.
replace hamster=1 if a203_4==1 | inlist(a203a_str, 122, 126, 209, 210, 302)

gen guinea_pig = 0 if rodent_int1!=.
replace guinea_pig=1 if a203_9==1 | inlist(a203a_str, 284, 330)

gen mouse_rat = 0 if rodent_int1!=.
replace mouse_rat=1 if a203_10==1 | inlist(a203a_str, 283, 145, 67, 68, 108, 259, 307, 308, 309, 310, ///
311)

gen chincilla = 0 if rodent_int1!=.
replace chincilla=1 if inlist(a203a_str, 1, 5, ///
10, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, ///
77, 80, 81, 82, ///
83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, ///
102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, ///
117, 161, 165, 222, 246, 254, 256, 322, 323, 324, 325 )

gen gerbil_degu = 0 if rodent_int1!=.
replace gerbil_degu=1 if inlist(a203a_str, 3, 104, 118, 298, 299, 300, 301, 302,  303,  32, 119, 120)

gen squirrel_chipmunk = 0 if rodent_int1!=.
replace squirrel_chipmunk=1 if inlist(a203a_str, 61, 252, 253, 254, ///
 255, 132, 321)
 
gen jerboa = 0 if rodent_int1!=.
replace jerboa=1 if inlist(a203a_str, 304, 305)

gen rodent_unspec = 0 if rodent_int1!=.
replace rodent_unspec=1 if inlist(a203a_str, 40, 133, 171, 172, 318)


foreach var of varlist hamster - rodent_unspec {
tab `var' family_allergy_asthma, col
}
*****************************************************************************'*
*Farm

*other furry animals

replace chincilla=1 if inlist(a202a_str, 8, 54, 55)
replace squirrel_chipmunk=1 if inlist(a202a_str, 59, 217) 
replace gerbil_degu=1 if inlist(a202a_str, 245)
replace mouse_rat=1 if inlist(a202a_str, 246)


*******************************************************************************
*Occupational

replace rodent_unspec=1 if am101_5==1 | am105_5==1 ///
| am095_8==1 | inlist(am105a_str, 6, 13, 15, 18, 22, 37, 57, 58, 65, 77, 78, 79, 80)
replace guinea_pig=1 if inlist(am105a_str, 20, 39, 51, 66, 74)
replace mouse_rat=1  if inlist(am105a_str, 44, 68, 69, 74)

******************************************************************************
*Combine variables

gen rodent_type=0 if rodent_int1!=.
replace rodent_type=6 if rodent_unspec==1
replace rodent_type=1 if guinea_pig==1
replace rodent_type=2 if hamster==1
replace rodent_type=3 if mouse_rat==1
replace rodent_type=4 if chincilla==1
replace rodent_type=5 if gerbil_degu==1 | squirrel_chipmunk==1 | jerboa==1

 
label define rodent 0 "none" 1 "guinea pig" 2 "hamster" 3 "mouse or rat" 4 "chinchilla" 5 "gerbil or degu"
label values rodent_type rodent


////////////////////////////////////////////////////////////////////////////////
********************************************************************************
*All
tabout bird_type rodent_type using exposure_types_FINAL.txt, replace ///
c(freq col) f(0c 1) clab(N %) ptotal(single) oneway

*By cat:
tabout bird_type rodent_type family_allergy_asthma using family_history_exposure_types_FINAL.txt, replace ///
c(freq col) f(0c 1) clab(N %) ptotal(single)

