local DataLayer = RequireScript("LyShineUI.UiDataLayer")
local CanvasCommon = RequireScript("LyShineUI._Common.CanvasCommon")
local UiLoader = {
  fileType = ".uicanvas",
  currentGroupIdx = nil,
  tickHandler = nil,
  waitBetweenGroups = 0.25,
  timer = 1,
  screensToPreload = {},
  screenDataByCrc = {},
  numScreensToPreload = 0,
  numScreensLoaded = 0,
  localFtue = 796963181,
  ftue = 56733483,
  mainmenu = 3423674012,
  charCreation = 876429936,
  iconCapture = 719790917
}
function UiLoader:AddScreen(groupIdx, path, autohide, drawOrder, deferLoad)
  if deferLoad and not self.deferredCanvasLoading then
    deferLoad = false
  end
  if not self.screensToPreload[groupIdx] then
    self.screensToPreload[groupIdx] = {}
  end
  drawOrder = drawOrder or -1
  local loadData = {
    path = path,
    autohide = autohide,
    drawOrder = drawOrder
  }
  if not deferLoad then
    table.insert(self.screensToPreload[groupIdx], loadData)
  end
  local fileStr
  for str in string.gmatch(path, "([^/]+)") do
    fileStr = str
  end
  self.screenDataByCrc[Math.CreateCrc32(fileStr)] = {
    isLoaded = not deferLoad,
    loadData = loadData
  }
  self.numScreensToPreload = self.numScreensToPreload + 1
end
function UiLoader:OnActivate()
  self.dataLayer = DataLayer
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableAsyncCanvasLoading", function(self, enableAsyncCanvasLoading)
    self.enableAsyncCanvasLoading = enableAsyncCanvasLoading
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiDeferredCanvasLoading", function(self, deferredCanvasLoading)
    self.deferredCanvasLoading = deferredCanvasLoading
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Screens.RequestLoad", function(self, screenToLoadCrc)
    local screenData = self.screenDataByCrc[screenToLoadCrc]
    if not screenData then
      Debug.Log("Error, runtime load of screen failed, load data not found. Crc = " .. tostring(screenToLoadCrc))
      return
    end
    if not screenData.isLoaded then
      screenData.isLoaded = true
      local fullPath = screenData.loadData.path .. self.fileType
      LyShineScriptBindRequestBus.Broadcast.ScriptLoadCanvas(fullPath, screenData.loadData.autohide, screenData.loadData.drawOrder, false)
    end
  end)
end
function UiLoader:InitScreenList()
  local isConsoleActive = LyShineScriptBindRequestBus.Broadcast.GetCVar("sys_DeactivateConsole") == 0
  if isConsoleActive then
    self:AddScreen(1, "LyShineUI/Woody/Woody", true, CanvasCommon.POPUP_DRAW_ORDER)
    self:AddScreen(1, "LyShineUI/Logger/Logger", true, CanvasCommon.POPUP_DRAW_ORDER)
    self:AddScreen(1, "LyShineUI/_Debug/FullscreenAssert", true, CanvasCommon.TOP_LEVEL_DRAW_ORDER + 100)
    if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableStyleGuide") then
      self:AddScreen(1, "LyShineUI/_Samples/StyleGuide", true, CanvasCommon.POPUP_DRAW_ORDER)
    end
  end
  self:AddScreen(1, "LyShineUI/Options/Options", true, CanvasCommon.ESCAPE_MENU_DRAW_ORDER)
  self:AddScreen(1, "LyShineUI/Respawn/Respawn", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(1, "LyShineUI/HUD/Vitals/Vitals", false, CanvasCommon.VITALS_DRAW_ORDER)
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableHudSettings") then
    self:AddScreen(7, "LyShineUI/HUD/Quickslots/QuickslotsImmersive", false, CanvasCommon.QUICKSLOTS_DRAW_ORDER)
    self:AddScreen(5, "LyShineUI/Equipment/EquipmentV2", true, CanvasCommon.EQUIPMENT_DRAW_ORDER)
  else
    self:AddScreen(7, "LyShineUI/HUD/Quickslots/Quickslots", false, CanvasCommon.QUICKSLOTS_DRAW_ORDER)
    self:AddScreen(1, "LyShineUI/NavBar/Encumbrance", false, CanvasCommon.HIGH_HUD_DRAW_ORDER)
    self:AddScreen(5, "LyShineUI/Equipment/Equipment", true, CanvasCommon.EQUIPMENT_DRAW_ORDER)
  end
  self:AddScreen(1, "LyShineUI/Objectives/Hud/ObjectivesHud", false, CanvasCommon.HIGH_HUD_DRAW_ORDER)
  self:AddScreen(1, "LyShineUI/StatusEffects/StatusEffects", false, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(1, "LyShineUI/Banner/Banner", true, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(1, "LyShineUI/Compass/Compass", false, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(1, "LyShineUI/HUD/Chat/ChatWidget", false, CanvasCommon.CHAT_WIDGET_DRAW_ORDER)
  self:AddScreen(1, "LyShineUI/CampingRestrictions/CampingRestrictions", false, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(2, "LyShineUI/Container/CatContainer", true, CanvasCommon.INVENTORY_DRAW_ORDER)
  self:AddScreen(2, "LyShineUI/EscapeMenu/EscapeMenu", true, CanvasCommon.ESCAPE_MENU_DRAW_ORDER)
  self:AddScreen(2, "LyShineUI/Feedback/Feedback", true, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(2, "LyShineUI/FlyoutMenu/FlyoutMenu", true, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(2, "LyShineUI/FullScreenSpinner/FullScreenSpinner", true, CanvasCommon.TOP_LEVEL_DRAW_ORDER)
  self:AddScreen(2, "LyShineUI/GiveUp/GiveUp", false, CanvasCommon.RETICLE_DRAW_ORDER + 1)
  self:AddScreen(2, "LyShineUI/GuildMenu/Guild", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(2, "LyShineUI/HUD/Chat/Chat", false, CanvasCommon.CHAT_DRAW_ORDER)
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-crafting-v4") then
    self:AddScreen(3, "LyShineUI/Crafting/CraftingScreenV4", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  else
    self:AddScreen(3, "LyShineUI/Crafting/CraftingStation", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  end
  self:AddScreen(3, "LyShineUI/OldWorldGuilds/OWMissionBoard", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(3, "LyShineUI/Territory/TerritoryInfo/TerritoryInfoScreen", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(3, "LyShineUI/Raid/SignUp", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(3, "LyShineUI/TurretShop/TurretShop", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(4, "LyShineUI/Contracts/ContractBrowser", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(4, "LyShineUI/HUD/Glory/GloryBar", false, CanvasCommon.HIGH_HUD_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/HitIndicator/HitIndicator", false, CanvasCommon.TOP_LEVEL_DRAW_ORDER + 1)
  self:AddScreen(5, "LyShineUI/HUD/Generator", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/HUD/Reticles/Reticles", false, CanvasCommon.RETICLE_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/HUD/UnifiedInteractCard/InteractScreen", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/HUD/Voip/Voip", false, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/Inventory/NewInventory", true, CanvasCommon.INVENTORY_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/Inventory/StackSplitter", true, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/LootTicker/LootTicker", false, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/NavBar/NavBar", true, CanvasCommon.NAV_BAR_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/NavBar/WorldHitArea", true, 0)
  self:AddScreen(5, "LyShineUI/NetworkStatus/NetworkStatus", true, CanvasCommon.TOP_LEVEL_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/Notifications/Notification", false, CanvasCommon.NOTIFICATION_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/Afflictions/Afflictions", true, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/ContextMenu/ContextMenu", true, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/ClaimMarker/StartClaim", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/BuildMode/BuildMode", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/BuildBanner/BuildBanner", false, CanvasCommon.TOP_LEVEL_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/RewardScreen/RewardScreen", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.siege.enable-warboard") then
    self:AddScreen(5, "LyShineUI/Warboard/WarboardEndOfMatch", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
    self:AddScreen(5, "LyShineUI/Warboard/WarboardInGame", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
    self:AddScreen(5, "LyShineUI/Warboard/WarboardLiteHUD", false, CanvasCommon.HUD_DRAW_ORDER)
  end
  self:AddScreen(5, "LyShineUI/EmoteUI/EmoteUI", true, CanvasCommon.CHAT_DRAW_ORDER)
  self:AddScreen(5, "LyShineUI/HUD/DamageNumbers/DamageNumbers", false, CanvasCommon.DAMAGE_DRAW_ORDER)
  self:AddScreen(6, "LyShineUI/Markers/MarkerManager", true, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(6, "LyShineUI/Markers/UnifiedInteract", true, CanvasCommon.HUD_DRAW_ORDER + 1)
  self:AddScreen(6, "LyShineUI/Markers/SocialMarkers", false, CanvasCommon.HUD_DRAW_ORDER + 2)
  self:AddScreen(6, "LyShineUI/Skills/Skills", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(6, "LyShineUI/Store/StoreScreen", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(6, "LyShineUI/Popup/Popup", true, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(6, "LyShineUI/ReportPlayer/ReportPlayer", true, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(6, "LyShineUI/Popup/TransferCurrencyPopup", true, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(6, "LyShineUI/SpectatorHUD/SpectatorHUD", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  self:AddScreen(6, "LyShineUI/HUD/WarHUD/WarHUD", false, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(6, "LyShineUI/SocialPane/SocialPane", false, CanvasCommon.SOCIAL_PANE_DRAW_ORDER)
  self:AddScreen(7, "LyShineUI/StationProperties/StationProperties", true, CanvasCommon.FULLSCREEN_DRAW_ORDER + 1)
  self:AddScreen(7, "LyShineUI/Tooltip/Tooltip", false, CanvasCommon.TOOLTIP_DRAW_ORDER)
  self:AddScreen(7, "LyShineUI/WarDeclaration/WarDeclarationPopup", true, CanvasCommon.POPUP_DRAW_ORDER - 1)
  self:AddScreen(7, "LyShineUI/WarningBar/WarningBar", true, CanvasCommon.TOP_LEVEL_DRAW_ORDER)
  self:AddScreen(7, "LyShineUI/WorldMap/MagicMap", true, CanvasCommon.MAP_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Pinging/Pinging", false, CanvasCommon.DAMAGE_DRAW_ORDER)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.social.enable-player-inspect") then
    self:AddScreen(8, "LyShineUI/PlayerInspect/PlayerInspect", false, CanvasCommon.POPUP_DRAW_ORDER)
  end
  if LyShineScriptBindRequestBus.Broadcast.IsEditor() then
    self:AddScreen(8, "LyShineUI/FlyoutMenu/FlyoutMenuTesterEditorOnly", true, CanvasCommon.IN_GAME_MENU_DRAW_ORDER)
  end
  if self.isFtue then
    self:AddScreen(8, "LyShineUI/HUD/TutorialMessage/TutorialMessage", true, CanvasCommon.FTUE_NOTIFICATIONS)
    self:AddScreen(8, "LyShineUI/HUD/TutorialMessage/TutorialMessageLarge", true, CanvasCommon.FTUE_NOTIFICATIONS)
    self:AddScreen(8, "LyShineUI/Tutorial/UIFocusOverlay", false, CanvasCommon.FTUE_NOTIFICATIONS - 1)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-dyeing") then
    self:AddScreen(8, "LyShineUI/Dyes/ArmorDyeing", true, CanvasCommon.EQUIPMENT_DRAW_ORDER)
    self:AddScreen(8, "LyShineUI/Dyes/DyeDiscovery", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-journal") then
    self:AddScreen(8, "LyShineUI/Objectives/Journal/JournalScreen", true, CanvasCommon.ESCAPE_MENU_DRAW_ORDER)
  else
    self:AddScreen(8, "LyShineUI/LoreReader/LoreReader", true, CanvasCommon.ESCAPE_MENU_DRAW_ORDER)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-p2p-trading") then
    self:AddScreen(8, "LyShineUI/Trade/TradeScreen", true, CanvasCommon.INVENTORY_DRAW_ORDER)
  end
  self:AddScreen(8, "LyShineUI/InlineTextSuggestions/InlineTextSuggestions", true, CanvasCommon.NOTIFICATION_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Territory/TerritoryPlanning/TerritoryPlanning", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Territory/TerritoryPlanning/TownProjects", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Raid/Raid", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Housing/HomePurchase", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Housing/HousingEnter", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Housing/HousingHUD", false, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Housing/HousingDecoration", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Housing/HousingManagement", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/FullscreenFader/FullScreenFader", true, CanvasCommon.TOP_LEVEL_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Conversation/ConversationScreen", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/ConfirmationPopup/ConfirmationPopup", true, CanvasCommon.POPUP_DRAW_ORDER + 1)
  self:AddScreen(8, "LyShineUI/WarTutorialPopup/WarTutorialPopup", true, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Territory/TerritoryStanding/TerritoryBonusPopup", true, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Arena/ArenaEnterMenu", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/qte/qte", false, CanvasCommon.POPUP_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/Inn/InnInteractMenu", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/HUD/GameMode/GameModeHud", false, CanvasCommon.HUD_DRAW_ORDER)
  self:AddScreen(8, "LyShineUI/HUD/Fishing/Fishing", false, CanvasCommon.HUD_DRAW_ORDER)
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-faction-changing") then
    self:AddScreen(8, "LyShineUI/ChangeFaction/ChangeFaction", true, CanvasCommon.POPUP_DRAW_ORDER)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enableBoxOpeningPopup") then
    self:AddScreen(8, "LyShineUI/Inventory/BoxOpeningPopup", true, CanvasCommon.POPUP_DRAW_ORDER)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enableQueueHud") then
    self:AddScreen(8, "LyShineUI/Hud/Queue/QueueHud", false, CanvasCommon.HUD_DRAW_ORDER)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-game-mode-duels") then
    self:AddScreen(8, "LyShineUI/HUD/Duel/DuelHud", false, CanvasCommon.HUD_DRAW_ORDER)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-game-mode-outpost-rush") then
    self:AddScreen(8, "LyShineUI/HUD/OutpostRush/OutpostRushHud", false, CanvasCommon.HUD_DRAW_ORDER)
    self:AddScreen(8, "LyShineUI/HUD/OutpostRush/OutpostRushSummonPopup", true, CanvasCommon.HUD_DRAW_ORDER)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
    self:AddScreen(8, "LyShineUI/HUD/FactionControlPoint/FactionControlPointHUD", false, CanvasCommon.HUD_DRAW_ORDER)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-all-dungeons") then
    self:AddScreen(8, "LyShineUI/Dungeons/DungeonEnterScreen", true, CanvasCommon.FULLSCREEN_DRAW_ORDER)
    self:AddScreen(8, "LyShineUI/HUD/Dungeon/DungeonHud", false, CanvasCommon.HUD_DRAW_ORDER)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-territory-incentives-screen") then
    self:AddScreen(8, "LyShineUI/TerritoryIncentives/TerritoryIncentives", true, CanvasCommon.POPUP_DRAW_ORDER - 1)
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-in-game-survey") then
    self:AddScreen(8, "LyShineUI/InGameSurvey/InGameSurvey", true, CanvasCommon.POPUP_DRAW_ORDER)
  end
  self.screenEntityIds = {}
end
function UiLoader:StartLoading(levelNameCrc, currentLevelCrc)
  self.levelNameCrc = levelNameCrc
  local frontendLevelName = ConfigProviderEventBus.Broadcast.GetString("javelin.frontend-level-name")
  self.mainmenu = Math.CreateCrc32(frontendLevelName)
  self.isFtue = self.levelNameCrc == self.localFtue or self.levelNameCrc == self.ftue
  if self.isFtue or self.levelNameCrc ~= self.mainmenu and self.levelNameCrc ~= self.charCreation and self.levelNameCrc ~= self.iconCapture and (not currentLevelCrc or currentLevelCrc == self.mainmenu or currentLevelCrc == self.localFtue or currentLevelCrc == self.ftue or currentLevelCrc == self.charCreation) then
    self.screenDataByCrc = {}
    self.numScreensToPreload = 0
    self.numScreensLoaded = 0
    self.currentGroupIdx = nil
    self:InitScreenList()
    self.lyshineManagerNotificationsBus = LyShineManagerNotificationBus.Connect(self, EntityId())
    self.tickHandler = TickBus.Connect(self)
  end
end
function UiLoader:StopLoading()
  if self.levelNameCrc ~= self.mainmenu then
    LyShineManagerBus.Broadcast.SetState(2702338936)
  end
  if self.tickHandler then
    self.tickHandler:Disconnect()
    self.tickHandler = nil
  end
  if self.lyshineManagerNotificationsBus then
    self.lyshineManagerNotificationsBus:Disconnect()
    self.lyshineManagerNotificationsBus = nil
  end
end
function UiLoader:OnTick(delta, timePoint)
  if self.timer > self.waitBetweenGroups then
    local groupData
    self.currentGroupIdx, groupData = next(self.screensToPreload, self.currentGroupIdx)
    if self.currentGroupIdx and groupData then
      for _, screenData in ipairs(groupData) do
        local fullPath = screenData.path .. self.fileType
        self.screenEntityIds[#self.screenEntityIds + 1] = LyShineScriptBindRequestBus.Broadcast.ScriptLoadCanvas(fullPath, screenData.autohide, screenData.drawOrder, self.enableAsyncCanvasLoading)
      end
    else
      self.screensToPreload = {}
      self.tickHandler:Disconnect()
      self.tickHandler = nil
    end
    self.timer = 0
  else
    self.timer = self.timer + delta
  end
end
function UiLoader:OnDeactivate()
  self:StopLoading()
end
function UiLoader:OnCanvasLoaded(canvasId)
  self.numScreensLoaded = self.numScreensLoaded + 1
  local canvasName = UiCanvasBus.Event.GetCanvasName(canvasId)
  if self.numScreensLoaded == self.numScreensToPreload then
    UILoadingNotificationBus.Broadcast.OnUILoadingComplete()
    DynamicBus.UiLoader.Broadcast.OnUiLoadingComplete()
    LyShineManagerBus.Broadcast.SetState(2702338936)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.enableNameplateSlider", function(self, enableNameplateSlider)
      if enableNameplateSlider then
        self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Options.Video.NameplateQuantity", function(self, nameplateQuantity)
          local fullPath = "LyShineUI/Markers/MarkerManager" .. self.fileType
          local markerCanvasId = UiCanvasManagerBus.Broadcast.FindLoadedCanvasByPathName(fullPath)
          if markerCanvasId and markerCanvasId:IsValid() then
            LyShineManagerBus.Broadcast.DeregisterScreen(markerCanvasId)
            UiCanvasManagerBus.Broadcast.UnloadCanvas(markerCanvasId)
            LocalPlayerMarkerRequestBus.Broadcast.ResetMarkerManager()
            LyShineScriptBindRequestBus.Broadcast.ScriptLoadCanvas(fullPath, true, CanvasCommon.HUD_DRAW_ORDER, false)
          end
        end)
      end
    end)
    self.dataLayer:RegisterDataObserver(self, "UIFeatures.g_uiDisableScreenLoading", function(self, isScreenLoadingDisabled)
      if isScreenLoadingDisabled then
        LyShineManagerBus.Broadcast.DeregisterAllScreens()
      elseif self.screenEntityIds then
        for _, screenData in ipairs(self.screensToPreload) do
          local fullPath = screenData.path .. self.fileType
          self.screenEntityIds[#self.screenEntityIds + 1] = LyShineScriptBindRequestBus.Broadcast.ScriptLoadCanvas(fullPath, screenData.autohide, screenData.drawOrder)
        end
      end
    end)
    if self.lyshineManagerNotificationsBus then
      self.lyshineManagerNotificationsBus:Disconnect()
      self.lyshineManagerNotificationsBus = nil
    end
  end
end
return UiLoader
