SELECT *
from covidproject..coviddeaths 
order by 1,2
-- order by 1,2

-- selection of columns
SELECT location, date, total_cases, new_cases, total_deaths ,population FROM covidproject..coviddeaths order by 1,2

-- finding death percentage
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage 
FROM covidproject..coviddeaths 
order by 1,2

-- finding death percentage of india
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM covidproject..coviddeaths
where location='India';


-- percentage of people getting infected in India
SELECT location, date, total_cases, population, (total_cases/population)*100 as percentagePeopleInfected
FROM covidproject..coviddeaths 
where location='India';


-- looking at countries with highest infection rate to population
SELECT location, population, max(total_cases) as highinfectedcount, max(total_cases/population)*100 as higestInfectedpercentage
FROM covidproject..coviddeaths 
group by location,population 
order by higestInfectedpercentage desc;


-- looking at countries with highest death count per population
-- removing null values from continent as some continents were present in location
SELECT location, max(cast(total_deaths as int)) as totaldeathcount FROM covidproject..coviddeaths 
where continent is null
group by location
order by totaldeathcount desc


-- now grouping by continent
SELECT continent, max(cast(total_deaths as int)) as totaldeathcount FROM covidproject..coviddeaths 
where continent is not null
group by continent 
order by totaldeathcount desc

-- now seeing the global data
-- on each day how many cases were recorded ie cases recorded per day
-- globally total deaths vs total cases
SELECT date,sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage 
FROM covidproject..coviddeaths 
where continent is not null
group by date
order by 1,2

-- total number of cases in the world
SELECT sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage 
FROM covidproject..coviddeaths 
where continent is not null
order by 1,2

-- looking at population vs vaccinations done
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM covidproject..coviddeaths dea 
join covidproject..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- adding new vaccinations each day so that we get total of it each day
-- doing order by date it will separate it out by each day (like cdf values)
-- partiton by location it will sum it for a particular country and then do the same for another

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations)) OVER (partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccinated
FROM covidproject..coviddeaths dea 
join covidproject..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date 
where dea.continent is not null
order by 2,3

-- percentage of people getting vaccinated
-- cte

with PopvsVac (continent,location,date,population,new_vaccinations,rollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations))OVER (partition by dea.location Order by dea.location,
dea.date) as rollingPeopleVaccinated
FROM covidproject..coviddeaths dea 
join covidproject..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
-- order by 2,3
)
select *,(rollingPeopleVaccinated/population)*100
from PopvsVac

-- using temp table

drop table if exists #PersonPopulationVaccinated
create table #PersonPopulationVaccinated
(
continent varchar(100),
location varchar(100),
date DateTime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric,
)
insert into #PersonPopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations))OVER (partition by dea.location Order by dea.location,
dea.date) as rollingPeopleVaccinated
FROM covidproject..coviddeaths dea 
join covidproject..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
-- order by 2,3
select *,(rollingPeopleVaccinated/population)*100
from #PersonPopulationVaccinated

-- creating view for later visualization

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,new_vaccinations))OVER (partition by dea.location Order by dea.location,
dea.date) as rollingPeopleVaccinated
FROM covidproject..coviddeaths dea 
join covidproject..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
-- order by 2,3

 

select continent,location,date,new_tests 
from covidproject..covidvaccinations
where continent is not null
order by 1,2

select * 
from covidproject..covidvaccinations