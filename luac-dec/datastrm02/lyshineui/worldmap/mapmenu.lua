local MapMenu = {
  Properties = {
    Background = {
      default = EntityId()
    },
    LeaderboardsContainer = {
      default = EntityId()
    },
    DayLeaderboardButton = {
      default = EntityId()
    },
    SeasonLeaderboardButton = {
      default = EntityId()
    },
    CompaniesAtWarButton = {
      default = EntityId()
    },
    CompaniesAtWarContainer = {
      default = EntityId()
    },
    TerritoryStandingsButton = {
      default = EntityId()
    },
    TerritoryStandingsContainer = {
      default = EntityId()
    },
    TerritoryStandingsPromptFlyout = {
      default = EntityId()
    },
    TerritoryStandingsPromptText = {
      default = EntityId()
    },
    TerritoryStandingsPromptHeader = {
      default = EntityId()
    },
    ObjectivesLocationsListButton = {
      default = EntityId()
    },
    ObjectivesLocationsListContainer = {
      default = EntityId()
    },
    WarPromptFlyout = {
      default = EntityId()
    },
    WarPromptText = {
      default = EntityId()
    },
    WarPromptHeader = {
      default = EntityId()
    },
    WarPromptParent = {
      default = EntityId()
    },
    ResourceLocationsButton = {
      default = EntityId()
    },
    ResourceLocationsContainer = {
      default = EntityId()
    },
    SettlementWarsContainer = {
      default = EntityId()
    },
    FilterParent = {
      default = EntityId()
    },
    FilterToggle = {
      default = EntityId()
    },
    FilterHeader = {
      default = EntityId()
    },
    FiltersContainer = {
      default = EntityId()
    },
    Filters = {
      LocalPlayer = {
        default = EntityId()
      },
      Respawn = {
        default = EntityId()
      },
      PointOfInterest = {
        default = EntityId()
      },
      Territory = {
        default = EntityId()
      },
      FactionInfluence = {
        default = EntityId()
      }
    },
    ObjectiveContainer = {
      default = EntityId()
    },
    DungeonContainer = {
      default = EntityId()
    },
    DungeonNameTextBg = {
      default = EntityId()
    },
    DungeonNameText = {
      default = EntityId()
    },
    DungeonNameDivider = {
      default = EntityId()
    },
    DungeonExitButton = {
      default = EntityId()
    }
  },
  enableLeaderboards = false,
  filterOptionsOpen = false,
  isExpanded = true
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MapMenu)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function MapMenu:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  DynamicBus.MapMenu.Connect(self.entityId, self)
  DynamicBus.Map.Connect(self.entityId, self)
  self.DayLeaderboardButton:SetText("@ui_leaderboard")
  self.DayLeaderboardButton:SetHeaderText("@ui_mapmenu_dayleaderboard")
  self.DayLeaderboardButton:SetIcon("LyShineUI\\Images\\Icons\\Misc\\icon_leaderboard.png", self.UIStyle.COLOR_TAN)
  self.DayLeaderboardButton:SetCallback(self.OnShowDayLeaderboard, self)
  self.SeasonLeaderboardButton:SetText("@ui_leaderboard")
  self.SeasonLeaderboardButton:SetHeaderText("@ui_mapmenu_seasonleaderboard")
  self.SeasonLeaderboardButton:SetIcon("LyShineUI\\Images\\Icons\\Misc\\icon_leaderboard.png", self.UIStyle.COLOR_TAN)
  self.SeasonLeaderboardButton:SetCallback(self.OnShowSeasonLeaderboard, self)
  self.DungeonExitButton:SetText("@ui_dungeon_leave")
  self.DungeonExitButton:SetCallback(self.OnExitDungeon, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableMapMenuActiveWarsPanel", function(self, enableCompaniesAtWar)
    self.enableCompaniesAtWar = enableCompaniesAtWar
  end)
  if self.enableCompaniesAtWar then
    self.CompaniesAtWarButton:SetText("@ui_mapmenu_companiesatwar")
    self.CompaniesAtWarButton:SetIcon("LyShineUI\\Images\\Icons\\Misc\\icon_warBigDiamond.png", self.UIStyle.COLOR_WHITE)
    self.CompaniesAtWarButton:SetCallback(self.OnShowCompaniesAtWar, self)
  end
  self.CompaniesAtWarButton:SetIcon("LyShineUI\\Images\\Icons\\Misc\\icon_warBigDiamond.png", self.UIStyle.COLOR_WHITE)
  self.ResourceLocationsButton:SetText("@ui_mapmenu_resourcelocations")
  self.ResourceLocationsButton:SetIcon("LyShineUI\\Images\\Icons\\Misc\\icon_resourceLocation.png", self.UIStyle.COLOR_TAN)
  self.ResourceLocationsButton:SetCallback(self.OnShowResourceLocations, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    if playerEntityId and self.delayUpdateButtons then
      self.UpdateButtons()
      self.delayUpdateButtons = nil
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableLeaderboards", function(self, enableLeaderboards)
    self.enableLeaderboards = enableLeaderboards
    if self.playerEntityId then
      self:UpdateButtons()
    else
      self.delayUpdateButtons = true
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableTerritoryMechanics", function(self, enableTerritoryMechanics)
    self.enableTerritoryMechanics = enableTerritoryMechanics
    if self.playerEntityId then
      self:UpdateButtons()
    else
      self.delayUpdateButtons = true
    end
  end)
  self.ObjectivesLocationsListButton:SetText("@objective_objectives")
  self.ObjectivesLocationsListButton:SetIcon("LyShineUI\\Images\\Icons\\Objectives\\icon_objective_mapButton.dds", self.UIStyle.COLOR_WHITE)
  self.ObjectivesLocationsListButton:ShowCounter(false)
  self.ObjectivesLocationsListButton:SetCallback(self.OnShowObjectiveLocationsList, self)
  self.TerritoryStandingsButton:SetText("@ui_mapmenu_territorystandings")
  self.TerritoryStandingsButton:SetIcon("LyShineUI\\Images\\Icons\\Misc\\icon_territoryToken.png", self.UIStyle.COLOR_WHITE)
  self.TerritoryStandingsButton:SetCallback(self.OnShowTerritoryStandings, self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
    self.rootPlayerId = rootPlayerId
  end)
  self.FilterToggle:SetText("@ui_filters")
  self.FilterToggle:SetIcon("LyShineUI\\Images\\Icons\\misc\\icon_mapfilter.png", self.UIStyle.COLOR_TAN)
  self.FilterToggle:SetCallback(self.OnMapLeftClick, self)
  self.Filters.LocalPlayer:SetCallback(self.OnFilterItemPress, self)
  self.Filters.Respawn:SetCallback(self.OnFilterItemPress, self)
  self.Filters.PointOfInterest:SetCallback(self.OnFilterItemPress, self)
  self.Filters.Territory:SetCallback(self.OnFilterItemPress, self)
  self.Filters.FactionInfluence:SetCallback(self.OnFilterItemPress, self)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarPromptParent, true)
end
function MapMenu:ToggleTimelineAnimations(isEnable)
  if isEnable then
    if self.timeline == nil then
      self.timeline = self.ScriptedEntityTweener:TimelineCreate()
      self.timeline:Add(self.Properties.TerritoryStandingsPromptHeader, 0.7, {opacity = 1})
      self.timeline:Add(self.Properties.TerritoryStandingsPromptHeader, 0.3, {opacity = 1})
      self.timeline:Add(self.Properties.TerritoryStandingsPromptHeader, 0.4, {
        opacity = 0,
        onComplete = function()
          self.timeline:Play()
        end
      })
    end
    self.timeline:Play()
    if self.warHeadertimeline == nil then
      self.warHeadertimeline = self.ScriptedEntityTweener:TimelineCreate()
      self.warHeadertimeline:Add(self.Properties.WarPromptHeader, 0.7, {opacity = 1})
      self.warHeadertimeline:Add(self.Properties.WarPromptHeader, 0.3, {opacity = 1})
      self.warHeadertimeline:Add(self.Properties.WarPromptHeader, 0.4, {
        opacity = 0,
        onComplete = function()
          self.warHeadertimeline:Play()
        end
      })
    end
    self.warHeadertimeline:Play()
  else
    if self.timeline ~= nil then
      self.timeline:Stop()
      self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
      self.timeline = nil
    end
    if self.warHeadertimeline ~= nil then
      self.warHeadertimeline:Stop()
      self.ScriptedEntityTweener:TimelineDestroy(self.warHeadertimeline)
      self.warHeadertimeline = nil
    end
  end
end
function MapMenu:OnShutdown()
  DynamicBus.MapMenu.Disconnect(self.entityId, self)
  DynamicBus.Map.Disconnect(self.entityId, self)
  self:ToggleTimelineAnimations(false)
end
function MapMenu:UpdateButtons()
  local buttonPositionY = UiTransformBus.Event.GetLocalPositionY(self.Properties.DayLeaderboardButton)
  local buttonSpacing = 114
  local filterSpacing = 120
  UiElementBus.Event.SetIsEnabled(self.Properties.DayLeaderboardButton, self.enableLeaderboards)
  UiElementBus.Event.SetIsEnabled(self.Properties.SeasonLeaderboardButton, self.enableLeaderboards)
  if self.enableLeaderboards then
    buttonPositionY = buttonPositionY + 2 * buttonSpacing
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CompaniesAtWarButton, self.enableCompaniesAtWar)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.objectives-enableDynamicSortingHud") then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ObjectivesLocationsListButton, buttonPositionY)
    buttonPositionY = buttonPositionY + buttonSpacing
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ObjectivesLocationsListButton, false)
  end
  if self.enableCompaniesAtWar then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.CompaniesAtWarButton, buttonPositionY)
    buttonPositionY = buttonPositionY + buttonSpacing
  end
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ResourceLocationsButton, buttonPositionY)
  buttonPositionY = buttonPositionY + buttonSpacing
  UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryStandingsButton, self.enableTerritoryMechanics)
  if self.enableTerritoryMechanics then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.TerritoryStandingsButton, buttonPositionY)
    buttonPositionY = buttonPositionY + buttonSpacing
  end
  UiTransformBus.Event.SetLocalPositionY(self.Properties.FilterParent, buttonPositionY)
  buttonPositionY = buttonPositionY + buttonSpacing
  local unspentTokens = self.TerritoryStandingsContainer:GetTotalUnspentTokens()
  local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_mapmenu_territorystandings_unspent_tokens", tostring(unspentTokens))
  UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryStandingsPromptText, text, eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryStandingsPromptFlyout, 0 < unspentTokens)
  self.TerritoryStandingsButton:SetCounterText(unspentTokens)
  self.TerritoryStandingsButton:ShowCounter(0 < unspentTokens)
  local signedUpTerritories = RaidSetupRequestBus.Broadcast.GetSignedUpTerritories()
  local warText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_mapmenu_numactivewars", tostring(#signedUpTerritories))
  if #signedUpTerritories == 1 then
    warText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_mapmenu_oneactivewar", tostring(#signedUpTerritories))
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.WarPromptText, warText, eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarPromptFlyout, 0 < #signedUpTerritories)
end
function MapMenu:SetMarkersLayer(markersLayer)
  self.markersLayer = markersLayer
end
function MapMenu:OnMapShown()
  self:ToggleTimelineAnimations(true)
  self:UpdateUnspentTokensCount()
  self:UpdateNumWars()
  self:UpdateDungeon()
end
function MapMenu:OnMapHidden()
  DynamicBus.Map.Broadcast.OnShowPanel()
  self:ToggleTimelineAnimations(false)
end
function MapMenu:OnMapLeftClick()
  if self.isExpanded and not self:IsSubPanelVisible() then
    self.ScriptedEntityTweener:Play(self.Properties.Background, 0.3, {x = 0}, {x = -200, ease = "QuadOut"})
    self.ResourceLocationsButton:AnimateButtonToSmall(true)
    self.SeasonLeaderboardButton:AnimateButtonToSmall(true)
    self.DayLeaderboardButton:AnimateButtonToSmall(true)
    self.TerritoryStandingsButton:AnimateButtonToSmall(true)
    self.ObjectivesLocationsListButton:AnimateButtonToSmall(true)
    if self.enableCompaniesAtWar then
      self.CompaniesAtWarButton:AnimateButtonToSmall(true)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.FilterHeader, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FiltersContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.FilterToggle, true)
    self.isExpanded = false
  end
