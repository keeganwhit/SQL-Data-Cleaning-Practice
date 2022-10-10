------------------------------------------------------------
-- Changing the DateTime format to Date for the SaleDate column

Select *
From covidproject..nash


select SaleDate, convert(date, SaleDate)
from covidproject..nash

--creating new column 
alter table nash
add SaleDateConverted Date;

--adding SaleDate info into new column with the Date format
Update nash
set SaleDateConverted = convert(date, SaleDate)

--Removing the old SaleDate column
Alter table nash
drop column SaleDate;

----------------------------------------------------------
-- Filling the null property addresses

select propertyaddress
from covidproject..nash
order by parcelID

-- Selects the ParcelID's that have null as property addresses
select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from covidproject..nash a
join covidproject..nash b
	on a.parcelID = b.parcelID
	and a.[uniqueID ]<>b.[UniqueID ]
where a.propertyaddress is null

-- Updates the null property address with the property address of the same ParcelID
update a
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from covidproject..nash a
join covidproject..nash b
	on a.parcelID = b.parcelID
	and a.[uniqueID ]<>b.[UniqueID ]
where a.propertyaddress is null

------------------------------------------------------------
-- Breaking up addresses into address, city, state

select propertyaddress
from covidproject..nash

-- Finds the commas in an address and splits it into address and city
select 
substring(propertyaddress, 1, charindex(',', propertyaddress)-1) as address,
substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress)) as AddressCity
from covidproject..nash

-- Creates tables and adds the info for property address and property city
alter table nash
add SplitPropertyAddress Nvarchar(255);

Update Nash
set SplitPropertyAddress = substring(propertyaddress, 1, charindex(',', propertyaddress)-1) 

alter table nash
add SplitPropertyCity Nvarchar(255);

Update Nash
set SplitPropertyCity = substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress))


select *
from covidproject..nash

-- Switches the commas in an address with periods so parsename can split the address into owner address, owner city, and owner state
select
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from covidproject..nash

-- Creates tables and adds the info for owner address, owner city, and owner state
alter table nash
add SplitOwnerState Nvarchar(255);

Update Nash
set SplitOwnerState = parsename(replace(owneraddress,',','.'),3)

alter table nash
add SplitOwnerCity Nvarchar(255);

Update Nash
set SplitOwnerCity = parsename(replace(owneraddress,',','.'),2)

alter table nash
add SplitOwnerAddress Nvarchar(255);

Update Nash
set SplitOwnerAddress = parsename(replace(owneraddress,',','.'),1)

Select *
from covidproject..nash

-------------------------------------------------------------------
-- Removes duplicate properties
-- selects all the duplicates
with rownumcte as (
Select *,
	row_number() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDateConverted,
				Legalreference
				order by uniqueID ) row_num

from covidproject..nash
)
select *
from rownumcte
where row_num > 1
order by propertyaddress

--removes all the duplicates
with rownumcte as (
Select *,
	row_number() over(
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDateConverted,
				Legalreference
				order by uniqueID ) row_num

from covidproject..nash
)
delete
from rownumcte
where row_num > 1
