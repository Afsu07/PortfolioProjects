select *
from PortfolioProject.dbo.CovidDeaths$
where continent is not null 
order by 3,4

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths$
order by 1,2


-- total cases vs total deaths
Select location, date, total_cases ,total_deaths,(total_deaths/total_cases)* 100 Death_persentage
from PortfolioProject.dbo.CovidDeaths$
where location like '%states%'
order by 1,2



-- total cases vs population
Select location, date, population, total_cases ,(total_cases/population)* 100 Death_persentage
from PortfolioProject.dbo.CovidDeaths$
where location like '%states%'
order by 1,2


-- looking at contries with highest infection rate comatre to population

Select location, population,max(total_cases) as highestinfection , max((total_cases/population))* 100 percentagepopulationinfected
from PortfolioProject.dbo.CovidDeaths$
group by location, population
order by percentagepopulationinfected desc



-- showing countries with highest death count per population

Select location, max(cast(total_deaths as int)) as total_death_counts
from PortfolioProject.dbo.CovidDeaths$
where continent is not null 
group by location
order by total_death_counts desc



--lets breake things down by continents
Select location, max(cast(total_deaths as int)) as total_death_counts
from PortfolioProject.dbo.CovidDeaths$
where continent is null 
group by location
order by total_death_counts desc


--global numbers

Select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 death_percentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2


Select   sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 death_percentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
order by 1,2


-- total vaccination vs population

with PopvsVac(continent, location, date, population, new_vaccinations ,rolling_people_vaccination)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as rolling_people_vaccination
from PortfolioProject.dbo.CovidDeaths$ death
join  PortfolioProject.dbo.CovidVaccinations$ vac
	on death.location = vac.location
	and death.date = vac.date
	where death.continent is not null
--order by 1,2,3
)


--use CTE
select *, (rolling_people_vaccination/population)*100
from PopvsVac



--TEMP table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(50),
location  varchar(50),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)


insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as rolling_people_vaccination
from PortfolioProject.dbo.CovidDeaths$ death
join  PortfolioProject.dbo.CovidVaccinations$ vac
	on death.location = vac.location
	and death.date = vac.date
	where death.continent is not null
--order by 1,2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated

--create views

CREATE VIEW percentpopulationvaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date) as rolling_people_vaccination
from PortfolioProject.dbo.CovidDeaths$ death
join  PortfolioProject.dbo.CovidVaccinations$ vac
	on death.location = vac.location
	and death.date = vac.date
	where death.continent is not null
--order by 1,2,3

SELECT *
from percentpopulationvaccinated
