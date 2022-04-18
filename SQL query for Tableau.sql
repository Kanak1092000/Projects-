Select Location, date, population, total_cases, total_deaths
From Covidprojects..CovidDeaths
where continent is not null 
order by 1,2

--Showing percent of worldwide population who got infected

Select Location, Population, MAX(new_cases) as HighestInfectionCount,  Max((new_cases/population))*100 as PercentPopulationInfected
From Covidprojects..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--Showing deathpercentage

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
From Covidprojects ..CovidDeaths
where continent is not null 
group by date 
order by 1,2,3 desc

--Showing highest total death count 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covidprojects..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
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


 --Creating temp table for above query
 
 
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
