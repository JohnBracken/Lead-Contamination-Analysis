/*Replace missing values with a blank*/
OPTIONS MISSING='';

/*Read in the cleaned csv file of genomic deletion data.*/
PROC IMPORT DATAFILE= '/folders/myfolders/SASData/Lead_Data.csv'
OUT=WORK.LEAD_DATA
DBMS=CSV;
GETNAMES=YES
;
RUN;

/*Split the latitude longitude coordinates into two separate columns.*/
DATA WORK.LEAD_DATA(DROP = County_Location);
  SET WORK.LEAD_DATA;
  County_Latitude=SCAN(County_Location,1,',');
  County_Longitude=SCAN(County_Location,2,',');
  
  /*Remove brackets */
  County_Latitude=COMPRESS(County_Latitude, "()");
  County_Longitude=COMPRESS(County_Longitude, "()");
  
  /*Convert to numeric variables*/
  County_Latitudes = INPUT(County_Latitude, 10.6);
  County_Longitudes = INPUT(County_Longitude, 10.6);
RUN;

/*Now remove the original character latitude and longitude values */
DATA WORK.LEAD_DATA(DROP = County_Latitude County_Longitude);
  SET WORK.LEAD_DATA;
RUN;

/*Find mean latitude and longitude of all New York school districts from
the lead concentration data. This location is actually near White Lake, 
New York State.*/
PROC MEANS DATA= WORK.LEAD_DATA;
VAR County_Latitudes County_Longitudes;
RUN;

/*Find the school with the most outlets greater than 15 ppm.  It was
the New Rochelle City School district in late 2016.  There were news articles
about lead problems in the district at that time.*/
PROC SQL;
CREATE TABLE Max_lead AS
SELECT * 
FROM 
WORK.LEAD_DATA
WHERE NumOutletsMoreThan15ppb= (SELECT MAX(NumOutletsMoreThan15ppb) FROM WORK.LEAD_DATA)
;
QUIT;

/*Find all school districts containing the word Buffalo. */
PROC SQL;
CREATE TABLE BUFFALO AS
SELECT * 
FROM
WORK.LEAD_DATA
WHERE School_District LIKE '%BUFFALO%';
QUIT;

/*Export the Buffalo lead data to a csv data.*/
PROC EXPORT DATA=WORK.BUFFALO DBMS=CSV
OUTFILE="/folders/myfolders/SASData/Buffalo_Lead_Data.csv"
REPLACE;
RUN;


