-- COVID19 Exploratory Analysis using Microsoft SQL-SERVER Management Studio

-- Show Start and End Date
SELECT MIN(date) as 'Start Date', MAX(date) as 'End Date'  fROM SQLProject..CovidVaccinations;

-- Show Top 50 Records
SELECT TOP 50 * FROM SQLProject..CovidDeaths;
SELECT TOP 50 * FROM SQLProject..CovidVaccinations;

-- Global Numbers - Total Cases,Total Deaths, And Death Percentage
SELECT SUM(total_cases) AS Total_Cases, SUM(total_deaths) AS Total_Deaths,
SUM(total_deaths)/SUM(total_cases)*100 AS DeathPercentage
FROM (
		SELECT location, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths
		FROM SQLProject..CovidDeaths
		WHERE continent IS NOT NULL
		GROUP BY location
		HAVING MAX(total_cases) IS NOT NULL
	  ) AS Gbl_Numbers


-- List Of Countries Affected By Covid19
SELECT DISTINCT location AS 'List of Countries' FROM CovidDeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
ORDER BY location


-- Number Of Countries Affected By Covid19
SELECT COUNT(*) AS 'Number of Countries' FROM (
	SELECT DISTINCT location FROM CovidDeaths
		WHERE continent IS NOT NULL AND total_cases IS NOT NULL
) AS country_count



-- Date Of First Case Reported For Each Country 
SELECT location AS Country, MIN(date) AS FirstCaseReportedOn 
FROM CovidDeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY location
ORDER BY location

-- Date Of First Case Reported by INDIA
SELECT location AS Country, MIN(date) AS FirstCaseReportedOn 
FROM CovidDeaths
WHERE location='INDIA' AND total_cases IS NOT NULL
GROUP BY location
ORDER BY location

-- Total Cases Vs Total Deaths (All Countries) - Observing Change With Time
SELECT location AS Country, date, population, total_cases AS cases, total_deaths AS deaths,
(total_cases/population) * 100 AS PercentPopulationInfected,
(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
ORDER BY location, date, population


-- Total Case Vs Total Deaths (India) - Observing Change With Time 
SELECT location AS Country, date, total_cases AS cases, total_deaths AS deaths, 
ROUND((total_deaths/total_cases)*100, 4) AS DeathPercentage
FROM CovidDeaths
WHERE location = 'India'
ORDER BY date



-- CASES_SUMMARY: Isolating Total Cases, Total Deaths For Each Country
-- DROP view IF EXISTS cases_summary
CREATE VIEW cases_summary AS
SELECT location AS Country, population, 
MAX(total_cases) AS Total_Cases, 
MAX(total_deaths) AS Total_Deaths,
MAX(total_cases)/population*100 AS Infected_Population_Percentage, -- percentage of population infected
MAX(total_deaths)/population*100 AS Death_Population_Percentage,   -- percentage of population died due to covid
MAX(total_deaths)/MAX(total_cases)*100 AS Death_Percentage -- percentage of deaths out of total number of cases
FROM CovidDeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY location, population


-- Cases And Deaths Compared To Population
SELECT * FROM cases_summary 
ORDER BY Country, population


-- Cases And Deaths Compared To Population (India)
SELECT * FROM cases_summary WHERE Country = 'India'


-- Highest To Lowest Death Count
SELECT Country, population, Total_Deaths
FROM cases_summary
ORDER BY Total_Deaths DESC



-- Cases And Deaths - Continent Wise
SELECT location, MAX(total_cases) AS Total_Cases, MAX(total_deaths) AS Total_Deaths
FROM CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location



-- Vaccination data 
DROP TABLE IF EXISTS #covidVaccinations
SELECT vac.continent, vac.location, vac.date, vac.new_vaccinations, vac.total_vaccinations,  vac.people_vaccinated, vac.people_fully_vaccinated, dea.population
INTO #covidVaccinations
FROM SQLProject..CovidDeaths as dea JOIN SQLProject..CovidVaccinations as vac on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- Vaccination Start Date For Countries

SELECT location AS Country, MIN(date) AS VaccinationStartedOn
FROM #covidVaccinations
WHERE continent IS NOT NULL AND total_vaccinations IS NOT NULL AND total_vaccinations > 0 AND location = 'INDIA'
GROUP BY location
ORDER BY VaccinationStartedOn



-- Total No. Of People Vaccinated, Vaccination Percentage Of Population
SELECT location, population, 
MAX(people_vaccinated) AS PeopleVaccinated, 
MAX(people_vaccinated)/population*100 AS Percentage_of_population_vaccinated
FROM #covidVaccinations
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY location





-- Looking at Total Cases Vs Total Deaths
-- alter table CovidDeaths alter column total_cases float;

select location, date, cast(total_cases as float) as Total_Cases, cast(total_deaths as float) as Total_Deaths, (total_deaths/total_cases)*100 as 'Death Percentage' 
from CovidDeaths order by 1,2;

-- Looking at Total Cases Vs Total Deaths in India -- Shows the likelihood of dying if you have covid in India. 

select location, date, cast(total_cases as float) as Total_Cases , convert(float, total_deaths) as Total_Deaths, (total_deaths/total_cases)*100 as 'Death Percentage' 
from CovidDeaths where location ='India' order by 1,2;

-- Looking at the total Cases vs Population -- Shows what % of population infected by Covid

select location, cast(total_cases as float) as Total_cases, Population, (total_cases/population)*100 as 'Covid Infected Population%' 
from CovidDeaths where location ='India' order by 1,2;


-- Looking at countries with highest infection rate compared to population

select location, population, total_cases, Max((total_cases/population))*100 as Covid_Infected_Pop_Percent
from CovidDeaths group by location, population, total_cases order by Covid_Infected_Pop_Percent desc;



-- Showing countries with highest death count per population
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc;


-- Let's break things down by continent
-- Showing continents with the highest death count per population:

select continent, max(cast(Total_deaths as int)) as TotalDeathCount from CovidDeaths where continent is not null group by continent order by TotalDeathCount desc;

-- GLOBAL NUMBERS

select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths,
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Death_Percentage
from CovidDeaths 
where continent is not null 
order by 1,2;

-- INDIAN NUMBERS

select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths,
SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Death_Percentage
from CovidDeaths 
where location = 'India'
order by 1,2;


-- Joining Tables CovidVaccinations and Covid_Death:

-- Looking at Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from SQLProject..CovidDeaths as dea 
JOIN SQLProject..CovidVaccinations as vac 
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3;

-- Looking at Total Population Vs Vaccinations

select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date)
as 'Cumulative Vaccinated SUM'
from SQLProject..CovidDeaths as dea 
JOIN SQLProject..CovidVaccinations as vac 
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3;



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 From PopvsVac


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
From SQLProject..CovidDeaths dea
Join SQLProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- VACCINATION SUMMARY 
DROP TABLE IF EXISTS #vaccination_summary;

