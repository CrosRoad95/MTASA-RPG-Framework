local _createVehicle = createVehicle
local vehicles = {}
local resourcesVehicles = {}
local spawnedVehicles = {}
local spawnedVehiclesTypes = {}

function getAllVehicles()
  local t = {}
  for vid, vehicle in pairs(spawnedVehicles)do
    t[#t + 1] = vehicle
  end
  return t
end

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

function isVehicleSpawned(vid)
  return spawnedVehicles[vid] and true or false
end

function getVehicleByVid(vid)
  return spawnedVehicles[vid] or false
end

function spawnVehicle(vid,x,y,z,rx,ry,rz,i,d)
  if(isVehicleSpawned(vid))then
    return false;
  end
  local result = exports.db:queryTable("select * from %s where id = ? limit 1", "vehicles", vid)
  if(not result or #result == 0)then
    return false
  end
  if(not i)then
    i = 0;
  end
  if(not d)then
    d = 0;
  end
  local position = {x,y,z,rx,ry,rz,i,d}
  local dbPosition = {}
  result = result[1]
  if(result.position)then
    result.position = split(result.position, ",")
    for i,v in ipairs(split(result.position, ","))do
      dbPosition[i] = tonumber(v)
    end
  end
  for i=1,8 do
    if(not position[i])then
      position[i] = dbPosition[i]
    end
  end
  if(not position[1] or not position[2] or not position[3])then
    return false
  end
  local vehicle = createVehicle(result.model,position[1], position[2], position[3], position[4], position[5], position[6])
  if(not vehicle)then
    return false
  end
  if(not spawnedVehiclesTypes[result.type])then
    spawnedVehiclesTypes[result.type] = {}
  end
  table.insert(spawnedVehiclesTypes[result.type], vehicle)
  setElementInterior(vehicle, position[7])
  setElementDimension(vehicle, position[8])
  setElementData(vehicle, "uid", vid);
  setElementData(vehicle, "type", result.type);
  setElementData(vehicle, "typeid", result.typeId);
end

