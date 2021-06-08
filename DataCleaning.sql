-- changing date format

  select SaleDate, convert(Date,SaleDate) from covidproject..NashvilleHousing

  update NashvilleHousing
  set SaleDate=convert(Date,SaleDate)

  alter table NashvilleHousing 
  add SaleDateConverted Date

  update NashvilleHousing
  set SaleDateConverted=convert(Date,SaleDate)

  select SaleDateConverted from covidproject..NashvilleHousing

  -- filling up null addresses

    select * from covidproject..NashvilleHousing
	where PropertyAddress is null

	select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress) 
	from covidproject..NashvilleHousing a
	join covidproject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null

	update a
    set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
	from covidproject..NashvilleHousing a
	join covidproject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null
-- just checking
	select * from covidproject..NashvilleHousing
	where PropertyAddress is null


-- spliting address

select PropertyAddress from NashvilleHousing

select 
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
from NashvilleHousing


  alter table NashvilleHousing 
  add PropertySplitAddress NVarchar(255)

  update NashvilleHousing
  set PropertySplitAddress=substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 
  
  alter table NashvilleHousing 
  add PropertySplitCity NVarchar(255)

  update NashvilleHousing
  set PropertySplitCity=substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

  select PARSENAME(replace(OwnerAddress,',','.'),3), PARSENAME(replace(OwnerAddress,',','.'),2),PARSENAME(replace(OwnerAddress,',','.'),1)
  from NashvilleHousing

  alter table NashvilleHousing 
  add OwnerSplitAddress NVarchar(255)

  update NashvilleHousing
  set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3 )
  
  alter table NashvilleHousing 
  add OwnerSplitCity NVarchar(255)

  update NashvilleHousing
  set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',','.'),2)

  alter table NashvilleHousing 
  add OwnerSplitState NVarchar(255)

  update NashvilleHousing
  set OwnerSplitState=PARSENAME(replace(OwnerAddress,',','.'),1) 

  -- filling in values yes or no

  select distinct(SoldAsVacant),count(SoldAsVacant)
  from NashvilleHousing
  group by SoldAsVacant
  order by 2
  
  select SoldAsVacant,
  case
  when SoldAsVacant='Y' then 'Yes'
  when SoldAsVacant='N' then 'No'
  else SoldAsVacant
  end
  from NashvilleHousing
 
 update NashvilleHousing
 set SoldAsVacant= case
  when SoldAsVacant='Y' then 'Yes'
  when SoldAsVacant='N' then 'No'
  else SoldAsVacant
  end

-- removing duplicates

with RowNumCTE AS (

select *,
ROW_NUMBER() over (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID
) row_num

from NashvilleHousing
-- order by ParcelID
)
Delete from RowNumCTE
where row_num>1


with RowNumCTE AS (

select *,
ROW_NUMBER() over (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY
UniqueID
) row_num

from NashvilleHousing
-- order by ParcelID
)
select * from RowNumCTE
where row_num>1
order by PropertyAddress

-- removing unused columns

select * from NashvilleHousing

alter table NashvilleHousing
drop column PropertyAddress,OwnerAddress,TaxDistrict,SaleDate

