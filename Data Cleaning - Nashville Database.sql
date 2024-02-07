--Data Cleaning Project in SQL Queries using a Database form Nashville Housing
Select * From Nashville.dbo.NashvilleHousing


-- Standarize Data Format
Select SaleDate, CONVERT(Date,SaleDate) 
From Nashville.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Data;
Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data
Select PropertyAddress
From Nashville.dbo.NashvilleHousing
Where PropertyAddress is not null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville.dbo.NashvilleHousing as a
JOIN Nashville.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashville.dbo.NashvilleHousing as a
JOIN Nashville.dbo.NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-- Breaking out Address into Individual Columns (Address, City, State)
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From Nashville.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAdress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Data;

Update NashvilleHousing
SET PropertySplitCit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--Let's try another method
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From Nashville.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAdress Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N in "Sold as Vacant" Field
Select Distinct(SoldAsVacant), COUNT(SoldASVacant)
From Nashville.dbo.NashvilleHousing
Group by SoldASVacant
Order by 2

Select SoldAsVacant,
CASE	When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldASVacant
		END
From Nashville.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE	When SoldAsVacant = 'Y' THEN 'Yes'
						When SoldAsVacant = 'N' THEN 'No'
						Else SoldASVacant
						END


-- Delete Unused Columns
Select *
From Nashville.dbo.NashvilleHousing

ALTER TABLE Nashville.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
