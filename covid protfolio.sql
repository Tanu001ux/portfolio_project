select * from CovidDeaths
select * from CovidVactinations

-----select Data that we are going to be useing 


select Location,date,total_cases,new_cases,total_deaths,population from CovidDeaths
where continent is not null
order by 3,4


---Looking at Toatal Cases Vs Total Deaths
--- Shows likelihood of daying if you contract covid in your country 
select Location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage from CovidDeaths
where location like '%states%'
 and continent is not null

order by 1,2

---Looking at the total cases vs Population 
--- shows what percentage of population got covid 

select Location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected from CovidDeaths
--where location like '%states%'
order by 1,2


----Looking at the countries with highest infection rate compared to population

select Location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
--where location like '%states%'
Group by location,population
order by PercentagePopulationInfected desc


-----Showing Countries With Highest Death Count Per Population 

select Location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by  TotalDeathCount desc

---LET'S BREAK THINGS DOWON BY CONTINENT 

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by  TotalDeathCount desc

----showing continents with the right highest death count per population 

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by  TotalDeathCount desc


----GLOBAL NUMBERS

select sum(New_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 from CovidDeaths
where continent is not null
--group by date
order by 1,2 

----looking at the total population vs vaccinations 

select dea.continent, dea.location, dea.date ,dea.population,
vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevactinated 
from CovidDeaths dea join CovidVactinations vac on 
dea.location =vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3
  
   ---USE CTE
   with popvsvac(Continent, Location, Date, Population,New_Vacctination, RollingPeopleVaccinated)
   as
   (
 select dea.continent, dea.location, dea.date ,dea.population,
vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevactinated 
from CovidDeaths dea join CovidVactinations vac on 
dea.location =vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
 )
 select *,(RollingPeopleVaccinated/Population)*100
 PopvsVac

 --TEMP TABLE

 CREATE table #percentagePopulationVaccinated 
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 insert into #percentagePopulationVaccinated 
 select dea.continent, dea.location, dea.date ,dea.population,
vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevactinated 
from CovidDeaths dea join CovidVactinations vac on 
dea.location =vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
  
  select *,(RollingPeopleVaccinated/Population)*100
  from #percentagePopulationVaccinated 

  ---creating view to store data for later visualizations

  create view #percentagePopulationVaccinated as
  select dea.continent, dea.location, dea.date ,dea.population,
vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations))over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevactinated 
from CovidDeaths dea join CovidVactinations vac on 
dea.location =vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select* from percentagePopulationVaccinated