function Update()
	local f = io.open("E:\\Documents\\Rainmeter\\Skins\\ClaudeMeter\\@Resources\\Session5hResetTime.txt")
	if f then
		local content = f:read("*a")
		f:close()
		return content:match("([^%s]+)")
	end
	return "--"
end
