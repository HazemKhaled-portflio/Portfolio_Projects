-- Cleaning Data in SQL

SELECT*
FROM layoffs;

-------------------------------------------------------

-- Create staging table

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-------------------------------------------------------

-- Finding duplicates

WITH cte_dupes AS(
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS dupes
FROM layoffs_staging
)
SELECT *
FROM cte_dupes
WHERE dupes > 1;

-------------------------------------------------------

-- Deleting duplicates

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `dupes` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS dupes
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE dupes > 1;

-------------------------------------------------------

-- Standardizing data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET country = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-------------------------------------------------------

-- Changing `date` column from string to date

SELECT `date`, str_to_date(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-------------------------------------------------------

-- Fixing Null/blank values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM layoffs_staging2 t1
	JOIN layoffs_staging2 t2
		ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
	JOIN layoffs_staging2 t2
		ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (
t1.industry IS NULL OR t1.industry = ''
) AND (
t2.industry IS NOT NULL AND t2.industry !=''
);

-------------------------------------------------------

-- Removing unnecessary rows/columns

SELECT *
FROM layoffs_staging2
WHERE (percentage_laid_off IS NULL) AND (total_laid_off IS NULL);

DELETE
FROM layoffs_staging2
WHERE (percentage_laid_off IS NULL) AND (total_laid_off IS NULL);

ALTER TABLE layoffs_staging2
DROP COLUMN dupes;

SELECT *
FROM layoffs_staging2

