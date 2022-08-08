local mod = {
	id = "advanced_ai_pilot",
	name = "Advanced AI Pilot",
	version = "1.1.1",
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
		Rarity = 1,
		Cost = 1,
		Sex = SEX_AI,
		Voice = "/voice/ai"
	}
	-- clear rarity afterwards, in case another mod checks for that
	Pilot_AdvancedAI.Rarity = 0

	-- add missing mission start text to AI personality
	Personality.Artificial.Gamestart = "Status: Time breach successful."

	-- make pilot available as a recruit, thats how they are unlocked
	table.insert(Pilot_Recruits, PILOT_ID)

	-- rremove the pilot from the deck
	local oldInitializeDecks = initializeDecks
	function initializeDecks()
		-- call original logic
		oldInitializeDecks()
		-- remove our pilot from the deck
		remove_element(pilot, GAME.PilotDeck)
	end
end

function mod:load(options, version)
end

return mod
