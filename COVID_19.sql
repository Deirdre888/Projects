SELECT * FROM project_portfolio.covid_deaths_africa;


# INSIGHT 1: Countries with highest death in a day in Africa
select location, max(cast(new_deaths as signed)) as Highest_Death_In_A_Day 
from covid_deaths_africa
group by location
order by Highest_Death_In_A_Day desc; # we needed to change the datatype hence the cast() function
#OUTCOME 1: from the results of the code above, the country in Africa with the highest number of deaths is SouthAfrica and the least is Saint Helena

#INSIGHT 1A: day in which highest deaths occurred in each country in Africa
select location,date, cast(new_deaths as signed) as Highest_Death_In_A_Day 
from covid_deaths_africa
where (location,cast(new_deaths as signed)) in (select location, max(cast(new_deaths as signed)) from covid_deaths_africa
group by location)
order by Highest_Death_In_A_Day desc;
#OUTCOME 1A: this returns the days the highest number of deaths occurred in each country in Africa

-- select d1.location, d1.date, cast(d1.new_deaths as signed) as Highest_Death_In_A_Day 
-- from covid_deaths_africa d1
-- inner join
-- (select location , max(cast(new_deaths as signed)) as Highest_Death_In_A_Day  from covid_deaths_africa d2
-- group by location)
-- on
-- d1.location = d2.location
-- and
-- cast(d1.new_deaths as signed) = cast(d2.new_deaths as signed)
-- order by Highest_Death_In_A_Day desc;


-- syntax for using joins
-- select location, date, new_deaths
-- from covid_deaths_africa
-- left join highest_death_per_day
-- on covid_deaths_africa.location = highest_death_per_day.location; 
-- -- and covid_deaths_africa.new_deaths = highest_death_per_day.Highest_death_per_day



#INSIGHT 2: Countries with the highest number of deaths in Africa
select location, max(cast(total_deaths as signed)) as Highest_Total_Number_Of_Deaths
from covid_deaths_africa 
group by location 
order by Highest_Total_Number_Of_Deaths desc;
#outcome 2: Country with the highest total amount of deaths in Africa is SouthAfrica

-- INSIGHT 2A: the outcome from insight 2 can also be gotten using the sum function on the new_death column  
select location, sum(cast(new_deaths as signed)) as Highest_Total_Number_Of_Deaths
from covid_deaths_africa 
group by location 
order by Highest_Total_Number_Of_Deaths desc;
#OUTCOME 2A: same as outcome 2


#INSIGHT 2B: death_delta
with death_delta(location,date, Number_Of_Deaths, change_in_death_with_previous_day) 
as
(
select location,date,  cast(new_deaths as signed) as Number_Of_Deaths, 
cast(new_deaths as signed) - lag(cast(new_deaths as signed)) over (partition by location order by date) change_in_death_with_previous_day
from covid_deaths_africa 
)
select *, change_in_death_with_previous_day/Number_Of_Deaths*100 as Percentage_change_in_death
from death_delta;
#OUTCOME 2B:


#INSIGHT 3: Countries with highest population decrease due to covid19 pandemic
select location, max(cast(total_deaths as unsigned))/population*100 as Highest_Population_Decrease
from covid_deaths_africa 
group by location 
order by Highest_Population_Decrease desc;
#OUTCOME 3: Population of SouthAfrica reduced by approximately 0.092%  due to covid_19 deaths 

#INSIGHT 4: Countries with the highest total number of new cases
select location, sum(cast(new_cases as signed)) as Total_Number_Of_Cases
from covid_deaths_africa 
group by location 
order by Total_Number_Of_Cases desc;
#OUTCOME 4: from results, southAfrca had the highest number of cases


#INSIGHT 5: countries with highest number of cases in a day and the date it occurred
select location,date, cast(new_cases as signed) as Highest_Cases_In_A_Day 
from covid_deaths_africa
where (location,cast(new_cases as signed)) in (select location, max(cast(new_cases as signed)) from covid_deaths_africa
group by location)
order by Highest_Cases_In_A_Day desc;
#OUTCOME 5:  with 21,980 on aug 1, 2021 SothAfrica hasd the highest number of cases is a day.


