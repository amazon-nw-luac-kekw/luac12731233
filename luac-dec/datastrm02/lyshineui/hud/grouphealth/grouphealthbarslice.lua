local GroupHealthBarSlice = {
  Properties = {
    HealthBar = {
      default = EntityId()
    },
    HealthFill = {
      default = EntityId()
    },
    HealthBarPulse = {
      default = EntityId()
    },
    HealthBarPulseFrame = {
      default = EntityId()
    },
    NameContainer = {
      default = EntityId()
    },
    NameTextField = {
      default = EntityId()
    },
    MicStatusGraphic = {
      default = EntityId()
    },
    LocalPlayerIcon = {
      default = EntityId()
    },
    VoipSpeaker = {
      default = EntityId()
    },
    StreamingStatusBG = {
      default = EntityId()
    },
    HealingStatusBG = {
      default = EntityId()
    },
    PlayerIcon = {
      default = EntityId()
    },
    PartyIcon = {
      default = EntityId()
    },
    CriticalCover = {
      default = EntityId()
    },
    LargeDeathIcon = {
      default = EntityId()
    },
    SmallDeathIcon = {
      default = EntityId()
    },
    DisconnectedIcon = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    }
  },
  DataPathObserverHandlerPrefix = "OnObserverUpdate",
  offlineIconPath = "lyshineui/images/icons/misc/icon_offline.dds",
  BG_ALPHA = 0.7,
  CRITICAL_HEALTH_PERCENT = 35,
  HEALTHY_STATE = 1,
  CRITICAL_STATE = 2,
  DEATHS_DOOR_STATE = 3,
  DEAD_STATE = 4,
  cachedMemberData = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(GroupHealthBarSlice)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function GroupHealthBarSlice:OnInit()
  BaseElement.OnInit(self)
  self.UIStyle = RequireScript("LyShineUI._Common.UIStyle")
  self.dataLayer = dataLayer
  local nameStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
    fontSize = self.UIStyle.FONT_SIZE_BODY_NEW,
    fontColor = self.UIStyle.COLOR_WHITE,
    characterSpacing = 0,
    fontEffect = self.UIStyle.FONT_EFFECT_DROP_SHADOW
  }
  SetTextStyle(self.Properties.NameTextField, nameStyle)
  self.currentState = self.HEALTHY_STATE
  self.criticalTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.criticalTimeline:Add(self.Properties.CriticalCover, 0.4, {opacity = 0.55})
  self.criticalTimeline:Add(self.Properties.CriticalCover, 0.05, {opacity = 0.55})
  self.criticalTimeline:Add(self.Properties.CriticalCover, 0.35, {
    opacity = 0.1,
    onComplete = function()
      self.criticalTimeline:Play()
    end
  })
  self.criticalHealthTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.criticalHealthTimeline:Add(self.Properties.HealthBarPulse, 0.4, {opacity = 0.9})
  self.criticalHealthTimeline:Add(self.Properties.HealthBarPulse, 0.05, {opacity = 0.9})
  self.criticalHealthTimeline:Add(self.Properties.HealthBarPulse, 0.35, {
    opacity = 0.1,
    onComplete = function()
      self.criticalHealthTimeline:Play()
    end
  })
  self.criticalHealthFrameTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.criticalHealthFrameTimeline:Add(self.Properties.HealthBarPulseFrame, 0.4, {opacity = 0.7})
  self.criticalHealthFrameTimeline:Add(self.Properties.HealthBarPulseFrame, 0.05, {opacity = 0.7})
  self.criticalHealthFrameTimeline:Add(self.Properties.HealthBarPulseFrame, 0.35, {
    opacity = 0.1,
    onComplete = function()
      self.criticalHealthFrameTimeline:Play()
    end
  })
  self.largeDeathTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.largeDeathTimeline:Add(self.Properties.LargeDeathIcon, 0.4, {opacity = 0.65})
  self.largeDeathTimeline:Add(self.Properties.LargeDeathIcon, 0.05, {opacity = 0.65})
  self.largeDeathTimeline:Add(self.Properties.LargeDeathIcon, 0.35, {
    opacity = 0.1,
    onComplete = function()
      self.largeDeathTimeline:Play()
    end
  })
  self.smallDeathTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.smallDeathTimeline:Add(self.Properties.SmallDeathIcon, 0.4, {opacity = 0.65})
  self.smallDeathTimeline:Add(self.Properties.SmallDeathIcon, 0.05, {opacity = 0.65})
  self.smallDeathTimeline:Add(self.Properties.SmallDeathIcon, 0.35, {
    opacity = 0.1,
    onComplete = function()
      self.smallDeathTimeline:Play()
    end
  })
  self.parentEntity = UiElementBus.Event.GetParent(self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", function(self, data)
    if data then
      self.localPlayerName = data
      self:UpdateIsLocalPlayer()
    end
  end)
  UiImageBus.Event.SetColor(self.Properties.HealthFill, self.UIStyle.COLOR_HEALTHBAR_GROUP)
  UiImageBus.Event.SetColor(self.Properties.StreamingStatusBG, self.UIStyle.COLOR_TWITCH_PURPLE)
  UiImageBus.Event.SetAlpha(self.Properties.StreamingStatusBG, self.BG_ALPHA)
  UiElementBus.Event.SetIsEnabled(self.Properties.StreamingStatusBG, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.VoipSpeaker, false)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HealingTarget.Name", function(self, name)
    UiElementBus.Event.SetIsEnabled(self.Properties.HealingStatusBG, name and name == self.cachedMemberData.characterName)
  end)
  self.PlayerIcon:SetRefreshDataOnFlyout(true)
end
function GroupHealthBarSlice:OnShutdown()
  self.ScriptedEntityTweener:TimelineDestroy(self.criticalTimeline)
  self.ScriptedEntityTweener:TimelineDestroy(self.criticalHealthTimeline)
  self.ScriptedEntityTweener:TimelineDestroy(self.criticalHealthFrameTimeline)
  self.ScriptedEntityTweener:TimelineDestroy(self.largeDeathTimeline)
  self.ScriptedEntityTweener:TimelineDestroy(self.smallDeathTimeline)
end
function GroupHealthBarSlice:ShowHealthBar(isEnabled)
  if self.isEnabled == isEnabled then
    return
  end
  local wasEnabled = UiElementBus.Event.IsEnabled(self.HealthBar)
  UiElementBus.Event.SetIsEnabled(self.Properties.NameTextField, isEnabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.VoipSpeaker, isEnabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlayerIcon, not isEnabled)
  if isEnabled then
    self.ScriptedEntityTweener:Set(self.Properties.PartyIcon, {
      x = 25,
      y = -19,
      scaleX = 1,
      scaleY = 1
    })
    self.ScriptedEntityTweener:Play(self.Properties.StreamingStatusBG, 0.15, {opacity = 0, ease = "QuadOut"})
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, 36)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.HealthBar, 9)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.HealthFill, 143)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.HealthFill, 7)
    self.ScriptedEntityTweener:Set(self.Properties.HealthBar, {
      x = 14,
      y = 20,
      w = 145
    })
    self.ScriptedEntityTweener:Set(self.Properties.HealthFill, {x = 0, y = 0})
    self.ScriptedEntityTweener:Set(self.Properties.DisconnectedIcon, {y = -19})
    UiTransformBus.Event.SetScale(self.entityId, Vector2(1, 1))
    if wasEnabled == false then
      self.ScriptedEntityTweener:Play(self.Properties.NameContainer, 0.15, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.HealthBar, 0.15, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    end
  else
    self.ScriptedEntityTweener:Set(self.Properties.PartyIcon, {
      x = 45,
      y = 16,
      scaleX = 1,
      scaleY = 1
    })
    self.ScriptedEntityTweener:Play(self.Properties.StreamingStatusBG, 0.15, {opacity = 1, ease = "QuadOut"})
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.HealthBar, 6)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.HealthFill, 50)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.HealthFill, 4)
    self.ScriptedEntityTweener:Set(self.Properties.HealthBar, {
      x = 1,
      y = 52,
      w = 54
    })
    self.ScriptedEntityTweener:Set(self.Properties.HealthFill, {x = 2, y = 1})
    self.ScriptedEntityTweener:Set(self.Properties.DisconnectedIcon, {y = -16})
  end
  self.isEnabled = isEnabled
  self:UpdateCriticalState(true)
end
function GroupHealthBarSlice:FullGroupAdjustment(isFullGroup)
  if isFullGroup then
    UiTransformBus.Event.SetScale(self.entityId, Vector2(0.9, 0.9))
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, 50)
  else
    UiTransformBus.Event.SetScale(self.entityId, Vector2(1, 1))
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, 57)
  end
end
function GroupHealthBarSlice:UpdateData(memberData)
  self.cachedMemberData = memberData
  self.groupMemberColor = self.UIStyle.COLOR_GROUP_MEMBERS[self.cachedMemberData.playerIndex]
  self.groupMemberIcon = self.UIStyle.ICONS_GROUP_MEMBERS[self.cachedMemberData.playerIndex]
  UiImageBus.Event.SetColor(self.Properties.PartyIcon, self.groupMemberColor)
  UiImageBus.Event.SetSpritePathname(self.Properties.PartyIcon, self.groupMemberIcon)
  self:UpdatePortrait()
  self:UpdateIsLocalPlayer()
end
function GroupHealthBarSlice:UpdateName(data)
  self.cachedMemberData.characterName = data
  UiTextBus.Event.SetText(self.Properties.NameTextField, self.cachedMemberData.characterName)
  self.VoipSpeaker:SetPlayer(self.cachedMemberData.characterName, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.VoipSpeaker, true)
  self:UpdateIsLocalPlayer()
end
function GroupHealthBarSlice:UpdateFaction(newFaction)
  if self.PlayerIcon then
    self.PlayerIcon:SetPlayerFactionOverride(newFaction)
  end
end
function GroupHealthBarSlice:UpdateLevel(data)
  if self.PlayerIcon then
    self.PlayerIcon:SetPlayerLevelOverride(data)
  end
end
function GroupHealthBarSlice:UpdateHealth(data)
  self.cachedMemberData.playerHealth = data
  if self.cachedMemberData.playerHealth then
    self:SetClampedScale(self.Properties.HealthFill, self.cachedMemberData.playerHealth / 100)
  end
  self:UpdateCriticalState()
end
function GroupHealthBarSlice:UpdateMana(data)
  self.cachedMemberData.playerMana = data
end
function GroupHealthBarSlice:UpdateDeathsDoor(data)
  self.cachedMemberData.isDeathsDoor = data
  self:UpdateCriticalState()
end
function GroupHealthBarSlice:UpdatePlayerIcon(data)
  if data then
    self.cachedMemberData.playerIcon = data:Clone()
    self:UpdatePortrait()
  end
end
function GroupHealthBarSlice:StreamingStatus(data)
  self.cachedMemberData.isStreaming = data
  UiElementBus.Event.SetIsEnabled(self.StreamingStatusBG, data)
end
function GroupHealthBarSlice:EnableCriticalElements(enableCover, enableDeath, animatePulse)
  UiElementBus.Event.SetIsEnabled(self.Properties.CriticalCover, enableCover)
  UiElementBus.Event.SetIsEnabled(self.Properties.HealthBarPulse, enableCover)
  UiElementBus.Event.SetIsEnabled(self.Properties.HealthBarPulseFrame, enableCover)
  local showLargeDeathIcon = not self.isEnabled and enableDeath
  local showSmallDeathIcon = self.isEnabled and enableDeath
  UiElementBus.Event.SetIsEnabled(self.Properties.LargeDeathIcon, showLargeDeathIcon)
  UiElementBus.Event.SetIsEnabled(self.Properties.SmallDeathIcon, showSmallDeathIcon)
  if animatePulse then
    self.criticalTimeline:Play()
    self.criticalHealthTimeline:Play()
    self.criticalHealthFrameTimeline:Play()
    if showLargeDeathIcon then
      self.largeDeathTimeline:Play()
      self.smallDeathTimeline:Stop()
    elseif showSmallDeathIcon then
      self.smallDeathTimeline:Play()
      self.largeDeathTimeline:Stop()
    end
  else
    self.criticalTimeline:Stop()
    self.criticalHealthTimeline:Stop()
    self.criticalHealthFrameTimeline:Stop()
    self.largeDeathTimeline:Stop()
    self.smallDeathTimeline:Stop()
  end
