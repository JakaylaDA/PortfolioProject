SELECT *
FROM Porfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM Porfolio..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

-- select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Porfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--- Looking at the total cases vs total deaths ( How many cases are in the country? What is the percentage of people who died?)
--likley hood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Porfolio..CovidDeaths
WHERE continent is not null
WHERE location like '%states%'


-- Looking at total cases vs populations
-- shows what population got covid

SELECT Location, date, population, total_cases,  (total_cases/population)*100 as PercentofPopulationInfected
FROM Porfolio..CovidDeaths
WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at counrtries with the highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM Porfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY population, location
ORDER BY PercentofPopulationInfected desc



--- Showing countries with highest death count per population

SELECT Location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Porfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY population, location
ORDER BY TotalDeathCount desc

-- break down by continent

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Porfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- showing the continents with the highest 

SELECT Location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Porfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY population, location
ORDER BY TotalDeathCount desc




-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
FROM Porfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

SELECT date SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
FROM Porfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2





-- looking a total popualation vs vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM Porfolio..CovidDeaths dea
JOIN Porfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3








-- use cte

With PopvsVac (continent, location, date , population, new_vaccinations, rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM Porfolio..CovidDeaths dea
JOIN Porfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT*, (rollingpeoplevaccinated/population)*100
FROM PopvsVac





-- temp table

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM Porfolio..CovidDeaths dea
JOIN Porfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rollingpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated





--creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM Porfolio..CovidDeaths dea
JOIN Porfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT*
FROM dbo.PercentPopulationVaccinated

CREATE VIEW PopByContinent as
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Porfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location

SELECT *
FROM dbo.PopByContinent
