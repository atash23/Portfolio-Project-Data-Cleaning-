
/*
Cleaning Data in SQL Queries

*/

Select *
From [Portfolio Project]..NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


---------------------------------------------------------------------------------------------

--Population Property Adress data

Select *
From [Portfolio Project]..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columnds (Adress, City, State)
Select PropertyAddress
From [Portfolio Project]..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
From [Portfolio Project]..NashvilleHousing


--Using PARSENAME to split the address
Select OwnerAddress
From [Portfolio Project]..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State

From [Portfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From [Portfolio Project]..NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End

--Remove Dublicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Project]..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Delete Unused Columns

Select *
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN SaleDate

