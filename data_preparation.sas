/* ----- Data preprocessing ----- */

/* Data import */
PROC IMPORT
   DATAFILE="/home/u64118426/sasuser.v94/Projet_biostats/heart.csv"
   OUT=dataset_projet
   DBMS=CSV REPLACE;
   GETNAMES=YES;
RUN;

/* Expliciting categorical features */
DATA dataset_projet;
    /* Converting 'sex' */
    set dataset_projet;
	if sex = 1 then sex_char = "male";
    else if sex = 0 then sex_char = "female";
    drop sex; 
    rename sex_char = sex; 
	
	/* Converting 'exang' + renaming */   
    set dataset_projet;
	if exang = 1 then exerc_ind_angina="yes";
	else if exang = 0 then exerc_ind_angina="no";
	drop exang;

	/* Converting 'fbs' + renaming */
	set dataset_projet;
	if fbs=1 then f_blood_sugar="yes";
	else if fbs=0 then f_blood_sugar="no";
	drop fbs;
	
	/* Converting 'slope' + renaming */
	set dataset_projet;
	if slope=1 then peak_exerc_slope="upsloping";
	else if slope=2 then peak_exerc_slope="flat";
	else if slope=3 then peak_exerc_slope="downsloping";
	drop slope;

	/* Converting 'restecg' + renaming */
	set dataset_projet;
	if restecg=0 then resting_ecg="normal";
	else if restecg=1 then resting_ecg="abnormal";
	drop restecg;
	
	/* Converting 'target' + renaming */
	set dataset_projet;
	if target=1 then heart_disease="yes";
	else if target=0 then heart_disease="no";
	drop target;
	
	/* Converting 'cp' + renaming */
	set dataset_projet;
	if cp=1 then chest_pain="typical angina";
	else if cp=2 then chest_pain="atypical angina";
	else if cp=3 then chest_pain="non-anginal pain";
	drop cp;
RUN;

/* Deleting features with NaN */
DATA dataset_projet;
    SET dataset_projet;
	IF cmiss(of _all_) > 0 THEN delete;
RUN;

/* Renaming features */
data dataset_projet;
    set dataset_projet;
    rename trestbps = rest_blood_p;
    rename chol = cholestoral;
    rename thalach = max_heart_rate;
run;

/* ----- End of data preprocessing ----- */

/* ----- Odd ratios ----- */

PROC FREQ 
	data=dataset_projet order=data;
	tables sex*heart_disease / chisq relrisk alpha=0.05 nocol nocum norow nopercent;
run;
/* Results :
P-value(chisq) < 0.0001 ; VCramer = 0.30 => H1 accepted : there is a dependency between sex and heart diseases
Oddratio = 7.36 (Confidence inter. : [3.83;14.1]) 
Interpretation : x7.36 odds to have a heart disease if you're a woman
*/

PROC FREQ 
	data=dataset_projet order=data;
	tables resting_ecg*heart_disease / chisq relrisk alpha=0.05 nocol nocum norow nopercent;
run;
/* Results :
P-value(chisq) = 0.005 ; VCramer =  0.12 => H1 accepted : there is a dependency between resting ECG and heart diseases
Oddratio = 1.81 (Confidence inter. : [1.2;2.8]) 
Interpretation : x1.81 odds to have a heart disease if you have an abnormal resting electrocardiographic results
*/

PROC FREQ data=dataset_projet order=data;
	tables exerc_ind_angina*heart_disease / chisq relrisk alpha=0.05 nocol nocum norow nopercent;
run;
/* Results :
P-value(chisq) = 0.03  ; VCramer = 0.09  => H1 accepted : there is a dependency between exercise induced angina and heart disease
Oddratio = 1.87 (Confidence inter. : [1.04;3.33]) 
Interpretation : x1.87 oods to have a heart disease if you don't show exercise induced angina (according to litterature, you would expect the opposite)
*/

PROC FREQ 
	data=dataset_projet order=data;
	tables f_blood_sugar*heart_disease / chisq relrisk alpha=0.05 nocol nocum norow nopercent;
run;
/* Results :
P-value(chisq) = 0.99 => H0 accepted : there is no link between a fasting abnormally high blood sugar rate and heart disease*/


/* Chi-square test on native 'chest_pain' feature (3 modes) */ 
PROC FREQ 
	data=dataset_projet order=data; 
	tables chest_pain*heart_disease / chisq relrisk alpha=0.05 nocol nocum norow nopercent;
run;
/* Results :
P-value(chisq) = 0.006 => H1 accepted, there is a link between the type of chest pain and heart disease.*/
/* Chi-square test and odd ratio on binarized 'chest_pain' */
DATA dataset_projet;
	set dataset_projet;
	if chest_pain IN ("typical angina") then chest_pain_bin="typical";
	else if chest_pain IN ("atypical angin","non-anginal pa") then chest_pain_bin="atypical";
run;
PROC FREQ 
	data=dataset_projet order=data; 
	tables chest_pain_bin*heart_disease / chisq relrisk alpha=0.05 nocol nocum norow nopercent;
run;
/* Results :
P-value(chisq) = 0.03 ; VCramer = 0.09 => H1 accepted : there is a dependency between the type of chest pain and heart diseases (typical as a chest angina type of pain) 
Oddratio = 1.67 (Confidence inter. : [1.05;2.68]) 
Interpretation : x1.67 odds to have a heart disease if you chest pain is an classic angina-type of pain
*/	
