use portfolioproject
select *
from PortfolioProject.dbo.CovidDeaths$ 
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVaccinations$
--order by 3,4

--Select Data

select location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths$
order by 1,2

---Looking at Total Cases vs Total Deaths
--Shows likelihood of dying in a specific country

select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where location like '%india%'
where continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of Population has covid

select location, date,total_cases,total_deaths,population,(total_cases/population)*100 as PercentageInfected
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
--where (location like '%india%') or (location like '%states%')
order by 1,2

--Looking at Countries with highest Infeciton Rate compared to Population

select location,population,max(total_cases)as HighestInfectionCount, max((total_cases/population))*100 as MaxPercentageInfected
from PortfolioProject.dbo.CovidDeaths$
--where (location like '%india%') or (location like '%states%')
where continent is not null
group by location,population
order by MaxPercentageInfected desc



--Looking at Countries with highest Death Count per Population

select location,max(cast(total_deaths as int))as HighestDeathCount
--, max((total_deaths/population))*100 as MaxMortalityRate
from PortfolioProject.dbo.CovidDeaths$
--where (location like '%india%') or (location like '%states%')
where continent is not null
group by location
order by HighestDeathCount desc

--Seeing highest death counts per population with respect to continents

select continent,max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
--where (location like '%india%') or (location like '%states%')
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from PortfolioProject.dbo.CovidDeaths$
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2



--Looking at Total Population vs Vaccinations (forming a cumulative (rolling) sum of the vaccinations)

select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingSum
from PortfolioProject.dbo.CovidDeaths$ dea 
join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Looking at Total Population vs Total Vaccinations using CTE

with PopVsVac (continent,location,date,new_vaccinations,population,RollingSum)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingSum
from PortfolioProject.dbo.CovidDeaths$ dea 
join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

select *,(RollingSum/population)*100
from PopVsVac


--TEMP TABLE

DROP TABLE #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
new_vaccinations numeric,
population numeric,
RollingSum numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingSum
from PortfolioProject.dbo.CovidDeaths$ dea 
join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *,(RollingSum/population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualization

Create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingSum
from PortfolioProject.dbo.CovidDeaths$ dea 
join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 