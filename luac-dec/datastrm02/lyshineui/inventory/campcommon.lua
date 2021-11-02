local CampCommon = {
  isCampAvailable = nil,
  distanceValue = nil,
  distanceText = nil,
  campDestroyTime = 1
}
function CampCommon:UpdateCampInfo(dataLayer)
  local numHomePoints = dataLayer:GetDataFromNode("Hud.LocalPlayer.HomePoints.Count")
  local campID = "None"
  local campNode = dataLayer:GetDataNode("Hud.LocalPlayer.Camping.GDEID")
  if campNode then
    campID = campNode:GetData()
  end
  local hasCamp = campID ~= "None"
  if numHomePoints ~= nil and 0 < numHomePoints and hasCamp then
    local homePointsDataNode = dataLayer:GetDataNode("Hud.LocalPlayer.HomePoints")
    for i = 1, numHomePoints do
      local currentDataNode = homePointsDataNode[tostring(i)]
      local id = currentDataNode.GDEID:GetData()
      if id == campID then
        local playerPosition = dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
        local campPosition = currentDataNode.Position:GetData()
        local text, distance = GetLocalizedDistance(playerPosition, campPosition)
        self.distanceValue = distance
        self.distanceText = LocalizeDecimalSeparators(text)
        break
      end
    end
  end
  self.isCampAvailable = not hasCamp
end
function CampCommon:GetIsCampAvailable()
  return self.isCampAvailable
end
function CampCommon:GetCampDistanceValue()
  return self.distanceValue
end
function CampCommon:GetCampDistanceText()
  return self.distanceText
end
function CampCommon:GetCampDestroyTime()
  return self.campDestroyTime
end
function CampCommon:GetCanPlaceOrDestroyCamp()
  local dataLayer = RequireScript("LyShineUI.UiDataLayer")
  local isUnlocked = dataLayer:GetDataFromNode("Hud.LocalPlayer.Camping.IsUnlocked")
  if not isUnlocked then
    return false
  end
  local vitalsEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.VitalsEntityId")
  local isInDeathsDoor = VitalsComponentRequestBus.Event.IsDeathsDoor(vitalsEntityId)
  local isAtWar = WarDataClientRequestBus.Broadcast.IsInSiegeWarfare()
  return not isInDeathsDoor and not isAtWar
end
return CampCommon
