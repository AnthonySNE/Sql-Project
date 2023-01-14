--Select *
--From PortfolioProject..CovidDeaths
--order by location, date

--Select *
--From portfolioproject..CovidVaccinations
--order by location, date

--Select * 
--From portfolioproject..NewCovidDeaths
--where iso_code = 'GRD' and year(date) = 2020

--select *
--From portfolioproject..NewCovidDeaths
--order by 3,4

--select *
--From portfolioproject..NewCovidVaccinations
--order by 3,4


Select Location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.NewCovidDeaths
order by location, date

-- Total Cases VS Total Deaths

Select Location, Date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as percentage_death
from PortfolioProject..NewCovidDeaths
where location like '%states%' and year(date) = 2022
order by 1,2 desc

-- Total Cases vs Population

Select Location, Date, total_cases, population, ((total_cases/population)*100) as totalcases_percentage
from PortfolioProject..NewCovidDeaths
where location like '%states%' and year(date) = 2020
order by 1,2 desc

Select Location, Date, total_cases, population, ((total_cases/population)*100) as totalcases_percentage
from PortfolioProject..NewCovidDeaths
where location like '%states%' 
order by 1,2 desc
-- Total Deaths and percentages
Select Location, population, max(total_cases) as highest_cases,(max(total_cases/population)*100) as Percentage_pop_infected
from PortfolioProject..NewCovidDeaths
group by location, population
order by 4 desc


Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..NewCovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc


-- 1 Global 

Select  sum(new_cases) as tot_new_cases, sum(cast(new_deaths as int)) as tot_new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage_Global
From PortfolioProject..NewCovidDeaths
where continent is not null
--group by date
order by 1,2

-- Total Population vs Vaccinations
select * 
From PortfolioProject..NewCovidVaccinations;



with PopvsVacc (continent, location, date, population, new_vaccinations, Rolling_count_people_Vacc)
as
(
Select D.continent, D.location, d.date, d.population, V.new_vaccinations
, sum(cast( v.new_vaccinations as bigint)) over (partition by D.location order by d.location, d.date) as Rolling_count_people_Vacc
--,(Rolling_count_people_Vacc/100)
From PortfolioProject..NewCovidDeaths as D
join PortfolioProject..NewCovidVaccinations as V
on D.location = V.location and D.date = V.date 
where d.continent is not null 
--order by 2,3 
)
Select *, (Rolling_count_people_Vacc/population)*100 percentagevacc
From PopvsVacc


--Temp Tables

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..NewCovidDeaths dea
Join PortfolioProject..NewCovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as vaccinepercentadministered
From #PercentPopulationVaccinated




Select v.continent, v.location, v.date, (cast(v. people_vaccinated as bigint)) as PeopleVacc, d.population
, (v.people_vaccinated/d.population)*100 as percentVaccinated
From PortfolioProject..NewCovidVaccinations as v
join PortfolioProject..NewCovidDeaths as d
	on v.location = d.location
	and v.date = d.date
order by location, date





Create View PercentVaccineAdministered as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..NewCovidDeaths dea
Join PortfolioProject..NewCovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3




Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..NewCovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..NewCovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International','High Income', 'upper middle income', 'lower middle income', 'low income')
Group by location
order by TotalDeathCount desc


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..NewCovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc