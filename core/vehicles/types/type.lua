local types = {}

function createVehicleType(id, name, behavior)
  -- todo: dodać czyszczenie typów stworzonych z zewnętrznych skryptów
  if(types[id])then
    return false
  end
  types[id] = {
    name = name,
    behavior = behavior
  }
end

function isVehicleTypeValid(id)
  return types[id] and true or false
end

function callVehicleBehavior(vehicle, event, ...)
  local t = getTypeVehicle(source)
  if(types[t])then
    local behavior = types[t].behavior
    if(behavior and behavior[event])then
      if(behavior[event](vehicle, ...))then

      else
        cancelEvent()
      end
    end
  else
    outputDebugString("Wykryto nieprawidłowy typ pojazdu "..getVehicleName(source)..", typ: "..tostring(t))
  end
end

function fireCheckAccessMethod(player, vehicle)
  local t = getTypeVehicle(vehicle)
  if(types[t])then
    local behavior = types[t].behavior
    if(behavior and behavior.checkAccess)then
      return behavior.checkAccess(player, vehicle)
    end
  end
end

addEventHandler("onVehicleStartEnter", resourceRoot, function(...)
  callVehicleBehavior(source, "onVehicleStartEnter", ...)
end)
addEventHandler("onVehicleStartExit", resourceRoot, function(...)
  callVehicleBehavior(source, "onVehicleStartExit", ...)
end)

createVehicleType(0, "unknown") -- domyślny jeżeli pojazd nie ma typu
createVehicleType(1, "private", private)
createVehicleType(2, "fraction")
createVehicleType(3, "work")

