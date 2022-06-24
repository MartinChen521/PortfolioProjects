select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- select *
-- from PortfolioProject..CovidVaccination
-- order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date, total_cases,  total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid
select Location, date, total_cases,  Population, (Total_deaths/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%states'
order by 1,2

select Location, date, total_cases,  Population, (Total_deaths/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- Where location like '%states%'
order by 1,2

-- Looking at COuntries with Highest Infection Rate compared to Population
select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases)/population) *100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
-- Figuring out that the data might includes unexpected output e.g European Union, Africa
select Location,  max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc
 
-- Let's break things down by continent

select continent ,  max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
select  date, sum(new_cases) as total_cases ,  sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2

-- Total Global numbers until today 
select sum(new_cases) as total_cases ,  sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population) as 
From PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3
	
-- USE¡@CTE

With PopvsVac(Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPercentage
From PopvsVac


-- Creating View to store data for later Visualizations

Create View Percent



-- Temp Table

drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
	)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated


-- Create a View to store data for further data Vizs
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
JOIN  PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
-- order by 2,3

select *
From PercentPopulationVaccinated
