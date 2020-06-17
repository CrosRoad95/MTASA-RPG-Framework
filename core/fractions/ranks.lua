local fractionsRanks = {}

function cacheRank(rId)
  local data = {}
  local results = exports.db:queryTable("select valuekey, value from %s where rankId = ?", "fractionsranks", rId)
  if(#results == 0)then
    fractionsRanks[rId] = nil;
    return 
  end
  for i,v in ipairs(results)do
    if(tonumber(v.value))then
      data[v.valuekey] = tonumber(v.value)
    else
      data[v.valuekey] = fromJSON(v.value) or v.value
    end
  end
  fractionsRanks[rId] = data;
end

function fractionRankExists(rId)
  return fractionsRanks[rId] and true or false
end

function getFractionRankValue(rId, key)
  if(not fractionRankExists(rId))then
    return false
  end

  return fractionsRanks[rId][key]
end

function hasFractionRankValue(rId, key)
  local value = getFractionRankValue(rId, key)
  return value ~= nil and true or false
end

function setFractionRankValue(rId, key, value)
  if(not fractionRankExists(rId))then
    return false
  end
  
  if(hasFractionRankValue(rId, key))then
    exports.db:queryTableFree("update %s set value = ? where rankId = ? and valuekey = ? limit 1", "fractionsranks", toJSON(value, true), rId, key)
  else
    exports.db:queryTableFree("insert into %s (rankId, valuekey, value)values(?,?,?)", "fractionsranks", rId, key, toJSON(value, true))
  end
  cacheRank(rId)
  return true
end

function getFractionRanks()
  local t = {}
  for rId in pairs(fractionsRanks)do
    t[#t + 1] = rId
  end
  return t
end

function cacheRanks()
  fractionsRanks = {}
  local results = exports.db:queryTable("SELECT rankId FROM %s group by rankId", "fractionsranks", rId)
  for i,v in ipairs(results)do
    cacheRank(v.rankId)
  end
end
