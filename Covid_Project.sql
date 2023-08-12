SELECT *
FROM PortFolioProject..CovidDeaths
where location is not NULL
ORDER BY 3,4

SELECT *
FROM PortFolioProject..CovidVaccinations
where location is not NULL


SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortFolioProject..CovidDeaths
where location is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortFolioProject..CovidDeaths
WHERE LOCATION Like '%india%'
and continent is not NULL
ORDER BY 1,2
 -- this query was to check what percentage of people died in each country relative to cases
 --shows likelihood of dying if you contract covid in your country

 --Looking at total cases vs Population
 -- Shows what percentage of people got covid 

 SELECT Location,date,total_cases,population,(total_cases/population)*100 as CovidAffected 
FROM PortFolioProject..CovidDeaths
WHERE LOCATION Like '%india%'
ORDER BY 1,2

--Looking at countries with highest Infection rates compared to Population

SELECT Location,MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))*100 as PercentPopulationAffected
FROM PortFolioProject..CovidDeaths
--WHERE LOCATION Like '%india%'
Group by Location, Population
ORDER BY PercentPopulationAffected desc

--Looking at countries with highest death count compared to Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortFolioProject..CovidDeaths
Where Continent is not NULL
Group by Location
ORDER BY TotalDeathCount desc

--Let's break things down by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortFolioProject..CovidDeaths
Where Continent is NULL
Group by location
ORDER BY TotalDeathCount desc


--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortFolioProject..CovidDeaths
Where Continent is not NULL
Group by continent
ORDER BY TotalDeathCount desc

---Global Numbers based off of date

Select date, SUM(new_cases)as total_deaths, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortFolioProject..CovidDeaths
Where continent is not NULL
Group by date
order by DeathPercentage desc


SELECT *
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date

---Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not NULL
ORDER BY 2,3


---agg funtions in this

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not NULL
ORDER BY 2,3

---USING CTE 

WITH PopsvsVac (Continent, Location,Date, Population, new_vaccination, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not NULL
--order by 2,3
)
 SELECT *, (RollingPeopleVaccinated/Population)*100
 FROM PopsvsVac

 --TEMP TABLE
 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric)

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageofVaccinatedPeople
 FROM  #PercentPopulationVaccinated


 --CREATING View to store data for visualization later

 CREATE View PercentPopulationVaccinated AS
 SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortFolioProject..CovidDeaths dea
JOIN PortFolioProject..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not NULL
--ORDER BY 2,3


Select *
FROM PercentPopulationVaccinated