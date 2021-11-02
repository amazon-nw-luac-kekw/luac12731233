local profiler = RequireScript("LyShineUI._Common.Profiler")
local GroupMarker = {
  Properties = {
    Title = {
      default = EntityId()
    },
    PartyIcon = {
      default = EntityId()
    },
    OffscreenPartyIcon = {
      default = EntityId()
    },
    Distance = {
      default = EntityId()
    },
    Player = {
      ArrowIndicator = {
        default = EntityId()
      }
    },
    ScreenStates = {
      OnScreen = {
        default = EntityId()
      },
      OffScreen = {
        default = EntityId()
      }
    }
  },
  isOnScreen = true,
  shouldEnableMarker = false,
  isInLocalPlayerDungeon = true,
  gameModeParticipantComponentReady = false,
  healthBarFillCannotDamagePath = "lyshineui/images/markers/marker_healthbarcannotdamage.png",
  healthBarBgCannotDamagePath = "lyshineui/images/markers/marker_healthbarBgcannotdamage.png",
  screenPosVec2 = Vector2(0)
}
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local uiStyle = RequireScript("LyShineUI._Common.UIStyle")
local markerTypeData = RequireScript("LyShineUI.Markers.MarkerData")
function GroupMarker:OnActivate()
  self.dataLayer = dataLayer
  self.registrar = registrar
  self.tweener = tweener
  self.UIStyle = uiStyle
  self.distance = -1
  self.registrar:RegisterEntity(self)
  self.tweener:OnActivate()
  self.states = {
    onScreen = {
      currentState = 0,
      stateNames = {Screen_Enter = 1, Screen_Exit = 2}
    },
    deadStates = {
      currentState = 0,
      stateNames = {
        Alive = 1,
        Dead = 2,
        InDeathsDoor = 3
      }
    },
    deathsDoor = {
      currentState = 0,
      stateNames = {EnterDeathsDoor = 1, ExitDeathsDoor = 2}
    }
  }
end
function GroupMarker:OnDeactivate()
  if self.registrar then
    self.registrar:UnregisterEntity(self)
  end
  self.tweener:OnDeactivate()
  if self.canvasSizeNotificationHandler then
    self.canvasSizeNotificationHandler:Disconnect()
    self.markerNotificationHandler = nil
  end
  if self.groupDataHandler then
    DynamicBus.GroupDataNotification.Disconnect(self.entityId, self)
    self.groupDataHandler = nil
  end
  if self.tickHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickHandler = nil
  end
  dataLayer:UnregisterObservers(self)
  self.isInLocalPlayerDungeon = true
end
function GroupMarker:RegisterDatapaths(index)
  self.index = index
  self.markerClass = UiMarkerBus.Event.GetMarker(self.entityId)
  self.markerClass:SetMarkerType("RootPlayer")
  self.markerClass:SetKeepOnScreen(true)
  self.originalTypeInfo = markerTypeData:GetTypeInfo("RootPlayer")
  self.typeInfo = ShallowCopy(self.originalTypeInfo)
  self.typeInfo.nameTextColor = self.UIStyle.COLOR_NAMEPLATE_GROUP
  UiTextBus.Event.SetColor(self.Properties.Title, self.typeInfo.nameTextColor)
  local groupMemberColor = self.UIStyle.COLOR_GROUP_MEMBERS[index]
  local groupMemberIcon = self.UIStyle.ICONS_GROUP_MEMBERS[index]
  UiImageBus.Event.SetSpritePathname(self.Properties.PartyIcon, groupMemberIcon)
  UiImageBus.Event.SetColor(self.Properties.PartyIcon, groupMemberColor)
  UiImageBus.Event.SetSpritePathname(self.Properties.OffscreenPartyIcon, groupMemberIcon)
  UiImageBus.Event.SetColor(self.Properties.OffscreenPartyIcon, groupMemberColor)
  UiImageBus.Event.SetColor(self.Properties.Player.ArrowIndicator, groupMemberColor)
  if not self.groupDataHandler then
    self.groupDataHandler = DynamicBus.GroupDataNotification.Connect(self.entityId, self)
  end
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Accessibility.TextSizeOption", function(self, textSize)
    self.accessibilityScale = 1
    if textSize == eAccessibilityTextOptions_Bigger then
      self.accessibilityScale = 1.5
    end
  end)
  local basePath = "Hud.LocalPlayer.Group.Members." .. tostring(index) .. "."
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "CharacterId", function(self, characterIdString)
    if not characterIdString then
      return
    end
    self.isPlayer = true
    self.characterIdString = characterIdString
    self.lastHealth = 0
    self.lastDeathsDoor = nil
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "CharacterName", function(self, characterName)
    if not characterName then
      return
    end
    self.characterName = characterName
    UiTextBus.Event.SetText(self.Properties.Title, characterName)
    UiElementBus.Event.SetIsEnabled(self.Properties.Title, true)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "IsLocalPlayer", function(self, isLocalPlayer)
    if isLocalPlayer == nil then
      return
    end
    self.isLocalPlayer = isLocalPlayer
    self:UpdateEnabled()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "WorldPosition", function(self, worldPosition)
    if not worldPosition then
      return
    end
    self.lastWorldPos = worldPosition
    self:OnCrySystemPostViewSystemUpdate()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.GameModeParticipantBus.IsReady", function(self, isReady)
    self.gameModeParticipantComponentReady = isReady
    if isReady then
      local gameModeIndex = self.dataLayer:GetDataFromNode(basePath .. "GameModeIndex")
      self:OnMemberGameModeIndexChanged(gameModeIndex)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "GameModeIndex", function(self, gameModeIndex)
    if not gameModeIndex then
      return
    end
    self:OnMemberGameModeIndexChanged(gameModeIndex)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "IsMarkerShowing", function(self, isMarkerShowing)
    self.isFullMarkerShowing = isMarkerShowing
    self:UpdateEnabled()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_autoPingingEnabled", function(self, isEnabled)
    self.autoPingingEnabled = isEnabled
  end)
  local pingIndexToSourceType = {
    ePingSource_Group1,
    ePingSource_Group2,
    ePingSource_Group3,
    ePingSource_Group4,
    ePingSource_Group5
  }
  local criticalHealthPercent = 15
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "HealthPct", function(self, health)
    if not self.isLocalPlayer and health then
      if self.lastHealth and self.lastHealth > criticalHealthPercent and health <= criticalHealthPercent then
        if self.autoPingingEnabled and self.isInLocalPlayerDungeon then
          local isPingMuted = GroupsRequestBus.Broadcast.GetIsPingMuted(self.characterIdString)
          if not isPingMuted then
            PingNotificationBus.Broadcast.OnPingShown(self.lastWorldPos, pingIndexToSourceType[index], ePingType_NeedHealing, false, self.characterName)
          end
        end
      elseif self.lastHealth and self.lastHealth <= criticalHealthPercent and health > criticalHealthPercent then
        PingNotificationBus.Broadcast.OnPingCancelled(pingIndexToSourceType[index])
      end
      self.lastHealth = health
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, basePath .. "IsDeathsDoor", function(self, isInDeathsDoor)
    if not self.isLocalPlayer and isInDeathsDoor ~= nil then
      if self.lastDeathsDoor == false and isInDeathsDoor then
        if self.autoPingingEnabled and self.isInLocalPlayerDungeon then
          local isPingMuted = GroupsRequestBus.Broadcast.GetIsPingMuted(self.characterIdString)
          if not isPingMuted then
            PingNotificationBus.Broadcast.OnPingShown(self.lastWorldPos, pingIndexToSourceType[index], ePingType_NeedRevive, false, self.characterName)
          end
        end
      elseif self.lastDeathsDoor and isInDeathsDoor == false then
        PingNotificationBus.Broadcast.OnPingCancelled(pingIndexToSourceType[index])
      end
      self.lastDeathsDoor = isInDeathsDoor
    end
  end)
  local memberAdded = DynamicBus.SocialPaneBus.Broadcast.IsGroupMemberAdded(self.index)
  if memberAdded then
    self:OnMemberAdded(self.index)
  end
