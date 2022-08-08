local mod = mod_loader.mods[modApi.currentMod]
local pawnMove = mod:loadScript("pawnMoveSkill")
local saveData = mod:loadScript("saveData")

-- implementation of +1 move skill
local oldMoveTarget = Move.GetTargetArea
function Move:GetTargetArea(p)
  if Pawn:IsAbility("AdvMoveSpeed") then
    if pawnMove.IsTargetAreaExt() then
      return pawnMove.GetTargetArea(p, Pawn:GetMoveSpeed() + 1)
    end
  end
  return oldMoveTarget(self, p)
end

--[[--
  Gets the max health for a pawn. Will be a little low in the mech tester

  @param pawn  Pawn to get health for
  @return Max health for the pawn.
]]
local function getPawnMaxHealth(pawn)
  -- if no region, just use a large number
  -- would rather an unneeded animation play than no healing
  if saveData.dataUnavailable() then
    --return _G[pawn:GetType()]:GetHealth()
    return 20
  end
  -- fetch from save data if available
  return saveData.getPawnKey(pawn, "max_health")
end

-- implementation of regen skill
modApi.events.onPostEnvironment:subscribe(function(mission)
  if Game:GetTurnCount() ~= 0 then
    local mechs = extract_table(Board:GetPawns(TEAM_PLAYER))
    for i,id in pairs(mechs) do
      local pawn = Board:GetPawn(id)
      if pawn:IsAbility("AdvPsionRegen") and not pawn:IsDead() and pawn:GetHealth() < getPawnMaxHealth(pawn) then
        -- local effect = SkillEffect()
        -- effect:AddDamage()
        Board:DamageSpace(SpaceDamage(pawn:GetSpace(), -1))
      end
    end
  end
end)
