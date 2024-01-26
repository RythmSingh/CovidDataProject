SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECTING DATA WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWING LIVELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNRY
-- CURRENTLY WE ARE DEALING WITH DEATH PERCENTAGE OF INIDA DURING COVID

SELECT  location,  date,  total_cases, total_deaths,
(CONVERT(FLOAT, total_deaths)/NULLIF(CONVERT(FLOAT, total_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%INDIA%' AND continent IS NOT NULL
ORDER BY 1,2

-- LOOKING AT TOTAL CASE VS POPULATION
-- SHOWS WHAT PERCENTAGE OF COVID GET INFECTED

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%INDIA%'
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- AND HERE ACTUALLY SOMETHING IS GONE WRONG SO TRIED USING CONTINENT AS NULL AND WE GOT CORRECT INFORMATION

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths ) AS TotalDeaths,
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- LOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY D.Location ORDER BY D.LOCATION, D.DATE) AS ROLLINGPeopleVaccinaetd
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL AND D.location LIKE '%INDIA%'
ORDER BY 1,2,3

--USING CTE

WITH PopVSVac (Continent, location, date, population, new_vaccinations, ROLLINGPeopleVaccinated)
AS
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY D.Location ORDER BY D.LOCATION, D.DATE) AS ROLLINGPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL 
)
SELECT *, (ROLLINGPeopleVaccinated/population)*100
FROM PopVSVac

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY D.Location ORDER BY D.LOCATION, D.DATE) AS ROLLINGPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location
AND D.date = V.date

SELECT *, (ROLLINGPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR VISULISATION

USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY D.Location ORDER BY D.LOCATION, D.DATE) AS ROLLINGPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccinations AS V
ON D.location = V.location
AND D.date = V.date
WHERE D.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated