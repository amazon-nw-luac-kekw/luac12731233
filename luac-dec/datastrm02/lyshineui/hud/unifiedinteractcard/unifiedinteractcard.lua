local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local UnifiedInteractCard = {
  Properties = {
    InteractNameElement = {
      default = EntityId()
    },
    TitleBackground = {
      default = EntityId()
    },
    OwnershipElement = {
      default = EntityId()
    },
    OwnershipNameText = {
      default = EntityId()
    },
    SecurityLevelNameText = {
      default = EntityId()
    },
    InteractOptionsElement = {
      default = EntityId()
    },
    PermissionDeniedElement = {
      default = EntityId()
    },
    WarMessageElement = {
      default = EntityId()
    },
    WarIcon = {
      default = EntityId()
    },
    Circle = {
      default = EntityId()
    },
    CircleBG = {
      default = EntityId()
    },
    CircleFlash = {
      default = EntityId()
    },
    CircleProgress = {
      default = EntityId()
    },
    CircleProgressTail = {
      default = EntityId()
    },
    TimerText = {
      default = EntityId()
    },
    IsGatherable = {default = false},
    Options = {
      default = EntityId()
    },
    TitleFrame = {
      default = EntityId()
    },
    IconX = {
      default = EntityId()
    },
    RespawnIconContainer = {
      default = EntityId()
    },
    RespawnIcon = {
      default = EntityId()
    },
    RespawnIconFill = {
      default = EntityId()
    },
    RespawnIconFillBg = {
      default = EntityId()
    },
    RespawnTimerText = {
      default = EntityId()
    },
    RespawnTimerLabel = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    }
  },
  boundOwnershipEntityId = nil,
  playerHasPermission = false,
  playerMeetsLevel = false,
  isAtWar = false,
  isDead = false,
  guildWarIconPath = "LyShineUI\\Images\\markers\\marker_squareBig.png",
  ownershipNameTextInitPosY = 40,
  ownershipNameTextOutpostRushPosY = 80,
  interactNameElementTextInitPosY = 4,
  interactNameElementTextOutpostRushPosY = -15
}
local profiler = RequireScript("LyShineUI._Common.Profiler")
local InteractCommon = require("LyShineUI.HUD.UnifiedInteractCard.InteractCommon")
local RESPAWN_PRIVATE_POINT_PNG = "LyShineUI/Images/Map/Icon/respawnPointCentered.png"
local RESPAWN_GUILD_POINT_PNG = "LyShineUI/Images/Map/Icon/respawnGuildPoint.png"
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(UnifiedInteractCard)
function UnifiedInteractCard:OnInit()
  BaseElement.OnInit(self)
  self.timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
  self.positionOffset = Vector2(0, 0)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.canvasSize = UiCanvasBus.Event.GetCanvasSize(self.canvasId)
  self.widthOffset = UiTransform2dBus.Event.GetLocalWidth(self.entityId) / 2
  self.heightOffset = UiTransform2dBus.Event.GetLocalHeight(self.entityId) / 2
  self.originalCirclePath = UiImageBus.Event.GetSpritePathname(self.Properties.Circle)
  self.originalOwnershipNameColor = UiTextBus.Event.GetColor(self.Properties.OwnershipNameText)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CircleFlash, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CircleProgress, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CircleProgressTail, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.TimerText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RespawnIconContainer, false)
  if self.Properties.RespawnIcon:IsValid() then
    self.RespawnIcon:SetIcon("LyShineUI/Images/Map/Icon/respawnPoint.png", Color(1, 1, 1))
  end
  self.FONT_STYLE_RESPAWN_TIMER = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = self.UIStyle.FONT_SIZE_NAME,
    fontColor = self.UIStyle.COLOR_RED
  }
  SetTextStyle(self.Properties.RespawnTimerText, self.FONT_STYLE_RESPAWN_TIMER)
  self.FONT_STYLE_RESPAWN_LABEL = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 20,
    fontColor = self.UIStyle.COLOR_GRAY_90
  }
  SetTextStyle(self.Properties.RespawnTimerLabel, self.FONT_STYLE_RESPAWN_LABEL)
  self.boundOwnershipEntityId = EntityId()
  self.playerHasPermission = false
  self.playerMeetsLevel = false
  UiElementBus.Event.SetIsEnabled(self.Properties.PermissionDeniedElement, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarMessageElement, false)
  self:BusConnect(UiCanvasSizeNotificationBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableNewGatherTimer", function(self, enableNewGatherTimer)
    self.enableNewGatherTimer = enableNewGatherTimer
  end)
  if self.IsGatherable then
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GatheringEntityId", function(self, gatheringEntityId)
      if self.gatheringEntityId then
        self:BusDisconnect(UiGatheringComponentNotificationsBus, self.gatheringEntityId)
      end
      if gatheringEntityId then
        self.gatheringEntityId = gatheringEntityId
        self:BusConnect(UiGatheringComponentNotificationsBus, self.gatheringEntityId)
      end
    end)
    self.ScriptedEntityTweener:Set(self.Properties.Circle, {
      scaleX = 0,
      scaleY = 0,
      ease = "QuadOut"
    })
  end
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Accessibility.TextSizeOption", function(self, textSize)
    local accessibilityScale = 1
    if textSize == eAccessibilityTextOptions_Bigger then
      accessibilityScale = 1.5
    end
    UiTransformBus.Event.SetScale(self.entityId, Vector2(accessibilityScale))
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    self.isDead = isDead
    if self.isDead then
      self:SetIsEnabled(false)
    end
  end)
  self.gatheringImpactTypes = {Chopping = 3, Mining = 2.08}
  UiImageBus.Event.SetFillClockwise(self.RespawnIconFill, false)
end
function UnifiedInteractCard:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  if self.GatherableNotificationBusId then
    self:BusDisconnect(self.GatherableNotificationBusId)
    self.GatherableNotificationBusId = nil
  end
end
function UnifiedInteractCard:OnTick(deltaTime, timePoint)
  if self.respawnTimeRemaining then
    self.respawnTimeRemaining = self.respawnTimeRemaining - deltaTime
    self:UpdateRespawnTimer()
    if self.respawnTimeRemaining <= 0 then
      self:EnableRespawnTimer(false)
    end
  end
  if self.tickPosition then
    local worldPosition = TransformBus.Event.GetWorldTranslation(self.interactableEntityId)
    self:SetScreenPosition(LyShineManagerBus.Broadcast.ProjectToScreen(worldPosition, false, false))
  end
end
function UnifiedInteractCard:StartTick()
  if not self.tickHandler then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function UnifiedInteractCard:StopTick()
  if not self.tickHandler then
    return
  end
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function UnifiedInteractCard:UpdateRespawnTimer()
  if self.respawnDuration and self.respawnDuration > 0 and self.respawnTimeRemaining and 0 < self.respawnTimeRemaining then
    local oldFillAmount = UiImageBus.Event.GetFillAmount(self.RespawnIconFill)
    local newFillAmount = (self.respawnDuration - (self.respawnDuration - math.max(0, self.respawnTimeRemaining))) / self.respawnDuration
    if oldFillAmount ~= newFillAmount then
      UiImageBus.Event.SetFillAmount(self.RespawnIconFill, newFillAmount)
    end
    local timerText = self.timeHelpers:ConvertToShorthandString(self.respawnTimeRemaining)
    if self.respawnTimerText ~= timerText then
      self.respawnTimerText = timerText
      UiTextBus.Event.SetTextWithFlags(self.RespawnTimerText, timerText, eUiTextSet_SetLocalized)
    end
  end
end
function UnifiedInteractCard:EnableRespawnTimer(enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.RespawnIconFill, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.RespawnIconFillBg, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.RespawnTimerText, enable)
  UiElementBus.Event.SetIsEnabled(self.Properties.RespawnTimerLabel, enable)
  if enable then
    self:StartTick()
    self:UpdateRespawnTimer()
  end
end
function UnifiedInteractCard:SetIsEnabled(isEnabled)
  if isEnabled then
    UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {opacity = 0}, {opacity = 1})
    if self.IsGatherable then
      self.ScriptedEntityTweener:Play(self.Properties.Circle, 0.25, {
        scaleX = 1,
        scaleY = 1,
        ease = "QuadOut"
      })
      UiFaderBus.Event.SetFadeValue(self.Properties.Options, 1)
    else
      if self.ownershipGuildId then
        self.hasGuildWarObservers = true
        self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", self.UpdateGuildWarState)
        self:UpdateGuildWarState()
      else
        self:UpdateWarAndPermissionsMessage()
      end
      self.ScriptedEntityTweener:Play(self.Properties.Circle, 0.15, {scaleX = 0, scaleY = 0}, {
        scaleX = 1,
        scaleY = 1,
        ease = "QuadOut"
      })
    end
  else
    self.ScriptedEntityTweener:Play(self.entityId, 0.3, {
      opacity = 0,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
        self:OnHidden()
      end
    })
    if self.IsGatherable then
      self.ScriptedEntityTweener:Play(self.Properties.Circle, 0.2, {scaleX = 0, scaleY = 0})
    else
      self.ScriptedEntityTweener:Play(self.Properties.Circle, 0.2, {scaleX = 1, scaleY = 1}, {scaleX = 0, scaleY = 0})
    end
  end
end
function UnifiedInteractCard:UpdateGuildWarState()
  local isAtWar
  if not self.ownershipGuildId then
    isAtWar = false
  else
    isAtWar = IsAtWarWithGuild(self.ownershipGuildId)
  end
  if isAtWar ~= self.isAtWar then
    self.isAtWar = isAtWar
    UiImageBus.Event.SetSpritePathname(self.Properties.Circle, self.isAtWar and self.guildWarIconPath or self.originalCirclePath)
    UiElementBus.Event.SetIsEnabled(self.Properties.CircleBG, not self.isAtWar)
    UiElementBus.Event.SetIsEnabled(self.Properties.WarIcon, self.isAtWar)
    local displayText
    if self.isAtWar then
      local warColor = dominionCommon:GetWarPhaseColor(dominionCommon:GetWarDetailsFromGuildId(self.ownershipGuildId):GetWarPhase())
      UiTextBus.Event.SetColor(self.Properties.OwnershipNameText, warColor)
      UiImageBus.Event.SetColor(self.Properties.Circle, warColor)
      UiImageBus.Event.SetColor(self.Properties.WarIcon, warColor)
      displayText = "@ui_atwar"
    else
      UiImageBus.Event.SetColor(self.Properties.Circle, self.UIStyle.COLOR_WHITE)
      if not self.playerMeetsLevel then
        local playerRank = GuildsComponentBus.Broadcast.GetPlayerRankName()
        displayText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_guildrank_no_permissions", playerRank)
      else
        displayText = "@ui_nopermission"
      end
      UiTextBus.Event.SetColor(self.Properties.OwnershipNameText, self.originalOwnershipNameColor)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.PermissionDeniedElement, displayText, eUiTextSet_SetLocalized)
  end
  self:UpdateWarAndPermissionsMessage(self.isAtWar)
end
function UnifiedInteractCard:UpdateWarAndPermissionsMessage(isAtWar)
  local showWarMessage = not self.playerHasPermission and not isAtWar and self.showTerritoryInfo
  UiElementBus.Event.SetIsEnabled(self.Properties.WarMessageElement, showWarMessage)
  local showPermissionDeniedMessage = not self.playerHasPermission and not showWarMessage
  UiElementBus.Event.SetIsEnabled(self.Properties.PermissionDeniedElement, showPermissionDeniedMessage)
end
function UnifiedInteractCard:OnHidden()
  UiElementBus.Event.SetIsEnabled(self.Properties.InteractNameElement, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.OwnershipElement, false)
  UnifiedInteractOptionsComponentRequestsBus.Event.RemoveAllInteractOptions(self.Properties.InteractOptionsElement)
  if self.ownershipNotificationsHandler then
    self:BusDisconnect(self.ownershipNotificationsHandler)
    self.ownershipNotificationsHandler = nil
  end
  if self.hasGuildWarObservers then
    UiImageBus.Event.SetSpritePathname(self.Properties.Circle, self.originalCirclePath)
    UiImageBus.Event.SetColor(self.Properties.Circle, self.UIStyle.COLOR_WHITE)
    UiElementBus.Event.SetIsEnabled(self.Properties.CircleBG, true)
    self.ScriptedEntityTweener:Set(self.Properties.OwnershipNameText, {
      textColor = self.originalOwnershipNameColor
    })
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId")
    self.ownershipGuildId = nil
    self.hasGuildWarObservers = nil
    self.isAtWar = nil
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.PermissionDeniedElement, "@ui_nopermission", eUiTextSet_SetLocalized)
  self.playerHasPermission = false
  self.playerMeetsLevel = false
  if self.isDataPosition then
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.UnifiedInteract.ScreenPosition." .. tostring(self.interactableEntityId))
    local playerComponentData = InteractCommon:GetLocalPlayerComponentData()
    UiInteractorComponentRequestsBus.Event.StopPositionUpdates(playerComponentData.interactorEntityId, self.interactableEntityId)
    self.isDataPosition = false
  end
  if self.onFadeCallback then
    self.onFadeCallback.func(self.onFadeCallback.callingSelf, self.onFadeCallback.markerId, self)
    self.onFadeCallback = nil
  end
  if self.markerNotificationHandler then
    self:BusDisconnect(self.markerNotificationHandler)
    self.markerNotificationHandler = nil
  end
end
function UnifiedInteractCard:SetScreenPosition(screenPosition, force)
  if UiElementBus.Event.IsEnabled(self.entityId) or force then
    screenPosition.x = Clamp(screenPosition.x + self.positionOffset.x, self.canvasSize.x * 0.1, self.canvasSize.x * 0.9 - self.widthOffset)
    screenPosition.y = Clamp(screenPosition.y + self.positionOffset.y, self.canvasSize.y * 0.2, self.canvasSize.y * 0.8 - self.heightOffset)
    UiTransformBus.Event.SetLocalPosition(self.entityId, Vector2(screenPosition.x, screenPosition.y))
  end
end
function UnifiedInteractCard:OnPositionChangedInteractOffset(screenPosition)
  self:SetScreenPosition(screenPosition)
end
function UnifiedInteractCard:SetInteractName(interactName)
  if not interactName or interactName == "" or interactName == " " then
    UiElementBus.Event.SetIsEnabled(self.Properties.TitleFrame, false)
    return
  end
  self.interactName = interactName
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.InteractName", interactName)
  UiTextBus.Event.SetTextWithFlags(self.Properties.InteractNameElement, interactName, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.InteractNameElement, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.TitleFrame, true)
end
function UnifiedInteractCard:SetStructureName(structureName)
  if not structureName or structureName == "" then
    structureName = self.interactName
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.InteractNameElement, structureName, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.InteractNameElement, true)
end
function UnifiedInteractCard:OnInteractFocus(onFocus, hasMarker, positionOffset, tickPosition)
  if self.isDead then
    return
  end
  self.respawnTimeRemaining = nil
  self.positionOffset = positionOffset
  self.interactableEntityId = onFocus.interactableEntityId
  if not hasMarker then
    self.isDataPosition = true
    self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.UnifiedInteract.ScreenPosition." .. tostring(self.interactableEntityId), function(self, screenPosition)
      self:SetScreenPosition(screenPosition)
    end)
  else
    self.markerNotificationHandler = MarkerNotificationBus.Connect(self, onFocus.markerEntityId)
    self.tickPosition = tickPosition
    if self.tickPosition then
      local worldPosition = TransformBus.Event.GetWorldTranslation(self.interactableEntityId)
      self:SetScreenPosition(LyShineManagerBus.Broadcast.ProjectToScreen(worldPosition, false, false), true)
      self:StartTick()
    end
  end
  local playerComponentData = InteractCommon:GetLocalPlayerComponentData()
  local interactName = onFocus.interactName
  if interactName then
    self:SetInteractName(interactName)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.InteractNameElement, false)
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.InteractEntityId", self.interactableEntityId)
  local playerHasPermission = true
  if not self.IsGatherable then
    local rootId = TransformBus.Event.GetRootId(self.interactableEntityId)
    local hasVitals = VitalsComponentRequestBus.Event.IsDeathsDoor(rootId) ~= nil
    if not hasVitals then
      UiElementBus.Event.SetIsEnabled(self.Properties.Divider, true)
      self.ScriptedEntityTweener:Play(self.Properties.Divider, 0.3, {w = 0, opacity = 0}, {
        w = 250,
        opacity = 1,
        ease = "QuadOut"
      })
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.Divider, false)
    end
    self.boundOwnershipEntityId = onFocus:GetOwnershipBind().ownershipBindEntityId
    if self.boundOwnershipEntityId:IsValid() then
      local guildId = GuildsComponentBus.Broadcast.GetGuildId()
      local territoryId = UiInteractRequestsBus.Event.GetTerritoryEntityId(self.interactableEntityId)
      self.ownershipGuildId = OwnershipRequestBus.Event.GetGuildId(self.boundOwnershipEntityId)
      playerHasPermission = OwnershipRequestBus.Event.PlayerHasPermissions(self.boundOwnershipEntityId, playerComponentData.playerEntityId, guildId)
      local hasOwnershipComponent = playerHasPermission ~= nil
      UiElementBus.Event.SetIsEnabled(self.Properties.OwnershipElement, hasOwnershipComponent)
      if hasOwnershipComponent then
        local ownershipData = onFocus:GetOwnershipBind():GetOwnership()
        self.OwnershipElement:OnOwnershipChanged(ownershipData)
        self.ownershipNotificationsHandler = self:BusConnect(UiOwnershipNotificationsBus, self.boundOwnershipEntityId)
        self:SetStructureName(ownershipData.ownedStructureName)
      else
        local ownershipGuildValid = self.ownershipGuildId and self.ownershipGuildId:IsValid()
        if not ownershipGuildValid or guildId == self.ownershipGuildId then
          playerHasPermission = true
        end
      end
      self.playerMeetsLevel = true
      playerHasPermission = playerHasPermission and self.playerMeetsLevel
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.OwnershipElement, false)
    end
    local rootPlayerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    local inOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(rootPlayerId, 2444859928)
    local interactNameElementTextPosY = self.interactNameElementTextInitPosY
    local ownershipNameTextPosY = self.ownershipNameTextInitPosY
    if inOutpostRush then
      local buildableId = BuildableRequestBus.Event.GetBuildableId(rootId)
      local isComplete = BuildableRequestBus.Event.IsComplete(rootId)
      if not isComplete and buildableId == 3329276415 then
        UiTextBus.Event.SetTextWithFlags(self.Properties.OwnershipNameText, "@ui_or_commandpost_buff_off", eUiTextSet_SetLocalized)
        UiTextBus.Event.SetColor(self.Properties.OwnershipNameText, self.UIStyle.COLOR_BRIGHT_YELLOW)
        interactNameElementTextPosY = self.interactNameElementTextOutpostRushPosY
        ownershipNameTextPosY = self.ownershipNameTextOutpostRushPosY
      else
        UiTextBus.Event.SetText(self.Properties.OwnershipNameText, "")
      end
    end
    UiTransformBus.Event.SetLocalPositionY(self.Properties.InteractNameElement, interactNameElementTextPosY)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.OwnershipNameText, ownershipNameTextPosY)
  end
  self:SetPlayerHasPermission(playerHasPermission, onFocus.unifiedInteractOptions)
  local textSize = UiTextBus.Event.GetTextSize(self.Properties.InteractNameElement)
  local textWidth = textSize.x
  local paddingX = self.IsGatherable and 100 or 200
  textWidth = textWidth + paddingX
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TitleBackground, textWidth)
  self.onFadeCallback = nil
  self.isHomePoint = false
  if not self.IsGatherable then
    self.isHomePoint = onFocus.isHomePoint
    do
      local showRespawnPoint = false
      if self.isHomePoint then
        self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.UnifiedInteract.RespawnCooldownDuration", function(self, duration)
          self.respawnDuration = duration or 0
          self:UpdateRespawnTimer()
        end)
        self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.UnifiedInteract.RespawnCooldownRemaining", function(self, timeRemaining)
          self.respawnTimeRemaining = timeRemaining or 0
          self:EnableRespawnTimer(self.respawnTimeRemaining > 0)
        end)
        self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.UnifiedInteract.RespawnType", function(self, type)
          local iconPath
          if type == "Private" then
            iconPath = RESPAWN_PRIVATE_POINT_PNG
          elseif type == "Camp" then
            iconPath = RESPAWN_PRIVATE_POINT_PNG
          elseif type == "Guild" then
            iconPath = RESPAWN_GUILD_POINT_PNG
          end
          if iconPath then
            self.RespawnIcon:SetIcon(iconPath, Color(1, 1, 1))
            showRespawnPoint = true
          end
        end)
      else
        self:EnableRespawnTimer(false)
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.RespawnIconContainer, showRespawnPoint)
    end
  end
  self:SetIsEnabled(true)
end
function UnifiedInteractCard:OnInteractUnfocus(onFadeCallback)
  self.onFadeCallback = onFadeCallback
  self:SetIsEnabled(false)
  if self.isHomePoint then
    self:EnableRespawnTimer(false)
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.UnifiedInteract.RespawnCooldownRemaining")
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.UnifiedInteract.RespawnCooldownDuration")
  end
  local rootPlayerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local inOutpostRush = GameModeParticipantComponentRequestBus.Event.IsInGameMode(rootPlayerId, 2444859928)
  if inOutpostRush and self.Properties.OwnershipNameText:IsValid() then
    UiTextBus.Event.SetText(self.Properties.OwnershipNameText, "")
    UiTextBus.Event.SetColor(self.Properties.OwnershipNameText, self.originalOwnershipNameColor)
  end
  self:StopTick()
  self.tickPosition = false
end
function UnifiedInteractCard:OnInteractExecute(onExecute)
  local shouldClose = InteractCommon:OnInteractExecute(onExecute, self.Properties.InteractOptionsElement)
  if shouldClose then
    self:SetIsEnabled(false)
  end
  if onExecute.interactOptionEntry == "OpenInteractScreen" then
    LyShineManagerBus.Broadcast.ToggleState(3592356463)
  end
  if onExecute.interactOptionEntry == "OpenMap" then
    LyShineManagerBus.Broadcast.SetState(2477632187)
  end
end
function UnifiedInteractCard:OnOwnershipChanged(ownership)
  local playerComponentData = InteractCommon:GetLocalPlayerComponentData()
  local playerHasPermission = InteractCommon:OnOwnershipChanged({
    ownership = ownership,
    playerComponentData = playerComponentData,
    boundOwnershipEntityId = self.boundOwnershipEntityId
  })
  self:SetPlayerHasPermission(playerHasPermission)
  self.ownershipGuildId = ownership.ownedByGuildId
  self:UpdateGuildWarState()
  self:SetStructureName(ownership.ownedStructureName)
  if type(self.OwnershipElement) == "table" then
    self.OwnershipElement:OnOwnershipChanged(ownership)
  end
end
function UnifiedInteractCard:OnGuildStructureNameChanged(structureName)
  self:SetStructureName(structureName)
end
function UnifiedInteractCard:SetPlayerHasPermission(playerHasPermission, unifiedInteractOptions)
  local playerComponentData = InteractCommon:GetLocalPlayerComponentData()
  InteractCommon:SetPlayerHasPermission({
    unifiedInteractOptions = unifiedInteractOptions,
    lastPlayerHasPermissionState = self.playerHasPermission,
    interactOptionsElement = self.Properties.InteractOptionsElement,
    playerComponentData = playerComponentData,
    playerHasPermission = playerHasPermission
  })
  self.playerHasPermission = playerHasPermission
end
function UnifiedInteractCard:OnGatheringStart(gatheringStart)
  if not self.enableNewGatherTimer then
    self:SetIsEnabled(false)
    return
  end
  self.isBeingGathered = UiElementBus.Event.IsEnabled(self.entityId)
  if not self.isBeingGathered then
    return
  end
  local gatherableAmount = gatheringStart.gatherableBind.gatherableAmount
  self.gatherAmountRemaining = gatherableAmount.timeRemaining
  self.gatherAmountTotal = gatherableAmount.totalTime
  self.remainingGatherPercentAtStart = gatherableAmount.timeRemainingAtStart / gatherableAmount.totalTime
  self.remainingGatherPercent = self.remainingGatherPercentAtStart
  self.lastDisplayedGatherPercent = self.remainingGatherPercentAtStart
  self.actualLastRemainingPercent = self.remainingGatherPercentAtStart
  UiFaderBus.Event.SetFadeValue(self.Properties.CircleFlash, 0)
  UiElementBus.Event.SetIsEnabled(self.Properties.CircleFlash, true)
  UiImageBus.Event.SetFillAmount(self.Properties.CircleProgress, self.remainingGatherPercent)
  UiElementBus.Event.SetIsEnabled(self.Properties.CircleProgress, true)
  UiImageBus.Event.SetFillAmount(self.Properties.CircleProgressTail, 0)
  UiElementBus.Event.SetIsEnabled(self.Properties.CircleProgressTail, true)
  self.ScriptedEntityTweener:Play(self.Properties.Options, 0.25, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.CircleProgress, 0.25, {opacity = 0}, {opacity = 1})
  self.impactCount = 0
  self.gatheringType = gatheringStart.gatheringType
  if self.GatherableNotificationBusId then
    self:BusDisconnect(self.GatherableNotificationBusId)
    self.GatherableNotificationBusId = nil
  end
  self.gatherableControllerId = gatheringStart.gatherableBind.gatherableEntityId
  if self.gatherableControllerId then
    self.GatherableNotificationBusId = self:BusConnect(UiGatherableComponentNotificationsBus, self.gatherableControllerId)
  end
end
function UnifiedInteractCard:OnGatheringEnd()
  if not self.enableNewGatherTimer or not self.isBeingGathered then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.TimerText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CircleProgress, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CircleProgressTail, false)
  if self.GatherableNotificationBusId then
    self:BusDisconnect(self.GatherableNotificationBusId)
    self.GatherableNotificationBusId = nil
  end
  if self.remainingGatherPercent > 0 then
    self.ScriptedEntityTweener:Play(self.Properties.Options, 0.25, {opacity = 1})
  end
  self.isBeingGathered = false
  self.gatherAmountRemaining = nil
  self.gatherAmountTotal = nil
end
function UnifiedInteractCard:CalculatePercentagePerImpact(percentPerSwing)
  if percentPerSwing ~= 0 then
    local numSwingsToComplete = math.ceil(self.remainingGatherPercent / percentPerSwing + 1)
    if numSwingsToComplete ~= 0 then
      self.percentagePerImpact = self.lastDisplayedGatherPercent / numSwingsToComplete
    end
  end
end
function UnifiedInteractCard:OnMomentOfImpact()
  if not self.enableNewGatherTimer or not self.isBeingGathered then
    return
  end
  local gatherImpactScaleFactor = self.gatheringImpactTypes[self.gatheringType]
  if gatherImpactScaleFactor then
    self.impactCount = self.impactCount + 1
    local displayGatherPercent
    if self.lastDisplayedGatherPercent == self.remainingGatherPercentAtStart then
      local percentPerSwing = self.remainingGatherPercentAtStart - self.remainingGatherPercent
      self:CalculatePercentagePerImpact(percentPerSwing * gatherImpactScaleFactor)
      displayGatherPercent = self.remainingGatherPercentAtStart - self.percentagePerImpact
    else
      displayGatherPercent = self.lastDisplayedGatherPercent - self.percentagePerImpact
      if self.impactCount == 2 or math.abs(displayGatherPercent - self.remainingGatherPercent) > 0.5 then
        self:CalculatePercentagePerImpact(self.actualLastRemainingPercent - self.remainingGatherPercent)
        displayGatherPercent = self.lastDisplayedGatherPercent - self.percentagePerImpact
      end
    end
    self.ScriptedEntityTweener:Play(self.Properties.CircleProgress, 0.25, {
      imgFill = self.lastDisplayedGatherPercent
    }, {imgFill = displayGatherPercent, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.CircleProgressTail, 0.25, {
      imgFill = self.lastDisplayedGatherPercent
    }, {
      imgFill = displayGatherPercent,
      ease = "QuadInOut",
      delay = 0.5
    })
    self.ScriptedEntityTweener:Play(self.Properties.CircleFlash, 0.5, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
    self.lastDisplayedGatherPercent = displayGatherPercent
    self.actualLastRemainingPercent = self.remainingGatherPercent
  end
end
function UnifiedInteractCard:OnAmountChanged(gatherableAmount)
  local curNumGatherers = UiGatherableComponentRequestsBus.Event.CurrentNumGatherers(self.gatherableControllerId)
  local requiredNumGatherers = UiGatherableComponentRequestsBus.Event.RequiredNumGatherers(self.gatherableControllerId)
  local hasRequiredAmtOfPlayers = curNumGatherers == requiredNumGatherers
  if hasRequiredAmtOfPlayers then
    local remainingGatherPercent = gatherableAmount.timeRemaining / gatherableAmount.totalTime
    self:UpdateCircleProgress(remainingGatherPercent)
  end
end
function UnifiedInteractCard:UpdateCircleProgress(remainingGatherPercent)
  self.remainingGatherPercent = remainingGatherPercent
  if not self.gatheringImpactTypes[self.gatheringType] then
    UiImageBus.Event.SetFillAmount(self.Properties.CircleProgress, self.remainingGatherPercent)
  end
end
function UnifiedInteractCard:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    self.canvasSize = UiCanvasBus.Event.GetCanvasSize(self.canvasId)
  end
end
return UnifiedInteractCard