end
function GroupMarker:OnMemberAdded(addedIndex)
  if self.index == addedIndex then
    self.shouldEnableMarker = true
    self:UpdateEnabled()
  end
end
function GroupMarker:OnMemberRemoved(removedIndex)
  if self.index == removedIndex then
    self.shouldEnableMarker = false
    self:UpdateEnabled()
  end
end
function GroupMarker:OnMemberGameModeIndexChanged(gameModeIndex)
  if not gameModeIndex or self.isLocalPlayer or not self.gameModeParticipantComponentReady then
    return
  end
  local localPlayerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local localPlayerGameModeIndex = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeIndex(localPlayerRootEntityId)
  self.isInLocalPlayerDungeon = localPlayerGameModeIndex == gameModeIndex
  self:UpdateEnabled()
end
function GroupMarker:UpdateEnabled()
  local isEnabled = not self.isLocalPlayer and self.shouldEnableMarker and not self.isFullMarkerShowing and self.isInLocalPlayerDungeon
  UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
  self.isMarkerEnabled = isEnabled
  if isEnabled then
    self.tickHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
  elseif self.tickHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickHandler = nil
  end
end
function GroupMarker:IsInState(stateGroup, stateName)
  return stateGroup.currentState == stateGroup.stateNames[stateName]
end
function GroupMarker:GetStateName(stateData, stateIndex)
  for stateName, index in pairs(stateData.stateNames) do
    if stateIndex == index then
      return stateName
    end
  end
end
function GroupMarker:SetState(stateData, stateIndex, forceState)
  local currentState = stateData.currentState
  if self.originalTypeInfo.States and (currentState ~= stateIndex or forceState) then
    stateData.currentState = stateIndex
    local stateName = self:GetStateName(stateData, stateIndex)
    local stateInfo = self.originalTypeInfo.States[stateName]
    if not stateInfo then
      return
    end
    local lastFadeDistance = self.typeInfo.fadeDistance
    Merge(self.typeInfo, stateInfo, false, true, true)
    if stateInfo.callbackFunction then
      stateInfo.callbackFunction(self)
    end
  end
end
function GroupMarker:RestoreCurrentState(stateData)
  self:SetState(stateData, stateData.currentState, true)
end
function GroupMarker:UpdateOnScreenState()
  local onScreenState = self.states.onScreen
  self:SetState(onScreenState, self.isOnScreen and onScreenState.stateNames.Screen_Enter or onScreenState.stateNames.Screen_Exit)
end
function GroupMarker:OnDistanceChanged(distance)
  local shouldShow = self.distance > self.typeInfo.fadeDistance or not self.isOnScreen
  if self.distance == distance and shouldShow == self.shouldShowOnDistance then
    return
  end
  self.distance = distance
  if shouldShow ~= self.shouldShowOnDistance then
    self.shouldShowOnDistance = shouldShow
    UiFaderBus.Event.SetFadeValue(self.entityId, self.shouldShowOnDistance and 1 or 0)
  end
  if self.shouldShowOnDistance then
    local distanceText = DistanceToText(distance)
    UiTextBus.Event.SetText(self.Properties.Distance, distanceText)
  end
end
function GroupMarker:OnCrySystemPostViewSystemUpdate()
  if self.lastWorldPos then
    self.isOnScreen = self.markerClass:OnWorldPositionChanged(self.lastWorldPos)
    self:UpdateOnScreenState()
    local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
    if playerPosition then
      self:OnDistanceChanged(self.lastWorldPos:GetDistance(playerPosition))
    end
  end
end
return GroupMarker
