--Covid 19 Data Exploration 

select *
From Covid..CovidDeaths
Where continent is not null
order by 3,4

select *
From Covid..CovidVaccinations
order by 3,4

--Select Data that we are going to be using:

Select Location, date, total_cases, new_cases, total_deaths, population
From Covid..CovidDeaths
order by 1,2;

-- Looking at Total Caes vs Total Deaths
-- Shows likelihood of dying if you contract covid in US

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Covid..CovidDeaths
where location like '%states%'
order by 1,2;

-- Looking at Total Caes vs Population
-- Shows what percentage of population got Covid in US

Select Location, date, Population,  total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Covid..CovidDeaths
--where location like '%states%'
order by 1,2;

--Looking at countries with Highest Infection Rate Compared to Population
--What countries have the highest infections rates compared to population?

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Covid..CovidDeaths
--where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid..CovidDeaths
--where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Covid..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2


Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Covid..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Joining our 2 tables together


Select *
From Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) 
as RollingPeopleVaccinated--,(RollingVaccinations/populations)*100
From Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.date) as RollingPeopleVaccinated
--,(RollingVaccinations/populations)*100
From Covid..CovidDeaths dea
join Covid..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select * 
From PercentPopulationVaccinated