end
function MapMenu:OnShowPanel()
end
function MapMenu:IsCursorOnMapMenu()
  local entityId
  if self.LeaderboardsContainer:IsVisible() then
    entityId = self.Properties.LeaderboardsContainer
  elseif self.ResourceLocationsContainer:IsVisible() then
    entityId = self.Properties.ResourceLocationsContainer
  elseif self.CompaniesAtWarContainer:IsVisible() then
    entityId = self.Properties.CompaniesAtWarContainer
  elseif self.TerritoryStandingsContainer:IsVisible() then
    entityId = self.Properties.TerritoryStandingsContainer
  elseif self.ObjectivesLocationsListContainer:IsVisible() then
    entityId = self.Properties.ObjectivesLocationsListContainer
  elseif self.SettlementWarsContainer:IsVisible() then
    entityId = self.Properties.SettlementWarsContainer
  else
    entityId = self.Properties.Background
  end
  if entityId then
    local screenPoint = CursorBus.Broadcast.GetCursorPosition()
    local viewportRect = UiTransformBus.Event.GetViewportSpaceRect(entityId)
    local viewportRight = viewportRect:GetCenterX() + viewportRect:GetWidth() / 2
    if viewportRight >= screenPoint.x then
      return true
    end
  end
  return false
end
function MapMenu:OnMapMenuHover()
  if not self.isExpanded and not self:IsSubPanelVisible() then
    self.ScriptedEntityTweener:Play(self.Properties.Background, 0.3, {x = -200}, {x = 0, ease = "QuadOut"})
    self.ResourceLocationsButton:AnimateButtonToSmall(false)
    self.SeasonLeaderboardButton:AnimateButtonToSmall(false)
    self.DayLeaderboardButton:AnimateButtonToSmall(false)
    self.TerritoryStandingsButton:AnimateButtonToSmall(false)
    self.ObjectivesLocationsListButton:AnimateButtonToSmall(false)
    if self.enableCompaniesAtWar then
      self.CompaniesAtWarButton:AnimateButtonToSmall(false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.FilterHeader, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.FiltersContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.FilterToggle, false)
    local childElements = UiElementBus.Event.GetChildren(self.Properties.FiltersContainer)
    local startDelay = 0.02
    for i = 1, #childElements do
      local button = childElements[i]
      self.ScriptedEntityTweener:Play(button, 0.1, {opacity = 0}, {
        opacity = 1,
        delay = startDelay * i
      })
    end
    self.isExpanded = true
  end
end
function MapMenu:UpdateUnspentTokensCount()
  local unspentTokens = self.TerritoryStandingsContainer:GetTotalUnspentTokens()
  local text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_mapmenu_territorystandings_unspent_tokens", tostring(unspentTokens))
  UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryStandingsPromptText, text, eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryStandingsPromptFlyout, 0 < unspentTokens)
  self.TerritoryStandingsButton:SetCounterText(unspentTokens)
  self.TerritoryStandingsButton:ShowCounter(0 < unspentTokens)
end
function MapMenu:UpdateNumWars()
  local signedUpTerritories = RaidSetupRequestBus.Broadcast.GetSignedUpTerritories()
  local warText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_mapmenu_numactivewars", tostring(#signedUpTerritories))
  if #signedUpTerritories == 1 then
    warText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_mapmenu_oneactivewar", tostring(#signedUpTerritories))
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.WarPromptText, warText, eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarPromptFlyout, 0 < #signedUpTerritories)
end
function MapMenu:UpdateDungeon()
  if self.rootPlayerId then
    local gameModeId = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(self.rootPlayerId)
    UiElementBus.Event.SetIsEnabled(self.Properties.DungeonContainer, gameModeId ~= 0)
    if gameModeId ~= 0 then
      local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.rootPlayerId, gameModeId)
      UiTextBus.Event.SetTextWithFlags(self.Properties.DungeonNameText, gameModeData.displayName, eUiTextSet_SetLocalized)
      SetTextStyle(self.Properties.DungeonNameText, {
        characterSpacing = 200,
        fontColor = self.UIStyle.COLOR_TAN_LIGHT,
        fontFamily = self.UIStyle.FONT_FAMILY_PICA,
        fontSize = 26,
        textCasing = self.UIStyle.TEXT_CASING_UPPER
      })
      local titleTextWidth = UiTextBus.Event.GetTextWidth(self.Properties.DungeonNameText)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.DungeonNameTextBg, titleTextWidth + 100)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.DungeonNameDivider, titleTextWidth)
    end
  end
end
function MapMenu:OnShowDayLeaderboard()
  local isDayLeaderboard = true
  DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Leaderboards, isDayLeaderboard)
end
function MapMenu:OnShowSeasonLeaderboard()
  local isDayLeaderboard = false
  DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Leaderboards, isDayLeaderboard)
end
function MapMenu:OnShowCompaniesAtWar()
  if not self.enableCompaniesAtWar then
    return
  end
  DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.CompaniesAtWar)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarPromptParent, false)
end
function MapMenu:OnShowTerritoryStandings()
  if not self.enableTerritoryMechanics then
    return
  end
  DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.TerritoryStanding)
end
function MapMenu:OnShowObjectiveLocationsList()
  DynamicBus.Map.Broadcast.OnShowPanel(mapTypes.panelTypes.ObjectiveLocationList)
end
function MapMenu:OnShowResourceLocations()
  DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.MapLegend)
end
function MapMenu:OnShowSettlementWars(settlementKey)
  DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.SettlementWars, settlementKey)
end
function MapMenu:OnFilterItemPress(entityId)
  local isFilterOn = UiCheckboxBus.Event.GetState(entityId)
  for filterType, id in pairs(self.Properties.Filters) do
    if id == entityId then
      self.markersLayer:SetOptionFilter(filterType, not isFilterOn)
      return
    end
  end
end
function MapMenu:IsSubPanelVisible()
  if self.LeaderboardsContainer:IsVisible() then
    return true
  end
  if self.ResourceLocationsContainer:IsVisible() then
    return true
  end
  if self.CompaniesAtWarContainer:IsVisible() then
    return true
  end
  if self.SettlementWarsContainer:IsVisible() then
    return true
  end
  if self.ObjectiveContainer:IsVisible() then
    return true
  end
  if self.ObjectivesLocationsListContainer:IsVisible() then
    return true
  end
  if self.TerritoryStandingsContainer:IsVisible() then
    return true
  end
  return false
end
function MapMenu:OnExitDungeon()
  local dungeonWillClose = true
  local exitDungeonEventId = "ExitDungeonPopupId"
  local popupTitle = "@ui_exit_dungeon_title"
  local popupMessage = dungeonWillClose and "@ui_exit_dungeon_will_close_desc" or "@ui_exit_dungeon_desc"
  local buttonStyle = ePopupButtons_YesNo
  local isInCombat = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CombatStatus.IsInCombat")
  local inCombatDurationSeconds = -1
  if isInCombat then
    inCombatDurationSeconds = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CombatStatus.InCombatTimePoint"):Subtract(TimePoint:Now()):ToSeconds()
    popupTitle = "@ui_quitpopup_incombat_title"
    popupMessage = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_exit_dungeon_incombat", timeHelpers:ConvertSecondsToHrsMinSecString(inCombatDurationSeconds))
    buttonStyle = ePopupButtons_OK
  end
  PopupWrapper:RequestPopup(buttonStyle, popupTitle, popupMessage, exitDungeonEventId, self, function(self, result, eventId)
    if eventId == exitDungeonEventId and result == ePopupResult_Yes then
      PlayerArenaRequestBus.Event.ForfeitArena(self.rootPlayerId, true)
    end
  end)
end
return MapMenu
