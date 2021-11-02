local ScriptLimiter = {
  Properties = {}
}
local currentCount = 0
local maxCount = 0
function ScriptLimiter:OnActivate()
  if self.scriptActivated == false or self.scriptActivated == nil then
    self.dataLayer = require("LyShineUI.UiDataLayer")
    self.playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    self:setMaxCount()
    self.scriptActivated = true
  else
    return
  end
end
function ScriptLimiter:setMaxCount()
  local raidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  if raidId and raidId:IsValid() then
    local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(raidId)
    local isInvasion = warDetails:IsInvasion()
    if isInvasion then
      maxCount = 2
    else
      maxCount = 2
    end
  else
    maxCount = 5
  end
end
function ScriptLimiter:CanActivateMore()
  self:setMaxCount()
  return currentCount < maxCount
end
function ScriptLimiter:Activated()
  currentCount = currentCount + 1
end
function ScriptLimiter:Deactivated()
  if currentCount <= 0 then
    Debug.Log("Warning: the currentCount variable is getting bellow zero")
  end
  currentCount = currentCount - 1
end
function ScriptLimiter:OnDeactivate()
  self.scriptActivated = false
end
return ScriptLimiter
