use "F:\NSS 70th\Shreya\NSSO Stata Files\33\Visit 1\AH0133V1.dta", clear
*Keep the identifiers from the survey*
keep common_id second_stage_stratum fod_sub_region sub_round sub_stratum ///
     stratum_number lot_fsu_number
replace common_id = substr(common_id,9,27)  //the 9th place of the common id with 27 characters//
sort common_id
compress

//Drop what is not needed//
drop special_char blank end filler level

********************************************************************************************************************

//This set of code converts string variables to numeric and reorders and regroups them

*********************************************************************************************************************

*Religion
rename religion_code religion
replace religion = "Hinduism" 		if religion=="1" 
replace religion = "Islam"   		if religion=="2" 
replace religion = "Christianity"   if religion=="3" 
replace religion = "Others"   		if religion=="4" | religion=="5" | ///
                                       religion=="6" | religion=="7" | ///
									   religion=="9"

label define order1  1 "Hinduism" 2 "Islam" ///
                     3 "Christianity"   4 "Others"  
encode religion, gen(religion1) label(order1)
drop religion
rename religion1 religion

* Social Group
rename social_group_code social_group
replace social_group = "ST" 		if social_group=="1" 
replace social_group = "SC"   		if social_group=="2" 
replace social_group = "OBC"        if social_group=="3" 
replace social_group = "Others"   	if social_group=="9" 

label define order2  1 "ST" 2 "SC" ///
                     3 "OBC"   4 "Others"  
encode social_group, gen(social_group1) label(order2)
drop social_group
rename social_group1 social_group

*Keep only the household head*
keep if relation_head=="1"

* Gender of the hh head
generate hh_sex   =  "Male"   if sex=="1"
replace  hh_sex   =  "Female"  if sex=="2"
label define order1  1 "Male" 2 "Female" 
encode hh_sex, gen(hh_sex1) label(order1)
drop hh_sex sex
rename hh_sex1 hh_sex
label var hh_sex "Gender of the hh. head"

//To generate a variable for whether people have crop insurance or not, by household id and crop type//

bys common_id crop_code: gen crop_insurance = "Yes" if crop_insured=="1" | ///
                                                        crop_insured=="2"
replace crop_insurance = "No"  if crop_insured=="3"
														
label define order1  1 "Yes"  2 "No"
encode crop_insurance, gen(crop_insurance1) label(order1)
drop crop_insured crop_insurance
rename crop_insurance1 crop_insurance
label var crop_insurance "Crop Insurance: Yes/No"

//This code generates a variable for people who don't have insurance, stating why they don't have insurance//
*Generate variable by household id and type of crop produced*
bys common_id crop_code: gen no_insure_reason = "Not aware" if reason_ins=="01" | ///
                                                               reason_ins=="02"
replace no_insure_reason = "Not interested or needed"		if reason_ins=="03" | ///
                                                               reason_ins=="04"		
replace no_insure_reason = "Facility not available"		    if reason_ins=="05" 
replace no_insure_reason = "Inability to pay premium"		if reason_ins=="06" 
replace no_insure_reason = "Bank far off"					if reason_ins=="08"
replace no_insure_reason = "Others"					        if reason_ins=="07" | ///
													           reason_ins=="09" | ///
															   reason_ins=="10" | ///
															   reason_ins=="11"
															   
label define order2  1 "Not aware"  2 "Not interested or needed"  ///
                     3 "Facility not available" 4 "Inability to pay premium" ///
					 5 "Bank far off" 6 "Others"
encode no_insure_reason, gen(no_insure_reason1) label(order2)
drop no_insure_reason crop_loss
rename no_insure_reason1 no_insure_reason
label var no_insure_reason "Not insured: Reasons"
//Put zeros on the missing values
recode no_insure_reason . = 0 

save "F:\NSS 70th\Shreya\NSSO Stata Files\33\Visit 1\AH0133V1.dta", replace

