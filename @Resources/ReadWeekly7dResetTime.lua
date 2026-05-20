function Update()
	local f = io.open("E:\\Documents\\Rainmeter\\Skins\\ClaudeMeter\\@Resources\\Weekly7dResetTime.txt")
	if f then
		local content = f:read("*a")
		f:close()
		return content:gsub("^%s+", ""):gsub("%s+$", "")
	end
	return "--"
end
