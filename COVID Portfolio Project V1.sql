SELECT * FROM PortfolioProject..CovidDeaths$
	WHERE continent IS NOT NULL;


--SELECT * FROM PortfolioProject..CovidVaccinations$
--	ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population 
	FROM PortfolioProject..CovidDeaths$
		ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows percent chance of dying if you contract covid in your country.
SELECT location, date, total_cases, total_deaths, ROUND((Total_deaths/Total_cases)*100,4) AS percent_death
	FROM PortfolioProject..CovidDeaths$
	WHERE location like '%states%'
		ORDER BY 1,2;

-- Looking at Total Cases vs Population
--Shows what percent of population has contracted COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_of_population
	FROM PortfolioProject..CovidDeaths$
	WHERE location like '%states%'
		ORDER BY 1,2;

--Looking at Countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS Highest_infection_Count, population, (MAX(total_cases)/population)*100 AS highest_infection_rate
	FROM PortfolioProject..CovidDeaths$
		GROUP BY population, location
		ORDER BY highest_infection_rate DESC;

--Breakdown of total_death by Continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
	FROM PortfolioProject..CovidDeaths$
		WHERE continent IS NULL
			GROUP BY location
			ORDER BY total_death_count DESC;

--Showing country's with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death, MAX(population) AS Population, (MAX(CAST(total_deaths AS INT))/MAX(population)) AS percent_of_deaths
	FROM PortfolioProject..CovidDeaths$
		WHERE continent IS NOT null
		GROUP BY location
		ORDER BY total_death DESC;

-- Showing continents with the highest death counts
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
	FROM PortfolioProject..CovidDeaths$
		WHERE continent IS NULL
			GROUP BY location
			ORDER BY total_death_count DESC;

-- Global Numbers
SELECT date, SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths AS INT)) AS total_new_death, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS death_percentage
	FROM PortfolioProject..CovidDeaths$
		WHERE continent IS NOT NULL
			GROUP BY date
			ORDER BY 1,2;

--Combine CovidDeaths with CovidVaccines
SELECT * 
	FROM PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date;

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated,
	(rolling_people_vaccinated/population)
FROM PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
			WHERE dea.continent IS NOT NULL
				ORDER BY 2,3;

-- Use CTE
WITH popVSvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
	AS(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
			WHERE dea.continent IS NOT NULL)
SELECT *, (rolling_people_vaccinated/population)*100 FROM popVSvac

--Temp Table
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
			WHERE dea.continent IS NOT NULL

SELECT * FROM #PercentPopulationVaccinated


--Creating View For visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM PortfolioProject..CovidDeaths$ dea
	JOIN PortfolioProject..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
			WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated