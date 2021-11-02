local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local NavBar = {
  Properties = {
    NavMenuHolder = {
      default = EntityId()
    },
    NavMenuList = {
      default = EntityId()
    },
    SupportOptions = {
      default = EntityId()
    },
    ExitHint = {
      default = EntityId()
    },
    TimeText = {
      default = EntityId()
    }
  },
  STATE_NAME_NAVBAR = 3766762380,
  STATE_NAME_ESCAPE = 1643432462,
  STATE_NAME_GUILD = 1967160747,
  STATE_NAME_OPTIONS = 3493198471,
  STATE_NAME_MAP = 2477632187,
  STATE_NAME_JOURNAL = 1823500652,
  STATE_NAME_SKILLS = 3576764016,
  STATE_NAME_NAMEPLATES_ONLY = 3175660710,
  STATE_NAME_STORE = 4283914359,
  navBarMenuName = "NavBar",
  navBarOffsetY = 20,
  isCameraSet = false,
  ContentUnavailablePopupTitle = "@ui_content_unavailable_title",
  ContentUnavailablePopupText = "@ui_content_unavailable_message",
  ContentUnavailableEventId = "ContentUnavailablePopup",
  isSkillsScreenBlocked = false,
  isMasteryTutorialActive = false,
  unspentAttributePoints = 0,
  unclaimedRewardCount = 0,
  unspentWeaponMasteryPoints = 0
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(NavBar)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function NavBar:OnInit()
  BaseScreen.OnInit(self)
  self.ExitHint:SetCallback("OnEscapeHintPressed", self)
  self.ExitHint:SetKeybindMapping("toggleMenuComponent")
  self.NavButtonData = {
    {
      text = "@ui_navmenu_guild",
      stateName = self.STATE_NAME_GUILD,
      hintKeybind = "toggleGuildComponent",
      callback = "OnGuildPressed",
      buttonOverride = "LyShineUI\\NavBar\\NavBarButton"
    },
    {
      text = "@ui_navmenu_map",
      stateName = self.STATE_NAME_MAP,
      hintKeybind = "toggleMapComponent",
      callback = "OnMapPressed",
      buttonOverride = "LyShineUI\\NavBar\\NavBarButton"
    },
    {
      text = "@ui_navmenu_journal",
      stateName = self.STATE_NAME_JOURNAL,
      hintKeybind = "toggleJournalComponent",
      callback = "OnJournalPressed",
      buttonOverride = "LyShineUI\\NavBar\\NavBarButton"
    },
    {
      text = "@ui_navmenu_progression",
      stateName = self.STATE_NAME_SKILLS,
      hintKeybind = "toggleSkillsComponent",
      callback = "OnSkillsPressed",
      buttonOverride = "LyShineUI\\NavBar\\NavBarButton"
    },
    {
      text = "@ui_navmenu_store",
      stateName = self.STATE_NAME_STORE,
      callback = "OnStorePressed",
      buttonOverride = "LyShineUI\\NavBar\\NavBarButton"
    },
    {
      text = "@ui_navmenu_settings",
      stateName = self.STATE_NAME_OPTIONS,
      callback = "OnOptionsPressed",
      buttonOverride = "LyShineUI\\NavBar\\NavBarButton"
    },
    {
      text = "@ui_navmenu_game_menu",
      stateName = self.STATE_NAME_ESCAPE,
      callback = "OnGamePressed",
      buttonOverride = "LyShineUI\\NavBar\\NavBarButton"
    }
  }
  self.screenStatesToSkipOutro = {}
  self.screenStatesToSkipOutro[self.STATE_NAME_NAVBAR] = true
  self.screenStatesToSkipOutro[self.STATE_NAME_ESCAPE] = true
  self.screenStatesToSkipOutro[self.STATE_NAME_GUILD] = true
  self.screenStatesToSkipOutro[self.STATE_NAME_OPTIONS] = true
  self.screenStatesToSkipOutro[self.STATE_NAME_MAP] = true
  self.screenStatesToSkipOutro[self.STATE_NAME_JOURNAL] = true
  self.screenStatesToSkipOutro[self.STATE_NAME_SKILLS] = true
  self.screenStatesToSkipOutro[self.STATE_NAME_STORE] = true
  self.screenStatesToHide = {
    [4283914359] = false
  }
  self.disabledStates = {}
  self.disabledStates[self.STATE_NAME_SKILLS] = true
  self.disabledStates[self.STATE_NAME_NAMEPLATES_ONLY] = true
  self.disabledStates[self.STATE_NAME_STORE] = true
  self.disabledStates[self.STATE_NAME_JOURNAL] = not ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-journal")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableAttributes", function(self, data)
    if data then
      self.disabledStates[self.STATE_NAME_SKILLS] = false
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableTradeskills", function(self, data)
    if data then
      self.disabledStates[self.STATE_NAME_SKILLS] = false
    end
  end)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if not self.isFtue and EntitlementsDataHandler:IsStoreEnabled() then
    self.disabledStates[self.STATE_NAME_STORE] = false
  end
  for i = #self.NavButtonData, 1, -1 do
    if self.disabledStates[self.NavButtonData[i].stateName] then
      table.remove(self.NavButtonData, i)
    end
  end
  local actionMapActivators = {
    "ui_cancel",
    "ui_visible_mod",
    "ui_visible"
  }
  if LyShineScriptBindRequestBus.Broadcast.IsEditor() then
    table.insert(actionMapActivators, "toggleMenuComponentF10")
  end
  self.actionHandlers = {}
  for k, v in pairs(actionMapActivators) do
    self.actionHandlers[k] = CryActionNotificationsBus.Connect(self, v)
  end
  DynamicBus.Map.Connect(self.entityId, self)
  AdjustElementToCanvasWidth(self.NavMenuHolder, self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.dataLayer:RegisterOpenEvent(self.navBarMenuName, self.canvasId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.UnspentPoints", function(self, count)
    if count ~= nil then
      self.unspentAttributePoints = count
      local totalCount = count + self.unclaimedRewardCount + self.unspentWeaponMasteryPoints
      self:EnableItemNotification("Skills", 0 < totalCount, totalCount)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Skills.MasteryPoints", function(self, count)
    if count ~= nil then
      self.unspentWeaponMasteryPoints = count
      local totalCount = count + self.unspentAttributePoints + self.unclaimedRewardCount
      self:EnableItemNotification("Skills", 0 < totalCount, totalCount)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "MetaAchievements.UnclaimedRewardCount", function(self, count)
    if count ~= nil then
      self.unclaimedRewardCount = count
      local totalCount = count + self.unspentAttributePoints + self.unspentWeaponMasteryPoints
      self:EnableItemNotification("Skills", 0 < totalCount, totalCount)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.GuildWarCount", function(self, count)
    if count ~= nil then
      self:EnableItemNotification("Guild", 0 < count, count)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.TurretVitalsEntityId", function(self, vitalsEntityId)
    self.isInTurretInteraction = vitalsEntityId and vitalsEntityId:IsValid()
  end)
  if self.isFtue then
    self:SetupFtueControls()
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
    DynamicBus.TutorialMessage.Connect(self.entityId, self)
  end
  self:SetNavMenu()
  self.NavMenuList:SetCallback(self.ExecuteObservers, self)
  DynamicBus.NavBarBus.Connect(self.entityId, self)
end
function NavBar:OnEscapeHintPressed()
  self:OnCryAction("toggleMenuComponent")
end
function NavBar:ExecuteObservers()
  local unspentPoints = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Attributes.UnspentPoints")
  if unspentPoints then
    self.unspentAttributePoints = unspentPoints
    local totalCount = unspentPoints + self.unclaimedRewardCount + self.unspentWeaponMasteryPoints
    self:EnableItemNotification("Skills", 0 < totalCount, totalCount)
  end
  local unspentWeaponMasteryPoints = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Skills.MasteryPoints")
  if unspentWeaponMasteryPoints then
    self.unspentWeaponMasteryPoints = unspentWeaponMasteryPoints
    local totalCount = unspentWeaponMasteryPoints + self.unclaimedRewardCount + self.unspentAttributePoints
    self:EnableItemNotification("Skills", 0 < totalCount, totalCount)
  end
  local unclaimedRewards = self.dataLayer:GetDataFromNode("MetaAchievements.UnclaimedRewardCount")
  if unclaimedRewards then
    self.unclaimedRewardCount = unclaimedRewards
    local totalCount = unclaimedRewards + self.unspentAttributePoints + self.unspentWeaponMasteryPoints
    self:EnableItemNotification("Skills", 0 < totalCount, totalCount)
  end
  local guildData = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.GuildWarCount")
  if guildData then
    self:EnableItemNotification("Guild", 0 < guildData, guildData)
  end
end
function NavBar:OnShutdown()
  for k, v in pairs(self.actionHandlers) do
    v:Disconnect()
  end
  DynamicBus.Map.Disconnect(self.entityId, self)
  DynamicBus.NavBarBus.Disconnect(self.entityId, self)
  self:EndTick()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
    DynamicBus.TutorialMessage.Disconnect(self.entityId, self)
  end
  BaseScreen.OnShutdown(self)
  self:SetCameraMovementEnabled(true)
end
function NavBar:SetNavMenu()
  if self.NavMenuList:GetTabCount() == 0 then
    for i = 1, #self.NavButtonData do
      local currentNavData = self.NavButtonData[i]
      local buttonParams = {
        hintKeybind = currentNavData.hintKeybind,
        stateName = currentNavData.stateName
      }
      self.NavMenuList:AddTab(currentNavData.text, currentNavData.callback, self, buttonParams, currentNavData.buttonOverride, false, #self.NavButtonData)
    end
    local navHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.NavMenuHolder)
    self.ScriptedEntityTweener:Set(self.Properties.NavMenuHolder, {
      y = -(navHeight + self.navBarOffsetY)
    })
  end
end
function NavBar:EnableItemNotification(stateName, isEnabled, value)
  for i = 1, #self.NavButtonData do
    local currentNavData = self.NavButtonData[i]
    if Math.CreateCrc32(stateName) == currentNavData.stateName then
      local currentButton = self.NavMenuList:GetTab(i)
      if not currentButton then
        return
      end
      if isEnabled then
        if Math.CreateCrc32(stateName) == self.STATE_NAME_GUILD then
          currentButton:SetIconVisible(true)
          if value then
            currentButton:SetIconValue(value)
          end
        elseif Math.CreateCrc32(stateName) == self.STATE_NAME_SKILLS or Math.CreateCrc32(stateName) == self.STATE_NAME_MAP then
          currentButton:SetIconVisible(true)
          currentButton:SetHintHighlightVisible(true)
          if value then
            currentButton:SetIconValue(value)
          end
        end
      elseif Math.CreateCrc32(stateName) == self.STATE_NAME_GUILD then
        currentButton:SetIconVisible(false)
      elseif Math.CreateCrc32(stateName) == self.STATE_NAME_SKILLS or Math.CreateCrc32(stateName) == self.STATE_NAME_MAP then
        currentButton:SetIconValue(nil)
        currentButton:SetIconVisible(false)
        currentButton:SetHintHighlightVisible(false)
      end
      return
    end
  end
end
function NavBar:UpdateSelectedItem()
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  for i = 1, #self.NavButtonData do
    if currentState == self.NavButtonData[i].stateName then
      self.NavMenuList:SetSelectedTab(i)
    end
  end
end
function NavBar:StartTick()
  if LoadScreenBus.Broadcast.IsLoadingScreenShown() then
    return
  end
  local localPlayerGdeRoot = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  if not localPlayerGdeRoot or not localPlayerGdeRoot:IsValid() then
    return
  end
  if self.tickHandler == nil then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function NavBar:EndTick()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function NavBar:OnTick(delta, timePoint)
  local now = timeHelpers:ServerSecondsSinceEpoch()
  if now ~= self.lastTime then
    self.lastTime = now
    local timeText = timeHelpers:GetCurrentServerTime()
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeText, timeText, eUiTextSet_SetAsIs)
  end
end
function NavBar:SetCameraMovementEnabled(isEnabled)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(isEnabled)
end
function NavBar:VisibilityChanged(isVisible)
  if isVisible then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.NavMenuHolder, true)
    self.ScriptedEntityTweener:Set(self.Properties.NavMenuHolder, {opacity = 1})
    self.ScriptedEntityTweener:PlayC(self.Properties.NavMenuHolder, 0.25, tweenerCommon.navMenuHolderIn)
  else
    local navHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.NavMenuHolder)
    self.ScriptedEntityTweener:Play(self.Properties.NavMenuHolder, 0.2, {
      y = -(navHeight + self.navBarOffsetY),
      ease = "QuadIn",
      onComplete = function()
        UiCanvasBus.Event.SetEnabled(self.canvasId, false)
        LyShineManagerBus.Broadcast.TransitionOutComplete()
      end
    })
  end
end
function NavBar:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.showingMissionOnMap = DynamicBus.MagicMap.Broadcast.IsShowingObjectiveData()
  if self.screenStatesToHide[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
  if not self.showingMissionOnMap then
    self:UpdateSelectedItem()
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Screens.Chat.SetContainerVisibility", true)
    self:SetCameraMovementEnabled(false)
    if self.isCameraSet ~= true then
      self.isCameraSet = true
      JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_NavBar", 0.25)
    end
    if self.isMasteryTutorialActive then
      self.ScriptedEntityTweener:Set(self.Properties.NavMenuHolder, {opacity = 0})
      UiElementBus.Event.SetIsEnabled(self.Properties.NavMenuHolder, false)
    else
      self:VisibilityChanged(true)
    end
    self.audioHelper:PlaySound(self.audioHelper.Screen_EscapeMenuOpen)
    self:StartTick()
    self:UpdateUnspentTokensCount()
  end
end
function NavBar:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToHide[fromState] and self.canvasId then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
  if not self.showingMissionOnMap then
    self.NavMenuList:UnfocusSelectedTab()
    self:EndTick()
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Screens.Chat.SetContainerVisibility", false)
    self:SetCameraMovementEnabled(true)
    if self.screenStatesToSkipOutro[toState] then
      LyShineManagerBus.Broadcast.TransitionOutComplete()
    else
      if self.isCameraSet then
        self.isCameraSet = false
        JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_NavBar", 0.25)
      end
      self:VisibilityChanged(false)
      DynamicBus.NavBarBus.Broadcast.OnNavBarClosed()
    end
    self.audioHelper:PlaySound(self.audioHelper.Screen_EscapeMenuClose)
    self.SupportOptions:SetVisible(false)
  else
    LyShineManagerBus.Broadcast.TransitionOutComplete()
  end
  self.showingMissionOnMap = false
end
local ignoreEscStates = {
  3901667439,
  921475099,
  3326371288
}
local escapeKeyHandlingStates = {
  640726528,
  2477632187,
  3370453353,
  3211015753,
  2640373987,
  3548394217,
  3160088100,
  2552344588,
  3024636726,
  1101180544,
  4283914359,
  849925872,
  978471761
}
function NavBar:OnCryAction(actionName, value)
  local isVisibleKey = actionName == "ui_visible"
  local isVisibleModKey = actionName == "ui_visible_mod"
  if isVisibleKey or isVisibleModKey then
    if FtueSystemRequestBus.Broadcast.IsFtue() then
      return
    end
    if isVisibleModKey then
      self.isVisibleModDown = 0 < value
    elseif self.isVisibleModDown then
      local isUiVisible = LyShineScriptBindRequestBus.Broadcast.GetCVar("g_uivisible") ~= 0
      LyShineScriptBindRequestBus.Broadcast.SetCVar("g_uivisible", isUiVisible and 0 or 1)
    end
    return
  end
  local currentLevel = LyShineManagerBus.Broadcast.GetCurrentLevel()
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  for _, state in ipairs(ignoreEscStates) do
    if currentState == state then
      return
    end
  end
  if self.dataLayer:IsScreenOpen("WarDeclarationPopup") then
    return
  end
  if self.dataLayer:IsScreenOpen("ConfirmationPopup") then
    DynamicBus.ConfirmationPopup.Broadcast.HideConfirmationPopup()
    return
  end
  if self.dataLayer:IsScreenOpen("WarTutorialPopup") then
    DynamicBus.WarTutorialPopup.Broadcast.HideWarTutorialPopup()
    return
  end
  if self.isInTurretInteraction and (currentState == 0 or currentState == 2702338936) then
    return
  end
  if currentLevel ~= 0 and currentLevel ~= -1 and currentLevel ~= 6 then
    for _, state in ipairs(escapeKeyHandlingStates) do
      if currentState == state then
        DynamicBus.EscapeKeyNotificationBus.Broadcast.OnEscapeKeyPressed()
        return
      end
    end
    if currentState == 3024636726 then
      DynamicBus.CraftingStationBus.Broadcast.OnEscapeKeyPressed()
    elseif currentState == 1343302363 then
      DynamicBus.DyeDiscoveryBus.Broadcast.OnEscapeKeyPressed()
    elseif currentState == 156281203 then
      DynamicBus.ContractBrowser.Broadcast.OnEscapeKeyPressed()
    elseif currentState == 1967160747 then
      DynamicBus.GuildMenuBus.Broadcast.OnEscapeKeyPressed()
    elseif currentState == 3211015753 then
      DynamicBus.TerritoryInfoScreen.Broadcast.OnEscapeKeyPressed()
    elseif self.showingMissionOnMap then
      LyShineManagerBus.Broadcast.SetState(2609973752)
    elseif currentState == 2609973752 then
      DynamicBus.OWGDynamicRequestBus.Broadcast.OnEscapeKeyPressed()
    elseif currentState == 663562859 then
      LyShineManagerBus.Broadcast.ExitState(663562859)
    else
      LyShineManagerBus.Broadcast.SetState(2702338936)
    end
  else
    if actionName == "toggleMenuComponent" and LyShineScriptBindRequestBus.Broadcast.IsEditor() then
      return
    end
    if currentLevel ~= 6 then
      if currentLevel ~= 10 then
        if self.dataLayer:IsScreenOpen("FlyoutMenu") then
          DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
        end
        LyShineManagerBus.Broadcast.SetState(3766762380)
      else
        LyShineManagerBus.Broadcast.SetState(2702338936)
      end
    end
  end
end
function NavBar:OnHoverStart(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.OnHover)
end
function NavBar:TryCloseOtherScreens()
  self.SupportOptions:SetVisible(false)
end
function NavBar:OnGamePressed()
  self:TryCloseOtherScreens()
  LyShineManagerBus.Broadcast.SetState(self.STATE_NAME_ESCAPE)
end
function NavBar:OnGuildPressed()
  if self.isFtue then
    PopupWrapper:RequestPopup(ePopupButtons_OK, self.ContentUnavailablePopupTitle, self.ContentUnavailablePopupText, self.ContentUnavailableEventId, self, function(self, result, eventId)
    end)
    self:UpdateSelectedItem()
  else
    self:TryCloseOtherScreens()
    LyShineManagerBus.Broadcast.SetState(self.STATE_NAME_GUILD)
  end
end
function NavBar:OnOptionsPressed()
  self:TryCloseOtherScreens()
  LyShineManagerBus.Broadcast.SetState(self.STATE_NAME_OPTIONS)
end
function NavBar:OnStorePressed()
  if not EntitlementsDataHandler:IsStoreEnabled() or self.isFtue then
    PopupWrapper:RequestPopup(ePopupButtons_OK, self.ContentUnavailablePopupTitle, self.ContentUnavailablePopupText, self.ContentUnavailableEventId, self, function(self, result, eventId)
    end)
    self:UpdateSelectedItem()
  else
    self:TryCloseOtherScreens()
    LyShineManagerBus.Broadcast.SetState(self.STATE_NAME_STORE)
  end
end
function NavBar:OnMapPressed()
  if self.isFtue then
    PopupWrapper:RequestPopup(ePopupButtons_OK, self.ContentUnavailablePopupTitle, self.ContentUnavailablePopupText, self.ContentUnavailableEventId, self, function(self, result, eventId)
    end)
    self:UpdateSelectedItem()
  else
    self:TryCloseOtherScreens()
    LyShineManagerBus.Broadcast.SetState(self.STATE_NAME_MAP)
  end
end
function NavBar:OnJournalPressed()
  self:TryCloseOtherScreens()
  LyShineManagerBus.Broadcast.SetState(self.STATE_NAME_JOURNAL)
end
function NavBar:OnSkillsPressed()
  if self.isFtue and self.isSkillsScreenBlocked then
    PopupWrapper:RequestPopup(ePopupButtons_OK, self.ContentUnavailablePopupTitle, self.ContentUnavailablePopupText, self.ContentUnavailableEventId, self, function(self, result, eventId)
    end)
    self:UpdateSelectedItem()
  else
    self:TryCloseOtherScreens()
    LyShineManagerBus.Broadcast.SetState(self.STATE_NAME_SKILLS)
  end
end
function NavBar:OnSupportPressed(entityTable)
  LyShineManagerBus.Broadcast.SetState(3766762380)
  self.SupportOptions:SetVisible(true)
  local viewportPos = UiTransformBus.Event.GetViewportPosition(entityTable.entityId)
  local heightOffset = UiTransformBus.Event.GetViewportSpaceRect(entityTable.entityId):GetHeight()
  local padding = 6
  viewportPos.y = viewportPos.y + heightOffset + padding
  UiTransformBus.Event.SetViewportPosition(self.Properties.SupportOptions, viewportPos)
end
function NavBar:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasWidth(self.NavMenuHolder, self.canvasId)
  end
end
function NavBar:SetupFtueControls()
  self.ftueBlockedActions = {
    toggleInventoryWindow = "ui",
    toggleChatComponent = "ui",
    toggleChatComponentSlash = "ui",
    toggleGuildComponent = "ui",
    toggleMapComponent = "ui",
    toggleSkillsComponent = "ui",
    makeCampOn = "ui",
    togglePvpFlag = "ui",
    toggleEmoteWindow = "ui",
    autorun = "movement",
    fishing_activate = "player"
  }
  self.ftueUnblockActionsOnMessage = {
    ["@TUT_Inventory_Open"] = {
      "toggleInventoryWindow"
    },
    ["@TUT_Autorun"] = {"autorun"},
    ["@TUT_Mastery_SelectTree"] = {
      "toggleSkillsComponent"
    }
  }
  self.ftueBlockedKeys = {}
  for action, group in pairs(self.ftueBlockedActions) do
    if LyShineManagerBus.Broadcast.IsKeybindBound(action, group) then
      local keyName = LyShineManagerBus.Broadcast.GetKeybind(action, group)
      self.ftueBlockedKeys[self:NormalizeKeyName(keyName)] = true
    end
  end
  self.KeyInputNotificationBus = self:BusConnect(KeyInputNotificationBus, self.canvasId)
  self:BusConnect(TutorialComponentNotificationsBus, self.canvasId)
  self.isSkillsScreenBlocked = true
end
function NavBar:OnKeyPressed(keyName)
  keyName = self:NormalizeKeyName(keyName)
  if self.ftueBlockedKeys[keyName] then
    self:OnBlockedFtueAction()
  end
end
function NavBar:OnBlockedFtueAction()
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ftue_action_unavailable")
  notificationData.contextId = self.entityId
  notificationData.allowDuplicates = false
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function NavBar:OnTutorialActivated(tutorialMsgId)
  local unblockActions = self.ftueUnblockActionsOnMessage[tutorialMsgId]
  if unblockActions then
    for i = 1, #unblockActions do
      local action = unblockActions[i]
      local group = self.ftueBlockedActions[action]
      if action and group then
        local keyName = LyShineManagerBus.Broadcast.GetKeybind(action, group)
        self.ftueBlockedKeys[self:NormalizeKeyName(keyName)] = false
      end
    end
  end
end
function NavBar:NormalizeKeyName(keyName)
  return string.lower(string.match(keyName, "%S+"))
end
function NavBar:SetMasteryTutorialActive(isActive)
  self.isMasteryTutorialActive = isActive
  if isActive then
    self.isSkillsScreenBlocked = false
    self:OnTutorialActivated("@TUT_Mastery_SelectTree")
  end
end
function NavBar:SetElementVisibleForFtue(isVisible)
  if isVisible then
    self.KeyInputNotificationBus = self:BusConnect(KeyInputNotificationBus, self.canvasId)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockEscMenu", false)
  else
    self:BusDisconnect(self.KeyInputNotificationBus)
    UIInputRequestsBus.Broadcast.EnableInputFilter("LockEscMenu", true)
    LyShineManagerBus.Broadcast.SetState(2702338936)
  end
end
function NavBar:UpdateTerritories()
  if not self.territories then
    self.territories = {}
    local claims = MapComponentBus.Broadcast.GetClaims()
    for index = 1, #claims do
      local capital = claims[index]
      local territoryData = {
        index = capital.monikerId,
        territoryId = capital.settlementId
      }
      local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(capital.settlementId)
      territoryData.nameLocalizationKey = territoryDefn.nameLocalizationKey
      table.insert(self.territories, territoryData)
    end
  end
end
function NavBar:GetTotalUnspentTokens()
  self:UpdateTerritories()
  local unspent = 0
  for i, territory in ipairs(self.territories) do
    local standing = TerritoryDataHandler:GetTerritoryStanding(territory.territoryId)
    unspent = unspent + standing.tokens
  end
  return unspent
end
function NavBar:UpdateUnspentTokensCount()
  local unspentTokens = self:GetTotalUnspentTokens()
  if unspentTokens ~= nil then
    self:EnableItemNotification("Map", 0 < unspentTokens, unspentTokens)
  end
end
return NavBar
