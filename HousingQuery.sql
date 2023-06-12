/* Let's look at the data */
SELECT *
FROM portfolio.dbo.NashvilleHousing

-----

/* Standardize Date Format in SaleDate */
SELECT SaleDate, CONVERT(Date, SaleDate) 
FROM portfolio.dbo.NashvilleHousing
-- The new column is what we want the SaleDate to look like.

UPDATE NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate)
-- Use UPDATE to change SaleDate to Date Format. 

-- Add a new column with the standardized date. Use ALTER TABLE, then UPDATE.
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Check to see if new column SaleDateConverted is correct.
SELECT SaleDateConverted, CONVERT(Date, SaleDate) 
FROM portfolio.dbo.NashvilleHousing


-----

/* Let's look at the Property Address Data */
SELECT PropertyAddress
FROM portfolio..NashvilleHousing
WHERE PropertyAddress is null


/* I noticed there are nulls. Let's investigate. */
SELECT *
FROM portfolio..NashvilleHousing
ORDER BY ParcelID
-- I notice the same ParcelID and PropertyAddress are listed for different UniqueIDs. 


-----

/* I want to it to find a ParcelID with a null PropertyAddress. Then populate the PropertyAddress from a different UniqueID with a matching ParcelID. */
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM portfolio..NashvilleHousing a
JOIN portfolio..NashvilleHousing b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null
-- Join where the ParcelIDs are the same but the UniqueIDs are different, and look where the PropertyAddress is null.

-- Use ISNULL to create new column that reflects where a.Property was null and have it input b.PropertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio..NashvilleHousing a
JOIN portfolio..NashvilleHousing b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Update PropertyAddress column using alias a.
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio..NashvilleHousing a
JOIN portfolio..NashvilleHousing b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Then rerun with WHERE clause to check it worked and there should be no nulls.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio..NashvilleHousing a
JOIN portfolio..NashvilleHousing b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


-----

/* Let's look at the Property Address */
Select PropertyAddress
FROM portfolio.dbo.NashvilleHousing


/* Split PropertyAddress into separate columns for address and city Using SUBSTRING and CHARINDEX */
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM portfolio.dbo.NashvilleHousing
-- Take the PropertyAddress at position 1 until the comma ','. Then to remove the comma, -1. Name the column 'Address'
-- Take the PropertyAddress until the comma's position. Then to remove the comma, -1. Name the column 'City'
-- Run query to check accuracy

ALTER TABLE NashvilleHousing
ADD SplitPropertyAddress Nvarchar(255);
-- Add a column for the split address.
Update NashvilleHousing
SET SplitPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
-- Input the data for the split address column.

ALTER TABLE NashvilleHousing
ADD SplitPropertyCity Nvarchar(255);
-- Add a column for the split city.
UPDATE NashvilleHousing
SET SplitPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
-- Input the data for the split city column.

SELECT *
FROM portfolio..NashvilleHousing
-- Let's see the updated table.


-----

/* Let's look at the OwnerAddress */
SELECT OwnerAddress
FROM portfolio..NashvilleHousing


/* Split OwnerAddress into separate columns for address, city, and state. */
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM portfolio..NashvilleHousing
-- PARSENAME(OwnerAddress, 1)
-- PARSENAME only looks for periods, so we need to REPLACE the commas with a period. 
-- PARSENAME goes backwards, so we need 321 instead of 123.

ALTER TABLE NashvilleHousing
ADD SplitOwnerAddress Nvarchar(255);
-- Add a column for SplitOwnerAddress.
Update NashvilleHousing
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
-- Input the data for SplitOwnerAddress column.

ALTER TABLE NashvilleHousing
ADD SplitOwnerCity Nvarchar(255);
-- Add a column for SplitOwnerCity.
Update NashvilleHousing
SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
-- Input the data for SplitOwnerCity column.

ALTER TABLE NashvilleHousing
ADD SplitOwnerState Nvarchar(255);
-- Add a column for SplitOwnerState.
Update NashvilleHousing
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
-- Input the data for SplitOwnerState column.

SELECT *
FROM portfolio..NashvilleHousing


-----

/* Let's look at the SoldAsVacant column. */
SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant)
FROM portfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


/* Update the Y/N to show as Yes/No in the Sold as Vacant field. */
SELECT SoldAsVacant
, CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM portfolio..NashvilleHousing

-- Since query works, we can update accordingly.
UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Rerun our SoldAsVacant column to check completion.
SELECT DISTINCT(SoldAsVacant), COUNT (SoldAsVacant)
FROM portfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-----

/* Check for duplicates. */
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM portfolio..NashvilleHousing
ORDER BY ParcelID
-- In the column row_num, I can identify the 2's. Upon investigation, I see the 2 rows have all the same data but different UniqueId's. 


/* USE CTE to view all the duplicates (row_num 2's) */
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM portfolio..NashvilleHousing
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress
-- There are 104 duplicates. 


/* Remove Duplicates */
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM portfolio..NashvilleHousing
)
DELETE
FROM RowNumCTE 
WHERE row_num > 1


/* Rerun query to check if leftover duplicates. */
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) AS row_num
FROM portfolio..NashvilleHousing
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE 
WHERE row_num > 1
ORDER BY PropertyAddress


-----

/* Delete unused columns. */
SELECT *
FROM portfolio..NashvilleHousing

ALTER TABLE portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress
-- These addresses have been split, so delete the old ones. 
-- You also can delete any other unwanted columns, but I'm leaving the rest as is. 

