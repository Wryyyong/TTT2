---
-- Reports hooks added to the hookWatchList table on server startup, and prevents those hooks from further additions after gamemode initialization.
-- @author Wryyyong
-- @module HookWatch

local ErrorNoHaltWithStack = ErrorNoHaltWithStack
local hook = hook
local print = print
local table = table
local debug = debug
local concommand = concommand

-- Main module table
hookWatch = hookWatch or {}

local hookWatchLocked = hookWatchLocked or nil

-- Table of eventNames to monitor
local hookWatchList = {
	TTT2AdminCheck = true
}

-- Copy the existing hook.Add function to oldHookAdd if the latter does not already exist.
local oldHookAdd = oldHookAdd or hook.Add

---
-- Checks the contents of eventName and whether or not initialization has been completed before passing the arguments onto the original hook.Add function.
-- @param string event_name The name of the event to hook onto
-- @param string name The unique ID for the hook
-- @param function func The function to execute when the hook is called
-- @realm shared
function hook.Add(event_name, name, func)
	if hookWatchLocked and hookWatchList[event_name] then
		ErrorNoHaltWithStack("Hook event '", event_name, "' is locked to further additions")

		return
	end

	oldHookAdd(event_name, name, func)
end

---
-- Sets a boolean that will prevent further events from being added to hooks present in hookWatchList.
-- @note This function is called at the end of GM:InitPostEntity on both the client and server.
-- @realm shared
function hookWatch.Lock()
	hookWatchLocked = true
end

if SERVER then
	---
	-- Prints all hooks tied to event names listed in hookWatchList, along with the filepath of the hook's origin.
	-- @realm server
	function hookWatch.Report()
		local hookTable = hook.GetTable()

		print("")
		print("TTT2 HOOKWATCH REPORT")
		print("=============================================================")
		print("")

		for hookEventNameProc, _ in SortedPairs(hookWatchList) do
			local hookEventName = hookTable[hookEventNameProc]

			if hookEventName then
				local hookEventList = table.GetKeys(hookEventName)

				print(hookEventNameProc .. ":")

				for hookIDList = 1, #hookEventList do
					local hookID = hookEventList[hookIDList]
					local hookFilePath = debug.getinfo(hookEventName[hookID], S)["source"]

					print("\t" .. hookID .. " | " .. hookFilePath)
				end

				print("")
			end
		end

		print("=============================================================")
		print("This is the end of the report output.")
		print("")
	end

	concommand.Add("hookwatchreport", hookWatch.Report)
end
