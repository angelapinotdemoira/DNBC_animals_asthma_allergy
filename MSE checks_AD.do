*Atopic dermatitis diagnostics
*Angela Pinot de Moira
*July 2022
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

keep if AD!=. 
drop if migration_m==1 //n=166 excludes mothers who emigrated before birth
drop if inlist(migration,1,2) //n=91 excludes children who emigrated before birth or who immigrated after birth

*create date of 13th birthday:
gen day = day(eventda)
replace day=28 if day(eventda)==29 & month(eventda)==2
gen month = month(eventda)
gen year = (year(eventda)) + 13
gen bday_13 = mdy(month,day,year)
format bday_13 %d

*

egen outdate = rowmin(AD_date doddato migration_date bday_13)
format outdate %d
format AD_date %d

gen AD_cox = AD
replace AD_cox =0 if AD_date>outdate & AD_date!=.

stset outdate, failure(AD_cox==1) origin(eventda) enter(eventda) ///
scale(365.25) id(lbgravff) exit(time eventda + 365.25*13)

*drop multiples:
keep if flerfold==1

********************************************************************************
///Use reported parental history of allergy:
drop family_allergy_asthma family_allergy_asthma2 rhinitis_p_reg ///
asthma_p_reg asthma_m_reg rhinitis_m_reg
egen family_allergy_asthma = rowmax(asthma_bf asthma_m allergy_f allergy_inh_m)
recode family_allergy_asthma 0=1 1=0, gen(family_allergy_asthma2) //for interactions
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
summ AD_cox cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 rhinitis_p_reg asthma_p_reg asthma_m_reg rhinitis_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat children_cat parity_m ///
agebirth_m_y preg_smk copenhagen nursery antibiotics miss


********************************************************************************
********************************************************************************

cd "D:\Data\workdata\707796\Results\Diagnostics" 

foreach var of varlist AD_cox cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 asthma_p_reg asthma_m_reg ///
mat_ed_3cat hhincome_cat crowding_cat parity_m ///
agebirth_m_y  copenhagen sex children_cat  ///
preg_smk rhinitis_m_reg rhinitis_p_reg {
if "`var'"=="AD_cox" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) 
est store AD_`var'
} 
if "`var'"=="cat_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
} 
else if "`var'"=="dog_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
else if "`var'"=="rabbit_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) 
est store AD_`var'
}
if "`var'"=="rodent_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="exotic_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}

if "`var'"=="bird_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1  ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) 
est store AD_`var'
}
if "`var'"=="livestock_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="asthma_p_reg" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg  i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="asthma_m_reg" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg  ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="mat_ed_3cat" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg )
est store AD_`var'
}
if "`var'"=="hhincome_cat" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
  i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="crowding_cat" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) 
est store AD_`var'
}
if "`var'"=="parity_m" {
display `var'
char mat_ed_3cat[omit] 2
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="agebirth_m_y" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
 i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) 
est store AD_`var'
}
if "`var'"=="copenhagen" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y  if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="sex" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="children_cat" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="preg_smk" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex i.rhinitis_m_reg ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="rhinitis_m_reg" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk  ///
i.mat_ed_3cat)
est store AD_`var'
}
if "`var'"=="rhinitis_p_reg" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
agebirth_m_y i.copenhagen if miss==0, nohr strata(sex preg_smk i.rhinitis_m_reg ///
i.mat_ed_3cat) 
est store AD_`var'
}
}


esttab AD_AD_cox AD_cat_int1 AD_dog_int1 AD_rabbit_int1 ///
AD_rodent_int1 AD_exotic_int1 AD_bird_int1 ///
AD_livestock_int1 AD_asthma_p_reg AD_asthma_m_reg ///
AD_mat_ed_3cat AD_hhincome_cat AD_crowding_cat AD_parity_m ///
AD_agebirth_m_y  AD_copenhagen AD_sex AD_children_cat  ///
AD_preg_smk AD_rhinitis_m_reg AD_rhinitis_p_reg ///
using AD_diagnostics, /// 
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


*******************************************************************************
*Step two - now remove relevant variables:

foreach var of varlist AD_cox  dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 asthma_p_reg asthma_m_reg ///
 hhincome_cat crowding_cat parity_m ///
   sex children_cat  ///
 rhinitis_m_reg rhinitis_p_reg {
if "`var'"=="AD_cox" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
) 
est store AD_`var'
} 
else if "`var'"=="dog_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
)
est store AD_`var'
}
else if "`var'"=="rabbit_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
) 
est store AD_`var'
}
if "`var'"=="rodent_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
)
est store AD_`var'
}
if "`var'"=="exotic_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
)
est store AD_`var'
}

if "`var'"=="bird_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1  ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
) 
est store AD_`var'
}
if "`var'"=="livestock_int1" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
)
est store AD_`var'
}
if "`var'"=="asthma_p_reg" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg  i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
)
est store AD_`var'
}
if "`var'"=="asthma_m_reg" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg  ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
)
est store AD_`var'
}
if "`var'"=="hhincome_cat" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
  i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
)
est store AD_`var'
}
if "`var'"=="crowding_cat" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
) 
est store AD_`var'
}
if "`var'"=="parity_m" {
display `var'
char mat_ed_3cat[omit] 2
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat  ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
)
est store AD_`var'
}
if "`var'"=="sex" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata( i.rhinitis_m_reg ///
)
est store AD_`var'
}
if "`var'"=="children_cat" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
)
est store AD_`var'
}
if "`var'"=="rhinitis_m_reg" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.rhinitis_p_reg i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex   ///
)
est store AD_`var'
}
if "`var'"=="rhinitis_p_reg" {
display `var'
*char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
*Adjusted 1:
xi: stcox  i.dog_int1 i.rabbit_int1 i.rodent_int1 i.exotic_int1 i.bird_int1 ///
i.livestock_int1 i.asthma_p_reg i.asthma_m_reg ///
 i.hhincome_cat i.crowding_cat i.children_cat i.parity_m ///
  if miss==0, nohr strata(sex  i.rhinitis_m_reg ///
) 
est store AD_`var'
}
}


esttab AD_AD_cox AD_dog_int1 AD_rabbit_int1 ///
AD_rodent_int1 AD_exotic_int1 AD_bird_int1 ///
AD_livestock_int1 AD_asthma_p_reg AD_asthma_m_reg ///
 AD_hhincome_cat AD_crowding_cat AD_parity_m ///
  AD_sex AD_children_cat  ///
 AD_rhinitis_m_reg AD_rhinitis_p_reg ///
using AD_diagnostics, /// 
 b(%12.6fc) se(%12.6fc) tab ///
mtitles ("Nothing" ///
"Minus dog" "Minus rabbit" ///
"Minus rodent" ///
"Minus exotic" "Minus bird" ///
"Minus livestock" "Minus asthma_p" ///
"Minus asthma_m" ///
"Minus hh income" "Minus crowding" ///
"Minus parity"  ///
 "Minus sex" ///
"Minus children cat"  ///
"Minus rhinitis_m" "Minus rhinits_p") ///
nostar noisily replace








