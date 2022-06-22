select * from [dbo].[Data1]
select * from [dbo].[Data2]

--number of rows in our dataset
select Count(*) from [dbo].[Data1]
select Count(*) from [dbo].[Data2]

--dataset for jharkhand and bihar
select * from [dbo].[Data1]
where state in ('Jharkhand' ,'Bihar')
--Alternative way
Select * from [dbo].[Data1]
where state = 'Jharkhand' or state = 'Bihar'
 --dataset for Uttar Pradesh and West Bengal
 Select * from [dbo].[Data1]
 where state = 'Uttar Pradesh' or state = 'West Bengal'


--Total Population of India
Select  SUM(Population) as 'total Pop' from [dbo].[Data2]

--Avg growth rate of India
Select AVG(Growth)*100 as 'Avg Growth' from [dbo].[Data1]

--Avg Growth with respect to States
Select state, AVG(Growth)*100 as 'Avg Growth' from [dbo].[Data1]
Group by state 

-- Avg sex ratio
Select state, round(Avg(Sex_Ratio),0) As ' Avg Sex Ratio' from [dbo].[Data1]
group by state
order by [ Avg Sex Ratio] Desc

--Avg literacy rate
select state, round(Avg(Literacy),0) as 'Avg Literacy rate' from [dbo].[Data1]
group by state
order by [Avg Literacy rate] desc

--states having literacy rate greater than 90
Select state, round(Avg(Literacy),0) as 'Avg Literacy rate'  from [dbo].[Data1]
group by state
Having round(Avg(Literacy),0) > 90
order by [Avg Literacy rate] desc

--top 3 states showing highest growth rate
Select top 3 state, Avg(Growth)*100  as 'Avg Growth Rate' from [dbo].[Data1]
group by state
order by [Avg Growth Rate] desc

--top 3 states showing lowest sex ratio
Select top 3 state, round(Avg(Sex_Ratio),0) As ' Avg Sex Ratio' from [dbo].[Data1]
group by state
order by [ Avg Sex Ratio] asc

--top and bottom 3 states in literacy rate

drop table if exists #topstates
create table #topstates
(state varchar(255),
topstate float
)

insert into #topstates
Select state, round(Avg(Literacy),0) as 'Avg Literacy rate'  from [dbo].[Data1]
group by state order by [Avg Literacy rate] desc

select top 3 state, topstate  from #topstates order by #topstates.topstate desc

drop table if exists #bottomstates
Create table #bottomstates
(state varchar(255),
bottomstate float
)
insert into #bottomstates
select state, round(Avg(Literacy),0) as 'Avg Literacy Rate' from [dbo].[Data1]
group by State
order by [Avg Literacy Rate] asc
select top 3 * from #bottomstates  order by #bottomstates.bottomstate asc

--union operator to joion #topstates and # bottomstates

select * from (
select top 3 state, topstate  from #topstates order by #topstates.topstate desc) a
union
select * from (select top 3 * from #bottomstates  order by #bottomstates.bottomstate asc) b


--states starting with letter A
select  Distinct(state) from [dbo].[Data1]
where State Like 'A%'

--states staring with letter A or B
select Distinct(state) from [dbo].[Data1]
where state like 'A%' or state like 'B%'

--states staring with letter A and ending with h
select distinct(state) from  [dbo].[Data1]
where state like 'A%h'

--joining both th tables

select [dbo].[Data1].District, [dbo].[Data1].State, sex_ratio, [dbo].[Data2].Population from [dbo].[Data1] inner join [dbo].[Data2]
on [dbo].[Data1].District = [dbo].[Data2].District

--finding the number of males and females

select a.state, a.district, round(a.population/(a.sex_ratio + 1),0) males, round((a.population*a.sex_ratio)/(a.sex_ratio + 1),0) females from
(select [dbo].[Data1].District, [dbo].[Data1].State, sex_ratio, [dbo].[Data2].Population from [dbo].[Data1] inner join [dbo].[Data2]
on [dbo].[Data1].District = [dbo].[Data2].District) a

--by states
select b.state, sum(b.males) total_males, sum(b.females)total_females from 
(select a.state, a.district, round(a.population/(a.sexratio + 1),0) males, round((a.population*a.sexratio)/(a.sexratio + 1),0) females from
(select [dbo].[Data1].District, [dbo].[Data1].State, sex_ratio/100 sexratio , [dbo].[Data2].Population from [dbo].[Data1] inner join [dbo].[Data2]
on [dbo].[Data1].District = [dbo].[Data2].District) a) b
group by b.State

--total literacy rate
select b.state, sum(b.litrate_people) total_litrate_people, sum(b.illterate_people) total_illtrate_people from
(select a.state, a.district, round(a.literacy_ratio*a.population,0) litrate_people, round((1-a.literacy_ratio)*a.population,0) illterate_people from
(select [dbo].[Data1].District, [dbo].[Data1].State, Literacy/100 literacy_ratio, [dbo].[Data2].Population from [dbo].[Data1] inner join [dbo].[Data2]
on [dbo].[Data1].District = [dbo].[Data2].District) a) b
group by b.State

--population in previous census

select sum(e.previous_census_population) previous_census_population, sum(e.current_census_population) current_census_population from
(select d.district, d.state, round(d.population/(1+d.Growth_rate),0) previous_census_population, d.population current_census_population from
(select [dbo].[Data1].District, [dbo].[Data1].State, Growth/100 Growth_rate, [dbo].[Data2].Population from [dbo].[Data1] inner join [dbo].[Data2]
on [dbo].[Data1].District = [dbo].[Data2].District) d) e
 
-- population vs area


select g.total_area/g.previous_census_population as previous_census_population_vs_area, g.total_area/g.current_census_population as current_census_population_vs_area from
(select q.*,r.total_area from (
select '1' as keyy,f. * from
(select sum(e.previous_census_population) previous_census_population, sum(e.current_census_population) current_census_population from
(select d.district, d.state, round(d.population/(1+d.Growth_rate),0) previous_census_population, d.population current_census_population from
(select [dbo].[Data1].District, [dbo].[Data1].State, Growth/100 Growth_rate, [dbo].[Data2].Population from [dbo].[Data1] inner join [dbo].[Data2]
on [dbo].[Data1].District = [dbo].[Data2].District) d) e) f ) q inner join (

select '1' as keyy,z. * from (
select sum(area_km2) total_area from [dbo].[Data2]) z) r on q.keyy=r.keyy)g

--window function

--output top 3 districts from each state with highest literacy rate
select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) rnk from [dbo].[Data1]) a
where a.rnk in(1,2,3) order by state










