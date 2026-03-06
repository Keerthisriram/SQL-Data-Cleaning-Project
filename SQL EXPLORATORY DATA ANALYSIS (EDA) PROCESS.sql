Select * from layoffs_staging_2;

#To find and max & min date:
Select YEAR(min(`date`)) AS MIN_YEAR, YEAR(max(`date`) ) AS MAX_YEAR 
FROM layoffs_staging_2;

#Which company have highest laid_off:
SELECT company, sum(total_laid_off) AS TOTAL_OFF 
FROM layoffs_staging_2
GROUP BY company order by 2 DESC;

#Which company have lowest laid_off:
SELECT company, sum(total_laid_off) AS TOTAL_OFF 
FROM layoffs_staging_2
WHERE total_laid_off IS NOT NULL
GROUP BY company order by 2 ;

#which indusrty have highest laid_off:
SELECT industry, sum(total_laid_off) AS TOTAL_OFF
FROM layoffs_staging_2
GROUP BY industry order by 2 desc ;


#which indusrty have lowest laid_off:
SELECT industry, sum(total_laid_off) AS TOTAL_OFF
FROM layoffs_staging_2
GROUP BY industry order by 2  ;

#Which company raised highest funds:
SELECT company, max(funds_raised_millions) 
FROM layoffs_staging_2
GROUP BY company;

#Which country raised highest funds:
SELECT country, max(funds_raised_millions) 
FROM layoffs_staging_2
GROUP BY country;

#Which year have the highest laidoff:
SELECT YEAR(`date`) AS Years, 
SUM(total_laid_off) AS Total_off
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;


#TOTAL_LAID_OFF IN A YEAR BY country: 
 SELECT country,YEAR(`date`) AS `Year`,
 SUM(total_laid_off) AS Total_laid_off
 FROM layoffs_staging_2
 GROUP BY country, `Year` ORDER BY country ;

#Top 5 Highest laid_off per Year:

WITH Company_Rank AS (
SELECT company, YEAR(`date`) AS Years, 
SUM(total_laid_off) AS Total_off,
DENSE_RANK() OVER(PARTITION BY YEAR(`date`) ORDER BY SUM(total_laid_off) DESC) AS Ranking
FROM layoffs_staging_2
WHERE YEAR(`date`) is NOT NULL
GROUP BY company,YEAR(`date`)
)
SELECT * from Company_Rank
WHERE Ranking<=5;







