local types = {}

function createVehicleType(id, name)
  -- todo: dodać czyszczenie typów stworzonych z zewnętrznych skryptów
  if(types[id])then
    return false
  end
  types[id] = {
    name = name,
  }
end

function isVehicleTypeValid(id)
  return types[id] and true or false
end

createVehicleType(0, "unknown") -- domyślny jeżeli pojazd nie ma typu
createVehicleType(1, "private")
createVehicleType(2, "fraction")
createVehicleType(3, "work")