WITH cte_vaccination_summary (location, total_vaccinations, people_vaccinated, people_fully_vaccinated)
AS
(
	SELECT location,
	MAX(total_vaccinations),
	MAX(people_vaccinated),
	MAX(people_fully_vaccinated)
	FROM #covidVaccinations
	WHERE continent IS NOT NULL
	GROUP BY location
)
SELECT * INTO #vaccination_summary
FROM cte_vaccination_summary




-- TOP 5 countries with most people vaccinated (United States, India, United Kingdom, Brazil and Germany)

SELECT TOP 5 location
FROM #vaccination_summary
ORDER BY people_vaccinated DESC






-- COUNTRY DEMOGRAPHICS
DROP TABLE IF EXISTS #country_demographics ;

WITH cte_countryDemog(location, population, population_density, median_age, aged_65_older, aged_70_older, gdp_per_capita, extreme_poverty, human_development_index)
AS
(
	SELECT dea.location, 
	MAX(dea.population) AS population,
	MAX(vac.population_density) AS Population_Density,
	MAX(vac.median_age) AS Median_Age,
	MAX(vac.aged_65_older) AS Aged_65_Older,
	MAX(vac.aged_70_older) AS Aged_70_Older,
	MAX(vac.gdp_per_capita) AS Gdp_Per_Capita,
	MAX(vac.extreme_poverty) AS Extreme_Poverty,
	MAX(vac.human_development_index) AS Human_Development_Index
	FROM CovidDeaths as dea join CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date 
	WHERE dea.continent IS NOT NULL
	GROUP BY dea.location
)
SELECT * INTO #country_demographics 
FROM cte_countrydemog



-- COUNTRY HEALTH
DROP TABLE IF EXISTS #country_health

WITH cte_countryHealth (location, population, Stringency_Index, Cardiovascular_Death_Rate, Diabetes_Prevalence, Female_Smokers, Male_Smokers, Life_Expectancy)
AS
(
	SELECT dea.location,
	MAX(population) AS population,
	MAX(stringency_index) AS Stringency_Index,
	MAX(cardiovasc_death_rate) AS Cardiovascular_Death_Rate,
	MAX(diabetes_prevalence) AS Diabetes_Prevalence,
	MAX(female_smokers) AS Female_Smokers,
	MAX(male_smokers) AS Male_Smokers,
	MAX(life_expectancy) AS Life_Expectancy
	FROM CovidDeaths as dea join CovidVaccinations as vac on dea.location = vac.location and dea.date = vac.date 
	WHERE dea.continent IS NOT NULL
	GROUP BY dea.location
)
SELECT * INTO #country_health 
FROM cte_countryHealth


-- Above Countries With People Vaccinated and Percentage of population Vaccinated
SELECT vs.location, cd.population, vs.people_vaccinated AS people_vaccinated,
(vs.people_vaccinated/cd.population)*100 AS vaccinated_perc_of_population
FROM #vaccination_summary vs
JOIN #country_demographics cd
	ON vs.location = cd.location
WHERE vs.location IN (
					SELECT TOP 5 location
					FROM #vaccination_summary
					ORDER BY people_vaccinated DESC
					)
ORDER BY vaccinated_perc_of_population DESC



-- Comparing Diabetes Prevalence, Cardiovascular Death Rate To Death Percentage
SELECT cs.Country, ch.Cardiovascular_Death_Rate, ch.Diabetes_Prevalence, cs.Death_Percentage
FROM #country_health ch
JOIN cases_summary cs
	ON ch.location = cs.Country
ORDER BY Death_Percentage DESC


-- Comparing Smokers to Infected Population And Death Percentage
SELECT cs.Country, ch.Female_Smokers, ch.Male_Smokers, cs.Infected_Population_Percentage, cs.Death_Percentage
FROM #country_health ch
JOIN cases_summary cs
	ON ch.location = cs.Country
ORDER BY Male_Smokers DESC


-- Comparing Percentage Of Population Over 65 And 70 To Infected Population And Death Percentage
SELECT cs.Country, 
cd.aged_65_older AS Percetange_of_population_over_65,
cd.aged_70_older AS Percetange_of_population_over_70,
cs.Infected_Population_Percentage, cs.Death_Percentage
FROM #country_demographics cd
JOIN cases_summary cs
	ON cd.location = cs.Country
ORDER BY Percetange_of_population_over_65 DESC


