*Allergic rhinitis analysis_from age 6
*Angela Pinot de Moira
*18 Feb 2021
***************************
*Open data and create additional variables:


run "D:\Data\workdata\707796\Do files\allergic rhinitis_from age6.do" 

merge 1:m pnr using "D:\Data\workdata\707796\analysis_data.dta"
recode rhinitis6 .=0 if _merge==3 & outcome==1
drop _merge // merge is the same as merge_ad
*Parity
recode parity_m 1/4=1

*Mode of delivery
recode mode_delivery 1/2=0 3/5=1, gen(c_section)

*Household size
run  "D:\Data\workdata\707796\Do files\hh size.do" 

*Source of animal exposure
run "D:\Data\workdata\707796\Do files\animal_source.do"

cd "D:\Data\workdata\707796\Results"

*Rabbit, rodent and exotic variables:

run "D:\Data\workdata\707796\Do files\new rabbit, rodents and other_furry variables.do"



********************************************************************************
*Setup data

keep if rhinitis6!=. 
drop if inlist(migration6,1,2) //n=1,393 excludes children who emigrated before 6th birthday
drop if doddato< bday_6 & !mi(bday_6) //501 children died before 6th birthday

*create date of 13th birthday:
gen day = day(eventda)
replace day=28 if day(eventda)==29 & month(eventda)==2
gen month = month(eventda)
gen year = (year(eventda)) + 13
gen bday_13 = mdy(month,day,year)
format bday_13 %d
*/
/**create date of 16th birthday (instead of 13th as per original script):
gen day = day(eventda)
replace day=28 if day(eventda)==29 & month(eventda)==2
gen month = month(eventda)
gen year = (year(eventda)) + 16
gen bday_16 = mdy(month,day,year)
format bday_16 %d
*/

egen outdate = rowmin(rhinitis6_date doddato migration_date6 bday_13) //13th birthday
*egen outdate = rowmin(rhinitis6_date doddato migration_date6 bday_16)
format outdate %d
format rhinitis6_date %d

gen rhinitis6_cox = rhinitis6
replace rhinitis6_cox =0 if rhinitis6_date>outdate & rhinitis6_date!=.

gen start_date=bday_6 - 1

stset outdate, failure(rhinitis6_cox==1) origin(eventda) enter(start_date) ///
scale(365.25) id(lbgravff) exit(time eventda + 365.25*13)

*drop multiples:
keep if flerfold==1

********************************************************************************
///To use reported parental history of allergy:
drop family_allergy_asthma family_allergy_asthma2 rhinitis_p_reg ///
asthma_p_reg asthma_m_reg rhinitis_m_reg
egen family_allergy_asthma = rowmax(asthma_bf asthma_m allergy_f allergy_inh_m)
recode family_allergy_asthma 0=1 1=0, gen(family_allergy_asthma2)
gen rhinitis_p_reg = allergy_f
gen asthma_p_reg = asthma_bf
gen asthma_m_reg = asthma_m
gen rhinitis_m_reg = allergy_inh_m
//


********************************************************************************
*Create a variable to indicate missing values (to identify study population):
egen miss = rowmiss(cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 rhinitis_p_reg asthma_p_reg asthma_m_reg rhinitis_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat children_cat parity_m ///
agebirth_m_y preg_smk copenhagen)

recode miss 0=0 1/max=1

*Check missingness:
summ rhinitis6 cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 rhinitis_p_reg asthma_p_reg asthma_m_reg rhinitis_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat children_cat parity_m ///
agebirth_m_y preg_smk copenhagen  antibiotics miss

********************************************************************************
*LOOP

**)First loop:

cd "D:\Data\workdata\707796\Results\Diagnostics" 

foreach var of varlist rhinitis6_cox cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 asthma_p_reg asthma_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat parity_m ///
agebirth_m_y  copenhagen sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg {
if "`var'"=="rhinitis6_cox" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
} 
if "`var'"=="cat_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
} 
else if "`var'"=="dog_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg)
est store AR_`var'
}
else if "`var'"=="rabbit_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg)
est store AR_`var'
}
if "`var'"=="rodent_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1  i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="exotic_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}

if "`var'"=="bird_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1  ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="livestock_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="asthma_p_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1  i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="asthma_m_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg  ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="mat_ed_3cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="hhincome_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="crowding_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="parity_m" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat  ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="agebirth_m_y" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="copenhagen" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="sex" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata( children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="children_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex   ///
preg_smk rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="preg_smk" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="rhinitis_m_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk  rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="rhinitis_p_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
preg_smk rhinitis_m_reg ) 
est store AR_`var'
}
}


esttab AR_rhinitis6_cox AR_cat_int1 AR_dog_int1 AR_rabbit_int1 ///
AR_rodent_int1 AR_exotic_int1 AR_bird_int1 ///
AR_livestock_int1 AR_asthma_p_reg AR_asthma_m_reg ///
AR_mat_ed_3cat AR_hhincome_cat AR_crowding_cat AR_parity_m ///
AR_agebirth_m_y  AR_copenhagen AR_sex AR_children_cat  ///
AR_preg_smk AR_rhinitis_m_reg AR_rhinitis_p_reg ///
using rhinitis_diagnostics, /// 
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



**)Second loop (delete variables as appropriate):

cd "D:\Data\workdata\707796\Results\Diagnostics" 


foreach var of varlist rhinitis6_cox cat_int1 dog_int1 rabbit_int1   bird_int1 ///
livestock_int1 asthma_p_reg asthma_m_reg ///
mat_ed_3cat  parity_m ///
agebirth_m_y  copenhagen sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg {
if "`var'"=="rhinitis6_cox" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
} 
if "`var'"=="cat_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
} 
else if "`var'"=="dog_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg)
est store AR_`var'
}
else if "`var'"=="rabbit_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg)
est store AR_`var'
}
if "`var'"=="bird_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1    ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="livestock_int1" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="asthma_p_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1  i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="asthma_m_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg  ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="mat_ed_3cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="parity_m" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat   ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="agebirth_m_y" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="copenhagen" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="sex" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata( children_cat  ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="children_cat" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex   ///
 rhinitis_m_reg rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="rhinitis_m_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
  rhinitis_p_reg) 
est store AR_`var'
}
if "`var'"=="rhinitis_p_reg" {
display `var'
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1   i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
i.mat_ed_3cat  i.parity_m ///
agebirth_m_y  i.copenhagen  if miss==0, nohr strata(sex children_cat  ///
 rhinitis_m_reg ) 
est store AR_`var'
}
}


esttab AR_rhinitis6_cox AR_cat_int1 AR_dog_int1 AR_rabbit_int1 ///
  AR_bird_int1 ///
AR_livestock_int1 AR_asthma_p_reg AR_asthma_m_reg ///
AR_mat_ed_3cat AR_parity_m ///
AR_agebirth_m_y  AR_copenhagen AR_sex AR_children_cat  ///
 AR_rhinitis_m_reg AR_rhinitis_p_reg ///
using rhinitis_diagnostics, /// 
 b(%12.6fc) se(%12.6fc) tab ///
mtitles ("Nothing" "Minus cat" ///
"Minus dog" "Minus rabbit" ///
 "Minus bird" ///
"Minus livestock" "Minus asthma_p" ///
"Minus asthma_m" "Minus mat ed" ///
"Minus parity" "Minus agebirth" ///
"Minus copenhagen" "Minus sex" ///
"Minus children cat"  ///
"Minus rhinitis_m" "Minus rhinits_p") ///
nostar noisily replace




