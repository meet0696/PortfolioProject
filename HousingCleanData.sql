----Cleaning House_Sale Data in SQL Queries 

Select * From HousingData

---Standardize Date Format 

ALTER TABLE HousingData
Add SalesDate Date;

Update HousingData
SET SalesDate = CONVERT(Date, SaleDate)

Select SalesDate, CONVERT(Date, SaleDate) 
From HousingData

---Populate Property Address Data (Removing Null values)

Select [UniqueID ], PropertyAddress From HousingData order by [UniqueID ] --FINDING WHICH ADDRESS FIELD IS NULL

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingData a Join HousingData b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ] where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingData a Join HousingData b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ] where a.PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from HousingData a Join HousingData b 
on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ] --JUST MAKING SURE BY CHECKING DATA.

--- Breaking PropertyAddress & Owner Address field (IN address, City, State) Using Substring/char index

-- 1) Breaking Property Address:- 
Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as City
From HousingData

-- Updating Columns of property Address and City.

ALTER TABLE HousingData
Add Property_Address Nvarchar(255);

Update HousingData
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

--DROP Table if exists Property_Address_City
--ALTER TABLE HousingData
--DROP COLUMN Property_Address_City;

ALTER TABLE HousingData
Add Prop_Address_City Nvarchar(256);

Update HousingData
SET Prop_Address_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) 


-- 2) Breaking Ower Address:- 
		--Replace comma to Period
Select PARSENAME(REPLACE(OwnerAddress, ',', '.' ),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.' ),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.' ),1)
From HousingData

-- Updating Columns of Owner Address, City and State.

ALTER TABLE HousingData
Add Owner_Address Nvarchar(255);

Update HousingData
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),3) 

ALTER TABLE HousingData
Add Owner_Address_City Nvarchar(256);

Update HousingData
SET Owner_Address_City = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),2) 

ALTER TABLE HousingData
Add Owner_Address_State Nvarchar(256);

Update HousingData
SET Owner_Address_State = PARSENAME(REPLACE(OwnerAddress, ',', '.' ),1)

-- Change Y and N to YES and NO in "SoldAsVacant"

Select Distinct(SoldAsVacant) From HousingData -- Just checking Values 

Select SoldAsVacant,
CASE When SoldAsVacant= 'Y' Then 'Yes'
	 When SoldAsVacant= 'N' Then 'No'
	 ELSE SoldAsVacant
	 END
From HousingData

Update HousingData
SET SoldAsVacant =CASE When SoldAsVacant= 'Y' Then 'Yes'
	 When SoldAsVacant= 'N' Then 'No'
	 ELSE SoldAsVacant
	 END

--Remove Duplicates Using CTE

Select * , 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	PropertyAddress,
	Salesdate,
	SalePrice,
	LegalReference
	Order By UniqueID
)
From HousingData