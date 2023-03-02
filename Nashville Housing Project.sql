-- Creating a table with the matching data structure in the CSV file

CREATE TABLE NashvilleHousing(
UniqueID INTEGER,
ParcelID VARCHAR(200),
LandUse VARCHAR(100),
PropertyAddress VARCHAR(100),
SaleDate DATE,
SalePrice TEXT,
LegalReference VARCHAR(200),
SoldAsVacant VARCHAR(50), 
OwnerName VARCHAR(100),
OwnerAddress VARCHAR(200),
Acreage DECIMAL,
TaxDistrict VARCHAR(100),
LandValue INTEGER,
BuildingValue INTEGER,
TotalValue INTEGER,
YearBuilt INTEGER,
Bedrooms SMALLINT,
FullBath SMALLINT,
HalfBath SMALLINT
)

SELECT * FROM nashvillehousing


-- Populate property address data

SELECT * FROM nashvillehousing
--WHERE propertyaddress IS NULL
ORDER BY parcelid

SELECT a.uniqueid, a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b
	ON a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL

UPDATE nashvillehousing AS a
SET PropertyAddress = COALESCE(b.propertyaddress, a.propertyaddress)
FROM nashvillehousing b 
WHERE a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid AND a.propertyaddress IS NULL;


-- Breaking out Address into Individual Columns (Address, City, State)


SELECT propertyaddress FROM nashvillehousing
--WHERE propertyaddress IS NULL
ORDER BY parcelid

SELECT
SPLIT_PART(propertyaddress, ',', 1) AS address, 
SPLIT_PART(propertyaddress, ',', -1) AS address2
FROM nashvillehousing

ALTER TABLE nashvillehousing
ADD PropertySplitAddress VARCHAR(255)

UPDATE nashvillehousing
SET PropertySplitAddress = SPLIT_PART(propertyaddress, ',', 1)

ALTER TABLE nashvillehousing
ADD PropertySplitCity VARCHAR(255)

UPDATE nashvillehousing
SET PropertySplitCity = SPLIT_PART(propertyaddress, ',', -1)

SELECT * FROM nashvillehousing

SELECT OwnerAddress
FROM nashvillehousing

SELECT
SPLIT_PART(owneraddress, ',', 1) AS address,
SPLIT_PART(owneraddress, ',', 2) AS address1,
SPLIT_PART(owneraddress, ',', 3) AS address2
FROM nashvillehousing

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress VARCHAR(255)

UPDATE nashvillehousing
SET OwnerSplitAddress = SPLIT_PART(owneraddress, ',', 1)

ALTER TABLE nashvillehousing
ADD OwnerSplitCity VARCHAR(255)

UPDATE nashvillehousing
SET OwnerSplitCity = SPLIT_PART(owneraddress, ',', 2)

ALTER TABLE nashvillehousing
ADD OwnerSplitState VARCHAR(255)

UPDATE nashvillehousing
SET OwnerSplitState = SPLIT_PART(owneraddress, ',', 3)

SELECT * FROM nashvillehousing


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove duplicates


DELETE FROM nashvillehousing
WHERE uniqueid IN
    (SELECT uniqueid
    FROM
        (SELECT uniqueid,
         ROW_NUMBER() OVER( PARTITION BY parcelid, propertyaddress, saleprice, saledate, legalreference
        ORDER BY  uniqueid ) AS row_number
        FROM nashvillehousing ) t
        WHERE t.row_number > 1 )
		
Select * FROM nashvillehousing


-- Delete unused columns


SELECT * FROM nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN owneraddress, DROP COLUMN taxdistrict, DROP COLUMN propertyaddress, DROP COLUMN saledate