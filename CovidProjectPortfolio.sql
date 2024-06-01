SELECT *
FROM PortfolioCovidProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4;

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioCovidProject.dbo.CovidDeaths
ORDER BY 1,2


-- Melihat data Total Cases vs Total Deaths
-- Menunjukan kemungkinan kematian jika tertular covid di negara Indonesia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioCovidProject.dbo.CovidDeaths
WHERE location like '%indo%'
AND continent IS NOT NULL
ORDER BY 1,2


-- Melihat data Total Cases vs Pupulation
-- Menunjukan berapa persen yang tertular covid dari total populasi
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioCovidProject.dbo.CovidDeaths
WHERE location like '%indo%'
AND continent IS NOT NULL
ORDER BY 1,2


-- Menunjukan negara dengan infeksi tertinggi berbandingkan jumlah populasi
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioCovidProject.dbo.CovidDeaths
--WHERE location like '%indo%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Menunjukan jumlah kematian tertinggi per jumlah populasi di suatu negara
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioCovidProject.dbo.CovidDeaths
--WHERE location like '%indo%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAK DOWN JUMLAH KEMATIAN BERDASARKAN CONTINENT/BENUA
SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioCovidProject.dbo.CovidDeaths
--WHERE location like '%indo%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Menunjukan continent/benua dengan jumlah kematian terbanyak per jumlah populasi
SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioCovidProject.dbo.CovidDeaths
--WHERE location like '%indo%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



--  Menunjukan jumlah kasus dan jumlah kematian secara global per hari
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS 
	DeathPercentage
FROM PortfolioCovidProject.dbo.CovidDeaths
--WHERE location like '%indo%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Menunjukan jumlah kasus dan jumlah kematian secara global
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS 
	DeathPercentage
FROM PortfolioCovidProject.dbo.CovidDeaths
--WHERE location like '%indo%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Melihat total Populasi vs total Vaksinasi
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
FROM PortfolioCovidProject.dbo.CovidDeaths AS dea
JOIN PortfolioCovidProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- 1.1 MENGGUNAKAN CTE UNTUK MELIHAT PRESENTASE DARI TOTAL VAKSINASI
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
FROM PortfolioCovidProject.dbo.CovidDeaths AS dea
JOIN PortfolioCovidProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPeopleVaccinated
FROM PopvsVac
ORDER BY 2,3;


-- 1.2 MENGGUNAKAN TEMPORARY TABLE UNTUK MELIHAT PRESENTASE DARI TOTAL VAKSINASI
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
FROM PortfolioCovidProject.dbo.CovidDeaths AS dea
JOIN PortfolioCovidProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPeopleVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2,3



-- Membuat view untuk data visualisasi
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
  dea.date) AS RollingPeopleVaccinated
FROM PortfolioCovidProject.dbo.CovidDeaths AS dea
JOIN PortfolioCovidProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated