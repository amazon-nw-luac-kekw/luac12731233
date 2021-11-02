local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local landingCommon = RequireScript("LyShineUI.Main Menu.LandingCommon")
local ELumberyardState = {
  Disconnected = 0,
  QueueGameLogin = 1,
  WaitingForQueuedLogin = 2,
  QueryForRemoteConfigClass = 3,
  WaitingForRemoteConfigClass = 4,
  StartREPConnection = 5,
  WaitingForREPConnection = 6,
  WaitingForActorGameConnection = 7,
  WaitingForSpawnPoint = 8,
  WaitingForAOIClient = 9,
  WaitingForPlayerSpawn = 10,
  InGame = 11
}
local LandingScreen = {
  Properties = {
    ScreenHolder = {
      default = EntityId()
    },
    CreateCharacterBg = {
      default = EntityId()
    },
    Black = {
      default = EntityId()
    },
    QuitPopupTitle = {
      default = "@ui_quitpopup_title"
    },
    QuitPopupText = {
      default = "@ui_quitdesktoppopup_message"
    },
    DeletePopupTitle = {
      default = "@mm_deletechartitle"
    },
    DeletePopupText = {
      default = "@mm_deletecharwarning"
    },
    ConnectionErrorPopupTitle = {
      default = "@mm_connection_error_title"
    },
    ConnectionErrorPopupText = {
      default = "@mm_loginservices_NoConnection"
    },
    StatusSpinnerEntity = {
      default = EntityId()
    },
    FailedConnectionEntity = {
      default = EntityId()
    },
    ServerLoadingText = {
      default = EntityId()
    },
    WorldSpinnerEntity = {
      default = EntityId()
    },
    ServerPane = {
      default = EntityId()
    },
    ServerList = {
      default = EntityId()
    },
    ServerContentBoxHolder = {
      default = EntityId()
    },
    ServerContentBox = {
      default = EntityId()
    },
    ServerContentSlider = {
      default = EntityId()
    },
    ServerRegionDropdown = {
      default = EntityId()
    },
    ServerRegionText = {
      default = EntityId()
    },
    ServerCountText = {
      default = EntityId()
    },
    ServerDividerLine1 = {
      default = EntityId()
    },
    ServerDividerLine2 = {
      default = EntityId()
    },
    ServerDividerLine3 = {
      default = EntityId()
    },
    ServerTableHeader = {
      default = EntityId()
    },
    ServerSortNameButton = {
      default = EntityId()
    },
    ServerSortLastPlayedButton = {
      default = EntityId()
    },
    ServerSortPopulationButton = {
      default = EntityId()
    },
    RegionalCharacterCount = {
      default = EntityId()
    },
    RegionalCharacterCountTooltip = {
      default = EntityId()
    },
    RefreshButton = {
      default = EntityId()
    },
    RefreshButtonBg = {
      default = EntityId()
    },
    RefreshButtonIcon = {
      default = EntityId()
    },
    CharacterPane = {
      default = EntityId()
    },
    CharacterList = {
      default = EntityId()
    },
    CharacterListPane = {
      default = EntityId()
    },
    CreateCharacterButton = {
      default = EntityId()
    },
    StoreButtonHolder = {
      default = EntityId()
    },
    CharacterInfoCard = {
      default = EntityId()
    },
    CharacterInfoScrimHolder = {
      default = EntityId()
    },
    CharacterInfoElements = {
      default = EntityId()
    },
    CharacterInfoDividerLine1 = {
      default = EntityId()
    },
    CharacterInfoDividerLine2 = {
      default = EntityId()
    },
    CharacterInfoDividerLine3 = {
      default = EntityId()
    },
    PlayButton = {
      default = EntityId()
    },
    PlayButtonText = {
      default = EntityId()
    },
    DeleteButton = {
      default = EntityId()
    },
    WorldInfoCard = {
      default = EntityId()
    },
    WorldInfoPlayMessageTitle = {
      default = EntityId()
    },
    WorldInfoPlayMessage = {
      default = EntityId()
    },
    WorldInfoPlayDividerLine1 = {
      default = EntityId()
    },
    WorldInfoPlayDividerLine2 = {
      default = EntityId()
    },
    WorldDescriptionCard = {
      default = EntityId()
    },
    WorldPaneLearnMoreButton = {
      default = EntityId()
    },
    QueueInfo = {
      default = EntityId()
    },
    QueueDepth = {
      default = EntityId()
    },
    QueueTime = {
      default = EntityId()
    },
    QueueDepthBg = {
      default = EntityId()
    },
    QueueTimeBg = {
      default = EntityId()
    },
    GlobalMotdHolder = {
      default = EntityId()
    },
    GlobalMotdTitle = {
      default = EntityId()
    },
    GlobalMotdText = {
      default = EntityId()
    },
    NavMenuHolder = {
      default = EntityId()
    },
    NavButton1 = {
      default = EntityId()
    },
    NavButton2 = {
      default = EntityId()
    },
    NavButton3 = {
      default = EntityId()
    },
    NavButton4 = {
      default = EntityId()
    },
    TwitchLoginSection = {
      default = EntityId()
    },
    TwitchButton = {
      default = EntityId()
    },
    TwitchLogoutButton = {
      default = EntityId()
    },
    ClusterNotificationPopup = {
      Window = {
        default = EntityId()
      },
      PopupContainer = {
        default = EntityId()
      },
      Title = {
        default = EntityId()
      },
      Body = {
        default = EntityId()
      },
      PopupScrim = {
        default = EntityId()
      },
      PopupTitleLine = {
        default = EntityId()
      },
      PopupImage = {
        default = EntityId()
      },
      CancelButton = {
        default = EntityId()
      },
      AcceptButton = {
        default = EntityId()
      }
    },
    MergeInfoPopup = {
      Window = {
        default = EntityId()
      },
      PopupContainer = {
        default = EntityId()
      },
      Frame = {
        default = EntityId()
      },
      Faq = {
        default = EntityId()
      },
      PostMerge = {
        default = EntityId()
      },
      UpcomingMerge = {
        default = EntityId()
      },
      PopupScrim = {
        default = EntityId()
      },
      AcceptButton = {
        default = EntityId()
      },
      CloseButton = {
        default = EntityId()
      },
      LearnMoreButton = {
        default = EntityId()
      },
      TimeRemainingText = {
        default = EntityId()
      }
    },
    SupportOptions = {
      default = EntityId()
    }
  },
  notificationHandlers = {},
  popupQuitEventId = "ConfirmQuitPopup",
  popupDeleteEventId = "Popup_OnDeleteCharacter",
  popupErrorEventId = "Popup_ErrorMessage",
  characterEntityId = EntityId(),
  selectedWorldId = "",
  selectedCharacterId = "",
  selectedWorldIndex = -1,
  selectedCharacterIndex = -1,
  selectedRegionId = 0,
  selectedServerButtonTable = nil,
  characterList = {},
  currentCharacterList = {},
  worldList = {},
  worldCMSList = {},
  worldDataList = {},
  worldSetImageId = {},
  SORT_BYNONE = 0,
  SORT_BYNAME_ASC = 1,
  SORT_BYNAME_DESC = 2,
  SORT_BYLASTPLAYED_ASC = 3,
  SORT_BYLASTPLAYED_DESC = 4,
  SORT_BYPOPULATION_ASC = 5,
  SORT_BYPOPULATION_DESC = 6,
  POPULATION_LOW = 0,
  POPULATION_MED = 1,
  POPULATION_HIGH = 2,
  sortType = 0,
  pingImageTable = {},
  worldListReady = false,
  characterListReady = false,
  worldHasCapacity = false,
  authSuccess = false,
  shown = false,
  worldListRefresh = false,
  renamePopupShown = false,
  maxCharactersPerRegion = 3,
  tickBusHandler = nil,
  worldZ = 0,
  hiddenWorldZ = -1000,
  CREATE_FAKE_DATA = false,
  FAKE_WORLD_COUNT = 40,
  STATE_NONE = 0,
  STATE_CONNECTING_TO_SERVICE = 1,
  STATE_CONNECTING_TO_GAME = 2,
  currentState = 0,
  CONNECTION_TIMER_DURATION = 60,
  connectionTimer = 60,
  autoRefreshTimerDuration = 60,
  autoRefreshTimerDurationAfterError = 10,
  autorefreshTimer = 60,
  REFRESH_TIMER_DURATION = 2,
  refreshTimer = 0,
  ftueFlow = false,
  MERGE_POPUP_FAQ = 0,
  MERGE_POPUP_WARNING = 1,
  MERGE_POPUP_POSTMERGE = 2,
  MERGE_POPUP_RETURN_MAIN = 0,
  MERGE_POPUP_RETURN_WARNING = 1,
  POPUP_LARGE_WIDTH = 1400,
  POPUP_SMALL_WIDTH = 800,
  POPUP_LARGE_BUTTON_POS = 500,
  POPUP_SMALL_BUTTON_POS = 0,
  INFO_STATE_NO_CHARACTER = 0,
  INFO_STATE_ONE_CHARACTER_ALLOWED = 1,
  INFO_STATE_MULTI_CHARACTER_ALLOWED = 2,
  INFO_STATE_RESTRICTED_CHARACTER_WORLD = 3,
  INFO_STATE_MAX_CHARACTERS_REACHED = 4,
  returnDestination = 0,
  mergeTime = nil,
  pendingWorldMergeList = {},
  hasShownMergeWarning = false,
  showMetrics = false,
  queuePopupVisible = false,
  enableButtons = true,
  clusterNotificationImagePathRoot = "lyshineui/images/landingscreen/serverimage/serverImageLarge"
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(LandingScreen)
local bitHelpers = RequireScript("LyShineUI._Common.BitwiseHelpers")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function LandingScreen:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(UiMainMenuBus)
  self:BusConnect(UiCharacterServiceNotificationBus)
  self:BusConnect(UiLoginScreenNotificationBus)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self:SetVisualElements()
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterInfoCard, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterPane, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.WorldInfoCard, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.FailedConnectionEntity, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerTableHeader, false)
  self.authSuccess = GameRequestsBus.Broadcast.IsAuthorized()
  table.insert(self.pingImageTable, {
    ping = 200,
    image = "lyshineui/images/icons/misc/icon_connection_1.png"
  })
  table.insert(self.pingImageTable, {
    ping = 100,
    image = "lyshineui/images/icons/misc/icon_connection_2.png"
  })
  table.insert(self.pingImageTable, {
    ping = 50,
    image = "lyshineui/images/icons/misc/icon_connection_3.png"
  })
  table.insert(self.pingImageTable, {
    ping = 0,
    image = "lyshineui/images/icons/misc/icon_connection_4.png"
  })
  self.sortButtons = {
    {
      button = self.ServerSortNameButton,
      sort = "NAME"
    },
    {
      button = self.ServerSortLastPlayedButton,
      sort = "LASTPLAYED"
    },
    {
      button = self.ServerSortPopulationButton,
      sort = "POPULATION"
    }
  }
  self.ServerSortNameButton:SetCallback(self.OnSortButtonClicked, self)
  self.ServerSortNameButton:SetText("@ui_servername")
  self.ServerSortLastPlayedButton:SetCallback(self.OnSortButtonClicked, self)
  self.ServerSortLastPlayedButton:SetText("@ui_lastplayed")
  self.ServerSortPopulationButton:SetCallback(self.OnSortButtonClicked, self)
  self.ServerSortPopulationButton:SetText("@ui_population")
  self.sortType = self.SORT_BYNONE
  self.ServerSortNameButton:SetDeselected()
  self.ServerSortPopulationButton:SetDeselected()
  self.ServerSortLastPlayedButton:SetDeselected()
  local defaultRegions = {}
  self.ServerRegionDropdown:SetDropdownListHeightByRows(#defaultRegions)
  self.ServerRegionDropdown:SetListData(defaultRegions)
  self.ServerRegionDropdown:SetText("")
  self.ServerRegionDropdown:SetListBgAlpha(1)
  UiElementBus.Event.SetIsEnabled(self.Properties.GlobalMotdHolder, false)
  self.ClusterNotificationPopup.CancelButton:SetCallback(self.OnClusterPopupCancel, self)
  self.ClusterNotificationPopup.CancelButton:SetText("@ui_clusterwarning_cancel")
  self.ClusterNotificationPopup.AcceptButton:SetCallback(self.OnClusterPopupAccept, self)
  self.ClusterNotificationPopup.AcceptButton:SetButtonStyle(self.ClusterNotificationPopup.AcceptButton.BUTTON_STYLE_CTA)
  self.ClusterNotificationPopup.AcceptButton:SetText("@ui_clusterwarning_accept")
  self.MergeInfoPopup.LearnMoreButton:SetCallback(self.OnMergeLearnMoreClicked, self)
  self.MergeInfoPopup.LearnMoreButton:SetText("@ui_mergewarning_learn")
  self.MergeInfoPopup.CloseButton:SetCallback(self.OnMergeCloseClicked, self)
  self.MergeInfoPopup.CloseButton:SetButtonStyle(self.MergeInfoPopup.CloseButton.BUTTON_STYLE_REGULAR)
  self.MergeInfoPopup.AcceptButton:SetCallback(self.OnMergeCloseClicked, self)
  self.MergeInfoPopup.AcceptButton:SetButtonStyle(self.ClusterNotificationPopup.AcceptButton.BUTTON_STYLE_CTA)
  self.MergeInfoPopup.AcceptButton:SetText("@ui_ok")
  self.WorldPaneLearnMoreButton:SetCallback(self.OnWorldPaneLearnMoreClicked, self)
  self.WorldPaneLearnMoreButton:SetText("@ui_mergewarning_learn")
  UiElementBus.Event.SetIsEnabled(self.Properties.WorldPaneLearnMoreButton, false)
  self.dataLayer:RegisterOpenEvent("LandingScreen", self.canvasId)
  if self.Properties.StatusSpinnerEntity:IsValid() then
    self.ScriptedEntityTweener:StartAnimation({
      id = self.Properties.StatusSpinnerEntity,
      duration = 1,
      opacity = 1,
      timesToPlay = -1,
      rotation = 359
    })
  end
  if self.Properties.WorldSpinnerEntity:IsValid() then
    self.ScriptedEntityTweener:StartAnimation({
      id = self.Properties.WorldSpinnerEntity,
      duration = 1,
      opacity = 1,
      timesToPlay = -1,
      rotation = 359
    })
  end
  self:OnConfigChanged()
  self:BusConnect(ConfigSystemEventBus)
  UiMainMenuRequestBus.Broadcast.RequestCustomizableCharacterEntityId()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableRegionSelect", function(self, enableRegionSelect)
    UiElementBus.Event.SetIsEnabled(self.Properties.ServerRegionDropdown, enableRegionSelect)
    UiElementBus.Event.SetIsEnabled(self.Properties.ServerRegionText, enableRegionSelect)
    UiElementBus.Event.SetIsEnabled(self.Properties.ServerDividerLine1, enableRegionSelect)
  end)
  self.autorefreshTimer = self.autoRefreshTimerDuration
  local ftue = FtueSystemRequestBus.Broadcast.IsFtue()
  local isFirstRun = GameRequestsBus.Broadcast.IsFirstRun()
  if not isFirstRun and not ftue and not self.ftueFlow then
    self.audioHelper:PlaySound(self.audioHelper.Set_State_MX_Main_Return)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableTwitchSystem", function(self, twitchEnabled)
    if twitchEnabled then
      if not self.twitchHandler then
        self.twitchHandler = self:BusConnect(TwitchSystemNotificationBus)
      end
      local isLoggedIn = TwitchSystemRequestBus.Broadcast.IsLoggedIn()
      self:OnLoginStateChangedScript(isLoggedIn)
    elseif self.twitchHandler then
      self:BusDisconnect(self.twitchHandler)
      self.twitchHandler = nil
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchLoginSection, twitchEnabled)
  end)
  local hasErroredOnce = false
  local errorPopupIsOpen = false
  local timeSinceLastError = WallClockTimePoint:Now()
  self.dataLayer:RegisterDataCallback(self, "MainMenu.LastError", function(self, errorMessage)
    if errorMessage then
      local currentTime = WallClockTimePoint:Now()
      local minTimeBetweenErrors = timeHelpers.secondsInMinute
      if not hasErroredOnce or minTimeBetweenErrors < currentTime:Subtract(timeSinceLastError):ToSeconds() then
        timeSinceLastError = currentTime
        hasErroredOnce = true
        errorPopupIsOpen = true
        PopupWrapper:RequestPopup(ePopupButtons_OK, "@mm_connectionfailed", errorMessage, "connectionError", self, function(self, result, eventId)
          if eventId == "connectionError" then
            errorPopupIsOpen = false
            local delayError = false
            self:ResetScreenAfterError(delayError)
          end
        end)
      elseif not errorPopupIsOpen then
        local delayError = true
        self:ResetScreenAfterError(delayError)
      end
    end
  end)
end
function LandingScreen:OnConfigChanged()
  BaseScreen.OnConfigChanged(self)
  local hideStore = not ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableMainMenuStore")
  UiElementBus.Event.SetIsEnabled(self.Properties.StoreButtonHolder, not hideStore)
  self.ftueFlow = ConfigProviderEventBus.Broadcast.GetBool("javelin.use-new-character-creation-flow")
  local prevUseWorldSetChecks = self.useWorldSetChecks
  local prevUseRegionCharacterLimit = self.useRegionCharacterLimit
  local prevAutoRefreshTimerDuration = self.autoRefreshTimerDuration
  self.useWorldSetChecks = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-world-set-restrictions")
  self.useRegionCharacterLimit = ConfigProviderEventBus.Broadcast.GetBool("javelin.use-regional-character-limit")
  self.autoRefreshTimerDuration = ConfigProviderEventBus.Broadcast.GetInt("UIFeatures.mm-server-refresh-time-s")
  if prevUseWorldSetChecks ~= self.useWorldSetChecks or prevUseRegionCharacterLimit ~= self.useRegionCharacterLimit or prevAutoRefreshTimerDuration ~= self.autoRefreshTimerDuration then
    self:RefreshWorldList()
  end
end
function LandingScreen:OnTick(deltaTime, timePoint)
  if self.ServerRegionDropdown.isShown then
    self.refreshTimer = self.REFRESH_TIMER_DURATION
  else
    self.refreshTimer = self.refreshTimer - deltaTime
    if self.refreshTimer < 0 then
      self.refreshTimer = self.REFRESH_TIMER_DURATION
      UiLoginScreenRequestBus.Broadcast.GetRegionList()
    end
  end
  if self.worldListReady and not self.worldListRefresh and not self.renamePopupShown then
    self.autorefreshTimer = self.autorefreshTimer - deltaTime
    if 0 > self.autorefreshTimer then
      self:AutoRefreshWorldList()
    end
  end
  if self.currentState == self.STATE_CONNECTING_TO_GAME then
    local loginState = GameRequestsBus.Broadcast.GetConnectionStatus()
    self:SetLoginState(loginState)
  elseif self.currentState == self.STATE_CONNECTING_TO_SERVICE then
    self.connectionTimer = self.connectionTimer - deltaTime
    if 0 > self.connectionTimer then
      self.currentState = self.STATE_NONE
      UiElementBus.Event.SetIsEnabled(self.Properties.FailedConnectionEntity, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.ServerLoadingText, false)
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.RefreshButton, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.RegionalCharacterCount, true)
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NavButton1, true)
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NavButton2, true)
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NavButton3, true)
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NavButton4, true)
      UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ServerRegionDropdown, true)
    end
  elseif self.mergeTime ~= nil then
    local now = os.time()
    local timeRemainingSeconds = self.mergeTime - now
    if 0 < timeRemainingSeconds then
      local timeUntilMergeText = timeHelpers:ConvertToShorthandString(timeRemainingSeconds, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.MergeInfoPopup.TimeRemainingText, timeUntilMergeText, eUiTextSet_SetLocalized)
    else
      self.mergeTime = nil
      self.returnDestination = self.MERGE_POPUP_RETURN_MAIN
      if self.mergePopupType == self.MERGE_POPUP_WARNING then
        self:SetMergeInfoPopupVisible(false)
      end
    end
  end
end
function LandingScreen:AutoRefreshWorldList()
  self.autorefreshTimer = self.autoRefreshTimerDuration
  self.worldListReady = false
  self.worldListRefresh = true
  self.characterListReady = false
  UiLoginScreenRequestBus.Broadcast.GetLoginInfoLists(false)
end
function LandingScreen:SetVisualElements()
  local ServerRegionTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 22,
    fontColor = self.UIStyle.COLOR_TAN,
    characterSpacing = 200
  }
  local ServerCountTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 22,
    fontColor = self.UIStyle.COLOR_TAN,
    characterSpacing = 200
  }
  SetTextStyle(self.ServerRegionText, ServerRegionTextStyle)
  SetTextStyle(self.ServerCountText, ServerCountTextStyle)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ServerRegionText, "@ui_serverselectiontitle", eUiTextSet_SetLocalized)
  self.ServerDividerLine1:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.ServerDividerLine2:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.ServerDividerLine3:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.ServerDividerLine1:SetVisible(true)
  self.ServerDividerLine2:SetVisible(true)
  self.ServerDividerLine3:SetVisible(true)
  self.CharacterInfoDividerLine1:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.CharacterInfoDividerLine2:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.CharacterInfoDividerLine3:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.CharacterInfoDividerLine1:SetVisible(true)
  self.CharacterInfoDividerLine2:SetVisible(true)
  self.CharacterInfoDividerLine3:SetVisible(true)
  self.WorldInfoPlayDividerLine1:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.WorldInfoPlayDividerLine2:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.WorldInfoPlayDividerLine1:SetVisible(true)
  self.WorldInfoPlayDividerLine2:SetVisible(true)
  self.ClusterNotificationPopup.PopupTitleLine:SetColor(self.UIStyle.COLOR_TAN_LIGHT)
  self.ClusterNotificationPopup.PopupTitleLine:SetVisible(true)
  self.CreateCharacterButton:SetText("@ui_play")
  self.CreateCharacterButton:SetCallback("LandingCreate", self)
  self.CreateCharacterButton:SetButtonStyle(self.CreateCharacterButton.BUTTON_STYLE_HERO)
  self.CreateCharacterButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnCreateCharacterHover)
  self.CreateCharacterButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnCreateCharacterBeginPress)
  self.PlayButton:SetText("")
  self.PlayButton:SetCallback(self.LandingPlay, self)
  self.PlayButton:SetButtonStyle(self.PlayButton.BUTTON_STYLE_HERO)
  self.PlayButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnPlayHover)
  self.PlayButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnPlayPress)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@ui_play", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.PlayButtonText, self.UIStyle.FONT_STYLE_BUTTON_HERO)
  self.DeleteButton:SetText("@ui_deletecharacter")
  self.DeleteButton:SetCallback("LandingDelete", self)
  self.DeleteButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnDeleteCharacterHover)
  self.DeleteButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnDeleteCharacterPress)
  local enableBenchmark = self.dataLayer:GetDataFromNode("UIFeatures.g_enableBenchmark")
  local navButtonData
  if enableBenchmark then
    navButtonData = {
      {
        entityId = self.NavButton1,
        text = "",
        tooltip = "@ui_navmenu_settings",
        iconPath = "lyshineui/images/navbar/iconsettingsWhite.png",
        callback = self.LandingOptions
      },
      {
        entityId = self.NavButton2,
        text = "",
        tooltip = "@ui_navmenu_support",
        iconPath = "lyshineui/images/navbar/iconContactWhite.png",
        callback = self.OnSupportPressed
      },
      {
        entityId = self.NavButton3,
        text = "",
        tooltip = "@ui_navmenu_benchmark",
        iconPath = "lyshineui/images/navbar/iconbenchmarkWhite.png",
        callback = self.LandingBenchmark
      },
      {
        entityId = self.NavButton4,
        text = "",
        tooltip = "@ui_navmenu_quit",
        iconPath = "lyshineui/images/navbar/iconexitWhite.png",
        callback = self.LandingExit
      }
    }
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.NavButton1, false)
    navButtonData = {
      {
        entityId = self.NavButton2,
        text = "",
        tooltip = "@ui_navmenu_settings",
        iconPath = "lyshineui/images/navbar/iconsettingsWhite.png",
        callback = self.LandingOptions
      },
      {
        entityId = self.NavButton3,
        text = "",
        tooltip = "@ui_navmenu_support",
        iconPath = "lyshineui/images/navbar/iconContactWhite.png",
        callback = self.OnSupportPressed
      },
      {
        entityId = self.NavButton4,
        text = "",
        tooltip = "@ui_navmenu_quit",
        iconPath = "lyshineui/images/navbar/iconexitWhite.png",
        callback = self.LandingExit
      }
    }
  end
  for i = 1, #navButtonData do
    local currentNavData = navButtonData[i]
    local currentNavButton = currentNavData.entityId
    currentNavButton:SetTooltip(currentNavData.tooltip)
    currentNavButton:SetButtonStyle(currentNavButton.BUTTON_STYLE_NAV_BUTTON)
    currentNavButton:SetBackgroundPathname(currentNavData.iconPath)
    currentNavButton:SetCallback(currentNavData.callback, self)
  end
  local twitchButtonData = {
    {
      entityId = self.TwitchLogoutButton,
      text = "",
      tooltip = "@ui_twitch_logout_tooltip",
      iconPath = "lyshineui/images/icons/twitch/iconTwitchWhite.png",
      callback = "OnTwitchLogoutPress",
      visible = false
    },
    {
      entityId = self.TwitchButton,
      text = "@ui_twitch_login_button",
      tooltip = "@ui_twitch_login_tooltip",
      iconPath = "lyshineui/images/icons/twitch/iconTwitchWhite.png",
      callback = "OnTwitchPress",
      visible = true
    }
  }
  for i = 1, #twitchButtonData do
    local currentButtonData = twitchButtonData[i]
    local currentTwitchButton = currentButtonData.entityId
    currentTwitchButton:SetText(currentButtonData.text, false, false)
    currentTwitchButton:SetTooltip(currentButtonData.tooltip)
    currentTwitchButton:SetTextColor(self.UIStyle.COLOR_WHITE, 0)
    currentTwitchButton:SetButtonSingleIconPath(currentButtonData.iconPath)
    currentTwitchButton:SetCallback(currentButtonData.callback, self)
    UiElementBus.Event.SetIsEnabled(currentTwitchButton.entityId, currentButtonData.visible)
  end
  local supportOptions = self.registrar:GetEntityTable(self.Properties.SupportOptions)
  supportOptions:RemoveFeedbackButton()
  local dropdownTable = self.registrar:GetEntityTable(self.Properties.ServerRegionDropdown)
  if dropdownTable then
    dropdownTable:SetDropdownScreenCanvasId(self.Properties.ServerRegionDropdown)
    dropdownTable:SetCallback("OnRegionDropdownSelected", self)
  end
end
function LandingScreen:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.Properties.ScreenHolder, self.canvasId)
    AdjustElementToCanvasSize(self.Properties.ClusterNotificationPopup.Window, self.canvasId)
    AdjustElementToCanvasSize(self.Properties.MergeInfoPopup.Window, self.canvasId)
    AdjustElementToCanvasWidth(self.Properties.NavMenuHolder, self.canvasId)
    AdjustElementToCanvasHeight(self.Properties.ServerPane, self.canvasId)
    AdjustElementToCanvasHeight(self.Properties.CharacterListPane, self.canvasId)
    AdjustElementToCanvasHeight(self.Properties.CharacterPane, self.canvasId)
    AdjustElementToCanvasHeight(self.Properties.WorldInfoCard, self.canvasId)
    AdjustElementToCanvasHeight(self.Properties.CharacterInfoCard, self.canvasId)
    AdjustElementToCanvasHeight(self.Properties.CharacterInfoScrimHolder, self.canvasId)
  end
end
function LandingScreen:OnShutdown()
  BaseScreen.OnShutdown(self)
  timingUtils:StopDelay(self)
end
function LandingScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.playButtonClicked = false
  self.currentState = self.STATE_NONE
  self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  self:BeginConnection()
  UiElementBus.Event.SetIsEnabled(self.Properties.Black, true)
  self.ScriptedEntityTweener:Play(self.Properties.Black, 1, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.2,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.Black, false)
    end
  })
  self.CreateCharacterButton:StartStopImageSequence(true)
  self.PlayButton:StartStopImageSequence(true)
end
function LandingScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.playButtonClicked = false
  self.shown = false
  self:BusDisconnect(self.tickHandler)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self.CreateCharacterButton:StartStopImageSequence(false)
  self.PlayButton:StartStopImageSequence(false)
end
function LandingScreen:OnRefreshFocus()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonBg, 0.2, {opacity = 0.3, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.OnHover_LandingScreen)
end
function LandingScreen:OnRefreshUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonBg, 0.2, {opacity = 0.1, ease = "QuadOut"})
end
function LandingScreen:OnRefreshServerPress()
  self:BeginConnection()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonIcon, 0.38, {rotation = 0}, {timesToPlay = 1, rotation = 359})
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnRefreshServerPress)
end
function LandingScreen:OnTwitchFocus()
  self.TwitchButton.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  self.ScriptedEntityTweener:Play(self.TwitchButton.Properties.ButtonBg, 0.2, {
    imgColor = self.UIStyle.COLOR_TWITCH_PURPLE_LIGHT,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_LandingScreen)
end
function LandingScreen:OnTwitchLogoutFocus()
  self.TwitchLogoutButton.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  self.ScriptedEntityTweener:Play(self.TwitchLogoutButton.Properties.ButtonBg, 0.2, {
    imgColor = self.UIStyle.COLOR_TWITCH_PURPLE_LIGHT,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_LandingScreen)
end
function LandingScreen:OnTwitchUnfocus()
  self.TwitchButton.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  self.ScriptedEntityTweener:Play(self.TwitchButton.ButtonBg, 0.2, {
    imgColor = self.UIStyle.COLOR_TWITCH_PURPLE,
    ease = "QuadOut"
  })
end
function LandingScreen:OnTwitchLogoutUnfocus()
  self.TwitchLogoutButton.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  self.ScriptedEntityTweener:Play(self.TwitchLogoutButton.ButtonBg, 0.2, {
    imgColor = self.UIStyle.COLOR_TWITCH_PURPLE,
    ease = "QuadOut"
  })
end
function LandingScreen:OnTwitchPress()
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  TwitchSystemRequestBus.Broadcast.StartTwitchLogin(true)
end
function LandingScreen:OnTwitchLogoutPress()
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  TwitchSystemRequestBus.Broadcast.Logout()
end
function LandingScreen:OnLoginStateChangedScript(isLoggedIn)
  if isLoggedIn then
    local twitchDisplayName = TwitchSystemRequestBus.Broadcast.GetTwitchDisplayName()
    self.TwitchLogoutButton:SetText(twitchDisplayName, true, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchLogoutButton, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchButton, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchLogoutButton, false)
    self.TwitchLogoutButton:SetText("", true, false)
  end
end
function LandingScreen:BeginConnection()
  self.currentState = self.STATE_CONNECTING_TO_SERVICE
  self.connectionTimer = self.CONNECTION_TIMER_DURATION
  self.refreshTimer = self.REFRESH_TIMER_DURATION
  self.autoRefreshTimer = self.autoRefreshTimerDuration
  self.worldListRefresh = false
  self:SetLoginState(ELumberyardState.Disconnected)
  self:EnableButtons(false)
  self:ShowCharacter(false)
  self:SetWorldInfoVisible(false)
  self:SetCharacterPaneVisible(false)
  self.shown = true
  if self.authSuccess then
    self:RefreshWorldList()
  end
  self:ShowServerLoadingSpinner()
end
function LandingScreen:ShowServerLoadingSpinner()
  self.ScriptedEntityTweener:Play(self.Properties.ServerContentBoxHolder, 0.3, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ServerLoadingText, 0.3, {opacity = 1, ease = "QuadOut"})
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerTableHeader, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerLoadingText, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.FailedConnectionEntity, false)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.RefreshButton, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RegionalCharacterCount, false)
end
function LandingScreen:LandingOptions()
  LyShineManagerBus.Broadcast.SetState(2717041095)
end
function LandingScreen:LandingBenchmark()
  self:EnableButtons(false)
  UiMainMenuRequestBus.Broadcast.StartBenchmark()
end
function LandingScreen:LandingExit()
  self.StoreButtonHolder:OnSetVisible(false)
  self.audioHelper:PlaySound(self.audioHelper.Cancel)
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, self.Properties.QuitPopupTitle, self.Properties.QuitPopupText, self.popupQuitEventId, self, self.OnPopupResult)
end
function LandingScreen:OnSupportPressed()
  local supportOptions = self.registrar:GetEntityTable(self.Properties.SupportOptions)
  supportOptions:SetVisible(true)
end
function LandingScreen:OnHoverStart(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.OnHover_LandingScreen)
end
function LandingScreen:LandingServerSelect(entityId, actionName)
  self.audioHelper:PlaySound(self.audioHelper.Play)
end
function LandingScreen:LandingPlay(entityId, actionName)
  self.playButtonClicked = true
  self.PlayButton:SetButtonStyle(self.PlayButton.BUTTON_STYLE_DEFAULT)
  self.PlayButton:SetEnabled(false)
  local currentCharacterData = self.currentCharacterList[self.selectedCharacterIndex]
  if currentCharacterData and self.shown and currentCharacterData.mustRename then
    self.renamePopupShown = true
    DynamicBus.RenamePopupBus.Broadcast.SetCallback("OnCharacterRename", self)
    DynamicBus.RenamePopupBus.Broadcast.OpenPopup(true, currentCharacterData.name, self.selectedCharacterId)
    return
  end
  self:EnableButtons(false)
  UiMainMenuRequestBus.Broadcast.ShowLoadingScreen()
  local worldType = "OpenWorld"
  if not self.currentCharacterList[self.selectedCharacterIndex].ftueCompleted then
    worldType = "FTUE"
  end
  GameRequestsBus.Broadcast.RequestLogin(self.selectedCharacterId, worldType)
  self.currentState = self.STATE_CONNECTING_TO_GAME
  if self.selectedWorldIndex > 0 and self.selectedWorldIndex <= #self.worldList then
    local name = self.worldList[self.selectedWorldIndex].worldData.name
    if name then
      LyShineManagerBus.Broadcast.SetWorldName(name)
    end
  end
end
function LandingScreen:LandingCreate(entityId, actionName)
  if self.ftueFlow then
    if not self.useWorldSetChecks or self.worldList[self.selectedWorldIndex].worldData.worldSet == "StubbedWorldSet" then
      self:StartIntro()
    else
      local titleText = GetLocalizedReplacementText("@ui_clusterwarning_title", {
        worldName = self.worldList[self.selectedWorldIndex].worldData.name
      })
      local bodyText = GetLocalizedReplacementText("@ui_clusterwarning_body", {
        worldName = self.worldList[self.selectedWorldIndex].worldData.name,
        worldSetName = self.worldList[self.selectedWorldIndex].worldSetName
      })
      UiTextBus.Event.SetTextWithFlags(self.Properties.ClusterNotificationPopup.Title, titleText, eUiTextSet_SetAsIs)
      UiTextBus.Event.SetTextWithFlags(self.Properties.ClusterNotificationPopup.Body, bodyText, eUiTextSet_SetAsIs)
      local imagePath = self.clusterNotificationImagePathRoot .. self.worldList[self.selectedWorldIndex].imageId .. ".dds"
      UiImageBus.Event.SetSpritePathname(self.Properties.ClusterNotificationPopup.PopupImage, imagePath)
      self:SetClusterNotificationPopupVisible(true)
    end
  else
    LyShineManagerBus.Broadcast.SetState(4065059436)
  end
end
function LandingScreen:StartIntro()
  self:EnableButtons(false)
  local name = self.worldList[self.selectedWorldIndex].worldData.name
  if name then
    LyShineManagerBus.Broadcast.SetWorldName(name)
  end
  UiMainMenuRequestBus.Broadcast.StartIntro()
end
function LandingScreen:LandingDelete(entityId, actionName)
  self:EnableButtons(false)
  if self.selectedCharacterIndex > 0 then
    local currentCharacterData = self.currentCharacterList[self.selectedCharacterIndex]
    if currentCharacterData then
      local event = UiAnalyticsEvent("DeleteCharacter")
      event:AddAttribute("character_id", currentCharacterData.characterId)
      event:AddAttribute("player", currentCharacterData.name)
      event:AddAttribute("world_id", currentCharacterData.worldId)
      event:Send()
    end
  end
  PopupWrapper:RequestPopup(ePopupButtons_YesNo, self.Properties.DeletePopupTitle, self.Properties.DeletePopupText, self.popupDeleteEventId, self, self.OnPopupResult)
end
function LandingScreen:PopulateWorldSelectionList(entityId, actionName)
  self.pendingWorldMergeList = UiLoginScreenRequestBus.Broadcast.GetPendingWorldMergeList()
  local childList = UiElementBus.Event.GetChildren(self.Properties.ServerList)
  for i = 1, #childList do
    local isVisible = i <= #self.worldList
    UiElementBus.Event.SetIsEnabled(childList[i], isVisible)
    if isVisible then
      local entity = Entity(childList[i])
      entity:SetName(self.worldList[i].worldData.worldId)
      local worldInfoBox = self.registrar:GetEntityTable(childList[i])
      worldInfoBox:SetWorldInfo(self.worldList[i])
    end
  end
  local spacing = UiLayoutColumnBus.Event.GetSpacing(self.Properties.ServerList)
  spacing = spacing * #self.worldList
  local offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.ServerList)
  offsets.bottom = offsets.top + spacing
  UiTransform2dBus.Event.SetOffsets(self.Properties.ServerList, offsets)
  self.selectedWorldIndex = self:GetWorldIndex(landingCommon.lastPlayerSelectedWorldId)
  if 1 > self.selectedWorldIndex or self.selectedWorldIndex > #self.worldList then
    self.selectedWorldIndex = 1
  end
  UiRadioButtonGroupBus.Event.SetAllowUncheck(self.Properties.ServerList, true)
  local selectedButton = UiRadioButtonGroupBus.Event.GetState(self.Properties.ServerList)
  local selectedButtonEntityTable = self.registrar:GetEntityTable(selectedButton)
  if selectedButton:IsValid() then
    UiRadioButtonGroupBus.Event.SetState(self.Properties.ServerList, selectedButton, false)
    selectedButtonEntityTable:OnUnfocus()
  end
  UiRadioButtonGroupBus.Event.SetAllowUncheck(self.Properties.ServerList, false)
  local selectedEntityId = UiElementBus.Event.GetChild(self.Properties.ServerList, self.selectedWorldIndex - 1)
  local isHandlingEvents = true
  if selectedEntityId:IsValid() and #self.worldList > 0 then
    isHandlingEvents = UiInteractableBus.Event.IsHandlingEvents(selectedEntityId)
    if isHandlingEvents then
      UiRadioButtonGroupBus.Event.SetState(self.Properties.ServerList, selectedEntityId, true)
      self:SelectServer(selectedEntityId)
    end
  end
  if not isHandlingEvents then
    local childList = UiElementBus.Event.GetChildren(self.Properties.ServerList)
    for i = 1, #childList do
      isHandlingEvents = UiInteractableBus.Event.IsHandlingEvents(childList[i])
      if isHandlingEvents then
        UiRadioButtonGroupBus.Event.SetState(self.Properties.ServerList, childList[i], true)
        self:SelectServer(childList[1])
        break
      end
    end
  end
  if not isHandlingEvents then
    self.selectedWorldIndex = 0
    self:CheckCharacterVisibility()
  end
  if not self.hasShownMergeWarning and self:HasRecentlyMergedCharacter() then
    self.hasShownMergeWarning = true
    self:OpenMergePopup(self.MERGE_POPUP_POSTMERGE, self.MERGE_POPUP_RETURN_MAIN)
  end
  if not self.hasShownMergeWarning then
    for i = 1, #self.pendingWorldMergeList do
      if self:HasCharacterOnWorld(self.pendingWorldMergeList[i].sourceWorldId) then
        self.hasShownMergeWarning = true
        self.mergeTime = self:ParseDate(self.pendingWorldMergeList[i].mergeTime)
        self:OpenMergePopup(self.MERGE_POPUP_WARNING, self.MERGE_POPUP_RETURN_MAIN)
        break
      end
    end
  end
end
function LandingScreen:PopulateCharacterSelectionList(worldId)
  local isCharacterPaneAvailable = #self.worldList > 0
  self:SetCharacterPaneVisible(isCharacterPaneAvailable)
  local hasShownCreate = false
  local maxCharacterCount = 1
  local selectedWorldSet
  if 0 < self.selectedWorldIndex and self.selectedWorldIndex <= #self.worldList then
    maxCharacterCount = self.worldList[self.selectedWorldIndex].worldData.maxAccountCharacters
    selectedWorldSet = self.worldList[self.selectedWorldIndex].worldData.worldSet
  end
  local isLocalServer = selectedWorldSet == "StubbedWorldSet"
  if not isLocalServer and maxCharacterCount > self.maxCharactersPerRegion then
    maxCharacterCount = self.maxCharactersPerRegion
  end
  local numWorldCharacters = 0
  local numWorldSetCharacters = 0
  local alternateCharacterWorldName = ""
  if self.useWorldSetChecks then
    for i = 1, #self.characterList do
      if self.characterList[i].worldId == worldId then
        numWorldCharacters = numWorldCharacters + 1
      end
      for j = 1, #self.worldList do
        if self.worldList[j].worldData.worldId == self.characterList[i].worldId and self.worldList[j].worldData.worldSet == selectedWorldSet then
          if self.worldList[j].worldData.worldId ~= worldId then
            alternateCharacterWorldName = self.worldList[j].worldData.name
          end
          numWorldSetCharacters = numWorldSetCharacters + 1
        end
      end
    end
  end
  local countText = GetLocalizedReplacementText("@ui_region_character_count", {
    numCharacter = #self.characterList,
    maxCharacter = self.maxCharactersPerRegion
  })
  local tooltipText = GetLocalizedReplacementText("@ui_region_character_tooltip", {
    numCharacter = #self.characterList,
    maxCharacter = self.maxCharactersPerRegion
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.RegionalCharacterCount, countText, eUiTextSet_SetAsIs)
  self.RegionalCharacterCountTooltip:SetSimpleTooltip(tooltipText)
  local showAllDebugCharacters = LyShineScriptBindRequestBus.Broadcast.GetCVar("sys_DeactivateConsole") == 0
  local characterEntry
  self.currentCharacterList = {}
  for i = 1, #self.characterList do
    if self.characterList[i].worldId == worldId then
      characterEntry = UiElementBus.Event.GetChild(self.Properties.CharacterList, #self.currentCharacterList)
      if not (not showAllDebugCharacters or characterEntry) or not characterEntry:IsValid() then
        local prototype = UiElementBus.Event.GetChild(self.Properties.CharacterList, 0)
        characterEntry = self:CloneElement(prototype, self.Properties.CharacterList, true).entityId
        local yPos = UiTransformBus.Event.GetLocalPositionY(prototype)
        local height = UiTransform2dBus.Event.GetLocalHeight(prototype)
        UiTransformBus.Event.SetLocalPositionY(characterEntry, yPos + (height + 5) * #self.currentCharacterList)
      end
      UiElementBus.Event.SetIsEnabled(characterEntry, true)
      local charInfoBox = self.registrar:GetEntityTable(characterEntry)
      charInfoBox:SetSlotStatus(charInfoBox.CHARSTATUS_ACTIVE)
      charInfoBox:SetCharacterInfo(self.characterList[i].name, self.characterList[i].characterId, self.characterList[i].currentLevel)
      if self.characterList[i].guildId:IsValid() then
        charInfoBox:SetGuildCrest(self.characterList[i].crestData, true)
      else
        charInfoBox:SetGuildCrest(nil, true)
      end
      charInfoBox:SetPortrait(self.characterList[i].portraitData)
      if self.characterList[i].publishedSource == "CLIENT" then
        charInfoBox:SetLastPlayed(nil)
      else
        charInfoBox:SetLastPlayed(self.characterList[i].publishedElapsedSeconds)
      end
      self.currentCharacterList[#self.currentCharacterList + 1] = self.characterList[i]
      UiElementBus.Event.SetIsEnabled(characterEntry, true)
      if maxCharacterCount <= #self.currentCharacterList and not showAllDebugCharacters then
        break
      end
    end
  end
  local useRegionalLimits = self.useRegionCharacterLimit and not isLocalServer
  local hasNoCharacter = 1 > #self.currentCharacterList
  local maxRegionCharacters = useRegionalLimits and #self.characterList >= self.maxCharactersPerRegion and hasNoCharacter
  if maxRegionCharacters then
    self.ScriptedEntityTweener:Play(self.Properties.CreateCharacterBg, 0.3, {opacity = 0, ease = "QuadOut"})
    self:SetInformationState(self.INFO_STATE_MAX_CHARACTERS_REACHED)
  elseif hasNoCharacter then
    self.ScriptedEntityTweener:Play(self.Properties.CreateCharacterBg, 0.3, {opacity = 1, ease = "QuadOut"})
    self:SetInformationState(self.INFO_STATE_NO_CHARACTER)
  else
    self.ScriptedEntityTweener:Play(self.Properties.CreateCharacterBg, 0.3, {opacity = 0, ease = "QuadOut"})
    if 1 < maxCharacterCount then
      self:SetInformationState(self.INFO_STATE_MULTI_CHARACTER_ALLOWED)
    else
      self:SetInformationState(self.INFO_STATE_ONE_CHARACTER_ALLOWED)
    end
  end
  local isDebugClient = LyShineScriptBindRequestBus.Broadcast.IsDebugClient()
  local maintenanceBypass = LyShineScriptBindRequestBus.Broadcast.IsMaintenanceBypass()
  local isServerDown = false
  if self.selectedServerButtonTable ~= nil then
    isServerDown = self.selectedServerButtonTable:GetIsServerDown()
  end
  local canAccessServer = isDebugClient or maintenanceBypass or not isServerDown
  local withinCharacterLimits = maxCharacterCount > #self.currentCharacterList and (isLocalServer or numWorldCharacters == numWorldSetCharacters)
  local isCreateCharacterAvailable = withinCharacterLimits and canAccessServer and worldId ~= -1 and not maxRegionCharacters and not self.worldIsOnlineButUnavailable
  if numWorldCharacters == numWorldSetCharacters then
    if maxCharacterCount > #self.currentCharacterList then
      for i = #self.currentCharacterList + 1, maxCharacterCount do
        characterEntry = UiElementBus.Event.GetChild(self.Properties.CharacterList, i - 1)
        local charInfoBox = self.registrar:GetEntityTable(characterEntry)
        charInfoBox:SetCreateCharacterCallback("LandingCreate", self)
        if not hasShownCreate and isCreateCharacterAvailable then
          hasShownCreate = true
          charInfoBox:SetSlotStatus(charInfoBox.CHARSTATUS_CANCREATE)
        else
          charInfoBox:SetSlotStatus(charInfoBox.CHARSTATUS_INACTIVE)
        end
        UiElementBus.Event.SetIsEnabled(characterEntry, true)
      end
    end
    local childElements = UiElementBus.Event.GetChildren(self.Properties.CharacterList)
    local numToHide = math.max(1, maxCharacterCount + 1)
    if showAllDebugCharacters then
      numToHide = math.max(numToHide, #self.currentCharacterList + 1)
    end
    for i = numToHide, #childElements do
      local characterEntry = childElements[i]
      UiElementBus.Event.SetIsEnabled(characterEntry, false)
    end
    if 0 < #self.currentCharacterList then
      local index = 1
      if 0 < self.selectedCharacterIndex and self.selectedCharacterIndex <= #self.currentCharacterList then
        index = self.selectedCharacterIndex
      end
      local newCharacterId = self.dataLayer:GetDataFromNode("MainMenu.NewCharacterId")
      LyShineDataLayerBus.Broadcast.SetData("MainMenu.NewCharacterId", "")
      if newCharacterId and 0 < #newCharacterId then
        for i = 1, #self.currentCharacterList do
          if self.currentCharacterList[i].characterId == newCharacterId then
            index = i
            break
          end
        end
      end
      self:SelectCharacterByIndex(index)
    else
      self:ShowCharacter(false)
    end
  else
    local warningText = GetLocalizedReplacementText("@ui_clusterwarning_cannot_create", {
      worldName = alternateCharacterWorldName,
      worldSetName = self.worldList[self.selectedWorldIndex].worldSetName
    })
    self.clusterWarningMessage = warningText
    self:SetInformationState(self.INFO_STATE_RESTRICTED_CHARACTER_WORLD)
  end
end
function LandingScreen:PopulateWorldDescription(worldId)
  local now = os.time()
  UiElementBus.Event.SetIsEnabled(self.Properties.WorldPaneLearnMoreButton, now < self.worldList[self.selectedWorldIndex].mergeTime)
  if #self.worldCMSList.worldDescriptions > 0 then
    for i = 1, #self.worldCMSList.worldDescriptions do
      if self.worldCMSList.worldDescriptions[i].worldId == worldId then
        self.WorldDescriptionCard:SetWorldDescription(self.worldCMSList.worldDescriptions[i].name, self.worldCMSList.worldDescriptions[i].description, self.worldCMSList.worldDescriptions[i].motd, self.worldList[self.selectedWorldIndex])
        return
      end
    end
  end
  self.WorldDescriptionCard:SetWorldDescription(self.worldList[self.selectedWorldIndex].worldData.name, "", "", self.worldList[self.selectedWorldIndex])
end
function LandingScreen:ChangeServer(entityId, actionName)
  self:SelectServer(entityId, true)
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnServerSelectPress)
end
function LandingScreen:SelectServer(entityId, playerSelected)
  local selectedEntityId = UiRadioButtonGroupBus.Event.GetState(self.Properties.ServerList)
  if selectedEntityId:IsValid() and #self.worldList > 0 then
    self.selectedWorldIndex = UiElementBus.Event.GetIndexOfChildByEntityId(self.Properties.ServerList, selectedEntityId) + 1
    if 0 < self.selectedWorldIndex and self.selectedWorldIndex <= #self.worldList then
      self.selectedServerButtonTable = self.registrar:GetEntityTable(selectedEntityId)
      self.selectedServerButtonTable:OnSelected()
      self.selectedWorldId = self.worldList[self.selectedWorldIndex].worldData.worldId
      if playerSelected then
        landingCommon.lastPlayerSelectedWorldId = self.selectedWorldId
      end
      local queueSize = self.worldList[self.selectedWorldIndex].worldData.worldMetrics.queueSize
      local queueWaitTimeSec = self.worldList[self.selectedWorldIndex].worldData.worldMetrics.queueWaitTimeSec
      local isUnknownQueueWaitTime = queueWaitTimeSec <= 0
      self.showMetrics = 0 < queueSize or 0 < queueWaitTimeSec
      UiElementBus.Event.SetIsEnabled(self.Properties.QueueInfo, self.showMetrics and not self.queuePopupVisible)
      if self.showMetrics then
        local queueSize = GetLocalizedReplacementText("@ui_queue_depth", {numplayers = queueSize})
        local timeToWait
        if 0 < queueWaitTimeSec then
          timeToWait = timeHelpers:ConvertToShorthandString(queueWaitTimeSec, false, true)
        elseif isUnknownQueueWaitTime then
          timeToWait = "@ui_unknown"
        end
        local waitTime = GetLocalizedReplacementText("@ui_expected_wait_time", {time = timeToWait})
        UiTextBus.Event.SetTextWithFlags(self.Properties.QueueDepth, queueSize, eUiTextSet_SetAsIs)
        UiTextBus.Event.SetTextWithFlags(self.Properties.QueueTime, waitTime, eUiTextSet_SetAsIs)
        local queueDepthTextSize = UiTextBus.Event.GetTextSize(self.Properties.QueueDepth).x
        local queueDepthTextWidth = queueDepthTextSize + 100
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.QueueDepthBg, queueDepthTextWidth)
        local queueTimeTextSize = UiTextBus.Event.GetTextSize(self.Properties.QueueDepth).x
        local queueTimeTextWidth = queueTimeTextSize + 100
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.QueueTimeBg, queueTimeTextWidth)
      end
      UiLoginScreenRequestBus.Broadcast.SetSelectedWorldId(self.selectedWorldId)
      MainMenuSystemRequestBus.Broadcast.SetSelectedWorldId(self.selectedWorldId)
      self.worldHasCapacity = self.worldList[self.selectedWorldIndex].worldData.maxConnectionCount == 0 or self.worldList[self.selectedWorldIndex].worldData.connectionCount < self.worldList[self.selectedWorldIndex].worldData.maxConnectionCount
      self.worldIsOnlineButUnavailable = bitHelpers:TestFlag(self.worldList[self.selectedWorldIndex].worldData.publicStatusCode, bitHelpers.SERVERSTATUS_DOWNFORMAINTENANCE)
      self:EnableButtons(true)
      self:PopulateWorldDescription(self.selectedWorldId)
      self:PopulateCharacterSelectionList(self.selectedWorldId)
      self:CheckCharacterVisibility()
      self.StoreButtonHolder:OnSetVisible(true)
      self:SetWorldInfoVisible(true)
    end
  end
end
function LandingScreen:ChangeCharacter(entityId, actionName)
  self:SelectCharacter(entityId)
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnSelectCharacterPress)
end
function LandingScreen:SelectCharacter(entityId)
  local selectedEntityId = UiRadioButtonGroupBus.Event.GetState(self.Properties.CharacterList)
  if selectedEntityId:IsValid() then
    local selectedButtonTable = self.registrar:GetEntityTable(UiElementBus.Event.GetParent(selectedEntityId))
    if selectedButtonTable ~= nil then
      selectedButtonTable:OnSelected()
    end
    local characterInfoId = UiElementBus.Event.GetParent(selectedEntityId)
    self.selectedCharacterIndex = UiElementBus.Event.GetIndexOfChildByEntityId(self.Properties.CharacterList, characterInfoId) + 1
    timingUtils:StopDelay(self)
    self:ShowCharacter(false)
    if self.selectedCharacterIndex > 0 then
      timingUtils:Delay(0.25, self, function()
        self:ShowCharacter(true)
      end)
      local currentCharacterData = self.currentCharacterList[self.selectedCharacterIndex]
      self.selectedCharacterId = currentCharacterData.characterId
      UiLoginScreenRequestBus.Broadcast.SetVisibleCharacter(self.selectedCharacterId)
      local charInfoBox = self.registrar:GetEntityTable(self.Properties.CharacterInfoCard)
      charInfoBox:SetCharacterInfo(currentCharacterData.name, self.selectedCharacterId, currentCharacterData.currentLevel)
      charInfoBox:SetLastPlayed(currentCharacterData.publishedElapsedSeconds)
      if currentCharacterData.guildId:IsValid() then
        charInfoBox:SetGuildCrest(currentCharacterData.crestData, false)
      else
        charInfoBox:SetGuildCrest(nil, false)
      end
      charInfoBox:SetPortrait(currentCharacterData.portraitData)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Position", currentCharacterData.position)
    end
  end
  self:UpdatePlayButton()
end
function LandingScreen:UpdatePlayButton()
  local isServerDown = false
  if self.selectedServerButtonTable ~= nil then
    isServerDown = self.selectedServerButtonTable:GetIsServerDown()
  end
  local buttonEnabled = false
  local isDebugClient = LyShineScriptBindRequestBus.Broadcast.IsDebugClient()
  local maintenanceBypass = LyShineScriptBindRequestBus.Broadcast.IsMaintenanceBypass()
  if not self.playButtonClicked then
    self.PlayButton:SetButtonStyle(self.PlayButton.BUTTON_STYLE_HERO)
  end
  if isDebugClient or maintenanceBypass or not isServerDown then
    buttonEnabled = true
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@ui_play", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.PlayButtonText, self.UIStyle.COLOR_WHITE)
    self.PlayButton:SetEnabled(true)
  else
    buttonEnabled = false
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@mm_serverdown", eUiTextSet_SetLocalized)
    self.PlayButton:SetEnabled(false)
    UiTextBus.Event.SetColor(self.Properties.PlayButtonText, self.UIStyle.COLOR_YELLOW)
  end
  local isSpinnerEnabled = UiElementBus.Event.IsEnabled(self.Properties.StatusSpinnerEntity)
  if self.enableButtons and buttonEnabled and not isSpinnerEnabled then
    timingUtils:DelayFrames(10, self, function()
      self.PlayButton:SetEnabled(true)
      UiTextBus.Event.SetColor(self.Properties.PlayButtonText, self.UIStyle.COLOR_WHITE)
    end)
    self.PlayButton:SetEnabled(true)
    UiTextBus.Event.SetColor(self.Properties.PlayButtonText, self.UIStyle.COLOR_WHITE)
  else
    self.PlayButton:SetEnabled(false)
    UiTextBus.Event.SetColor(self.Properties.PlayButtonText, self.UIStyle.COLOR_GRAY_50)
  end
end
function LandingScreen:OnCharacterRename()
  self.characterListReady = false
  self.renamePopupShown = false
  self.selectedCharacterId = ""
  self.characterList = {}
  self.currentCharacterList = {}
  self:PopulateCharacterSelectionList(-1)
  UiLoginScreenRequestBus.Broadcast.GetLoginInfoLists(true)
  self:CheckCharacterVisibility()
end
function LandingScreen:GoToNewWorldWebsite()
  self.audioHelper:PlaySound(self.audioHelper.OnClick)
  OptionsDataBus.Broadcast.OpenNewWorldSiteInBrowser()
end
function LandingScreen:OnPopupResult(result, eventId)
  if eventId == self.popupQuitEventId then
    if result == ePopupResult_Yes then
      GameRequestsBus.Broadcast.RequestDisconnect(eExitGameDestination_Desktop)
    end
  elseif eventId == self.popupDeleteEventId then
    if self.selectedCharacterIndex > 0 then
      local currentCharacterData = self.currentCharacterList[self.selectedCharacterIndex]
      if currentCharacterData then
        local event = UiAnalyticsEvent("DeleteCharacterPopup")
        local confirmationValue = result == ePopupResult_Yes and 1 or 0
        event:AddAttribute("confirmation", confirmationValue)
        event:AddAttribute("character_id", currentCharacterData.characterId)
        event:AddAttribute("player", currentCharacterData.name)
        event:AddAttribute("world_id", currentCharacterData.worldId)
        event:Send()
      end
    end
    if result == ePopupResult_Yes then
      self.selectedCharacterIndex = -1
      UiCharacterServiceRequestBus.Broadcast.DeactivateCharacter(self.selectedCharacterId)
    else
      self:EnableButtons(true)
    end
  end
end
function LandingScreen:ResetScreenAfterError(delayRefresh)
  self:EnableSafeButtons(true)
  self:SetLoginState(ELumberyardState.Disconnected)
  self.currentState = self.STATE_NONE
  if delayRefresh then
    self.autorefreshTimer = self.autoRefreshTimerDurationAfterError
    self.worldListRefresh = false
  else
    self:AutoRefreshWorldList()
  end
end
function LandingScreen:OnWorldCMSDataSet(worldData)
  self.worldCMSList = worldData
  if #self.worldList > 0 and 0 < #self.worldCMSList.worldDescriptions then
    for _, world in ipairs(self.worldList) do
      local logWarning = true
      for j = 1, #self.worldCMSList.worldDescriptions do
        if world.worldData.worldId == self.worldCMSList.worldDescriptions[j].worldId then
          world.worldData.name = self.worldCMSList.worldDescriptions[j].name
          for k = 1, #self.worldCMSList.setsData do
            if world.worldData.worldSet == self.worldCMSList.setsData[k].setId then
              if self.worldCMSList.setsData[k].name and self.worldCMSList.setsData[k].name ~= "" then
                world.worldSetName = self.worldCMSList.setsData[k].name
              end
              break
            end
          end
          logWarning = false
          break
        end
      end
      if logWarning and not self.CREATE_FAKE_DATA then
        Debug.Log("[OnWorldCMSDataSet] No world cms data available for world id:  " .. world.worldData.worldId)
      end
    end
  end
  local showGlobalMotd = 0 < string.len(self.worldCMSList.globalMotd.description)
  if showGlobalMotd then
    UiTextBus.Event.SetTextWithFlags(self.Properties.GlobalMotdTitle, self.worldCMSList.globalMotd.title, eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.GlobalMotdText, self.worldCMSList.globalMotd.description, eUiTextSet_SetAsIs)
    LyShineManagerBus.Broadcast.SetGlobalAnnouncement(self.worldCMSList.globalMotd.title, self.worldCMSList.globalMotd.description)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.GlobalMotdHolder, showGlobalMotd)
  self.worldListReady = true
  if self.characterListReady then
    self:UpdateDynamicData()
    self:SortWorldList()
    self:PopulateWorldSelectionList()
    self:SetStartingState()
    self.worldListRefresh = false
  end
