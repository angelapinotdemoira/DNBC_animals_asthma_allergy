/*
Angela Pinot de Moira
Atopic dermatitis outcome variable - version 2
4th February 2021
*/

********************************************************************************

*Announce directories:

global lprdiag "D:\Data\workdata\707796\LPRDIAG"
global dnbc "D:\Data\workdata\707796\uploaded data"


********************************************************************************
*Merge with lpr data

clear all

use eventda lbgravff bcpr flerfold flernr outcome using "$dnbc\DNBC_data.dta"

by bcpr, sort: gen n=_N
keep if n==1 
drop n

gen pnr=bcpr

merge 1:m pnr using "$lprdiag\merged_lpradm_lprdiag_1995-2018.dta", keepusing (pnr recnum d_inddto d_uddto c_adiag c_diag c_diagtype c_tildiag)
drop if _merge==2 // denominator based on all live births in DNBC
*keep if _merge==3 // denominator based on all live births in lpr from DNBC
drop _merge

/*
tempvar dup n
unab vlist: _all //place all variables in the current dataset in the local macro vlist
summ `vlist'
by `vlist', sort: gen `dup'=_n
tab `dup' // there are no duplicates
*/


*****************************************************
/*Atopic dermatitis

CRITERIA 1 (based on ICD-10)
>=1 hospital contact for:
L20 "atopic dermatitis"

*/

********************************************************************************

//Create hospital episode variables:

***********Atopic dermatitis****************************

gen AD = 1 if regexm(c_diag,"^DL20") 

*Create an in (start) date
gen AD_date = d_inddto if AD==1
format AD_date %d
*******************************************************************************
*Collapse the dataset:

collapse (max) AD (min) AD_date, by(pnr)

*******************************************************************************
************************************************************************
/*Merge with DNBC data:
tempfile ad
save `ad'

use "$dnbc\DNBC_data.dta", clear

gen pnr=bcpr

merge 1:1 pnr using `ad', keepusing (AD AD_date)
drop if _merge==2
rename _merge merge_ad

*/