end
function GroupHealthBarSlice:UpdateCriticalState(forceUpdate)
  if self.cachedMemberData.playerHealth == nil then
    return
  end
  local hasNoHealth = self.cachedMemberData.playerHealth <= 0
  if self.cachedMemberData.isDeathsDoor and hasNoHealth then
    if forceUpdate or self.currentState ~= self.DEATHS_DOOR_STATE then
      self.ScriptedEntityTweener:Set(self.Properties.CriticalCover, {
        imgColor = self.UIStyle.COLOR_BLACK
      })
      self:EnableCriticalElements(true, true, true)
      self.currentState = self.DEATHS_DOOR_STATE
    end
  elseif hasNoHealth then
    if forceUpdate or self.currentState ~= self.DEAD_STATE then
      self:EnableCriticalElements(true, true, false)
      self.ScriptedEntityTweener:Set(self.Properties.CriticalCover, {
        imgColor = self.UIStyle.COLOR_BLACK,
        opacity = 0.75
      })
      self.ScriptedEntityTweener:Set(self.Properties.LargeDeathIcon, {opacity = 1})
      self.ScriptedEntityTweener:Set(self.Properties.SmallDeathIcon, {opacity = 1})
      self.currentState = self.DEAD_STATE
    end
  elseif self.cachedMemberData.playerHealth < self.CRITICAL_HEALTH_PERCENT then
    if forceUpdate or self.currentState ~= self.CRITICAL_STATE then
      self.ScriptedEntityTweener:Set(self.Properties.CriticalCover, {
        imgColor = self.UIStyle.COLOR_RED_DARK
      })
      self:EnableCriticalElements(true, false, true)
      self.currentState = self.CRITICAL_STATE
    end
  elseif forceUpdate or self.currentState ~= self.HEALTHY_STATE then
    self:EnableCriticalElements(false, false, false)
    self.currentState = self.HEALTHY_STATE
  end
end
function GroupHealthBarSlice:UpdateMicStatus()
end
function GroupHealthBarSlice:UpdatePortrait()
  self.PlayerIcon:SetPlayerIcon(self.cachedMemberData.playerIcon)
  local simpleId = SimplePlayerIdentification()
  simpleId.characterIdString = self.cachedMemberData.characterId
  simpleId.playerName = self.cachedMemberData.characterName
  self.PlayerIcon:SetPlayerId(simpleId)
end
function GroupHealthBarSlice:UpdateIsLocalPlayer()
  self.isLocalPlayer = self.cachedMemberData.characterName == self.localPlayerName
  if self.cachedMemberData.isLocalPlayer ~= self.isLocalPlayer then
    UiElementBus.Event.SetIsEnabled(self.Properties.LocalPlayerIcon, self.isLocalPlayer)
  end
  self.cachedMemberData.isLocalPlayer = self.isLocalPlayer
end
function GroupHealthBarSlice:UpdateOnlineStatus(isOnline)
  local nameTextPosX = isOnline and 21 or 39
  local nameColor = isOnline and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_RED_MEDIUM
  self.ScriptedEntityTweener:Set(self.Properties.NameTextField, {x = nameTextPosX})
  UiTextBus.Event.SetColor(self.Properties.NameTextField, nameColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.DisconnectedIcon, not isOnline)
end
function GroupHealthBarSlice:SetClampedScale(entityId, percent)
  if percent then
    percent = self:Clamp(percent, 0, 1)
    local currentScale = UiTransformBus.Event.GetScale(entityId)
    if currentScale then
      currentScale.x = percent
      UiTransformBus.Event.SetScale(entityId, currentScale)
    end
  end
end
function GroupHealthBarSlice:Clamp(valueToClamp, min, max)
  local returnVal = valueToClamp
  returnVal = math.min(returnVal, max)
  returnVal = math.max(returnVal, min)
  return returnVal
end
return GroupHealthBarSlice
