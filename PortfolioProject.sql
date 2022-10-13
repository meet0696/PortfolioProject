-- Covid Death Table
Select * from CovidDeaths Where continent is not null Order by 3
--Covid Vaccination Table
Select * from CovidVaccinations Order by 3

--Using Covid Death Table 
Select location, Date, total_cases,new_cases,total_deaths, population 
from CovidDeaths Where continent is not null Order by location, date

--Total Cases Vs Total Deaths
Select location, Date, total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPerCases 
from CovidDeaths
Where location = 'India' and continent is not null
Order by location, date

-- Total Cases Vs Total Population(Precentage of Populations got Covid)
Select location, Date, total_cases,total_deaths, Population, (total_cases/population)*100 As CasesPerPopulation 
from CovidDeaths
Where location = 'India' and continent is not null
Order by location, date

-- Countries with Highest Infection Rate Compared to Population
Select location,Population, Max (total_cases) As HighestInfection_Count,  Max (total_cases/population)*100 As PercentPopulationInfected
from CovidDeaths
Where continent is not null
Group by location , Population
Order by PercentPopulationInfected desc


-- Countries with Highest Death Count Per Population
Select location,Max(Cast(total_deaths as int)) As Highest_Death
from CovidDeaths
Where continent is not null
Group by location
Order by Highest_Death desc

-- Highest Death Count by Continent
Select location,Max(Cast(total_deaths as int)) As Highest_Death
from CovidDeaths
Where continent is null
Group by location
Order by Highest_Death desc

--Select continent,Max(Cast(total_deaths as int)) As Highest_Death
--from CovidDeaths
--Where continent is not null
--Group by continent
--Order by Highest_Death desc

-- Global Numbers of Cases and Death
Select Sum(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/ SUM (new_cases)*100 As DeathPerCases 
from CovidDeaths
Where continent is not null
Order by 1,2

--Select Sum(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/ SUM (new_cases)*100 As DeathPerCases 
--from CovidDeaths
--Order by 1,2


-- Using Vaccinations Table For JOIN

--Total Population Vs Vaccinations
--Select * from CovidVaccinations CV Join CovidDeaths CD On CV.location = CD.location and CV.date = CD.date

Select CD.continent,CD.location,CD.date,CD.population, CV.total_vaccinations 
from CovidVaccinations CV Join CovidDeaths CD On CV.location = CD.location and CV.date = CD.date
Where CD.continent is not null
Order by 2,3

Select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations,SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location Order By CD.location, CD.Date) as RollingCountVaccinated
from CovidVaccinations CV Join CovidDeaths CD On CV.location = CD.location and CV.date = CD.date
Where CD.continent is not null
Order by 2,3

--Using CTE to update query
With popvsvac (continent,location,date,population,new_vaccinations, RollingCountVaccinated)
as(
Select CD.continent,CD.location,CD.date,CD.population, CV.new_vaccinations,SUM(CONVERT(int,CV.new_vaccinations)) OVER (Partition by CD.location Order By CD.location, CD.Date) as RollingCountVaccinated
from CovidVaccinations CV Join CovidDeaths CD On CV.location = CD.location and CV.date = CD.date
Where CD.continent is not null
)
Select *, (RollingCountVaccinated/population)*100 as PercentageVaccinated From popvsvac

--Using Temp Table for above query
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to Store Data for Later Visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select * From PercentPopulationVaccinated





