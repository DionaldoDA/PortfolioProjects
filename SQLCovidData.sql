Select *
	From PortfolioProject..CovidDeaths$
	order by 3,4

--Select *
	--From Portfolio_Project..CovidVaccinations$
	--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2 --Organizes it from Location and Date

-- Looking at the Total Cases vs. Total Deaths (Way to find Ratio)
-- Shows likelihood of dying if you contract covid in your Country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage --Percentage/Ratio
From PortfolioProject..CovidDeaths$
WHERE location like '%Canada%' -- If you want to find only in Canada
order by 1,2 --Organizes it from Location and Date

-- Looking at the Total Cases vs. Population
-- Shows Infection Rate of Covid
Select Location, date,total_cases, (total_cases/population)*100 as Infection_Rate
From PortfolioProject..CovidDeaths$
-- WHERE location like '%Canada%' -- If you want to find only in Canada
order by 1,2 --Organizes it from Location and Date

-- Looking at Countries with Highest Infection Rate vs. Total Population

SELECT Location, Population, MAX(total_cases) as Highest_Infection_Rate, MAX((total_cases/population)) * 100 as Percent_Pop_Infected
FROM PortfolioProject..CovidDeaths$
GROUP by Location, population
Order by Percent_Pop_Infected DESC
-- Highest Country was Andorra with 17% infection rate

--  Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP by Location
Order by Total_Death_Count DESC
-- Highest was US 

-- BREAK IT DOWN BY CONTINENT'

-- Showing Continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
GROUP by continent
ORDER by Total_Death_Count DESC
-- North America being the highest, Oceania being the lowest

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths$
Where continent is not null 
ORDER by 1,2;

-- Vaccination Data

-- Percentage of Population that has received at least one Covid Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as People_Vacc
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations - going to be used with Tableau

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
