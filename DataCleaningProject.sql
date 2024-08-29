SELECT * FROM PortfolioProject.nashvillehousing;

-- Populate Property Address Data

SELECT * FROM PortfolioProject.nashvillehousing
ORDER BY ParcelID;

SELECT * FROM PortfolioProject.nashvillehousing
WHERE PropertyAddress IS NULL;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.nashvillehousing a
JOIN PortfolioProject.nashvillehousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE PortfolioProject.nashvillehousing a
JOIN PortfolioProject.nashvillehousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Breaking The Address --

SELECT *
FROM PortfolioProject.nashvillehousing;

SELECT 
SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address,
SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1) AS Address
FROM PortfolioProject.nashvillehousing;

ALTER TABLE PortfolioProject.nashvillehousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE PortfolioProject.nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);
--
ALTER TABLE PortfolioProject.nashvillehousing
ADD PropertySplitCity VARCHAR(255);

UPDATE PortfolioProject.nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1);
--

SELECT OwnerAddress
FROM PortfolioProject.nashvillehousing;

SELECT 
SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1) AS FirstPart,
SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1) AS SecondPart,
SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1) AS LastPart
FROM PortfolioProject.nashvillehousing;
--
ALTER TABLE PortfolioProject.nashvillehousing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE PortfolioProject.nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1);
--
ALTER TABLE PortfolioProject.nashvillehousing
ADD OwnerSplitCity VARCHAR(255);

UPDATE PortfolioProject.nashvillehousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1);
--
ALTER TABLE PortfolioProject.nashvillehousing
ADD OwnerSplitState VARCHAR(255);

UPDATE PortfolioProject.nashvillehousing
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1);
--
SELECT *
FROM PortfolioProject.nashvillehousing;


-- Change the Y and N to Yes and No --

SELECT distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = "Y" THEN "Yes" 
	 WHEN SoldAsVacant = "N" THEN "No" 
     ELSE SoldAsVacant 
     END
FROM PortfolioProject.nashvillehousing;

UPDATE PortfolioProject.nashvillehousing
SET SoldAsVacant = 
	 CASE WHEN SoldAsVacant = "Y" THEN "Yes" 
	 WHEN SoldAsVacant = "N" THEN "No" 
     ELSE SoldAsVacant 
     END;
     

-- Remove Duplicates -- 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID, 
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY 
					UniqueID
                    ) row_num
FROM PortfolioProject.nashvillehousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

DELETE nh
FROM PortfolioProject.nashvillehousing nh
JOIN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, 
                                PropertyAddress,
                                SalePrice,
                                SaleDate,
                                LegalReference
                   ORDER BY UniqueID
               ) AS row_num
        FROM PortfolioProject.nashvillehousing
    ) AS RowNumCTE
    WHERE row_num > 1
) AS duplicates
ON nh.UniqueID = duplicates.UniqueID;

-- Remove Columns -- 

SELECT *
FROM PortfolioProject.nashvillehousing;

ALTER TABLE PortfolioProject.nashvillehousing
DROP COLUMN OwnerAddress,
DROP COLUMN PropertyAddress,
DROP COLUMN TaxDistrict;




