
clear
set more off

**************************************************************************************************************
* This do-file replicates the results in Rocha, Ferraz, and Soares "Human Capital Persistence and Development"
**************************************************************************************************************

global ps		"/Users/claudioferraz/Dropbox/Nucleos_final"  
global RepDir	"${ps}/Replication"

*************************************************************************************************************************
* TABLE 2: SUMMARY STATISTICS FOR GEOGRAPHIC CHARACTERISTICS AND FOR SOCIOECONOMIC VARIABLES BY CENSUS YEAR
*************************************************************************************************************************

use "$RepDir/RochaFerrazSoares_Data1920shape.dta", clear 

eststo summstats: estpost summarize settlement ln_distk lat longitude geo_altitude geo_solo_sarg geo_solo_scambi geo_solo_sespondo geo_solo_slat sh_lit72 sh_childschool72 sh_slaves72 sh_foreign72 pop72 railway72 sh_lit20 schools_child20 teachers_child20 pop20 sh_foreign20 sh_foreign_lit20 sh_smallholders20 coffee_ha20 value_land20 railway20 sh_emp_ag20 sh_emp_ind20 sh_emp_serv20 sh_lit40 schools_child40 sh_child_school40  pop40 sh_emp_ag40 sh_emp_ind40 sh_emp_serv40 sh_lit00 years_schooling00 sh_child_school00 schools_child00 teachers_child00 income_pc00 sh_emp_ag00 sh_emp_ind00 sh_emp_serv00

esttab summstats using "$RepDir/table2.csv" , replace cell("mean sd min max") 


********************************************************************	
* TABLE 3: DIFFERENCE IN INITIAL CHARACTERISTICS FOR MUNICIPALITIES WITH AND WITHOUT SETTLEMENTS
********************************************************************	

use "$RepDir/RochaFerrazSoares_Data1872shape.dta", clear 

*Average characteristics for settlement and non-settlement municipalities*
eststo summstats_a: estpost summarize  ln_distk geo_lat_72 geo_long_72 geo_altitude  geo_solo_slat sh_lit72 sh_child_school72  sh_foreign72 sh_slaves72 popdensity72 railway72 publicservants_pc72 legalprofession_pc72 teachers_pc72 sh_emp_ag72 sh_emp_ind72 sh_emp_serv72 if settlement==1
eststo summstats_b: estpost summarize  ln_distk geo_lat_72 geo_long_72 geo_altitude  geo_solo_slat sh_lit72 sh_child_school72  sh_foreign72 sh_slaves72 popdensity72 railway72 publicservants_pc72 legalprofession_pc72 teachers_pc72 sh_emp_ag72 sh_emp_ind72 sh_emp_serv72 if settlement==0
esttab summstats_a summstats_b using "$RepDir/table3a.csv", replace cell("mean sd") 

