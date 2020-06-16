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
     ) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci
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
      PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci
   ]],
   ["groups"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'group id',
      `name` varchar(40) COLLATE utf8_polish_ci NOT NULL,
      `inherit` varchar(200) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'id grup po przecinku',
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci 
   ]],
   ["groupPrivilages"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `groupId` int(11) NOT NULL,
      `action` varchar(40) COLLATE utf8_polish_ci NOT NULL,
      `access` enum('true','false') COLLATE utf8_polish_ci NOT NULL DEFAULT 'false',
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci     
   ]]
}

function initializeTables()
  for tableName,sql in pairs(tables)do
    queryFree(string.format(sql, getTablePrefix()..tableName));
  end
end
addEventHandler("onDatabaseConnected", root, initializeTables)