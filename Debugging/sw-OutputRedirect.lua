if not __ConsoleHasInit then rconsolecreate() rconsolesettitle("Script-Ware Developer Console Redirect") end

local OldPrint, OldWarn;
OldPrint = hookfunction(print, newcclosure(function(...)
	if checkcaller() then
		local Args = {...}
		if #Args > 0 then
			rconsoleprint("[*]: ")
			for i, Arg in ipairs(Args) do
				rconsoleprint(tostring(Arg))
				if #Args > i then rconsoleprint("    ") end
			end
			rconsoleprint("\n")
		else
			rconsoleprint("[*]: \n")
		end
	else
		return OldPrint(...)
	end
end))

OldWarn = hookfunction(warn, newcclosure(function(...)
	if checkcaller() then
		local Args = {...}
		if #Args > 0 then
			rconsoleprint("[!]: ")
			for i, Arg in ipairs(Args) do
				rconsoleprint(tostring(Arg))
				if #Args > i then rconsoleprint("    ") end
			end
			rconsoleprint("\n")
		else
			rconsoleprint("[!]: \n")
		end
	else
		return OldWarn(...)
	end
end))

getgenv().__ConsoleHasInit = true
