*Asthma sensitivity analysis
*Angela Pinot de Moira
*6th December 2021
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
*Select population:
egen miss = rowmiss(cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 ///
livestock_int1 allergy_f asthma_bf asthma_m allergy_inh_m ///
mat_ed_3cat hhincome_cat crowding_cat children_cat  ///
agebirth_m_y preg_smk copenhagen asthma_current_medall)

drop if miss!=0

**************************************************************************
*retrieve new asthma variable:
drop asthma asthma_date _merge
tempfile asthma_sensitivity
save `asthma_sensitivity'
run "D:\Data\workdata\707796\Do files\asthma_for_sensitivity_analysis.do"
merge 1:1 pnr using `asthma_sensitivity'
keep if _merge==3
drop _merge
keep if asthma!=. 

*Migration ******************************
*Include only children who didn't migrate or immigrate within the year before 7-year FU
by pnr, sort: gen n=_N
keep if n==1 
drop n

tempfile migration_sensitivity
save `migration_sensitivity'

keep pnr lbgravff eventda y7_dato

merge 1:m pnr using "$inout\vnds_2018.dta"
drop if _merge==2

*Create a variable which indicates whether each time is a start or end date
gen inout = 1 if indud_kode=="U"
replace inout =-1 if indud_kode=="I"
by lbgravff (haend_dato), sort: gen n=_n
replace inout = 0 if n==1 & indud_kode=="I"
drop n

*Create a status variable for each individual
gsort lbgravff haend_dato -inout
by lbgravff: gen status = sum(inout)

*Create status at 7-year FU minus 1 year which is the nearest event to 7-year FU minus 1 year
gen start_date= y7_dato - 365.25 // create a start date
gen diff2 = start_date - haend_dato if haend_dato<=start_date & haend_dato!=. & start_date!=.
by lbgravff, sort: egen min_diff2 = min(diff2)
gen status_7 = status if min_diff2==diff2 & diff2!=. & min_diff2!=.

//create stauts after start date (7-year FU minus 1 year)
gen n = 1 if  haend_dato>start_date & haend_dato!=. & start_date!=. // identifies observations after birth
by lbgravff n (haend_dato), sort: gen n2=_n if haend_dato>start_date & haend_dato!=. & start_date!=.

//create migration variable
by lbgravff, sort: egen migration7 = max(status_7) // 0=no migration 1=migrated before birth
replace migration7 = 2 if inlist(migration7,.,0) & n2==1 & indud_kode=="I" // immigrated after birth
replace migration7 = 3 if inlist(migration7,0,.) & n2==1 & indud_kode=="U" //migrated after birth
replace migration7 = 0 if _merge==1

gen migration_date7 = haend_dato if migration7==3

collapse (max) migration7 migration_date7, by(lbgravff) 

merge 1:1 lbgravff using `migration_sensitivity'
keep if _merge==3
drop _merge

drop if inlist(migration7,1,2) // excludes children who emigrated before start date or immigrated after
drop if migration7==3 & migration_date7<y7_dato & y7_dato!=.

drop if doddato< y7_dato & !mi(y7_dato) 


**************************

*drop multiples:
keep if flerfold==1

*identify registry cases occurring after 7-year FU:
format asthma_date %d
gen asthma_cox = asthma
replace asthma_cox =0 if asthma_date>y7_dato & asthma_date!=.

drop if y7_dato==.

********************************************************************************
*logistic regression:

*DNBC
*Unadjusted:
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 {
xi: logistic i.asthma_current_medall i.`var' if miss==0, vce(cluster mcpr)
est store `var'
}


*Adjusted 1:
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: logistic i.asthma_current_medall i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 ///
i.exotic_int1 i.bird_int1 ///
i.livestock_int1 allergy_f asthma_bf asthma_m allergy_inh_m ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk i.copenhagen i.sex if miss==0, vce(cluster mcpr)
est store adj


*Registry:
*Unadjusted:
foreach var of varlist cat_int1 dog_int1 rabbit_int1 rodent_int1 exotic_int1 bird_int1 livestock_int1 {
xi: logistic i.asthma_cox i.`var' if miss==0, vce(cluster mcpr)
est store `var'_reg
}


*Adjusted 1:
char mat_ed_3cat[omit] 2
char crowding_cat[omit] 2
xi: logistic i.asthma_cox i.cat_int1 i.dog_int1 i.rabbit_int1 i.rodent_int1 ///
i.exotic_int1 i.bird_int1 ///
i.livestock_int1 allergy_f asthma_bf asthma_m allergy_inh_m ///
i.mat_ed_3cat i.hhincome_cat i.crowding_cat i.children_cat  ///
agebirth_m_y i.preg_smk i.copenhagen i.sex if miss==0, vce(cluster mcpr)
est store adj_reg


******************************************************************************
/////Tabulate results/////

*Esttab


esttab    cat_int1 cat_int1_reg dog_int1 dog_int1_reg ///
rabbit_int1 rabbit_int1_reg ///
rodent_int1 rodent_int1_reg ///
exotic_int1 exotic_int1_reg ///
bird_int1 bird_int1_reg ///
livestock_int1 livestock_int1_reg ///
adj adj_reg ///
using sensitivity_analysis_asthma, /// 
wide eform b(2) ci(2) one tab /// 
mtitles ("Unadjusted cat HR (95% CI)_dnbc" ///
"Unadjusted cat HR (95% CI)_reg" ///
"Unadjusted dog HR (95% CI)_dnbc" ///
"Unadjusted dog HR (95% CI)_reg" ///
"Unadjusted rabbit HR (95% CI)_dnbc" ///
"Unadjusted rabbit HR (95% CI)_reg" ///
"Unadjusted rodent HR (95% CI)_dnbc" ///
"Unadjusted rodent HR (95% CI)_reg" ///
"Unadjusted exotic HR (95% CI)_dnbc" ///
"Unadjusted exotic HR (95% CI)_reg" ///
"Unadjusted bird HR (95% CI)_dnbc" ///
"Unadjusted bird HR (95% CI)_reg" ///
"Unadjusted livestock HR (95% CI)_dnbc" ///
"Unadjusted livestock HR (95% CI)_reg" ///
"Adjusted HR (95% CI)_dnbc" ///
"Adjusted HR (95% CI)_reg" ///
) noisily replace