end
function LandingScreen:OnAuthComplete(success)
  self.authSuccess = success
  if self.authSuccess and self.shown then
    self:RefreshWorldList()
  end
end
function LandingScreen:DeactivateCharacterResult(success, errorCode, errorMessage)
  if not success then
    PopupWrapper:RequestPopup(ePopupButtons_OK, errorCode, errorMessage, "Popup_ErrorMessage", self, function(self, result, eventId)
    end)
  end
  self:RefreshWorldList()
  self:EnableButtons(true)
end
function LandingScreen:OnLoginInfoListResult(worlds, characters, names, maxAccountCharacters)
  self:OnWorldListResult(worlds)
  self:OnCharactersPayloadResult(characters, maxAccountCharacters)
end
function LandingScreen:OnWorldListResult(worlds)
  self.worldList = {}
  for i = 1, #worlds do
    local newWorld = WorldMetadata()
    newWorld.status = worlds[i].status
    newWorld.publicStatusCode = worlds[i].publicStatusCode
    newWorld.connectionCount = worlds[i].connectionCount
    newWorld.maxConnectionCount = worlds[i].maxConnectionCount
    newWorld.worldId = worlds[i].worldId
    newWorld.worldSet = worlds[i].worldSet
    newWorld.maxAccountCharacters = worlds[i].maxAccountCharacters
    newWorld.name = worlds[i].name
    newWorld.worldMetrics = worlds[i].worldMetrics
    table.insert(self.worldList, {
      worldData = newWorld,
      worldSetName = worlds[i].worldSet,
      population = 0,
      characterCount = 0,
      lastPlayed = 0,
      groupLastPlayed = 32000000,
      mergeTime = 0,
      imageId = self:GetWorldSetImageId(worlds[i].worldSet)
    })
  end
  self.currentState = self.STATE_NONE
  if #self.worldList == 0 then
    self:PopulateCharacterSelectionList(-1)
  end
  if self.CREATE_FAKE_DATA then
    for i = 1, self.FAKE_WORLD_COUNT do
      local fakeWorld = WorldMetadata()
      fakeWorld.status = "ACTIVE"
      fakeWorld.publicStatusCode = 0
      fakeWorld.connectionCount = math.random(100, 2000)
      fakeWorld.maxConnectionCount = 2000
      fakeWorld.worldId = string.format("00000000-0000-0000-0000-0000000000%02d", i + 1)
      fakeWorld.worldSet = string.format("Fake World Set %01d", math.floor(i / 5))
      fakeWorld.maxAccountCharacters = i % 2 == 0 and 4 or 1
      fakeWorld.name = "Fake World " .. tostring(i + 1)
      local lastPlayed = math.random(96000, 31000000)
      fakeWorld.worldMetrics = WorldMetrics()
      fakeWorld.worldMetrics.queueSize = math.random(0, 20)
      fakeWorld.worldMetrics.queueWaitTimeSec = math.random(10, 3600)
      local populationCheck = math.random(0, 2)
      if populationCheck == 2 then
        fakeWorld.worldMetrics.worldPopulationStatus = "high"
      elseif populationCheck == 1 then
        fakeWorld.worldMetrics.worldPopulationStatus = "medium"
      else
        fakeWorld.worldMetrics.worldPopulationStatus = "low"
      end
      table.insert(self.worldList, {
        worldData = fakeWorld,
        worldSetName = fakeWorld.worldSet,
        population = 0,
        characterCount = 0,
        lastPlayed = lastPlayed,
        groupLastPlayed = 32000000,
        mergeTime = 0,
        imageId = self:GetWorldSetImageId(fakeWorld.worldSet)
      })
    end
  end
  if self.characterListReady and #self.worldList > 0 then
    self:UpdateDynamicData()
    self:SortWorldList()
  end
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.ServerList, #self.worldList)
  UiWorldListBus.Event.SetWorldCount(self.Properties.ServerPane, #self.worldList)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerTableHeader, true)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    DynamicContentBus.Broadcast.ClearWorldsCMSData()
    DynamicContentBus.Broadcast.RetrieveWorldsCMSData()
  end)
end
function LandingScreen:GetWorldSetImageId(worldSet)
  local imageId = 1
  local isFound = false
  for i = 1, #self.worldSetImageId do
    if self.worldSetImageId[i] == worldSet then
      isFound = true
      imageId = i
      break
    end
  end
  if not isFound then
    table.insert(self.worldSetImageId, worldSet)
    imageId = #self.worldSetImageId
  end
  return imageId
end
function LandingScreen:OnCharactersPayloadResult(characters, maxAccountCharacters)
  self.currentCharacterList = {}
  self.characterList = characters
  self.maxCharactersPerRegion = maxAccountCharacters
  self.characterListReady = true
  if self.worldListReady then
    self:UpdateDynamicData()
    self:SortWorldList()
    self:PopulateWorldSelectionList()
    self:SetStartingState()
    self.worldListRefresh = false
  end
end
function LandingScreen:OnQueuePopupVisibilityChanged(visible)
  self.queuePopupVisible = visible
  UiElementBus.Event.SetIsEnabled(self.Properties.QueueInfo, self.showMetrics and not self.queuePopupVisible)
end
function LandingScreen:GetWorldName(worldId)
  for _, world in ipairs(self.worldList) do
    if world.worldData.worldId == worldId then
      return world.worldData.name
    end
  end
  return ""
end
function LandingScreen:GetWorldIndex(worldId)
  for i, world in ipairs(self.worldList) do
    if world.worldData.worldId == worldId then
      return i
    end
  end
  return -1
end
function LandingScreen:HasCharacterOnWorld(worldId)
  for j = 1, #self.characterList do
    if self.characterList[j].worldId == worldId then
      return true
    end
  end
  return false
end
function LandingScreen:HasRecentlyMergedCharacter()
  for j = 1, #self.characterList do
    if string.len(self.characterList[j].prevWorldId) > 0 and self.characterList[j].worldId ~= self.characterList[j].prevWorldId then
      return true
    end
  end
  return false
end
function LandingScreen:UpdateDynamicData()
  local sortByLastPlayed = false
  local groupLastPlayedList = {}
  for _, world in ipairs(self.worldList) do
    world.characterCount = 0
    for j = 1, #self.characterList do
      if self.characterList[j].worldId == world.worldData.worldId then
        sortByLastPlayed = true
        world.characterCount = world.characterCount + 1
        if world.lastPlayed == 0 or self.characterList[j].publishedElapsedSeconds < world.lastPlayed then
          world.lastPlayed = self.characterList[j].publishedElapsedSeconds
          if world.lastPlayed == 0 then
            world.lastPlayed = 86400
          end
          if groupLastPlayedList[world.worldData.worldSet] == nil or world.lastPlayed < groupLastPlayedList[world.worldData.worldSet] then
            groupLastPlayedList[world.worldData.worldSet] = world.lastPlayed
          end
        end
      end
    end
    for k = 1, #self.pendingWorldMergeList do
      if world.worldData.worldId == self.pendingWorldMergeList[k].sourceWorldId then
        world.mergeDestinationName = self:GetWorldName(self.pendingWorldMergeList[k].destinationWorldId)
        world.mergeTime = self:ParseDate(self.pendingWorldMergeList[k].mergeTime)
      end
    end
  end
  for _, world in ipairs(self.worldList) do
    if groupLastPlayedList[world.worldData.worldSet] then
      world.groupLastPlayed = groupLastPlayedList[world.worldData.worldSet]
    else
      world.groupLastPlayed = 0
    end
    if world.worldData.worldMetrics.worldPopulationStatus == "high" then
      world.population = self.POPULATION_HIGH
    elseif world.worldData.worldMetrics.worldPopulationStatus == "medium" then
      world.population = self.POPULATION_MED
    else
      world.population = self.POPULATION_LOW
    end
  end
  if self.sortType == self.SORT_BYNONE then
    if sortByLastPlayed then
      self.sortType = self.SORT_BYLASTPLAYED_ASC
      self.ServerSortLastPlayedButton:SetSelectedAscending()
    else
      self.sortType = self.SORT_BYPOPULATION_ASC
      self.ServerSortPopulationButton:SetSelectedAscending()
    end
  end
end
function LandingScreen:ClearWorldList()
  self.worldListReady = false
  self.characterListReady = false
  self.worldList = {}
  self.characterList = {}
  self.currentCharacterList = {}
  self.worldSetImageId = {}
  self:PopulateWorldSelectionList(EntityId(), "")
  self:PopulateCharacterSelectionList(-1)
  UiWorldListBus.Event.SetWorldCount(self.Properties.ServerPane, 0)
  self:SetWorldInfoVisible(false)
  self:SetCharacterPaneVisible(false)
  self:CheckCharacterVisibility()
  self.autorefreshTimer = self.autoRefreshTimerDuration
end
function LandingScreen:OnRegionDropdownSelected(item, itemData)
  if itemData and itemData.regionId and self.selectedRegionId ~= itemData.regionId then
    self.ServerRegionDropdown:SetSelectedImage(itemData.image)
    self:ClearWorldList()
    self:ShowServerLoadingSpinner()
    self.selectedRegionId = itemData.regionId
    self:EnableButtons(false)
    OptionsDataBus.Broadcast.SetRegionId(itemData.regionId)
  end
end
function LandingScreen:OnClusterListResult(regions)
  local dropdownTable = self.registrar:GetEntityTable(self.Properties.ServerRegionDropdown)
  if dropdownTable and not dropdownTable.isShown then
    local currentRegion = GameRequestsBus.Broadcast.GetRegionId()
    local currentRegionIndex = 1
    local currentlatencyImage = ""
    local listItemData = {}
    local latencyImage
    for i = 1, #regions do
      for j = 1, #self.pingImageTable do
        if regions[i].latencyMs >= self.pingImageTable[j].ping then
          latencyImage = self.pingImageTable[j].image
          break
        end
      end
      local latencyText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_milliseconds_markup", tostring(math.ceil(regions[i].latencyMs)))
      table.insert(listItemData, {
        text = regions[i].name,
        regionId = regions[i].regionId,
        image = latencyImage,
        latency = latencyText
      })
      if regions[i].regionId == currentRegion then
        currentRegionIndex = i
        currentlatencyImage = latencyImage
      end
    end
    self.selectedRegionId = currentRegion
    dropdownTable:SetDropdownListHeightByRows(#listItemData)
    dropdownTable:SetListData(listItemData)
    dropdownTable:SetText(0 < #regions and regions[currentRegionIndex].name or "")
    dropdownTable:SetSelectedImage(currentlatencyImage)
  end
end
function LandingScreen:EnableSafeButtons(enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.RefreshButton, enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NavButton1, enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NavButton2, enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NavButton3, enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NavButton4, enable)
end
function LandingScreen:EnableButtons(enable)
  self.enableButtons = enable
  self:UpdatePlayButton()
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PlayButton, enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.DeleteButton, enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ServerContentBox, enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ServerContentSlider, enable)
  self:EnableSafeButtons(enable)
  self.StoreButtonHolder:SetIsHandlingEvents(enable)
  for _, buttonData in pairs(self.sortButtons) do
    buttonData.button:SetIsHandlingEvents(enable)
  end
  local serverEntryList = UiElementBus.Event.GetChildren(self.Properties.ServerList)
  for i = 1, #serverEntryList do
    local worldInfoBox = self.registrar:GetEntityTable(serverEntryList[i])
    worldInfoBox:SetEnabled(enable)
  end
  local characterList = UiElementBus.Event.GetChildren(self.Properties.CharacterList)
  for i = 1, #characterList do
    local childList = UiElementBus.Event.GetChildren(characterList[i])
    for j = 1, #childList do
      UiInteractableBus.Event.SetIsHandlingEvents(childList[j], enable)
    end
  end
end
function LandingScreen:ShowCharacter(show)
  if show then
    TransformBus.Event.SetWorldZ(self.characterEntityId, self.worldZ)
    UiElementBus.Event.SetIsEnabled(self.Properties.CharacterInfoCard, true)
    self.ScriptedEntityTweener:Stop(self.Properties.CharacterInfoCard)
    self.ScriptedEntityTweener:Play(self.Properties.CharacterInfoCard, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    TransformBus.Event.SetWorldZ(self.characterEntityId, self.hiddenWorldZ)
    self.ScriptedEntityTweener:Play(self.Properties.CharacterInfoCard, 0.2, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.CharacterInfoCard, false)
      end
    })
  end
  self:UpdatePlayButton()
end
function LandingScreen:SetCharacterListPaneVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.CharacterListPane, true)
    self.ScriptedEntityTweener:Stop(self.Properties.CharacterListPane)
    self.ScriptedEntityTweener:Play(self.Properties.CharacterListPane, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.CharacterListPane, 0.12, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.CharacterListPane, false)
      end
    })
  end
end
function LandingScreen:SetWorldInfoVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldInfoCard, true)
    self.ScriptedEntityTweener:Stop(self.Properties.WorldInfoCard)
    self.ScriptedEntityTweener:Play(self.Properties.WorldInfoCard, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.WorldInfoCard, 0.2, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.WorldInfoCard, false)
      end
    })
  end
end
function LandingScreen:SetCharacterPaneVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.CharacterPane, true)
    self.ScriptedEntityTweener:Stop(self.Properties.CharacterPane)
    self.ScriptedEntityTweener:Play(self.Properties.CharacterPane, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.CharacterPane, 0.2, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.CharacterPane, false)
      end
    })
  end
end
function LandingScreen:SetInformationState(state)
  if state == self.INFO_STATE_NO_CHARACTER then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessageTitle, "@ui_create_character_title_main_menu", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessage, "@ui_create_character_message_main_menu", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldInfoPlayDividerLine2, true)
    local offsetPosY = 80
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WorldInfoPlayMessageTitle, offsetPosY)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WorldInfoPlayMessage, offsetPosY)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WorldInfoPlayDividerLine2, offsetPosY)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.QueueInfo, offsetPosY)
    UiElementBus.Event.SetIsEnabled(self.Properties.CreateCharacterButton, true)
    self.CreateCharacterButton:SetEnabled(true)
    self:SetCharacterListPaneVisible(false)
  elseif state == self.INFO_STATE_ONE_CHARACTER_ALLOWED then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessageTitle, "", eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessage, "", eUiTextSet_SetAsIs)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldInfoPlayDividerLine2, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CreateCharacterButton, false)
    self.CreateCharacterButton:StartStopImageSequence(false)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.QueueInfo, 0)
    self:SetCharacterListPaneVisible(false)
  elseif state == self.INFO_STATE_MULTI_CHARACTER_ALLOWED then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessageTitle, "", eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessage, "", eUiTextSet_SetAsIs)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldInfoPlayDividerLine2, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CreateCharacterButton, false)
    self.CreateCharacterButton:StartStopImageSequence(false)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.QueueInfo, 0)
    self:SetCharacterListPaneVisible(true)
  elseif state == self.INFO_STATE_RESTRICTED_CHARACTER_WORLD then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessageTitle, "@ui_clusterwarning_cannot_create_title", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessage, self.clusterWarningMessage, eUiTextSet_SetAsIs)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldInfoPlayDividerLine2, true)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WorldInfoPlayMessageTitle, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WorldInfoPlayMessage, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WorldInfoPlayDividerLine2, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.QueueInfo, 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.CreateCharacterButton, true)
    self.CreateCharacterButton:SetEnabled(false)
    self:SetCharacterListPaneVisible(false)
  elseif state == self.INFO_STATE_MAX_CHARACTERS_REACHED then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessageTitle, "@ui_regionmaxwarning_cannot_create_title", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldInfoPlayMessage, "@ui_regionmaxwarning_cannot_create", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldInfoPlayDividerLine2, true)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WorldInfoPlayMessageTitle, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WorldInfoPlayMessage, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.WorldInfoPlayDividerLine2, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.QueueInfo, 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.CreateCharacterButton, true)
    self.CreateCharacterButton:SetEnabled(false)
    self:SetCharacterListPaneVisible(false)
  end
end
function LandingScreen:SetLoginState(state)
  local canPlay = state == ELumberyardState.Disconnected
  local isAuthenticating = state >= ELumberyardState.QueueGameLogin and state <= ELumberyardState.WaitingForQueuedLogin
  local isConfiguring = state >= ELumberyardState.QueryForRemoteConfigClass and state <= ELumberyardState.WaitingForRemoteConfigClass
  local isConnecting = state >= ELumberyardState.StartREPConnection and state < ELumberyardState.InGame
  local playButtonTextPositionSpinnerVisible = -30
  local playButtonTextWidth = 260
  if canPlay then
    playButtonTextPositionSpinnerVisible = -10
    playButtonTextWidth = 340
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@ui_play", eUiTextSet_SetLocalized)
  elseif isConnecting then
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@mm_connecting", eUiTextSet_SetLocalized)
  elseif isAuthenticating then
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@mm_authenticating", eUiTextSet_SetLocalized)
  elseif isConfiguring then
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@mm_configuring", eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusSpinnerEntity, isConnecting or isAuthenticating or isConfiguring)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.PlayButtonText, playButtonTextPositionSpinnerVisible)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.PlayButtonText, playButtonTextWidth)
  self:UpdatePlayButton()
end
function LandingScreen:RefreshWorldList()
  self.worldListReady = false
  self.characterListReady = false
  self.worldList = {}
  self.characterList = {}
  self.currentCharacterList = {}
  self:PopulateWorldSelectionList(EntityId(), "")
  self:PopulateCharacterSelectionList(-1)
  UiWorldListBus.Event.SetWorldCount(self.Properties.ServerPane, 0)
  UiLoginScreenRequestBus.Broadcast.GetLoginInfoLists(false)
  UiLoginScreenRequestBus.Broadcast.GetRegionList()
  self.autorefreshTimer = self.autoRefreshTimerDuration
  self:CheckCharacterVisibility()
end
function LandingScreen:SetStartingState()
  self.ScriptedEntityTweener:Stop(self.Properties.ServerContentBoxHolder)
  if not self.worldListRefresh then
    self.ScriptedEntityTweener:Play(self.Properties.ServerContentBoxHolder, 0.3, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ServerLoadingText, 0.3, {
    opacity = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  UiElementBus.Event.SetIsEnabled(self.Properties.FailedConnectionEntity, false)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.RefreshButton, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.RegionalCharacterCount, true)
  self.ScriptedEntityTweener:Play(self.Properties.RegionalCharacterCount, 0.3, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.2
  })
  self:EnableButtons(true)
  self:CheckCharacterVisibility()
end
function LandingScreen:GetCharacterCountByWorld(worldId)
  local count = 0
  for i = 1, #self.characterList do
    if self.characterList[i].worldId == worldId then
      count = count + 1
    end
  end
  return count
end
function LandingScreen:SelectCharacterByIndex(index)
  if #self.worldList > 0 and 0 < self.selectedWorldIndex and self.selectedWorldIndex <= #self.worldList and 0 < self:GetCharacterCountByWorld(self.worldList[self.selectedWorldIndex].worldData.worldId) then
    local childId = UiElementBus.Event.GetChild(self.Properties.CharacterList, index - 1)
    if childId:IsValid() then
      self.selectedCharacterIndex = index
      local radioButton = UiElementBus.Event.FindDescendantByName(childId, "RadioButton")
      if radioButton:IsValid() then
        UiRadioButtonGroupBus.Event.SetState(self.Properties.CharacterList, radioButton, true)
        self:SelectCharacter(self.Properties.CharacterList)
      end
    end
  end
end
function LandingScreen:CheckCharacterVisibility()
  if #self.worldList > 0 and 0 < self.selectedWorldIndex and #self.characterList then
    for i = 1, #self.characterList do
      if self.characterList[i].worldId == self.worldList[self.selectedWorldIndex].worldData.worldId then
        self:ShowCharacter(true)
        return
      end
    end
  end
  self:ShowCharacter(false)
end
function LandingScreen:SetCustomizableCharacterEntityId(entityId)
  self.characterEntityId = entityId
  CustomizableCharacterRequestBus.Event.SetAlwaysUpdate(self.characterEntityId, true)
  self.worldZ = 32
end
function LandingScreen:OnSortButtonClicked(sortButton)
  self.worldListRefresh = true
  self.autorefreshTimer = self.autoRefreshTimerDuration
  for _, buttonData in pairs(self.sortButtons) do
    if buttonData.button == sortButton then
      if buttonData.button.isSelected and buttonData.button.direction == buttonData.button.ASCENDING then
        buttonData.button:SetSelectedDescending()
        self.sortType = self["SORT_BY" .. buttonData.sort .. "_DESC"]
      else
        buttonData.button:SetSelectedAscending()
        self.sortType = self["SORT_BY" .. buttonData.sort .. "_ASC"]
      end
    else
      buttonData.button:SetDeselected()
    end
  end
  if landingCommon.lastPlayerSelectedWorldId == "" then
    landingCommon.lastPlayerSelectedWorldId = self.selectedWorldId
  end
  self:SortWorldList()
  self:PopulateWorldSelectionList()
  self:SetStartingState()
  self.worldListRefresh = false
end
function LandingScreen:SortWorldList()
  if self.sortType == self.SORT_BYNAME_ASC then
    table.sort(self.worldList, function(first, second)
      if first.worldSetName == second.worldSetName then
        return first.worldData.name < second.worldData.name
      else
        return first.worldSetName < second.worldSetName
      end
    end)
  elseif self.sortType == self.SORT_BYNAME_DESC then
    table.sort(self.worldList, function(first, second)
      if first.worldSetName == second.worldSetName then
        return first.worldData.name > second.worldData.name
      else
        return first.worldSetName > second.worldSetName
      end
    end)
  elseif self.sortType == self.SORT_BYLASTPLAYED_ASC then
    table.sort(self.worldList, function(first, second)
      if first.lastPlayed == second.lastPlayed then
        if first.worldData.worldMetrics.queueWaitTimeSec == second.worldData.worldMetrics.queueWaitTimeSec then
          if first.worldSetName == second.worldSetName then
            return first.worldData.name < second.worldData.name
          else
            return first.worldSetName < second.worldSetName
          end
        else
          return first.worldData.worldMetrics.queueWaitTimeSec < second.worldData.worldMetrics.queueWaitTimeSec
        end
      elseif first.lastPlayed == 0 then
        return false
      elseif second.lastPlayed == 0 then
        return true
      else
        return first.lastPlayed < second.lastPlayed
      end
    end)
  elseif self.sortType == self.SORT_BYLASTPLAYED_DESC then
    table.sort(self.worldList, function(first, second)
      if first.lastPlayed == second.lastPlayed then
        if first.worldData.worldMetrics.queueWaitTimeSec == second.worldData.worldMetrics.queueWaitTimeSec then
          if first.worldSetName == second.worldSetName then
            return first.worldData.name > second.worldData.name
          else
            return first.worldSetName > second.worldSetName
          end
        else
          return first.worldData.worldMetrics.queueWaitTimeSec > second.worldData.worldMetrics.queueWaitTimeSec
        end
      elseif first.lastPlayed == 0 then
        return false
      elseif second.lastPlayed == 0 then
        return true
      else
        return first.lastPlayed > second.lastPlayed
      end
    end)
  elseif self.sortType == self.SORT_BYPOPULATION_ASC then
    table.sort(self.worldList, function(first, second)
      if first.population == second.population then
        if first.worldData.worldMetrics.queueWaitTimeSec == second.worldData.worldMetrics.queueWaitTimeSec then
          if first.worldSetName == second.worldSetName then
            return first.worldData.name < second.worldData.name
          else
            return first.worldSetName < second.worldSetName
          end
        else
          return first.worldData.worldMetrics.queueWaitTimeSec < second.worldData.worldMetrics.queueWaitTimeSec
        end
      else
        return first.population < second.population
      end
    end)
  else
    table.sort(self.worldList, function(first, second)
      if first.population == second.population then
        if first.worldData.worldMetrics.queueWaitTimeSec == second.worldData.worldMetrics.queueWaitTimeSec then
          if first.worldSetName == second.worldSetName then
            return first.worldData.name > second.worldData.name
          else
            return first.worldSetName > second.worldSetName
          end
        else
          return first.worldData.worldMetrics.queueWaitTimeSec > second.worldData.worldMetrics.queueWaitTimeSec
        end
      else
        return first.population > second.population
      end
    end)
  end
end
function LandingScreen:OnClusterPopupCancel()
  self:SetClusterNotificationPopupVisible(false)
end
function LandingScreen:OnClusterPopupAccept()
  self:SetClusterNotificationPopupVisible(false)
  self:StartIntro()
end
function LandingScreen:SetClusterNotificationPopupVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.ClusterNotificationPopup.Window, true)
    self.ScriptedEntityTweener:Play(self.Properties.ClusterNotificationPopup.PopupContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.ClusterNotificationPopup.PopupScrim, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.ClusterNotificationPopup.PopupContainer)
    self.ScriptedEntityTweener:Play(self.Properties.ClusterNotificationPopup.PopupContainer, 0.3, {
      opacity = 0,
      y = -10,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.ClusterNotificationPopup.Window, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.ClusterNotificationPopup.PopupScrim, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function LandingScreen:OnMergeCloseClicked()
  if self.returnDestination == self.MERGE_POPUP_RETURN_MAIN then
    self:SetMergeInfoPopupVisible(false)
  else
    self:OpenMergePopup(self.MERGE_POPUP_WARNING, self.MERGE_POPUP_RETURN_MAIN)
  end
end
function LandingScreen:OnMergeLearnMoreClicked()
  self:OpenMergePopup(self.MERGE_POPUP_FAQ, self.MERGE_POPUP_RETURN_WARNING)
end
function LandingScreen:OnWorldPaneLearnMoreClicked()
  self.mergeTime = self.worldList[self.selectedWorldIndex].mergeTime
  self:OpenMergePopup(self.MERGE_POPUP_WARNING, self.MERGE_POPUP_RETURN_MAIN)
end
function LandingScreen:OpenMergePopup(popupType, returnDest)
  self.mergePopupType = popupType
  self.returnDestination = returnDest
  UiElementBus.Event.SetIsEnabled(self.Properties.MergeInfoPopup.Faq, popupType == self.MERGE_POPUP_FAQ)
  UiElementBus.Event.SetIsEnabled(self.Properties.MergeInfoPopup.UpcomingMerge, popupType == self.MERGE_POPUP_WARNING)
  UiElementBus.Event.SetIsEnabled(self.Properties.MergeInfoPopup.PostMerge, popupType == self.MERGE_POPUP_POSTMERGE)
  if popupType == self.MERGE_POPUP_WARNING then
    self.ScriptedEntityTweener:Set(self.Properties.MergeInfoPopup.Frame, {
      w = self.POPUP_SMALL_WIDTH
    })
    self.ScriptedEntityTweener:Set(self.Properties.MergeInfoPopup.AcceptButton, {
      x = self.POPUP_SMALL_BUTTON_POS
    })
  else
    self.ScriptedEntityTweener:Set(self.Properties.MergeInfoPopup.Frame, {
      w = self.POPUP_LARGE_WIDTH
    })
    self.ScriptedEntityTweener:Set(self.Properties.MergeInfoPopup.AcceptButton, {
      x = self.POPUP_LARGE_BUTTON_POS
    })
  end
  self:SetMergeInfoPopupVisible(true)
end
function LandingScreen:SetMergeInfoPopupVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.MergeInfoPopup.Window, true)
    self.ScriptedEntityTweener:Play(self.Properties.MergeInfoPopup.PopupContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.MergeInfoPopup.PopupScrim, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.MergeInfoPopup.PopupContainer)
    self.ScriptedEntityTweener:Play(self.Properties.MergeInfoPopup.PopupContainer, 0.3, {
      opacity = 0,
      y = -10,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.MergeInfoPopup.Window, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.MergeInfoPopup.PopupScrim, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function LandingScreen:ParseDate(inputDate)
  local offset = tonumber(os.date("%z"))
  local direction = offset < 0 and -1 or 1
  offset = math.abs(offset)
  local offsetMinutes = offset % 100
  local offsetSeconds = direction * (math.floor(offset / 100) * timeHelpers.minutesInHour + offsetMinutes) * timeHelpers.secondsInMinute
  local dateStrings = StringSplit(inputDate, "T")
  local dayStrings = StringSplit(dateStrings[1], "-")
  local timeStrings = StringSplit(dateStrings[2], ":")
  local mergeTime = os.time({
    year = dayStrings[1],
    month = dayStrings[2],
    day = dayStrings[3],
    hour = timeStrings[1],
    min = timeStrings[2],
    sec = timeStrings[3]
  })
  return mergeTime + offsetSeconds
end
return LandingScreen
