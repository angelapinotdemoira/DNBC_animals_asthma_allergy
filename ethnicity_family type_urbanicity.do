********************************************************************************
*Angela Pinot de Moira
*Creating ethnicity and single mother variables
*20 Jan 2021
********************************************************************************

********************************************************************************
*Announce directories:

global dnbc "D:\Data\workdata\707796\uploaded data"
global bef "D:\Data\workdata\707796\BEF"


*********************************************************************************
*For mothers:

use lbgravff eventda bcpr mcpr flerfold outcome using "$dnbc\DNBC_data.dta", clear


label drop _all // this prevents the labels in BEF taking the labels in MFR

*Merge mothers with BEF to obtain family id:
gen pnr = mcpr // merge using mother's cpr
gen year = year(eventda) //create a year variable for each child to merge on

merge m:1 pnr year using $bef\BEF_1990-2011.dta
drop if _merge==2 // n=102,522
rename _merge bef_merge
drop pnr

********************************************************************************
/*Single mother and family type

Hustype:

1= single man
2= single woman
3 = maried couple
4 = other couples
5 = non resident children (under 18)
6 = households consisting of several families

*/
drop __*
 
recode hustype 1/2=1 3/4=0 5=1 6=0, gen(single_woman)

recode hustype (1/2=2 "single") (3/4=1 "couple") (5=2 "single") (6 =3 "multiple families"), ///
gen(family_type)

********************************************************************************
/* Ethnicity

1 = persons or Danish origin
2 = born in Denmark but neither parent is both a Danish citizen and born in Denmark.
	If there is no information about either of the parents and the person is a foreign
	citizen (but born in Denmark?), the person is classified in this group
3 = not born in Denmark. niether of the parents are both Danish citizens and born in Denmark.
	If there is no information about either parent and the person was born abroad, the
	person is classified in this group
	
*/

recode ie_type (1=1 "Danish origin") (2/3=2 "Non-Danish origin"), gen(ethnicity_m)

********************************************************************************
*Urbanicity

gen urbanicity = 1 if inlist(kom,101,147,157)
replace urbanicity = 2 if inrange(kom,151,155) | inrange(kom,159,208) ///
						| inlist(kom,223,227,253,269)
replace urbanicity = 3 if inlist(kom,461,751,851)
replace urbanicity = 4 if inlist(kom,209,211,217,219,259,265,313,315,323,325,329, ///
333,367,369,373,400,445,449,479,515,537,545,561,573,607,615,621,631,657,661,663, ///
671,707,731,743,745,779,787,791,805,813,821,823,841,407) 
replace urbanicity = 5 if kom!=. & urbanicity==. & bef_merge==3

label define urban 1 "Copenhagen" 2 "Copenhagen suburbs" 3 "provincial cities" ///
					4 "provincial towns" 5 "rural areas"
label values urbanicity urban

********************************************************************************
*Copenhagen variable

gen copenhagen = 1 if kom==101
replace copenhagen=0 if kom!=1 & bef_merge==3

********************************************************************************
keep lbgravff reg urbanicity ethnicity_m family_type single_woman copenhagen

tempfile mother
save `mother'

********************************************************************************
*Father's ethnicity

use lbgravff cpr_fader eventda using "D:\Data\workdata\707796\analysis_data.dta", clear

label drop _all // this prevents the labels in BEF taking the labels in MFR

*Merge mothers with BEF to obtain family id:
gen pnr = cpr_fader // merge using mother's cpr

joinby pnr using $bef\BEF_1990-2011.dta, unmatched(master)


collapse (min) ie_type, by(cpr_fader lbgravff)

recode ie_type (1=1 "Danish origin") (2/3=2 "Non-Danish origin"), gen(ethnicity_p)

keep lbgravff ethnicity_p
