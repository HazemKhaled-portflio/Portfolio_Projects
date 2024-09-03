-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;


-- Finding the maximum amount of laid off workers

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Companies with the highest number of laid off workers

SELECT company, SUM(total_laid_off) sum
FROM layoffs_staging2
GROUP BY company
ORDER BY sum DESC;


-- Looking at the date where the data begins and ends

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


-- The industries with the highest number of laid off workers

SELECT industry, SUM(total_laid_off) sum
FROM layoffs_staging2
GROUP BY industry
ORDER BY sum DESC;


-- Countries with the highest laid off workers

SELECT country, SUM(total_laid_off) sum
FROM layoffs_staging2
GROUP BY country
ORDER BY sum DESC;


-- Number of laid off workers each year

SELECT YEAR(`date`), SUM(total_laid_off) sum
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


-- number of laid off workers based on company stage

SELECT stage, SUM(total_laid_off) sum
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- Number of laid off workers each month

SELECT country, SUM(total_laid_off) sum
FROM layoffs_staging2
GROUP BY country
ORDER BY sum DESC;

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1;


-- Using CTE to calculate Rolling total

WITH rolling_total AS(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_laid
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH`,total_laid , SUM(total_laid) OVER(ORDER BY `MONTH`) AS rolling_total
FROM rolling_total;

SELECT company, SUM(total_laid_off) sum
FROM layoffs_staging2
GROUP BY company
ORDER BY sum DESC;


-- Number of laid off workers by company each year

SELECT company, YEAR(`date`), SUM(total_laid_off) sum
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;


-- Showing top 5 companies with the highest number of laid off workers each year

WITH company_year(company, years, sum) AS(
SELECT company, YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), company_year_rank AS (
SELECT * , DENSE_RANK() OVER(PARTITION BY years ORDER BY sum DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;






