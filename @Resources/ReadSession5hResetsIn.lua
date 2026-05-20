function Update()
	local f = io.open("E:\\Documents\\Rainmeter\\Skins\\ClaudeMeter\\@Resources\\Session5hResetsIn.txt")
	if f then
		local content = f:read("*a")
		f:close()
		content = content:match("([^%s]+)")
		return content or "0m"
	end
	return "0m"
end
