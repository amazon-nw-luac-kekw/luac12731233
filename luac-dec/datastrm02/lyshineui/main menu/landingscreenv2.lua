local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local landingCommon = RequireScript("LyShineUI.Main Menu.LandingCommon")
local cinematicUtils = RequireScript("LyShineUI._Common.CinematicUtils")
local entitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local worldListCommon = RequireScript("LyShineUI._Common.WorldListCommon")
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
    ScreenHeader = {
      default = EntityId()
    },
    BlackIntroReveal = {
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
    ServerList = {
      default = EntityId()
    },
    ServerContentBoxHolder = {
      default = EntityId()
    },
    ServerContentBox = {
      default = EntityId()
    },
    ServerContentBoxMask = {
      default = EntityId()
    },
    ServerRegionDropdown = {
      default = EntityId()
    },
    WorldSelectServerRegionDropdown = {
      default = EntityId()
    },
    ServerRegionText = {
      default = EntityId()
    },
    ServerTableHeader = {
      default = EntityId()
    },
    ServerSortNameButton = {
      default = EntityId()
    },
    ServerSortWorldSetButton = {
      default = EntityId()
    },
    ServerSortCharacterNameButton = {
      default = EntityId()
    },
    ServerSortWaitTimeButton = {
      default = EntityId()
    },
    ServerSortPopulationButton = {
      default = EntityId()
    },
    ServerSortFriendsButton = {
      default = EntityId()
    },
    ServerSortQueueSize = {
      default = EntityId()
    },
    ServerSortWorldSetLabel = {
      default = EntityId()
    },
    ServerSortWorldSetTooltip = {
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
    CharacterSelectionScreen = {
      default = EntityId()
    },
    CharacterInfoHolder = {
      default = EntityId()
    },
    CharacterList = {
      default = EntityId()
    },
    CharacterListTitle = {
      default = EntityId()
    },
    CharacterPurchaseButtonHolder = {
      default = EntityId()
    },
    CharacterPurchaseSlotButton = {
      default = EntityId()
    },
    CharacterViewWorldListButton = {
      default = EntityId()
    },
    CharacterRefreshButton = {
      default = EntityId()
    },
    CharacterFailedConnectionEntity = {
      default = EntityId()
    },
    CharacterServerLoadingText = {
      default = EntityId()
    },
    CharacterServerLoadingSpinner = {
      default = EntityId()
    },
    PlayButton = {
      default = EntityId()
    },
    PlayButtonText = {
      default = EntityId()
    },
    WorldInfoCard = {
      default = EntityId()
    },
    WorldInfoFrame = {
      default = EntityId()
    },
    WorldInfoMessageHolder = {
      default = EntityId()
    },
    ServerMOTDContainer = {
      default = EntityId()
    },
    ServerMOTDTitle = {
      default = EntityId()
    },
    ServerMOTDMessage = {
      default = EntityId()
    },
    GlobalAnnouncementContainer = {
      default = EntityId()
    },
    GlobalAnnouncementTitle = {
      default = EntityId()
    },
    GlobalAnnouncementMessage = {
      default = EntityId()
    },
    NavMenuHolder = {
      default = EntityId()
    },
    NavMenuBg = {
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
    NewWorldLogo = {
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
    TwitchSpinner = {
      default = EntityId()
    },
    LandingScreen = {
      default = EntityId()
    },
    LandingScreenNewsTiles = {
      default = {
        EntityId()
      }
    },
    LandingScreenNewsSpinnerHolder = {
      default = EntityId()
    },
    LandingScreenNewsSpinner = {
      default = EntityId()
    },
    LandingGlobalAnnouncement = {
      default = EntityId()
    },
    LandingGlobalAnnouncementHolder = {
      default = EntityId()
    },
    LandingGlobalAnnouncementContainer = {
      default = EntityId()
    },
    LandingGlobalAnnouncementTitle = {
      default = EntityId()
    },
    LandingGlobalAnnouncementMessage = {
      default = EntityId()
    },
    LandingGlobalAnnouncementFrame = {
      default = EntityId()
    },
    LandingPlayButton = {
      default = EntityId()
    },
    ExitSurveyCheckbox = {
      default = EntityId()
    },
    WorldSelectionListScreen = {
      default = EntityId()
    },
    WorldSelectionListScreenHolder = {
      default = EntityId()
    },
    WorldSelectionListScreenContent = {
      default = EntityId()
    },
    WorldSelectionListContinueButton = {
      default = EntityId()
    },
    WorldSelectionListRegionConnectionWarningHolder = {
      default = EntityId()
    },
    WorldSelectionListRegionConnectionWarning = {
      default = EntityId()
    },
    WorldSelectionListRecommendedTitle = {
      default = EntityId()
    },
    WorldSelectionListRecommendedServer = {
      default = EntityId()
    },
    WorldSelectionListMoreOptions = {
      default = EntityId()
    },
    WorldSelectionWarningScreen = {
      default = EntityId()
    },
    WorldSelectionWarningScreenPopupContainer = {
      default = EntityId()
    },
    WorldSelectionWarningScreenPopupScrim = {
      default = EntityId()
    },
    WorldSelectionWarningScreenText = {
      default = EntityId()
    },
    WorldSelectionWarningScreenHeader = {
      default = EntityId()
    },
    WorldSelectionWarningScreenButton1 = {
      default = EntityId()
    },
    WorldSelectionWarningScreenButton2 = {
      default = EntityId()
    },
    WorldSelectionWarningScreenButtonClose = {
      default = EntityId()
    },
    DisplaySettingsScreen = {
      default = EntityId()
    },
    DisplaySettingsBrightnessSlider = {
      default = EntityId()
    },
    DisplaySettingsContrastSlider = {
      default = EntityId()
    },
    DisplaySettingsContinueButton = {
      default = EntityId()
    },
    DisplaySettingsRestoreButton = {
      default = EntityId()
    },
    DisplaySettingsMainBg = {
      default = EntityId()
    },
    DisplaySettingsContentHolder = {
      default = EntityId()
    },
    BasicSettingsScreen = {
      default = EntityId()
    },
    BasicSettingsContinueButton = {
      default = EntityId()
    },
    BasicSettingsRestoreButton = {
      default = EntityId()
    },
    BasicSettingsListItem = {
      default = EntityId()
    },
    BasicSettingsMainBg = {
      default = EntityId()
    },
    TwitchInfoPopup = {
      Window = {
        default = EntityId()
      },
      PopupContainer = {
        default = EntityId()
      },
      FrameHeader = {
        default = EntityId()
      },
      CloseButton = {
        default = EntityId()
      },
      AcceptButton = {
        default = EntityId()
      },
      DeclineButton = {
        default = EntityId()
      },
      PopupScrim = {
        default = EntityId()
      }
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
      PopupWarning = {
        default = EntityId()
      },
      PopupDescription1 = {
        default = EntityId()
      },
      PopupDescription2 = {
        default = EntityId()
      },
      PopupScrim = {
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
      FrameHeader = {
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
      CharEntry1 = {
        default = EntityId()
      },
      CharEntry2 = {
        default = EntityId()
      },
      CharEntry3 = {
        default = EntityId()
      },
      CharEntryDivider = {
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
  popupTwitchLogoutEventId = "Popup_OnTwitchLogout",
  characterEntityId = EntityId(),
  selectedWorldId = "",
  selectedCharacterId = "",
  selectedWorldIndex = -1,
  selectedCharacterIndex = -1,
  selectedRegionId = 0,
  characterData = {},
  currentCharacterData = {},
  worldList = {},
  worldCMSList = {},
  worldDataList = {},
  sortType = 0,
  pingImageTable = {},
  worldListReady = false,
  characterDataReady = false,
  worldHasCapacity = false,
  authSuccess = false,
  shown = false,
  worldListRefresh = false,
  renamePopupShown = false,
  isBlurred = false,
  maxCharactersPerRegion = 4,
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
  autoRefreshTimerDuration = 30,
  autoRefreshTimerDurationAfterError = 10,
  autorefreshTimer = 30,
  REFRESH_TIMER_DURATION = 30,
  refreshTimer = 0,
  MERGE_POPUP_FAQ = 0,
  MERGE_POPUP_WARNING = 1,
  MERGE_POPUP_POSTMERGE = 2,
  MERGE_POPUP_RETURN_MAIN = 0,
  MERGE_POPUP_RETURN_WARNING = 1,
  POPUP_LARGE_WIDTH = 1400,
  POPUP_SMALL_WIDTH = 1130,
  POPUP_LARGE_HEIGHT = 590,
  POPUP_SMALL_HEIGHT = 620,
  POPUP_LARGE_BUTTON_HEIGHT = 50,
  POPUP_SMALL_BUTTON_HEIGHT = 90,
  returnDestination = 0,
  hasShownMergeWarning = false,
  showMetrics = false,
  queuePopupVisible = false,
  enableButtons = true,
  isPurchaseCharacterSlotEnabled = false,
  clusterNotificationImagePathRoot = "lyshineui/images/landingscreen/serverimage/serverImageLarge",
  purchasedCharacterSlots = 0,
  maxPurchaseableSlots = 2,
  debugMaxCharacters = 2,
  maxVisibleCharacters = 4,
  CINEMATIC_CHARACTER_TO_LANDING = "CharacterToIntro",
  CINEMATIC_LANDING_TO_CHARACTER = "IntroToCharacter",
  CINEMATIC_LANDING_INTRO = "IntroStart",
  currentCinematic = "IntroStart",
  SCREEN_STATE_LANDING = 1,
  SCREEN_STATE_CHARACTER_SELECT = 2,
  SCREEN_STATE_WORLD_SELECT = 3,
  SCREEN_STATE_BASIC_SETTINGS = 4,
  SCREEN_STATE_DISPLAY_SETTINGS = 5,
  currentScreenState = nil,
  SCREEN_TRANSITION_INTRO = 1,
  SCREEN_TRANSITION_FORWARD = 2,
  SCREEN_TRANSITION_BACK = 3,
  SCREEN_TRANSITION_FADE_IN = 4,
  SCREEN_TRANSITION_NONE = 5,
  currentScreen = nil,
  previousScreen = nil,
  isTransitioning = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(LandingScreen)
local bitHelpers = RequireScript("LyShineUI._Common.BitwiseHelpers")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function LandingScreen:OnInit()
  BaseScreen.OnInit(self)
  self.autoRefreshTimerDuration = ConfigProviderEventBus.Broadcast.GetInt("UIFeatures.mm-server-refresh-time-s")
  self:BusConnect(UiMainMenuBus)
  self:BusConnect(UiCharacterServiceNotificationBus)
  self:BusConnect(UiLoginScreenNotificationBus)
  self:BusConnect(CrySystemNotificationsBus)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self:BusConnect(CryActionNotificationsBus, "toggleMenuComponent")
  self:SetVisualElements()
  self:CloseAllSubscreens()
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
  self.dataLayer:OnChange(self, "UIFeatures.showQueueTimes", function(self, showQueueTimeDataNode)
    if showQueueTimeDataNode then
      local showQueueTime = showQueueTimeDataNode:GetData()
      UiElementBus.Event.SetIsEnabled(self.Properties.ServerSortWaitTimeButton, showQueueTime)
    end
  end)
  self.sortButtons = {
    {
      button = self.ServerSortNameButton,
      sort = "NAME",
      label = "@ui_world_select_world"
    },
    {
      button = self.ServerSortWorldSetButton,
      sort = "WORLDSET",
      label = "@ui_world_select_world_set"
    },
    {
      button = self.ServerSortCharacterNameButton,
      sort = "CHARACTER",
      label = "@mm_charactercount"
    },
    {
      button = self.ServerSortWaitTimeButton,
      sort = "WAIT",
      label = "@ui_world_select_queue_time"
    },
    {
      button = self.ServerSortPopulationButton,
      sort = "POPULATION",
      label = "@ui_world_select_population"
    },
    {
      button = self.ServerSortFriendsButton,
      sort = "FRIENDS",
      label = "@ui_online_friends"
    },
    {
      button = self.ServerSortQueueSize,
      sort = "QUEUE",
      label = "@ui_world_select_queue_size"
    }
  }
  self.ServerSortWorldSetTooltip:SetButtonStyle(self.ServerSortWorldSetTooltip.BUTTON_STYLE_QUESTION_MARK)
  self.ServerSortWorldSetTooltip:SetTooltip("@world_set_desc")
  self.sortType = worldListCommon.SORT_BYNONE
  for _, buttonData in ipairs(self.sortButtons) do
    local button = buttonData.button
    button:SetCallback(self.OnSortButtonClicked, self)
    button:SetText(buttonData.label)
    button:SetDeselected()
  end
  self:SetWorldSetTooltipPosition()
  self:InitRegionDropdown(self.ServerRegionDropdown)
  self:InitRegionDropdown(self.WorldSelectServerRegionDropdown)
  self.dataLayer:RegisterOpenEvent("LandingScreen", self.canvasId)
  if self.Properties.StatusSpinnerEntity:IsValid() then
    self.ScriptedEntityTweener:Play(self.Properties.StatusSpinnerEntity, 1, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  end
  if self.Properties.WorldSpinnerEntity:IsValid() then
    self.ScriptedEntityTweener:Play(self.Properties.WorldSpinnerEntity, 1, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  end
  if self.Properties.CharacterServerLoadingSpinner:IsValid() then
    self.ScriptedEntityTweener:Play(self.Properties.CharacterServerLoadingSpinner, 1, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  end
  if self.Properties.LandingScreenNewsSpinner:IsValid() then
    self.ScriptedEntityTweener:Play(self.Properties.LandingScreenNewsSpinner, 1, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  end
  UiMainMenuRequestBus.Broadcast.RequestCustomizableCharacterEntityId()
  self.autorefreshTimer = self.autoRefreshTimerDuration
  self.dataLayer:RegisterAndExecuteDataObserver(self, "javelin.enable-exit-survey", function(self, exitSurveyEnabled)
    if exitSurveyEnabled == nil then
      return
    end
    self.exitSurveyEnabled = exitSurveyEnabled
    UiElementBus.Event.SetIsEnabled(self.Properties.ExitSurveyCheckbox, exitSurveyEnabled)
  end)
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
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enableCharacterSlotPurchase", function(self, isPurchaseEnabled)
    self.isPurchaseCharacterSlotEnabled = isPurchaseEnabled
    self:RefreshPurchaseSlotButton()
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
  self.dataLayer:RegisterAndExecuteDataObserver(self, "MainMenu.ErrorPopups.ErrorSeen", function(self, errorSeen)
    local errorId = self.dataLayer:GetDataFromNode("MainMenu.ErrorPopups.LastErrorId")
    if errorSeen ~= nil and not errorSeen and errorId then
      local timepoint = WallClockTimePoint():AddDuration(Duration.FromSecondsUnrounded(self.dataLayer:GetDataFromNode("MainMenu.ErrorPopups.LastErrorTimepoint") or 0))
      local additionalInfo = self.dataLayer:GetDataFromNode("MainMenu.ErrorPopups.LastErrorAdditionalInfo") or ""
      local eventId = self.dataLayer:GetDataFromNode("MainMenu.ErrorPopups.LastErrorEventId") or ""
      PopupWrapper:RequestError(errorId, timepoint, additionalInfo, eventId)
      LyShineDataLayerBus.Broadcast.SetData("MainMenu.ErrorPopups.ErrorSeen", true)
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "MainMenu.IsBanned", function(self, isBanned)
    if isBanned then
      self.LandingPlayButton:SetText("@ui_banned")
      self.LandingPlayButton:SetEnabled(false)
    end
  end)
  self.enablePopupEntitlements = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableTwitchPopupInMainMenu")
  self.hasInitialized = true
end
function LandingScreen:OnCryAction(actionName)
  if actionName == "toggleMenuComponent" then
    self:OnBackButtonClicked()
  end
end
function LandingScreen:OnEntitlementsReady()
  if EntitlementRequestBus.Broadcast.AreThereNewEntitlements() then
    self:ShowTwitchRewardsPopup()
  end
end
function LandingScreen:ShowTwitchRewardsPopup()
  self:CollectTwitchRewards()
  if #self.twitchRewards > 0 then
    if self.notification then
      UiNotificationsBus.Broadcast.RescindNotification(self.notification, true, true)
    end
    local notificationData = NotificationData()
    notificationData.type = "Generic"
    notificationData.text = "@ui_twitch_reward_text"
    notificationData.title = "@ui_twitch_reward_notification"
    notificationData.icon = "LyShineUI/Images/Icons/Twitch/iconTwitchPurpleBg.dds"
    notificationData.hasChoice = true
    notificationData.acceptTextOverride = "@ui_twitch_reward_view"
    notificationData.declineTextOverride = "@ui_dismiss"
    notificationData.contextId = self.entityId
    notificationData.callbackName = "OnShowTwitchRewardsFromNotification"
    self.notification = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function LandingScreen:OnShowTwitchRewardsFromNotification(notificationId, isAccepted)
  self.notification = nil
  if isAccepted and #self.twitchRewards > 0 then
    DynamicBus.StoreScreenBus.Broadcast.InvokeStoreWithEntitlements(self.twitchRewards)
  end
end
function LandingScreen:CollectTwitchRewards()
  local entitlementIds = vector_Crc32()
  EntitlementRequestBus.Broadcast.GetAllEntitlementIds(entitlementIds)
  self.twitchRewards = {}
  for i = 1, #entitlementIds do
    local entitlementId = entitlementIds[i]
    local entitlementData = EntitlementRequestBus.Broadcast.GetEntitlementData(entitlementId)
    local isNew = EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeNew(entitlementData.rewardType, entitlementData.rewardKey)
    local sourceType = entitlementData.sourceType
    if isNew and sourceType == entitlementsDataHandler.MTX_SOURCE_TYPE_TWITCH then
      table.insert(self.twitchRewards, entitlementId)
    end
  end
end
function LandingScreen:OnConfigChanged()
  BaseScreen.OnConfigChanged(self)
  local hideStore = not ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableEntitlements")
  local prevUseWorldSetChecks = self.useWorldSetChecks
  local prevUseRegionCharacterLimit = self.useRegionCharacterLimit
  local prevAutoRefreshTimerDuration = self.autoRefreshTimerDuration
  self.useWorldSetChecks = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-world-set-restrictions")
  self.useRegionCharacterLimit = ConfigProviderEventBus.Broadcast.GetBool("javelin.use-regional-character-limit")
  self.autoRefreshTimerDuration = ConfigProviderEventBus.Broadcast.GetInt("UIFeatures.mm-server-refresh-time-s")
  if (prevUseWorldSetChecks ~= self.useWorldSetChecks or prevUseRegionCharacterLimit ~= self.useRegionCharacterLimit or prevAutoRefreshTimerDuration ~= self.autoRefreshTimerDuration) and self.hasInitialized then
    self:RefreshWorldList()
  end
end
function LandingScreen:OnTick(deltaTime, timePoint)
  local deferRefresh = self.deletePopupOpen
  if self.ServerRegionDropdown.isShown or self.WorldSelectServerRegionDropdown.isShown then
    self.refreshTimer = self.REFRESH_TIMER_DURATION
  else
    self.refreshTimer = self.refreshTimer - deltaTime
    if self.refreshTimer < 0 then
      self.refreshTimer = self.REFRESH_TIMER_DURATION
      if not deferRefresh then
        UiLoginScreenRequestBus.Broadcast.GetRegionList()
      end
    end
  end
  if self.worldListReady and not self.worldListRefresh and not self.renamePopupShown then
    self.autorefreshTimer = self.autorefreshTimer - deltaTime
    if 0 > self.autorefreshTimer then
      if not deferRefresh then
        self:AutoRefreshWorldList()
      else
        self.autorefreshTimer = self.autoRefreshTimerDuration
      end
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
      UiElementBus.Event.SetIsEnabled(self.Properties.CharacterFailedConnectionEntity, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.ServerLoadingText, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.CharacterServerLoadingText, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.RegionalCharacterCount, true)
      self.isRefreshEnabled = true
      self:RefreshCharacterRefreshButtonEnabled()
      self.ServerRegionDropdown:StopSpinner()
      self.WorldSelectServerRegionDropdown:StopSpinner()
    end
  end
end
function LandingScreen:AutoRefreshWorldList()
  self.autorefreshTimer = self.autoRefreshTimerDuration
  self.worldListReady = false
  self.worldListRefresh = true
  self.characterDataReady = false
  UiLoginScreenRequestBus.Broadcast.GetLoginInfoLists(false)
end
function LandingScreen:OnViewWorldListButtonPress()
  self:SetScreenState(self.SCREEN_STATE_WORLD_SELECT, self.SCREEN_TRANSITION_FADE_IN, {isWorldListOnly = true})
end
function LandingScreen:SetVisualElements()
  self.PlayButton:SetText()
  self.PlayButton:SetCallback(self.OnSelectCharacterPlayPressed, self)
  self.PlayButton:SetButtonStyle(self.PlayButton.BUTTON_STYLE_HERO)
  self.PlayButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnPlayHover)
  self.PlayButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnPlayPress)
  self.PlayButton:StartStopImageSequence(true)
  UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@ui_play", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.PlayButtonText, self.UIStyle.FONT_STYLE_BUTTON_HERO)
  self.LandingPlayButton:SetText("@ui_continue")
  self.LandingPlayButton:SetCallback(self.OnLandingPlayPressed, self)
  self.LandingPlayButton:SetButtonStyle(self.LandingPlayButton.BUTTON_STYLE_HERO)
  self.LandingPlayButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnPlayHover)
  self.LandingPlayButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnPlayPress)
  self.LandingPlayButton:StartStopImageSequence(true)
  self.CharacterPurchaseSlotButton:SetSlotStatus(self.CharacterPurchaseSlotButton.CHARSTATUS_PURCHASE_LOCKED)
  self.CharacterPurchaseSlotButton:SetText("@ui_additionalcharacter")
  self.CharacterViewWorldListButton:SetText("@ui_world_select_view_worlds")
  self.CharacterViewWorldListButton:SetCallback(self.OnViewWorldListButtonPress, self)
  self.CharacterRefreshButton:SetText("@ui_world_select_refresh")
  self.CharacterRefreshButton:SetCallback(self.OnRefreshServerPress, self)
  self.WorldSelectionListContinueButton:SetText("@ui_world_select_select_world")
  self.WorldSelectionListContinueButton:SetCallback(self.ConfirmServerSelectionChange, self)
  self.WorldSelectionListContinueButton:SetButtonStyle(self.WorldSelectionListContinueButton.BUTTON_STYLE_HERO)
  self.WorldSelectionListContinueButton:StartStopImageSequence(true)
  self.WorldSelectionWarningScreenHeader:SetText("@ui_warning")
  self.WorldSelectionWarningScreenHeader:SetTextAlignment(self.WorldSelectionWarningScreenHeader.TEXT_ALIGN_CENTER)
  self.WorldSelectionWarningScreenButton1:SetButtonStyle(self.WorldSelectionWarningScreenButton1.BUTTON_STYLE_CTA)
  self.WorldSelectionListRecommendedServer:SetCallback(self.ChangeServerByWorldId, self)
  self:WorldSelectionToggleOptions(false)
  self.WorldInfoFrame:SetFrameStyle(self.WorldInfoFrame.FRAME_STYLE_DEFAULT_NO_OUTLINE)
  SetTextStyle(self.Properties.ServerMOTDMessage, self.UIStyle.FONT_STYLE_POPUP_MESSAGE)
  SetTextStyle(self.Properties.GlobalAnnouncementMessage, self.UIStyle.FONT_STYLE_POPUP_MESSAGE)
  SetTextStyle(self.Properties.ServerMOTDTitle, self.UIStyle.FONT_STYLE_POPUP_MESSAGE_TITLE)
  SetTextStyle(self.Properties.GlobalAnnouncementTitle, self.UIStyle.FONT_STYLE_POPUP_MESSAGE_TITLE)
  self.LandingGlobalAnnouncementFrame:SetFrameStyle(self.LandingGlobalAnnouncementFrame.FRAME_STYLE_DEFAULT_NO_OUTLINE)
  SetTextStyle(self.Properties.LandingGlobalAnnouncementTitle, self.UIStyle.FONT_STYLE_POPUP_MESSAGE_TITLE)
  SetTextStyle(self.Properties.LandingGlobalAnnouncementMessage, self.UIStyle.FONT_STYLE_POPUP_MESSAGE)
  self.DisplaySettingsContinueButton:SetText("@ui_continue")
  self.DisplaySettingsContinueButton:SetCallback(self.OnDisplaySettingsContinue, self)
  self.DisplaySettingsContinueButton:SetButtonStyle(self.DisplaySettingsContinueButton.BUTTON_STYLE_CTA)
  self.DisplaySettingsRestoreButton:SetText("@ui_restore_defaults")
  self.DisplaySettingsRestoreButton:SetCallback(self.RestoreDisplaySettings, self)
  self.BasicSettingsContinueButton:SetText("@ui_continue")
  self.BasicSettingsContinueButton:SetCallback(self.OpenDisplaySettingsScreen, self)
  self.BasicSettingsContinueButton:SetButtonStyle(self.BasicSettingsContinueButton.BUTTON_STYLE_CTA)
  self.BasicSettingsRestoreButton:SetText("@ui_restore_defaults")
  self.BasicSettingsRestoreButton:SetCallback(self.RestoreBasicSettings, self)
  self.ScreenHeader:SetText("")
  self.ScreenHeader:SetHintCallback(self.OnBackButtonClicked, self)
  self.ScreenHeader:SetBgVisible(false, 0.1)
  self.ScriptedEntityTweener:Set(self.Properties.ScreenHeader, {opacity = 0})
  self.ExitSurveyCheckbox:SetText("@ui_options_take_exit_survey")
  self.ExitSurveyCheckbox:SetTextSize(self.UIStyle.FONT_SIZE_BODY_NEW)
  self.ExitSurveyCheckbox:SetCallback(self, self.OnEnableExitSurveyChanged)
  SetTextStyle(self.Properties.ClusterNotificationPopup.PopupWarning, self.UIStyle.FONT_STYLE_BODY_NEW_REGULAR)
  SetTextStyle(self.Properties.ClusterNotificationPopup.PopupDescription1, self.UIStyle.FONT_STYLE_BODY_NEW_REGULAR)
  SetTextStyle(self.Properties.ClusterNotificationPopup.PopupDescription2, self.UIStyle.FONT_STYLE_BODY_NEW_REGULAR)
  self.ClusterNotificationPopup.CancelButton:SetCallback(self.OnClusterPopupCancel, self)
  self.ClusterNotificationPopup.CancelButton:SetText("@ui_clusterwarning_cancel")
  self.ClusterNotificationPopup.AcceptButton:SetCallback(self.OnClusterPopupAccept, self)
  self.ClusterNotificationPopup.AcceptButton:SetButtonStyle(self.ClusterNotificationPopup.AcceptButton.BUTTON_STYLE_CTA)
  self.ClusterNotificationPopup.AcceptButton:SetText("@ui_clusterwarning_accept")
  self.MergeInfoPopup.FrameHeader:SetTextAlignment(self.MergeInfoPopup.FrameHeader.TEXT_ALIGN_CENTER)
  self.MergeInfoPopup.LearnMoreButton:SetCallback(self.OnMergeLearnMoreClicked, self)
  self.MergeInfoPopup.LearnMoreButton:SetText("@ui_mergewarning_learn")
  self.MergeInfoPopup.CloseButton:SetCallback(self.OnMergeCloseClicked, self)
  self.MergeInfoPopup.AcceptButton:SetCallback(self.OnMergeCloseClicked, self)
  self.MergeInfoPopup.AcceptButton:SetButtonStyle(self.MergeInfoPopup.AcceptButton.BUTTON_STYLE_HERO)
  self.MergeInfoPopup.AcceptButton:SetText("@ui_ok")
  self.MergeInfoPopup.AcceptButton:StartStopImageSequence(true)
  self.MergeInfoPopup.CharEntry1:SetCharacterNameColor(self.UIStyle.COLOR_WHITE)
  self.MergeInfoPopup.CharEntry2:SetCharacterNameColor(self.UIStyle.COLOR_WHITE)
  self.MergeInfoPopup.CharEntry3:SetCharacterNameColor(self.UIStyle.COLOR_WHITE)
  self.landingTileDefaultImages = {
    {
      image = "lyshineui/images/landingscreen/newstiledefault1.dds"
    },
    {
      image = "lyshineui/images/landingscreen/newstiledefault2.dds"
    },
    {
      image = "lyshineui/images/landingscreen/newstiledefault3.dds"
    },
    {
      image = "lyshineui/images/landingscreen/newstiledefault4.dds"
    },
    {
      image = "lyshineui/images/landingscreen/newstiledefault5.dds"
    }
  }
  UiElementBus.Event.SetIsEnabled(self.Properties.LandingScreenNewsSpinnerHolder, false)
  self.ScriptedEntityTweener:Set(self.Properties.LandingScreenNewsSpinnerHolder, {opacity = 1})
  for i = 0, #self.Properties.LandingScreenNewsTiles do
    local landingNewsTile = self.Properties.LandingScreenNewsTiles[i]
    local landingNewsTileTable = self.registrar:GetEntityTable(landingNewsTile)
    local defaultTileImage = self.landingTileDefaultImages[i + 1].image
    local defaultTitle = "@ui_landing_tile_default_title" .. i + 1
    local defaultDescription = "@ui_landing_tile_default_description" .. i + 1
    landingNewsTileTable:SetImage(defaultTileImage)
    landingNewsTileTable:SetText(defaultTitle, defaultDescription)
    UiElementBus.Event.SetIsEnabled(landingNewsTile, false)
  end
  self.TwitchInfoPopup.FrameHeader:SetText("@twitch_link_title")
  self.TwitchInfoPopup.FrameHeader:SetTextAlignment(self.TwitchInfoPopup.FrameHeader.TEXT_ALIGN_CENTER)
  self.TwitchInfoPopup.AcceptButton:SetText("@ui_continue")
  self.TwitchInfoPopup.AcceptButton:SetButtonStyle(self.TwitchInfoPopup.AcceptButton.BUTTON_STYLE_CTA)
  self.TwitchInfoPopup.AcceptButton:SetCallback(function(self)
    self:SetTwitchScreenVisible(false)
    TwitchSystemRequestBus.Broadcast.StartTwitchLogin(true)
    self.requestedTwitchLogin = true
    self:StartTwitchSpinner()
  end, self)
  self.TwitchInfoPopup.DeclineButton:SetText("@ui_decline")
  self.TwitchInfoPopup.DeclineButton:SetCallback(function()
    self:SetTwitchScreenVisible(false)
  end, self)
  self.TwitchInfoPopup.CloseButton:SetCallback(function()
    self:SetTwitchScreenVisible(false)
  end, self)
  local enableBenchmark = self.dataLayer:GetDataFromNode("UIFeatures.g_enableBenchmark")
  local navButtonData
  if enableBenchmark then
    navButtonData = {
      {
        entityId = self.NavButton1,
        text = "",
        tooltip = "@ui_navmenu_quit",
        iconPath = "lyshineui/images/navbar/iconexitWhite.dds",
        callback = self.LandingExit
      },
      {
        entityId = self.NavButton2,
        text = "",
        tooltip = "@ui_navmenu_settings",
        iconPath = "lyshineui/images/navbar/iconsettingsWhite.dds",
        callback = self.LandingOptions
      },
      {
        entityId = self.NavButton3,
        text = "",
        tooltip = "@ui_navmenu_support",
        iconPath = "lyshineui/images/navbar/iconContactWhite.dds",
        callback = self.OnSupportPressed
      },
      {
        entityId = self.NavButton4,
        text = "",
        tooltip = "@ui_navmenu_benchmark",
        iconPath = "lyshineui/images/navbar/iconbenchmarkWhite.dds",
        callback = self.LandingBenchmark
      }
    }
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.NavButton4, false)
    navButtonData = {
      {
        entityId = self.NavButton1,
        text = "",
        tooltip = "@ui_navmenu_quit",
        iconPath = "lyshineui/images/navbar/iconexitWhite.dds",
        callback = self.LandingExit
      },
      {
        entityId = self.NavButton2,
        text = "",
        tooltip = "@ui_navmenu_settings",
        iconPath = "lyshineui/images/navbar/iconsettingsWhite.dds",
        callback = self.LandingOptions
      },
      {
        entityId = self.NavButton3,
        text = "",
        tooltip = "@ui_navmenu_support",
        iconPath = "lyshineui/images/navbar/iconContactWhite.dds",
        callback = self.OnSupportPressed
      }
    }
  end
  for i = 1, #navButtonData do
    local currentNavData = navButtonData[i]
    local currentNavButton = currentNavData.entityId
    currentNavButton:SetText("")
    currentNavButton:SetTooltip(currentNavData.tooltip)
    currentNavButton:SetIconPath(currentNavData.iconPath)
    currentNavButton:SetIconPositionX(0)
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
      tooltip = "",
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
end
function LandingScreen:WorldSelectionToggleOptions(isCollapsed, isWorldListOnly)
  if isWorldListOnly then
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListRecommendedTitle, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListRecommendedServer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListScreenContent, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListMoreOptions, false)
    self.ScriptedEntityTweener:Set(self.Properties.ServerContentBox, {h = 435})
    self.ScriptedEntityTweener:Set(self.Properties.ServerContentBoxMask, {h = 445})
    self.ScriptedEntityTweener:Stop(self.Properties.WorldSelectionListScreenContent)
    self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionListScreenHolder, 0.3, {h = 570, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionListScreenContent, 0.3, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.25
    })
    local maintenanceBypass = LyShineScriptBindRequestBus.Broadcast.IsMaintenanceBypass()
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListContinueButton, maintenanceBypass)
    self:SetWorldListItemsSelectable(maintenanceBypass)
    UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.ServerContentBox, 0)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListRecommendedTitle, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListRecommendedServer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListContinueButton, true)
    self.ScriptedEntityTweener:Set(self.Properties.ServerContentBox, {h = 435})
    self.ScriptedEntityTweener:Set(self.Properties.ServerContentBoxMask, {h = 445})
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListMoreOptions, false)
    self:SetWorldListItemsSelectable(true)
    if isCollapsed then
      local recommendedServerWorldId = self.WorldSelectionListRecommendedServer:GetWorldId()
      if recommendedServerWorldId then
        self:ChangeServerByWorldId(recommendedServerWorldId)
      end
      self.WorldSelectionListMoreOptions:SetText("@ui_world_select_more_options")
      self.WorldSelectionListMoreOptions:SetCallback(function()
        self:WorldSelectionToggleOptions(false)
      end, self)
      self.ScriptedEntityTweener:Stop(self.Properties.WorldSelectionListScreenContent)
      self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionListScreenHolder, 0.3, {h = 250, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionListScreenContent, 0.1, {
        opacity = 0,
        ease = "QuadOut",
        onComplete = function()
          UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListScreenContent, false)
        end
      })
    else
      self.WorldSelectionListMoreOptions:SetText("@ui_world_select_hide_options")
      self.WorldSelectionListMoreOptions:SetCallback(function()
        self:WorldSelectionToggleOptions(true)
      end, self)
      self.ScriptedEntityTweener:Stop(self.Properties.WorldSelectionListScreenContent)
      UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListScreenContent, true)
      self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionListScreenHolder, 0.3, {h = 730, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionListScreenContent, 0.3, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        delay = 0.25
      })
    end
  end
end
function LandingScreen:SetWorldListItemsSelectable(isSelectable)
  local childElements = UiElementBus.Event.GetChildren(self.Properties.ServerList)
  for i = 1, #childElements do
    local currentEntityId = childElements[i]
    local currentEntityTable = self.registrar:GetEntityTable(currentEntityId)
    currentEntityTable:SetIsSelectable(isSelectable)
  end
end
function LandingScreen:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.Properties.ScreenHolder, self.canvasId)
    AdjustElementToCanvasSize(self.Properties.ClusterNotificationPopup.Window, self.canvasId)
    AdjustElementToCanvasSize(self.Properties.MergeInfoPopup.Window, self.canvasId)
    AdjustElementToCanvasSize(self.Properties.DisplaySettingsMainBg, self.canvasId)
    AdjustElementToCanvasSize(self.Properties.BasicSettingsMainBg, self.canvasId)
    AdjustElementToCanvasSize(self.Properties.TwitchInfoPopup.Window, self.canvasId)
    AdjustElementToCanvasWidth(self.Properties.NavMenuBg, self.canvasId)
  end
end
function LandingScreen:OnShutdown()
  BaseScreen.OnShutdown(self)
  self:StopTwitchSpinner()
  timingUtils:StopDelay(self)
  DynamicContentBus.Broadcast.ClearCMSData(eCMSDataType_MarketingTiles)
  self.newsData = nil
  if self.Properties.StatusSpinnerEntity:IsValid() then
    self.ScriptedEntityTweener:Stop(self.Properties.StatusSpinnerEntity)
  end
  if self.Properties.WorldSpinnerEntity:IsValid() then
    self.ScriptedEntityTweener:Stop(self.Properties.WorldSpinnerEntity)
  end
  if self.Properties.CharacterServerLoadingSpinner:IsValid() then
    self.ScriptedEntityTweener:Stop(self.Properties.CharacterServerLoadingSpinner)
  end
  if self.Properties.LandingScreenNewsSpinner:IsValid() then
    self.ScriptedEntityTweener:Stop(self.Properties.LandingScreenNewsSpinner)
  end
  entitlementsDataHandler:RemoveOnEntitlementChangedCallback(self)
  self:SetCameraDof(false)
end
function LandingScreen:OnEnableExitSurveyChanged(isChecked)
  if not self.exitSurveyEnabled then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.ExitSurveyEnabled", isChecked)
  OptionsDataBus.Broadcast.SerializeOptions()
end
function LandingScreen:UpdateNewsTiles()
  if not self.newsData then
    return
  end
  for i = 0, #self.Properties.LandingScreenNewsTiles do
    local landingNewsTile = self.Properties.LandingScreenNewsTiles[i]
    local data = self.newsData[i + 1]
    UiElementBus.Event.SetIsEnabled(landingNewsTile, data ~= nil)
    if data then
      local landingNewsTileTable = self.registrar:GetEntityTable(landingNewsTile)
      if landingNewsTileTable then
        landingNewsTileTable:SetNewsData(data)
      end
    end
  end
end
function LandingScreen:OnLevelAsyncUnloadStart()
  UiMainMenuRequestBus.Broadcast.ShowLoadingScreen()
end
function LandingScreen:OnLevelLoadComplete()
  self.hasLevelLoadCompleted = true
  if self.queueIntroCinematic and not self.playButtonClicked then
    self:PlayOnTransitionInCinematic()
  end
  self.queueIntroCinematic = nil
end
function LandingScreen:PlayOnTransitionInCinematic()
  cinematicUtils:PlayCinematic(self.currentCinematic, self, nil)
end
function LandingScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.exitSurveyEnabled then
    local state = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Misc.ExitSurveyEnabled")
    self.ExitSurveyCheckbox:SetState(state)
  end
  self:CloseAllSubscreens()
  self:UpdateNewsTiles()
  if self.currentScreenState == self.SCREEN_STATE_CHARACTER_SELECT then
    self:SetScreenState(self.SCREEN_STATE_CHARACTER_SELECT, self.SCREEN_TRANSITION_FADE_IN)
  elseif self.currentScreenState == self.SCREEN_STATE_LANDING then
    self:SetScreenState(self.SCREEN_STATE_LANDING, self.SCREEN_TRANSITION_FADE_IN)
  else
    self:SetScreenIntro(self.SCREEN_STATE_LANDING, self.SCREEN_TRANSITION_INTRO, self.CINEMATIC_LANDING_INTRO)
    if self.hasLevelLoadCompleted then
      self:PlayOnTransitionInCinematic()
    else
      self.queueIntroCinematic = true
    end
  end
  self.playButtonClicked = false
  self.currentState = self.STATE_NONE
  self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  if self.optionsOpen then
    self.shown = true
  else
    self:BeginConnection()
  end
  self.optionsOpen = false
  if self.enablePopupEntitlements then
    self.entitlementBus = self:BusConnect(EntitlementNotificationBus)
    EntitlementRequestBus.Broadcast.SyncEntitlements()
  end
end
function LandingScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.playButtonClicked = false
  self.shown = false
  self:BusDisconnect(self.tickHandler)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.entitlementBus then
    self:BusDisconnect(self.entitlementBus)
    self.entitlementBus = nil
  end
end
function LandingScreen:SetNavHolderVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.NavMenuHolder, true)
    self.ScriptedEntityTweener:Play(self.Properties.NavMenuHolder, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.NavMenuHolder, 0.2, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.NavMenuHolder, false)
      end
    })
  end
end
function LandingScreen:SetScreenHeaderVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.ScreenHeader, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.ScreenHeader, 0.2, {opacity = 0, ease = "QuadOut"})
  end
end
function LandingScreen:SetNewWorldLogoVisible(isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.NewWorldLogo, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.NewWorldLogo, 0.2, {opacity = 0, ease = "QuadOut"})
  end
end
function LandingScreen:OnRefreshFocus()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonBg, 0.2, {opacity = 0.3, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.OnHover_LandingScreen)
end
function LandingScreen:OnRefreshUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonBg, 0.2, {opacity = 0.1, ease = "QuadOut"})
end
function LandingScreen:OnRefreshServerPress()
  if not self.isRefreshEnabled then
    return
  end
  self.ScriptedEntityTweener:Play(self.Properties.RefreshButtonIcon, 0.38, {rotation = 0}, {timesToPlay = 1, rotation = 359})
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnRefreshServerPress)
  if self.isRefreshButtonThrottled then
    return
  end
  self:BeginConnection()
  local throttleDelay = 15
  self.isRefreshButtonThrottled = true
  self:RefreshCharacterRefreshButtonEnabled()
  timingUtils:StopDelay(self, self.ResetRefreshServerButtonThrottle)
  timingUtils:Delay(throttleDelay, self, self.ResetRefreshServerButtonThrottle)
end
function LandingScreen:ResetRefreshServerButtonThrottle()
  self.isRefreshButtonThrottled = false
  self:RefreshCharacterRefreshButtonEnabled()
end
function LandingScreen:RefreshCharacterRefreshButtonEnabled()
  local isEnabled = self.isRefreshEnabled and not self.isRefreshButtonThrottled
  self.CharacterRefreshButton:SetEnabled(isEnabled)
  local hintText
  if self.isRefreshButtonThrottled then
    hintText = "@ui_server_refresh_throttle_hint"
  end
  self.CharacterRefreshButton:SetTooltip(hintText)
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
  self:SetTwitchScreenVisible(true)
end
function LandingScreen:SetTwitchScreenVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchInfoPopup.Window, true)
    self.ScriptedEntityTweener:Play(self.Properties.TwitchInfoPopup.PopupContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.TwitchInfoPopup.PopupScrim, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.TwitchInfoPopup.PopupContainer)
    self.ScriptedEntityTweener:Play(self.Properties.TwitchInfoPopup.PopupContainer, 0.3, {
      opacity = 0,
      y = -10,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.TwitchInfoPopup.Window, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.TwitchInfoPopup.PopupScrim, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function LandingScreen:OnTwitchLogoutPress()
  self.audioHelper:PlaySound(self.audioHelper.Accept)
  self.twitchPopupHandler = UiPopupNotificationsBus.Connect(self, self.popupTwitchLogoutEventId)
  TwitchSystemRequestBus.Broadcast.Logout()
end
function LandingScreen:OnLoginStateChangedScript(isLoggedIn)
  self:StopTwitchSpinner()
  if isLoggedIn then
    local twitchDisplayName = TwitchSystemRequestBus.Broadcast.GetTwitchDisplayName()
    self.TwitchLogoutButton:SetText(twitchDisplayName, true, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchLogoutButton, true)
    if self.requestedTwitchLogin then
      PopupWrapper:RequestPopup(ePopupButtons_OK, "@twitch_account_linked", "@twitch_account_linked_desc", "Popup_TwitchLoginSuccessMessage", self, function(self, result, eventId)
      end)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchButton, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TwitchLogoutButton, false)
    self.TwitchLogoutButton:SetText("", true, false)
  end
end
function LandingScreen:StartTwitchSpinner()
  if not self.isTwitchSpinning then
    self.TwitchButton:SetButtonSingleIconVisible(false)
    self.TwitchLogoutButton:SetButtonSingleIconVisible(false)
    self.ScriptedEntityTweener:Play(self.Properties.TwitchSpinner, 1, {rotation = 0, opacity = 1}, {timesToPlay = -1, rotation = 359})
    self.isTwitchSpinning = true
  end
end
function LandingScreen:StopTwitchSpinner()
  if self.isTwitchSpinning then
    self.ScriptedEntityTweener:Stop(self.Properties.TwitchSpinner)
    self.ScriptedEntityTweener:Set(self.Properties.TwitchSpinner, {rotation = 0, opacity = 0})
    self.isTwitchSpinning = false
    self.TwitchButton:SetButtonSingleIconVisible(true)
    self.TwitchLogoutButton:SetButtonSingleIconVisible(true)
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
  self.shown = true
  if self.authSuccess then
    self:RefreshWorldList()
    self:RefreshPurchasableCharacterSlotData()
  end
  self:ShowServerLoadingSpinner()
end
function LandingScreen:RefreshPurchasableCharacterSlotData()
  local charSlotData = entitlementsDataHandler:GetCharacterSlotEntitlementData()
  self.purchasedCharacterSlots = charSlotData.numEntitled
  self.maxPurchaseableSlots = charSlotData.numAvailable
  if not self.registeredInitEntitlementCallback then
    entitlementsDataHandler:AddOnEntitlementChangedCallback(self, self.OnCharacterSlotPurchased)
    self.registeredInitEntitlementCallback = true
  end
end
function LandingScreen:ShowServerLoadingSpinner(onCompleteCallback)
  self.ScriptedEntityTweener:Stop(self.Properties.ServerContentBoxHolder)
  self.ScriptedEntityTweener:Play(self.Properties.ServerContentBoxHolder, 0.3, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.CharacterServerLoadingText, 0.3, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ServerLoadingText, 0.3, {
    opacity = 1,
    ease = "QuadOut",
    onComplete = function()
      if onCompleteCallback then
        onCompleteCallback(self)
      end
    end
  })
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerTableHeader, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerLoadingText, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.FailedConnectionEntity, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterServerLoadingText, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterFailedConnectionEntity, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.RegionalCharacterCount, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerSortWorldSetTooltip, false)
  self:SetCharacterListVisible(false)
  self.isRefreshEnabled = false
  self:RefreshCharacterRefreshButtonEnabled()
end
function LandingScreen:SetCharacterListVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.CharacterList, true)
    self.ScriptedEntityTweener:Stop(self.Properties.CharacterList)
    self.ScriptedEntityTweener:Play(self.Properties.CharacterList, 0.3, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.CharacterListTitle, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.CharacterListTitle, 0.12, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.CharacterList, 0.12, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.CharacterList, false)
      end
    })
  end
end
function LandingScreen:LandingOptions()
  self.optionsOpen = true
  LyShineManagerBus.Broadcast.SetState(2717041095)
end
function LandingScreen:LandingBenchmark()
  self:EnableButtons(false)
  UiMainMenuRequestBus.Broadcast.StartBenchmark()
end
function LandingScreen:LandingExit()
  self.audioHelper:PlaySound(self.audioHelper.Cancel)
  PopupWrapper:RequestPopupWithParams({
    title = self.Properties.QuitPopupTitle,
    message = self.Properties.QuitPopupText,
    eventId = self.popupQuitEventId,
    callerSelf = self,
    callback = self.OnPopupResult,
    buttonsYesNo = true,
    showExitSurvey = self.exitSurveyEnabled,
    bottomPadding = self.exitSurveyEnabled and 30 or nil
  })
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
function LandingScreen:OnLandingPlayPressed(entityId, actionName)
  cinematicUtils:PlayCinematic(self.CINEMATIC_LANDING_TO_CHARACTER)
  local hasDoneFirstTimeLandingScreenComplete = self:GetHasDoneFirstTimeLandingScreen()
  if not hasDoneFirstTimeLandingScreenComplete then
    self:SetScreenState(self.SCREEN_STATE_WORLD_SELECT, self.SCREEN_TRANSITION_FORWARD)
  else
    self:SetScreenState(self.SCREEN_STATE_CHARACTER_SELECT, self.SCREEN_TRANSITION_FORWARD)
  end
end
function LandingScreen:OnSelectCharacterPlayPressed(entityId, actionName)
  if not self.selectedCharacterId or self.selectedCharacterId == "" then
    return
  end
  self.playButtonClicked = true
  self.PlayButton:SetEnabled(false)
  local currentCharacterData = self.currentCharacterData[self.selectedCharacterIndex]
  if currentCharacterData and self.shown and currentCharacterData.mustRename then
    self.renamePopupShown = true
    DynamicBus.RenamePopupBus.Broadcast.SetCallback("OnCharacterRename", self)
    DynamicBus.RenamePopupBus.Broadcast.OpenPopup(true, currentCharacterData.name, self.selectedCharacterId)
    return
  end
  self:EnableButtons(false)
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusSpinnerEntity, true)
  local worldType = "OpenWorld"
  if not self.currentCharacterData[self.selectedCharacterIndex].ftueCompleted then
    worldType = "FTUE"
  end
  self:SaveWorldName()
  GameRequestsBus.Broadcast.RequestLogin(self.selectedCharacterId, worldType)
  self.currentState = self.STATE_CONNECTING_TO_GAME
end
function LandingScreen:SaveWorldName(worldIdOverride)
  local characterWorldId = worldIdOverride
  if not characterWorldId then
    for i = 1, #self.currentCharacterData do
      if self.currentCharacterData[i].characterId == self.selectedCharacterId then
        characterWorldId = self.currentCharacterData[i].worldId
        break
      end
    end
  end
  for _, world in ipairs(self.worldList) do
    if world.worldData.worldId == characterWorldId then
      local name = world.worldData.name
      if name then
        LyShineManagerBus.Broadcast.SetWorldName(name)
      end
      local worldSetName = world.worldData.worldSet
      if worldSetName then
        LyShineDataLayerBus.Broadcast.SetData("WorldInfo.WorldSetName", worldSetName)
      end
      LyShineDataLayerBus.Broadcast.SetData("WorldInfo.WorldId", characterWorldId)
      LyShineDataLayerBus.Broadcast.SetData("WorldInfo.RegionName", self.ServerRegionDropdown:GetText())
    end
  end
end
function LandingScreen:OnCreateCharacterPressed(entityId, actionName)
  if self.worldList and #self.worldList == 0 then
    self:OnViewWorldListButtonPress()
    local title = "@mm_serverunavailable"
    local confirmation = "@mm_serverunavailable"
    PopupWrapper:RequestPopup(ePopupButtons_OK, title, confirmation, "noWorlds", self, function(self, result, eventId)
    end)
    return
  end
  local disableSkipWorldSelection = self.dataLayer:GetDataFromNode("UIFeatures.disableSkipWorldSelection")
  if not disableSkipWorldSelection and self.worldList[self.selectedWorldIndex].worldData.worldSet == "StubbedWorldSet" then
    self:RequestGoToIntro(true)
  else
    local noCharacterSlotsAvailableInAnyRegion = false
    local noSlotsInGoodRegions = false
    if self.characterNames then
      noCharacterSlotsAvailableInAnyRegion = true
      local charactersPerRegion = {}
      for j = 1, #self.characterNames do
        local regionId = self.characterNames[j].region
        if not charactersPerRegion[regionId] then
          charactersPerRegion[regionId] = 0
        end
        charactersPerRegion[regionId] = charactersPerRegion[regionId] + 1
      end
      local regionDropdownListItems = self.ServerRegionDropdown.mListItems
      for i = 1, #regionDropdownListItems do
        local regionData = regionDropdownListItems[i]
        local regionId = regionData.regionId
        local numCharsInRegion = charactersPerRegion[regionId] or 0
        if numCharsInRegion < self.maxCharactersPerRegion + self.purchasedCharacterSlots then
          noCharacterSlotsAvailableInAnyRegion = false
          break
        end
      end
      noSlotsInGoodRegions = true
      for i = 1, #regionDropdownListItems do
        local regionData = regionDropdownListItems[i]
        local regionId = regionData.regionId
        local regionLatencyMs = self.regionLatencyInfo[i]
        local isGoodRegion = regionLatencyMs < 200
        local numCharsInRegion = charactersPerRegion[regionId] or 0
        if isGoodRegion and numCharsInRegion < self.maxCharactersPerRegion + self.purchasedCharacterSlots then
          noSlotsInGoodRegions = false
          break
        end
      end
    else
      noCharacterSlotsAvailableInAnyRegion = false
    end
    if self.useWorldSetChecks and noCharacterSlotsAvailableInAnyRegion then
      self:OpenWorldSelectionWarning("@ui_landing_all_slots_full", false)
    elseif noSlotsInGoodRegions then
      self:OpenWorldSelectionWarning("@ui_landing_no_good_regions", true)
    else
      self:SetScreenState(self.SCREEN_STATE_WORLD_SELECT, self.SCREEN_TRANSITION_FADE_IN)
    end
  end
end
function LandingScreen:CheckCharacterCreationLimits()
  if not self.useWorldSetChecks then
    return true
  end
  local noCharacterSlotsInSpecificWorld = false
  local noCharacterSlotsInWorldSet = false
  local worldInfo = self:GetSelectedWorldInfo()
  if worldInfo then
    local maxAccountCharacters = worldInfo.worldData.maxAccountCharacters
    if maxAccountCharacters <= worldInfo.characterCount then
      noCharacterSlotsInSpecificWorld = true
    end
    local totalCharactersInWorldSet = 0
    local worldSet = worldInfo.worldData.worldSet
    for worldIndex, world in ipairs(self.worldList) do
      if world.worldData.worldSet == worldSet then
        totalCharactersInWorldSet = totalCharactersInWorldSet + world.characterCount
      end
    end
    if maxAccountCharacters <= totalCharactersInWorldSet then
      noCharacterSlotsInWorldSet = true
    end
    if noCharacterSlotsInSpecificWorld then
      self:OpenWorldSelectionWarning("@mm_loginservices_TooManyCharactersForWorld", false)
    elseif noCharacterSlotsInWorldSet then
      self:OpenWorldSelectionWarning("@mm_loginservices_TooManyCharactersForWorldSet", false)
    end
    return not noCharacterSlotsInSpecificWorld and not noCharacterSlotsInWorldSet
  end
end
function LandingScreen:OnBackButtonClicked()
  if self.isTransitioning then
    return
  end
  if self.isClusterNotificationVisible then
    self:OnClusterPopupCancel()
  elseif self.currentScreenState == self.SCREEN_STATE_WORLD_SELECT then
    local hasDoneFirstTimeLandingScreenComplete = self:GetHasDoneFirstTimeLandingScreen()
    if not hasDoneFirstTimeLandingScreenComplete then
      cinematicUtils:PlayCinematic(self.CINEMATIC_CHARACTER_TO_LANDING)
      self:SetScreenState(self.SCREEN_STATE_LANDING, self.SCREEN_TRANSITION_BACK)
    else
      self:SetScreenState(self.SCREEN_STATE_CHARACTER_SELECT, self.SCREEN_TRANSITION_FADE_IN)
    end
  elseif self.currentScreenState == self.SCREEN_STATE_CHARACTER_SELECT then
    cinematicUtils:PlayCinematic(self.CINEMATIC_CHARACTER_TO_LANDING)
    self:SetScreenState(self.SCREEN_STATE_LANDING, self.SCREEN_TRANSITION_BACK)
  end
end
function LandingScreen:CloseAllSubscreens()
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterSelectionScreen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionWarningScreen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListScreen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DisplaySettingsScreen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.BasicSettingsScreen, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.LandingScreen, false)
end
function LandingScreen:SetScreenIntro(screenState, transitionType, cinematic)
  self.currentCinematic = cinematic
  self.ScriptedEntityTweener:Play(self.Properties.BlackIntroReveal, 0.6, {opacity = 1}, {
    opacity = 0,
    ease = "QuadOut",
    delay = 1,
    onComplete = function()
      self:SetScreenState(screenState, transitionType)
    end
  })
end
function LandingScreen:SetScreenState(state, transitionType, extraParams)
  local currentScreen
  self.currentScreenState = state
  if state == self.SCREEN_STATE_LANDING then
    currentScreen = self.Properties.LandingScreen
    self:OpenLandingScreen()
    self:ForceSelectServerBasedOnCharacter()
  elseif state == self.SCREEN_STATE_CHARACTER_SELECT then
    currentScreen = self.Properties.CharacterSelectionScreen
    self:OpenCharacterSelection()
    self:ForceSelectServerBasedOnCharacter()
  elseif state == self.SCREEN_STATE_WORLD_SELECT then
    currentScreen = self.Properties.WorldSelectionListScreen
    self:OpenWorldSelectList(extraParams and extraParams.isWorldListOnly)
  elseif state == self.SCREEN_STATE_BASIC_SETTINGS then
    currentScreen = self.Properties.BasicSettingsScreen
  elseif state == self.SCREEN_STATE_DISPLAY_SETTINGS then
    currentScreen = self.Properties.DisplaySettingsScreen
  end
  if self.currentScreen ~= currentScreen then
    self.previousScreen = self.currentScreen
    self.currentScreen = currentScreen
    if self.previousScreen ~= nil then
      self:SetScreenVisible(self.previousScreen, false, transitionType)
    end
  end
  self:SetScreenVisible(self.currentScreen, true, transitionType)
end
function LandingScreen:SetScreenVisible(screen, isVisible, transitionType)
  if isVisible then
    self.isTransitioning = true
    UiElementBus.Event.SetIsEnabled(self.currentScreen, true)
    if transitionType == self.SCREEN_TRANSITION_INTRO then
      self.ScriptedEntityTweener:Play(self.currentScreen, 1, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        onComplete = function()
          self.isTransitioning = false
        end
      })
    elseif transitionType == self.SCREEN_TRANSITION_FORWARD then
      self.ScriptedEntityTweener:Play(self.currentScreen, 0.6, {opacity = 0, x = 600}, {
        opacity = 1,
        x = 0,
        delay = 0.4,
        ease = "QuadOut",
        onComplete = function()
          self.isTransitioning = false
        end
      })
    elseif transitionType == self.SCREEN_TRANSITION_BACK then
      self.ScriptedEntityTweener:Play(self.currentScreen, 0.6, {opacity = 0, x = -600}, {
        opacity = 1,
        x = 0,
        delay = 0.3,
        ease = "QuadOut",
        onComplete = function()
          self.isTransitioning = false
        end
      })
    elseif transitionType == self.SCREEN_TRANSITION_FADE_IN then
      self.ScriptedEntityTweener:Play(self.currentScreen, 0.3, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        onComplete = function()
          self.isTransitioning = false
        end
      })
    elseif transitionType == self.SCREEN_TRANSITION_NONE then
      self.ScriptedEntityTweener:Play(self.currentScreen, 0.3, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        onComplete = function()
          self.isTransitioning = false
        end
      })
    end
  elseif transitionType == self.SCREEN_TRANSITION_INTRO then
    self.ScriptedEntityTweener:Play(self.previousScreen, 1, {opacity = 1}, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.previousScreen, false)
      end
    })
  elseif transitionType == self.SCREEN_TRANSITION_FORWARD then
    self.ScriptedEntityTweener:Play(self.previousScreen, 0.5, {opacity = 1, x = 0}, {
      opacity = 0,
      x = -600,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.previousScreen, false)
      end
    })
  elseif transitionType == self.SCREEN_TRANSITION_BACK then
    self.ScriptedEntityTweener:Play(self.previousScreen, 0.5, {opacity = 1, x = 0}, {
      opacity = 0,
      x = 600,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.previousScreen, false)
      end
    })
  elseif transitionType == self.SCREEN_TRANSITION_FADE_IN then
    self.ScriptedEntityTweener:Play(self.previousScreen, 0.3, {opacity = 1}, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.previousScreen, false)
      end
    })
  elseif transitionType == self.SCREEN_TRANSITION_NONE then
    self.ScriptedEntityTweener:Play(self.previousScreen, 0.5, {
      opacity = 1,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.previousScreen, false)
      end
    })
  end
end
function LandingScreen:OpenLandingScreen()
  self:SetNewWorldLogoVisible(true)
  self:SetNavHolderVisible(true)
  self:SetScreenHeaderVisible(false)
  self.ScreenHeader:SetBgVisible(false, 0.3)
  self:SetCharacterVisibilityOverride(false)
end
function LandingScreen:OpenCharacterSelection()
  self:SetNewWorldLogoVisible(false)
  self:SetNavHolderVisible(true)
  self:SetScreenHeaderVisible(true)
  self.ScreenHeader:SetText("@ui_character_Select_title")
  self.ScreenHeader:SetBgVisible(false, 0.3)
  self:SetCharacterVisibilityOverride(false)
end
function LandingScreen:OpenWorldSelectionWarning(warningText, showButton)
  UiTextBus.Event.SetTextWithFlags(self.Properties.WorldSelectionWarningScreenText, warningText, eUiTextSet_SetLocalized)
  if showButton then
    self.WorldSelectionWarningScreenButton1:SetText("@ui_world_select_select_world")
    self.WorldSelectionWarningScreenButton1:SetCallback(function(self)
      self:SetScreenState(self.SCREEN_STATE_WORLD_SELECT, self.SCREEN_TRANSITION_FADE_IN)
      self:SetWorldSelectionWarningVisible(false)
    end, self)
    self.WorldSelectionWarningScreenButton2:SetText("@ui_close")
    self.WorldSelectionWarningScreenButton2:SetCallback(function(self)
      self:SetWorldSelectionWarningVisible(false)
    end, self)
    self.ScriptedEntityTweener:Set(self.Properties.WorldSelectionWarningScreenButton1, {x = -140})
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionWarningScreenButton1, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionWarningScreenButton2, true)
  else
    self.WorldSelectionWarningScreenButton1:SetText("@ui_close")
    self.WorldSelectionWarningScreenButton1:SetCallback(function(self)
      self:SetWorldSelectionWarningVisible(false)
    end, self)
    self.ScriptedEntityTweener:Set(self.Properties.WorldSelectionWarningScreenButton1, {x = 0})
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionWarningScreenButton2, false)
  end
  self.WorldSelectionWarningScreenButtonClose:SetCallback(function(self)
    self:SetWorldSelectionWarningVisible(false)
  end, self)
  self:SetWorldSelectionWarningVisible(true)
end
function LandingScreen:SetWorldSelectionWarningVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionWarningScreen, true)
    self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionWarningScreenPopupContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionWarningScreenPopupScrim, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.WorldSelectionWarningScreen)
    self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionWarningScreenPopupContainer, 0.3, {
      opacity = 0,
      y = -10,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionWarningScreen, false)
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.WorldSelectionWarningScreenPopupScrim, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function LandingScreen:OpenWorldSelectList(isWorldListOnly)
  self.isWorldListOnly = isWorldListOnly
  self:SetNewWorldLogoVisible(false)
  self:SetNavHolderVisible(false)
  self:SetScreenHeaderVisible(true)
  self.ScreenHeader:SetBgVisible(true, 0.3)
  UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListScreen, true)
  local screenTitle = isWorldListOnly and "@ui_world_select_view_worlds" or "@ui_world_select_title"
  self.ScreenHeader:SetText(screenTitle)
  if isWorldListOnly then
    self:WorldSelectionToggleOptions(nil, true)
  else
    self.stopRefreshRecommendedServer = false
    self:SetRecommendedServer()
    self.stopRefreshRecommendedServer = true
    self:WorldSelectionToggleOptions(false)
    self:SetCharacterVisibilityOverride(true)
  end
end
function LandingScreen:SetRecommendedServer()
  local forceSelectRecommendedServer = true
  if self.stopRefreshRecommendedServer then
    forceSelectRecommendedServer = false
    local currentRecommended = self.WorldSelectionListRecommendedServer.worldInfo
    if currentRecommended then
      local isCurrentRecommendedAvailable = false
      for i = 1, #self.worldList do
        local world = self.worldList[i]
        if world.worldData.worldId == currentRecommended.worldData.worldId then
          isCurrentRecommendedAvailable = true
          break
        end
      end
      if not isCurrentRecommendedAvailable then
        forceSelectRecommendedServer = true
      end
    end
  end
  local selectableWorlds = {}
  for i = 1, #self.worldList do
    local world = self.worldList[i]
    if self:WorldIsSelectable(world) and world.characterName == worldListCommon.defaultWorldCharName then
      table.insert(selectableWorlds, world)
    end
  end
  if 0 < #selectableWorlds then
    table.sort(selectableWorlds, worldListCommon:GetSortByRecommendedWorld())
    local selectedWorld = selectableWorlds[1]
    local isRecommendedDown = selectedWorld.worldData.publicStatusCode ~= 0
    local hasFriends = 0 < selectedWorld.numFriends
    local hasBeenPlayed = 0 < selectedWorld.lastPlayed
    if not isRecommendedDown and not hasFriends and not hasBeenPlayed then
      local queueSizeDiffTolerance = selectedWorld.worldData.worldMetrics.queueSize * (self.dataLayer:GetDataFromNode("UIFeatures.landingScreenSimilarServersQueueSizePercentage") or 0.5)
      queueSizeDiffTolerance = math.max(queueSizeDiffTolerance, 0)
      local isWorldFull = selectedWorld.worldData.connectionCount >= selectedWorld.worldData.maxConnectionCount
      local numSelectableWorlds = #selectableWorlds
      local lastIndexOfSimilarWorlds = 1
      for i = 2, numSelectableWorlds do
        local otherWorld = selectableWorlds[i]
        local otherWorldFull = otherWorld.worldData.connectionCount >= otherWorld.worldData.maxConnectionCount
        local isDown = otherWorld.worldData.publicStatusCode ~= 0
        local queueSizeDiff = math.abs(otherWorld.worldData.worldMetrics.queueSize - selectedWorld.worldData.worldMetrics.queueSize)
        local isSimilarPopulation = math.abs(otherWorld.populationCount - selectedWorld.populationCount) <= worldListCommon.populationTolerance
        if not isDown and isSimilarPopulation and queueSizeDiffTolerance >= queueSizeDiff and isWorldFull == otherWorldFull then
          lastIndexOfSimilarWorlds = i
        else
          break
        end
      end
      math.randomseed(os.time())
      math.random()
      math.random()
      math.random()
      local randomWorldIndex = math.random(1, lastIndexOfSimilarWorlds)
      selectedWorld = selectableWorlds[randomWorldIndex]
      selectedWorld = selectedWorld or selectableWorlds[1]
    end
    self.WorldSelectionListRecommendedServer:SetWorldInfo(selectedWorld)
    if forceSelectRecommendedServer then
      self:ChangeServerByWorldId(selectedWorld.worldData.worldId)
    end
  elseif #self.worldList > 0 then
    self.WorldSelectionListRecommendedServer:SetWorldInfo(self.worldList[1])
    self:ChangeServerByWorldId(self.worldList[1].worldData.worldId)
  end
end
function LandingScreen:RequestGoToIntro(skipMaintenanceModeCheck)
  if not skipMaintenanceModeCheck then
    local maintenanceBypass = LyShineScriptBindRequestBus.Broadcast.IsMaintenanceBypass()
    if not maintenanceBypass then
      if self.worldIsOnlineButUnavailable then
        local title = "@mm_serverdown"
        local confirmation = "@mm_loginservices_worldmaintenance"
        PopupWrapper:RequestPopup(ePopupButtons_OK, title, confirmation, "maintenance", self, function(self, result, eventId)
        end)
        return
      end
      if self:IsWorldCharacterCreationDisabled(self.selectedWorldId) then
        local title = "@ui_world_select_change_selection"
        local confirmation = "@mm_characterCreateDisabled"
        PopupWrapper:RequestPopup(ePopupButtons_OK, title, confirmation, "charCreateDisabled", self, function(self, result, eventId)
        end)
        return
      end
    end
  end
  local hasDoneFirstTimeLandingScreenComplete = self:GetHasDoneFirstTimeLandingScreen()
  if not hasDoneFirstTimeLandingScreenComplete then
    self:OpenBasicSettingsScreen()
  else
    self:StartIntro()
  end
end
function LandingScreen:OpenBasicSettingsScreen()
  if not self.basicSettingsItems then
    self.basicSettingsData = {
      {
        text = "@ui_invertcamera",
        desc = "@ui_invertlook_desc",
        dataNode = "Controls.InvertLook",
        inputType = "Toggle",
        callback1 = "DisableInvertLook",
        callback2 = "EnableInvertLook",
        inputText1 = "@ui_off",
        inputText2 = "@ui_on"
      },
      {
        text = "@ui_profanity_filter",
        desc = "@ui_profanity_filter_desc",
        dataNode = "Accessibility.ChatProfanityFilter",
        inputType = "Toggle",
        callback1 = "DisableChatProfanityFilter",
        callback2 = "EnableChatProfanityFilter",
        inputText1 = "@ui_off",
        inputText2 = "@ui_on"
      },
      {
        text = "@ui_texttospeech",
        desc = "@ui_texttospeech_desc",
        dataNode = "Accessibility.TTS",
        inputType = "Toggle",
        callback1 = "DisableTTS",
        callback2 = "EnableTTS",
        inputText1 = "@ui_off",
        inputText2 = "@ui_on",
        featureFlag = "UIFeatures.enable-tts"
      },
      {
        text = "@ui_speechtotext",
        desc = "@ui_speechtotext_desc",
        dataNode = "Accessibility.SpeechToText",
        inputType = "Toggle",
        callback1 = "DisableSpeechToText",
        callback2 = "EnableSpeechToText",
        inputText1 = "@ui_off",
        inputText2 = "@ui_on",
        featureFlag = "UIFeatures.enable-speechToText"
      },
      {
        text = "@ui_subtitles",
        desc = "@ui_subtitles_desc",
        dataNode = "Accessibility.Subtitles",
        inputType = "Toggle",
        callback1 = "DisableSubtitles",
        callback2 = "EnableSubtitles",
        inputText1 = "@ui_off",
        inputText2 = "@ui_on"
      },
      {
        text = "@ui_colorBlindness",
        desc = "@ui_colorBlindness_desc",
        dataNode = "Accessibility.ColorBlindness",
        inputType = "Dropdown",
        callback = "SetColorBlindness",
        dropdownData = {
          {
            text = "@ui_options_ColorBlindness_NoFilter",
            data = 0
          },
          {
            text = "@ui_options_ColorBlindness_Protanopia",
            data = 1
          },
          {
            text = "@ui_options_ColorBlindness_Protanomaly",
            data = 2
          },
          {
            text = "@ui_options_ColorBlindness_Deuteranopia",
            data = 3
          },
          {
            text = "@ui_options_ColorBlindness_Deuteranomaly",
            data = 4
          },
          {
            text = "@ui_options_ColorBlindness_Tritanopia",
            data = 5
          },
          {
            text = "@ui_options_ColorBlindness_Tritanomaly",
            data = 6
          },
          {
            text = "@ui_options_ColorBlindness_Achromatopsia",
            data = 7
          },
          {
            text = "@ui_options_ColorBlindness_Achromatomaly",
            data = 8
          }
        }
      }
    }
    self.basicSettingsItems = {
      self.BasicSettingsListItem
    }
    local prototypeTable = self.BasicSettingsListItem
    local entityParentId = UiElementBus.Event.GetParent(prototypeTable.entityId)
    for i = 2, #self.basicSettingsData do
      local cloneTable = CloneUiElement(self.canvasId, self.registrar, prototypeTable.entityId, entityParentId, true)
      table.insert(self.basicSettingsItems, cloneTable)
    end
    self:SetBasicSettingItems()
  end
  self:SetScreenState(self.SCREEN_STATE_BASIC_SETTINGS, self.SCREEN_TRANSITION_FADE_IN)
end
function LandingScreen:SetBasicSettingItems()
  for index, data in ipairs(self.basicSettingsData) do
    local settingsTable = self.basicSettingsItems[index]
    settingsTable:SetText(data.text)
    settingsTable:SetTextDescription(data.desc)
    settingsTable:SetInputType(data.inputType)
    local toggleEntity = UiElementBus.Event.FindDescendantByName(settingsTable.entityId, "Toggle")
    local dropdownEntity = UiElementBus.Event.FindDescendantByName(settingsTable.entityId, "Dropdown")
    if data.inputType == "Toggle" then
      UiElementBus.Event.SetIsEnabled(dropdownEntity, false)
      local toggleTable = self.registrar:GetEntityTable(toggleEntity)
      if toggleTable then
        toggleTable:SetCallback(data.callback1, data.callback2, self)
        toggleTable:SetText(data.inputText1, data.inputText2)
        toggleTable:SetWidth(380)
        local dataPath = string.format("%s.%s", "Hud.LocalPlayer.Options", data.dataNode)
        local initialVal = self.dataLayer:GetDataFromNode(dataPath) or 0
        toggleTable:InitToggleState(initialVal)
        toggleTable:SetDataNode(dataPath)
      end
    elseif data.inputType == "Dropdown" then
      UiElementBus.Event.SetIsEnabled(toggleEntity, false)
      local dropdownTable = self.registrar:GetEntityTable(dropdownEntity)
      if dropdownTable then
        dropdownTable:SetDropdownScreenCanvasId(self.entityId)
        dropdownTable:SetListData(data.dropdownData)
        dropdownTable:SetCallback(function(tableSelf, entityId, data)
          OptionsDataBus.Broadcast.SetColorBlindness(data.data)
        end, self)
        local colorBlindnessValue = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Accessibility.ColorBlindness") or 0
        colorBlindnessValue = colorBlindnessValue + 1
        local initialDropdownText = data.dropdownData[colorBlindnessValue].text
        dropdownTable:SetText(initialDropdownText)
        dropdownTable:SetDropdownListHeightByRows(5)
      end
    end
  end
end
function LandingScreen:EnableInvertLook()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.InvertLook", true)
end
function LandingScreen:DisableInvertLook()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Controls.InvertLook", false)
end
function LandingScreen:EnableChatProfanityFilter()
  self:SendChatProfanityFilterTelemetry(true)
  OptionsDataBus.Broadcast.SetChatProfanityFilter(true)
end
function LandingScreen:DisableChatProfanityFilter()
  self:SendChatProfanityFilterTelemetry(false)
  OptionsDataBus.Broadcast.SetChatProfanityFilter(false)
end
function LandingScreen:SendChatProfanityFilterTelemetry(enable)
  local event = UiAnalyticsEvent("change_profanity_filter")
  event:AddAttribute("Enable", enable and 1 or 0)
  event:Send()
end
function LandingScreen:EnableTTS()
  OptionsDataBus.Broadcast.SetTTSEnabled(true)
  local event = UiAnalyticsEvent("text_to_speech")
  event:AddAttribute("enabled", 1)
  event:Send()
end
function LandingScreen:DisableTTS()
  OptionsDataBus.Broadcast.SetTTSEnabled(false)
  local event = UiAnalyticsEvent("text_to_speech")
  event:AddAttribute("enabled", 0)
  event:Send()
end
function LandingScreen:EnableSpeechToText()
  OptionsDataBus.Broadcast.SetSpeechToTextEnabled(true)
  local event = UiAnalyticsEvent("speech_to_text")
  event:AddAttribute("enabled", 1)
  event:Send()
end
function LandingScreen:DisableSpeechToText()
  OptionsDataBus.Broadcast.SetSpeechToTextEnabled(false)
  local event = UiAnalyticsEvent("speech_to_text")
  event:AddAttribute("enabled", 0)
  event:Send()
end
function LandingScreen:EnableSubtitles()
  OptionsDataBus.Broadcast.SetSubtitles(true)
end
function LandingScreen:DisableSubtitles()
  OptionsDataBus.Broadcast.SetSubtitles(false)
end
function LandingScreen:RestoreBasicSettings()
  OptionsDataBus.Broadcast.ResetGameplaySettings()
  OptionsDataBus.Broadcast.ResetPreferencesSettings()
  OptionsDataBus.Broadcast.ResetAccessibilitySettings()
  self:SetBasicSettingItems()
end
function LandingScreen:OpenDisplaySettingsScreen()
  local brightnessSettings = {
    text = "@ui_options_brightness",
    desc = "@ui_options_brightness_desc",
    dataNode = "Video.Brightness",
    callback = "SetBrightness",
    minValue = 30,
    maxValue = 80,
    featureFlag = "UIFeatures.g_uiEnableBrightnessSettings",
    displayToGameFunc = function(percentage)
      return percentage / 100
    end,
    gameToDisplayFunc = function(percentage)
      return percentage * 100
    end
  }
  local contrastSettings = {
    text = "@ui_options_contrast",
    desc = "@ui_options_contrast_desc",
    dataNode = "Video.Contrast",
    callback = "SetContrast",
    minValue = 10,
    maxValue = 80,
    featureFlag = "UIFeatures.g_uiEnableContrastSettings",
    displayToGameFunc = function(percentage)
      return percentage / 100
    end,
    gameToDisplayFunc = function(percentage)
      return percentage * 100
    end
  }
  self:SetupDisplaySlider(brightnessSettings, self.DisplaySettingsBrightnessSlider)
  self:SetupDisplaySlider(contrastSettings, self.DisplaySettingsContrastSlider)
  self:SetScreenState(self.SCREEN_STATE_DISPLAY_SETTINGS, self.SCREEN_TRANSITION_NONE)
  self.ScriptedEntityTweener:Play(self.Properties.DisplaySettingsContentHolder, 1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function LandingScreen:SetupDisplaySlider(settingsData, sliderTable)
  sliderTable:SetLabel(settingsData.text)
  sliderTable:SetCallback(settingsData.callback, self)
  sliderTable.Slider:SetDisplayToGameDataFunc(settingsData.displayToGameFunc)
  local sliderVal = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options." .. settingsData.dataNode) or 0
  sliderVal = settingsData.gameToDisplayFunc(sliderVal)
  sliderTable:SetSliderMinValue(settingsData.minValue)
  sliderTable:SetSliderMaxValue(settingsData.maxValue or 100)
  sliderTable:SetSliderValue(sliderVal)
  sliderTable:HideCrownIcons()
  if settingsData.dataNode == "Video.Brightness" then
    self.settingsBrightnessDefault = sliderVal
  end
  if settingsData.dataNode == "Video.Contrast" then
    self.settingsConstrastDefault = sliderVal
  end
end
function LandingScreen:SetBrightness(entity)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  if 0 <= sliderVal then
    if entity:GetDisplayToGameDataFunc() then
      sliderVal = entity:GetDisplayToGameDataFunc()(sliderVal)
    end
    OptionsDataBus.Broadcast.SetBrightness(sliderVal)
  end
end
function LandingScreen:SetContrast(entity)
  local sliderVal = UiSliderBus.Event.GetValue(entity.entityId)
  if 0 <= sliderVal then
    if entity:GetDisplayToGameDataFunc() then
      sliderVal = entity:GetDisplayToGameDataFunc()(sliderVal)
    end
    OptionsDataBus.Broadcast.SetContrast(sliderVal)
  end
end
function LandingScreen:ConfirmServerSelectionChange()
  local canCreateCharacter = self:CheckCharacterCreationLimits()
  if not canCreateCharacter then
    return
  end
  local titleText = GetLocalizedReplacementText("@ui_clusterwarning_title", {
    worldName = self.worldList[self.selectedWorldIndex].worldData.name
  })
  local warningText = GetLocalizedReplacementText("@ui_clusterwarning_warning", {
    worldSetName = self.worldList[self.selectedWorldIndex].worldSetName,
    colorHex1 = ColorRgbaToHexString(self.UIStyle.COLOR_TAN_LIGHT),
    colorHex2 = ColorRgbaToHexString(self.UIStyle.COLOR_WHITE)
  })
  local description1Text = GetLocalizedReplacementText("@ui_clusterwarning_description1", {
    worldName = self.worldList[self.selectedWorldIndex].worldData.name,
    worldSetName = self.worldList[self.selectedWorldIndex].worldSetName
  })
  local description2Text = GetLocalizedReplacementText("@ui_clusterwarning_description2", {
    worldSetName = self.worldList[self.selectedWorldIndex].worldSetName
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.ClusterNotificationPopup.Title, titleText, eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ClusterNotificationPopup.PopupWarning, warningText, eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ClusterNotificationPopup.PopupDescription1, description1Text, eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ClusterNotificationPopup.PopupDescription2, description2Text, eUiTextSet_SetAsIs)
  local imagePath = self.clusterNotificationImagePathRoot .. self.worldList[self.selectedWorldIndex].imageId .. ".dds"
  UiImageBus.Event.SetSpritePathname(self.Properties.ClusterNotificationPopup.PopupImage, imagePath)
  self:SetClusterNotificationPopupVisible(true)
end
function LandingScreen:OnDisplaySettingsContinue()
  self.ScriptedEntityTweener:Play(self.Properties.BlackIntroReveal, 0.6, {
    opacity = 1,
    ease = "QuadOut",
    onComplete = function()
      self:StartIntro()
    end
  })
end
function LandingScreen:RestoreDisplaySettings()
  OptionsDataBus.Broadcast.ResetVisualSettings()
  if self.settingsBrightnessDefault then
    self.DisplaySettingsBrightnessSlider:SetSliderValue(self.settingsBrightnessDefault)
  end
  if self.settingsConstrastDefault then
    self.DisplaySettingsContrastSlider:SetSliderValue(self.settingsConstrastDefault)
  end
end
function LandingScreen:StartIntro()
  self:EnableButtons(false)
  self:SaveWorldName(self.selectedWorldId)
  UiMainMenuRequestBus.Broadcast.StartIntro()
  self:ClearFirstTimeLandingScreen()
end
function LandingScreen:RefreshPurchaseSlotButton()
  self:RefreshPurchasableCharacterSlotData()
  local numOfCharacters = self.characterData and #self.characterData or 0
  local canPurchaseMore = numOfCharacters < self.maxCharactersPerRegion + self.maxPurchaseableSlots
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterPurchaseButtonHolder, self.isPurchaseCharacterSlotEnabled)
  if self.isPurchaseCharacterSlotEnabled then
    if canPurchaseMore then
      self.CharacterPurchaseSlotButton:SetCreateCharacterCallback(self.OnCharacterPurchaseSlotPressed, self)
      self.CharacterPurchaseSlotButton:SetSlotStatus(self.CharacterPurchaseSlotButton.CHARSTATUS_CANCREATE)
    else
      self.CharacterPurchaseSlotButton:SetCreateCharacterCallback("")
      self.CharacterPurchaseSlotButton:SetSlotStatus(self.CharacterPurchaseSlotButton.CHARSTATUS_PURCHASE_LOCKED)
    end
  end
end
function LandingScreen:OnCharacterPurchaseSlotPressed(entityId, actionName)
  entitlementsDataHandler:StartCharacterSlotPurchase(self, self.OnCharacterSlotPurchased)
end
function LandingScreen:OnCharacterSlotPurchased()
  if not (self.shown and self.worldListReady) or not self.characterDataReady then
    return
  end
  self:RefreshPurchaseSlotButton()
  self:PopulateCharacterSelectionList()
end
function LandingScreen:OnCharacterDeletePressed(entityId, actionName)
  if not (not (self.selectedCharacterIndex <= 0) and self.enableButtons) or UiElementBus.Event.IsEnabled(self.Properties.StatusSpinnerEntity) then
    return
  end
  self:EnableButtons(false)
  local currentCharacterData = self.currentCharacterData[self.selectedCharacterIndex]
  if currentCharacterData then
    local event = UiAnalyticsEvent("DeleteCharacter")
    event:AddAttribute("character_id", currentCharacterData.characterId)
    event:AddAttribute("player", currentCharacterData.name)
    event:AddAttribute("world_id", currentCharacterData.worldId)
    event:Send()
  end
  self.deletePopupOpen = true
  local placeholderText = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_confirm_delete_character_placeholder")
  PopupWrapper:RequestPopupWithParams({
    title = self.Properties.DeletePopupTitle,
    message = GetLocalizedReplacementText(self.Properties.DeletePopupText, {
      characterName = self.currentCharacterData[self.selectedCharacterIndex].name
    }),
    eventId = self.popupDeleteEventId,
    callerSelf = self,
    callback = self.OnPopupResult,
    buttonsYesNo = true,
    yesButtonText = "@mm_deletechartitle",
    noButtonText = "@ui_cancel",
    customData = {
      {
        detailType = "TextInput",
        label = "",
        value = {
          placeholderText = placeholderText,
          callerSelf = self,
          onChangeCallback = function(callerSelf, popupRef, currentText)
            if self.selectedCharacterIndex > 0 then
              local currentCharacterData = self.currentCharacterData[self.selectedCharacterIndex]
              local enableButton = string.lower(currentText) == string.lower(currentCharacterData.name)
              self.canDeleteChar = enableButton
              popupRef.ButtonYes:SetEnabled(enableButton)
            end
          end
        }
      }
    }
  })
end
function LandingScreen:WorldIsSelectable(worldInfo)
  if not worldInfo then
    return false
  end
  local status = worldInfo.worldData.status
  local publicStatus = worldInfo.worldData.publicStatusCode
  local isDisabled = status ~= "ACTIVE" or bitHelpers:TestFlag(publicStatus, bitHelpers.SERVERSTATUS_DISABLED)
  return not isDisabled
end
function LandingScreen:GetWorldMessageForCharacter(charData)
  if self.worldCMSList and self.worldCMSList.worldDescriptions then
    for i = 1, #self.worldCMSList.worldDescriptions do
      if self.worldCMSList.worldDescriptions[i].worldId == charData.worldId then
        return self.worldCMSList.worldDescriptions[i].motd
      end
    end
  end
end
function LandingScreen:PopulateWorldSelectionList(entityId, actionName)
  self.pendingWorldMergeListDataNode = self.dataLayer:Call(225285239)
  if not self.hasShownMergeWarning and self:HasRecentlyMergedCharacter() then
    self.hasShownMergeWarning = true
    self:OpenMergePopup(self.MERGE_POPUP_POSTMERGE, self.MERGE_POPUP_RETURN_MAIN)
  end
  if not self.hasShownMergeWarning then
    local mergingCharacters = {}
    local pendingWorldList = self.pendingWorldMergeListDataNode:GetData()
    for i = 1, #pendingWorldList do
      local mergingWorldId = pendingWorldList[i].sourceWorldId
      for j = 1, #self.characterData do
        local character = self.characterData[j]
        if character.worldId == mergingWorldId then
          local mergeTime = worldListCommon:ParseDate(pendingWorldList[i].mergeTime)
          table.insert(mergingCharacters, {characterData = character, mergeTime = mergeTime})
        end
      end
    end
    if 0 < #mergingCharacters then
      local charEntries = {
        self.Properties.MergeInfoPopup.CharEntry1,
        self.Properties.MergeInfoPopup.CharEntry2,
        self.Properties.MergeInfoPopup.CharEntry3
      }
      for index, characterEntry in ipairs(charEntries) do
        local data = mergingCharacters[index]
        if data then
          local charInfoBox = self.registrar:GetEntityTable(characterEntry)
          local characterData = data.characterData
          local worldName = ""
          local characterWorldId = characterData.worldId
          for _, world in ipairs(self.worldList) do
            if world.worldData.worldId == characterWorldId then
              worldName = world.worldData.name
              break
            end
          end
          local region = ""
          if self.characterNames then
            for j = 1, #self.characterNames do
              if characterData.name == self.characterNames[j].name then
                local regionId = self.characterNames[j].region
                if self.characterNameRegionIdsToName then
                  region = self.characterNameRegionIdsToName[regionId]
                  break
                end
                region = regionId
                break
              end
            end
          end
          charInfoBox:SetSlotStatus(charInfoBox.CHARSTATUS_ACTIVE)
          charInfoBox:SetCharacterInfo(characterData.name, characterData.characterId, characterData.currentLevel)
          charInfoBox:SetMergeTime(data.mergeTime)
          charInfoBox:SetWorldInfoText(worldName)
          charInfoBox:SetRegionText(region)
          charInfoBox:SetWorldMessageTooltip(self:GetWorldMessageForCharacter(characterData))
        end
        UiElementBus.Event.SetIsEnabled(characterEntry, data ~= nil)
        local dividerPosY = 306
        if index == #charEntries and data ~= nil then
          dividerPosY = 362
        end
        UiTransformBus.Event.SetLocalPositionY(self.Properties.MergeInfoPopup.CharEntryDivider, dividerPosY)
      end
      self.hasShownMergeWarning = true
      self:OpenMergePopup(self.MERGE_POPUP_WARNING, self.MERGE_POPUP_RETURN_MAIN)
    end
  end
  local noWorldData
  if #self.worldList == 0 then
    noWorldData = {}
    noWorldData.label = "@mm_serverunavailable"
  end
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
  local worldListCount = #self.worldList
  self.selectedWorldIndex = self:GetWorldIndex(landingCommon.lastPlayerSelectedWorldId)
  local isSelectedWorldAvailable = (1 <= self.selectedWorldIndex or worldListCount >= self.selectedWorldIndex) and self:WorldIsSelectable(self.worldList[self.selectedWorldIndex])
  if isSelectedWorldAvailable then
    self:SelectServer(self.selectedWorldIndex)
  else
    self.stopRefreshRecommendedServer = false
    self:SetRecommendedServer()
    self.stopRefreshRecommendedServer = true
  end
  if 0 < self.selectedWorldIndex and self.selectedWorldIndex <= #self.worldList then
    self:ChangeServerByWorldId(self.worldList[self.selectedWorldIndex].worldData.worldId)
  end
end
function LandingScreen:PopulateCharacterSelectionList(worldId)
  local maxCharacterCount = self.maxCharactersPerRegion + self.purchasedCharacterSlots
  local maintenanceBypass = LyShineScriptBindRequestBus.Broadcast.IsMaintenanceBypass()
  if maintenanceBypass then
    maxCharacterCount = math.max(maxCharacterCount, #self.characterData) + 1
  end
  local countText = GetLocalizedReplacementText("@ui_region_character_count", {
    numCharacter = #self.characterData,
    maxCharacter = maxCharacterCount
  })
  local tooltipText = GetLocalizedReplacementText("@ui_region_character_tooltip", {
    numCharacter = #self.characterData,
    maxCharacter = maxCharacterCount
  })
  UiTextBus.Event.SetTextWithFlags(self.Properties.RegionalCharacterCount, countText, eUiTextSet_SetAsIs)
  self.RegionalCharacterCountTooltip:SetSimpleTooltip(tooltipText)
  self.currentCharacterData = {}
  local numElementsToShow = math.max(maxCharacterCount, #self.characterData)
  local prototype = UiElementBus.Event.GetChild(self.Properties.CharacterList, 0)
  local prototypeHeight = 0
  local prototypeSpacing = 8
  for i = 1, numElementsToShow do
    local characterEntry = UiElementBus.Event.GetChild(self.Properties.CharacterList, i - 1)
    if not characterEntry or not characterEntry:IsValid() then
      characterEntry = self:CloneElement(prototype, self.Properties.CharacterList, true).entityId
    end
    local yPos = UiTransformBus.Event.GetLocalPositionY(prototype)
    prototypeHeight = UiTransform2dBus.Event.GetLocalHeight(prototype)
    UiTransformBus.Event.SetLocalPositionY(characterEntry, yPos + (prototypeHeight + prototypeSpacing) * (i - 1))
    UiElementBus.Event.SetIsEnabled(characterEntry, true)
  end
  local listHeight = (prototypeHeight + prototypeSpacing) * numElementsToShow - prototypeSpacing
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.CharacterList, listHeight)
  local initHeight = 170
  local purchaseHolderHeight = 120
  local maxVisibleCharacters = math.min(maxCharacterCount, self.maxVisibleCharacters)
  local bgHeight = initHeight + (prototypeHeight + prototypeSpacing) * maxVisibleCharacters
  if self.isPurchaseCharacterSlotEnabled then
    bgHeight = bgHeight + purchaseHolderHeight
  end
  self.ScriptedEntityTweener:Play(self.Properties.CharacterInfoHolder, 0.2, {h = bgHeight, ease = "QuadOut"})
  self:SetCharacterListVisible(true)
  for i = 1, #self.characterData do
    local charData = self.characterData[i]
    local characterEntry = UiElementBus.Event.GetChild(self.Properties.CharacterList, i - 1)
    UiElementBus.Event.SetIsEnabled(characterEntry, true)
    local charInfoBox = self.registrar:GetEntityTable(characterEntry)
    if maxCharacterCount < i then
      charInfoBox:SetSlotStatus(charInfoBox.CHARSTATUS_LOCKED)
      charInfoBox:SetWorldMessageTooltip("@mm_charslot_locked_tooltip")
    else
      charInfoBox:SetSlotStatus(charInfoBox.CHARSTATUS_ACTIVE)
      charInfoBox:SetDeleteCharacterCallback(self.OnCharacterDeletePressed, self)
      charInfoBox:SetWorldMessageTooltip("")
    end
    charInfoBox:SetChangeCharacterCallback(function()
      self:SelectCharacterByIndex(i)
    end, self)
    charInfoBox:SetCharacterInfo(charData.name, charData.characterId, charData.currentLevel)
    if charData.guildId:IsValid() then
      charInfoBox:SetGuildCrest(charData.crestData, true)
    else
      charInfoBox:SetGuildCrest(nil, true)
    end
    table.insert(self.currentCharacterData, charData)
    local worldName = ""
    local characterWorldId = charData.worldId
    for _, world in ipairs(self.worldList) do
      if world.worldData.worldId == characterWorldId then
        worldName = world.worldData.name
        break
      end
    end
    charInfoBox:SetWorldInfoText(LyShineScriptBindRequestBus.Broadcast.LocalizeText(worldName))
    local destinationWorldName, mergeTime
    local pendingWorldList = self.pendingWorldMergeListDataNode:GetData()
    for k = 1, #pendingWorldList do
      if characterWorldId == pendingWorldList[k].sourceWorldId then
        destinationWorldName = self:GetWorldName(pendingWorldList[k].destinationWorldId)
        mergeTime = worldListCommon:ParseDate(pendingWorldList[k].mergeTime)
        break
      end
    end
    if mergeTime then
      charInfoBox:SetMergeTime(mergeTime)
      charInfoBox:SetWorldMessageTooltip(GetLocalizedReplacementText("@ui_character_merge_destination", {
        worldName = worldName,
        destinationWorldName = destinationWorldName,
        date = timeHelpers:GetLocalizedAbbrevDate(mergeTime),
        mergeTime = timeHelpers:ConvertToShorthandString(mergeTime - os.time(), false)
      }))
    else
      charInfoBox:SetMergeTimeVisible(false)
    end
    local isWorldInMaintenance = self:IsWorldInMaintenanceMode(characterWorldId)
    if isWorldInMaintenance then
      charInfoBox:SetWorldMessageTooltip("@mm_loginservices_worldmaintenance")
    end
  end
  local isCreateCharacterAvailable = maxCharacterCount > #self.currentCharacterData or maintenanceBypass
  local characterElements = UiElementBus.Event.GetChildren(self.Properties.CharacterList)
  for i = #self.currentCharacterData + 1, #characterElements do
    local characterEntry = characterElements[i]
    if characterEntry and characterEntry:IsValid() then
      local charInfoBox = self.registrar:GetEntityTable(characterEntry)
      local hideSlot = maxCharacterCount < i or not isCreateCharacterAvailable
      charInfoBox:SetCreateCharacterCallback(self.OnCreateCharacterPressed, self)
      charInfoBox:SetSlotStatus(charInfoBox.CHARSTATUS_CANCREATE)
      charInfoBox:SetText("@ui_createcharacter")
      charInfoBox:SetWorldMessageTooltip()
      UiElementBus.Event.SetIsEnabled(characterEntry, not hideSlot)
    end
  end
  if #self.currentCharacterData > 0 then
    local hasPrevChar = false
    local selectedCharacterIndex = 1
    if 0 < self.selectedCharacterIndex and self.selectedCharacterIndex <= #self.currentCharacterData then
      selectedCharacterIndex = self.selectedCharacterIndex
      hasPrevChar = true
    end
    local createdNewCharSelected = false
    local newCharacterId = self.dataLayer:GetDataFromNode("MainMenu.NewCharacterId")
    LyShineDataLayerBus.Broadcast.SetData("MainMenu.NewCharacterId", "")
    if newCharacterId and 0 < #newCharacterId then
      for i = 1, #self.currentCharacterData do
        if self.currentCharacterData[i].characterId == newCharacterId then
          selectedCharacterIndex = i
          createdNewCharSelected = true
          break
        end
      end
    end
    if not createdNewCharSelected and not hasPrevChar then
      local lastPlayedWorldElapsedSec = GetMaxNum()
      for i = 1, #self.currentCharacterData do
        local characterWorldId = self.currentCharacterData[i].worldId
        for _, world in ipairs(self.worldList) do
          if world.worldData.worldId == characterWorldId then
            if world.lastPlayed ~= 0 and lastPlayedWorldElapsedSec > world.lastPlayed then
              lastPlayedWorldElapsedSec = world.lastPlayed
              selectedCharacterIndex = i
            end
            break
          end
        end
      end
    end
    self:SelectCharacterByIndex(selectedCharacterIndex)
  else
    self:ShowCharacter(false)
    self:UpdateCharacterSelectMessages()
  end
end
function LandingScreen:ChangeServerByWorldId(worldId)
  local childElements = UiElementBus.Event.GetChildren(self.Properties.ServerList)
  for i = 1, #childElements do
    local currentEntityId = childElements[i]
    local currentEntityTable = self.registrar:GetEntityTable(currentEntityId)
    local currentEntityWorldId = currentEntityTable:GetWorldId()
    if currentEntityWorldId == worldId then
      local selectedEntityId = UiRadioButtonGroupBus.Event.GetState(self.Properties.ServerList)
      if selectedEntityId:IsValid() then
        UiRadioButtonGroupBus.Event.SetState(self.Properties.ServerList, selectedEntityId, false)
        local selectedEntityTable = self.registrar:GetEntityTable(selectedEntityId)
        selectedEntityTable:OnUnselected()
      end
      UiRadioButtonGroupBus.Event.SetState(self.Properties.ServerList, currentEntityId, true)
      currentEntityTable:OnSelected()
      self:ChangeServer(currentEntityId)
      local newSelectedIndex = UiElementBus.Event.GetIndexOfChildByEntityId(self.Properties.ServerList, currentEntityId)
      local listItemHeight = UiTransform2dBus.Event.GetLocalHeight(currentEntityId)
      local listItemSpacing = 5
      local scrollAmount = (listItemHeight + listItemSpacing) * newSelectedIndex
      UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.ServerContentBox, scrollAmount * -1)
      self:UpdateRecommendedWorldSelectState(worldId)
      break
    end
  end
end
function LandingScreen:ChangeServer(entityId, actionName)
  if self.isWorldListOnly then
    return
  end
  local selectedEntityId = UiRadioButtonGroupBus.Event.GetState(self.Properties.ServerList)
  if selectedEntityId:IsValid() and #self.worldList > 0 then
    local selectedEntityTable = self.registrar:GetEntityTable(selectedEntityId)
    self:UpdateWorldSelectionListContinueButton(selectedEntityTable)
    local selectedWorldIndex = UiElementBus.Event.GetIndexOfChildByEntityId(self.Properties.ServerList, selectedEntityId) + 1
    self:SelectServer(selectedWorldIndex, true)
    local selectedWorldId = selectedEntityTable:GetWorldId()
    self:UpdateRecommendedWorldSelectState(selectedWorldId)
  end
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnServerSelectPress)
end
function LandingScreen:UpdateWorldSelectionListContinueButton(selectedItemInServerList)
  local isSelectable = not selectedItemInServerList.isAtCharacterLimit
  if isSelectable then
    self.WorldSelectionListContinueButton:SetEnabled(true)
    self.WorldSelectionListContinueButton:SetTooltip("")
  else
    self.WorldSelectionListContinueButton:SetEnabled(false)
    self.WorldSelectionListContinueButton:SetTooltip("@mm_world_character_limit")
  end
end
function LandingScreen:UpdateRecommendedWorldSelectState(selectedWorldId)
  local recommendedServerWorldId = self.WorldSelectionListRecommendedServer:GetWorldId()
  if selectedWorldId == recommendedServerWorldId then
    self.WorldSelectionListRecommendedServer:OnSelected()
  else
    self.WorldSelectionListRecommendedServer:OnUnselected()
  end
end
function LandingScreen:SelectServer(selectedIndex, saveWorldId)
  self.selectedWorldIndex = selectedIndex
  if self.selectedWorldIndex > 0 and self.selectedWorldIndex <= #self.worldList then
    self.selectedWorldId = self.worldList[self.selectedWorldIndex].worldData.worldId
    if saveWorldId then
      landingCommon.lastPlayerSelectedWorldId = self.selectedWorldId
    end
    UiLoginScreenRequestBus.Broadcast.SetSelectedWorldId(self.selectedWorldId)
    MainMenuSystemRequestBus.Broadcast.SetSelectedWorldId(self.selectedWorldId)
    self.worldHasCapacity = self.worldList[self.selectedWorldIndex].worldData.maxConnectionCount == 0 or self.worldList[self.selectedWorldIndex].worldData.connectionCount < self.worldList[self.selectedWorldIndex].worldData.maxConnectionCount
    self.worldIsOnlineButUnavailable = bitHelpers:TestFlag(self.worldList[self.selectedWorldIndex].worldData.publicStatusCode, bitHelpers.SERVERSTATUS_DOWNFORMAINTENANCE)
    self:EnableButtons(true)
    self:CheckCharacterVisibility()
    self:SetWorldInfoVisible(true)
  end
  self:UpdatePlayButton()
