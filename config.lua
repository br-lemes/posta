

local hibernate = "hibernate.cfg.xml"

--------------------------------------------------------------------------------

local cfgfile = io.open(hibernate, "r")
local buffer = cfgfile:read("*a")
cfgfile:close()

local host, database = buffer:match('<property name="hibernate.connection.url">jdbc:mysql://(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)/(%a*)</property>')
local user = buffer:match('<property name="hibernate.connection.username">(%a*)</property>')
local password = buffer:match('<property name="hibernate.connection.password">([A-Za-z0-9+/]*=?=?)</property>')

local base64 = require("base64")

return {
	host = host,
	database = database,
	user = user,
	password = base64.decode(password),
}
