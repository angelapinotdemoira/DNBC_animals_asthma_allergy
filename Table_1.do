*Table 1
*Angela Pinot de Moira
*19 Feb 2021
***************************
*Open data and run ado files:

clear

run "D:\Data\workdata\707796\Do files\allergic rhinitis_from age6.do" 

merge 1:m pnr using "D:\Data\workdata\707796\analysis_data.dta"
recode rhinitis6 .=0 if _merge==3 & outcome==1
drop _merge // merge is the same as merge_ad

*run "D:\Data\workdata\707796\Do files\Ado\tabout.ado"

*Parity
recode parity_m 1/4=1

*Mode of delivery
recode mode_delivery 1/2=0 3/5=1, gen(c_section)

*Household size
run  "D:\Data\workdata\707796\Do files\hh size.do" 

*Source of animal exposure
run "D:\Data\workdata\707796\Do files\animal_source.do"

*Working with animals (no/farming and zoo/domestic)
gen farm_zoo_o = 0 if cattle_o==0 & pigs_o==0 & poultry_o==0 & sheep_goats_o==0 & equine_o==0 & zoo_o==0
replace farm_zoo = 1 if inlist(cattle_o,1,2) | inlist(pigs_o,1,2) | inlist(poultry_o,1,2) | ///
 inlist(sheep_goats_o,1,2) | inlist(equine_o,1,2) | inlist(zoo_o,1,2)
gen domestic_o = 0 if other_furry_o==0 & dogs_o==0 & cat_o==0 & bird_o==0 
replace domestic_o=1 if inlist(other_furry_o,1,2) | inlist(dogs_o,1,2) | inlist(cat_o,1,2) | inlist(bird_o,1,2) 

gen occ = 0 if farm_zoo_o==0 & domestic_o==0
replace occ = 1 if farm_zoo_o==1 | domestic_o==1


*Gestational age
gen ga_wks = geslut/7
cd "D:\Data\workdata\707796\Results"

*Rabbit, rodent and exotic variables:

run "D:\Data\workdata\707796\Do files\new rabbit, rodents and other_furry variables.do"


********************************************************************************
*Define population (note, this includes children with missing outcome)

*create date of 13th birthday:
gen day = day(eventda)
replace day=28 if day(eventda)==29 & month(eventda)==2
gen month = month(eventda)
gen year = (year(eventda)) + 13
gen bday_13 = mdy(month,day,year)
format bday_13 %d


keep if asthma!=. //liveborns with valid CPR
keep if flerfold==1 //singletons
 // n=5,677 (children not live born or with invalid cpr)
 // 4,183 multiples dropped
count
*Identify those with AD data:
replace AD=. if migration_m==1 // mother's who migrated before birth (n=166)
replace AD=. if inlist(migration,1,2) // children who immigrated after birth (n=91)

egen outdate = rowmin(AD_date doddato migration_date bday_13)
format outdate %d
replace AD =0 if AD_date>outdate & AD_date!=.
drop outdate
count

*Identify those with asthma data:
replace asthma=. if inlist(migration6,1,2) //n=1,204 excludes children who emigrated before 6th birthday
replace asthma=. if doddato< bday_6 & !mi(bday_6) //397 children died before 6th birthday
egen outdate = rowmin(asthma_date doddato migration_date6 bday_13)
format outdate %d
replace asthma =0 if asthma_date>outdate & asthma_date!=.
drop outdate
count // 

*Identify those with rhinitis data:
replace rhinitis6=. if inlist(migration6,1,2) //n=1,393 excludes children who emigrated before 6th birthday
replace rhinitis6=. if doddato< bday_6 & !mi(bday_6) //501 children died before 6th birthday
egen outdate = rowmin(rhinitis6_date doddato migration_date6 bday_13) //13th birthday
format outdate %d
replace rhinitis6 =0 if rhinitis6_date>outdate & rhinitis6_date!=.
drop outdate



/*establish which children have information on all types of animal exposures in pregnancy and covariates:
egen miss = rowmiss(cat_int1 dog_int1 other_furry_int1 bird_int1 ///
livestock_int1 asthma_m allergy_inh_m asthma_bf allergy_f ///
mat_ed_3cat hhincome_cat crowding_cat children_cat parity_m ///
agebirth_m_y preg_smk copenhagen)
keep if miss==0
*/

*establish which children have information on all types of animal exposures in pregnancy:
egen pets_int1 = rowmiss(dog_int1 cat_int1 rabbit_int1 rodent_int1 exotic_int1 livestock_int1 bird_int1)

keep if pets_int1==0 // keep those that have complete information on pets (n=6,169)

drop if  doddato==eventda // drop children who died on birth day

********************Label variables---------------------------------------------

*Recode missing categorical values as 9999:
foreach var of varlist AD asthma rhinitis6  allergy_f asthma_bf asthma_m allergy_any_m allergy_inh_m ///
animal_allergy_m mat_ed_3cat hhincome_cat crowding_cat children_cat parity_m ///
 preg_smk copenhagen antibiotics {
recode `var' .=9999
}

*Maternal education
la var mat_ed_3cat "Mother's education"
label define mat_ed2 1 "Low" ///
2 "Medium" ///
3 "High" ///
9999 "Missing"
label val mat_ed_3cat mat_ed2
*Smoking in pregnancy
la var preg_smk "Mother's smoking in pregnancy"
la def binary 0 "No" 1 "Yes" 9999 "Missing"
la val preg_smk binary
*Parity
la var parity_m "Multiparous"
la val parity binary
*Maternal asthma
la var asthma_m "Maternal history of asthma"
la val asthma_m binary
*Any maternal allergy
la var allergy_any_m "Maternal history of any allergy"
la val allergy_any_m binary
*Maternal inhalent allergy
la var allergy_inh_m "Maternal history of inhalent allergy"
la val allergy_inh_m binary
*Maternal animal allergy
la var animal_allergy_m "Maternal history of animal allergy"
la val animal_allergy_m binary
*Paternal asthma
la var asthma_bf "Paternal history of asthma"
la val asthma_bf binary
*Paternal allergy
la var allergy_f "Paternal history of allergy"
la val allergy_f binary
*Sex
la var sex "Sex of child"
la def sex 1 "Male" 2 "Female" 9999 "Missing"
la val sex sex
*Household income
la var hhincome_cat "Household income"
label define income 1 "Quintile 1 (low)" ///
2 "Quintile 2" ///
3 "Quintile 3" ///
4 "Quintile 4 (high)" ///
9999 "Missing"
la val hhincome_cat income
*Sex
la var sex "Sex of child"
*la def sex 1 "Male" 2 "Female" 9999 "Missing"
la val sex sex
*Copenhagen
la var copenhagen "Living in Copenhagen"
la val copenhagen binary
*Antibiotics
la var antibiotics "Antibiotics"
la val antibiotics binary
*Timing of exposure
la var cat "Cat timing"
la var dog "Dog timing"
la var rabbit "Rabbit timing"
la var rodent "Rodent timing"
la var exotic "Exotic timing"
la var bird "Bird timing"
*label define ownership 0 "no ownership" 1 "pregnancy only" 2 "early-life only" 3 "pregnancy and early-life" 9999 "missing"
foreach var of varlist cat dog rabbit rodent exotic bird {
recode `var' .=9999
label val `var' "ownership"
}

*Source of exposure
gen pet_livestock = farm_home_livestock
label define source 0 "no exposure" 1 "home (pet)" 2 "other" 9999 "missing"
foreach var in cat dog rabbit rodent exotic bird livestock {
/*gen `var'_source = 0 if pet_`var'==0 & `var'_int1==0
replace `var'_source = 1 if pet_`var'==1 & `var'_int1==1
replace `var'_source = 2 if pet_`var'==0 & `var'_int1==1
*/
recode `var'_source .=9999
la val `var'_source "source"
 }


*Maternal age
la var agebirth_m_y "Maternal age (years)"

********************************************************************************
*Create tables

*******************Categorical variables:

*All
tabout mat_ed_3cat parity_m preg_smk asthma_m allergy_any_m allergy_inh_m ///
animal_allergy_m asthma_bf allergy_f sex antibiotics hhincome_cat ///
children_cat crowding_cat copenhagen AD asthma rhinitis6 using table1_cat_all_0722.txt, replace ///
c(freq col) f(0c 2) clab(N %) ptotal(single) oneway

*By cat:
tabout mat_ed_3cat parity_m preg_smk asthma_m allergy_any_m allergy_inh_m ///
animal_allergy_m asthma_bf allergy_f sex antibiotics hhincome_cat ///
children_cat crowding_cat copenhagen AD asthma rhinitis6  cat_source cat cat_int1 using table1_cat_cat_0722.txt, replace ///
c(freq col) f(0c 2) clab(N %) ptotal(single)

*By dog:
tabout mat_ed_3cat parity_m preg_smk asthma_m allergy_any_m allergy_inh_m ///
animal_allergy_m asthma_bf allergy_f sex antibiotics hhincome_cat ///
children_cat crowding_cat copenhagen AD asthma rhinitis6 dog_source dog dog_int1 using table1_cat_dog_0722.txt, replace ///
c(freq col) f(0c 2) clab(N %) ptotal(none)
 
*By rabbit:
tabout mat_ed_3cat parity_m preg_smk asthma_m allergy_any_m allergy_inh_m ///
animal_allergy_m asthma_bf allergy_f sex antibiotics hhincome_cat ///
children_cat crowding_cat copenhagen AD asthma rhinitis6  rabbit_source rabbit rabbit_int1 using table1_cat_rabbit_0722.txt, replace ///
c(freq col) f(0c 2) clab(N %) ptotal(none)

*By rodent:
tabout mat_ed_3cat parity_m preg_smk asthma_m allergy_any_m allergy_inh_m ///
animal_allergy_m asthma_bf allergy_f sex antibiotics hhincome_cat ///
children_cat crowding_cat copenhagen AD asthma rhinitis6  rodent_source rodent rodent_int1 using table1_cat_rodent_0722.txt, replace ///
c(freq col) f(0c 2) clab(N %) ptotal(none)

*By exotic:
tabout mat_ed_3cat parity_m preg_smk asthma_m allergy_any_m allergy_inh_m ///
animal_allergy_m asthma_bf allergy_f sex antibiotics hhincome_cat ///
children_cat crowding_cat copenhagen AD asthma rhinitis6  exotic_source exotic exotic_int1 using table1_cat_exotic_0722.txt, replace ///
c(freq col) f(0c 2) clab(N %) ptotal(none)

*By bird:
tabout mat_ed_3cat parity_m preg_smk asthma_m allergy_any_m allergy_inh_m ///
animal_allergy_m asthma_bf allergy_f sex antibiotics hhincome_cat ///
children_cat crowding_cat copenhagen AD asthma rhinitis6 bird_source bird bird_int1 using table1_cat_bird_0722.txt, replace ///
c(freq col) f(0c 2) clab(N %) ptotal(none)

*By livestock:
tabout mat_ed_3cat parity_m preg_smk asthma_m allergy_any_m allergy_inh_m ///
animal_allergy_m asthma_bf allergy_f sex antibiotics hhincome_cat ///
children_cat crowding_cat copenhagen AD asthma rhinitis6 livestock_source livestock_int1 using table1_cat_livestock_0722.txt, replace ///
c(freq col) f(0c 2) clab(N %) ptotal(none)

*Observations:
*All
tabout cat_int1 dog_int1 rabbit_int1 rodent_int1 bird_int1 livestock_int1 using table1_observations_0722.txt, replace ///
c(freq col) f(0c 1) clab(N %) ptotal(single) oneway


*Continuous variables:

tabout pets_int1 using table1_cont_all_0722.txt, replace ///
c(N agebirth_m_y mean agebirth_m_y sd agebirth_m_y N) ///
clab(N Mean SD) ///
f(0c 0 1) ///
sum ptotal(none) h2(|Mother's age (years) | )

tabout cat_int1 using table1_cont_cat_0722.txt, replace ///
c(N agebirth_m_y mean agebirth_m_y sd agebirth_m_y N) ///
clab(N Mean SD) ///
f(0c 0 1) ///
sum ptotal(none) h2(|Mother's age (years) | )

tabout dog_int1 using table1_cont_dog_0722.txt, replace ///
c(N agebirth_m_y mean agebirth_m_y sd agebirth_m_y N) ///
clab(N Mean SD) ///
f(0c 0 1) ///
sum ptotal(none) h2(|Mother's age (years) | )

tabout rabbit_int1 using table1_cont_rabbit_0722.txt, replace ///
c(N agebirth_m_y mean agebirth_m_y sd agebirth_m_y N) ///
clab(N Mean SD) ///
f(0c 0 1) ///
sum ptotal(none) h2(|Mother's age (years) | )

tabout rodent_int1 using table1_cont_rodent_0722.txt, replace ///
c(N agebirth_m_y mean agebirth_m_y sd agebirth_m_y N) ///
clab(N Mean SD) ///
f(0c 0 1) ///
sum ptotal(none) h2(|Mother's age (years) | )

tabout exotic_int1 using table1_cont_exotic_0722.txt, replace ///
c(N agebirth_m_y mean agebirth_m_y sd agebirth_m_y N) ///
clab(N Mean SD) ///
f(0c 0 1) ///
sum ptotal(none) h2(|Mother's age (years) | )

tabout bird_int1 using table1_cont_bird_0722.txt, replace ///
c(N agebirth_m_y mean agebirth_m_y sd agebirth_m_y N) ///
clab(N Mean SD) ///
f(0c 0 1) ///
sum ptotal(none) h2(|Mother's age (years) | )

tabout livestock_int1 using table1_cont_livestock_0722.txt, replace ///
c(N agebirth_m_y mean agebirth_m_y sd agebirth_m_y N) ///
clab(N Mean SD) ///
f(0c 0 1) ///
sum ptotal(none) h2(|Mother's age (years) | )
