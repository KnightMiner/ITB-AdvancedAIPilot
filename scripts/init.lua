local mod = {
	id = "advanced_ai_pilot",
	name = "Advanced AI Pilot",
	version = "1.0.0",
	requirements = {}
}

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
	Filters the advanced AI out of the extended pilots list

	@return Extended Pilots list without Advanced AI pilot
]]
local function filterPilotList()
	-- TODO: would like to cache this, but its a bit risky
	local filteredPilotList = {}
	for _, v in ipairs(PilotListExtended) do
		if v ~= "Pilot_AdvancedAI" then
			filteredPilotList[#filteredPilotList+1] = v
		end
	end

	return filteredPilotList
end

-- Cache for pilot unlocked, as the function is called pretty frequently in storage and the pilot selection screen
-- In both cases, the pilot is indeed unlocked
-- Might cause issues switching profiles, but mod loader does not exactly support that
local pilotUnlocked = false

--[[--
	Checks if the advanced AI pilot was unlocked

	@return True if the advanced AI was unlocked, false otherwise
]]
local function pilotUnlocked()
	if pilotUnlocked then
		return true
	end
	-- check and if true, cache it was true
	pilotUnlocked = Profile ~= nil and Profile.pilots ~= nil and list_contains(Profile.pilots, "Pilot_AdvancedAI")
	return pilotUnlocked
end

function mod:init(self)
	addSprite("portraits/pilots", "Pilot_AdvancedAI")
	addSprite("portraits/pilots", "Pilot_AdvancedAI_2")
	addSprite("portraits/pilots", "Pilot_AdvancedAI_blink")

	-- rarity is non-zero so its available in the pilot selection screen
	CreatePilot{
		Id = "Pilot_AdvancedAI",
		Name = "Adv. A.I. Unit",
		Personality = "Artificial",
		Rarity = 1, -- insert into  pilot list
		Cost = 1,
		Sex = SEX_AI,
		Voice = "/voice/ai",
		Skill = "UnlockableSkill"
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

	-- add skill description
	local originalGetSkillInfo = GetSkillInfo
	function GetSkillInfo(skill)
		if skill == "UnlockableSkill" then
			if pilotUnlocked() then
				return PilotSkill("Recruitable", "No Special Ability")
			else
				return PilotSkill("Recruitable", "Place in storage to unlock as a starter pilot")
			end
		end
		return originalGetSkillInfo(skill)
	end
end

function mod:load(self, options, version)
end

return mod
