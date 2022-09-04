-- Cleaning Data en SQL Queries

Select * From PrimerProyecto.dbo.Alojamiento

-- Estandarizamos formato fecha

/*SELECT SaleDateConverted, CONVERT(Date, SaleDate) as Estandarizado
FROM PrimerProyecto.dbo.Alojamiento

UPDATE PrimerProyecto.dbo.Alojamiento
SET SaleDate = CONVERT(Date, SaleDate)*/

ALTER TABLE PrimerProyecto.dbo.Alojamiento
ADD SaleDateConverted Date;

UPDATE PrimerProyecto.dbo.Alojamiento
SET SaleDateConverted = CONVERT(Date, SaleDate)



-- Rellenar datos NULL de dirección de propiedad (PropertyAdress)
-- Hay propiedades con ParcalID iguales, los que no tengan direccion pero tengan parcel id parecido, se le asignará la direccion del mismo.


Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress from PrimerProyecto.dbo.Alojamiento A
JOIN PrimerProyecto.dbo.Alojamiento B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is NULL

UPDATE A
	SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress) -- Podriamos setear tambien 'No Address'
	FROM PrimerProyecto.dbo.Alojamiento A
	JOIN PrimerProyecto.dbo.Alojamiento B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL




-- División de la dirección en columnas individuales (dirección, ciudad, estado)
-- Property Adress tiene como valor la direccion, ciudad y estado juntos. Vamos a separarlo.
-- Vamos a usar dos metodos, utilizando SUBSTRING y PARSENAME

Select PropertyAddress
From PrimerProyecto.dbo.Alojamiento

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Direccion
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Ciudad

From PrimerProyecto.dbo.Alojamiento

ALTER TABLE PrimerProyecto.dbo.Alojamiento
Add DireccionExtraida Nvarchar(255);

Update PrimerProyecto.dbo.Alojamiento
SET DireccionExtraida = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PrimerProyecto.dbo.Alojamiento
Add CiudadExtraida Nvarchar(255);

Update PrimerProyecto.dbo.Alojamiento
SET CiudadExtraida = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select OwnerAddress
From  PrimerProyecto.dbo.Alojamiento


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From  PrimerProyecto.dbo.Alojamiento


ALTER TABLE PrimerProyecto.dbo.Alojamiento
Add DireccionDueñoExtraida Nvarchar(255);

Update PrimerProyecto.dbo.Alojamiento
SET DireccionDueñoExtraida = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PrimerProyecto.dbo.Alojamiento
Add CiudadDueñoExtraida Nvarchar(255);

Update PrimerProyecto.dbo.Alojamiento
SET CiudadDueñoExtraida = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PrimerProyecto.dbo.Alojamiento
Add EstadoDueñoExtraida Nvarchar(255);

Update PrimerProyecto.dbo.Alojamiento
SET EstadoDueñoExtraida = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PrimerProyecto.dbo.Alojamiento


-- Cambiar Y y N a Yes o No en columna "Sold as Vacant"

Select Distinct(SoldAsVacant) From PrimerProyecto.dbo.Alojamiento

Select 
	SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM 
	PrimerProyecto.dbo.Alojamiento

UPDATE 
	PrimerProyecto.dbo.Alojamiento
SET
	SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END 


-- Eliminar Duplicados

WITH RowNumCTE AS (

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
				 ) row_num
FROM PrimerProyecto.dbo.Alojamiento
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1


-- Borrar columnas sin usar

Select *
From PrimerProyecto.dbo.Alojamiento


ALTER TABLE PrimerProyecto.dbo.Alojamiento
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
