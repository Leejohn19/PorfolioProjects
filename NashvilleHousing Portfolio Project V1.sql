
-- Cleaning Data in SQL
SELECT * FROM PortfolioProject.dbo.NashvilleHousing;

--Standardize Sale Date
SELECT SaleDate, CONVERT(Date,SaleDate) AS SaleDateConverted FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE NashvilleHousing
	SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
	ADD SaleDateConverted Date;

UPDATE NashvilleHousing
	SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT * FROM PortfolioProject.dbo.NashvilleHousing

--Populate Property Address Data
SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress) 
	FROM PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
		ON a.parcelID = b.ParcelID
			AND a.[UniqueID] <> b.[UniqueID]
		WHERE a.propertyaddress IS NULL;

UPDATE a SET propertyaddress= ISNULL(a.propertyaddress, b.propertyaddress) 
	FROM PortfolioProject.dbo.NashvilleHousing a
	JOIN PortfolioProject.dbo.NashvilleHousing b
		ON a.parcelID = b.ParcelID
			AND a.[UniqueID] <> b.[UniqueID]

--Breaking Out Address into Individual Columns(Address, City)
SELECT 
	SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) AS Address,
	SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) AS City
	FROM NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
	SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

ALTER TABLE NashvilleHousing
	ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing 
	SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))

SELECT * FROM PortfolioProject.dbo.NashvilleHousing


--Splitting OwnerAddress to Address, City, State
SELECT 
	PARSENAME(REPLACE(owneraddress,',','.') ,3),
	PARSENAME(REPLACE(owneraddress,',','.') ,2),
	PARSENAME(REPLACE(owneraddress,',','.') ,1)
	FROM NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing 
	SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.') ,3)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing 
	SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.') ,2)

ALTER TABLE NashvilleHousing
	ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing 
	SET OwnerSplitState = PARSENAME(REPLACE(owneraddress,',','.') ,1)

SELECT * FROM NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" Field
SELECT DISTINCT(soldasvacant)
	FROM NashvilleHousing

SELECT soldasvacant,
	CASE 
		WHEN soldasvacant = 'N' THEN 'No'
		WHEN soldasvacant = 'Y' THEN 'Yes'
		ELSE soldasvacant
	END
	FROM NashvilleHousing

UPDATE NashvilleHousing 
	SET soldasvacant = 
		CASE 
			WHEN soldasvacant = 'N' THEN 'No'
			WHEN soldasvacant = 'Y' THEN 'Yes'
		ELSE soldasvacant
	END

SELECT DISTINCT(soldasvacant)
	FROM NashvilleHousing

--Remove Duplicates
WITH rownumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY SaleDate) AS row_num
	FROM NashvilleHousing)
SELECT *  FROM rownumCTE	
	WHERE row_num >1
	ORDER BY PropertyAddress

--Remove Unused Columns

SELECT *
	FROM NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
	DROP COLUMN propertyaddress, taxdistrict, owneraddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
	DROP COLUMN saledate
