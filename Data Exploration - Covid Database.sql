Select * From CovidDeaths
Order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths
-- Looking for dying percentage if you contract Covid in Colombia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentageByCases
From CovidDeaths
Where location like 'Colombia'
Order by 1,2

-- Looking for Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as SickPercentage
From CovidDeaths
Where location like 'Colombia' and continent is not null
Order by 1,2

-- Total Deaths vs Population
-- Shows what percentage of population in Colombia died 
Select location, date, total_deaths, population, (total_deaths/population)*100 as DeathPercentageByPopulation
From CovidDeaths
Where location like 'Colombia' and continent is not null
Order by 1,2

-- Looking at Countries with hightest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Where continent is not null
Group by location, population
Order by 3 desc

-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as HighestDeaths,  MAX((total_deaths/population))*100 as Percentage
From CovidDeaths
Where continent is not null
Group by location
Order by HighestDeaths desc

-- Showing Highest Death Count by Continent
Select location, MAX(cast(total_deaths as int)) as HighestDeaths,  MAX((total_deaths/population))*100 as Percentage
From CovidDeaths
Where continent is null
Group by location
Order by HighestDeaths desc

--GLobal numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Join CovidDeaths and CovidVaccinations
Select * 
From CovidDeaths join CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date

--Looking at Total Population vs Vaccinations
--Create Table with RollingPeopleVaccinatedPercentage
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
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
From CovidDeaths join CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From #PercentPopulationVaccinated

--Create View to store data for later visualizations
Create view PercentPopulationVaccinated as 
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
SUM(CONVERT(int, CovidVaccinations.new_vaccinations)) OVER (Partition by CovidDeaths.location Order by CovidDeaths.location, CovidDeaths.date) as RollingPeopleVaccinated
From CovidDeaths join CovidVaccinations
	on CovidDeaths.location = CovidVaccinations.location
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent is not null

