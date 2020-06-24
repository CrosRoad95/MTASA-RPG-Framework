local tables = {
  ["accounts"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `login` varchar(32) COLLATE utf8_polish_ci NOT NULL,
      `password` varchar(60) COLLATE utf8_polish_ci NOT NULL,
      `serial` varchar(32) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'serial rejestracji',
      `lastSerial` varchar(32) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'ostatni serial',
      `ip` varchar(22) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'ip rejestracji',
      `lastIp` varchar(22) DEFAULT NULL COMMENT 'ostatnie ip',
      `registerTs` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'data rejestracji',
      `lastUsed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'data ostatniego logowania',
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci
  ]],
  ["accountsDatas"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `uid` int(11) NOT NULL COMMENT 'id konta',
      `valuekey` varchar(128) COLLATE utf8_polish_ci NOT NULL COMMENT 'klucz',
      `value` text COLLATE utf8_polish_ci NOT NULL COMMENT 'wartosc',
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci
  ]],
  ["fractions"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `name` varchar(120) COLLATE utf8_polish_ci NOT NULL,
      `shortcut` varchar(6) COLLATE utf8_polish_ci NOT NULL,
      `color` int(11) NOT NULL,
      `privilagesGroup` int(11) NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci
   ]],
   ["fractionsmembers"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'member id',
      `fid` int(11) NOT NULL COMMENT 'fraction id',
      `pid` int(11) NOT NULL COMMENT 'player id',
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci     
   ]],
   ["fractionsranks"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `rankId` int(11) NOT NULL,
      `valuekey` varchar(30) COLLATE utf8_polish_ci NOT NULL,
      `value` text COLLATE utf8_polish_ci NOT NULL,
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci     
   ]],
   ["fractionsmembersdata"] = [[
    CREATE TABLE IF NOT EXISTS %s (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `memberId` int(11) NOT NULL,
      `valueKey` varchar(64) NOT NULL,
      `value` text NOT NULL,
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci     
   ]],
   ["groups"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'group id',
      `name` varchar(40) COLLATE utf8_polish_ci NOT NULL,
      `inherit` varchar(200) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'id grup po przecinku',
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci 
   ]],
   ["groupPrivilages"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `groupId` int(11) NOT NULL,
      `action` varchar(40) COLLATE utf8_polish_ci NOT NULL,
      `access` enum('true','false') COLLATE utf8_polish_ci NOT NULL DEFAULT 'false',
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci     
   ]],
   ["vehicles"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `model` smallint(5) unsigned NOT NULL,
      `type` int(10) unsigned NOT NULL,
      `typeid` int(10) unsigned NOT NULL,
      `position` varchar(50) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'x,y,z,rx,ry,rz,i,d',
      `tuning` varchar(200) COLLATE utf8_polish_ci DEFAULT NULL,
      `color` varchar(47) COLLATE utf8_polish_ci NOT NULL DEFAULT '255,255,255,255,255,255,255,255,255,255,255,255',
      `colorlights` varchar(11) COLLATE utf8_polish_ci NOT NULL DEFAULT '255,255,255',
      `paintjob` tinyint(3) unsigned NOT NULL DEFAULT '3',
      `platetext` varchar(8) COLLATE utf8_polish_ci DEFAULT NULL,
      `variant` varchar(7) COLLATE utf8_polish_ci NOT NULL DEFAULT '255,255',
      `panels` varchar(13) COLLATE utf8_polish_ci NOT NULL DEFAULT '0,0,0,0,0,0,0',
      `doors` varchar(11) COLLATE utf8_polish_ci NOT NULL DEFAULT '0,0,0,0,0,0',
      `lights` varchar(7) COLLATE utf8_polish_ci NOT NULL DEFAULT '0,0,0,0',
      `health` smallint(5) unsigned NOT NULL DEFAULT '1000',
      `mileage` decimal(10,3) NOT NULL DEFAULT '0.000',
      `fuel` float DEFAULT NULL,
      `fuelsecondary` float DEFAULT NULL,
      `fueltype` smallint(5) DEFAULT NULL,
      `fueltypesecondary` smallint(5) DEFAULT NULL,
      `upgrades` varchar(40) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'id ulepszen po przecinku',
      `wheelstatus` varchar(19) COLLATE utf8_polish_ci NOT NULL DEFAULT '1000,1000,1000,1000',
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci
   ]]
}

function initializeTables()
  for tableName,sql in pairs(tables)do
    queryFree(string.format(sql, getTablePrefix()..tableName));
  end
end
addEventHandler("onDatabaseConnected", root, initializeTables)