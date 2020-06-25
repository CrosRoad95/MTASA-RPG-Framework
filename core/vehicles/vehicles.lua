local _createVehicle = createVehicle
local vehicles = {}
local resourcesVehicles = {}

local function onResourceStop()
  for i,v in ipairs(resourcesVehicles[source])do
    destroyElement(v)
  end
end

function registerResourceVehicle(resource, vehicle)
  local resourceRootElement = getResourceRootElement(resource)
  if(not resourcesVehicles[resourceRootElement])then
    resourcesVehicles[resourceRootElement] = {}
    addEventHandler("onResourceStop", resourceRootElement, onResourceStop)
  end
  table.insert(resourcesVehicles[resourceRootElement],vehicle);
  vehicles[#vehicles + 1] = vehicle
end

function createVehicle(...)
  sourceResource = sourceResource or getThisResource();
  local vehicle = _createVehicle(...)
  if(not vehicle)then
    return false
  end
  registerResourceVehicle(sourceResource, vehicle)
  return vehicle
end

function getLastVehicleId()
  local result = exports.db:queryTable("select max(id) as id from %s limit 1", "vehicles")
  if(result and #result > 0)then
    return result[1].id
  end
  return 0
end

function countVehicleByType(vehicleType)
  local result = exports.db:queryTable("select count(*) as amount from %s where type = ? limit 1", "vehicles", vehicleType)
  if(result and #result > 0)then
    return result[1].amount
  end
  return 0
end

function createNewVehicle(model, vehicleType)
  if(type(vehicleType) ~= "number")then
    vehicleType = 0
  end
  if(not isVehicleTypeValid(vehicleType))then
    return false
  end
  local amount = countVehicleByType(vehicleType)
  exports.db:queryTableFree("insert into %s (model, type)values(?,?)", "vehicles",model, vehicleType)
  local lastId = getLastVehicleId()
  exports.db:queryTableFree("update %s set typeid = ? where id = ? limit 1", "vehicles", amount + 1, lastId)
  return lastId
end

function getVehicleOwnerId(vehicleId)
  local result = exports.db:queryTable("select id from %s where vid = ? and permissions = 0 limit 1", "vehiclesAccess", vehicleId)
  if(result and #result == 1)then
    return result[1].id
  end
  return false
end

function getVehicleOwner(vehicleId)
  local result = exports.db:queryTable("select type,uid from %s where vid = ? and permissions = 0 limit 1", "vehiclesAccess", vehicleId)
  if(result and #result == 1)then
    local result = result[1];
    return {result.type, result.uid}
  end
  return false
end

function setVehicleOwner(vehicleId, t, uid)
  local id = getVehicleOwnerId(vehicleId)
  if(id)then
    exports.db:queryTableFree("update %s set type = ?, uid = ? where id = ? limit 1", "vehiclesAccess", t, uid, id)
  else
    exports.db:queryTableFree("insert into %s (vid,type,uid,permissions)values(?,?,?,0)","vehiclesAccess",vehicleId, t, uid)
  end
end

function spawnVehicle(id,x,y,z,rx,ry,rz,i,d)

end
