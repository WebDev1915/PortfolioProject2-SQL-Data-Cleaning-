/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]
-----------------------------------------------------------------------------------

LAPTOP-SAS1SRLS\SQLEXPRESS

-----------------------------------------------------------------------------------

--Cleaning Data in SQL Queries

Select *
FROM PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------
---Standardize Date Format

Select SaledateConverted,CONVERT(Date,saledate)
FROM PortfolioProject.dbo.NashvilleHousing

  
Update NashvilleHousing
SET SaleDate = CONVERT(Date,saledate)


 ALTER TABLE NashvilleHousing
 Add SaleDateConverted Date;

 Update NashvilleHousing
 SET SaleDateConverted = CONVERT(Date,Saledate)

 ------------------------------------------------------------------------------

 --Populate Property Address Data

Select *
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
ORDER BY ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
---If a.property is null then we want to replace Null with b.propert.address)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID=b.ParcelID
  AND a.[UniqueID]<> b.[UniqueID]
Where a.PropertyAddress is null

UPDATE a
----We are not using PortfolioProject..NashvilleHousing as it will give an error, when using update with joins we need to use alias.
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID=b.ParcelID
  AND a.[UniqueID]<> b.[UniqueID]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------

---Breaking Out address into individual columns (Address,City,Date)


Select PropertyAddress
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--ORDER BY ParcelID


Select 
Substring (PropertyAddress,1,CHARINDEX (',',PropertyAddress) -1) AS Address
,Substring (PropertyAddress,CHARINDEX (',',PropertyAddress) +1 ,LEN(PropertyAddress)) AS Address

FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring (PropertyAddress,1,CHARINDEX (',',PropertyAddress) -1)
 
ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = Substring (PropertyAddress,CHARINDEX (',',PropertyAddress) +1 ,LEN(PropertyAddress))









----------------------------------------

----Cleaning owner's adddress

Select *
FROM PortfolioProject..NashvilleHousing



Select OwnerAddress
FROM PortfolioProject..NashvilleHousing


Select
PARSENAME (REPLACE(OwnerAddress, ',', ','),1),-----Adress-----
PARSENAME (REPLACE(OwnerAddress, ',', ','),2),-----City-----
PARSENAME (REPLACE(OwnerAddress, ',', ','),3)-----State-----
FROM PortfolioProject..NashvilleHousing

---We did by Parsing (2nd method) we could have done through Substring also like we did above


ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',', ','),1)
 
ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',', ','),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitstate NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitstate = PARSENAME (REPLACE(OwnerAddress, ',', ','),3)
 

 Select *
FROM PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------
---Change y and N to Yes Or No in "Sold As Vacant" Field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
Group BY SoldAsVacant
Order BY 2


Select SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

---------------------------------------------------------------------------------------------

----Removing Duplicates-----

Select *,
  ROW_NUMBER() OVER (
  Partition BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
			   UniqueID
			   )row_num

FROM PortfolioProject..NashvilleHousing
Order By ParcelID


--------------------------------------------------------

-----------Delete Unused Columns----------

Select *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
Drop Column SaleDate