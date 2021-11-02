local SiegeWeaponMarker = {
  Properties = {
    TypeIcon = {
      default = EntityId()
    },
    AmmoText = {
      default = EntityId()
    },
    CooldownMeter = {
      default = EntityId()
    },
    TargetTag = {
      default = EntityId()
    },
    LowHealthIcon = {
      default = EntityId()
    },
    HealthBar = {
      default = EntityId()
    },
    HealthBarFill = {
      default = EntityId()
    },
    HealthBarDeltaFill = {
      default = EntityId()
    },
    HealthBarFrame = {
      default = EntityId()
    }
  },
  siegeWeaponType = nil,
  iconWidth = 32,
  FRAME_NO_AMMO = "lyshineui/images/markers/marker_seigeHealthFrame.dds",
  FRAME_WITH_AMMO = "lyshineui/images/markers/marker_seigeHealthFrameWithText.dds"
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local uiStyle = RequireScript("LyShineUI._Common.UIStyle")
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local markerTypeData = RequireScript("LyShineUI.Markers.MarkerData")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function SiegeWeaponMarker:OnActivate()
  self.UIStyle = uiStyle
  tweener:OnActivate()
  registrar:RegisterEntity(self)
  self.isEnabled = false
  self.maxAmmo = 0
  self.currentAmmo = 0
  self.raidId = RaidId()
  self.localPlayerRaidId = RaidId()
  self.tickHandler = nil
  self.cooldownDuration = 1
  self.cooldownEndTime = WallClockTimePoint()
  self.typeIcons = {}
  self.typeIcons[eSiegeWeaponType_Ballista] = "lyshineui/images/markers/ballista.png"
  self.typeIcons[eSiegeWeaponType_Repeater] = "lyshineui/images/markers/repeater.png"
  self.typeIcons[eSiegeWeaponType_Explosive] = "lyshineui/images/markers/bomb.png"
  self.typeIcons[eSiegeWeaponType_FireBarrel] = "lyshineui/images/markers/barreldropper.png"
  self.typeIcons[eSiegeWeaponType_Horn] = "lyshineui/images/markers/horn.png"
  self.typeIcons[eSiegeWeaponType_PlatformCannon] = "lyshineui/images/markers/ballista.png"
  self.typeIcons[eSiegeWeaponType_PlatformRepeater] = "lyshineui/images/markers/repeater.png"
  self.typeIcons[eSiegeWeaponType_PlatformExplosive] = "lyshineui/images/markers/bomb.png"
  UiElementBus.Event.SetIsEnabled(self.entityId, self.isEnabled)
end
function SiegeWeaponMarker:OnDeactivate()
  tweener:OnDeactivate()
  registrar:UnregisterEntity(self)
  if self.tickHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickHandler = nil
  end
  dataLayer:UnregisterObservers(self)
  self.markerClass = nil
end
function SiegeWeaponMarker:Init(dataPath)
  if not self.typeInfo then
    local originalTypeInfo = markerTypeData:GetTypeInfo("SiegeWeapon")
    self.typeInfo = ShallowCopy(originalTypeInfo)
  end
  self.markerName = dataPath
  self.markerClass = UiMarkerBus.Event.GetMarker(self.entityId)
  if self.markerClass then
    dataLayer:RegisterDataCallback(self, dataPath .. ".MarkerComponentId", function(self, markerId)
      if markerId then
        self.markerClass:Initialize(markerId)
        self.isFirstUpdate = true
      end
    end)
    dataLayer:RegisterDataCallback(self, dataPath .. ".StopUpdate", function(self)
      self.markerClass:Uninitialize()
    end)
    dataLayer:RegisterDataCallback(self, dataPath .. ".HealthPercent", self.UpdateHealthPercent)
    dataLayer:RegisterDataCallback(self, dataPath .. ".CurrentAmmo", self.UpdateCurrentAmmo)
    dataLayer:RegisterDataCallback(self, dataPath .. ".MaximumAmmo", self.UpdateMaxAmmo)
    dataLayer:RegisterDataCallback(self, dataPath .. ".SiegeWeaponType", self.UpdateSiegeWeaponType)
    dataLayer:RegisterDataCallback(self, dataPath .. ".CooldownDuration", self.UpdateCooldownDuration)
    dataLayer:RegisterDataCallback(self, dataPath .. ".CooldownEndTime", self.UpdateCooldownEndTime)
    dataLayer:RegisterDataCallback(self, dataPath .. ".RaidId", self.UpdateRaidId)
    dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Raid.Id", self.UpdatePlayerRaidId)
    dataLayer:RegisterDataObserver(self, dataPath .. ".IsTargetTagged", function(self, isTargetTagged)
      UiElementBus.Event.SetIsEnabled(self.Properties.TargetTag, isTargetTagged)
    end)
  else
    Debug.Log("SiegeWeaponMarker: Unable to initialize marker with path " .. tostring(dataPath))
    return
  end
  dataLayer:RegisterDataObserver(self, dataPath .. ".IsVisible", self.SetIsVisible)
  UiImageBus.Event.SetColor(self.Properties.LowHealthIcon, self.UIStyle.COLOR_RED_MEDIUM)
  UiElementBus.Event.SetIsEnabled(self.Properties.AmmoText, false)
end
function SiegeWeaponMarker:SetIsVisible(isVisible)
  self.isEnabled = isVisible == true
  self:CheckVisibility()
end
function SiegeWeaponMarker:SetState(stateData, stateIndex, forceState)
  local currentState = stateData.currentState
  if currentState ~= stateIndex or forceState then
    stateData.currentState = stateIndex
  end
end
function SiegeWeaponMarker:UpdateHealthPercent(health)
  if not health then
    return
  end
  local color = self.UIStyle.COLOR_WHITE
  if health < 0.5 then
    color = self.UIStyle.COLOR_RED_MEDIUM
  end
  UiImageBus.Event.SetColor(self.Properties.TypeIcon, color)
  local isVisible = health < 0.5
  UiElementBus.Event.SetIsEnabled(self.Properties.LowHealthIcon, isVisible)
  local curHealthScale = UiTransformBus.Event.GetScale(self.Properties.HealthBarFill)
  if health < curHealthScale.x or self.isFirstUpdate then
    if self.isFirstUpdate then
      UiTransformBus.Event.SetScaleX(self.Properties.HealthBarDeltaFill, health)
      self.isFirstUpdate = false
    else
      local delay = self.typeInfo.barVFXDelay
      tweener:Play(self.Properties.HealthBarDeltaFill, 0.3, {scaleX = health, delay = delay})
    end
  end
  curHealthScale.x = health
  UiTransformBus.Event.SetScale(self.Properties.HealthBarFill, curHealthScale)
end
function SiegeWeaponMarker:UpdateCurrentAmmo(curAmmo)
  if not curAmmo then
    return
  end
  self.currentAmmo = curAmmo
  UiTextBus.Event.SetTextWithFlags(self.Properties.AmmoText, tostring(self.currentAmmo) .. "/" .. tostring(self.maxAmmo), eUiTextSet_SetAsIs)
  if self.maxAmmo > 0 then
    local percent = self.currentAmmo / self.maxAmmo
    local color = self.UIStyle.COLOR_WHITE
    if percent < 0.25 then
      color = self.UIStyle.COLOR_RED_MEDIUM
    end
    UiTextBus.Event.SetColor(self.Properties.AmmoText, color)
  end
  self:CheckVisibility()
end
function SiegeWeaponMarker:UpdateMaxAmmo(maxAmmo)
  if maxAmmo then
    self.maxAmmo = maxAmmo
    self:UpdateCurrentAmmo(self.currentAmmo)
    self:CheckVisibility()
  end
end
function SiegeWeaponMarker:UpdateSiegeWeaponType(siegeWeaponType)
  self.siegeWeaponType = siegeWeaponType
  if KeyIsInsideTable(self.typeIcons, siegeWeaponType) then
    UiImageBus.Event.SetSpritePathname(self.Properties.TypeIcon, self.typeIcons[siegeWeaponType])
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.TypeIcon, self.typeIcons[eSiegeWeaponType_Ballista])
  end
end
function SiegeWeaponMarker:UpdateCooldownDuration(duration)
  self.cooldownDuration = duration
  UiImageBus.Event.SetFillAmount(self.Properties.CooldownMeter, 0)
  self:CheckVisibility()
end
function SiegeWeaponMarker:UpdateCooldownEndTime(endTime)
  self.cooldownEndTime = endTime
  self:CheckVisibility()
end
function SiegeWeaponMarker:UpdateRaidId(raidId)
  if raidId ~= nil then
    self.raidId = raidId
  else
    self.raidId = RaidId()
  end
  self:CheckVisibility()
end
function SiegeWeaponMarker:UpdatePlayerRaidId(raidId)
  if raidId ~= nil then
    self.localPlayerRaidId = raidId
  else
    self.localPlayerRaidId = RaidId()
  end
  self:CheckVisibility()
end
function SiegeWeaponMarker:CheckVisibility()
  UiElementBus.Event.SetIsEnabled(self.entityId, self.isEnabled)
  if self.isEnabled then
    local sameTeam = self.raidId:IsValid() and self.localPlayerRaidId:IsValid() and self.raidId == self.localPlayerRaidId
    local ammoVisible = self.maxAmmo > 0 and sameTeam
    UiElementBus.Event.SetIsEnabled(self.Properties.AmmoText, ammoVisible)
    local imagePath = ammoVisible and self.FRAME_WITH_AMMO or self.FRAME_NO_AMMO
    UiImageBus.Event.SetSpritePathname(self.Properties.HealthBarFrame, imagePath)
    if sameTeam and 0 < self.cooldownDuration then
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local isVisible = now >= self.cooldownEndTime
      if self.siegeWeaponType == eSiegeWeaponType_Horn or self.siegeWeaponType == eSiegeWeaponType_FireBarrel then
        local iconColor = isVisible and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_GRAY_50
        UiImageBus.Event.SetColor(self.Properties.TypeIcon, iconColor)
      end
      if now < self.cooldownEndTime and self.tickHandler == nil then
        self.tickHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
      else
        UiImageBus.Event.SetFillAmount(self.Properties.CooldownMeter, 0)
      end
    elseif self.tickHandler then
      DynamicBus.UITickBus.Disconnect(self.entityId, self)
      self.tickHandler = nil
    end
  end
end
function SiegeWeaponMarker:OnTick(deltaTime, timePoint)
  local now = timeHelpers:ServerNow()
  if self.cooldownDuration > 0 and now < self.cooldownEndTime then
    local timeRemainingSeconds = self.cooldownEndTime:Subtract(now):ToSecondsUnrounded()
    local percent = Clamp(timeRemainingSeconds / self.cooldownDuration, 0, 1)
    UiImageBus.Event.SetFillAmount(self.Properties.CooldownMeter, percent)
  else
    UiImageBus.Event.SetFillAmount(self.Properties.CooldownMeter, 0)
    UiImageBus.Event.SetColor(self.Properties.TypeIcon, self.UIStyle.COLOR_WHITE)
    if self.tickHandler then
      DynamicBus.UITickBus.Disconnect(self.entityId, self)
      self.tickHandler = nil
    end
  end
end
return SiegeWeaponMarker
