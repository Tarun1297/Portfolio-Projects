--Covid_data_new contains the data about the new cases coming in and the number of deaths.
--Covid-vaccinations contain various information about the people being vaccinated.

Select  *
From PortfolioProject..covid_data_new$
where continent is not null
order by 3,4

Select * 
from PortfolioProject..['covid-vaccinations$']
order by location,date


--Select the data we are going to use

Select location,date,total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_data_new$
order by location,date

-- Looking at Total Cases Vs Total Deaths in a Country
-- Shows the Likelihood of Dying if you retract Covid in your Country
Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..covid_data_new$
where location = 'India'
order by location,date

--Looking at Total Cases Vs the Population
--What percentage of people have got Covid
Select location,date,population,total_cases, (total_cases/population)*100 as covidPercent
From PortfolioProject..[covid_data_new$]
--where location = 'India'
order by location,date

--Looking at countries with highest infection rate compared to the population
Select location,population,max(total_cases) as highestInfectionCount,max((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..[covid_data_new$]
Group by location, population
order by PercentPopulationInfected DESC


--We look at the highest death count per population
Select location,max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[covid_data_new$]
where continent is not null
Group by location
order by TotalDeathCount DESC

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[covid_data_new$]
where continent is not null
Group by continent
order by TotalDeathCount DESC
-- Looks like the data contained in North America includes only data from United States


--This query would return the true number of cases in terms of continents
--Showing the continents with highest death counts
Select location,max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[covid_data_new$]
where continent is null
Group by location
order by TotalDeathCount DESC

--Global Numbers day by day

Select date,sum(new_cases) as DailyCases, SUM(CAST(new_deaths as int)) as DailyDeaths, (SUM(CAST(new_deaths as int))/ sum(new_cases) *100) as DeathPercent
--We use the cast operator because new_deaths is of nvarchar type and we need to convert it into int
From PortfolioProject..[covid_data_new$]
--where location = 'India'
where continent is not null
Group by date 
Order By 1,2


--Using the Covid Vaccinations Table

--Joining the 2 tables
Select * 
From PortfolioProject..[covid_data_new$] dea
Join PortfolioProject..['covid-vaccinations$'] vac
 on dea.location = vac.location
 and dea.date = vac.date


 --Looking at the Total Population and Vaccinations
 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated

From PortfolioProject..[covid_data_new$] dea
Join PortfolioProject..['covid-vaccinations$'] vac
 on dea.location = vac.location
 and dea.date = vac.date
 
 where dea.continent is not null
 --and vac.new_vaccinations is not null
 --and dea.location = 'Albania'
 order by 2,3

 --Creating a CTE to find out the % people vaccinated on a rolling basis
 with PopvsVac(continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
 (
  --Looking at the Total Population and Vaccinations
 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated

From PortfolioProject..[covid_data_new$] dea
Join PortfolioProject..['covid-vaccinations$'] vac
 on dea.location = vac.location
 and dea.date = vac.date

 where dea.continent is not null
 --and vac.new_vaccinations is not null
 
 --order by 2,3
 )

 Select *, (RollingPeopleVaccinated/population) *100 as RollingPercentVaccinated
 from PopvsVac
 order by 2,3 


 ---Using the temp tables to perform the above function
 --Temp Table

 DROP Table if exists #percentpeopleVaccinated
 Create Table #percentpeopleVaccinated
 (
 Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
 )


 Insert Into #percentpeopleVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_data_new$ dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #percentpeopleVaccinated

--Creating view to store the same data as above for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_data_new$ dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select * from PercentPopulationVaccinated
where continent is not null 
order by 2,3
