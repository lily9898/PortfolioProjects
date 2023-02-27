SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Selecting the data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID in the United States

SELECT location, date, total_cases, total_deaths,(total_deaths::decimal/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs. Population
-- Shows what percentage of population got infected with COVID

SELECT location, date, population, total_cases,(total_cases::decimal/population)*100 AS DeathPercentage
FROM coviddeaths
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY 1,2


-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases::decimal/population))*100 AS PercentPopulationInfected
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX((total_cases::decimal/population))*100 IS NOT NULL
ORDER BY PercentPopulationInfected DESC


-- Countries with highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT


-- Showing contintents with the highest death count per population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total population vs. vaccinations
-- Shows percentage of population that has received at least one Covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM coviddeaths dea
INNER JOIN covidvaccinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform calculation on Partition By in a previous query

WITH PopvsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Using Temp Table to perform calcuation on Partition By in a previous query

CREATE TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATE,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW "PercentPopulationVaccinated" AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL