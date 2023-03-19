--Cleaning Data in SQL Queries
*/

SELECT*
FROM PortfolioProject2.dbo.NashvilleHousing

--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,Saledate)
FROM PortfolioProject2.dbo.NashvilleHousing

Update NashvilleHousing
SET Saledate = CONVERT(Date,Saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaledateConverted = CONVERT(Date,Saledate)


--Populate Property Address date

SELECT*
FROM PortfolioProject2.dbo.NashvilleHousing
--WHERE propertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL (a.Propertyaddress, b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL (a.Propertyaddress, b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject2.dbo.NashvilleHousing
--WHERE propertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING (Propertyaddress, 1, CHARINDEX (',', PropertyAddress)-1) as Address,
SUBSTRING (Propertyaddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (Propertyaddress, 1, CHARINDEX (',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (Propertyaddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT*
FROM PortfolioProject2.dbo.NashvilleHousing







SELECT OwnerAddress
FROM PortfolioProject2.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProject2.dbo.NashvilleHousing






ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (Soldasvacant), COUNT(SoldAsVacant)
From PortfolioProject2.dbo.NashvilleHousing
Group by SoldAsVacant
Order By 2



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject2.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From PortfolioProject2.dbo.NashvilleHousing



---Remove Duplicates



WITH RowNumCTE as (
SELECT*, 
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
   PropertyAddress,
   SalePrice,
   SaleDate,
   LegalReference
   ORDER BY
   UniqueID
   ) row_num



From PortfolioProject2.dbo.NashvilleHousing
--order by ParcelID
)
SELECT*
FROM RowNumCTE
WHERE row_num >1



--Delete Unused Columns

SELECT*
From PortfolioProject2.dbo.NashvilleHousing


ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN SaleDate