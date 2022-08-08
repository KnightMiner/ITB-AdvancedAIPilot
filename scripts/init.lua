local mod = {
	id = "advanced_ai_pilot",
	name = "Advanced AI Pilot",
	version = "1.1.1",
	modApiVersion = "2.5.1",
	pilotDeck = {}
}

--- Pilot IDs to make sure it is not mistyped
local PILOT_ADV = "Pilot_AdvancedAI"
local PILOT_BLOOD = "Pilot_AdvPsion"
local PILOT_BOT = "Pilot_AdvSnowbot"
local PILOT_XP = "Pilot_Original"

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
	Checks if the given pilot was unlocked

	@return True if the advanced AI was unlocked, false otherwise
]]
function mod:pilotUnlocked(id)
	local saveData = self:loadScript("saveData")
	local pilots = saveData.safeGet(Profile, "pilots")
	return pilots ~= nil and list_contains(pilots, id)
end

function mod:metadata()
	local values = {"starter", "deck", "both", "neither"}
	local strings = {"Starter Pilot", "Pilot Deck", "Both", "Neither"}
	local tooltips = {
		"Pilot is available as one of the two starter pilots.",
		"Pilot will appear in time pods and as perfect island rewards.",
		"Pilot appears both as a starter and in the pilot deck.",
		"Pilot cannot be found in timelines, only in hangar once unlocked."
	}
  modApi:addGenerationOption(
    PILOT_ADV,
    "Advanced AI Unit",
    "Select where the Advanced AI Unit shows up in timelines.",
    {values = values, strings=strings, tooltips = tooltips, value = "starter"}
  )
  modApi:addGenerationOption(
    PILOT_BLOOD,
    "Blood Psion",
    "Select where the Blood Psion shows up in timelines.",
    {values = values, strings=strings, tooltips = tooltips, value = "starter"}
  )
  modApi:addGenerationOption(
    PILOT_BOT,
    "Speed-Bot",
    "Select where the Speed-Bot shows up in timelines.",
    {values = values, strings=strings, tooltips = tooltips, value = "starter"}
  )
  modApi:addGenerationOption(
    PILOT_XP,
    "Ralph Karlson",
    "Select where Ralph Karlson shows up in timelines.",
    {values = values, strings=strings, tooltips = tooltips, value = "both"}
  )
end

function mod:init()
	addSprite("portraits/pilots", "Pilot_AdvancedAI")
	addSprite("portraits/pilots", "Pilot_AdvancedAI_2")
	addSprite("portraits/pilots", "Pilot_AdvancedAI_blink")
	addSprite("portraits/pilots", "Pilot_AdvPsion")
	addSprite("portraits/pilots", "Pilot_AdvPsion_2")
	addSprite("portraits/pilots", "Pilot_AdvSnowbot")
	addSprite("portraits/pilots", "Pilot_AdvSnowbot_2")

	-- rarity is non-zero so its available in the pilot selection screen
	CreatePilot{
		Id = PILOT_ADV,
		Name = "Adv. A.I. Unit",
		Personality = "Artificial",
		Rarity = 1,
		Sex = SEX_AI,
		Voice = "/voice/ai"
	}
	CreatePilot{
		Id = PILOT_BLOOD,
		Personality = "Vek",
		Rarity = 1,
		Sex = SEX_VEK,
		Skill = "AdvPsionRegen",
	  PowerCost = 1,
	}
	CreatePilot{
		Id = PILOT_BOT,
		Personality = "Artificial",
		Rarity = 1,
		Sex = SEX_AI,
		Skill = "AdvMoveSpeed",
	  PowerCost = 1,
	}

	-- clear rarity afterwards, in case another mod checks for that
	Pilot_AdvancedAI.Rarity = 0
	Pilot_AdvPsion.Rarity = 0
	Pilot_AdvSnowbot.Rarity = 0

	-- add missing mission start text to AI personality
	Personality.Artificial.Gamestart = "Status: Time breach successful."

	-- make pilot available as a recruit, thats how they are unlocked
	table.insert(Pilot_Recruits, PILOT_ADV)
	table.insert(Pilot_Recruits, PILOT_BLOOD)
	table.insert(Pilot_Recruits, PILOT_BOT)

	-- load in logic behind the skills
	self:loadScript("skills")

	-- rremove the pilot from the deck
	local oldCheckPilotDeck = checkPilotDeck
	local IDS = {PILOT_ADV, PILOT_BLOOD, PILOT_BOT, PILOT_XP}
	function checkPilotDeck()
		local wasEmpty = #GAME.PilotDeck == 0
		-- call original logic
		oldCheckPilotDeck()

		-- remove disabled pilots from the deck
		-- TODO: this should be a modloader feature
		if wasEmpty then
			for _, id in ipairs(IDS) do
				if not mod.pilotDeck[id] then
					remove_element(id, GAME.PilotDeck)
				end
			end
		end
	end
end

local function loadConfig(options, pilot, default)
	local value = (options[pilot] and options[pilot].value) or default

	-- mark the pilot as appearing in time pods
	mod.pilotDeck[pilot] = value == "both" or value == "deck"
	_G[pilot].Rarity = mod.pilotDeck[pilot] and 1 or 0

	-- add or remove pilot from the starter list
	local isStarter = value == "both" or value == "starter"
	if isStarter then
		if not list_contains(Pilot_Recruits, pilot) then
			table.insert(Pilot_Recruits, pilot)
		end
	else
		remove_element(pilot, Pilot_Recruits)
	end
end

function mod:load(options, version)
	modApi:setText("Pilot_AdvPsionRegen_Title", "Regen")
	modApi:setText("Pilot_AdvPsionRegen_Text", "Repair 1 HP before vek attack each turn.")
	modApi:setText("Pilot_AdvMoveSpeed_Title", "+1 Move")
	modApi:setText("Pilot_AdvMoveSpeed_Text", "Increases the mech's move speed by 1.")

	loadConfig(options, PILOT_ADV,   "starter")
	loadConfig(options, PILOT_BLOOD, "starter")
	loadConfig(options, PILOT_BOT,   "starter")
	loadConfig(options, PILOT_XP,    "both")
end

return mod
