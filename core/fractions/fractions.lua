local fractions = {}
local fractionNameById = {}
local fractionIdByName = {}
local resourceFractions = {}

function getFractionsIds()
  local t = {}
  for fId in pairs(fractions)do
    t[#t + 1] = fId
  end
  return t
end

function cacheFractions()
  cacheFractionsNameId()
  cacheFractionsMembers()
  cacheRanks()
end

function cacheFractionsNameId()
  fractionNameById = {}
  fractionIdByName = {}
  
  local results = exports.db:queryTable("select id,name from %s", "fractions")
  for i,v in ipairs(results)do
    fractionNameById[v.id] = v.name
    fractionIdByName[v.name] = v.id
    cacheFractionFromDatabaseById(v.id)
  end
end

function cacheFraction(row)
  fractionNameById[row.id] = row.name
  fractionIdByName[row.name] = row.id
  fractions[row.id] = {
    data = row,
    members = {},
    vehicles = {},
  }
end

function cacheFractionFromDatabaseById(id)
  local result = exports.db:queryTable("select * from %s where id = ? limit 1", "fractions", id)
  if(result and #result > 0)then
    result = result[1];
    cacheFraction(result)
    return;
  end
  -- zapobiegaj odpytywaniu bazy danych jeżeli frakcja nie istnieje
  fractions[id] = false
end

function getFractionById(id)
  if(fractions[id] == nil)then
    cacheFractionFromDatabaseById(id)
  end
  return fractions[id];
end

function getFractionIdByName(name)
  return fractionIdByName[name]
end

function getFractionNameById(id)
  return fractionNameById[id]
end

function getFractionColor(id)
  local fraction = getFractionById(id)
  if(fraction)then
    return fraction.data.color
  end
  return false
end

function getLastFractionId()
  local result = exports.db:queryTable("SELECT max(id) as id FROM %s limit 1", "fractions")
  if(result and #result > 0)then
    return result[1].id
  end
  return false
end

function createFraction(name, shortcut, color)
  local id = getFractionIdByName(name)
  if(id)then
    -- frakcja już istnieje w bazie danych, aktualizowanie danych
    exports.db:queryTableFree("update %s set shortcut = ?, color = ? where id = ? limit 1", "fractions", shortcut, color, name)
    cacheFractionFromDatabaseById(name)
    cacheFractionsNameId();
    return id
  else
    exports.db:queryTableFree("insert into %s (name,shortcut,color)values(?,?,?)", "fractions", name, shortcut, color)
    cacheFractionFromDatabaseByName(name)
    cacheFractionsNameId();
    return getLastFractionId()
  end
end

function fractionExists(fid)
  return fractions[fid] and true or false
end

function cleanUpFractions()

end

addEventHandler("onResourceStart", resourceRoot, cacheFractions)
addEventHandler("onResourceStop", resourceRoot, cleanUpFractions)
