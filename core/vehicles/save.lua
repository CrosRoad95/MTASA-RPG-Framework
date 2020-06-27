local markedAsFullSave = {}
local changedVehicles = {}

function markVehicleForSave(vehicle)
  if(vehicle and type(vehicle) == "userdata" and getElementType(vehicle) == "vehicle")then
    markedAsFullSave[vehicle] = true
    return true
  end
  return false
end

function setVehicleChanged(vehicle)
  if(vehicle and type(vehicle) == "userdata" and getElementType(vehicle) == "vehicle")then
    changedVehicles[vehicle] = true
  end
  return false
end

function saveVehicle(light)

end

function lightSaveAll()
  for vehicle in ipairs(changedVehicles)do
    vehicleLightSave(vehicle)
  end
end

function saveAll()
  lightSaveAll()
  for vehicle in ipairs(markedAsFullSave)do
    vehicleLightSave(vehicle)
  end
end

function vehicleLightSave(vehicle)

end

function vehicleFullSave(vehicle)

end