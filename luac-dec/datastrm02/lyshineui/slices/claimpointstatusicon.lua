local ClaimPointStatusIcon = {
  Properties = {
    Meter = {
      default = EntityId()
    },
    MeterBG = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    TargetTag = {
      default = EntityId()
    },
    Pulse1 = {
      default = EntityId()
    },
    Pulse2 = {
      default = EntityId()
    }
  },
  animationTime = 0.1,
  statusIconLockPath = "lyshineui/images/slices/claimpointstatusicon/claimpointcomboflag.dds",
  statusIconContestedPath = "lyshineui/images/slices/claimpointstatusicon/claimpointcomboattacked.dds",
  statusIconEmpty = "lyshineui/images/slices/claimpointstatusicon/claimpointcomboempty.dds",
  idIconKeepPath = "lyshineui/images/slices/claimpointstatusicon/claimpointcombofort.dds",
  idIconGatePath = "lyshineui/images/slices/claimpointstatusicon/claimpointcombogate.dds",
  defaultMeterFill = "lyshineui/images/slices/claimpointstatusicon/claimpointfill",
  nameIconBasePath = "lyshineui/images/slices/claimpointstatusicon/claimpointcombo",
  outpostRushUnclaimed = "unclaimed",
  outpostRushClaimedAlly = "claimedAlly",
  outpostRushClaimedEnemy = "claimedEnemy",
  outpostRushNameIconBasePath = "lyshineui/images/slices/claimpointstatusicon/orclaimpointcombo_",
  outpostRushMeterBasePath = "lyshineui/images/slices/claimpointstatusicon/orclaimpointfill_",
  currentStatusIcon = -1,
  currentProgress = 0,
  GAMEMODE_WAR_INVASION = 0,
  gameMode = 0
}
local SiegeMarkerData = RequireScript("LyShineUI.Markers.SiegeMarkerData")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ClaimPointStatusIcon)
local bitHelpers = RequireScript("LyShineUI._Common.BitwiseHelpers")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function ClaimPointStatusIcon:OnInit()
  BaseElement.OnInit(self)
  self.timelineIcon = self.ScriptedEntityTweener:TimelineCreate()
  self.timelineIcon:Add(self.Properties.Icon, 0.35, {
    imgColor = self.UIStyle.COLOR_WHITE
  })
  self.timelineIcon:Add(self.Properties.Icon, 0.05, {
    imgColor = self.UIStyle.COLOR_WHITE
  })
  self.timelineIcon:Add(self.Properties.Icon, 0.3, {
    imgColor = self.UIStyle.COLOR_GREY_60,
    onComplete = function()
      self.timelineIcon:Play()
    end
  })
  self:SetName("-")
  self:SetState(0)
  self.pulseScaleUp = self.ScriptedEntityTweener:CacheAnimation(1, {
    opacity = 1,
    scaleX = 2,
    scaleY = 2,
    ease = "QuadOut"
  })
end
function ClaimPointStatusIcon:SetMeterBGColor(color)
  UiImageBus.Event.SetColor(self.Properties.MeterBG, color)
end
function ClaimPointStatusIcon:SetMeterColor(color, iconColor)
  if color == nil then
    return
  end
  UiImageBus.Event.SetColor(self.Properties.Meter, color)
  if self.timelineIcon then
    self.ScriptedEntityTweener:TimelineDestroy(self.timelineIcon)
  end
  if iconColor == nil then
    iconColor = color
  end
  local lighterColor = MixColors(iconColor, self.UIStyle.COLOR_WHITE, 0.33)
  self.timelineIcon = self.ScriptedEntityTweener:TimelineCreate()
  self.timelineIcon:Add(self.Properties.Icon, 0.35, {
    imgColor = self.UIStyle.COLOR_WHITE
  })
  self.timelineIcon:Add(self.Properties.Icon, 0.35, {
    imgColor = self.UIStyle.COLOR_WHITE
  })
  self.timelineIcon:Add(self.Properties.Icon, 0.3, {
    imgColor = lighterColor,
    onComplete = function()
      self.timelineIcon:Play()
    end
  })
  self.timelineIcon:Add(self.Properties.Icon, 0.05, {
    imgColor = lighterColor,
    onComplete = function()
      self.timelineIcon:Play()
    end
  })
  UiImageBus.Event.SetColor(self.Properties.Pulse1, iconColor)
  UiImageBus.Event.SetColor(self.Properties.Pulse2, iconColor)
end
function ClaimPointStatusIcon:SetState(state)
  if self.state ~= state then
    if bitHelpers:TestFlag(state, eCapturePointStateFlag_Contested) and self.currentStatusIcon ~= SiegeMarkerData.ICON_CONTESTED then
      self.currentStatusIcon = SiegeMarkerData.ICON_CONTESTED
      UiElementBus.Event.SetIsEnabled(self.Properties.Meter, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.MeterBG, true)
    elseif bitHelpers:TestFlag(state, eCapturePointStateFlag_Locked) and self.currentStatusIcon ~= SiegeMarkerData.ICON_LOCKED then
      UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.statusIconLockPath)
      self.currentStatusIcon = SiegeMarkerData.ICON_LOCKED
      self:ClearAllTimelines()
      UiElementBus.Event.SetIsEnabled(self.Properties.Meter, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.MeterBG, false)
    else
      self:ClearAllTimelines()
    end
    self.state = state
  end
end
function ClaimPointStatusIcon:SetName(name, isLocalPlayerOwned, gameModeOverride)
  self.name = name
  local iconBasePath = self.nameIconBasePath
  local meterBasePath = self.defaultMeterFill
  local isInOutpostRush = gameModeOverride == GameModeCommon.GAMEMODE_OUTPOST_RUSH
  if not isInOutpostRush then
    local rootPlayerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    if rootPlayerId then
      isInOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(rootPlayerId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
    end
  end
  if isInOutpostRush then
    if isLocalPlayerOwned == nil then
      iconBasePath = self.outpostRushNameIconBasePath .. self.outpostRushUnclaimed
      meterBasePath = self.outpostRushMeterBasePath .. self.outpostRushUnclaimed
    elseif isLocalPlayerOwned then
      iconBasePath = self.outpostRushNameIconBasePath .. self.outpostRushClaimedAlly
      meterBasePath = self.outpostRushMeterBasePath .. self.outpostRushClaimedAlly
    else
      iconBasePath = self.outpostRushNameIconBasePath .. self.outpostRushClaimedEnemy
      meterBasePath = self.outpostRushMeterBasePath .. self.outpostRushClaimedEnemy
    end
  end
  local isLocked = self.state ~= nil and bitHelpers:TestFlag(self.state, eCapturePointStateFlag_Locked)
  if name ~= "-" and isLocked == false then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconBasePath .. name .. ".dds")
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Meter, meterBasePath .. ".dds")
  UiImageBus.Event.SetSpritePathname(self.Properties.MeterBG, meterBasePath .. ".dds")
  self.isGatePhase = false
end
function ClaimPointStatusIcon:GetName()
  return self.name
end
function ClaimPointStatusIcon:SetDisplayName(name)
  self.displayName = name
end
function ClaimPointStatusIcon:GetDisplayName()
  return self.displayName
end
function ClaimPointStatusIcon:SetProgress(progress)
  local isLocked = self.state ~= nil and bitHelpers:TestFlag(self.state, eCapturePointStateFlag_Locked)
  local isContested = self.state ~= nil and bitHelpers:TestFlag(self.state, eCapturePointStateFlag_Contested)
  local amount = isLocked and 1 or progress
  self.ScriptedEntityTweener:Play(self.Properties.Meter, self.animationTime, {imgFill = amount})
  if isContested and amount > self.currentProgress then
    if not self.isContestPulseVisible then
      self.isContestPulseVisible = true
      self:SetContestedPulseVisible(true)
      self.timelineIcon:Play()
    end
  elseif self.isContestPulseVisible then
    self.isContestPulseVisible = false
    self:SetContestedPulseVisible(false)
    self.timelineIcon:Stop()
    self.ScriptedEntityTweener:PlayC(self.Properties.Icon, 0.25, tweenerCommon.imgToWhite)
  end
  self.currentProgress = amount
