local CeilingRaycastLimiterNPC = {
  Properties = {}
}
local currentCount = 0
function CeilingRaycastLimiterNPC:OnActivate()
  if self.scriptActivated == false or self.scriptActivated == nil then
    self.dataLayer = require("LyShineUI.UiDataLayer")
    self.playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local raidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    if raidId and raidId:IsValid() then
      local warDetails = WarDataServiceBus.Broadcast.GetWarForRaid(raidId)
      local isInvasion = warDetails:IsInvasion()
      if isInvasion then
        self.maxCount = 0
      else
        self.maxCount = 0
      end
    else
      self.maxCount = 5
    end
    self.scriptActivated = true
  else
    return
  end
end
function CeilingRaycastLimiterNPC:CanActivateMore()
  return currentCount < self.maxCount
end
function CeilingRaycastLimiterNPC:Activated()
  currentCount = currentCount + 1
end
function CeilingRaycastLimiterNPC:Deactivated()
  if currentCount <= 0 then
    Debug.Log("Warning: the currentCount variable is getting bellow zero")
  end
  currentCount = currentCount - 1
end
function CeilingRaycastLimiterNPC:OnDeactivate()
end
return CeilingRaycastLimiterNPC
