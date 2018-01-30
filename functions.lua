
local lfs = require("lfs")
local fun = { }

function fun.alldata()
	local data = { }
	for file in lfs.dir("data") do
		if file:match("^srodata") then
			table.insert(data, file:match("^srodata%-(%d%d%d%d%-%d%d%-%d%d%-%d%dh%d%dm)"))
		end
	end
	table.sort(data)
	return data
end

function fun.lastdata()
	local data = fun.alldata()
	return data[#data]
end

function fun.prevdata()
	local data = fun.alldata()
	return data[#data-1]
end

function fun.diffdata(data)
	if not data then data = fun.lastdata() end
	if not data then return nil end
	local ref = { }
	ref.year, ref.month, ref.day, ref.hour, ref.min =
		data:match("(%d%d%d%d)%-(%d%d)%-(%d%d)%-(%d%d)h(%d%d)m")
	return os.difftime(os.time(), os.time(ref)) / 60
end

return fun
