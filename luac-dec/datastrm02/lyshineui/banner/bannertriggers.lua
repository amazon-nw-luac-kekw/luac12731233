local BannerTriggers = {
  WAR_BANNER_DISPLAY_DURATION = 9,
  WAR_BANNER_DRAW_ORDER = 25,
  BANNER_DRAW_ORDER_TOP = 100,
  TERRITORY_CLAIMED_BANNER_DRAW_ORDER = 25,
  POINT_CHECK_TIME = 300,
  POINT_FORCED_TIME = 20,
  POINT_BANNER_DISPLAY_DURATION = 6,
  TOWN_CHECKIN_THRESHOLD = 20,
  mLastDamagedClaim = "",
  mLastDamagedClaimHealth = 100,
  mDamageBannerId = nil,
  queuedTradeskillBanners = {},
  timeSincePointCheck = 0,
  attributePoints = 0,
  masteryPoints = 0,
  firstLoadingScreenDismissed = false,
  raidId = RaidId(),
  DEBUG_OBJECTIVE_COMPLETED = false,
  ITEM_ICON_PATH = "LyShineUI\\Images\\Icons\\Items\\%s\\%s.dds",
  TRADESKILL_ICON_PATH = "LyShineUI\\Images\\Tradeskills\\tradeskill_%s.dds"
}
local layouts = RequireScript("LyShineUI.Banner.Layouts")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives.ObjectiveTypeData")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local ObjectivesDataHandler = RequireScript("LyShineUI._Common.ObjectivesDataHandler")
local WeaponMasteryData = RequireScript("LyShineUI.Skills.WeaponMastery.WeaponMasteryData")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local EncounterDataHandler = RequireScript("LyShineUI._Common.EncounterDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local TradeSkillsCommon = RequireScript("LyShineUI._Common.TradeSkillsCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local inventoryCommon = RequireScript("LyShineUI._Common.InventoryCommon")
local UIStyle = RequireScript("LyShineUI._Common.UIStyle")
local TerritoryEnteredCardTypes = {
  TerritoryType = 0,
  SettlementType = 1,
  FortType = 2,
  HQType = 3,
  OutpostType = 4,
  OpenWorld = 5
}
function BannerTriggers:OnInit(banners, dataLayer, tweener, audioHelper)
  if not (banners and dataLayer and tweener) or not audioHelper then
    Log("BannerTriggers:Init(): invalid init parameters")
    return
  end
  self.TOWN_PROJECTS_STATE = 640726528
  self.OWMISSION_BOARD_STATE = 2609973752
  self.notificationHandlers = {}
  self.banners = banners
  self.dataLayer = dataLayer
  self.ScriptedEntityTweener = tweener
  self.audioHelper = audioHelper
  self.playerLevel = nil
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.territoryTokens = {}
  self:RegisterObservers()
  self.loadScreenNotificationBus = self:BusConnect(LoadScreenNotificationBus, self.entityId)
  self:BusConnect(LandClaimNotificationBus)
  self:BusConnect(MapComponentEventBus)
  self:BusConnect(LocalPlayerEventsBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      if self.playerEntityId and self.categoricalProgressionHandler then
        self:BusDisconnect(self.categoricalProgressionHandler)
        self.categoricalProgressionHandler = nil
      end
      self.playerEntityId = playerEntityId
      local forceBanner = self:UpdateTerritoryTokens()
      self:TryPointsBanner(forceBanner)
      self.categoricalProgressionHandler = self:BusConnect(CategoricalProgressionNotificationBus, self.playerEntityId)
      self.progressionPointHandler = self:BusConnect(ProgressionPointsNotificationBus, self.playerEntityId)
    end
  end)
  self.layoutsWithCustomAnimateIn = {
    layouts.LAYOUT_TEXT_CARD,
    layouts.LAYOUT_LEVEL_UP_BANNER,
    layouts.ROW_TERRITORY_LEVEL_UP_BANNER,
    layouts.LAYOUT_WAR_CARD,
    layouts.LAYOUT_TERRITORY_CLAIMED,
    layouts.LAYOUT_ACHIEVEMENT,
    layouts.LAYOUT_TOWN_STRUCTURE_CHANGED,
    layouts.LAYOUT_TOWN_PROJECT_STARTED,
    layouts.LAYOUT_TERRITORY_ENTERED,
    layouts.LAYOUT_TERRITORY_LEVEL_UP_BANNER
  }
  self.layoutsWithCustomAnimateOut = {
    layouts.LAYOUT_TEXT_CARD,
    layouts.LAYOUT_LEVEL_UP_BANNER,
    layouts.ROW_TERRITORY_LEVEL_UP_BANNER,
    layouts.LAYOUT_WAR_CARD,
    layouts.LAYOUT_TERRITORY_CLAIMED,
    layouts.LAYOUT_ACHIEVEMENT,
    layouts.LAYOUT_TOWN_STRUCTURE_CHANGED,
    layouts.LAYOUT_TOWN_PROJECT_STARTED,
    layouts.LAYOUT_TERRITORY_ENTERED,
    layouts.LAYOUT_TERRITORY_LEVEL_UP_BANNER
  }
  self.layoutsWithCustomAnimateOutCallback = {
    [layouts.LAYOUT_LEVEL_UP_BANNER] = true
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, factionType)
    self.localPlayerFaction = factionType
    if self.notifyFactionsConflictsOnFactionSet then
      self.notifyFactionsConflictsOnFactionSet = false
      self:NotifyInitialFactionConflicts()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isAvailable)
    self.landClaimAvailable = isAvailable
    if isAvailable == true then
      local rawClaimKeys = LandClaimRequestBus.Broadcast.GetClaimKeys()
      for i = 1, #rawClaimKeys do
        local claimKey = rawClaimKeys[i]
        local conflictFaction = LandClaimRequestBus.Broadcast.GetTerritoryConflictFaction(claimKey)
        self:OnTerritoryConflictFactionChanged(claimKey, conflictFaction)
      end
      if self.localPlayerFaction then
        self:NotifyInitialFactionConflicts()
      else
        self.notifyFactionsConflictsOnFactionSet = true
      end
      self:TryTerritoryUpkeepNotification()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.OverpopulateTeleportTime", function(self, teleportTime)
    if teleportTime then
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local teleportTimeInSec = teleportTime:Subtract(now):ToSeconds()
      if 0 < teleportTimeInSec then
        self:OnOverpopulationPopup(teleportTimeInSec)
      end
    end
  end)
end
local overpopPopupId = "OverpopulationPopup"
function BannerTriggers:OnOverpopulationPopup(timeRemainingSeconds)
  PopupWrapper:RequestPopupWithParams({
    title = "@ui_overpopulationPopup",
    message = "@ui_overpopulationPopup_desc",
    eventId = overpopPopupId,
    callerSelf = self,
    callback = function(self, result, eventId)
      if eventId == overpopPopupId then
        LocalPlayerComponentRequestBus.Broadcast.RequestImmediateOverpopulationTeleport()
      end
    end,
    buttonText = "@ui_overpopulationPopup_teleport",
    additionalHeight = 30,
    customData = {
      {
        detailType = "RemainingTime",
        value = timeRemainingSeconds
      }
    }
  })
  self.isOverpopPopupShowing = true
  if not self.loadScreenNotificationBus then
    self.loadScreenNotificationBus = self:BusConnect(LoadScreenNotificationBus, self.entityId)
  end
end
function BannerTriggers:OnLoadingScreenShown()
  if self.isOverpopPopupShowing then
    UiPopupBus.Broadcast.HidePopup(overpopPopupId)
    self.isOverpopPopupShowing = false
  end
  if self.firstLoadingScreenDismissed and self.loadScreenNotificationBus then
    self:BusDisconnect(self.loadScreenNotificationBus)
    self.loadScreenNotificationBus = nil
  end
end
function BannerTriggers:OnLoadingScreenDismissed()
  self.firstLoadingScreenDismissed = true
  if self.isOverpopPopupShowing then
    UiPopupBus.Broadcast.HidePopup(overpopPopupId)
    self.isOverpopPopupShowing = false
  end
  if self.firstLoadingScreenDismissed and self.loadScreenNotificationBus then
    self:BusDisconnect(self.loadScreenNotificationBus)
    self.loadScreenNotificationBus = nil
  end
end
function BannerTriggers:NotifyInitialFactionConflicts()
  if self.localPlayerFaction == eFactionType_None then
    return
  end
  local numInConflict = 0
  for claimKey, factionId in pairs(self.initialConflictFactions) do
    if factionId == self.localPlayerFaction then
      numInConflict = numInConflict + 1
    end
  end
  if 0 < numInConflict then
    local notificationData = NotificationData()
    notificationData.type = "Social"
    notificationData.icon = "LyShineUI/Images/Icons/Misc/icon_warUncolored.dds"
    notificationData.title = "@owg_influence_login_notification_title"
    notificationData.text = GetLocalizedReplacementText("@owg_influence_login_notification_desc", {count = numInConflict})
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function BannerTriggers:OnShutdown()
  for _, handler in ipairs(self.notificationHandlers) do
    handler:Disconnect()
  end
  self.socialDataHandler:OnDeactivate()
  self.notificationHandlers = {}
  TimingUtils:StopDelay(self)
  self.pointsBannerDelay = nil
end
function BannerTriggers:BusConnect(bus, param)
  if bus == nil then
    Log("Trying to connect a bus that is nil.\n" .. debug.traceback())
    return
  end
  local handler
  if param == nil then
    handler = bus.Connect(self)
  else
    handler = bus.Connect(self, param)
  end
  table.insert(self.notificationHandlers, handler)
  return handler
end
function BannerTriggers:BusDisconnect(bushandler, param)
  if bushandler == nil then
    return
  end
  if param == nil then
    bushandler:Disconnect()
  else
    bushandler:Disconnect(param)
  end
  for index, handler in ipairs(self.notificationHandlers) do
    if handler == bushandler then
      table.remove(self.notificationHandlers, index)
      return
    end
  end
end
function BannerTriggers:GetGuildDetailedDataFailure(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - BannerTriggers:WarBanner: GuildData request throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - BannerTriggers:WarBanner: GuildData request timed out")
  end
end
function BannerTriggers:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Siege.SiegePhase", function(self, isInSiegePhase)
    self.isPlayerAtWar = isInSiegePhase
  end)
  LyShineDataLayerBus.Broadcast.SetData("LyShineUi.Banners.BannerScreenId", self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableClaimDamageBanner", function(self, enableClaimDamageBanner)
    self.mEnableClaimDamageBanners = enableClaimDamageBanner
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableClaimProtectedBanner", function(self, enableClaimProtectedBanner)
    self.mEnableClaimProtectedBanners = enableClaimProtectedBanner
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, claimKey)
    if claimKey and claimKey ~= 0 and not LoadScreenBus.Broadcast.IsLoadingScreenShown() then
      self:ShowTerritoryEnteredCard(claimKey, TerritoryEnteredCardTypes.TerritoryType)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HudComponent.OutpostId", function(self, outpostId)
    if not self.dataLayer:GetDataFromNode("UIFeatures.g_enableContracts") then
      return
    end
    if outpostId and string.len(outpostId) > 0 and not LoadScreenBus.Broadcast.IsLoadingScreenShown() then
      local claimKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
      local additionalData = {outpostId = outpostId}
      self:ShowTerritoryEnteredCard(claimKey, TerritoryEnteredCardTypes.OutpostType, additionalData)
    end
  end)
  self:BusConnect(UiTriggerAreaEventNotificationBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    if raidId and raidId:IsValid() then
      self.raidId = raidId
      if self.groupsNotificationBusHandler then
        self:BusDisconnect(self.groupsNotificationBusHandler)
        self.groupsNotificationBusHandler = nil
      end
      self.groupsNotificationBusHandler = self:BusConnect(GroupsUINotificationBus)
    else
      self.raidId:Reset()
      self:BusDisconnect(self.groupsNotificationBusHandler)
      self.groupsNotificationBusHandler = nil
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.WarDataBeenReplicated", function(self, replicated)
    if replicated then
      self.warDataReplicationTime = os.time()
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", function(self, warId)
    if not warId then
      return
    end
    if not self.firstLoadingScreenDismissed then
      return
    end
    if self.warDataReplicationTime == nil then
      return
    end
    local now = os.time()
    local timeElapsedSinceInitialReplicationSeconds = now - self.warDataReplicationTime
    if timeElapsedSinceInitialReplicationSeconds < 60 then
      return
    end
    local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
    if warDetails:GetWarPhase() ~= eWarPhase_PreWar then
      return
    end
    local guildIds = vector_GuildId()
    if not warDetails:IsInvasion() then
      guildIds:push_back(warDetails:GetAttackerGuildId())
    end
    guildIds:push_back(warDetails:GetDefenderGuildId())
    local function successCallback(self, results)
      local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
      local attackingGuildData, defendingGuildData
      for i = 1, #results do
        if results[i].guildId == warDetails:GetAttackerGuildId() then
          attackingGuildData = results[i]
        elseif results[i].guildId == warDetails:GetDefenderGuildId() then
          defendingGuildData = results[i]
        end
      end
      local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(warDetails:GetTerritoryId())
      local warTitleText = ""
      local warDetailText = ""
      local defendingGuildCrest, attackingGuildCrest
      if warDetails:IsInvasion() then
        warTitleText = "@ui_invasion_declared"
        warDetailText = GetLocalizedReplacementText("@ui_invasion_declared_details", {territoryName = territoryName})
      else
        warTitleText = "@ui_war_prewar"
        warDetailText = GetLocalizedReplacementText("@ui_war_declared_details", {territoryName = territoryName})
        defendingGuildCrest = defendingGuildData.crestData
        attackingGuildCrest = attackingGuildData.crestData
      end
      local bannerColor = 1
      local phaseEndTime = warDetails:GetPhaseEndTime()
      local isAttacking = self.localPlayerFaction == warDetails:GetAttackerFaction()
      local isInvasion = warDetails:IsInvasion()
      self.WAR_BANNER_DISPLAY_DURATION = layouts.WAR_BANNER_DISPLAY_DURATION
      self.audioHelper:PlaySound(self.audioHelper.Banner_WarDeclared)
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_WarDeclaration)
      local bannerData = {
        WarCard1 = {
          warTitleText = warTitleText,
          warDetailText = warDetailText,
          phaseEndTime = phaseEndTime,
          isAttacking = isAttacking,
          bannerColor = bannerColor,
          isInvasion = isInvasion,
          defendingGuildCrest = defendingGuildCrest,
          attackingGuildCrest = attackingGuildCrest
        }
      }
      local priority = 3
      self.banners:EnqueueBanner(layouts.LAYOUT_WAR_CARD, bannerData, self.WAR_BANNER_DISPLAY_DURATION, nil, nil, false, priority, self.WAR_BANNER_DRAW_ORDER)
    end
    local failureCallback = function(reason)
      if reason == eSocialRequestFailureReasonThrottled then
        Log("ERR - BannerTriggers:RequestGetGuilds: Throttled")
      elseif reason == eSocialRequestFailureReasonTimeout then
        Log("ERR - BannerTriggers:RequestGetGuilds: Timed Out")
      end
    end
    self.socialDataHandler:RequestGetGuilds_ServerCall(self, successCallback, failureCallback, guildIds)
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastEnemyClaimDestroyed.EnemyGuild", function(self, enemyGuild)
    local claimName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastEnemyClaimDestroyed.ClaimName")
    local claimPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastEnemyClaimDestroyed.ClaimPosition")
    local enemyGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastEnemyClaimDestroyed.EnemyGuildId")
    local playerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
    local playerGuildData = {
      guildName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Name"),
      crestData = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Crest")
    }
    local function successCallback(self, result)
      local guildData
      if 0 < #result then
        guildData = type(result[1]) == "table" and result[1].guildData or result[1]
      else
        Log("ERR - BannerTriggers:WarBanner: GuildData request returned with no data")
        return
      end
      if guildData and guildData:IsValid() then
        local keys = vector_basic_string_char_char_traits_char()
        keys:push_back("claimName")
        local values = vector_basic_string_char_char_traits_char()
        values:push_back(claimName)
        local isAtWar = WarDataClientRequestBus.Broadcast.IsAtWarWithGuild(enemyGuildId)
        local warTitleText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_war_claim_destroyed", keys, values)
        local warGuildsText = ""
        local warDetailText = isAtWar and "@ui_war_claimdestroyed_detail" or ""
        local warMessageText = isAtWar and "@ui_claimDestroyed_message" or "@ui_war_neutral_claim_marker_destroyed"
        local is2Steps = true
        local isSingleCrest = true
        local bannerColor = 2
        self.WAR_BANNER_DISPLAY_DURATION = layouts.INVASION_BANNER_DISPLAY_DURATION
        local attackingGuildData = playerGuildData
        local defendingGuildData = guildData
        local attackingGuildName = attackingGuildData.guildName
        local defendingGuildName = defendingGuildData.guildName
        if attackingGuildName and defendingGuildName then
          local keys = vector_basic_string_char_char_traits_char()
          keys:push_back("defendingGuildName")
          local values = vector_basic_string_char_char_traits_char()
          values:push_back(defendingGuildName)
          warGuildsText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_claimMarkerDestroyed", keys, values)
        end
        self.audioHelper:PlaySound(self.audioHelper.Banner_WarDeclared)
        self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_WarDeclaration)
        local attackingGuildCrest = attackingGuildData.crestData
        local defendingGuildCrest = defendingGuildData.crestData
        local bannerData = {
          WarCard1 = {
            warTitleText = warTitleText,
            warGuildsText = warGuildsText,
            warDurationText = "",
            warMessageText = warMessageText,
            warDetailText = warDetailText,
            phaseEndTime = nil,
            warAttackingGuildCrestData = attackingGuildCrest,
            warDefendingGuildCrestData = defendingGuildCrest,
            is2Steps = is2Steps,
            isSingleCrest = isSingleCrest,
            bannerColor = bannerColor
          }
        }
        local priority = 3
        self.banners:EnqueueBanner(layouts.LAYOUT_WAR_CARD, bannerData, self.WAR_BANNER_DISPLAY_DURATION, nil, nil, false, priority, self.WAR_BANNER_DRAW_ORDER)
      end
    end
    self.socialDataHandler:GetGuildDetailedData_ServerCall(self, successCallback, self.GetGuildDetailedDataFailure, enemyGuildId)
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastLockedClaimTaken.ClaimingGuild", function(self, claimingGuild)
    local claimName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.LastLockedClaimTaken.ClaimName")
    local text = GetLocalizedReplacementText("@ui_war_claim_taken", {claimName = claimName, guildName = claimingGuild})
    bannerData = {
      Text1 = {text = text}
    }
    local priority = 3
    local duration = 10
    self.mDamageBannerId = self.banners:EnqueueBanner(layouts.LAYOUT_CLAIM_TAKEN_MESSAGE, bannerData, duration, nil, nil, false, priority, self.WAR_BANNER_DRAW_ORDER)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Progression.Level", function(self, level)
    local enableGlory = self.dataLayer:GetDataFromNode("UIFeatures.g_uiEnableGloryBar")
    if not (enableGlory and level) or level < 1 or self.playerLevel == level then
      return
    end
    local firstTime = not self.playerLevel
    self.playerLevel = level
    if firstTime then
      return
    end
    local bannerData = {
      BannerLevelUp1 = {level = level, play = true}
    }
    local priority = 4
    local duration = layouts.DEFAULT_DISPLAY_DURATION
    local data = DynamicBus.MilestoneWindow.Broadcast.GetDataFromLevel(level)
    if data then
      bannerData.BannerLevelUp1.milestoneData = data
      for i = 1, #data do
        local milestoneData = data[i]
        if milestoneData.type == eMilestoneType_TerritoryRecommendation then
          duration = duration + layouts.DEFAULT_DISPLAY_DURATION
          break
        end
      end
      duration = duration + layouts.DEFAULT_DISPLAY_DURATION
    else
      local showNextMilestone = false
      local enableUpdatedRewardMapping = self.dataLayer:GetDataFromNode("UIFeatures.enable-updated-reward-mapping")
      if showNextMilestone and enableUpdatedRewardMapping then
        local nextMilestone = DynamicBus.MilestoneWindow.Broadcast.GetNextMilestoneForLevel(level)
        if 0 < nextMilestone then
          bannerData.BannerLevelUp1.nextMilestone = nextMilestone
          duration = duration * 2
        end
      end
    end
    self.banners:EnqueueBanner(layouts.LAYOUT_LEVEL_UP_BANNER, bannerData, duration, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Journal.NewChapterId", function(self, loreId)
    local loreData = LoreDataManagerBus.Broadcast.GetLoreData(loreId)
    local bannerData = {
      AchievementCard1 = {
        title = "@ui_chapter_discovered_title",
        subject = loreData.title,
        prompt = "@ui_openjournal",
        promptAction = "toggleJournalComponent",
        icon = "lyshineui/images/icons/objectives/icon_lore.png",
        iconColor = UIStyle.COLOR_GRAY_80,
        shouldPlayGlow = true
      }
    }
    local priority = 4
    self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, layouts.DEFAULT_DISPLAY_DURATION, nil, nil, false, priority)
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Journal.ChapterComplete", function(self, loreId)
    local loreData = LoreDataManagerBus.Broadcast.GetLoreData(loreId)
    local bannerData = {
      AchievementCard1 = {
        title = "@ui_chapter_complete_title",
        subject = loreData.title,
        prompt = "@ui_openjournal",
        promptAction = "toggleJournalComponent",
        icon = "lyshineui/images/icons/objectives/icon_lore.png",
        iconColor = UIStyle.COLOR_GRAY_80,
        shouldPlayGlow = true
      }
    }
    local priority = 4
    self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, layouts.DEFAULT_DISPLAY_DURATION, nil, nil, false, priority)
  end)
  self.enableObjectives = false
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-objectives") then
    self.enableObjectives = true
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId == nil then
      return
    end
    self.rootPlayerId = rootEntityId
    if self.enableObjectives then
      self:BusDisconnect(self.objectivesComponentBusHandler)
      self.objectivesComponentBusHandler = self:BusConnect(ObjectivesComponentNotificationsBus, rootEntityId)
      if self.playerArenaEventHandler then
        self:BusDisconnect(self.playerArenaEventHandler)
      end
      self.playerArenaEventHandler = self:BusConnect(PlayerArenaEventBus, rootEntityId)
    end
  end)
  SlashCommands:RegisterSlashCommand("townproject", function(args)
    if #args < 2 then
      return
    end
    local progressionData = TerritoryProgressionData()
    progressionData.description = "Blacksmith Upgrade Tier 2 to Tier 3"
    progressionData.image = "LyShineUI\\Images\\items\\BlacksmithT3.png"
    if args[2] == "start" then
      progressionData.title = "@ui_town_project_started"
      self:OnTownStructureChanged("Brightmark", progressionData, {}, UIStyle.COLOR_GREEN_LIGHT, UIStyle.COLOR_GREEN)
    end
    if args[2] == "upgrade" then
      progressionData.title = "@ui_town_project_completed"
      self:OnTownStructureChanged("Brightmark", progressionData, {}, UIStyle.COLOR_YELLOW_GOLD, UIStyle.COLOR_YELLOW_GOLD)
    end
    if args[2] == "downgrade" then
      local bannerData = {
        TextCard1 = {
          title = GetLocalizedReplacementText("@ui_territory_downgraded_banner", {
            structure = "Blacksmithing"
          }),
          sound = self.audioHelper.Banner_TerritoryDowngrade,
          musicSwitch = self.audioHelper.MusicSwitch_Gameplay,
          musicState = self.audioHelper.MusicState_Territory_Downgraded
        }
      }
      local priority = 4
      self.banners:EnqueueBanner(layouts.LAYOUT_TEXT_CARD, bannerData, layouts.DEFAULT_DISPLAY_DURATION, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
    end
    if args[2] == "taken" then
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Guild.LastLockedClaimTaken.ClaimingGuild", 1)
    end
  end)
  self:BusDisconnect(self.gameEventUiNotificationBusHandler)
  self.gameEventUiNotificationBusHandler = self:BusConnect(GameEventUiNotificationBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", function(self, guildId)
    self.guildId = guildId
    self:TryTerritoryUpkeepNotification()
    if self.guildId then
      self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.Id")
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.UnspentPoints", function(self, attributePoints)
    if attributePoints then
      local forceBanner = attributePoints > self.attributePoints
      self.attributePoints = attributePoints
      if forceBanner then
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Attributes.ScreenChecked", false)
      end
      self:TryPointsBanner(forceBanner)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Skills.MasteryPoints", function(self, masteryPoints)
    if masteryPoints then
      local forceBanner = masteryPoints > self.masteryPoints
      self.masteryPoints = masteryPoints
      if forceBanner then
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Skills.ScreenChecked", false)
      end
      self:TryPointsBanner(forceBanner)
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Damage.OnDownedPlayer", function(self, playerName)
    local chatMessage = BaseGameChatMessage()
    chatMessage.type = eChatMessageType_Group
    chatMessage.isPingMsg = true
    chatMessage.body = GetLocalizedReplacementText("@ui_downed_notification", {playerName = playerName})
    ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    self.audioHelper:PlaySound(self.audioHelper.KnockedDown_Player)
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Damage.OnKilledPlayer", function(self, playerName)
    local chatMessage = BaseGameChatMessage()
    chatMessage.type = eChatMessageType_Group
    chatMessage.isPingMsg = true
    chatMessage.body = GetLocalizedReplacementText("@ui_killed_notification", {playerName = playerName})
    ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    self.audioHelper:PlaySound(self.audioHelper.Killed_Player)
  end)
end
function BannerTriggers:OnCategoricalProgressionPointsChanged(progressionId, oldRank, newRank)
  if self.territoryTokens[progressionId] then
    local unspentTokens = ProgressionPointRequestBus.Event.GetUnspentTokens(self.playerEntityId, progressionId)
    if unspentTokens then
      local forceBanner = unspentTokens > self.territoryTokens[progressionId]
      if forceBanner then
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Map.ScreenChecked", false)
      end
      self.territoryTokens[progressionId] = unspentTokens
      self:TryPointsBanner(forceBanner)
    end
  end
end
function BannerTriggers:OnProgressionPointsChanged(pointId, oldLevel, newLevel)
  local pointData = ProgressionPointRequestBus.Event.GetStaticProgressionPointData(self.playerEntityId, pointId)
  if pointData.poolCategory == ePoolCategory_Territory then
    local forceBanner = self:UpdateTerritoryTokens()
    if forceBanner then
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Map.ScreenChecked", false)
    end
    self:TryPointsBanner(forceBanner)
  end
end
function BannerTriggers:UpdateTerritoryTokens()
  local forceBanner = false
  local claims = MapComponentBus.Broadcast.GetClaims()
  for index = 1, #claims do
    local territoryCrc = Math.CreateCrc32(tostring(claims[index].settlementId))
    local unspentPoints = ProgressionPointRequestBus.Event.GetUnspentTokens(self.playerEntityId, territoryCrc) or 0
    if not self.territoryTokens[territoryCrc] then
      self.territoryTokens[territoryCrc] = 0
    end
    forceBanner = forceBanner or unspentPoints > self.territoryTokens[territoryCrc]
    self.territoryTokens[territoryCrc] = unspentPoints
  end
  return forceBanner
end
function BannerTriggers:GetTotalUnspentTokens()
  local unspent = 0
  for idCrc, tokens in pairs(self.territoryTokens) do
    unspent = unspent + tokens
  end
  return unspent
end
function BannerTriggers:ExecutePointsBanner()
  if self.raidId and self.raidId:IsValid() then
    return
  end
  local hasPointsToDisplay = false
  local showAttributePoints = not self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Attributes.ScreenChecked") and self.attributePoints > 0
  local showMasteryPoints = not self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Skills.ScreenChecked") and 0 < self.masteryPoints
  local currentScreenState = LyShineManagerBus.Broadcast.GetCurrentState()
  if currentScreenState ~= 3576764016 and (showAttributePoints or showMasteryPoints) then
    local header1, header2, point1, point2, color1, color2
    if showAttributePoints and showMasteryPoints then
      header1 = "@ui_attribute_point"
      header2 = "@ui_mastery_point"
      point1 = self.attributePoints
      point2 = self.masteryPoints
      color1 = UIStyle.COLOR_XP
      color2 = UIStyle.COLOR_MASTERY
    elseif showAttributePoints then
      header1 = "@ui_attribute_point"
      point1 = self.attributePoints
      color1 = UIStyle.COLOR_XP
    elseif showMasteryPoints then
      header1 = "@ui_mastery_point"
      point1 = self.masteryPoints
      color1 = UIStyle.COLOR_MASTERY
    end
    if header1 then
      local bannerData = {
        TextCard1 = {
          header1 = header1,
          header2 = header2,
          point1 = point1,
          point2 = point2,
          color1 = color1,
          color2 = color2,
          title = "@ui_points_available",
          hintText = LyShineManagerBus.Broadcast.GetKeybind("toggleSkillsComponent", "ui")
        }
      }
      if self.currentSkillPointsBanner then
        self.banners:RescindBanner(self.currentSkillPointsBanner)
      end
      local priority = 3
      self.currentSkillPointsBanner = self.banners:EnqueueBanner(layouts.LAYOUT_TEXT_CARD, bannerData, self.POINT_BANNER_DISPLAY_DURATION, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
      hasPointsToDisplay = true
    end
  end
  local showStandingPoints = not self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Map.ScreenChecked") and 0 < self.standingTokens
  if currentScreenState ~= 2477632187 and showStandingPoints then
    local bannerData = {
      TextCard1 = {
        header1 = "@ui_standing_point",
        point1 = self.standingTokens,
        color1 = UIStyle.COLOR_STANDING,
        title = "@ui_points_available",
        hintText = LyShineManagerBus.Broadcast.GetKeybind("toggleMapComponent", "ui")
      }
    }
    if self.curentStandingPointsBanner then
      self.banners:RescindBanner(self.curentStandingPointsBanner)
    end
    local priority = 3
    self.curentStandingPointsBanner = self.banners:EnqueueBanner(layouts.LAYOUT_TEXT_CARD, bannerData, self.POINT_BANNER_DISPLAY_DURATION, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
    hasPointsToDisplay = true
  end
  if not hasPointsToDisplay then
    TimingUtils:StopDelay(self, self.ExecutePointsBanner)
    self.pointsBannerDelay = nil
  end
end
function BannerTriggers:TryPointsBanner(forceBanner)
  if self.raidId and self.raidId:IsValid() then
    return
  end
  self.standingTokens = self:GetTotalUnspentTokens()
  if not (self.attributePoints and self.masteryPoints) or not self.standingTokens then
    return
  end
  if self.attributePoints > 0 or self.masteryPoints > 0 or self.standingTokens > 0 then
    if forceBanner then
      TimingUtils:StopDelay(self, self.ExecutePointsBanner)
      self.pointsBannerDelay = nil
      TimingUtils:Delay(self.POINT_FORCED_TIME, self, self.ExecutePointsBanner)
    end
    if not self.pointsBannerDelay then
      self.pointsBannerDelay = TimingUtils:Delay(self.POINT_CHECK_TIME, self, self.ExecutePointsBanner, true)
    end
  end
end
function BannerTriggers:TryTerritoryUpkeepNotification()
  if self.guildId and self.landClaimAvailable then
    local rawClaimKeys = LandClaimRequestBus.Broadcast.GetClaimKeys()
    for i = 1, #rawClaimKeys do
      local claimKey = rawClaimKeys[i]
      local governanceData = LandClaimRequestBus.Broadcast.GetTerritoryGovernanceData(claimKey)
      if governanceData.failedToPayUpkeep then
        self:OnTerritoryUpkeepChanged(claimKey, true)
      end
    end
  end
end
function BannerTriggers:OnTerritoryUpkeepChanged(key, taxesDue)
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    return
  end
  if taxesDue then
    local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(key)
    local isInGuild = ownerData.guildId == self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
    if isInGuild then
      local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(key)
      local territoryUpkeepLocText = GetLocalizedReplacementText("@ui_territory_upkeep_due", {name = territoryName})
      local bannerData = {
        TextCard1 = {
          title = territoryUpkeepLocText,
          sound = self.audioHelper.Banner_TerritoryDowngrade,
          musicSwitch = self.audioHelper.MusicSwitch_Gameplay,
          musicState = self.audioHelper.MusicState_Territory_Downgraded
        }
      }
      local priority = 4
      self.banners:EnqueueBanner(layouts.LAYOUT_TEXT_CARD, bannerData, layouts.DEFAULT_DISPLAY_DURATION, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
      local chatMessage = BaseGameChatMessage()
      chatMessage.type = eChatMessageType_System
      chatMessage.body = territoryUpkeepLocText
      ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    end
  end
end
function BannerTriggers:OnAchievementChanged(achievementId, category, isUnlocked)
  if isUnlocked and category == "Recipe" then
    local recipeId = RecipeDataManagerBus.Broadcast.GetRecipeIdByAchievementId(achievementId)
    local recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeDataById(recipeId)
    local isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(recipeId)
    local itemData, displayName
    if isProcedural then
      local resultItemId = CraftingRequestBus.Broadcast.GetProceduralCraftingResult(recipeId, vector_Crc32())
      itemData = ItemDataManagerBus.Broadcast.GetItemData(resultItemId)
      displayName = recipeData.name
    else
      itemData = ItemDataManagerBus.Broadcast.GetItemData(Math.CreateCrc32(recipeData.resultItemId))
      displayName = itemData.displayName
    end
    local itemIcon = string.format(self.ITEM_ICON_PATH, itemData.itemType, itemData.icon)
    local bannerData = {
      AchievementCard1 = {
        title = "@new_recipe_unlocked",
        subject = displayName,
        icon = itemIcon,
        iconScale = 2,
        iconColor = UIStyle.COLOR_WHITE,
        shouldPlayGlow = true
      }
    }
    local bannerDisplayTime = 5
    local priority = 3
    self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, bannerDisplayTime, nil, nil, false, priority)
  end
end
function BannerTriggers:QueueTradeskillCelebration(skillData, milestones, newLevel)
  if 0 < #milestones then
    local bannerQueue = self.banners:GetBannerQueue(layouts.LAYOUT_LEVEL_UP_BANNER)
    local existingBannerData = self.queuedTradeskillBanners[skillData.name]
    if existingBannerData and (not bannerQueue.current or bannerQueue.current.uuid ~= existingBannerData.uuid) and 0 < #bannerQueue.queue then
      for i = 1, #existingBannerData.milestones do
        local milestone = {
          name = existingBannerData.milestones[i].name,
          icon = existingBannerData.milestones[i].icon
        }
        table.insert(milestones, milestone)
      end
      self.banners:RescindBanner(existingBannerData.uuid)
      self.queuedTradeskillBanners[skillData.name] = nil
    end
    local bannerData = {
      BannerLevelUp1 = {
        level = newLevel,
        play = true,
        displayName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(skillData.locName),
        tradeskill = true,
        milestoneData = milestones,
        iconPath = skillData.icon
      }
    }
    local priority = 4
    local duration = layouts.DEFAULT_DISPLAY_DURATION * 2
    self.queuedTradeskillBanners[skillData.name] = {
      uuid = self.banners:EnqueueBanner(layouts.LAYOUT_LEVEL_UP_BANNER, bannerData, duration, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP),
      milestones = milestones
    }
  end
end
function BannerTriggers:OnSiegeWarfareStarted(warId)
  if warId == nil then
    return
  end
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
  if warDetails:IsInvasion() then
    return
  end
  local guildIds = vector_GuildId()
  guildIds:push_back(warDetails:GetAttackerGuildId())
  guildIds:push_back(warDetails:GetDefenderGuildId())
  local function successCallback(self, results)
    local attackingGuildData, defendingGuildData
    for i = 1, #results do
      if results[i].guildId == warDetails:GetAttackerGuildId() then
        attackingGuildData = results[i]
      elseif results[i].guildId == warDetails:GetDefenderGuildId() then
        defendingGuildData = results[i]
      end
    end
    local defendingGuildCrest = defendingGuildData.crestData
    local attackingGuildCrest = attackingGuildData.crestData
    local attackingRaidId = warDetails:GetAttackerRaidId()
    local isAttacking = self.raidId == attackingRaidId
    local warCalendar = warDetails:GetRemainingWarSchedule()
    local phaseEndTime = warCalendar[1]:GetPhaseEndTime()
    local bannerColor = 1
    local warTitleText
    if isAttacking then
      warTitleText = "@ui_siege_phase_capture_points_attacker"
      bannerColor = 2
    else
      warTitleText = "@ui_siege_phase_capture_points_defender"
      bannerColor = 3
    end
    self.WAR_BANNER_DISPLAY_DURATION = layouts.WAR_BANNER_DISPLAY_DURATION
    self.audioHelper:PlaySound(self.audioHelper.Banner_WarPhase_Conquest)
    local bannerData = {
      WarCard1 = {
        warTitleText = warTitleText,
        phaseEndTime = phaseEndTime,
        isAttacking = isAttacking,
        bannerColor = bannerColor,
        isInvasion = false,
        isSiegeState = true,
        defendingGuildCrest = defendingGuildCrest,
        attackingGuildCrest = attackingGuildCrest
      }
    }
    local priority = 3
    self.banners:EnqueueBanner(layouts.LAYOUT_WAR_CARD, bannerData, self.WAR_BANNER_DISPLAY_DURATION, nil, nil, false, priority, self.WAR_BANNER_DRAW_ORDER)
  end
  local failureCallback = function(reason)
    if reason == eSocialRequestFailureReasonThrottled then
      Log("ERR - BannerTriggers:RequestGetGuilds: Throttled")
    elseif reason == eSocialRequestFailureReasonTimeout then
      Log("ERR - BannerTriggers:RequestGetGuilds: Timed Out")
    end
  end
  self.socialDataHandler:RequestGetGuilds_ServerCall(self, successCallback, failureCallback, guildIds)
end
function BannerTriggers:OnTerritoryActiveProjectChanged(claimKey, projectData, projectState)
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    return
  end
  local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(claimKey)
  local isInTerritory = claimKey == self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  local isInGuild = ownerData.guildId == self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  if isInTerritory or isInGuild then
    local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(claimKey)
    if projectState == eSettlementProgressionState_Active then
      if isInTerritory then
        local stationUpgrades = {}
        self:OnTownStructureChanged(territoryName, projectData, stationUpgrades, UIStyle.COLOR_GREEN_LIGHT, UIStyle.COLOR_GREEN, "@ui_town_project_started")
      end
      local chatMessage = BaseGameChatMessage()
      chatMessage.type = eChatMessageType_System
      chatMessage.body = GetLocalizedReplacementText("@ui_town_project_started_chat", {
        name = projectData.chatNotificationTitle,
        territory = territoryName
      })
      ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    elseif projectState == eSettlementProgressionState_Blocking then
      if isInTerritory then
        local stationUpgrades = {}
        self:OnTownStructureChanged(territoryName, projectData, stationUpgrades, UIStyle.COLOR_YELLOW_GOLD, UIStyle.COLOR_YELLOW_GOLD, "@ui_town_project_completed")
      else
        local notificationData = NotificationData()
        notificationData.title = "@ui_town_project_completed"
        notificationData.text = projectData.title
        notificationData.icon = projectData.icon
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
      local chatMessage = BaseGameChatMessage()
      chatMessage.type = eChatMessageType_System
      chatMessage.body = GetLocalizedReplacementText("@ui_town_project_completed_chat", {
        title = projectData.chatNotificationTitle,
        territory = territoryName
      })
      ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    elseif projectState == eSettlementProgressionState_Completed then
      if isInTerritory then
        local stationUpgrades = {}
        self:OnTownStructureChanged(territoryName, projectData, stationUpgrades, UIStyle.COLOR_YELLOW_GOLD, UIStyle.COLOR_YELLOW_GOLD, "@ui_town_project_completed")
      else
        local notificationData = NotificationData()
        notificationData.title = "@ui_town_project_completed"
        notificationData.text = projectData.title
        notificationData.icon = projectData.icon
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
      local chatMessage = BaseGameChatMessage()
      chatMessage.type = eChatMessageType_System
      chatMessage.body = GetLocalizedReplacementText("@ui_town_project_completed_chat", {
        title = projectData.chatNotificationTitle,
        territory = territoryName
      })
      ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    elseif projectState == eSettlementProgressionState_Cancelled then
      local notificationData = NotificationData()
      notificationData.title = "@ui_town_project_cancelled"
      notificationData.text = GetLocalizedReplacementText("@ui_territory_upgrade_cancelled", {territoryName = territoryName})
      notificationData.icon = projectData.icon
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      local chatMessage = BaseGameChatMessage()
      chatMessage.type = eChatMessageType_System
      chatMessage.body = GetLocalizedReplacementText("@ui_town_project_cancelled_chat", {
        title = projectData.chatNotificationTitle,
        territory = territoryName
      })
      ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    end
  end
end
function BannerTriggers:OnClaimOwnerChanged(claimId, newOwnerData, oldOwnerData)
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    return
  end
  local playerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local newOwnerGuildValid = newOwnerData.guildId and newOwnerData.guildId:IsValid()
  local oldOwnerGuildValid = oldOwnerData.guildId and oldOwnerData.guildId:IsValid()
  local claimDestroyed = not newOwnerGuildValid
  local unownedToOwned = not oldOwnerGuildValid and newOwnerGuildValid
  if unownedToOwned then
    local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(claimId)
    local claimedByText = GetLocalizedReplacementText("@ui_territory_claimed", {
      guildName = newOwnerData.guildName,
      territoryName = territoryName
    })
    local bannerData = {
      TerritoryClaimedCard1 = {
        claimedByText = claimedByText,
        guildName = newOwnerData.guildName,
        guildCrestData = newOwnerData.guildCrestData
      }
    }
    local bannerDisplayTime = 5
    local priority = 4
    self.banners:EnqueueBanner(layouts.LAYOUT_TERRITORY_CLAIMED, bannerData, bannerDisplayTime, nil, nil, false, priority, self.TERRITORY_CLAIMED_BANNER_DRAW_ORDER)
    self.audioHelper:PlaySound(self.audioHelper.LandClaim_Claimed)
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_LandClaim_Claimed)
  end
  if claimDestroyed and playerGuildId == oldOwnerData.guildId then
    self.audioHelper:PlaySound(self.audioHelper.LandClaim_Destroyed)
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_LandClaim_Destroyed)
  end
end
function BannerTriggers:UpdateDiscoveredPOI(poiData)
  if poiData.id == "" then
    return
  end
  if poiData.isCharted then
    if poiData.isArea then
      return
    end
    if poiData:HasPoiTag(597936596) then
      local landmarkData = MapComponentBus.Broadcast.GetFirstLandmarkByType(poiData.id, eTerritoryLandmarkType_FishingHotspot)
      local level = FishingRequestsBus.Event.GetRequiredLevelByHotspotId(self.playerEntityId, Math.CreateCrc32(landmarkData.landmarkData))
      if level > CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, 1975517117) then
        return
      end
    end
    local difficultyData = {}
    local poiLevel = MapComponentBus.Broadcast.GetMedianPoiLevel(poiData.id)
    if poiLevel ~= 0 then
      table.insert(difficultyData, {
        text = GetLocalizedReplacementText("@objective_recommendedlevel", {
          level = tostring(poiLevel)
        }),
        minLevel = poiLevel
      })
    end
    if poiData.groupSize ~= 0 then
      local minGroup, maxGroup = EncounterDataHandler:GetGroupRange(poiData)
      local groupText = tostring(minGroup) .. " - " .. tostring(maxGroup)
      if minGroup == maxGroup then
        groupText = tostring(maxGroup)
      end
      if maxGroup <= 1 then
        groupText = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_solo")
      end
      table.insert(difficultyData, {
        text = GetLocalizedReplacementText("@objective_recommendedgroup", {group = groupText}),
        minGroupSize = minGroup
      })
    end
    local subjectText = "@ui_poi_charted"
    local titleText = poiData.nameLocalizationKey
    local bannerQueue = self.banners:GetBannerQueue(layouts.LAYOUT_ACHIEVEMENT)
    if self.mDiscoveryBannerId and (not bannerQueue.current or bannerQueue.current.uuid ~= self.mDiscoveryBannerId) and 0 < #bannerQueue.queue then
      self.banners:RescindBanner(self.mDiscoveryBannerId)
      self.mDiscoveryBannerId = nil
    end
    local bannerData = {
      AchievementCard1 = {
        title = titleText,
        subject = subjectText,
        icon = poiData.mapIconPath,
        iconScale = 2,
        iconColor = UIStyle.COLOR_WHITE,
        shouldPlayGlow = true,
        difficultyData = difficultyData
      }
    }
    local bannerDisplayTime = 5
    local priority = 3
    self.mDiscoveryBannerId = self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, bannerDisplayTime, nil, nil, false, priority)
  end
end
function BannerTriggers:OnLeavingPoiObjective(gracePeriodOverTime)
  if self.leavingPoiNotification then
    UiNotificationsBus.Broadcast.RescindNotification(self.leavingPoiNotification, true, true)
  end
  TimingUtils:StopDelay(self, self.PlayDarknessAbandonMusic)
  local secondsTillLeaving = math.max(gracePeriodOverTime:Subtract(TimePoint:Now()):ToSeconds(), 1)
  local notificationData = NotificationData()
  notificationData.title = "@ui_leaving_event_area"
  notificationData.text = "@ui_leaving_event_area_description"
  notificationData.maximumDuration = secondsTillLeaving
  notificationData.showProgress = true
  self.leavingPoiNotification = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  if not self.activeEncounterObjectiveData then
    return
  end
  self.objectiveTypeOnAbandonPoi = self.activeEncounterObjectiveData.type
  TimingUtils:Delay(secondsTillLeaving, self, self.PlayDarknessAbandonMusic)
end
function BannerTriggers:PlayDarknessAbandonMusic()
  if self.objectiveTypeOnAbandonPoi == eObjectiveType_Darkness_Minor or self.objectiveTypeOnAbandonPoi == eObjectiveType_Darkness_Major then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Darkness, self.audioHelper.MusicState_Darkness_Abandoned)
  elseif self.objectiveTypeOnAbandonPoi == eObjectiveType_Arena then
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Arena, self.audioHelper.MusicState_Arena_Completed)
  end
