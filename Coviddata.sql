Select *
From PortfolioProject..CovidDeaths
WHERE Continent is NOT NULL
ORDER BY 3,4

--SELECT *
--From PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
WHERE Continent is NOT NULL
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
AND Continent is NOT NULL
ORDER BY 1,2 

--Looking at total cases vs population
--Shows what percentage of population got Covid
Select Location, date, Population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
AND Continent is NOT NULL
ORDER BY 1,2 

--country with highest infection rate
Select Location, Population, MAX(total_cases) AS HighestInfectCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC 

--Showing countries with Highest Death Count per population
Select Location, MAX(total_deaths) AS HighestDeathCount
From PortfolioProject..CovidDeaths
WHERE Continent is NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC 

--Let's break things down by continent

Select Location, MAX(total_deaths) AS HighestDeathCount
From PortfolioProject..CovidDeaths
WHERE Continent is NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC 

--showing continents with highest death counts
Select Continent, MAX(total_deaths) AS HighestDeathCount
From PortfolioProject..CovidDeaths
WHERE Continent is not NULL
GROUP BY Continent
ORDER BY HighestDeathCount DESC 

-- Global Numbers
Select date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage --(total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent is NOT NULL
GROUP BY date
ORDER BY 1,2

CREATE VIEW DeathPercentage AS
Select SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage --(total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE Continent is NOT NULL
--GROUP BY date
--ORDER BY 1,2

--Covid Vaccinations

Select *
FROM CovidVaccinations

--Normal join of two tables

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.Location = vac.Location
   and dea.date = vac.date

--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.Location = vac.Location
   and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.Location = vac.Location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.Location = vac.Location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualisations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.LOCATION ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.Location = vac.Location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3