end
function ClaimPointStatusIcon:ClearAllTimelines()
  self.timelineIcon:Stop()
  UiImageBus.Event.SetColor(self.Properties.Icon, self.UIStyle.COLOR_WHITE)
  self:SetContestedPulseVisible(false)
end
function ClaimPointStatusIcon:SetIsTargetTagged(isTargetTagged)
  UiElementBus.Event.SetIsEnabled(self.Properties.TargetTag, isTargetTagged)
end
function ClaimPointStatusIcon:SetIcon(id)
  if id == SiegeMarkerData.ICON_KEEP then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.idIconKeepPath)
  elseif id == SiegeMarkerData.ICON_GATE then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.idIconGatePath)
  end
  self.isGatePhase = true
end
function ClaimPointStatusIcon:SetCustomIcon(imagePath, hideMeter)
  if imagePath and LyShineScriptBindRequestBus.Broadcast.IsFileExists(imagePath) then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, imagePath)
  end
  if hideMeter then
    UiElementBus.Event.SetIsEnabled(self.Properties.Meter, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.MeterBG, false)
  end
end
function ClaimPointStatusIcon:SetIconColor(color)
  if color then
    UiImageBus.Event.SetColor(self.Properties.Icon, color)
  end
end
function ClaimPointStatusIcon:SetIconScale(scale)
  if scale then
    UiTransformBus.Event.SetScale(self.Properties.Icon, scale)
  end
end
function ClaimPointStatusIcon:Reset()
  UiElementBus.Event.SetIsEnabled(self.Properties.Meter, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.MeterBG, true)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.statusIconEmpty)
  self:SetIconColor(self.UIStyle.COLOR_WHITE)
  self:SetIconScale(Vector2(1, 1))
  self:SetName("-")
  self:SetState(0)
end
function ClaimPointStatusIcon:SetContestedPulseVisible(isVisible)
  local animDuration = 1
  if isVisible then
    self.ScriptedEntityTweener:PlayFromC(self.Properties.Pulse1, animDuration, {
      opacity = 0,
      scaleX = 1,
      scaleY = 1
    }, self.pulseScaleUp)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.Pulse2, animDuration, {
      opacity = 0,
      scaleX = 1,
      scaleY = 1
    }, self.pulseScaleUp, 0.4)
    self.ScriptedEntityTweener:PlayC(self.Properties.Pulse1, animDuration, tweenerCommon.fadeOutQuadOut, animDuration / 3)
    self.ScriptedEntityTweener:PlayC(self.Properties.Pulse2, animDuration, tweenerCommon.fadeOutQuadOut, animDuration / 3 + 0.4, function()
      self:SetContestedPulseVisible(true)
    end)
  else
    self.ScriptedEntityTweener:Stop(self.Properties.Pulse1)
    self.ScriptedEntityTweener:Stop(self.Properties.Pulse2)
    self.ScriptedEntityTweener:PlayC(self.Properties.Pulse1, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.Pulse2, 0.3, tweenerCommon.fadeOutQuadOut)
  end
end
function ClaimPointStatusIcon:OnShutdown()
  if self.warboardInGameBusHandler then
    DynamicBus.WarboardInGameBus.Disconnect(self.entityId, self)
    self.warboardInGameBusHandler = nil
  end
  if self.timelineIcon then
    self.ScriptedEntityTweener:TimelineDestroy(self.timelineIcon)
  end
end
return ClaimPointStatusIcon