end
function BannerTriggers:OnReturningToPoiObjective()
  if self.leavingPoiNotification then
    UiNotificationsBus.Broadcast.RescindNotification(self.leavingPoiNotification, true, true)
    self.leavingPoiNotification = nil
  end
  TimingUtils:StopDelay(self, self.PlayDarknessAbandonMusic)
end
function BannerTriggers:OnObjectiveAdded(objectiveId)
  if LoadScreenBus.Broadcast.IsLoadingScreenShown() then
    return
  end
  local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveId)
  if objectiveType == eObjectiveType_Crafting or objectiveType == eObjectiveType_Quest or objectiveType == eObjectiveType_Journey or objectiveType == eObjectiveType_Darkness_Minor or objectiveType == eObjectiveType_DynamicPOI or objectiveType == eObjectiveType_Darkness_Major or objectiveType == eObjectiveType_Invasion or objectiveType == eObjectiveType_Arena or objectiveType == eObjectiveType_Dungeon then
    return
  end
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  if currentState == self.TOWN_PROJECTS_STATE and objectiveType == eObjectiveType_CommunityGoal then
    return
  end
  if currentState == self.OWMISSION_BOARD_STATE and objectiveType == eObjectiveType_Mission then
    return
  end
  local isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  local styleData = ObjectiveTypeData:GetType(objectiveType)
  local objectiveName = ObjectiveRequestBus.Event.GetTitle(objectiveId)
  local titleText = "@objective_started"
  local promptText = not isFtue and "@ui_openjournal" or nil
  local iconPath = styleData.iconPath
  local iconColor = styleData.iconColor
  local sound
  local difficultyData = {}
  if objectiveType == eObjectiveType_Mission then
    titleText = "@mission_accepted"
  end
  local bannerData = {
    AchievementCard1 = {
      bgColor = styleData.bgColor,
      title = objectiveName,
      titleColor = styleData.textColor,
      subject = titleText,
      prompt = promptText,
      promptAction = "toggleJournalComponent",
      icon = iconPath,
      iconColor = iconColor,
      sound = sound,
      difficultyData = difficultyData
    }
  }
  local bannerDisplayTime = 5
  local priority = 3
  self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, bannerDisplayTime, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
