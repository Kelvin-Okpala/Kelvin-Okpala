SELECT *
FROM PortfolioProject..[covid deaths]
WHERE continent is not null
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..[covid vaccinations]
--ORDER BY 3,4;

--Select the data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..[covid deaths]
WHERE continent is not null
ORDER BY 1,2;


--Let's look at Total Cases vs Total Deaths
--To find out the likelihood of dying if you contract the virus

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..[covid deaths]
WHERE continent is not null
ORDER BY 1,2;

--To isolate a specific location and find out the likelihood of dying if you contract the virus

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..[covid deaths]
WHERE location like '%States%'
AND continent is not null
ORDER BY 1,2;

--Looking at the Total Cases vs Population
--Shows what population of the population has Covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..[covid deaths]
--WHERE location like '%States%'
WHERE continent is not null
ORDER BY 1,2;

--Show Countries with highest infection rate compared to Population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..[covid deaths]
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC;

--Show Countries with Highest Death Counts per Population

SELECT location,MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..[covid deaths]
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;


--LET'S BREAK THIS DOWN BY CONTINENT

--Showing Continents with the highest death count per population

SELECT continent,MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..[covid deaths]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_Cases,SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..[covid deaths]
--WHERE location like '%States%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

--Looking at Total Population Vs Vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER By dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..[covid deaths] dea
JOIN PortfolioProject..[covid vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


--Using a CTE


With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER By dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..[covid deaths] dea
JOIN PortfolioProject..[covid vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac;


/**
With PopVsVac (continent, location, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.population, MAX(vac.new_vaccinations)
, MAX(SUM(CONVERT(bigint,vac.new_vaccinations))) OVER (Partition by dea.location ORDER By dea.location) AS RollingPeopleVaccinated
FROM PortfolioProject..[covid deaths] dea
JOIN PortfolioProject..[covid vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac;
**/



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER By dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..[covid deaths] dea
JOIN PortfolioProject..[covid vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;



--Creating View to store data for later visualizations


Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER By dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..[covid deaths] dea
JOIN PortfolioProject..[covid vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated;