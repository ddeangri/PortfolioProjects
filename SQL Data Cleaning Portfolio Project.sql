	Select *
	From PortfolioProject..NashvilleHousing

--Standardize Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate)
	From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Adress data

Select *
	From PortfolioProject..NashvilleHousing
	--Where PropertyAddress is null
	order by ParcelID

	Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
	From PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
	JOIN PortfolioProject..NashvilleHousing b
		on a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null


--Breaking out Address Into Individual Columns (Address, City, State)

Select	PropertyAddress
From  PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)) as Address
From  PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, Len(PropertyAddress)) 

Select *
From  PortfolioProject..NashvilleHousing


Select OwnerAddress
From  PortfolioProject..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From  PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity= PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState= PARSENAME(Replace(OwnerAddress, ',', '.'), 1) 

Select *
From  PortfolioProject..NashvilleHousing

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldasVacant), Count(SoldasVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2


SELECT SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
from PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
	when SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From PortfolioProject..NashvilleHousing

--Remove Duplicates
With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
Select *
FROM RowNumCTE
WHERE row_num > 1
order by PropertyAddress


-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate
