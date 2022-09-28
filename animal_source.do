*Angela Pinot de Moira
*Defining source of animal exposure
*22 Feb 2021
********************************************************************************

*******************************************************************************
*Restricting to home exposure (excluding farm and occupational exposure)
*Create a new livestock variable which restricts to farm and home exposure

gen pet_dog = dog_preg

gen pet_cat = cat_preg

gen pet_otherfurry = 0 if other_furry_preg==0 ///
& rabbit_preg==0 & rodent_preg==0
replace pet_otherfurry = 1 if  other_furry_preg==1 | rabbit_preg==1 | rodent_preg==1 
 
gen pet_bird =bird_preg

gen farm_home_livestock=1 if  sheep_f==1 | deer_f==1 | ///
 pigs_f==1 | cattle_f==1 | cattle_preg==1 | equine_preg==1 | equine_f==1
replace farm_home_livestock=0 if sheep_f==0 & deer_f==0 &  ///
 pigs_f==0 &  cattle_f==0 &  cattle_preg==0 &  equine_preg==0 &  equine_f==0 

 
 /////////////////
 *Generate variables which include "other sources"
 


*Source of exposure
gen otherfurry_int1  = other_furry_int1
gen pet_livestock = farm_home_livestock
label define source2 0 "no exposure" 1 "home (pet)" 2 "other" 
foreach var in cat dog otherfurry bird livestock {
gen `var'_source = 0 if pet_`var'==0 & `var'_int1==0
replace `var'_source = 1 if pet_`var'==1 & `var'_int1==1
replace `var'_source = 2 if pet_`var'==0 & `var'_int1==1
la val `var'_source "source2"
 }
drop otherfurry_int1 pet_livestock
