---
-- Lists hooks added to GM:TTT2AdminCheck on startup, and locks the hook from further additions after initialization.
-- @author Wryyyong
-- @module TTT2AdminCheckWatch

local hook = hook
local table = table
local print = print
local debug = debug
local concommand = concommand

local TTT2AdminCheckLocked = TTT2AdminCheckLocked or nil
TTT2AdminCheckWatch = TTT2AdminCheckWatch or {}

-- Copy the existing hook.Add function to oldHookAdd if the latter does not already exist.
local oldHookAdd = oldHookAdd or hook.Add

---
-- Checks the contents of event_name and whether or not initialization has been completed before passing the arguments onto the original function.
-- @param string event_name The name of the event to hook onto
-- @param string name The unique ID for the hook
-- @param function func The function to execute when the hook is called
-- @realm shared
function hook.Add(event_name, name, func)
	if event_name == "TTT2AdminCheck" and TTT2AdminCheckLocked then return end
	oldHookAdd(event_name, name, func)
end

---
-- Sets a boolean that will prevent further hooks from being added to GM:TTT2AdminCheck.
-- @note This function is called at the end of GM:InitPostEntity on both the client and server.
-- @realm shared
function TTT2AdminCheckWatch.Lock()
	TTT2AdminCheckLocked = true
end

if SERVER then
	---
	-- Prints all hooks tied to GM:TTT2AdminCheck, along with the filepath of the hook's origin.
	-- @realm server
	function TTT2AdminCheckWatch.Report()
		local tbl
		tbl = hook.GetTable()
		tbl = tbl["TTT2AdminCheck"]

		local keys = table.GetKeys(tbl)

		print("")
		print("TTT2ADMINCHECK REPORT")
		print("=============================================================")
		print("")

		for _ = 1, #keys do
			local k = keys[_]
			local d = debug.getinfo(tbl[k], S)
			local v = d["short_src"]

			print(k .. " | " .. v)
		end

		print("")
		print("=============================================================")
		print("This is the end of the report output.")
		print("")
	end

	concommand.Add("admincheckreport", TTT2AdminCheckWatch.Report)
end
