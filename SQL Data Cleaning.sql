
#DATA CLEANING:

## 1.Remove Duplicates
#  2.Standardize the data
#  3.Remove Null or Blank spaces
#  4.Remove unwanted row or Columns.

## Steps to Import the from different sources:

# Creating database schema and import the data from external sources

#Create sample data for data cleaning using original dataset.
CREATE TABLE layoffs_staging_1 LIKE layoffs;

 #Insert the data from original table
INSERT INTO layoffs_staging_1 
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging_1 ;

# Find the duplicates using window function:

WITH ROW_NUM_UPDATE AS(

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location,industry,
total_laid_off, percentage_laid_off,`date`, stage,
country,funds_raised_millions) AS ROW_NUM
FROM layoffs_staging_1
)
SELECT * FROM ROW_NUM_UPDATE
WHERE ROW_NUM>1 ;

#If exist delete the duplicates:

# We can't delete using CTE.For deleting the Row number we have to create another duplicate table  and insert the row_num column;
CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `ROW_NUM`INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#Insert the duplicate records using window function.

INSERT INTO layoffs_staging_2
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location,industry,
total_laid_off, percentage_laid_off,`date`, stage,
country,funds_raised_millions) AS ROW_NUM
FROM layoffs_staging_1
 );

SELECT * FROM layoffs_staging_2
WHERE ROW_NUM>1;

#DELETE THE DUPLICATES:
DELETE FROM layoffs_staging_2
WHERE ROW_NUM>1;


#2.Standardize the data:
SELECT * FROM layoffs_staging_2;

#Remove the white space :
SELECT company,TRIM(company)from layoffs_staging_2;

UPDATE layoffs_staging_2
SET company=TRIM(company);

#Update the column value which have the same value if needed.
SELECT DISTINCT industry FROM layoffs_staging_2 ORDER BY 1;

UPDATE layoffs_staging_2 
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country FROM layoffs_staging_2 ORDER BY 1;

#Remove unwanted character from the text
UPDATE layoffs_staging_2
SET country=TRIM(TRAILING '.' FROM country) 
WHERE country LIKE 'United States%';

#standardize the datatype:
 
select `date` from layoffs_staging_2;

#Update date format from string to date:
UPDATE layoffs_staging_2 
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

#Need to check if date is in correct datatype,If it's not in date format change the datatype into date format .
ALTER TABLE layoffs_staging_2 
MODIFY `date` date;


#3.Remove NULL or blank values:

select * from  layoffs_staging_2
WHERE industry is NULL OR industry='';

#Need to verify the company, those have the any industry name.If it's there need to update the same.

SELECT * FROM layoffs_staging_2 
WHERE company='Airbnb';


SELECT DISTINCT t1.industry,t1.company, t2.industry FROM layoffs_staging_2 t1
JOIN layoffs_staging_2 t2 ON t1.company = t2.company
WHERE t1.industry IS NULL OR t1.industry =''
AND t2.industry IS NOT NULL;


UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry ='';

UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2 
ON t1.company = t2.company
SET t1.industry=t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

#REMOVE Blank values:

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;

DELETE  FROM layoffs_staging_2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;


#4.Remove unwanted rows and columns:
SELECT *
FROM layoffs_staging_2;

ALTER TABLE layoffs_staging_2
DROP COLUMN ROW_NUM;


SELECT *FROM layoffs_staging_2 order by 1;