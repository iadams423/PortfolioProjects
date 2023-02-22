--SELECT *
--FROM PortfolioProject..CovidDeaths
-- Where continent is not null
--order by 3,4 

--SELECT *
--FROM PortfolioProject..CovidDeaths
--order by 3,4 

-- Select Data that we're going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2 

-- Looking at the Total cases vs. Total Deaths
-- Showing likelihood of drying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS death_percentage
FROM PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, population, total_cases, ((total_cases/population) * 100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(((total_cases/population) * 100)) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
group by location,population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death count per population
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group By Location
Order By TotalDeathCount desc


-- Let's break things down by continent

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is null
Group By location
Order By TotalDeathCount desc

--Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 AS death_percentage
FROM PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group By date
order by 1,2



--Looking at Total Population vs. Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
order by 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as  RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE (Columns in With statement must equal columns in Select statement)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPplVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as  RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPplVaccinated/Population)*100 as VaccPercentage
From PopvsVac



-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPplVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as  RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null

SELECT *, (RollingPplVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store date for later visualizations
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as  RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null

Select *
FROM PercentPopulationVaccinated