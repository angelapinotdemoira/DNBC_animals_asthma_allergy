*Asthma analysis
*Angela Pinot de Moira
*18 Feb 2021
***************************
*Open data and create additional variables:

cd "D:\Data\workdata\707796\Results"

use "D:\Data\workdata\707796\analysis_data.dta", clear

*Parity
recode parity_m 1/4=1

*Mode of delivery
recode mode_delivery 1/2=0 3/5=1, gen(c_section)

*Household size
run  "D:\Data\workdata\707796\Do files\hh size.do" 

*Source of animal exposure
run "D:\Data\workdata\707796\Do files\animal_source.do"

*Rabbit, rodent and exotic variables:

run "D:\Data\workdata\707796\Do files\new rabbit, rodents and other_furry variables.do"


********************************************************************************
*Setup data

keep if asthma!=. 
drop if inlist(migration6,1,2) //n=1,393 excludes children who emigrated before 6th birthday
drop if doddato< bday_6 & !mi(bday_6) //501 children died before 6th birthday

*create date of 13th birthday:
gen day = day(eventda)
replace day=28 if day(eventda)==29 & month(eventda)==2
gen month = month(eventda)
gen year = (year(eventda)) + 13
gen bday_13 = mdy(month,day,year)
format bday_13 %d

*

egen outdate = rowmin(asthma_date doddato migration_date6 bday_13)
format outdate %d
format asthma_date %d

gen asthma_cox = asthma
replace asthma_cox =0 if asthma_date>outdate & asthma_date!=.

 gen start_date=bday_6 - 1
*stset timeout, failure(asthma_cox==1) origin(eventda) enter(bday_6) scale(365.25) id(lbgravff)

stset outdate, failure(asthma_cox==1) origin(eventda) enter(start_date) ///
scale(365.25) id(lbgravff) exit(time bday_6 + 365.25*7)

*drop multiples:
keep if flerfold==1

********************************************************************************
*Use reported parental history of allergy:

drop family_allergy_asthma family_allergy_asthma2 rhinitis_p_reg ///
asthma_p_reg asthma_m_reg rhinitis_m_reg
egen family_allergy_asthma = rowmax(asthma_bf asthma_m allergy_f allergy_inh_m)
recode family_allergy_asthma 0=1 1=0, gen(family_allergy_asthma2)
gen rhinitis_p_reg = allergy_f
gen asthma_p_reg = asthma_bf
gen asthma_m_reg = asthma_m
gen rhinitis_m_reg = allergy_inh_m


********************************************************************************
*Create a variable to indicate missingness (to identify study population):

egen miss = rowmiss(cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 rhinitis_p_reg asthma_p_reg asthma_m_reg rhinitis_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat children_cat parity_m ///
agebirth_m_y preg_smk copenhagen sex)

recode miss 0=0 1/max=1

*Check missingness:
summ asthma_cox cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 rhinitis_p_reg asthma_p_reg asthma_m_reg rhinitis_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat children_cat parity_m ///
agebirth_m_y preg_smk copenhagen  antibiotics sex miss



*******************************************************************************
*******************************************************************************

cd "D:\Data\workdata\707796\Results\Diagnostics" 

foreach var of varlist asthma_cox cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 asthma_p_reg asthma_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat parity_m ///
agebirth_m_y  copenhagen sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg {
if "`var'"=="asthma_cox" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
} 
if "`var'"=="cat_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
} 
else if "`var'"=="dog_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1  i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
else if "`var'"=="rabbit_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="rodent_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="exotic_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}

if "`var'"=="bird_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1  ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="livestock_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="asthma_p_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="asthma_m_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="mat_ed_3cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="hhincome_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="crowding_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="parity_m" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="agebirth_m_y" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
 i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="copenhagen" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex) 
est store asthma_`var'
}
if "`var'"=="sex" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(copenhagen) 
est store asthma_`var'
}
if "`var'"=="children_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="preg_smk" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="rhinitis_m_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="rhinitis_p_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
}


esttab asthma_asthma_cox asthma_cat_int1 asthma_dog_int1 asthma_rabbit_int1 ///
asthma_rodent_int1 asthma_exotic_int1 asthma_bird_int1 ///
asthma_livestock_int1 asthma_asthma_p_reg asthma_asthma_m_reg ///
asthma_mat_ed_3cat asthma_hhincome_cat asthma_crowding_cat asthma_parity_m ///
asthma_agebirth_m_y  asthma_copenhagen asthma_sex asthma_children_cat  ///
asthma_preg_smk asthma_rhinitis_m_reg asthma_rhinitis_p_reg ///
using asthma_diagnostics, /// 
 b(%12.6fc) se(%12.6fc) tab ///
mtitles ("Nothing" "Minus cat" ///
"Minus dog" "Minus rabbit" ///
"Minus rodent" ///
"Minus exotic" "Minus bird" ///
"Minus livestock" "Minus asthma_p" ///
"Minus asthma_m" "Minus mat ed" ///
"Minus hh income" "Minus crowding" ///
"Minus parity" "Minus agebirth" ///
"Minus copenhagen" "Minus sex" ///
"Minus children cat" "Minus preg smk" ///
"Minus rhinitis_m" "Minus rhinits_p") ///
nostar noisily replace


*****************************************************************
*Step 2 - remove relevant covariates:

cd "D:\Data\workdata\707796\Results\Diagnostics" 


foreach var of varlist asthma_cox cat_int1 dog_int1 rabbit_int1  exotic_int1 bird_int1 ///
 asthma_p_reg asthma_m_reg ///
 hhincome_cat crowding_cat parity_m ///
agebirth_m_y  copenhagen sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg {
if "`var'"=="asthma_cox" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
} 
if "`var'"=="cat_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
} 
else if "`var'"=="dog_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1  i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
else if "`var'"=="rabbit_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="exotic_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}

if "`var'"=="bird_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1  ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="asthma_p_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="asthma_m_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="hhincome_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="crowding_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="parity_m" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="agebirth_m_y" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
 i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="copenhagen" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex) 
est store asthma_`var'
}
if "`var'"=="sex" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(copenhagen) 
est store asthma_`var'
}
if "`var'"=="children_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="preg_smk" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="rhinitis_m_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
if "`var'"=="rhinitis_p_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
 i.asthma_p_reg i.asthma_m_reg i.rhinitis_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.preg_smk  if miss==0,  nohr strata(sex copenhagen) 
est store asthma_`var'
}
}


esttab asthma_asthma_cox asthma_cat_int1 asthma_dog_int1 asthma_rabbit_int1 ///
 asthma_exotic_int1 asthma_bird_int1 ///
 asthma_asthma_p_reg asthma_asthma_m_reg ///
 asthma_hhincome_cat asthma_crowding_cat asthma_parity_m ///
asthma_agebirth_m_y  asthma_copenhagen asthma_sex asthma_children_cat  ///
asthma_preg_smk asthma_rhinitis_m_reg asthma_rhinitis_p_reg ///
using asthma_diagnostics, /// 
 b(%12.6fc) se(%12.6fc) tab ///
mtitles ("Nothing" "Minus cat" ///
"Minus dog" "Minus rabbit" ///
"Minus exotic" "Minus bird" ///
 "Minus asthma_p" ///
"Minus asthma_m" ///
"Minus hh income" "Minus crowding" ///
"Minus parity" "Minus agebirth" ///
"Minus copenhagen" "Minus sex" ///
"Minus children cat" "Minus preg smk" ///
"Minus rhinitis_m" "Minus rhinits_p") ///
nostar noisily replace
