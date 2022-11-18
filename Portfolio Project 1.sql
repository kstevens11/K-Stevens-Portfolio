SELECT *
 FROM PortfolioProject..CovidDeaths$
 WHERE continent is not null
 ORDER BY 3,4

--SELECT *
-- FROM PortfolioProject..CovidVaccinations$
-- ORDER BY 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..CovidDeaths$
 ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths$
 --WHERE location like '%states%'
 ORDER BY 1,2

-- Looking at total cases vs population
-- Shows what percentage of population contracted covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths$
 --WHERE location like '%states%'
 ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths$
 --WHERE location like '%states%'
 Group by Location, population
 ORDER BY PercentPopulationInfected DESC

-- Showing countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths$
 --WHERE location like '%states%'
 WHERE continent is not null
 Group by Location
 ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths$
 --WHERE location like '%states%'
 WHERE continent is not null
 Group by continent
 ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS


SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as bigint)) AS TotalDeaths, (SUM(cast(new_deaths as bigint))/SUM(new_cases))*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths$
 --WHERE location like '%states%'
 WHERE continent is not null
 --GROUP BY date
 ORDER BY 1,2

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(bigint,vac.new_vaccinations)) 
 OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2,3;


-- USE CTE

WITH PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(bigint,vac.new_vaccinations)) 
 OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
 WHERE dea.continent is not null
 --ORDER BY 2,3
 )
 SELECT *, (RollingPeopleVaccinated/population)*100
 FROM PopvsVac


 -- TEMP TABLE

 DROP TABLE IF exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(bigint,vac.new_vaccinations)) 
 OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
 --WHERE dea.continent is not null
 --ORDER BY 2,3
 
 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated


 -- Creating view to store data for later visulations

 DROP VIEW IF EXISTS PercentPopulationVaccinated
 
 USE PortfolioProject
 GO
 CREATE VIEW PercentPopulationVaccinated AS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(CONVERT(bigint,vac.new_vaccinations)) 
 OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
    ON dea.location = vac.location
	AND dea.date = vac.date
 WHERE dea.continent is not null
 --ORDER BY 2,3

SELECT *
 FROM PercentPopulationVaccinated