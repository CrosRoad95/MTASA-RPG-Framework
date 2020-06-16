local groups = {}
local groupsPermissions = {}

function queryParentGroups(groupId, t, controlTable)
  local results = exports.db:queryTable("select inherit from %s where id = ? limit 1", "groups", groupId)
  for i,v in ipairs(results)do
    if(v.inherit)then
      for _,parentGroupId in ipairs(split(v.inherit, ","))do
        parentGroupId = tonumber(parentGroupId)
        if(parentGroupId)then
          if(not controlTable[parentGroupId])then
            controlTable[parentGroupId] = true
            t[#t + 1] = parentGroupId;
            queryParentGroups(parentGroupId, t, controlTable)
          end
        end
      end
    end
  end
end

function cacheGroupPermissions(groupId)
  local groupPermissions = {}
  local results = exports.db:queryTable("select action,access from %s where groupId = ?", "groupspriviliges", groupId)
  for i,v in ipairs(results)do
    local action = split(v.action, ".")
    if(#action == 2)then
      if(not groupPermissions[action[1]])then
        groupPermissions[action[1]] = {}
      end
      if(groupPermissions[action[1]][action[2]] ~= false)then
        groupPermissions[action[1]][action[2]] = v.access == "true"
      end
    end
  end
  groupsPermissions[groupId] = groupPermissions
end

function cacheGroup(groupId)
  groups[groupId] = {}
  local result = exports.db:queryTable("select * from %s where id = ? limit 1", "groups", groupId)
  if(not result or #result == 0)then return false end;
  result = result[1];

  local group = {}
  group.parents = {}
  queryParentGroups(result.id, group.parents, {})
  groups[groupId] = group
end

function cacheGroups()
  local results = exports.db:queryTable("select id from %s", "groups")
  for i,v in ipairs(results)do
    cacheGroup(v.id)
    cacheGroupPermissions(v.id)
  end
end

function destroyPermissionsGroup(groupId)
  exports.db:queryTableFree("delete from %s where id = ? limit 1", "groups", groupId)
  exports.db:queryTableFree("delete from %s where groupId = ? limit 1", "groupspriviliges", groupId)
  for i,v in ipairs(groups[groupId].parents)do
    cacheGroupPermissions(v)
  end
  groups[groupId] = false
  groupsPermissions[groupId] = false
end

function internalHasGroupPermissionTo(groupId, actionGroup, action)
  local permissions = groupsPermissions[groupId]
  if(permissions and permissions[actionGroup] and type(permissions[actionGroup][action]) == "boolean")then
    return permissions[actionGroup][action]
  end
  return nil
end

function hasGroupPermissionTo(groupId, actionGroup, action)
  local hasPermission = internalHasGroupPermissionTo(groupId, actionGroup, action)
  if(type(hasPermission) == "boolean")then
    return hasPermission;
  end
  local group = groups[groupId]
  if(not group)then
    return false
  end
  for i,v in ipairs(group.parents)do
    hasPermission = internalHasGroupPermissionTo(v, actionGroup, action)
    if(type(hasPermission) == "boolean")then
      return hasPermission;
    end
  end

  return false
end

function queryGroupByName(name)
  local result = exports.db:queryTable("select * from %s where lower(name) = ? limit 1", "groups", string.lower(name))
  if(result and #result == 1)then
    return result[1]
  end
  return false
end

function getLastGroupId()
  local result = exports.db:queryTable("select max(id) as id from %s limit 1", "groups")
  if(result and #result == 1)then
    return result[1].id
  end
  return false
end

function createPermissionsGroup(name, inherit)
  local result = queryGroupByName(name)
  if(result)then
    return false
  end
  if(type(inherit) == "table")then
    local inherit = table.concat(inherit, ",")
    exports.db:queryTableFree("insert into %s (name,inherit)values(?,?)", "groups",name, inherit)
  else
    exports.db:queryTableFree("insert into %s (name)values(?)", "groups", name)
  end
  local lastGroup = getLastGroupId();
  cacheGroup(lastGroup)
  cacheGroupPermissions(lastGroup)
  return lastGroup;
end

function groupExists(groupId)
  return groups[groupId] and true or false
end

function setGroupPermission(groupId, actionGroup, action, access)
  if(not groupExists(groupId))then
    return false
  end
  if(type(actionGroup) ~= "string" or type(action) ~= "string")then
    return false
  end
  local access = access and "true" or "false"
  local action = string.lower(actionGroup.."."..action)
  local result = exports.db:queryTable("select id from %s where groupId = ? and lower(action) = ?", "groupspriviliges", groupId, action)
  if(result and #result > 0)then
    exports.db:queryTableFree("update %s set access = ? where id = ? limit 1", "groupspriviliges", access, result[1].id)
  else
    exports.db:queryTableFree("insert into %s (groupId, action, access)values(?,?,?)", "groupspriviliges", groupId, action, access)
  end
  cacheGroupPermissions(groupId)
  return true
end

function getGroupPermissions(groupId, includeInherited, copy, t)
  if(not groupExists(groupId))then
    return false
  end
  if(includeInherited)then
    local permissions = {}
    getGroupPermissions(groupId, false, true, permissions)
    for i,v in ipairs(groups[groupId].parents)do
      getGroupPermissions(v, false, true, permissions)
    end
    return permissions;
  end
  if(copy)then
    if(not t)then
      t = {}
    end

    for group in pairs(groupsPermissions[groupId])do
      if(not t[group])then
        t[group] = {}
      end
      for action,access in pairs(groupsPermissions[groupId][group])do
        if(t[group][action] ~= false)then
          t[group][action] = access
        end
      end
    end
  else
    return groupsPermissions[groupId]
  end
end

addEventHandler("onResourceStart", resourceRoot, function()
  cacheGroups();
end)