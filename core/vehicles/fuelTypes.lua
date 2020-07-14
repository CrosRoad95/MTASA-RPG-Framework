local fuelTypes = {}

function addFuelType(id, type, properties)
  if(isValidFuelId(id))then
    return false
  end
  fuelTypes[id] = {
    type = type,
    properties = properties,
  }
  return true
end

function isValidFuelId(id)
  return fuelTypes[id] and true or false
end

function setVehicleFuelTypeId(vehicle, id)
  if(isValidFuelId(id))then
    setElementData(vehicle, "fuelType", id)
  end
end

function setVehicleSecondaryFuelTypeId(vehicle, id)
  if(isValidFuelId(id))then
    setElementData(vehicle, "fuelTypeSecondary", id)
  end
end

addFuelType(1, "lpg", {})
addFuelType(2, "diesel", {})
addFuelType(3, "benzyna", {})
addFuelType(4, "elektryczne", {})