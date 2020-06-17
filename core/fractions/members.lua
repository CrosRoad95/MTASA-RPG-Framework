local fractionsMembers = {}
local members = {}

function cacheFractionMembers(fId)
  local tempMembers = {}
  local results = exports.db:queryTable("select pid from %s where fid = ?", "fractionsmembers", fId)
  for pid,data in pairs(members)do
    if(data.fraction == fid)then
      members[pid] = nil
    end
  end
  for i,v in ipairs(results)do
    tempMembers[#tempMembers + 1] = v.pid
    members[v.pid] = {
      fraction = fId,
    }
  end
  fractionsMembers[fId] = tempMembers;
end

function quaryGetPlayerFraction(pId)
  local result = exports.db:queryTable("select fid from %s where pid = ? limit 1", "fractionsmembers", pId)
  if(result and #result > 0)then
    return result[1].fid
  else
    return false
  end
end

function quaryHasPlayerFraction(pId)
  return quaryGetPlayerFraction(pId) and true or false
end

function getPlayerFraction(pId)
  if(members[pId])then
    return members[pId].fraction
  end
  return false
end

function hasPlayerFraction(pId)
  return getPlayerFraction(pId) and true or false
end

function cacheFractionsMembers()
  for i,fId in ipairs(getFractionsIds())do
    cacheFractionMembers(fId)
  end
end

function getFractionMembers(fId)
  return fractionsMembers[fId] or false
end

function addFractionMember(fId, pId, rank)
  if(not fractionExists(fId))then
    return false
  end
  if(quaryHasPlayerFraction(pId))then
    return false
  end
  exports.db:queryTableFree("insert into %s (fid, pid, rank)values(?,?,?)","fractionsmembers", fId, pId, rank)
  return true
end
