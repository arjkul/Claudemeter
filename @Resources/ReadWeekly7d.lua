function Update()
	local f = io.open("E:\\Documents\\Rainmeter\\Skins\\ClaudeMeter\\@Resources\\Weekly7d.txt")
	if f then
		local content = f:read("*a")
		f:close()
		content = content:match("([%d.]+)")
		return content or "0"
	end
	return "0"
end