*Test of equal means*
local varlist "ln_distk geo_lat_72 geo_long_72 geo_altitude  geo_solo_slat sh_lit72 sh_child_school72  sh_foreign72 sh_slaves72 popdensity72 railway72 publicservants_pc72 legalprofession_pc72 teachers_pc72 sh_emp_ag72 sh_emp_ind72 sh_emp_serv72"
cap estimates clear
foreach X of local varlist {
 eststo: reg `X' settlement , rob
}
esttab using "$RepDir/table3b.csv", replace se(3) brac noconstant star(+ 0.10 * 0.05) keep(settlement) r2 b(3)

**************************************************
*TABLE 4: THE SHORT-TERM EFFECTS OF SETTLEMENTS
**************************************************

use "$RepDir/RochaFerrazSoares_Data1920shape.dta", clear 

gen lvalue_land20=log(value_land20)
gen lwage_const20 =log(wage_const20)
gen lwage_ag20=log(wage_ag20)

global geo "ln_distk latitude longitude geo_altitude geo_solo_sarg geo_solo_scambi geo_solo_sespondo geo_solo_slat"
global y72 "sh_foreign72 sh_slaves72 sh_lit72 sh_emp_ag72 sh_emp_ind72 sh_emp_serv72 railway72"

*FOR SHARE LITERATE FOREIGNERS WE RESTRICT FOR THOSE MUNICIPALITIES WHERE AT LEAST 1% OF POPULATION IS FOREIGNER OTHERWISE SHARE IS NOT WELL DEFINED. THIS IS ROBUST TO USING 5 OR 10 PERCENT*
replace sh_foreign_lit20 = . if sh_foreign20<=0.01

cap estimates clear

eststo: reg sh_lit20 settlement,                     r cluster(cod72)
eststo: reg sh_lit20 settlement $geo,                r cluster(cod72)
eststo: reg sh_lit20 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_foreign20 settlement $geo $y72 ,      r cluster(cod72)
eststo: reg sh_foreign_lit20 settlement $geo $y72 ,  r cluster(cod72)
eststo: reg popdensity20 settlement $geo $y72 ,      r cluster(cod72)
eststo: reg sh_smallholders20 settlement $geo $y72 , r cluster(cod72)
eststo: reg coffee_ha20  settlement $geo $y72 ,      r cluster(cod72)
eststo: reg lvalue_land20 settlement $geo $y72 ,     r cluster(cod72)
eststo: reg lwage_const20 settlement $geo $y72 ,     r cluster(cod72)
eststo: reg lwage_ag20 settlement $geo $y72 ,        r cluster(cod72)

esttab using "$RepDir/table4.csv", replace se(3) brac noconstant star(+ 0.10 * 0.05 ** 0.01) keep(settlement) ar2 b(3)

**************************************************************************
* TABLE 5: THE MEDIUM AND LONG-TERM EFFECTS OF SETTLEMENTS
**************************************************************************

gen lincome_pc00=log(income_pc00)

cap estimates clear

eststo: reg sh_lit40 settlement $geo $y72,          r cluster(cod72)
eststo: reg sh_lit40_15_19 settlement $geo $y72,    r cluster(cod72)
eststo: reg sh_lit00 settlement $geo $y72,          r cluster(cod72)
eststo: reg sh_lit00_15_19 settlement $geo $y72,    r cluster(cod72)
eststo: reg years_schooling00 settlement $geo $y72, r cluster(cod72)
eststo: reg lincome_pc00 settlement $geo $y72,      r cluster(cod72)

esttab using "$RepDir/table5.csv", replace se(3) brac noconstant star(+ 0.10 * 0.05 ** 0.01) keep(settlement) ar2 b(3)

*************************************************************************************************************************
* Table 6- Mid and Long-Term Effects of Settlements on Human Capital: Panel-Data Specifications 	
*************************************************************************************************************************

*Use dataset no 3	
use "$RepDir/RochaFerrazSoares_Data1872_1940.dta", clear 

*Create interactions with year dummies
xi i.year i.year*settlement i.year*geo_lat_72 i.year*geo_long_72 i.year*geo_altitude_72 i.year*geo_distk_72 i.year*geo_solo_slat_72 i.year*sh_foreign72  i.year*sh_slaves72 i.year*sh_child_school72 

global geog "_IyeaXgeo_1920 _IyeaXgeo_1940  _IyeaXgeoa1920 _IyeaXgeoa1940  _IyeaXgeob1920 _IyeaXgeob1940  _IyeaXgeoc1920 _IyeaXgeoc1940  _IyeaXgeod1920 _IyeaXgeod1940 "
global demog "_IyeaXsh__1920 _IyeaXsh__1940 _IyeaXsh_a1920 _IyeaXsh_a1940  _IyeaXsh_b1920 _IyeaXsh_b1940"

cap estimates clear

eststo: xtreg sh_lit _IyeaXset_1920 _IyeaXset_1940  _Iyear_1920 _Iyear_1940, r fe i(cod72)
eststo: xtreg sh_lit _IyeaXset_1920 _IyeaXset_1940  _Iyear_1920 _Iyear_1940 $geog, r fe i(cod72)
eststo: xtreg sh_lit _IyeaXset_1920 _IyeaXset_1940  _Iyear_1920 _Iyear_1940 $geog $demog, r fe i(cod72)

esttab using "$RepDir/table6.csv", replace se(3) brac noconstant star(+ 0.10 * 0.05 ** 0.01) keep(_IyeaXset_1920 _IyeaXset_1940) ar2 b(3)


*************************************************************************************************************************
*Table 7- The Effects of Settlements on School Inputs and School Attendance
*************************************************************************************************************************

use "$RepDir/RochaFerrazSoares_Data1920shape.dta", clear 

global geo "ln_distk latitude longitude geo_altitude geo_solo_sarg geo_solo_scambi geo_solo_sespondo geo_solo_slat"
global y72 "sh_foreign72 sh_slaves72 sh_lit72 sh_emp_ag72 sh_emp_ind72 sh_emp_serv72 railway72"

cap estimates clear

eststo: reg schools_child20 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg teachers_child20 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg schools_child40 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_child_school40 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg schools_child00 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg teachers_child00 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_child_school00 settlement $geo $y72 ,          r cluster(cod72)

esttab using "$RepDir/table7.csv", replace se(3) brac noconstant star(+ 0.10 * 0.05 ** 0.01) keep(settlement) ar2 b(3)

**********************************************
* Table 8- The Long-Run Effects of Settlements on Employment and Structural Transformation
**********************************************

cap estimates clear

eststo: reg sh_emp_ag20  settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_emp_ind20 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_emp_serv20 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_emp_ag40 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_emp_ind40 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_emp_serv40  settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_emp_ag00 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_emp_ind00 settlement $geo $y72 ,          r cluster(cod72)
eststo: reg sh_emp_serv00  settlement $geo $y72 ,          r cluster(cod72)

esttab using "$RepDir/table8.csv", replace se(3) brac noconstant star(+ 0.10 * 0.05 ** 0.01) keep(settlement) ar2 b(3)

*********************************************************************************
* Table 9- Persistent Effects of Settlements on Years of Schooling, by Cohorts of Individuals
*********************************************************************************

cap estimates clear

eststo: reg years_school_all_nm  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1920_29nm  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1930_39nm  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1940_49nm  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1950_59nm  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1960_69nm  settlement $geo $y72, r cluster(cod72)

esttab using "$RepDir/table9A.csv", replace se(3) brac noconstant star(+ 0.10 * 0.05 ** 0.01) keep(settlement) ar2 b(3)

cap estimates clear

eststo: reg years_school_all_m  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1920_29m  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1930_39m  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1940_49m  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1950_59m  settlement $geo $y72, r cluster(cod72)
eststo: reg years_school_1960_69m  settlement $geo $y72, r cluster(cod72)

esttab using "$RepDir/table9B.csv", replace se(3) brac noconstant star(+ 0.10 * 0.05 ** 0.01) keep(settlement) ar2 b(3)
    
**********************************************************	
* Table 10- The Effects of Settlements on Literacy Rates, Conditional on National Identities and Religion	
**********************************************************		

gen lincome_pc00=log(income_pc00)

cap estimates clear

eststo: reg sh_lit20  settlement sh_germany20 sh_spain20 sh_italy20 sh_portugal20 sh_japan20 sh_catholics20 $geo $y72, r cluster(cod72)
eststo: reg sh_lit40  settlement sh_germany20 sh_spain20 sh_italy20 sh_portugal20 sh_japan20 sh_catholics20 $geo $y72, r cluster(cod72)
eststo: reg years_schooling00  settlement sh_germany20 sh_spain20 sh_italy20 sh_portugal20 sh_japan20 sh_catholics20 $geo $y72, r cluster(cod72)
eststo: reg lincome_pc00  settlement sh_germany20 sh_spain20 sh_italy20 sh_portugal20 sh_japan20 sh_catholics20 $geo $y72, r cluster(cod72)

esttab using "$RepDir/table10.csv", replace se(3) brac noconstant star(+ 0.10 * 0.05 ** 0.01) keep(settlement sh_germany20 sh_spain20 sh_italy20 sh_portugal20 sh_japan20 sh_catholics20) ar2 b(3)


 
