SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Portrays likelihood of dying if you contract covid in the Netherlands

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS pct_cases_vs_deaths
	-- ROUND(sum(total_deaths)/sum(total_cases), 3) AS pct_cases_vs_deaths
FROM CovidDeaths
WHERE location like 'Netherlands'
	AND continent IS NOT NULL
ORDER BY 1,2



-- Check the total cases versus population
-- Reflects the percentage of overall population contracting COVID

SELECT 
	location,
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population,
	ROUND((total_cases/population)*100,2) AS pct_cases_vs_population
FROM CovidDeaths
WHERE location like 'Netherlands'
ORDER BY 1, 2


-- countries with the highest investion rate compared to population

SELECT
	location,
	population, 
	MAX(total_cases) AS highest_infection_count,
	MAX(ROUND((total_cases/population)*100,2)) AS pct_cases_vs_population
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC


-- locations with highest death count per population

SELECT
	location,
	MAX(cast(total_deaths AS INT)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC



-- BREAKING DOWN BY CONTINENT
-- continents with the highest count of deaths (absolute numbers)

SELECT
	continent,
	MAX(cast(total_deaths AS INT)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


-- average of new cases per 100 capita per continent

SELECT
	continent,
	ROUND(AVG(new_cases/population)*100,3) AS avg_daily_new_cases_per_100
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC




-- GLOBAL NUMBERS
SELECT 
	SUM(new_cases) AS total_cases, 
	ROUND(AVG(new_cases),2) AS average_new_cases,
	SUM(CAST(new_deaths as int)) AS total_deaths, 
	ROUND(AVG(CAST(new_deaths AS int)),2) AS average_new_deaths,
	ROUND(SUM(CAST(new_deaths AS int)),2)/ROUND(SUM(new_cases),2)*100 AS death_percentage
From CovidDeaths
where continent is not null 
order by 1,2


-- total population vs vaccination

SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_count
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
		ON cd.location = cv.location
		AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3


-- using subquey to perform calculation on partition by location 

SELECT 
	continent, 
	location, 
	date, 
	population, 
	new_vaccinations,
	rolling_count/population*100 AS rol_count_pop
FROM
(
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_count
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
		ON cd.location = cv.location
		AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY 2,3
) AS part_rol_count_pop



-- using CTE to perform the same calculation on partition by location 

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_count)
AS 
(
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_count
From PortfolioProject..CovidDeaths cd
Join PortfolioProject..CovidVaccinations cv
		ON cd.location = cv.location
		AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (rolling_count/population)*100
FROM pop_vs_vac



-- creating view to store data for later visualisation

CREATE VIEW cov_deaths_cont AS 
SELECT
	continent,
	MAX(cast(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
-- ORDER BY 2 DESC
