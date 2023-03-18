SELECT*
FROM covidPortfolio..covidDeaths
WHERE continent is not null
order by 3,4

--SELECT*
--FROM covidPortfolio..covidvaccinations
--WHERE continent is not null
--order by 3,4

--Select Data that we are going to be using

--SELECT Location, date, total_cases, new_cases, total_deaths, population 
--FROM covidPortfolio..covidDeaths
--order by 1, 2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, 
cast(total_deaths as bigint)/NULLIF(cast(total_cases as float),0)*100 AS deathPercentage
FROM covidPortfolio..covidDeaths
WHERE location LIKE '%States%'
order by 1,2

--Looking at Total cases VS Population
--Shows what percentage of population got Covid

SELECT location, date, Population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
WHERE location LIKE '%States%'
order by 1,2 DESC

--Looking at countries with highest infection rate compared to Population

SELECT 
location, Population,MAX(total_cases) AS Highest_InfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covidPortfolio..covidDeaths
--WHERE location LIKE '%States%'
GROUP BY Location, Population
order by PercentPopulationInfected DESC

--Showing the countries with the Highest Death Count per Population

SELECT 
location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM covidPortfolio..covidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY Location
order by Total_Death_Count DESC

--LETS BREAK THINGS DOWN BY CONTINENT 

SELECT 
continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM covidPortfolio..covidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY continent
order by Total_Death_Count DESC


--Showing continents with highest death count per population

SELECT 
continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM covidPortfolio..covidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY continent
order by Total_Death_Count DESC


--GLOBAL NUMBERS

Select
SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM covidPortfolio..covidDeaths
WHERE continent IS NOT NULL
--group by date
order by 1,2

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM covidPortfolio..covidDeaths dea
JOIN covidPortfolio..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac 
(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM covidPortfolio..covidDeaths dea
JOIN covidPortfolio..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT* , (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPoulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
DATE datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM covidPortfolio..covidDeaths dea
JOIN covidPortfolio..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT* , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM covidPortfolio..covidDeaths dea
JOIN covidPortfolio..covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT*
FROM PercentPopulationVaccinated