function Update()
	local f = io.open("E:\\Documents\\Rainmeter\\Skins\\ClaudeMeter\\@Resources\\Weekly7dResetsIn.txt")
	if f then
		local content = f:read("*a")
		f:close()
		content = content:match("([^%s]+)")
		return content or "0h"
	end
	return "0h"
end
