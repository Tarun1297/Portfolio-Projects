-- This project is about exploring the dataset and cleaning the dataset to get it ready for use.
-- The dataset contains information about various houses which includes the OwnerName,LandUse, SalePrice Etc.

--Exploring the data

Select *
From PortfolioProject..Housing$
order by [UniqueID ]

-- Cleaning data in the SQL queries


--Standardizing the Sale date(We want to remove the time part from the Sale date)

Alter Table PortfolioProject..Housing$
Add SaleconvertedDate Date;

Update PortfolioProject..Housing$
Set SaleconvertedDate = convert(date, SaleDate)

Select *
From PortfolioProject..Housing$

-- Populate the Property Address Data
--We notice that Parcelid values produce the same address everytime.

Select ParcelID,PropertyAddress
From PortfolioProject..Housing$
order by ParcelID

-- Therefore we are going to populate the property address according to the parcel ID it is associated with.

Select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress) 
From  PortfolioProject..Housing$ a
Join  PortfolioProject..Housing$ b

on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

where a.PropertyAddress is null

--Updating the table using the above code:

Update a
Set propertyAddress = Isnull(a.propertyAddress,b.propertyAddress)
From  PortfolioProject..Housing$ a
Join  PortfolioProject..Housing$ b

on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out the object into Individual columns(Address, City, State)

Select PropertyAddress,SUBSTRING(propertyAddress, 1, CHARINDEX(',',propertyAddress)-1) as Address,
SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1, len(propertyAddress)) as Place
from PortfolioProject..Housing$


Alter Table PortfolioProject..Housing$
Add Address varchar(50)

Alter Table PortfolioProject..Housing$
Add Place varchar(50)

Update PortfolioProject..Housing$
Set Address = SUBSTRING(propertyAddress, 1, CHARINDEX(',',propertyAddress)-1)

Update PortfolioProject..Housing$
Set Place = SUBSTRING(propertyAddress,CHARINDEX(',',propertyAddress)+1, len(propertyAddress)) 

select Address,Place
From PortfolioProject..Housing$

-- Looking at the owner address

Select * 
From PortfolioProject..Housing$

--Parsing the ownerAddrress field
Select ownerAddress, PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)

from PortfolioProject..Housing$

--Now we Alter the table accordingly

Alter Table PortfolioProject..Housing$
Add OwnerSplitAddress varchar(255)

Update PortfolioProject..Housing$
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table PortfolioProject..Housing$
Add OwnerSplitCity varchar(255)

Update PortfolioProject..Housing$
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table PortfolioProject..Housing$
Add OwnerSplitState varchar(255)

Update PortfolioProject..Housing$
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)

--Now we check again

select *
From PortfolioProject..Housing$

--Looking at SoldAsVacant Column

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..Housing$
group by SoldAsVacant

--We want to remove this ambiguity by having having just a 'yes' or a 'no'

Select SoldAsVacant,
Case
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'Yes' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
When SoldAsVacant = 'No' Then 'No'
End
From PortfolioProject..Housing$

--Updating it in the column SoldAsVacant

Update PortfolioProject..Housing$
Set SoldAsVacant = Case
When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'Yes' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
When SoldAsVacant = 'No' Then 'No'
End

--Removing Duplicates

With rowNumCTE as (

Select *,
	Row_Number() OVER (
	Partition by ParcelID,
	propertyAddress,
	SaleconvertedDate, 
	LegalReference 
	ORDER BY uniqueID) Row_num

From PortfolioProject..Housing$
--order by ParcelID
)

Select * 
From rowNumCTE
where Row_num>1


-- Deleting Unused columns

Alter Table PortfolioProject..Housing$
Drop column owneraddress, propertyaddress, TaxDistrict, SaleDate

Alter Table PortfolioProject..Housing$
Drop Column SaleDate

--Checking if the columns are also present

Select * 
From PortfolioProject..Housing$