end
function BannerTriggers:OnTrackedObjectiveAdded(objectiveId)
  local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveId)
  local isEncounter = objectiveType == eObjectiveType_Darkness_Minor or objectiveType == eObjectiveType_Darkness_Major or objectiveType == eObjectiveType_Arena or objectiveType == eObjectiveType_Dungeon or objectiveType == eObjectiveType_DefendObject
  local isDarkness = objectiveType == eObjectiveType_Darkness_Minor or objectiveType == eObjectiveType_Darkness_Major
  if not isEncounter then
    return
  end
  local objectiveName = ObjectiveRequestBus.Event.GetTitle(objectiveId)
  local styleData = ObjectiveTypeData:GetType(objectiveType)
  if objectiveType == eObjectiveType_Dungeon then
    local gameModeId = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(self.rootPlayerId)
    local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.rootPlayerId, gameModeId)
    local subjectText = ""
    local rewards, additionalTextData
    if #gameModeData.possibleItemDropIds > 0 then
      rewards = gameModeData.possibleItemDropIds
      subjectText = "@ui_available_rewards"
    end
    local bannerData = {
      AchievementCard1 = {
        title = objectiveName,
        titleColor = styleData.textColor,
        subject = subjectText,
        additionalTextData = additionalTextData,
        rewards = rewards,
        sound = self.audioHelper.Banner_ArenaStarted
      }
    }
    local bannerDisplayTime = 5
    local priority = 3
    self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, bannerDisplayTime, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
    return
  end
  local objectiveEntityId = ObjectiveRequestBus.Event.GetOwningEntityId(objectiveId)
  local objectiveDefinition = ObjectiveDataHelper:GetDefinitionFromExternalObjective(objectiveId)
  local spawnerTag = SpawnerRequestBus.Event.GetSpawnerTag(objectiveEntityId)
  if not objectiveDefinition then
    Debug.Log("BannerTriggers:OnObjectiveAdded attempted to display banner without an available objectiveDefinition (" .. tostring(objectiveId) .. ")")
    return
  end
  local titleText = "@objective_started"
  local iconPath = styleData.iconPath
  local iconColor = styleData.iconColor
  local sound
  local difficultyData = {}
  if objectiveDefinition.groupSize ~= 0 then
    local minGroup, maxGroup = EncounterDataHandler:GetGroupRange(objectiveDefinition)
    local groupText = tostring(minGroup) .. " - " .. tostring(maxGroup)
    if minGroup == maxGroup then
      groupText = tostring(maxGroup)
    end
    if maxGroup <= 1 then
      groupText = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_solo")
    end
    table.insert(difficultyData, {
      text = GetLocalizedReplacementText("@objective_recommendedgroup", {group = groupText}),
      minGroupSize = minGroup
    })
  end
  local minLevel = objectiveDefinition.recommendedLevel
  if not minLevel or minLevel == 0 then
    minLevel = EncounterDataHandler:GetLevel(spawnerTag)
  end
  table.insert(difficultyData, {
    text = GetLocalizedReplacementText("@objective_recommendedlevel", {
      level = tostring(minLevel)
    }),
    minLevel = minLevel
  })
  if objectiveType == eObjectiveType_Darkness_Minor then
    local itemDescriptor = ItemDescriptor()
    itemDescriptor.itemId = EncounterDataHandler:GetRequiredItem(spawnerTag)
    local tier = StaticItemDataManager:GetItem(itemDescriptor.itemId).tier
    local hasAzothStaff = 0 < inventoryCommon:GetInventoryItemCount(itemDescriptor)
    titleText = "@incursion_started_minor"
    sound = self.audioHelper.Banner_DarknessStarted
    table.insert(difficultyData, {
      text = GetLocalizedReplacementText("@objective_requiresitem", {
        itemName = itemDescriptor:GetDisplayName(),
        tier = tier
      }),
      isMet = hasAzothStaff
    })
  elseif objectiveType == eObjectiveType_Darkness_Major then
    local itemDescriptor = ItemDescriptor()
    itemDescriptor.itemId = EncounterDataHandler:GetRequiredItem(spawnerTag)
    local tier = StaticItemDataManager:GetItem(itemDescriptor.itemId).tier
    local hasAzothStaff = 0 < inventoryCommon:GetInventoryItemCount(itemDescriptor)
    titleText = "@incursion_started_major"
    sound = self.audioHelper.Banner_DarknessStarted
    table.insert(difficultyData, {
      text = GetLocalizedReplacementText("@objective_requiresitem", {
        itemName = itemDescriptor:GetDisplayName(),
        tier = tier
      }),
      isMet = hasAzothStaff
    })
    for i = 1, #difficultyData do
      if difficultyData[i].isMet == false then
        iconPath = string.gsub(iconPath, "%.png$", "_danger.png")
        iconColor = UIStyle.COLOR_RED
        break
      end
    end
  elseif objectiveType == eObjectiveType_Arena then
    titleText = "@arena_started"
    sound = self.audioHelper.Banner_ArenaStarted
    iconColor = UIStyle.COLOR_GREEN_LIGHT
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Arena, self.audioHelper.MusicState_Arena_Countdown)
  end
  self.activeEncounterObjectiveData = {title = objectiveName, type = objectiveType}
  local bannerData = {
    AchievementCard1 = {
      darkness = isDarkness,
      bgColor = styleData.bgColor,
      title = objectiveName,
      titleColor = styleData.textColor,
      subject = titleText,
      promptAction = "toggleJournalComponent",
      icon = iconPath,
      iconColor = iconColor,
      sound = sound,
      difficultyData = difficultyData
    }
  }
  local bannerDisplayTime = 5
  local priority = 3
  self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, bannerDisplayTime, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