end
function LandingScreen:IsWorldInMaintenanceMode(worldId)
  for _, world in ipairs(self.worldList) do
    if world.worldData.worldId == worldId then
      return bitHelpers:TestFlag(world.worldData.publicStatusCode, bitHelpers.SERVERSTATUS_DOWNFORMAINTENANCE)
    end
  end
  return false
end
function LandingScreen:IsWorldCharacterCreationDisabled(worldId)
  for _, world in ipairs(self.worldList) do
    if world.worldData.worldId == worldId then
      return bitHelpers:TestFlag(world.worldData.publicStatusCode, bitHelpers.SERVERSTATUS_CHARACTERCREATIONDISABLED)
    end
  end
  return false
end
function LandingScreen:ChangeCharacter(entityId, actionName)
  self:ShowCharacter(false)
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
    timingUtils:StopDelay(self, self.CheckCharacterVisibility)
    self:ShowCharacter(false)
    if self.selectedCharacterIndex > 0 then
      timingUtils:Delay(0.25, self, self.CheckCharacterVisibility)
      local currentCharacterData = self.currentCharacterData[self.selectedCharacterIndex]
      self.selectedCharacterId = currentCharacterData.characterId
      UiLoginScreenRequestBus.Broadcast.SetVisibleCharacter(self.selectedCharacterId)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Position", currentCharacterData.position)
      self:ForceSelectServerBasedOnCharacter()
    end
    self:UpdateCharacterSelectMessages()
  end
  self:UpdatePlayButton()
end
function LandingScreen:ForceSelectServerBasedOnCharacter()
  if self.currentScreenState ~= self.SCREEN_STATE_LANDING or self.currentScreenState ~= self.SCREEN_STATE_CHARACTER_SELECT then
    return
  end
  if self.selectedCharacterIndex > 0 then
    local currentCharacterData = self.currentCharacterData[self.selectedCharacterIndex]
    for worldIndex, world in ipairs(self.worldList) do
      if world.worldData.worldId == currentCharacterData.worldId then
        self:SelectServer(worldIndex, true)
      end
    end
  end
end
function LandingScreen:GetSelectedWorldInfo()
  if #self.worldList > 0 and 0 < self.selectedWorldIndex and self.selectedWorldIndex <= #self.worldList then
    return self.worldList[self.selectedWorldIndex]
  end
  return nil
end
function LandingScreen:IsSelectedServerDown()
  local worldInfo = self:GetSelectedWorldInfo()
  if worldInfo then
    local publicStatus = worldInfo.worldData.publicStatusCode
    return bitHelpers:TestFlag(publicStatus, bitHelpers.SERVERSTATUS_DOWNFORMAINTENANCE)
  end
  return false
end
function LandingScreen:UpdatePlayButton()
  local isServerDown = self:IsSelectedServerDown()
  local isDebugClient = LyShineScriptBindRequestBus.Broadcast.IsDebugClient()
  local maintenanceBypass = LyShineScriptBindRequestBus.Broadcast.IsMaintenanceBypass()
  local slotLocked = self.selectedCharacterIndex > self.maxCharactersPerRegion + self.purchasedCharacterSlots
  if not self.playButtonClicked then
    self.PlayButton:SetButtonStyle(self.PlayButton.BUTTON_STYLE_HERO)
  end
  local buttonEnabled = false
  if isDebugClient or maintenanceBypass or not isServerDown then
    buttonEnabled = true
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@ui_play", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.PlayButtonText, self.UIStyle.COLOR_WHITE)
    if slotLocked then
      buttonEnabled = false
    end
  else
    buttonEnabled = false
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@mm_serverdown", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.PlayButtonText, self.UIStyle.COLOR_YELLOW)
  end
  if self.selectedCharacterIndex < 0 or self.selectedCharacterIndex > #self.currentCharacterData then
    buttonEnabled = false
  end
  local isSpinnerEnabled = UiElementBus.Event.IsEnabled(self.Properties.StatusSpinnerEntity)
  if self.enableButtons and buttonEnabled and not isSpinnerEnabled then
    self.PlayButton:SetEnabled(true)
    UiTextBus.Event.SetColor(self.Properties.PlayButtonText, self.UIStyle.COLOR_WHITE)
  else
    self.PlayButton:SetEnabled(false)
    UiTextBus.Event.SetColor(self.Properties.PlayButtonText, self.UIStyle.COLOR_GRAY_50)
  end
end
function LandingScreen:OnCharacterRename()
  self.characterDataReady = false
  self.renamePopupShown = false
  self.selectedCharacterId = ""
  self.characterData = {}
  self.currentCharacterData = {}
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
    self.deletePopupOpen = false
    if self.selectedCharacterIndex > 0 then
      local currentCharacterData = self.currentCharacterData[self.selectedCharacterIndex]
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
    if result == ePopupResult_Yes and self.canDeleteChar then
      self.selectedCharacterIndex = -1
      self.canDeleteChar = false
      self:ShowServerLoadingSpinner(function()
        UiCharacterServiceRequestBus.Broadcast.DeactivateCharacter(self.selectedCharacterId)
      end)
    else
      self:EnableButtons(true)
    end
    self.canDeleteChar = false
  elseif eventId == self.popupTwitchLogoutEventId then
    if result == ePopupResult_Yes then
      self:StartTwitchSpinner()
    end
    self.twitchPopupHandler:Disconnect()
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
  worldListCommon:UpdateWorldDataWithCMS(self.worldList, self.worldCMSList)
  local showGlobalMotd = string.len(self.worldCMSList.globalMotd.description) > 0
  if showGlobalMotd then
    self.globalMotdTitle = self.worldCMSList.globalMotd.title
    self.globalMotdDesc = self.worldCMSList.globalMotd.description
  else
    self.globalMotdTitle = ""
    self.globalMotdDesc = ""
  end
  LyShineManagerBus.Broadcast.SetGlobalAnnouncement(self.globalMotdTitle, self.globalMotdDesc)
  self:UpdateCharacterSelectMessages()
  self.worldListReady = true
  if self.characterDataReady then
    self:RefreshScreenData()
    self.worldListRefresh = false
  end
end
function LandingScreen:OnMarketingTilesCMSDataSet(marketingCMSData)
  UiElementBus.Event.SetIsEnabled(self.Properties.LandingScreenNewsSpinnerHolder, false)
  if not self.newsData then
    self.newsData = {}
  else
    ClearTable(self.newsData)
  end
  for i = 1, #marketingCMSData.marketingTileData do
    local tileData = marketingCMSData.marketingTileData[i]
    table.insert(self.newsData, {
      title = tileData.title,
      description = tileData.description,
      price = tileData.price,
      oldPrice = tileData.oldPrice,
      timeRemainingSeconds = tileData.timeRemainingSeconds,
      isVideo = tileData.isVideoLink,
      isDisplaying = tileData.isDisplaying,
      index = i - 1
    })
  end
  self:UpdateNewsTiles()
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
  self:BeginConnection()
end
function LandingScreen:OnLoginInfoListResult(worlds, characters, names, maxAccountCharacters)
  self:OnWorldListResult(worlds)
  self:OnCharactersPayloadResult(characters, maxAccountCharacters)
  if names ~= nil and 0 < #names then
    self:OnCharacterNamesResult(names)
  end
end
function LandingScreen:OnWorldListResult(worlds)
  self.worldList = worldListCommon:WorldVectorToTable(worlds)
  self.currentState = self.STATE_NONE
  if #self.worldList == 0 then
    self:PopulateCharacterSelectionList(-1)
  end
  if self.CREATE_FAKE_DATA then
    ClearTable(self.worldList)
    for i = 1, 20 do
      local fakeWorld = WorldMetadata()
      fakeWorld.status = "ACTIVE"
      fakeWorld.publicStatusCode = 0
      if 15 <= i then
        fakeWorld.publicStatusCode = 8
      end
      fakeWorld.connectionCount = math.random(100, 2000)
      if i < 3 then
        fakeWorld.connectionCount = 2000
      end
      fakeWorld.maxConnectionCount = 2000
      fakeWorld.worldId = string.format("00000000-0000-0000-0000-0000000000%02d", i + 1)
      fakeWorld.worldSet = string.format("Fake World Set %01d", math.floor(i / 5))
      fakeWorld.maxAccountCharacters = i % 2 == 0 and 4 or 1
      fakeWorld.name = "Fake World " .. tostring(i)
      local numFriends = 0
      local lastPlayed = 0
      if i == 6 then
        lastPlayed = 100
      end
      local mergeTime = math.random(os.time() - 500000, os.time() + 500000)
      fakeWorld.worldMetrics = WorldMetrics()
      fakeWorld.worldMetrics.queueSize = 0
      fakeWorld.worldMetrics.queueWaitTimeSec = fakeWorld.worldMetrics.queueSize * 3
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
        population = i * 100,
        characterCount = 0,
        lastPlayed = lastPlayed,
        groupLastPlayed = 32000000,
        mergeTime = mergeTime,
        index = i,
        numFriends = numFriends,
        imageId = worldListCommon:GetWorldSetImageId(fakeWorld.worldSet)
      })
    end
  end
  UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.ServerList, #self.worldList)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerTableHeader, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerSortWorldSetTooltip, true)
  if self.characterDataReady and #self.worldList > 0 then
    self:RefreshScreenData()
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    UiElementBus.Event.SetIsEnabled(self.Properties.LandingScreenNewsSpinnerHolder, true)
    local langUpdated = landingCommon.lastLanguageForMarketingTileRequest ~= setLang
    landingCommon.lastLanguageForMarketingTileRequest = setLang
    DynamicContentBus.Broadcast.RetrieveCMSData(eCMSDataType_Worlds, true)
    DynamicContentBus.Broadcast.RetrieveCMSData(eCMSDataType_MarketingTiles, langUpdated)
    self:SetWorldSetTooltipPosition()
  end)
end
function LandingScreen:SetWorldSetTooltipPosition()
  local textWidth = UiTextBus.Event.GetTextWidth(self.Properties.ServerSortWorldSetLabel)
  local padding = 10
  self.ScriptedEntityTweener:Set(self.Properties.ServerSortWorldSetTooltip, {
    x = textWidth + padding
  })
end
function LandingScreen:OnCharactersPayloadResult(characters, maxAccountCharacters)
  self.currentCharacterData = {}
  self.characterDataCache = characters
  self.characterData = characters
  self.maxCharactersPerRegion = maxAccountCharacters
  local forceNumMaxChars = self.dataLayer:GetDataFromNode("UIFeatures.landingScreenForceMaxCharacters") or 0
  self.maxCharactersPerRegion = math.max(self.maxCharactersPerRegion, forceNumMaxChars)
  self.characterDataReady = true
  if self.worldListReady then
    self:RefreshScreenData()
    self.worldListRefresh = false
  end
end
function LandingScreen:RefreshScreenData()
  self:UpdateWorldAndCharacterData()
  worldListCommon:SortWorldList(self.sortType, self.worldList)
  self:PopulateWorldSelectionList()
  self:PopulateCharacterSelectionList(-1)
  self:SetStartingState()
  self:UpdatePlayButton()
  if not self:GetHasDoneFirstTimeLandingScreen() and self.currentScreenState == self.SCREEN_STATE_CHARACTER_SELECT then
    self:SetScreenState(self.SCREEN_STATE_WORLD_SELECT, self.SCREEN_TRANSITION_FADE_IN)
  elseif self.currentScreenState == self.SCREEN_STATE_WORLD_SELECT then
    self:SetRecommendedServer()
  end
end
function LandingScreen:OnCharacterNamesResult(characterNames)
  self.characterNames = characterNames
  if self.characterDataReady and self.worldListReady then
    self:RefreshScreenData()
  end
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
function LandingScreen:HasRecentlyMergedCharacter()
  for j = 1, #self.characterData do
    if string.len(self.characterData[j].prevWorldId) > 0 and self.characterData[j].worldId ~= self.characterData[j].prevWorldId then
      local worldIndex = self:GetWorldIndex(self.characterData[j].prevWorldId)
      if worldIndex == -1 then
        return true
      end
    end
  end
  return false
end
function LandingScreen:UpdateWorldAndCharacterData()
  local pendingWorldList = self.pendingWorldMergeListDataNode:GetData()
  local sortByLastPlayed, characterDataTable = worldListCommon:UpdateWorldAndCharacterData(self.worldList, self.characterData, pendingWorldList)
  self.characterData = characterDataTable
  if self.sortType == worldListCommon.SORT_BYNONE then
    if sortByLastPlayed then
      self.sortType = worldListCommon.SORT_BYLASTPLAYED_ASC
      worldListCommon:SortWorldList(self.sortType, self.worldList)
    else
      self.sortType = worldListCommon.SORT_BYRECOMMENDED
      worldListCommon:SortWorldList(self.sortType, self.worldList)
      self:SetRecommendedServer()
    end
  end
  self:RefreshPurchaseSlotButton()
end
function LandingScreen:ClearWorldList()
  self.worldListReady = false
  self.characterDataReady = false
  self.worldList = {}
  self.characterData = {}
  self.currentCharacterData = {}
  worldListCommon.worldSetImageId = {}
  self:PopulateWorldSelectionList(EntityId(), "")
  self:PopulateCharacterSelectionList(-1)
  self:SetWorldInfoVisible(false)
  self:CheckCharacterVisibility()
  self.autorefreshTimer = self.autoRefreshTimerDuration
end
function LandingScreen:OnRegionDropdownSelected(item, itemData)
  if not self.enableButtons then
    return
  end
  if itemData and itemData.regionId and self.selectedRegionId ~= itemData.regionId then
    self.ServerRegionDropdown:StartSpinner()
    self.WorldSelectServerRegionDropdown:StartSpinner()
    self.ServerRegionDropdown:SetSelectedImage(itemData.image)
    self.WorldSelectServerRegionDropdown:SetSelectedImage(itemData.image)
    self:ClearWorldList()
    self.selectedRegionId = itemData.regionId
    self:UpdateRegionDropdownText()
    self:EnableButtons(false)
    self:ShowServerLoadingSpinner(function()
      OptionsDataBus.Broadcast.SetRegionId(itemData.regionId)
    end)
  end
end
function LandingScreen:OnClusterListResult(regions)
  self:SetRegionDropdownInfo(self.ServerRegionDropdown, regions)
  self:SetRegionDropdownInfo(self.WorldSelectServerRegionDropdown, regions)
end
function LandingScreen:EnableSafeButtons(enable)
  self.isRefreshEnabled = enable
  self:RefreshCharacterRefreshButtonEnabled()
end
function LandingScreen:EnableButtons(enable)
  self.enableButtons = enable
  self:UpdatePlayButton()
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PlayButton, enable)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ServerContentBox, enable)
  self:EnableSafeButtons(enable)
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
function LandingScreen:SetCharacterVisibilityOverride(isOverride)
  if isOverride then
    self:SetCameraDof(true)
    self:ShowCharacter(false)
    self.isCharacterVisibilityForced = true
  else
    self:SetCameraDof(false)
    self.isCharacterVisibilityForced = false
    self:CheckCharacterVisibility()
  end
end
function LandingScreen:SetCameraDof(isBlurred)
  if isBlurred == self.isBlurred then
    return
  end
  if isBlurred then
    JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
    JavelinCameraRequestBus.Broadcast.SetDepthOfField(self.UIStyle.BLUR_DEPTH_OF_FIELD, self.UIStyle.BLUR_AMOUNT, self.UIStyle.BLUR_NEAR_DISTANCE, self.UIStyle.BLUR_NEAR_SCALE, self.UIStyle.RANGE_DEPTH_OF_FIELD)
  else
    JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
  end
  self.isBlurred = isBlurred
end
function LandingScreen:ShowCharacter(show)
  if self.isCharacterVisibilityForced then
    return
  end
  if show then
    TransformBus.Event.SetWorldZ(self.characterEntityId, self.worldZ)
  else
    TransformBus.Event.SetWorldZ(self.characterEntityId, self.hiddenWorldZ)
  end
  self:UpdatePlayButton()
end
function LandingScreen:SetWorldInfoVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.WorldInfoCard, true)
    self.ScriptedEntityTweener:Play(self.Properties.WorldInfoCard, 0.3, {opacity = 1, ease = "QuadOut"})
    UiElementBus.Event.SetIsEnabled(self.Properties.LandingGlobalAnnouncement, true)
    self.ScriptedEntityTweener:Play(self.Properties.LandingGlobalAnnouncement, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.WorldInfoCard, 0.2, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.LandingGlobalAnnouncement, 0.2, {opacity = 0, ease = "QuadOut"})
  end
end
function LandingScreen:SetLoginState(state)
  local canPlay = state == ELumberyardState.Disconnected
  local isAuthenticating = state >= ELumberyardState.QueueGameLogin and state <= ELumberyardState.WaitingForQueuedLogin
  local isConfiguring = state >= ELumberyardState.QueryForRemoteConfigClass and state <= ELumberyardState.WaitingForRemoteConfigClass
  local isConnecting = state >= ELumberyardState.StartREPConnection and state < ELumberyardState.InGame
  if canPlay then
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@ui_play", eUiTextSet_SetLocalized)
  elseif isConnecting then
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@mm_connecting", eUiTextSet_SetLocalized)
  elseif isAuthenticating then
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@mm_authenticating", eUiTextSet_SetLocalized)
  elseif isConfiguring then
    UiTextBus.Event.SetTextWithFlags(self.Properties.PlayButtonText, "@mm_configuring", eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusSpinnerEntity, isConnecting or isAuthenticating or isConfiguring)
  self:UpdatePlayButton()
end
function LandingScreen:RefreshWorldList()
  self.worldListReady = false
  self.characterDataReady = false
  self.worldList = {}
  self.characterData = {}
  self.currentCharacterData = {}
  self:PopulateWorldSelectionList(EntityId(), "")
  self:PopulateCharacterSelectionList(-1)
  UiLoginScreenRequestBus.Broadcast.GetLoginInfoLists(true)
  UiLoginScreenRequestBus.Broadcast.GetRegionList()
  self.autorefreshTimer = self.autoRefreshTimerDuration
  self:CheckCharacterVisibility()
  self:SetRecommendedServer()
end
function LandingScreen:SetStartingState()
  if not self.worldListRefresh then
    self.ScriptedEntityTweener:Stop(self.Properties.ServerContentBoxHolder)
    self.ScriptedEntityTweener:Play(self.Properties.ServerContentBoxHolder, 0.3, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ServerLoadingText, 0.2, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.CharacterServerLoadingText, 0.2, {opacity = 0, ease = "QuadOut"})
  UiElementBus.Event.SetIsEnabled(self.Properties.FailedConnectionEntity, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterFailedConnectionEntity, false)
  self.isRefreshEnabled = true
  self:RefreshCharacterRefreshButtonEnabled()
  UiElementBus.Event.SetIsEnabled(self.Properties.RegionalCharacterCount, true)
  self.ScriptedEntityTweener:Play(self.Properties.RegionalCharacterCount, 0.3, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.2
  })
  self.ServerRegionDropdown:StopSpinner()
  self.WorldSelectServerRegionDropdown:StopSpinner()
  self:EnableButtons(true)
  self:CheckCharacterVisibility()
end
function LandingScreen:GetCharacterCountByWorld(worldId)
  local count = 0
  for i = 1, #self.characterData do
    if self.characterData[i].worldId == worldId then
      count = count + 1
    end
  end
  return count
end
function LandingScreen:SelectCharacterByIndex(index)
  local childId = UiElementBus.Event.GetChild(self.Properties.CharacterList, index - 1)
  if childId:IsValid() then
    if self.selectedCharacterIndex ~= index then
      local currentSelectedId = UiElementBus.Event.GetChild(self.Properties.CharacterList, self.selectedCharacterIndex - 1)
      if currentSelectedId:IsValid() then
        local currentSelectedTable = self.registrar:GetEntityTable(currentSelectedId)
        currentSelectedTable:OnUnselected()
      end
    end
    self.selectedCharacterIndex = index
    local radioButton = UiElementBus.Event.FindDescendantByName(childId, "CharacterInfoHolder")
    if radioButton:IsValid() then
      UiRadioButtonGroupBus.Event.SetState(self.Properties.CharacterList, radioButton, true)
      self:SelectCharacter(self.Properties.CharacterList)
    end
  end
end
function LandingScreen:CheckCharacterVisibility()
  local showCharacter = false
  local currentCharacterData = self.currentCharacterData[self.selectedCharacterIndex]
  if currentCharacterData then
    showCharacter = true
  end
  self:ShowCharacter(showCharacter)
end
function LandingScreen:SetCustomizableCharacterEntityId(entityId)
  self.characterEntityId = entityId
  CustomizableCharacterRequestBus.Event.SetAlwaysUpdate(self.characterEntityId, true)
  self.worldZ = 122.07218170166
end
function LandingScreen:OnSortButtonClicked(sortButton)
  self.worldListRefresh = true
  self.autorefreshTimer = self.autoRefreshTimerDuration
  for _, buttonData in pairs(self.sortButtons) do
    if buttonData.button == sortButton then
      if buttonData.button.isSelected and buttonData.button.direction == buttonData.button.ASCENDING then
        buttonData.button:SetSelectedDescending()
        self.sortType = worldListCommon["SORT_BY" .. buttonData.sort .. "_DESC"]
      else
        buttonData.button:SetSelectedAscending()
        self.sortType = worldListCommon["SORT_BY" .. buttonData.sort .. "_ASC"]
      end
    else
      buttonData.button:SetDeselected()
    end
  end
  if landingCommon.lastPlayerSelectedWorldId == "" then
    landingCommon.lastPlayerSelectedWorldId = self.selectedWorldId
  end
  worldListCommon:SortWorldList(self.sortType, self.worldList)
  self:PopulateWorldSelectionList()
  self:SetStartingState()
  worldListCommon:ReselectWorldIdInList(self.Properties.ServerList, self.selectedWorldId)
  self.worldListRefresh = false
end
function LandingScreen:OnClusterPopupCancel()
  self:SetClusterNotificationPopupVisible(false)
end
function LandingScreen:OnClusterPopupAccept()
  self:SetClusterNotificationPopupVisible(false)
  self:RequestGoToIntro()
end
function LandingScreen:SetClusterNotificationPopupVisible(isVisible)
  if isVisible then
    self.isClusterNotificationVisible = true
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
        self.isClusterNotificationVisible = false
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
  self:OpenMergePopup(self.MERGE_POPUP_WARNING, self.MERGE_POPUP_RETURN_MAIN)
end
function LandingScreen:OpenMergePopup(popupType, returnDest)
  self.mergePopupType = popupType
  self.returnDestination = returnDest
  UiElementBus.Event.SetIsEnabled(self.Properties.MergeInfoPopup.Faq, popupType == self.MERGE_POPUP_FAQ)
  UiElementBus.Event.SetIsEnabled(self.Properties.MergeInfoPopup.UpcomingMerge, popupType == self.MERGE_POPUP_WARNING)
  UiElementBus.Event.SetIsEnabled(self.Properties.MergeInfoPopup.PostMerge, popupType == self.MERGE_POPUP_POSTMERGE)
  local headerText = ""
  local popupWidth = self.POPUP_LARGE_WIDTH
  local popupHeight = self.POPUP_LARGE_HEIGHT
  local buttonHeight = self.POPUP_LARGE_BUTTON_HEIGHT
  local buttonStyle = self.MergeInfoPopup.AcceptButton.BUTTON_STYLE_CTA
  if popupType == self.MERGE_POPUP_WARNING then
    headerText = "@ui_mergewarning_title"
    popupWidth = self.POPUP_SMALL_WIDTH
    popupHeight = self.POPUP_SMALL_HEIGHT
    buttonHeight = self.POPUP_SMALL_BUTTON_HEIGHT
    buttonStyle = self.MergeInfoPopup.AcceptButton.BUTTON_STYLE_HERO
  elseif popupType == self.MERGE_POPUP_FAQ then
    headerText = "@ui_mergefaq_title"
  elseif popupType == self.MERGE_POPUP_POSTMERGE then
    headerText = "@ui_mergecomplete_title"
  end
  self.MergeInfoPopup.FrameHeader:SetWidth(popupWidth)
  self.MergeInfoPopup.FrameHeader:SetText(headerText)
  self.ScriptedEntityTweener:Set(self.Properties.MergeInfoPopup.Frame, {w = popupWidth, h = popupHeight})
  self.ScriptedEntityTweener:Set(self.Properties.MergeInfoPopup.AcceptButton, {h = buttonHeight})
  self.MergeInfoPopup.AcceptButton:SetButtonStyle(buttonStyle)
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
function LandingScreen:InitRegionDropdown(dropdownTable)
  local defaultRegions = {}
  dropdownTable:SetDropdownListHeightByRows(#defaultRegions)
  dropdownTable:SetListData(defaultRegions)
  dropdownTable:SetText("")
  dropdownTable:SetListBgAlpha(1)
  dropdownTable:SetDropdownScreenCanvasId(dropdownTable.entityId)
  dropdownTable:SetCallback(self.OnRegionDropdownSelected, self)
end
function LandingScreen:SetRegionDropdownInfo(dropdownTable, regions)
  if not self.regionLatencyInfo then
    self.regionLatencyInfo = {}
  end
  ClearTable(self.regionLatencyInfo)
  if dropdownTable and not dropdownTable.isShown then
    local currentRegion = GameRequestsBus.Broadcast.GetRegionId()
    local currentRegionIndex = 1
    local currentlatencyImage = ""
    local listItemData = {}
    local latencyImage
    for i = 1, #regions do
      self.regionLatencyInfo[i] = regions[i].latencyMs
      for j = 1, #self.pingImageTable do
        if regions[i].latencyMs >= self.pingImageTable[j].ping then
          latencyImage = self.pingImageTable[j].image
          break
        end
      end
      local latencyText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_milliseconds_markup", tostring(math.ceil(regions[i].latencyMs)))
      local gateway = UiLoginScreenRequestBus.Broadcast.GetGatewayRegion(regions[i].regionId)
      local numCharactersInRegion = 0
      if self.characterNames then
        for j = 1, #self.characterNames do
          if gateway == self.characterNames[j].region then
            numCharactersInRegion = numCharactersInRegion + 1
          end
        end
      end
      table.insert(listItemData, {
        text = regions[i].name,
        regionId = regions[i].regionId,
        image = latencyImage,
        latency = latencyText,
        latencyMs = regions[i].latencyMs,
        numChars = numCharactersInRegion,
        maxChars = self.maxCharactersPerRegion + self.purchasedCharacterSlots
      })
      if regions[i].regionId == currentRegion then
        currentRegionIndex = i
        currentlatencyImage = latencyImage
      end
    end
    self.selectedRegionId = currentRegion
    self.selectedRegionIndex = currentRegionIndex
    if dropdownTable == self.WorldSelectServerRegionDropdown then
      self:UpdateRegionDropdownText()
    end
    local dropdownText = 0 < #regions and regions[currentRegionIndex].name or ""
    dropdownTable:SetDropdownListHeightByRows(#listItemData)
    dropdownTable:SetListData(listItemData)
    dropdownTable:SetText(dropdownText)
    dropdownTable:SetSelectedImage(currentlatencyImage)
    self.WorldSelectionListRecommendedServer:SetRegionPing(currentlatencyImage)
    self.WorldSelectionListRecommendedServer:SetRegionText(dropdownText)
  end
end
function LandingScreen:UpdateRegionDropdownText()
  if not self.selectedRegionIndex then
    return
  end
  local selectedRegionLatency = self.regionLatencyInfo[self.selectedRegionIndex]
  if not selectedRegionLatency then
    return
  end
  local worstLatency = self.pingImageTable[1].ping
  local showWarning = selectedRegionLatency > worstLatency
  UiElementBus.Event.SetIsEnabled(self.Properties.WorldSelectionListRegionConnectionWarningHolder, showWarning)
  if showWarning then
    local isAllLatencyBad = true
    for _, latency in ipairs(self.regionLatencyInfo) do
      if latency < worstLatency then
        isAllLatencyBad = false
        break
      end
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldSelectionListRegionConnectionWarning, isAllLatencyBad and "@ui_region_warning_text_all" or "@ui_region_warning_text", eUiTextSet_SetLocalized)
  end
end
function LandingScreen:UpdateCharacterSelectMessages()
  local showWorldMotd = false
  local showGlobalMotd = false
  if self.selectedCharacterIndex > 0 then
    local currentCharacterData = self.currentCharacterData[self.selectedCharacterIndex]
    if currentCharacterData then
      local motdTitle = ""
      local motdMessage = ""
      local motd = self:GetWorldMessageForCharacter(currentCharacterData)
      if motd and motd ~= "" then
        motdTitle = "@ui_world_message"
        motdMessage = motd
      end
      local characterWorldId = currentCharacterData.worldId
      for _, world in ipairs(self.worldList) do
        if world.worldData.worldId == characterWorldId then
          if 0 < world.mergeTime then
            local mergeTime = os.date("%c", world.mergeTime)
            local mergeMessage = GetLocalizedReplacementText("@ui_mergewarning_long", {
              worldName = world.mergeDestinationName,
              time = mergeTime
            })
            motdTitle = "@ui_mergewarning_title"
            motdMessage = mergeMessage
          end
          break
        end
      end
      LyShineManagerBus.Broadcast.SetServerMOTD(motdMessage)
      showWorldMotd = motdTitle ~= "" or motdMessage ~= ""
      if showWorldMotd then
        UiTextBus.Event.SetTextWithFlags(self.Properties.ServerMOTDTitle, motdTitle, eUiTextSet_SetLocalized)
        UiTextBus.Event.SetTextWithFlags(self.Properties.ServerMOTDMessage, motdMessage, eUiTextSet_SetAsIs)
      end
    end
  end
  showGlobalMotd = self.globalMotdTitle ~= "" or self.globalMotdDesc ~= ""
  if showGlobalMotd then
    UiTextBus.Event.SetTextWithFlags(self.Properties.GlobalAnnouncementTitle, self.globalMotdTitle, eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.GlobalAnnouncementMessage, self.globalMotdDesc, eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.LandingGlobalAnnouncementTitle, self.globalMotdTitle, eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.LandingGlobalAnnouncementMessage, self.globalMotdDesc, eUiTextSet_SetAsIs)
  end
  local initHeight = 100
  local extendedHeight = 0
  local margin = 85
  if showWorldMotd then
    local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.ServerMOTDMessage)
    extendedHeight = textHeight + margin
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.ServerMOTDContainer, textHeight + margin)
    self.ScriptedEntityTweener:Set(self.Properties.ServerMOTDMessage, {h = textHeight})
    self.ScriptedEntityTweener:Play(self.Properties.ServerMOTDContainer, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.ServerMOTDContainer, 0.3, {opacity = 0, ease = "QuadOut"})
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.ServerMOTDContainer, 0)
  end
  local charactersOutsideCurrentRegion = {}
  if self.characterNames then
    for j = 1, #self.characterNames do
      local regionId = self.characterNames[j].region
      if regionId ~= self.selectedRegionId then
        table.insert(charactersOutsideCurrentRegion, self.characterNames[j])
      end
    end
  end
  if 0 < #charactersOutsideCurrentRegion then
    local mergingCharacters = {}
    local pendingWorldMergeList = self.pendingWorldMergeListDataNode:GetData()
    for i = 1, #pendingWorldMergeList do
      local mergingWorldId = pendingWorldMergeList[i].sourceWorldId
      for j = 1, #charactersOutsideCurrentRegion do
        local character = charactersOutsideCurrentRegion[j]
        if character.worldId == mergingWorldId then
          local mergeTime = worldListCommon:ParseDate(pendingWorldMergeList[i].mergeTime)
          table.insert(mergingCharacters, {characterData = character, mergeTime = mergeTime})
        end
      end
    end
  end
  local globalMessageHeight = 0
  if showGlobalMotd then
    local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.GlobalAnnouncementMessage)
    extendedHeight = extendedHeight + textHeight + margin
    globalMessageHeight = textHeight + margin
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.GlobalAnnouncementContainer, textHeight + margin)
    self.ScriptedEntityTweener:Set(self.Properties.GlobalAnnouncementMessage, {h = textHeight})
    self.ScriptedEntityTweener:Play(self.Properties.GlobalAnnouncementContainer, 0.3, {opacity = 1, ease = "QuadOut"})
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.GlobalAnnouncementContainer, textHeight + margin)
    self.ScriptedEntityTweener:Set(self.Properties.LandingGlobalAnnouncementMessage, {h = textHeight})
    self.ScriptedEntityTweener:Play(self.Properties.LandingGlobalAnnouncementContainer, 0.3, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.GlobalAnnouncementContainer, 0.3, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.LandingGlobalAnnouncementContainer, 0.3, {opacity = 0, ease = "QuadOut"})
  end
  self.ScriptedEntityTweener:Play(self.Properties.WorldInfoMessageHolder, 0.3, {h = extendedHeight, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.WorldInfoCard, 0.3, {
    h = extendedHeight + initHeight,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.LandingGlobalAnnouncementHolder, 0.3, {h = globalMessageHeight, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.LandingGlobalAnnouncement, 0.3, {
    h = globalMessageHeight + initHeight,
    ease = "QuadOut"
  })
  self:SetWorldInfoVisible(true)
end
function LandingScreen:ClearFirstTimeLandingScreen()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Misc.HasDoneFirstTimeLandingScreen", true)
  OptionsDataBus.Broadcast.SerializeOptions()
end
function LandingScreen:GetHasDoneFirstTimeLandingScreen()
  local enableFirstTimeFlow = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableFirstTimeLandingFlow")
  if not enableFirstTimeFlow then
    return true
  end
  local hasDoneFirstTime = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Misc.HasDoneFirstTimeLandingScreen")
  if hasDoneFirstTime then
    return hasDoneFirstTime
  end
  if not (self.worldListReady and self.characterDataReady) or self.currentCharacterData and #self.currentCharacterData > 0 then
    self:ClearFirstTimeLandingScreen()
    return true
  end
  return hasDoneFirstTime
end
return LandingScreen
