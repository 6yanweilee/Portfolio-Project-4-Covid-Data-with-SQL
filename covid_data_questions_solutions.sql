-- Select Data that we are going to be starting with

SELECT Location, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent is NOT NULL
order by 1, 2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, total_cases, total_deaths, (total_deaths/total_cases)*100 as '% Death'
FROM CovidDeaths$
WHERE Location like '%kingdom%'
and continent is NOT NULL
order by 1, 2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, Population, total_cases, (total_cases/Population)*100 as '% Infected'
FROM CovidDeaths$
WHERE Location like '%kingdom'
order by 1, 2;

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as 'Highest Infection Count', MAX((total_cases/Population))*100 as 'Highest % Infected'
FROM CovidDeaths$
Group by Location, population
ORDER by 4 DESC;

-- Countries with Highest Death Count per Population

SELECT Location, Population, MAX(total_deaths) as 'Highest Death Count', MAX((total_deaths/Population))*100 as 'Highest % Death'
FROM CovidDeaths$
GROUP BY Location, population
ORDER BY 4 DESC;

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as 'Total Death Count'
FROM CovidDeaths$
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

-- Show the percentage death per continent

SELECT continent, SUM(new_cases) AS 'Total Cases', SUM (cast(new_deaths as int)) AS 'Total Deaths', SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS '% Death'
FROM CovidDeaths$
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY 1, 2;

-- Show the percentage death per country

SELECT Location, SUM(new_cases) AS 'Total Cases', SUM (cast(new_deaths as int)) AS 'Total Deaths', SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS '% Death'
FROM CovidDeaths$
GROUP BY location
ORDER BY 1, 2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population,
	CovidVaccinations$.new_vaccinations, SUM(CONVERT(int, CovidVaccinations$.new_vaccinations)) OVER (Partition by CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.Date) as 'Rolling People Vaccinated'
FROM CovidDeaths$
JOIN CovidVaccinations$
ON CovidDeaths$.location = CovidVaccinations$.location
AND CovidDeaths$.date = CovidVaccinations$.date
WHERE CovidDeaths$.continent IS NOT NULL;

-- Using Common Table Expression to Calculate Partition By in 'Total Population vs Vaccinations'

With PopulationVsVaccinations (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT CovidDeaths$.continent, CovidDeaths$.location, CovidDeaths$.date, CovidDeaths$.population,
	CovidVaccinations$.new_vaccinations, SUM(CONVERT(int, CovidVaccinations$.new_vaccinations)) OVER (Partition by CovidDeaths$.location ORDER BY CovidDeaths$.location, CovidDeaths$.Date) as 'Rolling People Vaccinated'
FROM CovidDeaths$
JOIN CovidVaccinations$
ON CovidDeaths$.location = CovidVaccinations$.location
AND CovidDeaths$.date = CovidVaccinations$.date
WHERE CovidDeaths$.continent IS NOT NULL
)

Select *, (RollingPeopleVaccinated/Population)*100
FROM PopulationVsVaccinations;