end
function BannerTriggers:OnObjectiveCompleted(objectiveId, objectiveCrcId, objCreation)
  local objectiveData, objectiveType
  if objectiveCrcId then
    objectiveData = ObjectivesDataManagerBus.Broadcast.GetObjectiveData(objectiveCrcId)
    objectiveType = objectiveData.type
  elseif objectiveId then
    objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(objectiveId)
    objectiveType = objectiveData.type
  elseif objCreation.isDynamicPoiObjective then
    objectiveType = eObjectiveType_DynamicPOI
  else
    return
  end
  if objectiveType == eObjectiveType_Crafting or objectiveType == eObjectiveType_Quest or objectiveType == eObjectiveType_Journey or objectiveType == eObjectiveType_MainStoryQuest then
    return
  end
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  if currentState == self.TOWN_PROJECTS_STATE and objectiveType == eObjectiveType_CommunityGoal then
    return
  end
  if currentState == self.OWMISSION_BOARD_STATE and objectiveType == eObjectiveType_Mission then
    return
  end
  local styleData = ObjectiveTypeData:GetType(objectiveType)
  local titleColor = UIStyle.COLOR_GREEN_LIGHT
  local iconColor = UIStyle.COLOR_GREEN
  local titleText = "@objective_completed"
  local objectiveName = objectiveData.title
  if objCreation.isDynamicPoiObjective then
    objectiveName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(objCreation.originTerritoryId)
    titleText = "@dynamic_poi_objective_completed"
  end
  local sound
  if objectiveType == eObjectiveType_Mission then
    titleText = "@mission_completed"
  elseif objectiveType == eObjectiveType_Darkness_Minor or objectiveType == eObjectiveType_Darkness_Major or objectiveType == eObjectiveType_Arena then
    return
  end
  local bannerData = {
    AchievementCard1 = {
      bgColor = styleData.bgColor,
      title = titleText,
      titleColor = titleColor,
      subject = objectiveName,
      icon = styleData.iconPath,
      iconColor = iconColor,
      shouldPlayGlow = true,
      scratchOutSubject = true,
      sound = sound
    }
  }
  local priority = 3
  self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, 5, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
end
if BannerTriggers.DEBUG_OBJECTIVE_COMPLETED then
  function BannerTriggers:OnTrackedObjectiveRemoved(objectiveId)
    ObjectiveDataHelper:DebugLogObjective(objectiveId)
    self:OnObjectiveCompleted(objectiveId)
  end
  function BannerTriggers:OnTrackedObjectiveAdded(objectiveId)
    self:OnObjectiveAdded(objectiveId)
  end
end
function BannerTriggers:OnTaskBannerTriggerActivated(bannerTitle, bannerDescription, parentObjectiveId)
  local objectiveType = ObjectiveRequestBus.Event.GetType(parentObjectiveId)
  if objectiveType == eObjectiveType_Invasion then
    local bannerData = {
      WarCard1 = {
        warTitleText = bannerTitle,
        warGuildsText = "",
        warDurationText = "",
        warMessageText = "",
        warDetailText = bannerDescription,
        isSingleCrest = true,
        bannerColor = 1,
        isInvasion = true
      }
    }
    local priority = 3
    self.banners:EnqueueBanner(layouts.LAYOUT_WAR_CARD, bannerData, self.WAR_BANNER_DISPLAY_DURATION, nil, nil, false, priority, self.WAR_BANNER_DRAW_ORDER)
  else
    local bannerData = {
      TextCard1 = {title = bannerTitle, titleLabel = bannerDescription}
    }
    local priority = 4
    self.banners:EnqueueBanner(layouts.LAYOUT_TEXT_CARD, bannerData, layouts.DEFAULT_DISPLAY_DURATION, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
  end
end
function BannerTriggers:OnTypedUiGameEvent(gameEventType, progressionReward, currencyReward, itemReward, categoricalProgressionId, categoricalProgressionReward, territoryStandingReward, factionRepReward, factionTokensReward, azothReward)
  if gameEventType == eGameEventType_Darkness or gameEventType == eGameEventType_Arena then
    if not self.activeEncounterObjectiveData then
      return
    end
    local styleData = ObjectiveTypeData:GetType(self.activeEncounterObjectiveData.type)
    local titleText
    if self.activeEncounterObjectiveData.type == eObjectiveType_Darkness_Minor then
      titleText = "@incursion_completed_minor"
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Darkness, self.audioHelper.MusicState_Darkness_Completed)
    elseif self.activeEncounterObjectiveData.type == eObjectiveType_Darkness_Major then
      titleText = "@incursion_completed_major"
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Darkness, self.audioHelper.MusicState_Darkness_Completed)
    elseif self.activeEncounterObjectiveData.type == eObjectiveType_Arena then
      titleText = "@arena_completed"
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Arena, self.audioHelper.MusicState_Arena_Completed)
    end
    local bannerData = {
      AchievementCard1 = {
        bgColor = styleData.bgColor,
        title = titleText,
        titleColor = styleData.textColor,
        subject = self.activeEncounterObjectiveData.title,
        icon = styleData.iconPath,
        iconColor = styleData.iconColor,
        shouldPlayGlow = true,
        scratchOutSubject = true,
        sound = self.audioHelper.Banner_DarknessCompleted
      }
    }
    local priority = 3
    self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, 5, nil, nil, false, priority)
    self.activeEncounterObjectiveData = nil
  end
end
function BannerTriggers:OnObjectiveFailed(objectiveInstanceId, objectiveId, missionId)
  local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveInstanceId)
  if objectiveType == eObjectiveType_Crafting or objectiveType == eObjectiveType_DynamicPOI or FtueSystemRequestBus.Broadcast.IsFtue() then
    return
  end
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  if currentState == self.TOWN_PROJECTS_STATE and objectiveType == eObjectiveType_CommunityGoal then
    return
  end
  if currentState == self.OWMISSION_BOARD_STATE and objectiveType == eObjectiveType_Mission then
    return
  end
  local objectiveData = ObjectiveRequestBus.Event.GetObjectiveData(objectiveInstanceId)
  if objectiveData.flagPvp then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_pvp_missions_failed"
    notificationData.allowDuplicates = false
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  local missionParams = ObjectiveRequestBus.Event.GetCreationParams(objectiveInstanceId)
  local objectiveName, _ = ObjectivesDataHandler:GetMissionTitleAndDescription(missionParams, objectiveInstanceId)
  local titleText = "@objective_failed"
  if objectiveType == eObjectiveType_Mission then
    titleText = "@mission_failed"
  end
  local bannerData = {
    AchievementCard1 = {
      title = titleText,
      titleColor = UIStyle.COLOR_RED,
      subject = objectiveName,
      icon = "lyshineui/images/icons/objectives/icon_objectives.png",
      iconColor = UIStyle.COLOR_GRAY_80
    }
  }
  local bannerDisplayTime = 5
  local priority = 3
  self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, bannerDisplayTime, nil, nil, false, priority)
end
function BannerTriggers:GetNearestNamedTerritory(vec3Pos)
  if not vec3Pos then
    Log("BannerTriggers:GetNearestNamedTerritory(): vec3Pos is invalid, returning nil")
    return nil
  end
  return MapComponentBus.Broadcast.GetNearestNamedTerritory(Vector2(vec3Pos.x, vec3Pos.y))
end
function BannerTriggers:GetBiomeAtPosition(vec3Pos)
  if not vec3Pos then
    Log("BannerTriggers:GetBiomeAtPosition(): vec3Pos is invalid, returning empty string")
    return ""
  end
  local pos = Vector2(vec3Pos.x, vec3Pos.y)
  return MapComponentBus.Broadcast.GetTractAtPosition(pos)
end
function BannerTriggers:AnimateIn(bannerEntityId, layoutName, callback)
  for i = 1, #self.layoutsWithCustomAnimateIn do
    if layoutName == self.layoutsWithCustomAnimateIn[i] then
      self.banners:TransitionRow(self.banners:GetRow(self.layoutsWithCustomAnimateIn[i], 1), true)
      self.ScriptedEntityTweener:Set(bannerEntityId, {opacity = 0})
      local duration = 0.2
      local fadeValue = UiFaderBus.Event.GetFadeValue(bannerEntityId)
      duration = (1 - fadeValue) * duration
      self.ScriptedEntityTweener:StartAnimation({
        id = bannerEntityId,
        duration = duration,
        opacity = 1,
        onComplete = callback
      })
      return true
    end
  end
  return false
end
function BannerTriggers:AnimateOut(bannerEntityId, layoutName, callback)
  for i = 1, #self.layoutsWithCustomAnimateOut do
    if layoutName == self.layoutsWithCustomAnimateOut[i] then
      self.banners:TransitionRow(self.banners:GetRow(self.layoutsWithCustomAnimateOut[i], 1), false, callback)
      if not FtueSystemRequestBus.Broadcast.IsFtue() or layoutName == layouts.LAYOUT_ACHIEVEMENT then
        if self.layoutsWithCustomAnimateOutCallback[layoutName] then
          callback = nil
        end
        local duration = 1
        local fadeValue = UiFaderBus.Event.GetFadeValue(bannerEntityId)
        duration = fadeValue * duration
        self.ScriptedEntityTweener:StartAnimation({
          id = bannerEntityId,
          duration = duration,
          opacity = 0,
          onComplete = callback
        })
      end
      return true
    end
  end
  return false
end
function BannerTriggers:DoesContainMilestone(milestonesTable, name, icon)
  local localizedName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(name)
  for _, entry in pairs(milestonesTable) do
    local localizedEntryName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(entry.name)
    if localizedEntryName == localizedName and entry.icon == icon then
      return true
    end
  end
  return false
