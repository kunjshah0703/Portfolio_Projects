-- Select what data we are going to use it.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2;


-- Looking at Total Cases Vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%ndia'
ORDER BY 1, 2;


-- Looking at Total Cases Vs Population
-- Shows what percentage of Population Got Covid.

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS TotalCovid
FROM CovidDeaths
WHERE location LIKE '%ndia'
ORDER BY 1, 2;



-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
-- WHERE location LIKE '%ndia'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Showing Countries with highest Deat Count Per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE location LIKE '%ndia'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- LET's BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE location LIKE '%ndia'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing the continents with highest death count

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
-- WHERE location LIKE '%ndia'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--  GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths
-- WHERE location LIKE '%ndia'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2;



-- Looking at total population Vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths AS dea
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;



-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths AS dea
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac;



-- TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths AS dea
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths AS dea
JOIN CovidVaccinations$ AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated
