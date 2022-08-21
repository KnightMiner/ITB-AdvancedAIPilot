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
end

function mod:load(options, version)
	modApi:setText("Pilot_AdvPsionRegen_Title", "Regen")
	modApi:setText("Pilot_AdvPsionRegen_Text", "Repair 1 HP before vek attack each turn.")
	modApi:setText("Pilot_AdvMoveSpeed_Title", "+1 Move")
	modApi:setText("Pilot_AdvMoveSpeed_Text", "Increases the mech's move speed by 1.")
end

return mod