end
function BannerTriggers:OnCategoricalProgressionRankChanged(progressionId, oldRank, newRank, oldPoints, isInitialReplication)
  if isInitialReplication and FtueSystemRequestBus.Broadcast.IsFtue() == false then
    return
  end
  local progressionData = CategoricalProgressionRequestBus.Event.GetCategoricalProgressionData(self.playerEntityId, progressionId)
  if progressionData.rankTableId == "WeaponMastery" then
    local weaponMasteryData = WeaponMasteryData:GetByTableNameId(progressionId)
    local bannerData = {
      BannerLevelUp1 = {
        level = newRank + 1,
        play = true,
        weaponMastery = true,
        displayName = weaponMasteryData.text,
        iconPath = weaponMasteryData.icon
      }
    }
    local priority = 4
    self.banners:EnqueueBanner(layouts.LAYOUT_LEVEL_UP_BANNER, bannerData, layouts.DEFAULT_DISPLAY_DURATION, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Skills.ScreenChecked", false)
  elseif TradeSkillsCommon:IsGatheringSkill(progressionId) then
    local milestones = {}
    local skillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(progressionId)
    for i = oldRank + 1, newRank do
      local tradeskillLockedGatherableData = CategoricalProgressionRequestBus.Event.GetTradeskillLockedGatherableData(self.playerEntityId, skillData.name, i)
      for i = 1, #tradeskillLockedGatherableData do
        local gatherData = tradeskillLockedGatherableData[i]
        if gatherData.iconTypeUnlock and gatherData.iconTypeUnlock ~= "" then
          local icon = string.format(self.TRADESKILL_ICON_PATH, gatherData.iconTypeUnlock)
          if not self:DoesContainMilestone(milestones, gatherData.displayName, icon) then
            local milestone = {
              name = gatherData.displayName,
              icon = icon
            }
            table.insert(milestones, milestone)
          end
        end
      end
      local rankData = CategoricalProgressionRequestBus.Event.GetStaticTradeskillRankData(self.playerEntityId, progressionId, i)
      if rankData and rankData:IsValid() and rankData.iconTypeUnlock and rankData.iconTypeUnlock ~= "" then
        local icon = string.format(self.TRADESKILL_ICON_PATH, rankData.iconTypeUnlock)
        if not self:DoesContainMilestone(milestones, rankData.displayName, icon) then
          local title = GetLocalizedReplacementText("@ui_now_track_banner", {
            resourceName = rankData.displayName
          })
          local milestone = {name = title, icon = icon}
          table.insert(milestones, milestone)
        end
      end
    end
    self:QueueTradeskillCelebration(skillData, milestones, newRank)
  elseif TradeSkillsCommon:IsCraftingSkill(progressionId) then
    local milestones = {}
    local skillData = TradeSkillsCommon:GetTradeSkillDataFromTableId(progressionId)
    for i = oldRank + 1, newRank do
      local recipeIds = RecipeDataManagerBus.Broadcast.GetCraftingRecipesForTradeskillLevel(skillData.name, i)
      for i = 1, #recipeIds do
        local recipeData = RecipeDataManagerBus.Broadcast.GetCraftingRecipeData(recipeIds[i])
        if recipeData.knownByDefault and recipeData.listedByDefault then
          local isProcedural = RecipeDataManagerBus.Broadcast.IsRecipeProcedural(recipeData.id)
          local resultItemId
          if isProcedural then
            resultItemId = CraftingRequestBus.Broadcast.GetProceduralCraftingResult(recipeData.id, vector_Crc32())
          else
            resultItemId = Math.CreateCrc32(recipeData.resultItemId)
          end
          local itemData = ItemDataManagerBus.Broadcast.GetItemData(resultItemId)
          local itemIcon = string.format(self.ITEM_ICON_PATH, itemData.itemType, itemData.icon)
          local milestone = {
            name = itemData.displayName,
            icon = itemIcon
          }
          table.insert(milestones, milestone)
        end
      end
    end
    self:QueueTradeskillCelebration(skillData, milestones, newRank)
  else
    if not self.claimKeys or #self.claimKeys == 0 then
      local rawClaimKeys = LandClaimRequestBus.Broadcast.GetClaimKeys()
      self.claimKeys = {}
      for i = 1, #rawClaimKeys do
        local rawClaimKey = rawClaimKeys[i]
        table.insert(self.claimKeys, {
          originalKey = rawClaimKey,
          crcKey = Math.CreateCrc32(tostring(rawClaimKey))
        })
      end
    end
    for i = 1, #self.claimKeys do
      local keyData = self.claimKeys[i]
      if progressionId == keyData.crcKey then
        local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(keyData.originalKey)
        local territoryName = posData.territoryName
        local rankData = CategoricalProgressionRequestBus.Event.GetRankData(self.playerEntityId, keyData.crcKey, newRank)
        local bannerData = {
          BannerTerritoryLevelUp1 = {
            level = newRank,
            territoryName = territoryName,
            rankName = rankData.displayName,
            play = true
          }
        }
        local priority = 4
        self.banners:EnqueueBanner(layouts.LAYOUT_TERRITORY_LEVEL_UP_BANNER, bannerData, layouts.DEFAULT_DISPLAY_DURATION, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
        LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Map.ScreenChecked", false)
        break
      end
    end
  end
end
function BannerTriggers:OnTownStructureChanged(territoryName, progressionData, benefits, primaryColor, secondaryColor, projectStatus)
  local bannerData = {
    TownStructureChanged1 = {
      territoryName = territoryName,
      title = progressionData.title,
      description = progressionData.description,
      imagePath = progressionData.image,
      benefits = benefits,
      play = true,
      primaryColor = primaryColor,
      secondaryColor = secondaryColor,
      projectStatus = projectStatus
    }
  }
  local priority = 4
  self.banners:EnqueueBanner(layouts.LAYOUT_TOWN_STRUCTURE_CHANGED, bannerData, 6, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
end
function BannerTriggers:OnTerritoryProgressionChanged(key, category, prevLevel, level, projectId)
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    return
  end
  if level < prevLevel then
    local projectData = TerritoryDataHandler:GetTerritoryProjectDataFromProjectId(projectId)
    local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(key)
    local bannerData = {
      TextCard1 = {
        title = GetLocalizedReplacementText("@ui_territory_downgraded_banner", {
          structure = projectData.projectCategoryName,
          territoryName = territoryName
        }),
        sound = self.audioHelper.Banner_TerritoryDowngrade,
        musicSwitch = self.audioHelper.MusicSwitch_Gameplay,
        musicState = self.audioHelper.MusicState_Territory_Downgraded
      }
    }
    local priority = 4
    self.banners:EnqueueBanner(layouts.LAYOUT_TEXT_CARD, bannerData, layouts.DEFAULT_DISPLAY_DURATION, nil, nil, false, priority, self.BANNER_DRAW_ORDER_TOP)
    local chatMessage = BaseGameChatMessage()
    chatMessage.type = eChatMessageType_System
    chatMessage.body = GetLocalizedReplacementText("@ui_territory_downgraded_chat", {
      structure = projectData.projectCategoryName,
      territoryName = territoryName
    })
    ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
  end
end
function BannerTriggers:OnTerritoryConflictFactionChanged(key, factionType)
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    return
  end
  if not self.initialConflictFactions then
    self.initialConflictFactions = {}
  end
  if self.initialConflictFactions[key] ~= nil and self.initialConflictFactions[key] ~= factionType and factionType ~= eFactionType_None then
    local factionData = FactionCommon.factionInfoTable[factionType]
    local factionName = ""
    if factionData then
      factionName = factionData.factionName
    end
    local locText = GetLocalizedReplacementText("@owg_influence_conflict_notification_desc", {
      territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(key),
      faction = factionName
    })
    local notificationData = NotificationData()
    notificationData.type = "Social"
    notificationData.icon = "LyShineUI/Images/Icons/Misc/icon_warUncolored.dds"
    notificationData.title = "@owg_influence_conflict_notification_title"
    notificationData.text = locText
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    local chatMessage = BaseGameChatMessage()
    chatMessage.type = eChatMessageType_System
    chatMessage.body = locText
    ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
  end
  self.initialConflictFactions[key] = factionType
end
function BannerTriggers:OnTerritoryConflictLotteryEndTimeChanged(key, endTime)
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    return
  end
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  if not now then
    return
  end
  local timeUntilLotteryEnd = endTime:Subtract(now):ToSecondsRoundedUp()
  local notificationTolerance = 60
  if timeUntilLotteryEnd > notificationTolerance then
    local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(key)
    local factionType = self.initialConflictFactions[key]
    local factionData = FactionCommon.factionInfoTable[factionType]
    local factionName = ""
    if factionData then
      factionName = factionData.factionName
    end
    if not factionName then
      return
    end
    local locText = GetLocalizedReplacementText("@owg_war_declared_lottery_active_desc", {
      territoryName = territoryName,
      faction = factionName,
      time = timeHelpers:ConvertToShorthandString(timeUntilLotteryEnd)
    })
    local notificationData = NotificationData()
    notificationData.type = "Social"
    notificationData.icon = "LyShineUI/Images/Icons/Misc/icon_warUncolored.dds"
    notificationData.title = GetLocalizedReplacementText("@owg_war_declared_lottery_active", {territoryName = territoryName})
    notificationData.text = locText
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    local chatMessage = BaseGameChatMessage()
    chatMessage.type = eChatMessageType_System
    chatMessage.body = locText
    ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
  end
end
function BannerTriggers:OnUiTriggerAreaEventEntered(enteringEntityId, triggerEntityId, eventId, identifier)
  if LoadScreenBus.Broadcast.IsLoadingScreenShown() then
    return
  end
  local cardType, additionalData
  if eventId == 3718191953 then
    cardType = TerritoryEnteredCardTypes.SettlementType
    local claimKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.EnteredSettlementId", claimKey)
    self.enteredSettlementTime = WallClockTimePoint:Now()
  elseif eventId == 114609139 then
    cardType = TerritoryEnteredCardTypes.FortType
  else
    local locationBannerData = RequireScript("LyShineUI._Common.LocationBannerData")
    local hqBuildingData = locationBannerData.hqBuildingData
    additionalData = hqBuildingData[eventId]
    if additionalData then
      cardType = TerritoryEnteredCardTypes.HQType
      additionalData.eventId = eventId
    else
      local locKey = "@" .. identifier
      local localizedEvent = LyShineScriptBindRequestBus.Broadcast.LocalizeText(locKey)
      if localizedEvent and localizedEvent ~= locKey then
        cardType = TerritoryEnteredCardTypes.OpenWorld
        additionalData = {name = locKey, eventId = eventId}
      end
    end
  end
  if cardType then
    local claimKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    self:ShowTerritoryEnteredCard(claimKey, cardType, additionalData)
  end
end
function BannerTriggers:OnUiTriggerAreaEventExited(enteringEntityId, eventId)
  if LoadScreenBus.Broadcast.IsLoadingScreenShown() then
    return
  end
  if eventId == 3718191953 then
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.EnteredSettlementId", 0)
    TimingUtils:Delay(1, self, function(self)
      if LoadScreenBus.Broadcast.IsLoadingScreenShown() then
        return
      end
      if self.enteredSettlementTime and WallClockTimePoint:Now():Subtract(self.enteredSettlementTime):ToSeconds() < self.TOWN_CHECKIN_THRESHOLD then
        return
      end
      local bannerTitle, bannerDescription
      local fastTravelCommon = RequireScript("LyShineUI._Common.FastTravelCommon")
      local currentInnTerritoryId = fastTravelCommon:GetCurrentlySetInnTerritoryId()
      local currentTerritoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
      local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(currentTerritoryId)
      local territoryName = territoryDefn.nameLocalizationKey
      local bannerIcon = "LyShineUI\\Images\\icons\\objectives\\npc_inn.dds"
      local showBanner = true
      local titleRefresh = false
      if currentInnTerritoryId == currentTerritoryId then
        local currentInnCooldownTime = fastTravelCommon:GetCurrentlySetInnCooldownTime()
        if currentInnCooldownTime <= 0 then
          showBanner = false
        else
          bannerDescription = "@ui_leaving_settlement_recall_time_desc"
          local timeBeforeRecall = timeHelpers:ConvertSecondsToHrsMinSecString(currentInnCooldownTime)
          bannerTitle = GetLocalizedReplacementText("@ui_leaving_settlement_recall_time", {time = timeBeforeRecall})
          titleRefresh = true
        end
      else
        local hasInnHomePoint = currentInnTerritoryId ~= 0
        bannerDescription = "@ui_leaving_settlement_no_inn_desc"
        bannerIcon = "LyShineUI\\Images\\icons\\objectives\\npc_inn_inactive.dds"
        bannerTitle = "@ui_leaving_settlement_no_inn"
      end
      if showBanner then
        local bannerData = {
          TextCard1 = {
            title = bannerTitle,
            titleLabel = bannerDescription,
            showLine = true,
            showBg = true,
            icon = bannerIcon,
            titleRefresh = titleRefresh,
            titleLocTag = "@ui_leaving_settlement_recall_time",
            titleWallClock = fastTravelCommon:GetCurrentlySetInnCooldownTime(true)
          }
        }
        self.banners:EnqueueBanner(layouts.LAYOUT_TEXT_CARD, bannerData, 5, nil, nil, false, 5)
      end
    end)
  end
end
function BannerTriggers:ShowTerritoryEnteredCard(claimKey, territoryEnteredCardType, additionalData)
  if self.isPlayerAtWar then
    return
  end
  local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(claimKey)
  if not posData then
    Debug.Log("BannerTriggers:ShowTerritoryEnteredCard attempted to show invalid claim position data with claimKey: " .. tostring(claimKey))
    return
  end
  local isClaimable = posData.territoryName ~= nil and posData.territoryName ~= ""
  local hasSecondPhase = territoryEnteredCardType == TerritoryEnteredCardTypes.TerritoryType and isClaimable or territoryEnteredCardType == TerritoryEnteredCardTypes.SettlementType
  local duration = hasSecondPhase and 9 or layouts.DEFAULT_DISPLAY_DURATION
  local priority = 4
  local bannerData = {
    TerritoryEnteredCard1 = {
      isClaimable = isClaimable,
      hasSecondPhase = hasSecondPhase,
      showBg = true
    }
  }
  if territoryEnteredCardType == TerritoryEnteredCardTypes.OutpostType then
    if isClaimable then
      return
    end
    local outpostCapitals = MapComponentBus.Broadcast.GetOutposts()
    if not outpostCapitals or #outpostCapitals == 0 then
      return
    end
    for i = 1, #outpostCapitals do
      local outpostData = outpostCapitals[i]
      if additionalData.outpostId == outpostData.id then
        bannerData.TerritoryEnteredCard1.title = outpostData.nameLocalizationKey
        bannerData.TerritoryEnteredCard1.titleLabel = "@ui_outpost"
        self.banners:EnqueueBanner(layouts.LAYOUT_TERRITORY_ENTERED, bannerData, duration, nil, nil, false, priority)
      end
    end
    return
  end
  local retrieveGuildData = false
  local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(claimKey)
  if territoryEnteredCardType == TerritoryEnteredCardTypes.TerritoryType then
    if not territoryName or territoryName == "" then
      return
    end
    retrieveGuildData = true
    local territoryStanding = TerritoryDataHandler:GetTerritoryStanding(claimKey)
    bannerData.TerritoryEnteredCard1.title = territoryName
    bannerData.TerritoryEnteredCard1.titleLabel = isClaimable and "@ui_territory" or "@ui_region"
    bannerData.TerritoryEnteredCard1.standingLabel = GetLocalizedReplacementText("@ui_territory_standinglabel", {territoryName = territoryName})
    bannerData.TerritoryEnteredCard1.rank = tostring(territoryStanding.rank)
    bannerData.TerritoryEnteredCard1.rankName = territoryStanding.displayName
    bannerData.TerritoryEnteredCard1.description = "@ui_unclaimed_territory"
  elseif territoryEnteredCardType == TerritoryEnteredCardTypes.SettlementType or territoryEnteredCardType == TerritoryEnteredCardTypes.FortType then
    if not territoryName or territoryName == "" then
      return
    end
    retrieveGuildData = true
    local isSettlementData = territoryEnteredCardType == TerritoryEnteredCardTypes.SettlementType
    local upgradeType = isSettlementData and eTerritoryUpgradeType_Settlement or eTerritoryUpgradeType_Fortress
    local tierInfo, numTier = TerritoryDataHandler:GetUpgradeTierInfoByTerritoryId(claimKey, upgradeType)
    local locTag = isSettlementData and "@ui_territory_name_with_settlement_tier_name" or "@ui_territory_name_with_fort_tier_name"
    local unclaimedText = GetLocalizedReplacementText("@ui_unclaimed_settlementorfort", {
      tierName = tierInfo.name
    })
    local territoryNameWithTierName = GetLocalizedReplacementText(locTag, {
      territoryName = territoryName,
      tierName = tierInfo.name
    })
    bannerData.TerritoryEnteredCard1.title = territoryNameWithTierName
    bannerData.TerritoryEnteredCard1.tierLabel = GetRomanFromNumber(numTier)
    bannerData.TerritoryEnteredCard1.description = unclaimedText
    if isSettlementData then
      local propertyTaxText = TerritoryDataHandler:GetTaxOrFeeText(claimKey, eTaxOrFee_PropertyTax)
      local tradingTaxText = TerritoryDataHandler:GetTaxOrFeeText(claimKey, eTaxOrFee_TradingTax)
      local craftingFeeText = TerritoryDataHandler:GetTaxOrFeeText(claimKey, eTaxOrFee_CraftingFee)
      local refiningFeeText = TerritoryDataHandler:GetTaxOrFeeText(claimKey, eTaxOrFee_RefiningFee)
      local propertyTaxValue = TerritoryDataHandler:GetTaxOrFeeAmount(claimKey, eTaxOrFee_PropertyTax)
      local tradingTaxValue = TerritoryDataHandler:GetTaxOrFeeAmount(claimKey, eTaxOrFee_TradingTax)
      local craftingFeeValue = TerritoryDataHandler:GetTaxOrFeeAmount(claimKey, eTaxOrFee_CraftingFee)
      local refiningFeeValue = TerritoryDataHandler:GetTaxOrFeeAmount(claimKey, eTaxOrFee_RefiningFee)
      local taxes = {
        {
          label = "@ui_property_tax",
          value1 = propertyTaxText,
          value2 = TerritoryDataHandler:GetTaxOrFeeDisplayText(propertyTaxValue, eTaxOrFee_PropertyTax)
        },
        {
          label = "@ui_trading_tax",
          value1 = tradingTaxText,
          value2 = TerritoryDataHandler:GetTaxOrFeeDisplayText(tradingTaxValue, eTaxOrFee_TradingTax)
        },
        {
          label = "@ui_crafting_fee",
          value1 = craftingFeeText,
          value2 = TerritoryDataHandler:GetTaxOrFeeDisplayText(craftingFeeValue, eTaxOrFee_CraftingFee)
        },
        {
          label = "@ui_refining_fee",
          value1 = refiningFeeText,
          value2 = TerritoryDataHandler:GetTaxOrFeeDisplayText(refiningFeeValue, eTaxOrFee_RefiningFee)
        }
      }
      bannerData.TerritoryEnteredCard1.taxes = taxes
      bannerData.TerritoryEnteredCard1.isSettlement = true
    end
  elseif territoryEnteredCardType == TerritoryEnteredCardTypes.HQType then
    retrieveGuildData = true
    bannerData.TerritoryEnteredCard1.title = additionalData.name
    bannerData.TerritoryEnteredCard1.description = additionalData.description
    bannerData.TerritoryEnteredCard1.eventId = additionalData.eventId
    bannerData.TerritoryEnteredCard1.showBg = false
  elseif territoryEnteredCardType == TerritoryEnteredCardTypes.OpenWorld then
    bannerData.TerritoryEnteredCard1.title = additionalData.name
    bannerData.TerritoryEnteredCard1.description = additionalData.description
    bannerData.TerritoryEnteredCard1.eventId = additionalData.eventId
    bannerData.TerritoryEnteredCard1.showBg = false
  end
  local ownerData = isClaimable and LandClaimRequestBus.Broadcast.GetClaimOwnerData(claimKey) or nil
  if retrieveGuildData and ownerData and ownerData.guildId:IsValid() then
    local function successCallback(self, result)
      local guildData
      if 0 < #result then
        guildData = type(result[1]) == "table" and result[1].guildData or result[1]
      else
        Log("ERR - BannerTriggers:WarBanner: GuildData request returned with no data")
        return
      end
      if guildData and guildData:IsValid() then
        bannerData.TerritoryEnteredCard1.guildName = guildData.guildName
        bannerData.TerritoryEnteredCard1.crestData = guildData.crestData
        self.banners:EnqueueBanner(layouts.LAYOUT_TERRITORY_ENTERED, bannerData, duration, nil, nil, false, priority)
      end
    end
    self.socialDataHandler:GetGuildDetailedData_ServerCall(self, successCallback, self.GetGuildDetailedDataFailure, ownerData.guildId)
  else
    self.banners:EnqueueBanner(layouts.LAYOUT_TERRITORY_ENTERED, bannerData, duration, nil, nil, false, priority)
  end
end
function BannerTriggers:ShowArenaActivatedNotification(secondsTillTeleport)
  local notificationData = NotificationData()
  notificationData.title = "@arena_teleport_title"
  notificationData.text = "@arena_teleport_desc"
  notificationData.maximumDuration = secondsTillTeleport - 1
  notificationData.showProgress = true
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  local bannerData = {
    AchievementCard1 = {
      title = "@arena_started"
    }
  }
  local priority = 4
  self.banners:EnqueueBanner(layouts.LAYOUT_ACHIEVEMENT, bannerData, layouts.DEFAULT_DISPLAY_DURATION, nil, nil, false, priority)
  self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Arena, self.audioHelper.MusicState_Arena_Countdown)
end
function BannerTriggers:ShowMinimalTextBanner(titleText, descriptionText, titleLabelText, iconPath)
  local bannerData = {
    TerritoryEnteredCard1 = {
      title = titleText,
      description = descriptionText,
      titleLabel = titleLabelText,
      icon = iconPath,
      isClaimable = true
    }
  }
  return self.banners:EnqueueBanner(layouts.LAYOUT_TERRITORY_ENTERED, bannerData, 5, nil, nil, false, 4)
end
return BannerTriggers
