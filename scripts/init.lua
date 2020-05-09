local mod = {
	id = "advanced_ai_pilot",
	name = "Advanced AI Pilot",
	version = "1.0.0",
	modApiVersion = "2.5.1",
	requirements = {"Generic"}
}

--- Pilot ID to make sure it is not mistyped
local PILOT_ID = "Pilot_AdvancedAI"

--[[--
	Adds a sprite to the game

	@param path      Base sprite path
	@param filename  File to add
]]
local function addSprite(path, filename)
	modApi:appendAsset(
		string.format("img/%s/%s.png", path, filename),
		string.format("%simg/%s/%s.png", mod.resourcePath, path, filename)
	)
end

--[[--
  Helper function to load mod scripts

  @param  name   Script path relative to mod directory
]]
function mod:loadScript(path)
  return require(self.scriptPath..path)
end

--[[--
	Filters the advanced AI out of the extended pilots list

	@return Extended Pilots list without Advanced AI pilot
]]
local function filterPilotList()
	-- TODO: would like to cache this, but its a bit risky
	local filteredPilotList = {}
	for _, v in ipairs(PilotListExtended) do
		if v ~= PILOT_ID then
			filteredPilotList[#filteredPilotList+1] = v
		end
	end

	return filteredPilotList
end

--[[--
	Checks if the advanced AI pilot was unlocked

	@return True if the advanced AI was unlocked, false otherwise
]]
function mod:pilotUnlocked()
	local saveData = self:loadScript("saveData")
	local pilots = saveData.safeGet(Profile, "pilots")
	return pilots ~= nil and list_contains(pilots, PILOT_ID)
end

function mod:init()
	addSprite("portraits/pilots", "Pilot_AdvancedAI")
	addSprite("portraits/pilots", "Pilot_AdvancedAI_2")
	addSprite("portraits/pilots", "Pilot_AdvancedAI_blink")

	-- rarity is non-zero so its available in the pilot selection screen
	CreatePilot{
		Id = PILOT_ID,
		Name = "Adv. A.I. Unit",
		Personality = "Artificial",
		Rarity = 1, -- insert into  pilot list
		Cost = 1,
		Sex = SEX_AI,
		Voice = "/voice/ai"
	}

	-- clear rarity afterwards, in case another mod checks for that
	Pilot_AdvancedAI.Rarity = 0

	-- add missing mission start text to AI personality
	Personality.Artificial.Gamestart = "Status: Time breach successful."

	-- make pilot available as a recruit, thats how they are unlocked
	table.insert(Pilot_Recruits, "Pilot_AdvancedAI")

	-- prevent the advanced AI from dropping in timepods or appearing as an island reward
	local oldGetPilotDrop = getPilotDrop
	function getPilotDrop()
		-- filter out advanced AI
		local oldPilotList = PilotListExtended
		PilotListExtended = filterPilotList()

		-- call logic
		local result = oldGetPilotDrop()

		-- restore extended pilots list
		PilotListExtended = oldPilotList
		return result
	end
	local oldInitializeDecks = initializeDecks
	function initializeDecks()
		-- filter out advanced AI
		local oldPilotList = PilotListExtended
		PilotListExtended = filterPilotList()

		-- call logic
		oldInitializeDecks()

		-- restore extended pilots list
		PilotListExtended = oldPilotList
	end
end

function mod:load(options, version)
	-- the game only unlocks pilots from the inventory, so we need our recruit in inventory
	modApi:addPostStartGameHook(function()
		-- skip if unlocked
		if not self:pilotUnlocked() then
			-- check if any of the three pilots are the AI unit
			local saveData = self:loadScript("saveData")
			local hasAI = false
			for i = 0, 2 do
				local pilot = saveData.safeGet(GameData, "current", "pilot" .. i)
				if saveData.safeGet(pilot, "id") == PILOT_ID then
					-- do not run if the pilot has XP, that means they came from another run and somehow are still not unlocked
					-- skip to prevent deleting a good pilot
					if saveData.safeGet(pilot, "exp") > 0 then
						hasAI = false
						break
					end
					-- normal pilots
					hasAI = true
				end
			end

			-- if so, add it to the inventory then remove it to unlock
			if hasAI then
				-- ideally, we would add and remove a pilot from inventory
				-- unfortunately, there is no way to filter RemoveItem, it removes all copies, even the pilot in the mech
				-- so just manually "take the pilot out" for the player to unlock. Does fail the achievement criteria, but not much I can do about that
				--Game:AddPilot(PILOT_ID)
				Game:RemoveItem(PILOT_ID)
				Game:AddPilot(PILOT_ID)
			end
		end
	end)
end

return mod
