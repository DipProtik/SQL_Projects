create database if not exists augmedix_ds;

use augmedix_ds;

create table amdx_case_rprt
(
Patient_Name varchar(255),
Payer varchar(255),
NPI int,
TIN int,
Payer_Payment double,
Patient_Payment double,
Billed_Charge double,
Provider_Name varchar(255),
Date_of_Service date,
CPT_Code varchar(255)
);

-- drop table amdx_case_rprt2;

select * from amdx_case_rprt;

-- LOAD DATA INFILE 'Pre-Launch Case Payment Report - EHR Report.csv'
-- INTO TABLE amdx_case_rprt
-- FIELDS TERMINATED BY ','
-- IGNORE 1 LINES;


-- SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Pre-Launch Case Payment Report - EHR Report.csv'
INTO TABLE amdx_case_rprt
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'      
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Patient_Name, Payer, NPI, TIN, Payer_Payment, Patient_Payment, Billed_Charge, Provider_Name, Date_of_Service, CPT_Code, @dummy);



ALTER TABLE amdx_case_rprt
ADD COLUMN temp_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;


-- Trying to see the last row value of temp_id so that i can ensure that i am deleting the correct data of Date_of_Service values

SELECT * 
FROM amdx_case_rprt 
WHERE patient_name = "Scarlett Smith" AND payer IN ("UNITED HEALTHCARE", "Meritain Health Minneapolis");


UPDATE amdx_case_rprt
SET Date_of_Service = NULL
WHERE temp_id IN ( 25883, 25885);

--  Untill here I have uploaded the dataset as it is in the data source. Now let's start modifying.

create table deliverable_1_1 as
select distinct payer, SUM(payer_payment) as Payer_Payments_n, SUM(billed_charge) as Billed_Charges_n 
from amdx_case_rprt group by payer;

create table deliverable_1_2 as
select payer, Payer_Payments_n, Billed_Charges_n, ROUND(Payer_Payments_n, 3) as Total_Payer_Payments,
ROUND(billed_charges_n, 3) as Total_Billed_Charges,
round(((Payer_Payments_n/Billed_Charges_n)*100), 3) as Payment_to_Charge 
from deliverable_1_1
order by payer;

select * from deliverable_1_2;

create table deliverable_2_1 as 
select distinct payer, npi, tin from amdx_case_rprt
order by payer;

select count(payer) from deliverable_2_1;













