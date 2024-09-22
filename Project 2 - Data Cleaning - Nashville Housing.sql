--CLEANING DATA IN SQL QUERIES



--Standardize Data Format

Select SaleDateConverted, Convert(date, SaleDate)
From NashvilleHousing

--Update NashvilleHousing
--set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing
add SaleDateconverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)



--Populate property Address Data

select *
from NashvilleHousing
where propertyaddress is null
order by parcelid

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyADdress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Breaking out address into individual columns (address, city, state)

--Property Address
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress  nvarchar(255);

update nashvillehousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity  nvarchar(255);

update nashvillehousing
set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Owner Address
Select OwnerAddress
from NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress  nvarchar(255);

update nashvillehousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

alter table NashvilleHousing
add OwnerSplitCity  nvarchar(255);

update nashvillehousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

alter table NashvilleHousing
add OwnerSplitState  nvarchar(255);

update nashvillehousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant), count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,  CASE	when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	END
from NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
					END



--Remove Duplicates

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
from NashvilleHousing
)
delete 
from RowNumCTE
where row_num > 1
--order by PropertyAddress



--Delete Unused Columns

Select * 
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate