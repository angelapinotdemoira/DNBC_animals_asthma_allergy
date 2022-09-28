*Creating new variables for rabbit, rodent and other furry*
*Angela Pinot de Moira
*23 March 2022
***********************************************************

*rabbit_int1
*Create farm variable:
gen rabbit_farm = 0 if a201==1| a201==2
replace rabbit_farm=1 if inlist(a202a_str, 14, 15, 32, 33, 34, 35, 65, ///
73, 76, 87, 96, 97, 98, 123, 124, 129, 135, 144, 151, 156, 184, 185, 186, 187, ///
188, 189, 190, 191, 192, 193, 194, 198, 199, 200, 205, 209, 212, ///
213, 252, 279, 280) 
replace rabbit_farm=0 if a202_7==0 & rabbit_farm==.

*Create occupation variable:
gen rabbit_occ = 1 if  inlist(am105a_str,13,15,18,20,38,39,44, ///
51,53,59,65,69,74,75,77,78,79,80)
replace rabbit_occ = 0 if rabbit_occ==. & inrange(a159,1,4)
replace rabbit_occ = 0 if a162==4 // mothers who have not worked for 4-6 months

*Create final variable:
gen rabbit_int1 = 1 if rabbit_preg==1 | rabbit_farm==1 | rabbit_occ==1 
replace rabbit_int1=0 if rabbit_preg==0 & rabbit_farm==0 & rabbit_occ==0 

*Create rabbit_source variable:
*label define source2 0 "no exposure" 1 "home (pet)" 2 "other" 
gen rabbit_source = 0 if rabbit_preg==0 &  rabbit_farm==0 & rabbit_occ==0
replace rabbit_source = 1 if rabbit_preg==1   
replace rabbit_source = 2 if rabbit_preg==0 &  (rabbit_farm==1 | rabbit_occ==1) 
la val rabbit_source "source2" 

***********************************************************************

*rodent_int1
*Create farm variable:
gen rodent_farm = 0 if a201==1| a201==2
replace rodent_farm=1 if inlist(a202a_str, 8, 54, 55, 59, 217, 245, 246) 
replace rodent_farm=0 if a202_7==0 & rodent_farm==.

*Create occupation variable:
gen rodent_occ = 1 if  am101_5==1 | am105_5==1 | am095_8==1 ///
| inlist(am105a_str,6,13,15,18,20,22,37,39,44,51,57,58,65,66,68,69,74,77,78,79,80)
replace rodent_occ = 0 if rodent_occ==. & inrange(a159,1,4)
replace rodent_occ = 0 if a162==4 // mothers who have not worked for 4-6 months

*Create final variable:
gen rodent_int1 = 1 if rodent_preg==1 | rodent_farm==1 | rodent_occ==1 
replace rodent_int1=0 if rodent_preg==0 & rodent_farm==0 & rodent_occ==0 

*Create rabbit_source variable:
gen rodent_source = 0 if rodent_preg==0 &  rodent_farm==0 & rodent_occ==0
replace rodent_source = 1 if rodent_preg==1   
replace rodent_source = 2 if rodent_preg==0 &  (rodent_farm==1 | rodent_occ==1) 
la val rodent_source "source2" 


***********************************************************************
*exotic_furry_int1
*Create farm variable:
gen exotic_farm = 0 if a201==1| a201==2
replace exotic_farm=1 if inlist(a202a_str, 42, 89, 225, 228, 231, 232, ///
233, 234, 235, 236, 269) 
replace exotic_farm=0 if a202_7==0 & exotic_farm==.

*Create occupation variable:
gen exotic_occ = 1 if inlist(am105a_str,46,59,64,67,71,75) | ///
am104a_str==38 | inlist(am095b_str, 10) | zoo_o_current2==1 
replace exotic_occ = 0 if exotic_occ==. & inrange(a159,1,4)
replace exotic_occ = 0 if a162==4 // mothers who have not worked for 4-6 months

*Create final variable:
gen exotic_int1 = 1 if other_furry_preg==1 | exotic_farm==1 | exotic_occ==1 
replace exotic_int1=0 if other_furry_preg==0 & exotic_farm==0 & exotic_occ==0 

*Create rabbit_source variable:
gen exotic_source = 0 if other_furry_preg==0 &  exotic_farm==0 & exotic_occ==0
replace exotic_source = 1 if other_furry_preg==1   
replace exotic_source = 2 if other_furry_preg==0 &  (exotic_farm==1 | exotic_occ==1) 
la val exotic_source "source2" 


**********************************************************************
*Timing of exposure

label define ownership 0 "no ownership" 1 "pregnancy only" 2 "early-life only" 3 "pregnancy and early-life"

*rabbit
gen rabbit = 0 if rabbit_int1==0 & ///
rabbit_int4==0 
replace rabbit = 1 if (rabbit_int1==1) & ///
(rabbit_int4==0 )
replace rabbit = 2 if (rabbit_int1==0) & ///
(rabbit_int4==1 )
replace rabbit = 3 if rabbit_int1==1 & ///
(rabbit_int4==1 )

*rodent
gen rodent = 0 if rodent_int1==0 & ///
rodent_int4==0 
replace rodent = 1 if (rodent_int1==1) & ///
(rodent_int4==0 )
replace rodent = 2 if (rodent_int1==0) & ///
(rodent_int4==1 )
replace rodent = 3 if rodent_int1==1 & ///
(rodent_int4==1 )

*exotic
gen exotic = 0 if exotic_int1==0 & ///
other_furry_int4==0 
replace exotic = 1 if (exotic_int1==1) & ///
(other_furry_int4==0 )
replace exotic = 2 if (exotic_int1==0) & ///
(other_furry_int4==1 )
replace exotic = 3 if exotic_int1==1 & ///
(other_furry_int4==1 )

*Create a bird variable (commented out of "animal exposure" file)

*Birds
gen bird= 0 if bird_int1==0 & bird_int4==0
replace bird = 1 if bird_int1==1 & bird_int4==0
replace bird=2 if bird_int1==0 & bird_int4==1
replace bird=3 if bird_int1==1 & bird_int4==1
label values bird ownership





