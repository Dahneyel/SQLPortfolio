SELECT *
FROM CovidDeaths
ORDER BY 3,4

--Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS InfectedPopulationPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC

--Countries with the highest death counts by population
SELECT Location, population, MAX(total_deaths) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathsCount DESC

SELECT Location, population, MAX(total_deaths) AS TotalDeathsCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location, population
ORDER BY TotalDeathsCount DESC

--Exploring the daily death rate

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS NewDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_cases != 0 AND new_deaths != 0
GROUP BY date
ORDER BY 1,2


SELECT * 
FROM CovidVacinations

--Joining both CovidDeaths and CovidVacination tables
SELECT *
FROM CovidDeaths dea
JOIN CovidVacinations vac
ON dea.date = vac.date
AND dea.location = vac.location


--Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVacinations vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Temp Table

CREATE TABLE #PercentPolationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
RollingPeopleVaccinated float
)

INSERT INTO #PercentPolationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVacinations vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Population vs Rolling Percentage of People Vaccinated
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePeopleVaccinated
FROM #PercentPolationVaccinated

-- Creating view for future visualization
CREATE VIEW PercentPolationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVacinations vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPolationVaccinated