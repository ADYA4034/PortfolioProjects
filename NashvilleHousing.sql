--cleaning data in sqlqueries

SELECT *
FROM PortfolioProject..NashvilleHousing

--Standardise Date Format

SELECT SalesDateConverted, convert(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date

UPDATE NashvilleHousing
SET SalesDateConverted = convert(Date,SaleDate)

--Populate Property Address Data 

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is NOT NULL
ORDER BY ParcelID

--To replace the property address that has null values with its own address
SELECT nas.ParcelID, nash.ParcelID, nas.PropertyAddress, nash.PropertyAddress,ISNULL(nas.PropertyAddress,nash.PropertyAddress)
FROM PortfolioProject..NashvilleHousing nas	
JOIN PortfolioProject..NashvilleHousing nash
    ON nas.ParcelID = nash.ParcelID
AND nas.UniqueID <> nash.UniqueID
WHERE nas.PropertyAddress IS NULL

--Update the existing Postal address with above code
UPDATE nas
SET PropertyAddress = ISNULL(nas.PropertyAddress,nash.PropertyAddress)
FROM PortfolioProject..NashvilleHousing nas	
JOIN PortfolioProject..NashvilleHousing nash
    ON nas.ParcelID = nash.ParcelID
AND nas.UniqueID <> nash.UniqueID
WHERE nas.PropertyAddress IS NULL

--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is NOT NULL
--ORDER BY ParcelID

SELECT *
FROM PortfolioProject..NashvilleHousing

--Spliting address into address and City
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS ADDRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS ADDRESS
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


--Spliting Owner address into address and City
SELECT 
OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--SoldAsVacant removing Y and N to Yes and No
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END 
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END 
FROM PortfolioProject..NashvilleHousing

--Remove Duplicates using a CTE 

WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice,LegalReference ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID

)

SELECT *
FROM RowNumCTE  
WHERE row_num > 1
ORDER BY PropertyAddress

--To delete the duplicates 

WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice,LegalReference ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID

)
DELETE
FROM RowNumCTE  
WHERE row_num > 1
--ORDER BY PropertyAddress

--Delete Unused Columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate