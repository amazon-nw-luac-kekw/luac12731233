local TerritoryPlanning = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    BackgroundStep1 = {
      default = EntityId()
    },
    BackgroundStep2 = {
      default = EntityId()
    },
    LandingPanel = {
      default = EntityId()
    },
    InfoContainer = {
      default = EntityId()
    },
    InfoBackgroundMask = {
      default = EntityId()
    },
    ProjectTypePanels = {
      SettlementPanel = {
        default = EntityId()
      },
      FortPanel = {
        default = EntityId()
      },
      LifestylePanel = {
        default = EntityId()
      }
    },
    ProjectTypeButtons = {
      SettlementButton = {
        default = EntityId()
      },
      FortButton = {
        default = EntityId()
      },
      LifestyleButton = {
        default = EntityId()
      },
      WarPrepButton = {
        default = EntityId()
      },
      WeakenInvasionButton = {
        default = EntityId()
      }
    },
    TerritoryNameText = {
      default = EntityId()
    },
    TerritoryNameTextBg = {
      default = EntityId()
    },
    TerritoryOutline = {
      default = EntityId()
    },
    LifestyleUpgradesGrid = {
      default = EntityId()
    },
    UpgradeItemPrototype = {
      default = EntityId()
    },
    UpgradesCompletedText = {
      default = EntityId()
    },
    ActiveProjectContainer = {
      default = EntityId()
    },
    ActiveProjectTimeRemaining = {
      default = EntityId()
    },
    ProjectDetailPopup = {
      default = EntityId()
    },
    ProjectStartedPopup = {
      default = EntityId()
    },
    SelectPaymentPopup = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    LineTop = {
      default = EntityId()
    },
    LineLeft = {
      default = EntityId()
    },
    LineRight = {
      default = EntityId()
    },
    VerticalDivider = {
      default = EntityId()
    }
  },
  territoryOutlinePath = "LyShineUI/Images/Territory/Outlines/territoryPlanning_territory%d.dds",
  invalidTerritoryOutlinePath = "LyShineUI/Images/Territory/Outlines/territoryPlanning_Invalid.png",
  cancelProjectPopupId = "cancelProject",
  replaceProjectPopupId = "replaceProject"
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(TerritoryPlanning)
local territoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function TerritoryPlanning:OnInit()
  BaseScreen.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.ActiveProjectContainer, false)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.ProjectTypeButtons.SettlementButton:SetLabelText("@ui_upgradebutton_label_settlement")
  self.ProjectTypeButtons.SettlementButton:SetTooltip("@ui_upgradebutton_tooltip_settlement")
  self.ProjectTypeButtons.SettlementButton:SetIconPath("LyShineUI/Images/Icons/Misc/icon_settlement.png")
  self.ProjectTypeButtons.SettlementButton:SetCallback(self.OnSettlementButtonPressed, self)
  self.ProjectTypeButtons.FortButton:SetLabelText("@ui_upgradebutton_label_fort")
  self.ProjectTypeButtons.FortButton:SetTooltip("@ui_upgradebutton_tooltip_fort")
  self.ProjectTypeButtons.FortButton:SetIconPath("LyShineUI/Images/Icons/Misc/icon_fortress.png")
  self.ProjectTypeButtons.FortButton:SetCallback(self.OnFortButtonPressed, self)
  self.ProjectTypeButtons.LifestyleButton:SetLabelText("@ui_upgradebutton_label_lifestyle")
  self.ProjectTypeButtons.LifestyleButton:SetTooltip("@ui_upgradebutton_tooltip_lifestyle")
  self.ProjectTypeButtons.LifestyleButton:SetIconPath("LyShineUI/Images/Icons/Misc/icon_lifestyle.png")
  self.ProjectTypeButtons.LifestyleButton:SetCallback(self.OnLifestyleButtonPressed, self)
  self.ProjectTypeButtons.WeakenInvasionButton:SetLabelText("@ui_upgradebutton_label_weakeninvasions")
  self.ProjectTypeButtons.WeakenInvasionButton:SetTooltip("@ui_upgradebutton_tooltip_weakeninvasions")
  self.ProjectTypeButtons.WeakenInvasionButton:SetIconPath("LyShineUI/Images/Icons/Misc/icon_darknessDisabled.png")
  self.ProjectTypeButtons.WeakenInvasionButton:SetSubLabelText("@ui_coming_soon")
  self.ProjectTypeButtons.WeakenInvasionButton:SetIsClickable(false)
  self.ProjectTypeButtons.WarPrepButton:SetLabelText("@ui_upgradebutton_label_prepareforwars")
  self.ProjectTypeButtons.WarPrepButton:SetTooltip("@ui_upgradebutton_tooltip_prepareforwars")
  self.ProjectTypeButtons.WarPrepButton:SetIconPath("LyShineUI/Images/Icons/Misc/icon_preparewarDisabled.png")
  self.ProjectTypeButtons.WarPrepButton:SetSubLabelText("@ui_coming_soon")
  self.ProjectTypeButtons.WarPrepButton:SetIsClickable(false)
  self.ScreenHeader:SetHintCallback(self.OnExit, self)
  self.ScreenHeader:SetText("@ui_plan_territory" .. ".")
  self.upgradeTypeButtonData = {
    [eTerritoryUpgradeType_Settlement] = {
      button = self.ProjectTypeButtons.SettlementButton,
      tooltip = "@ui_upgradebutton_tooltip_settlement"
    },
    [eTerritoryUpgradeType_Fortress] = {
      button = self.ProjectTypeButtons.FortButton,
      tooltip = "@ui_upgradebutton_tooltip_fort"
    },
    [eTerritoryUpgradeType_Lifestyle] = {
      button = self.ProjectTypeButtons.LifestyleButton,
      tooltip = "@ui_upgradebutton_tooltip_lifestyle"
    }
  }
  self.buttonPositionsByTerritory = {
    [2] = {
      settlement = Vector2(1364, 225),
      fort = Vector2(1160, 430),
      lifestyle = Vector2(1465, 581),
      weakenInvasion = Vector2(1194, 718),
      warPrep = Vector2(969, 595)
    },
    [4] = {
      settlement = Vector2(1280, 540),
      fort = Vector2(1160, 302),
      lifestyle = Vector2(1530, 700),
      weakenInvasion = Vector2(985, 634),
      warPrep = Vector2(873, 487)
    },
    [5] = {
      settlement = Vector2(1210, 258),
      fort = Vector2(1416, 448),
      lifestyle = Vector2(1036, 602),
      weakenInvasion = Vector2(1412, 750),
      warPrep = Vector2(1563, 606)
    },
    [6] = {
      settlement = Vector2(1422, 484),
      fort = Vector2(1212, 273),
      lifestyle = Vector2(1077, 623),
      weakenInvasion = Vector2(1412, 750),
      warPrep = Vector2(1563, 606)
    },
    [8] = {
      settlement = Vector2(1157, 568),
      fort = Vector2(1575, 436),
      lifestyle = Vector2(1054, 360),
      weakenInvasion = Vector2(1505, 141),
      warPrep = Vector2(1383, 249)
    },
    [9] = {
      settlement = Vector2(1126, 532),
      fort = Vector2(1524, 391),
      lifestyle = Vector2(1209, 212),
      weakenInvasion = Vector2(1505, 141),
      warPrep = Vector2(1383, 249)
    },
    [10] = {
      settlement = Vector2(1487, 275),
      fort = Vector2(1151, 479),
      lifestyle = Vector2(1415, 612),
      weakenInvasion = Vector2(985, 634),
      warPrep = Vector2(1060, 747)
    },
    [11] = {
      settlement = Vector2(1396, 420),
      fort = Vector2(1489, 645),
      lifestyle = Vector2(1462, 220),
      weakenInvasion = Vector2(1075, 634),
      warPrep = Vector2(1142, 747)
    },
    [12] = {
      settlement = Vector2(1396, 282),
      fort = Vector2(1160, 460),
      lifestyle = Vector2(1387, 601),
      weakenInvasion = Vector2(1035, 682),
      warPrep = Vector2(1198, 558)
    },
    [13] = {
      settlement = Vector2(1366, 490),
      fort = Vector2(1232, 275),
      lifestyle = Vector2(1280, 692),
      weakenInvasion = Vector2(1404, 660),
      warPrep = Vector2(1471, 773)
    },
    [14] = {
      settlement = Vector2(1121, 277),
      fort = Vector2(1500, 434),
      lifestyle = Vector2(1579, 183),
      weakenInvasion = Vector2(1412, 672),
      warPrep = Vector2(1577, 576)
    },
    [15] = {
      settlement = Vector2(1300, 654),
      fort = Vector2(1560, 481),
      lifestyle = Vector2(1280, 289),
      weakenInvasion = Vector2(1404, 660),
      warPrep = Vector2(1471, 773)
    },
    [16] = {
      settlement = Vector2(1364, 225),
      fort = Vector2(1160, 430),
      lifestyle = Vector2(1465, 581),
      weakenInvasion = Vector2(1194, 718),
      warPrep = Vector2(969, 595)
    }
  }
  self.defaultButtonPositions = {
    settlement = Vector2(900, 100),
    fort = Vector2(900, 250),
    lifestyle = Vector2(900, 400),
    weakenInvasion = Vector2(900, 500),
    warPrep = Vector2(900, 600)
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isLandClaimManagerAvailable)
    self.isLandClaimManagerAvailable = isLandClaimManagerAvailable
    if isLandClaimManagerAvailable and LyShineManagerBus.Broadcast.IsInState(3370453353) then
      self:TryShowScreenOnDataReady()
    end
  end)
end
function TerritoryPlanning:OnShutdown()
  BaseScreen.OnShutdown(self)
end
function TerritoryPlanning:RefreshUpgradeList()
  UiElementBus.Event.SetIsEnabled(self.Properties.ActiveProjectContainer, false)
  self.territoryData = territoryDataHandler:GetAvailableTerritoryProjectUpgrades()
  self.activeProjects = {}
  self.activeProjectMaxLevels = {}
  self.activeProjectCurrentLevels = {}
  for k, projectGroup in ipairs(self.territoryData) do
    for i, projectData in ipairs(projectGroup) do
      if projectData:IsActive() then
        local detailedProjectData = territoryDataHandler:GetDetailedTerritoryProject(projectData.projectId)
        projectGroup[i] = detailedProjectData
        self.activeProjects[projectData.upgradeType] = detailedProjectData
        self.activeProjectMaxLevels[projectData.upgradeType] = projectGroup.maxLevel
        self.activeProjectCurrentLevels[projectData.upgradeType] = projectGroup.maxLevel
        break
      end
    end
  end
  local upgradeTypeToData = {}
  upgradeTypeToData[eTerritoryUpgradeType_Fortress] = {}
  upgradeTypeToData[eTerritoryUpgradeType_Settlement] = {}
  upgradeTypeToData[eTerritoryUpgradeType_Lifestyle] = {}
  local numAvailableUpgrades = 0
  for _, projectGroup in ipairs(self.territoryData) do
    local projectGroupElement = projectGroup[1]
    local upgradeType = projectGroupElement.upgradeType
    local dataTable = upgradeTypeToData[upgradeType]
    if not dataTable then
      Debug.Log("Warning: unable to find initialized table of this upgrade type: " .. tostring(upgradeType))
    else
      projectGroup.isActiveCallbackFn = self.OnIsActiveUpgrade
      projectGroup.callbackFn = self.OnProjectButtonPressed
      projectGroup.callbackSelf = self
      local numProjectsInGroup = #projectGroup
      if projectGroupElement:IsAvailable() then
        table.insert(dataTable, projectGroup)
        if upgradeType ~= eTerritoryUpgradeType_Lifestyle then
          numAvailableUpgrades = numAvailableUpgrades + numProjectsInGroup
        end
      end
      local activeGroupProject = self.activeProjects[upgradeType]
      if activeGroupProject then
        for i, projectData in ipairs(projectGroup) do
          if not projectData:IsComplete() then
            self.activeProjectCurrentLevels[upgradeType] = i - 1
            break
          end
        end
      end
    end
  end
  self.numAvailableUpgrades = numAvailableUpgrades
  self.ProjectTypePanels.SettlementPanel:SetUpgradeData(upgradeTypeToData[eTerritoryUpgradeType_Settlement])
  self.ProjectTypePanels.FortPanel:SetUpgradeData(upgradeTypeToData[eTerritoryUpgradeType_Fortress])
  self.ProjectTypePanels.LifestylePanel:SetUpgradeData(upgradeTypeToData[eTerritoryUpgradeType_Lifestyle])
  self:RefreshProgress()
end
function TerritoryPlanning:IsScreenReadyToShow()
  local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  return territoryId and territoryId ~= 0 and self.isLandClaimManagerAvailable
end
function TerritoryPlanning:TryShowScreenOnDataReady()
  if UiCanvasBus.Event.GetEnabled(self.canvasId) and self:IsScreenReadyToShow() then
    DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
    self:OnTransitionIn()
  end
end
function TerritoryPlanning:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  if not self:IsScreenReadyToShow() then
    DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true, 5, self, function(self)
      LyShineManagerBus.Broadcast.SetState(2702338936)
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_screen_unavailable"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end)
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, claimKey)
      if claimKey and claimKey ~= 0 then
        self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
        self:TryShowScreenOnDataReady()
      end
    end)
    return
  end
  local territoryName = territoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
  UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryNameText, territoryName, eUiTextSet_SetLocalized)
  local territoryTextSize = UiTextBus.Event.GetTextSize(self.Properties.TerritoryNameText).x
  local paddingX = 150
  local territoryTextWidth = territoryTextSize + paddingX
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TerritoryNameTextBg, territoryTextWidth)
  local buttonPositions = self.buttonPositionsByTerritory[territoryId]
  buttonPositions = buttonPositions or self.defaultButtonPositions
  self.ProjectTypeButtons.SettlementButton:SetPosition(buttonPositions.settlement)
  self.ProjectTypeButtons.FortButton:SetPosition(buttonPositions.fort)
  self.ProjectTypeButtons.LifestyleButton:SetPosition(buttonPositions.lifestyle)
  self.ProjectTypeButtons.WeakenInvasionButton:SetPosition(buttonPositions.weakenInvasion)
  self.ProjectTypeButtons.WarPrepButton:SetPosition(buttonPositions.warPrep)
  local territoryOutlinePath = string.format(self.territoryOutlinePath, territoryId)
  if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(territoryOutlinePath) then
    territoryOutlinePath = self.invalidTerritoryOutlinePath
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.TerritoryOutline, territoryOutlinePath)
  self.ProjectTypePanels.SettlementPanel:SetTerritoryId(territoryId)
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_TerritoryPlanningStep1", 0.5)
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Intro)
  UiElementBus.Event.SetIsEnabled(self.Properties.LandingPanel, true)
  for _, panel in pairs(self.Properties.ProjectTypePanels) do
    UiElementBus.Event.SetIsEnabled(panel, false)
  end
  self.ScriptedEntityTweener:Play(self.entityId, 0.2, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.BackgroundStep1, 0.5, {opacity = 0}, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Properties.BackgroundStep2, {opacity = 0})
  self.ScriptedEntityTweener:Play(self.Properties.InfoContainer, 0.5, {opacity = 0}, {opacity = 1, delay = 0.35})
  self.ScriptedEntityTweener:Play(self.Properties.TerritoryOutline, 0.5, {opacity = 0}, {opacity = 1, delay = 0.3})
  self.ScriptedEntityTweener:Play(self.Properties.ProjectTypeButtons.SettlementButton, 0.3, {opacity = 0}, {opacity = 1, delay = 0.3})
  self.ScriptedEntityTweener:Play(self.Properties.ProjectTypeButtons.FortButton, 0.3, {opacity = 0}, {opacity = 1, delay = 0.38})
  self.ScriptedEntityTweener:Play(self.Properties.ProjectTypeButtons.LifestyleButton, 0.3, {opacity = 0}, {opacity = 1, delay = 0.46})
  self.ScriptedEntityTweener:Play(self.Properties.ProjectTypeButtons.WeakenInvasionButton, 0.3, {opacity = 0}, {opacity = 1, delay = 0.54})
  self.ScriptedEntityTweener:Play(self.Properties.ProjectTypeButtons.WarPrepButton, 0.3, {opacity = 0}, {opacity = 1, delay = 0.62})
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 4
  self.targetDOFBlur = 0.5
  self.ScriptedEntityTweener:StartAnimation({
    id = self.Properties.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 1.2,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  if not self.interfaceComponentHandler then
    local territoryEntityId = self.dataLayer:GetDataFromNode("Hud.TerritoryGovernance.EntityId")
    self.interfaceComponentHandler = self:BusConnect(TerritoryInterfaceComponentNotificationsBus, territoryEntityId)
  end
  self:BusConnect(LandClaimNotificationBus)
  self:OnReceivedLatestProgressionData()
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
end
function TerritoryPlanning:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("", 0.5)
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.Properties.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  if self.interfaceComponentHandler then
    self:BusDisconnect(self.interfaceComponentHandler)
    self.interfaceComponentHandler = nil
  end
  self.ProjectDetailPopup:OnClose()
  DynamicBus.TerritoryPlanningToolip.Broadcast.CloseTooltip()
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  self.hasSeenReplaceWarning = false
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function TerritoryPlanning:OnReceivedTerritoryProgressionData(territoryProgressionData)
  self:OnReceivedLatestProgressionData()
end
function TerritoryPlanning:OnTerritoryActiveProjectChanged(claimKey, projectData, projectState)
  self:OnReceivedLatestProgressionData()
end
function TerritoryPlanning:OnReceivedLatestProgressionData()
  UiElementBus.Event.SetIsEnabled(self.Properties.ActiveProjectContainer, false)
  self:RefreshUpgradeList()
end
function TerritoryPlanning:RefreshProgress()
  local territoryEntityId = self.dataLayer:GetDataFromNode("Hud.TerritoryGovernance.EntityId")
  local progressionData = TerritoryInterfaceComponentRequestBus.Event.GetTerritoryProgressionData(territoryEntityId)
  local completedUpgrades = #progressionData.completedTerritoryUpgrades
  local upgradesCompletedText = GetLocalizedReplacementText("@ui_upgrade_numcompleted", {
    numCompleted = completedUpgrades,
    total = self.numAvailableUpgrades
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.UpgradesCompletedText, upgradesCompletedText, eUiTextSet_SetAsIs)
  local numCompletedSettlementUpgrades = 0
  local numCompletedFortUpgrades = 0
  for i = 1, completedUpgrades do
    local progressionStaticData = TerritoryGovernanceRequestBus.Broadcast.GetTerritoryProgressionData(progressionData.completedTerritoryUpgrades[i].projectId)
    if progressionStaticData.projectType == eTerritoryUpgradeType_Settlement then
      numCompletedSettlementUpgrades = numCompletedSettlementUpgrades + 1
    end
    if progressionStaticData.projectType == eTerritoryUpgradeType_Fortress then
      numCompletedFortUpgrades = numCompletedFortUpgrades + 1
    end
  end
  self.ProjectTypeButtons.SettlementButton:SetNumComplete(numCompletedSettlementUpgrades)
  self.ProjectTypePanels.SettlementPanel:SetNumProjectsCompleted(numCompletedSettlementUpgrades)
  self.ProjectTypeButtons.FortButton:SetNumComplete(numCompletedFortUpgrades)
  self.ProjectTypePanels.FortPanel:SetNumProjectsCompleted(numCompletedFortUpgrades)
  local settlementTierData, settlementTier = territoryDataHandler:GetUpgradeTierInfo(eTerritoryUpgradeType_Settlement, numCompletedSettlementUpgrades)
  local fortTierData, fortTier = territoryDataHandler:GetUpgradeTierInfo(eTerritoryUpgradeType_Fortress, numCompletedFortUpgrades)
  local updatedSettlementName = GetLocalizedReplacementText("@ui_upgrade_fill", {
    tiername = settlementTierData.name
  })
  local updatedFortName = GetLocalizedReplacementText("@ui_upgrade_fill", {
    tiername = fortTierData.name
  })
  self.ProjectTypeButtons.SettlementButton:SetLabelText(updatedSettlementName)
  self.ProjectTypeButtons.FortButton:SetLabelText(updatedFortName)
  for upgradeType, buttonData in pairs(self.upgradeTypeButtonData) do
    local activeProject = self.activeProjects[upgradeType]
    if activeProject then
      buttonData.button:SetProjectTypeActive(true)
      buttonData.button:SetTooltip(nil)
      buttonData.button:SetFocusCallback(function(t)
        t:OnActiveProjectTypeButtonFocus(upgradeType)
      end, self)
      buttonData.button:SetUnfocusCallback(self.OnActiveProjectTypeButtonUnfocus, self)
      local percentCompleteText = GetLocalizedReplacementText("@ui_upgradebutton_percentcomplete", {
        percentComplete = string.format("%.1f", activeProject:GetProgressPercent() * 100)
      })
      buttonData.button:SetPercentCompleteText(percentCompleteText)
      buttonData.button:SetPercentFill(activeProject:GetProgressPercent() * 0.9)
    else
      buttonData.button:SetProjectTypeActive(false)
      buttonData.button:SetTooltip(buttonData.tooltip)
      buttonData.button:SetFocusCallback(nil, nil)
      buttonData.button:SetUnfocusCallback(nil, nil)
      buttonData.button:SetPercentCompleteText("")
      buttonData.button:SetPercentFill(0)
    end
  end
end
function TerritoryPlanning:TransitionToPanel(fromPanel, toPanel)
  UiElementBus.Event.SetIsEnabled(fromPanel, false)
  UiElementBus.Event.SetIsEnabled(toPanel, true)
  self.ScriptedEntityTweener:Play(toPanel, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.3
  })
  DynamicBus.TerritoryPlanningToolip.Broadcast.CloseTooltip()
  if fromPanel == self.Properties.LandingPanel then
    JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_TerritoryPlanningStep2", 0.5)
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
    self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
    self.targetDOFDistance = 0
    self.targetDOFBlur = 1
    self.ScriptedEntityTweener:StartAnimation({
      id = self.DOFTweenDummyElement,
      easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
      duration = 0.5,
      opacity = 1,
      onUpdate = function(currentValue, currentProgressPercent)
        self:UpdateDepthOfField(currentValue)
      end
    })
    self.audioHelper:PlaySound(self.audioHelper.Crafting_IntroStep2)
    self.ScriptedEntityTweener:Play(self.Properties.BackgroundStep2, 0.35, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.Properties.BackgroundStep1, 0.35, {opacity = 0})
  end
  if toPanel == self.Properties.LandingPanel then
    JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_TerritoryPlanningStep1", 0.5)
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
    self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
    self.targetDOFDistance = 4
    self.targetDOFBlur = 0.5
    self.ScriptedEntityTweener:StartAnimation({
      id = self.DOFTweenDummyElement,
      easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
      duration = 0.5,
      opacity = 1,
      onUpdate = function(currentValue, currentProgressPercent)
        self:UpdateDepthOfField(currentValue)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.BackgroundStep2, 0.35, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.Properties.BackgroundStep1, 0.35, {opacity = 1})
    self.audioHelper:PlaySound(self.audioHelper.Crafting_Intro)
  end
  if toPanel == self.Properties.ProjectTypePanels.LifestylePanel then
    self.LineTop:SetVisible(true, 1.2, {delay = 0.35})
    self.LineLeft:SetVisible(true, 1.2, {delay = 0.35})
    self.LineRight:SetVisible(true, 1.2, {delay = 0.35})
    self.VerticalDivider:SetVisible(true, 1.2, {delay = 0.35})
  end
  if fromPanel == self.Properties.ProjectTypePanels.LifestylePanel then
    self.LineTop:SetVisible(false, 0)
    self.LineLeft:SetVisible(false, 0)
    self.LineRight:SetVisible(false, 0)
    self.VerticalDivider:SetVisible(false, 0)
  end
end
function TerritoryPlanning:OnSettlementButtonPressed()
  self:TransitionToPanel(self.Properties.LandingPanel, self.Properties.ProjectTypePanels.SettlementPanel)
  self.ScreenHeader:SetText("@ui_upgrade_town" .. ".")
end
function TerritoryPlanning:OnFortButtonPressed()
  self:TransitionToPanel(self.Properties.LandingPanel, self.Properties.ProjectTypePanels.FortPanel)
  self.ScreenHeader:SetText("@ui_upgrade_fort" .. ".")
end
function TerritoryPlanning:OnLifestyleButtonPressed()
  self:TransitionToPanel(self.Properties.LandingPanel, self.Properties.ProjectTypePanels.LifestylePanel)
  self.ScreenHeader:SetText("@ui_upgradebutton_label_lifestyle" .. ".")
end
function TerritoryPlanning:OnProjectButtonPressed(upgradeData)
  local activeProject = self.activeProjects[upgradeData.upgradeType]
  if activeProject and activeProject:GetProgressPercent() >= 1 then
    popupWrapper:RequestPopup(ePopupButtons_OK, "@ui_active_project_completed", "@ui_wait_for_cooldown", self.cancelProjectPopupId, self, function(self)
    end)
    return
  end
  self.ProjectDetailPopup:SetDetailPopupData(upgradeData, self, function(self)
    if upgradeData:IsActive() then
      popupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_cancel_project_title", "@ui_cancel_project_desc", self.cancelProjectPopupId, self, self.OnPopupResult)
      self.toCancelProjectId = upgradeData.projectId
    else
      self.selectedProject = upgradeData
      if activeProject and not self.hasSeenReplaceWarning then
        popupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_cancel_project_title", "@ui_replace_project_desc", self.replaceProjectPopupId, self, self.OnPopupResult)
      else
        self.SelectPaymentPopup:ShowPaymentOptionPopup(upgradeData.cost, self.OnSelectedPaymentOption, self)
      end
    end
  end)
end
function TerritoryPlanning:OnIsActiveUpgrade(upgradeData, upgradeDataEntityId)
  UiElementBus.Event.SetIsEnabled(self.Properties.ActiveProjectContainer, true)
  local viewportPos = UiTransformBus.Event.GetViewportPosition(upgradeDataEntityId)
  UiTransformBus.Event.SetViewportPosition(self.Properties.ActiveProjectContainer, viewportPos)
  local timeRemaining = upgradeData:GetTimeRemaining()
  self.ActiveProjectTimeRemaining:SetCurrentCountdownTime(timeRemaining)
end
function TerritoryPlanning:OnPopupResult(result, eventId)
  if eventId == self.cancelProjectPopupId then
    if result == ePopupResult_Yes then
      TerritoryGovernanceRequestBus.Broadcast.RequestCancelProject(self.toCancelProjectId)
      self.ProjectDetailPopup:OnClose()
    end
  elseif eventId == self.replaceProjectPopupId then
    if result == ePopupResult_No then
      self.ProjectDetailPopup:OnClose()
    else
      self.hasSeenReplaceWarning = true
      self.SelectPaymentPopup:ShowPaymentOptionPopup(self.selectedProject.cost, self.OnSelectedPaymentOption, self)
    end
  end
end
function TerritoryPlanning:OnSelectedPaymentOption(useCompanyWallet)
  self.ProjectDetailPopup:OnClose()
  local succeeded = TerritoryGovernanceRequestBus.Broadcast.RequestStartProject(self.selectedProject.projectId, not useCompanyWallet)
  if succeeded then
    self.ProjectStartedPopup:SetStartedPopupData(self.selectedProject, self.OnStartProjectPopupClose, self)
  else
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_town_project_cancelled"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  self.hasSeenReplaceWarning = false
end
function TerritoryPlanning:OnStartProjectPopupClose()
  self:OnReceivedLatestProgressionData()
end
function TerritoryPlanning:OnActiveProjectTypeButtonFocus(upgradeType)
  local button = self.upgradeTypeButtonData[upgradeType].button
  local activeProject = self.activeProjects[upgradeType]
  DynamicBus.TerritoryPlanningToolip.Broadcast.OnTooltipOpen(button.entityId, activeProject.projectImage, activeProject.projectTitle, activeProject.projectDescription, self.activeProjectCurrentLevels[activeProject.upgradeType], self.activeProjectMaxLevels[activeProject.upgradeType], activeProject:IsActive(), activeProject:GetTimeRemaining(), activeProject.cost, activeProject.projectCurrentTier, activeProject.currentProgress, activeProject.progressionNeeded)
end
function TerritoryPlanning:OnActiveProjectTypeButtonUnfocus()
  DynamicBus.TerritoryPlanningToolip.Broadcast.CloseTooltip()
end
function TerritoryPlanning:OnEscapeKeyPressed()
  local popups = {
    self.SelectPaymentPopup,
    self.ProjectDetailPopup,
    self.ProjectStartedPopup
  }
  for _, popup in pairs(popups) do
    local isPopupEnabled = UiElementBus.Event.IsEnabled(popup.entityId)
    if isPopupEnabled then
      popup:OnClose()
      return
    end
  end
  for _, panel in pairs(self.Properties.ProjectTypePanels) do
    if UiElementBus.Event.IsEnabled(panel) then
      self:TransitionToPanel(panel, self.Properties.LandingPanel)
      self.ScreenHeader:SetText("@ui_plan_territory" .. ".")
      return
    end
  end
  LyShineManagerBus.Broadcast.ExitState(3370453353)
end
function TerritoryPlanning:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function TerritoryPlanning:OnExit()
  self:OnEscapeKeyPressed()
end
return TerritoryPlanning