#INSIGHT 6: Percentage of death amongst the new cases and percentage of peope who recovered per country
select location, sum(cast(new_cases as signed)) as Total_Cases, sum(cast(new_deaths as signed)) as Total_Deaths, sum(cast(new_deaths as signed))/sum(cast(new_cases as signed))*100 as Percentage_deaths, 100 - sum(cast(new_deaths as signed))/sum(cast(new_cases as signed))*100 as Percentage_recovered
from covid_deaths_africa 
group by location 
order by Percentage_deaths, Percentage_recovered;
#OUTCOME 6: from results, Sudan had the highest number of death Percentage amongst the people that got infected in the country.

-- Covid Vaccinations Table 
SELECT * FROM project_portfolio.covidvaccinations_africa;
# Joining the covid_deaths_africa and covidvaccinations_africa table together
#Task 7: Join the covid_deaths_africa and covidvaccinations_africa table together on location and date
select *
from covid_deaths_africa t1
join covidvaccinations_africa t2
on t1.location = t2.location
and t1.date = t2.date;
#OUTCOME 7: returns joined tables t1 and t2


#INSIGHT 8: perentage of the population vaccinated
select t1.location, t1.population, max(cast(t2.people_vaccinated as signed)) as maximum_number_of_people_vaccinated, max(cast(t2.people_vaccinated as signed))/t1.population*100 as Percentage_Vaccinated
from covid_deaths_africa t1
join covidvaccinations_africa t2
on t1.location = t2.location
and t1.date = t2.date
group by t1.location
order by maximum_number_of_people_vaccinated desc;
#OUTCOME 8: Morocco has the highest number of people vaccinated


#INSIGHT 9: percentage of population fully vaccinated
select t1.location, t1.population, max(cast(t2.people_fully_vaccinated as signed)) as maximum_number_of_people_fully_vaccinated, max(cast(t2.people_fully_vaccinated as signed))/t1.population*100 as Percentage_fully_Vaccinated
from covid_deaths_africa t1
join covidvaccinations_africa t2
on t1.location = t2.location
and t1.date = t2.date
group by t1.location
order by maximum_number_of_people_fully_vaccinated desc;
#OUTCOME 9: Morrocco has the highest number of people fully vaccinated.


#INSIGHT 10: summing the total number of people vaccinnated by location
select t1.location, t1.date,t1.population,t2.new_vaccinations, sum(cast(t2.new_vaccinations as signed)) over (partition by t1.location order by t1.location,t1.date) as Sum_of_People_vaccinated_per_Country
from covid_deaths_africa t1
join covidvaccinations_africa t2
on t1.location = t2.location
and t1.date = t2.date
-- group by location
order by 1,2;


#INSIGHT 11: USING CTE TO CALCULATE THE % PEOPLE VACCINATED PER POPULATION
with Percentage (location, date, population, new_vaccinations, Sum_of_People_vaccinated_per_Country)
as
(
select t1.location, t1.date,t1.population,t2.new_vaccinations, sum(cast(t2.new_vaccinations as signed)) over (partition by t1.location order by t1.location,t1.date) as Sum_of_People_vaccinated_per_Country
from covid_deaths_africa t1
join covidvaccinations_africa t2
on t1.location = t2.location
and t1.date = t2.date
)
select *, Sum_of_People_vaccinated_per_Country/population*100 as Percentage_Vaccinated
from Percentage;




-- select t1.location, t1.population, max(cast(t2.people_fully_vaccinated as signed)) as maximum_number_of_people_fully_vaccinated, max(cast(t2.people_fully_vaccinated as signed))/t1.population*100 as Percentage_fully_Vaccinated
-- from covid_deaths_africa t1
-- join covidvaccinations_africa t2
-- on t1.location = t2.location
-- and t1.date = t2.date
-- where cast(t2.people_fully_vaccinated as signed) in (select max(cast(people_fully_vaccinated as signed)) from covidvaccinations_africa where max(cast(t2.people_fully_vaccinated as signed)) = 0)   
-- group by t1.location
-- order by maximum_number_of_people_fully_vaccinated desc;

-- select all location, case when min(cast(people_fully_vaccinated as signed) = 0) then 0 else min(cast(people_fully_vaccinated as signed)) end
-- from covidvaccinations_africa;


























































#INSIGHT 4:
#OUTCOME 4:
-- where location like "%Nigeria%"