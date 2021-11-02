local CeilingRaycastLimiter = {
  Properties = {}
}
local currentCount = 0
function CeilingRaycastLimiter:OnActivate()
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
        self.maxCount = 5
      end
    else
      self.maxCount = 10
    end
    self.scriptActivated = true
  else
    return
  end
end
function CeilingRaycastLimiter:CanActivateMore()
  return currentCount < self.maxCount
end
function CeilingRaycastLimiter:Activated()
  currentCount = currentCount + 1
end
function CeilingRaycastLimiter:Deactivated()
  if currentCount <= 0 then
    Debug.Log("Warning: the currentCount variable is getting bellow zero")
  end
  currentCount = currentCount - 1
end
function CeilingRaycastLimiter:OnDeactivate()
end
return CeilingRaycastLimiter
