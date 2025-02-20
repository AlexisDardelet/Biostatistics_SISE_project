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
	else if cp=4 then chest_pain="asymptomatic";
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