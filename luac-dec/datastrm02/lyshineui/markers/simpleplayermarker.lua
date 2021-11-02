local SimplePlayerMarker = {
  Properties = {
    Icon = {
      default = EntityId()
    }
  },
  PREVIOUS_LOD_LEVEL_NONE = -1,
  PREVIOUS_LOD_LEVEL_FULL = 0,
  PREVIOUS_LOD_LEVEL_MEDIUM = 1,
  PREVIOUS_LOD_LEVEL_SMALL = 2
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local uiStyle = RequireScript("LyShineUI._Common.UIStyle")
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function SimplePlayerMarker:OnActivate()
  self.UIStyle = uiStyle
  tweener:OnActivate()
  registrar:RegisterEntity(self)
end
function SimplePlayerMarker:OnDeactivate()
  tweener:OnDeactivate()
  registrar:UnregisterEntity(self)
  dataLayer:UnregisterObservers(self)
  self.markerClass = nil
end
function SimplePlayerMarker:Init(dataPath)
  self.markerClass = UiMarkerBus.Event.GetSimpleMarker(self.entityId)
  if self.markerClass then
    dataLayer:RegisterDataCallback(self, dataPath .. ".MarkerComponentId", function(self, markerId)
      if markerId then
        self.markerClass:Initialize(markerId)
      end
    end)
    dataLayer:RegisterDataCallback(self, dataPath .. ".PrevLodLevel", function(self, prevLodLevel)
      self.prevLodLevel = prevLodLevel
    end)
    dataLayer:RegisterDataCallback(self, dataPath .. ".StopUpdate", function(self)
      self.markerClass:Uninitialize()
    end)
    dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", function(self)
      self.markerClass:OnSocialDataChanged()
    end)
  else
    Debug.Log("SimplePlayerMarker: Unable to initialize simple marker with path " .. tostring(dataPath))
    return
  end
  dataLayer:RegisterDataObserver(self, dataPath .. ".IsVisible", self.SetIsVisible)
end
local scaleDown = {scaleX = 0.7, scaleY = 0.7}
local scaleUp = {scaleX = 1.2, scaleY = 1.2}
local scaleTo1 = {scaleX = 1, scaleY = 1}
function SimplePlayerMarker:SetIsVisible(isVisible)
  local isEnabled = isVisible == true
  if isEnabled then
    UiImageBus.Event.SetAlpha(self.Properties.Icon, 1)
    local animDuration = 0.25
    if self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_NONE then
      tweener:PlayFromC(self.Properties.Icon, animDuration, scaleDown, tweenerCommon.scaleTo1)
    elseif self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_FULL then
      tweener:PlayFromC(self.Properties.Icon, animDuration, scaleUp, tweenerCommon.scaleTo1)
    elseif self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_MEDIUM then
      tweener:PlayFromC(self.Properties.Icon, animDuration, scaleUp, tweenerCommon.scaleTo1)
    elseif self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_SMALL then
      tweener:Set(self.Properties.Icon, scaleTo1)
    end
  else
    UiImageBus.Event.SetAlpha(self.Properties.Icon, 0)
  end
end
return SimplePlayerMarker
