********************************************************************************
*Angela Pinot de Moira
*Creating variables to establish migration status
*16 Feb 2021
********************************************************************************

*Announce directories:

global dnbc "D:\Data\workdata\707796\uploaded data"
global inout "D:\Data\workdata\707796\VNDS_DOD"


*******************************************************************************
*Mother's migration
*********************************

use "$dnbc\DNBC_data.dta", clear

gen pnr=mcpr
keep pnr lbgravff eventda i1_dato 

joinby pnr using "$inout\vnds_2018.dta", unmatched(master)

//create status at birth

*Create a variable which indicates whether each time is a start or end date
gen inout = 1 if indud_kode=="U"
replace inout =-1 if indud_kode=="I"
by lbgravff (haend_dato), sort: gen n=_n
replace inout = 0 if n==1 & indud_kode=="I"
drop n

*Create a status variable for each individual
gsort lbgravff haend_dato -inout
by lbgravff: gen status = sum(inout) 

*Create status at birth which is the nearest event to birth before birth
gen diff = eventda - haend_dato if haend_dato<=eventda & haend_dato!=. & eventda!=.
by lbgravff, sort: egen min_diff = min(diff)
gen status_birth = status if min_diff==diff & diff!=. & min_diff!=.

//create stauts after birth

gen n = 1 if  haend_dato>eventda & haend_dato!=. & eventda!=. // identifies observations after birth
by lbgravff n (haend_dato), sort: gen n2=_n if haend_dato>eventda & haend_dato!=. & eventda!=.

//create migration variable

by lbgravff, sort: egen migration_m = max(status_birth) // 0=no migration 1=migrated before birth
recode migration_m -1=0
replace migration_m = 2 if inlist(migration,.,0) & n2==1 & indud_kode=="I" // immigrated after birth
replace migration_m = 3 if inlist(migration,0,.) & n2==1 & indud_kode=="U" //migrated after birth
replace migration_m = 0 if _merge==1

gen migration_m_date = haend_dato if migration==3

collapse (max) migration_m migration_m_date, by(lbgravff) 

tempfile migration_m
save `migration_m'


********************************************************************************
*Child's migration
*********************************

use "$dnbc\DNBC_data.dta", clear

gen pnr=bcpr
keep pnr lbgravff eventda 

by pnr, sort: gen n=_N
keep if n==1 
drop n

merge 1:m pnr using "$inout\vnds_2018.dta"
drop if _merge==2


//create status at birth

*Create a variable which indicates whether each time is a start or end date
gen inout = 1 if indud_kode=="U"
replace inout =-1 if indud_kode=="I"
by lbgravff (haend_dato), sort: gen n=_n
replace inout = 0 if n==1 & indud_kode=="I"
drop n

*Create a status variable for each individual
gsort lbgravff haend_dato -inout
by lbgravff: gen status = sum(inout) 

*Create status at birth which is the nearest event to birth before birth
gen diff = eventda - haend_dato if haend_dato<=eventda & haend_dato!=. & eventda!=.
by lbgravff, sort: egen min_diff = min(diff)
gen status_birth = status if min_diff==diff & diff!=. & min_diff!=.

//create stauts after birth

gen n = 1 if  haend_dato>eventda & haend_dato!=. & eventda!=. // identifies observations after birth
by lbgravff n (haend_dato), sort: gen n2=_n if haend_dato>eventda & haend_dato!=. & eventda!=.

//create migration variable

by lbgravff, sort: egen migration = max(status_birth) // 0=no migration 1=migrated before birth
replace migration = 2 if inlist(migration,.,0) & n2==1 & indud_kode=="I" // immigrated after birth
replace migration = 3 if inlist(migration,0,.) & n2==1 & indud_kode=="U" //migrated after birth
replace migration = 0 if _merge==1

gen migration_date = haend_dato if migration==3

drop n n2

**********************************************************************
//create status at six years:

*create date of 6th birthday:
gen day = day(eventda)
replace day=28 if day(eventda)==29 & month(eventda)==2
gen month = month(eventda)
gen year = (year(eventda)) + 6
gen bday_6 = mdy(month,day,year)
format bday_6 %d

*Create a variable which indicates whether each time is a start or end date
*see above

*Create status at 6th birthday which is the nearest event to 6th birthday before birthday
gen diff2 = bday_6 - haend_dato if haend_dato<=bday_6 & haend_dato!=. & bday_6!=.
by lbgravff, sort: egen min_diff2 = min(diff2)
gen status_6 = status if min_diff2==diff2 & diff2!=. & min_diff2!=.

//create stauts after 6th birthday

gen n = 1 if  haend_dato>bday_6 & haend_dato!=. & bday_6!=. // identifies observations after birth
by lbgravff n (haend_dato), sort: gen n2=_n if haend_dato>bday_6 & haend_dato!=. & bday_6!=.

//create migration variable

by lbgravff, sort: egen migration6 = max(status_6) // 0=no migration 1=migrated before birth
replace migration6 = 2 if inlist(migration6,.,0) & n2==1 & indud_kode=="I" // immigrated after birth
replace migration6 = 3 if inlist(migration6,0,.) & n2==1 & indud_kode=="U" //migrated after birth
replace migration6 = 0 if _merge==1

gen migration_date6 = haend_dato if migration6==3


**********************************************************************
format migration_* %d
label define migration 0 "no migration" 1 "migrated before birth(day)"  ///
2 "immigrated after birth(day)" 3 "migrated after birth(day)"

label values migration migration
label values migration6 migration
collapse (max) migration migration_date migration6 migration_date6 (mean) bday_6, by(lbgravff) 



