
--For viewing full table 

Select *
From Covidprojects..coviddeaths
Where continent is not null 
order by 3,4

--Showing percent of worldwide population who got infected

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Covidprojects..CovidDeaths
order by 1,2

--Showing countries having more cases

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covidprojects..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Showing countries  with highest total death count 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covidprojects..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Showing continents total death count 

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covidprojects..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Worldwide cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covidprojects..CovidDeaths
where continent is not null 
order by 1,2

--People who got vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
From Covidprojects..CovidDeaths dea
Join Covidprojects..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Using CTE on previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
From Covidprojects..CovidDeaths dea
Join Covidprojects..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (TotalPeopleVaccinated/Population)*100 as PercentofVaccinatedPopulation
From PopvsVac


--Now creating temp table for same query

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
From Covidprojects..CovidDeaths dea
Join Covidprojects..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (TotalPeopleVaccinated/Population)*100 as PercentofVaccinatedPopulation
From #PercentagePopulationVaccinated

--Creating view

USE [Covidprojects]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW PercentagePopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
From Covidprojects..CovidDeaths dea
Join Covidprojects..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

go