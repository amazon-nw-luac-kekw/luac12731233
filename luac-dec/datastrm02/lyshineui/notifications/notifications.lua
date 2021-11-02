local Notifications = {
  Properties = {
    MaxNotificationsVisible = {
      default = 4,
      description = "",
      min = 0
    },
    SecondsBetweenNotifications = {
      default = 1.5,
      description = "",
      min = 0
    },
    FadeSpeed = {
      default = 4,
      description = "Speed multiplier for fading notifications in/out (normally takes 1 second). Ex: 2 means twice as fast (1/2 sec).",
      min = 0
    },
    DefaultContainer = {
      default = EntityId()
    },
    MinorContainer = {
      default = EntityId()
    },
    CenterContainer = {
      default = EntityId()
    },
    DisabledContainer = {
      default = EntityId()
    },
    Durations = {
      Social = {
        default = 5,
        description = "Use this duration for Social notifications"
      },
      Groups = {
        default = 5,
        description = "Use this duration for Groups notifications"
      },
      Guild = {
        default = 5,
        description = "Use this duration for Guild notifications"
      },
      WarSingle = {
        default = 7,
        description = "Use this duration for WarSingle notifications"
      },
      Inventory = {
        default = 5,
        description = "Use this duration for Inventory notifications"
      },
      Choice = {
        default = 10,
        description = "Use this duration for choice notifications"
      },
      Minor = {
        default = 2.5,
        description = "Use this duration for Minor notifications"
      },
      Subtitle = {
        default = 5,
        description = "Use this duration for VO Subtitles"
      },
      ORTutorial = {
        default = 5,
        description = "Use this duration for Outpost Rush Contextual Tutorial notifications "
      }
    },
    yOffsetShort = {
      default = 160,
      description = "This is height of basic notification"
    },
    yOffsetTall = {
      default = 200,
      description = "This is height of choice notification"
    }
  },
  DefaultData = {
    containerName = "DefaultData",
    notificationsVisible = {},
    notificationsPending = {},
    notificationsChoice = {},
    visibleCount = 0,
    pendingCount = 0,
    timeSinceNotification = 0
  },
  MinorData = {
    containerName = "MinorData",
    notificationsVisible = {},
    notificationsPending = {},
    notificationsChoice = {},
    visibleCount = 0,
    pendingCount = 0,
    timeSinceNotification = 0
  },
  CenterData = {
    containerName = "CenterData",
    notificationsVisible = {},
    notificationsPending = {},
    notificationsChoice = {},
    visibleCount = 0,
    pendingCount = 0,
    timeSinceNotification = 0,
    maxVisibleOverride = 1
  },
  centerTypes = {
    WarInvite = {infiniteDuration = true},
    PvPGroupInvite = {infiniteDuration = true},
    PvEGroupInvite = {infiniteDuration = true},
    GroupKick = {infiniteDuration = false},
    FriendInviteCenter = {infiniteDuration = true},
    GuildInvite = {infiniteDuration = true},
    GenericInvite = {infiniteDuration = false},
    GameModeInvite = {infiniteDuration = true},
    DungeonInvite = {infiniteDuration = true}
  },
  defaultDuration = 2,
  topChoiceNotification = {},
  genericNotificationPath = "LyShineUI\\Notifications\\notification",
  guildNotificationPath = "LyShineUI\\Notifications\\GuildNotification",
  choiceNotificationPath = "LyShineUI\\Notifications\\ChoiceNotification",
  minorNotificationPath = "LyShineUI\\Notifications\\MinorNotification",
  centerNotificationPath = "LyShineUI\\Notifications\\CenterNotification",
  acceptKeybinding = "notificationAccept",
  declineKeybinding = "notificationDecline",
  warNotificationImagePath = "LyShineUI/Images/Icons/Misc/icon_warUncolored.png",
  deathsDoorNotificationImagePath = "LyShineUI/Images/DeathsDoor/DeathsDoorIcon.png",
  overburdenedCryActionHandlers = {},
  movementWarningRefCount = 0,
  lastMoveWarnTime = WallClockTimePoint(),
  lastInventorySlotsWarnTime = WallClockTimePoint(),
  MOVEMENT_MIN_TIME_BETWEEN_NOTIFICATIONS = 1000,
  notificationPools = {
    Generic = {},
    Guild = {},
    Choice = {},
    Minor = {},
    Center = {}
  },
  notificationPaths = {
    Generic = "LyShineUI\\Notifications\\notification",
    Guild = "LyShineUI\\Notifications\\GuildNotification",
    Choice = "LyShineUI\\Notifications\\ChoiceNotification",
    Minor = "LyShineUI\\Notifications\\MinorNotification",
    Center = "LyShineUI\\Notifications\\CenterNotification"
  },
  TIME_BETWEEN_TELEPORT_CHECKS = 1,
  TELEPORT_WARNING_TIME = 60,
  teleportTimer = 0,
  secondsToTeleport = 0,
  defaultNotificationSpacing = 5,
  defaultContainerYPos = 5,
  centerNotificationsDrawOrder = 150
}
local CommonDragDrop = RequireScript("LyShineUI.CommonDragDrop")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(Notifications)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(Notifications)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local warDeclarationPopupHelper = RequireScript("LyShineUI.WarDeclaration.WarDeclarationPopupHelper")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local genericInviteCommon = RequireScript("LyShineUI._Common.GenericInviteCommon")
function Notifications:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(UiNotificationsBus)
  self:BusConnect(DynamicBus.UITickBus)
  self:BusConnect(RaidSetupNotificationBus)
  self:BusConnect(LocalPlayerEventsBus)
  self:BusConnect(UiSpawnerNotificationBus, self.DisabledContainer)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  DynamicBus.BannerNotificationsBus.Connect(self.canvasId, self)
  self.defaultDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  self.currentAzothAmount = 0
  self.currencyAmount = 0
  self.factionReputationAmount = 0
  self.factionTokensAmount = 0
  if LoadScreenBus.Broadcast.IsLoadingScreenShown() then
    self.loadScreenNotificationBus = self:BusConnect(LoadScreenNotificationBus, self.entityId)
  end
  for i = 1, self.MaxNotificationsVisible do
    for typeName, dataSet in pairs(self.notificationPools) do
      self.notificationPools[typeName][i] = {typeName = typeName, index = i}
      self:SpawnSlice(self.DisabledContainer, self.notificationPaths[typeName], self.OnNotificationSpawned, self.notificationPools[typeName][i])
    end
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    if data then
      self.playerEntityId = data
      if self.genericInviteHandler then
        self:BusDisconnect(self.genericInviteHandler)
        self.genericInviteHandler = nil
      end
      self.genericInviteHandler = self:BusConnect(PlayerGenericInviteComponentNotificationBus, self.playerEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, data)
    if data then
      self.vitalsId = data
      if self.notificationHandler then
        self:BusDisconnect(self.notificationHandler)
      end
      self.notificationHandler = self:BusConnect(VitalsComponentNotificationBus, self.vitalsId)
      if self.guildNotificationHandler then
        self:BusDisconnect(self.guildNotificationHandler)
      end
      self.guildNotificationHandler = self:BusConnect(GuildNotificationsBus, self.vitalsId)
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.Rank", function(self, rank)
    if not self.receivedPortrayedGuildRank then
      self.receivedPortrayedGuildRank = true
      return
    end
    local showNotification = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.RankNotification")
    if showNotification and rank then
      local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
      local rankData = PlayerComponentRequestsBus.Event.GetGuildRankData(playerEntityId)
      if rankData then
        local notificationTitle = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_rankChanged", tostring(rankData.name))
        local keys = vector_basic_string_char_char_traits_char()
        keys:push_back("companyName")
        keys:push_back("rankName")
        keys:push_back("button_hint")
        local values = vector_basic_string_char_char_traits_char()
        local guildName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Name")
        values:push_back(guildName)
        local rankName = tostring(rankData.name)
        values:push_back(rankName)
        values:push_back(LyShineManagerBus.Broadcast.GetKeybind("toggleGuildComponent", "ui"))
        local notificationText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements("@ui_changedRankDesc", keys, values)
        local notificationData = NotificationData()
        notificationData.type = "Social"
        notificationData.title = notificationTitle
        notificationData.text = notificationText
        notificationData.maximumDuration = 10
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        self.audioHelper:PlaySound(self.audioHelper.OnGuildPromote)
      end
    end
  end)
  self.overburdenedActions = {
    jump = "@ui_overencumbered_sprint",
    dodge = "@ui_overencumbered_dodge",
    ability1 = "@ui_overencumbered_ability",
    ability2 = "@ui_overencumbered_ability",
    ability3 = "@ui_overencumbered_ability",
    moveleft_onpress = "@ui_overencumbered_move",
    moveright_onpress = "@ui_overencumbered_move",
    moveforward_onpress = "@ui_overencumbered_move",
    moveback_onpress = "@ui_overencumbered_move"
  }
  local wasOverburdened
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Equipment.EquipLoadCategory", function(self, equipLoad)
    local isOverburdened = equipLoad == eEquipLoad_Overburdened
    if wasOverburdened ~= isOverburdened then
      self:EnableMovementWarnings(isOverburdened)
      wasOverburdened = isOverburdened
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Inventory.TotalInventorySlotsUsed", function(self, totalSlots)
    self:NotifyInventorySlotsRemaining(false, nil)
  end)
  local afflictionIds = DamageDataBus.Broadcast.GetAfflictionRowKeys()
  for i = 1, #afflictionIds do
    if DamageDataBus.Broadcast.GetAfflictionRowKey(afflictionIds[i]) == "AfflictionFrostbite" then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Afflictions." .. tostring(afflictionIds[i]) .. ".IsAfflicted", function(self, afflicted)
        self:EnableMovementWarnings(afflicted)
      end)
      break
    end
  end
  local isFirstHomePointUpdate = true
  local knownHomePoints = {}
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HomePoints.Count", function(self, count)
    if count ~= nil then
      for i = 1, count do
        local gdeId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HomePoints." .. i .. ".GDEID")
        if not knownHomePoints[gdeId] then
          knownHomePoints[gdeId] = true
          if not isFirstHomePointUpdate then
            local homePointName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HomePoints." .. i .. ".Name")
            local homePointType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HomePoints." .. i .. ".Type")
            local notificationData = NotificationData()
            notificationData.type = "Minor"
            notificationData.text = homePointType == "FastTravelPoint" and "@ui_activated_fasttravel_point" or "@ui_activated_respawn_name"
            local isInDungeon = GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(self.vitalsId) ~= 0
            if isInDungeon then
              notificationData.text = GetLocalizedReplacementText("@ui_dungeon_respawn_point_unlocked", {areaName = homePointName})
            end
            UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
          elseif not LoadScreenBus.Broadcast.IsLoadingScreenShown() then
            self:NotifyHousingTaxDue()
          end
        end
      end
      isFirstHomePointUpdate = false
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.SocialEntityId", function(self, socialEntityId)
    if socialEntityId then
      if self.socialNotificationsHandler then
        self:BusDisconnect(self.socialNotificationsHandler)
      end
      self.socialNotificationsHandler = self:BusConnect(SocialNotificationsBus, socialEntityId)
    end
  end)
  DynamicBus.NotificationsRequestBus.Connect(self.entityId, self)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  self.isInMainMenu = GameRequestsBus.Broadcast.IsInMainMenu()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, territoryId)
    self.territoryId = territoryId
    self:TryQueueWarTeleportNotification()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.TerritoryEntityId", function(self, entityId)
    self.territoryEntityId = entityId
    self:TryQueueWarTeleportNotification()
  end)
  self.numBrokenItemsCount = 0
  self.numDamagedItemsCount = 0
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Paperdoll.ItemDamaged", function(self, itemId)
    if self.isFtue or self.isInMainMenu then
      return
    end
    if itemId then
      self:EnqueueItemDamagedNotification(false)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Paperdoll.ItemBroken", function(self, itemId)
    if self.isFtue or self.isInMainMenu then
      return
    end
    if itemId then
      self:EnqueueItemDamagedNotification(true)
    end
  end)
  local housingTaxesDueCheckFrequency = 3600
  timingUtils:Delay(housingTaxesDueCheckFrequency, self, function()
    self:NotifyHousingTaxDue()
  end, true)
end
function Notifications:EnqueueItemDamagedNotification(isBroken)
  if isBroken then
    self.numBrokenItemsCount = self.numBrokenItemsCount + 1
  else
    self.numDamagedItemsCount = self.numDamagedItemsCount + 1
  end
  if not self.itemDamagedNotifications then
    self.itemDamagedNotifications = timingUtils:Delay(1, self, self.FlushItemDamagedNotifications)
  end
end
function Notifications:TryQueueWarTeleportNotification()
  if self.teleportDelay then
    timingUtils:StopDelay(self, self.OnStartTeleportChecks)
    self.teleportDelay = nil
  end
  self.timeToCheckWarTeleport = 0
  if self.territoryEntityId and self.territoryEntityId:IsValid() and self.territoryId and self.territoryId ~= 0 then
    local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.territoryId)
    if warDetails and warDetails:IsValid() and warDetails:GetWarPhase() == eWarPhase_PreWar then
      local signupStatus = RaidSetupRequestBus.Broadcast.GetSignupStatus(self.territoryId)
      if signupStatus and signupStatus.selected then
        return
      end
      local siegeStartTime = warDetails:GetPhaseEndTime()
      local remainingTime = siegeStartTime:Subtract(timeHelpers:ServerNow()):ToSeconds()
      local timeToWarn = remainingTime - self.TELEPORT_WARNING_TIME
      if 0 < timeToWarn then
        self.teleportDelay = timingUtils:Delay(timeToWarn, self, self.OnStartTeleportChecks)
      end
    end
  end
end
function Notifications:OnStartTeleportChecks()
  self.teleportDelay = nil
  self.timeToCheckWarTeleport = self.TELEPORT_WARNING_TIME
  self.teleportTimer = self.TIME_BETWEEN_TELEPORT_CHECKS
  self.teleportNotificationId = nil
end
function Notifications:FlushItemDamagedNotifications()
  if self.numBrokenItemsCount > 0 then
    local notificationData = NotificationData()
    notificationData.type = "Inventory"
    notificationData.title = "@ui_inventory"
    notificationData.text = GetLocalizedReplacementText("@inv_itembroken", {
      num = self.numBrokenItemsCount
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  if 0 < self.numDamagedItemsCount then
    local notificationData = NotificationData()
    notificationData.type = "Inventory"
    notificationData.title = "@ui_inventory"
    notificationData.text = GetLocalizedReplacementText("@inv_itemdamaged", {
      num = self.numDamagedItemsCount
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
  self.numBrokenItemsCount = 0
  self.numDamagedItemsCount = 0
  self.itemDamagedNotifications = nil
end
function Notifications:OnCampReconnectFailed()
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.contextId = self.entityId
  notificationData.text = "@ui_camp_reconnect_failed"
  notificationData.maximumDuration = 10
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function Notifications:OnGuildWarEligibilityAdded(territoryId, warDecDeadline)
  if self.pendingWarLotteryNotification then
    UiNotificationsBus.Broadcast.RescindNotification(self.pendingWarLotteryNotification, true, true)
    self.pendingWarLotteryNotification = nil
  end
  if not GuildsComponentBus.Broadcast.IsGuildInActiveWarLottery() then
    local territoryDefn = TerritoryDefinitionsDataManagerBus.Broadcast.GetTerritoryDefinition(territoryId)
    local warLotteryTime = warDecDeadline:Subtract(timeHelpers:ServerNow()):ToSecondsRoundedUp()
    local timeString = timeHelpers:ConvertToShorthandString(warLotteryTime, true)
    local notificationData = NotificationData()
    notificationData.type = "WarSingle"
    notificationData.contextId = self.entityId
    notificationData.icon = "LyShineUI/Images/Icons/Misc/icon_warUncolored.dds"
    notificationData.title = "@ui_war_prewar"
    notificationData.text = GetLocalizedReplacementText("@ui_war_declared_on_territory", {
      territory = territoryDefn.nameLocalizationKey,
      time = timeString
    })
    notificationData.maximumDuration = 10
    notificationData.showProgress = true
    local hasWarDecPrivilege = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Declare_War)
    if hasWarDecPrivilege then
      notificationData.hasChoice = true
      notificationData.acceptTextOverride = "@ui_declarewar"
      notificationData.declineTextOverride = "@ui_dismiss"
      notificationData.callbackName = "OnDeclareWar"
    end
    self.pendingWarTerritory = territoryId
    self.pendingWarLotteryNotification = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function Notifications:OnDeclareWar()
  if self.pendingWarTerritory then
    local claimOwnerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.pendingWarTerritory)
    if claimOwnerData then
      warDeclarationPopupHelper:ShowWarDeclarationPopup(claimOwnerData.guildId, claimOwnerData.guildName, claimOwnerData.guildCrestData, self.pendingWarTerritory)
    end
  end
end
function Notifications:NotifyHousingTaxDue()
  local ownedHouses = PlayerHousingClientRequestBus.Broadcast.GetOwnedHouseData()
  if not ownedHouses then
    return
  end
  local warningToleranceSec = 86400
  local now = timeHelpers:ServerNow()
  for i = 1, #ownedHouses do
    local houseData = ownedHouses[i]
    local territoryId = MapComponentBus.Broadcast.GetContainingTerritory(houseData.housingPlotPos)
    local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
    local timeUntilTaxesDueSec = houseData.taxesDue:Subtract(now):ToSeconds()
    if warningToleranceSec > timeUntilTaxesDueSec then
      local notificationDesc
      if 0 < timeUntilTaxesDueSec then
        notificationDesc = GetLocalizedReplacementText("@ui_house_unpaid_taxes_due_soon", {
          time = timeHelpers:ConvertToShorthandString(timeUntilTaxesDueSec, false),
          territoryName = territoryName
        })
      else
        notificationDesc = GetLocalizedReplacementText("@ui_house_overdue_at", {territoryName = territoryName})
      end
      local notificationData = NotificationData()
      notificationData.type = "Social"
      notificationData.title = "@ui_house_tax"
      notificationData.text = notificationDesc
      notificationData.maximumDuration = 10
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end
end
function Notifications:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.NotificationsRequestBus.Disconnect(self.entityId, self)
  DynamicBus.BannerNotificationsBus.Disconnect(self.canvasId, self)
end
function Notifications:OnLoadingScreenDismissed()
  if self.loadScreenNotificationBus then
    self:BusDisconnect(self.loadScreenNotificationBus)
    self.loadScreenNotificationBus = nil
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CampReconnectFailed", function(self, shouldNotify)
    if not shouldNotify then
      return
    end
    self:OnCampReconnectFailed()
    self.dataLayer:ClearDataTree(1792830796)
  end)
  local voipRegistrationRestricted = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Voip.RegistrationRestricted")
  if not self.voipRegistrationNotificationShown and not self.isInMainMenu and voipRegistrationRestricted == true then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_voip_registration_restricted"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    self.voipRegistrationNotificationShown = true
  end
  if not self.isFirstHomePointUpdate then
    self:NotifyHousingTaxDue()
  end
  if not self.playerEntityId then
    return
  end
  local azothCurrencyCap = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, 928006727, 0)
  local warningPercentage = 0.85
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.AzothAmount", function(self, currencyAmount)
    if not currencyAmount then
      return
    end
    if currencyAmount <= self.currentAzothAmount then
      self.currentAzothAmount = currencyAmount
      return
    end
    local notificationTitle, notificationDesc
    if currencyAmount == azothCurrencyCap then
      notificationTitle = "@ui_azoth_max_title"
      notificationDesc = "@ui_azoth_max_desc"
    elseif currencyAmount >= azothCurrencyCap * warningPercentage then
      notificationTitle = "@ui_azoth_warning_title"
      notificationDesc = GetLocalizedReplacementText("@ui_azoth_warning_desc", {amount = currencyAmount, maxAmount = azothCurrencyCap})
    end
    if notificationTitle then
      local notificationData = NotificationData()
      notificationData.type = "Social"
      notificationData.icon = "LyShineUI/Images/Icons/Items/Resource/AzureT1.dds"
      notificationData.title = notificationTitle
      notificationData.text = notificationDesc
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
    self.currentAzothAmount = currencyAmount
  end)
  self.walletCap = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.wallet-cap-player")
  self.walletWarningThresholds = {
    0.85 * self.walletCap,
    0.9 * self.walletCap,
    0.95 * self.walletCap
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.Amount", function(self, currencyAmount)
    if not currencyAmount then
      return
    end
    if currencyAmount >= self.currencyAmount then
      local notificationTitle, notificationDesc
      if currencyAmount == self.walletCap then
        notificationTitle = "@ui_coin_max_title"
        notificationDesc = "@ui_coin_max_desc"
      else
        for _, threshold in ipairs(self.walletWarningThresholds) do
          if threshold > self.currencyAmount and threshold < currencyAmount then
            notificationTitle = "@ui_coin_warning_title"
            notificationDesc = GetLocalizedReplacementText("@ui_coin_warning_desc", {
              amount = GetLocalizedCurrency(currencyAmount),
              maxAmount = GetLocalizedCurrency(self.walletCap)
            })
          end
        end
      end
      if notificationTitle then
        local notificationData = NotificationData()
        notificationData.type = "Social"
        notificationData.icon = "LyShineUI/Images/Icons/Objectives/reward_coin.dds"
        notificationData.title = notificationTitle
        notificationData.text = notificationDesc
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
    end
    self.currencyAmount = currencyAmount
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Currency.RefundedAmount", function(self, refundedAmount)
    if refundedAmount and 0 < refundedAmount then
      local notificationData = NotificationData()
      notificationData.type = "Social"
      notificationData.icon = "LyShineUI/Images/Icons/Objectives/reward_coin.dds"
      notificationData.title = "@ui_coin_returned"
      notificationData.text = GetLocalizedReplacementText("@ui_coin_returned_desc", {
        amount = GetLocalizedCurrency(refundedAmount, false)
      })
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.FactionReputationAmount", function(self, currencyAmount)
    local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    if not playerFaction or playerFaction == eFactionType_None or playerFaction == eFactionType_Any then
      self.factionReputationAmount = 0
      return
    end
    local reputationId = FactionRequestBus.Event.GetFactionReputationProgressionIdFromType(self.playerEntityId, playerFaction)
    local currentRank = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, reputationId)
    local reputationCurrencyCap = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, reputationId, currentRank)
    if not currencyAmount then
      return
    end
    if currencyAmount <= self.factionReputationAmount then
      self.factionReputationAmount = currencyAmount
      return
    end
    local notificationTitle, notificationDesc
    if currencyAmount == reputationCurrencyCap then
      notificationTitle = "@ui_reputation_max_title"
      notificationDesc = "@ui_reputation_max_desc"
    elseif currencyAmount >= reputationCurrencyCap * warningPercentage then
      notificationTitle = "@ui_reputation_warning_title"
      notificationDesc = GetLocalizedReplacementText("@ui_reputation_warning_desc", {amount = currencyAmount, maxAmount = reputationCurrencyCap})
    end
    if notificationTitle then
      local notificationData = NotificationData()
      notificationData.type = "Social"
      notificationData.icon = "LyShineUI/Images/Icons/Objectives/reward_factionReputation" .. tostring(playerFaction) .. ".dds"
      notificationData.title = notificationTitle
      notificationData.text = notificationDesc
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
    self.factionReputationAmount = currencyAmount
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Currency.FactionTokensAmount", function(self, currencyAmount)
    local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    if not playerFaction or playerFaction == eFactionType_None or playerFaction == eFactionType_Any then
      self.factionTokensAmount = 0
      return
    end
    local tokensId = FactionRequestBus.Event.GetFactionTokensProgressionIdFromType(self.playerEntityId, playerFaction)
    local currentRank = CategoricalProgressionRequestBus.Event.GetRank(self.playerEntityId, tokensId)
    local tokensCurrencyCap = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(self.playerEntityId, tokensId, currentRank)
    if not currencyAmount then
      return
    end
    if currencyAmount <= self.factionTokensAmount then
      self.factionTokensAmount = currencyAmount
      return
    end
    local notificationTitle, notificationDesc
    if currencyAmount == tokensCurrencyCap then
      notificationTitle = "@ui_tokens_max_title"
      notificationDesc = "@ui_tokens_max_desc"
    elseif currencyAmount >= tokensCurrencyCap * warningPercentage then
      notificationTitle = "@ui_tokens_warning_title"
      notificationDesc = GetLocalizedReplacementText("@ui_tokens_warning_desc", {amount = currencyAmount, maxAmount = tokensCurrencyCap})
    end
    if notificationTitle then
      local notificationData = NotificationData()
      notificationData.type = "Social"
      notificationData.icon = "LyShineUI/Images/Icons/Objectives/reward_factionTokens" .. tostring(playerFaction) .. ".dds"
      notificationData.title = notificationTitle
      notificationData.text = notificationDesc
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
    self.factionTokensAmount = currencyAmount
  end)
end
function Notifications:NotifyInventorySlotsRemaining(alwaysShowWhenLow, slotsLeft)
  if slotsLeft == nil then
    slotsLeft = CommonDragDrop:GetInventorySlotsRemaining()
  end
  if slotsLeft > CommonDragDrop.INVENTORY_SLOTS_WARNING_THRESHOLD then
    return
  end
  local countChanged = slotsLeft ~= self.lastInventorySlotsLeft
  self.lastInventorySlotsLeft = slotsLeft
  local curTime = timeHelpers:ServerNow()
  if not alwaysShowWhenLow then
    if not countChanged then
      return
    end
    local timeSinceLastNotification = curTime:Subtract(self.lastInventorySlotsWarnTime):ToMillisecondsUnrounded()
    if timeSinceLastNotification < CommonDragDrop.INVENTORY_MIN_TIME_BETWEEN_NOTIFICATIONS then
      return
    end
  end
  local message = "@ui_inventoryfull"
  if 0 < slotsLeft then
    message = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_inventoryslotsremaining", slotsLeft)
  end
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = message
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  self.lastInventorySlotsWarnTime = curTime
end
function Notifications:EnableMovementWarnings(isEnabled)
  if isEnabled then
    if #self.overburdenedCryActionHandlers == 0 then
      for cryAction, _ in pairs(self.overburdenedActions) do
        self.overburdenedCryActionHandlers[#self.overburdenedCryActionHandlers + 1] = self:BusConnect(CryActionNotificationsBus, cryAction)
      end
    end
    self.movementWarningRefCount = self.movementWarningRefCount + 1
  else
    self.movementWarningRefCount = self.movementWarningRefCount - 1
    if 0 >= self.movementWarningRefCount then
      for _, handler in ipairs(self.overburdenedCryActionHandlers) do
        self:BusDisconnect(handler)
      end
      ClearTable(self.overburdenedCryActionHandlers)
      self.movementWarningRefCount = 0
    end
  end
end
function Notifications:OnBannerShowing(banner)
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.centerNotificationsDrawOrder)
end
function Notifications:OnBannerHidden()
  UiCanvasBus.Event.SetDrawOrder(self.canvasId, self.defaultDrawOrder)
end
function Notifications:OnTick(deltaTime, timePoint)
  self:TickContainer(self.DefaultData, deltaTime)
  self:TickContainer(self.CenterData, deltaTime)
  self:TickContainer(self.MinorData, deltaTime)
  self:TickDeathsDoorCooldown(deltaTime)
  self:TickTeleportTimer(deltaTime)
end
function Notifications:TickContainer(containerData, deltaTime)
  containerData.timeSinceNotification = containerData.timeSinceNotification + deltaTime
  if self.SecondsBetweenNotifications < containerData.timeSinceNotification then
    self:UpdatePendingQueue(containerData)
  end
end
function Notifications:OnCryAction(actionName)
  if actionName == self.acceptKeybinding then
    self:SelectNotification(true)
  elseif actionName == self.declineKeybinding then
    self:SelectNotification(false)
  elseif self.overburdenedActions[actionName] then
    local curTime = timeHelpers:ServerNow()
    local timeSinceLastNotification = curTime:Subtract(self.lastMoveWarnTime):ToMillisecondsUnrounded()
    if timeSinceLastNotification > self.MOVEMENT_MIN_TIME_BETWEEN_NOTIFICATIONS then
      local isImmobilized = LocalPlayerUIRequestsBus.Broadcast.IsImmobilizedByEncumbrance()
      if string.find(actionName, "move") and not isImmobilized then
        return
      end
      local message = self.overburdenedActions[actionName]
      local isEncumbered = LocalPlayerUIRequestsBus.Broadcast.IsEncumbered()
      local isFrostbitten = StatusEffectsRequestBus.Event.HasStatusEffect(self.playerEntityId, "Frostbite")
      local reason
      if isFrostbitten then
        if actionName == "jump" then
          return
        end
        reason = "@ui_afflicted_frostbite"
      else
        reason = isEncumbered and "@inv_encumbered" or "@inv_equipLoadOverburdened"
      end
      local notificationText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(message, reason)
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = notificationText
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      self.lastMoveWarnTime = curTime
    end
  end
end
function Notifications:SelectNotification(isAccept)
  if self:SelectNotificationInContainer(self.CenterData, isAccept) then
    return
  end
  self:SelectNotificationInContainer(self.DefaultData, isAccept)
end
function Notifications:SelectNotificationInContainer(containerData, isAccept)
  if containerData.notificationsChoice[1] then
    local handledCallback = true
    if isAccept then
      handledCallback = containerData.notificationsChoice[1]:SelectAccept()
    else
      containerData.notificationsChoice[1]:SelectDecline()
    end
    if handledCallback then
      table.remove(containerData.notificationsChoice, 1)
      return true
    end
  end
  return false
end
function Notifications:UpdatePendingQueue(containerData)
  local maxVisible = containerData.maxVisibleOverride and containerData.maxVisibleOverride or self.Properties.MaxNotificationsVisible
  if containerData.pendingCount > 0 and maxVisible > containerData.visibleCount then
    local notification = containerData.notificationsPending[1]
    if notification then
      containerData.notificationsVisible[tostring(notification.uuid)] = {notification = notification, targetYPos = 0}
      table.remove(containerData.notificationsPending, 1)
      self:ShowNotification(containerData, notification)
      containerData.pendingCount = containerData.pendingCount - 1
    end
  end
end
function Notifications:RemoveChoiceNotification(containerData, entityId)
  for i = 1, #containerData.notificationsChoice do
    if containerData.notificationsChoice[i].entityId == entityId then
      table.remove(containerData.notificationsChoice, i)
      return
    end
  end
  if self:GetNumChoiceNotifications() == 0 then
    if self.acceptBindingBus then
      self:BusDisconnect(self.acceptBindingBus)
      self.acceptBindingBus = nil
    end
    if self.declineBindingBus then
      self:BusDisconnect(self.declineBindingBus)
      self.declineBindingBus = nil
    end
  end
end
function Notifications:GetNumChoiceNotifications()
  return #self.DefaultData.notificationsChoice + #self.CenterData.notificationsChoice
end
function Notifications:GetNumNotificationsByType(notificationType)
  local containerData = self.DefaultData
  local isCenterNotification = self:IsCenterType(notificationType)
  if isCenterNotification then
    containerData = self.CenterData
  elseif notificationType == "Minor" or notificationType == "Subtitle" then
    containerData = self.MinorData
  end
  local count = 0
  for _, pendingNotification in ipairs(containerData.notificationsPending) do
    if pendingNotification.type == notificationType then
      count = count + 1
    end
  end
  for _, visibleNotification in pairs(containerData.notificationsVisible) do
    if visibleNotification.type == notificationType then
      count = count + 1
    end
  end
  return count
end
function Notifications:IsNotifcationEqual(notification, otherNotification)
  return notification.title == otherNotification.title and notification.text == otherNotification.text and notification.text2 == otherNotification.text2 and notification.showProgress == otherNotification.showProgress and notification.hasChoice == otherNotification.hasChoice and notification.entityId == otherNotification.entityId
end
function Notifications:EnqueueNotification(notificationOriginal)
  if not LocalPlayerUIRequestsBus.Broadcast.AreNotificationsEnabled() and not self.isFtue and not self.isInMainMenu then
    return
  end
  local subtitlesEnabled = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Accessibility.Subtitles")
  if not subtitlesEnabled and notificationOriginal.type == "Subtitle" then
    return
  end
  local compare = function(first, second)
    if first.priority ~= second.priority then
      return first.priority > second.priority
    end
    return first.timestamp < second.timestamp
  end
  local containerData = self.DefaultData
  local isCenterNotification = self:IsCenterType(notificationOriginal.type)
  if isCenterNotification then
    containerData = self.CenterData
  elseif notificationOriginal.type == "Minor" or notificationOriginal.type == "Subtitle" then
    containerData = self.MinorData
  end
  if not notificationOriginal.allowDuplicates then
    for _, pendingNotification in ipairs(containerData.notificationsPending) do
      if self:IsNotifcationEqual(pendingNotification, notificationOriginal) then
        return
      end
    end
    for _, visibleNotification in pairs(containerData.notificationsVisible) do
      if self:IsNotifcationEqual(visibleNotification.notification, notificationOriginal) then
        return
      end
    end
  end
  local notification = NotificationData()
  notification.type = notificationOriginal.type
  notification.showProgress = notificationOriginal.showProgress
  notification.hasChoice = notificationOriginal.hasChoice
  notification.canAccept = notificationOriginal.canAccept
  notification.acceptTextOverride = notificationOriginal.acceptTextOverride
  notification.declineTextOverride = notificationOriginal.declineTextOverride
  notification.maximumDuration = notificationOriginal.maximumDuration
  notification.entityId = notificationOriginal.entityId
  notification.contextId = notificationOriginal.contextId
  notification.uuid = notificationOriginal.uuid
  notification.timestamp = notificationOriginal.timestamp
  notification.callbackName = notificationOriginal.callbackName
  notification.icon = notificationOriginal.icon
  notification.text = notificationOriginal.text
  notification.text2 = notificationOriginal.text2
  notification.title = notificationOriginal.title
  notification.guildCrest = notificationOriginal.guildCrest
  notification.priority = notificationOriginal.priority
  notification.declineOnTimeout = notificationOriginal.declineOnTimeout
  notification.uuid = Uuid:Create()
  if self.isInMainMenu then
    notification.timestamp = os.time()
  else
    notification.timestamp = timeHelpers:ServerSecondsSinceEpoch()
  end
  if notification.maximumDuration == self.defaultDuration then
    if isCenterNotification and notification.hasChoice and self.centerTypes[notification.type].infiniteDuration then
      notification.maximumDuration = -1
    elseif notification.hasChoice then
      notification.maximumDuration = self.Durations.Choice
    elseif self.Durations[notification.type] then
      notification.maximumDuration = self.Durations[notification.type]
    end
  end
  table.insert(containerData.notificationsPending, notification)
  containerData.pendingCount = containerData.pendingCount + 1
  if isCenterNotification and #containerData.notificationsChoice > 0 then
    local notificationEntity = containerData.notificationsChoice[1]
    local notificationId = notificationEntity.uuid
    local visibleNotification = containerData.notificationsVisible[tostring(notificationId)]
    if visibleNotification then
      local notificationData = visibleNotification.notification
      if notificationData and notification.priority > notificationData.priority then
        self:RescindByDataContainer(containerData, notificationId, false, true)
        table.insert(containerData.notificationsPending, notificationData)
        containerData.pendingCount = containerData.pendingCount + 1
      end
    end
  end
  table.sort(containerData.notificationsPending, compare)
  return notification.uuid
end
function Notifications:RescindNotification(notificationId, withdrawPending, withdrawVisible)
  local centerRemoved = self:RescindByDataContainer(self.CenterData, notificationId, withdrawPending, withdrawVisible)
  local minorRemoved = self:RescindByDataContainer(self.MinorData, notificationId, withdrawPending, withdrawVisible)
  local defaultRemoved = self:RescindByDataContainer(self.DefaultData, notificationId, withdrawPending, withdrawVisible)
  return minorRemoved or centerRemoved or defaultRemoved
end
function Notifications:RescindByDataContainer(dataContainer, notificationId, withdrawPending, withdrawVisible)
  for i = #dataContainer.notificationsPending, 1, -1 do
    if withdrawPending and dataContainer.notificationsPending[i].uuid == notificationId then
      table.remove(dataContainer.notificationsPending, i)
      dataContainer.pendingCount = dataContainer.pendingCount - 1
      return true
    end
  end
  if withdrawVisible and dataContainer.notificationsVisible[tostring(notificationId)] then
    local notificationData = dataContainer.notificationsVisible[tostring(notificationId)]
    notificationData.entity:ShowTransitionOut()
    return true
  end
  return false
end
function Notifications:UpdateNotification(notificationId, notificationData)
  local centerUpdated = self:UpdateByDataContainer(self.CenterData, notificationId, notificationData)
  local minorUpdated = self:UpdateByDataContainer(self.MinorData, notificationId, notificationData)
  local defaultUpdated = self:UpdateByDataContainer(self.DefaultData, notificationId, notificationData)
  return minorUpdated or centerUpdated or defaultUpdated
end
function Notifications:UpdateByDataContainer(dataContainer, notificationId, notificationData)
  for i = #dataContainer.notificationsPending, 1, -1 do
    if dataContainer.notificationsPending[i].uuid == notificationId then
      if notificationData.title then
        dataContainer.notificationsPending[i].title = notificationData.title
      end
      if notificationData.text then
        dataContainer.notificationsPending[i].text = notificationData.text
      end
      if notificationData.guildCrest then
        dataContainer.notificationsPending[i].guildCrest = notificationData.guildCrest
      end
      if notificationData.icon then
        dataContainer.notificationsPending[i].icon = notificationData.icon
      end
      if notificationData.declineTextOverride then
        dataContainer.notificationsPending[i].declineTextOverride = notificationData.declineTextOverride
      end
      if notificationData.canAccept ~= nil then
        dataContainer.notificationsPending[i].canAccept = notificationData.canAccept
      end
      return true
    end
  end
  if dataContainer.notificationsVisible[tostring(notificationId)] then
    local visibleNotification = dataContainer.notificationsVisible[tostring(notificationId)]
    if visibleNotification and visibleNotification.entity then
      self:ConfigureVisibleNotification(visibleNotification.entity, notificationData)
    end
    return true
  end
  return false
end
function Notifications:IsNotificationValid(notificationId, checkPending, checkVisible)
  local centerValid = self:IsNotificationValidInDataContainer(self.CenterData, notificationId, checkPending, checkVisible)
  local minorValid = self:IsNotificationValidInDataContainer(self.MinorData, notificationId, checkPending, checkVisible)
  local defaultValid = self:IsNotificationValidInDataContainer(self.DefaultData, notificationId, checkPending, checkVisible)
  return minorValid or centerValid or defaultValid
end
function Notifications:IsNotificationValidInDataContainer(dataContainer, notificationId, checkPending, checkVisible)
  if checkPending == nil then
    checkPending = true
  end
  if checkVisible == nil then
    checkVisible = true
  end
  if checkPending then
    for i = #dataContainer.notificationsPending, 1, -1 do
      if dataContainer.notificationsPending[i].uuid == notificationId then
        return true
      end
    end
  end
  if checkVisible and dataContainer.notificationsVisible[tostring(notificationId)] then
    return true
  end
  return false
end
function Notifications:OnNotificationSpawned(entity, data)
  entity:SetPoolName(data.typeName)
  self.notificationPools[data.typeName][data.index].entity = entity
  self.notificationPools[data.typeName][data.index].isShown = false
end
function Notifications:SetNotificationElement(elementData, notification)
  self:ConfigureVisibleNotification(elementData.entity, notification)
  local containerData = self.DefaultData
  if self:IsCenterType(notification.type) then
    containerData = self.CenterData
  elseif notification.type == "Minor" or notification.type == "Subtitle" then
    containerData = self.MinorData
  end
  local visibleNotification = containerData.notificationsVisible[tostring(notification.uuid)]
  visibleNotification.entity = elementData.entity
  visibleNotification.itemIndex = elementData.index
  elementData.entity:SetContainerName(containerData.containerName)
  if notification.hasChoice then
    if not self.acceptBindingBus then
      self.acceptBindingBus = self:BusConnect(CryActionNotificationsBus, self.acceptKeybinding)
    end
    if not self.declineBindingBus then
      self.declineBindingBus = self:BusConnect(CryActionNotificationsBus, self.declineKeybinding)
    end
    if #notification.acceptTextOverride > 0 then
      elementData.entity:SetAcceptText(notification.acceptTextOverride)
    end
    if 0 < #notification.declineTextOverride then
      elementData.entity:SetDeclineText(notification.declineTextOverride)
    end
    table.insert(containerData.notificationsChoice, elementData.entity)
  end
  local contextElement = self.registrar:GetEntityTable(notification.contextId)
  if contextElement then
    elementData.entity:SetCallback(contextElement, notification.callbackName)
  end
  if type(elementData.entity.ApplyCustomTypeSettings) == "function" then
    elementData.entity:ApplyCustomTypeSettings(notification.type)
  end
  elementData.entity:SetUUID(notification.uuid)
  elementData.entity:SetDuration(notification.maximumDuration, notification.showProgress, notification.declineOnTimeout)
  elementData.entity:SetNotificationManager(self)
  elementData.entity:ShowTransitionIn()
end
function Notifications:ShowNotification(containerData, notification)
  if notification.hasChoice and (not notification.callbackName or notification.callbackName == "" or not notification.contextId) then
    Debug.Log("[Notifications.lua] choice notifications must include a callbackName and contextId reference")
    return
  end
  local isMinorNotification = notification.type == "Minor" or notification.type == "Subtitle"
  local notificationPool = self.notificationPools.Generic
  local notificationContainer = self.DefaultContainer
  local centered = self:IsCenterType(notification.type)
  if centered then
    notificationPool = self.notificationPools.Center
    notificationContainer = self.CenterContainer
  elseif notification.hasChoice then
    notificationPool = self.notificationPools.Choice
  elseif notification.type == "Guild" or notification.type == "WarSingle" then
    notificationPool = self.notificationPools.Guild
  elseif isMinorNotification then
    notificationPool = self.notificationPools.Minor
    notificationContainer = self.MinorContainer
  end
  local availableIndex
  for index, elementData in ipairs(notificationPool) do
    if elementData.entity and not elementData.isShown then
      availableIndex = index
      break
    end
  end
  if availableIndex then
    local availableElement = notificationPool[availableIndex]
    availableElement.isShown = true
    containerData.timeSinceNotification = 0
    containerData.visibleCount = containerData.visibleCount + 1
    self:SetNotificationElement(availableElement, notification)
    UiElementBus.Event.Reparent(availableElement.entity.entityId, notificationContainer, EntityId())
    if notification.pushNotificationToChat then
      self:SendChatNotification(notification)
    end
    DynamicBus.Banner.Broadcast.OnNotificationShowing(centered)
  end
  self:BroadcastNotificationCountChanged()
end
local chatMessage = BaseGameChatMessage()
chatMessage.type = eChatMessageType_System
function Notifications:SendChatNotification(notification)
  chatMessage.body = notification.text
  ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
end
function Notifications:RemoveVisibleNotification(containerName, notificationId, poolType)
  local containerData = self[containerName]
  if containerData then
    local notificationData = containerData.notificationsVisible[tostring(notificationId)]
    if notificationData then
      local notificationPool = self.notificationPools[poolType]
      local notificationElementData = notificationPool[notificationData.itemIndex]
      local centered = self:IsCenterType(notificationData.notification.type)
      if notificationElementData then
        if notificationData.notification.hasChoice then
          self:RemoveChoiceNotification(containerData, notificationData.entity.entityId)
        end
        if notificationData.entity.ResetSettings then
          notificationData.entity:ResetSettings()
        end
        notificationData.itemIndex = nil
        notificationElementData.isShown = false
        containerData.notificationsVisible[tostring(notificationId)] = nil
        containerData.visibleCount = containerData.visibleCount - 1
        UiElementBus.Event.Reparent(notificationElementData.entity.entityId, self.DisabledContainer, EntityId())
        DynamicBus.Banner.Broadcast.OnNotificationHidden(centered)
      end
    end
  end
  self:BroadcastNotificationCountChanged()
end
function Notifications:ConfigureVisibleNotification(entity, notificationData)
  if entity and notificationData then
    if entity.SetType then
      entity:SetType(notificationData.type)
    end
    if entity.SetTitle and notificationData.title then
      entity:SetTitle(notificationData.title)
    end
    if entity.SetIcon then
      if self:IsCenterType(notificationData.type) and notificationData.icon ~= "" then
        entity:SetIcon(notificationData.icon)
      elseif notificationData.guildCrest and notificationData.guildCrest:IsValid() then
        entity:SetIcon(notificationData.guildCrest)
      elseif notificationData.icon and notificationData.icon ~= "" then
        entity:SetIcon(notificationData.icon)
      end
    end
    if entity.SetMessage then
      entity:SetMessage(notificationData.text)
    end
    if entity.SetAcceptText and notificationData.acceptTextOverride and notificationData.acceptTextOverride ~= "" then
      entity:SetAcceptText(notificationData.acceptTextOverride)
    end
    if entity.SetDeclineText and notificationData.declineTextOverride and notificationData.declineTextOverride ~= "" then
      entity:SetDeclineText(notificationData.declineTextOverride)
    end
    if entity.SetCanAccept then
      entity:SetCanAccept(notificationData.canAccept)
    end
  end
end
function Notifications:IsCenterType(type)
  return self.centerTypes[type] ~= nil
end
function Notifications:BroadcastNotificationCountChanged()
  local totalHeight = 0
  local children = UiElementBus.Event.GetChildren(self.Properties.DefaultContainer)
  for i = #children, 1, -1 do
    self.ScriptedEntityTweener:Play(children[i], 0.6, {y = totalHeight, ease = "QuadOut"})
    local childHeight = UiTransform2dBus.Event.GetLocalHeight(children[i])
    totalHeight = totalHeight + childHeight
  end
  totalHeight = totalHeight + UiTransformBus.Event.GetLocalPositionY(self.Properties.DefaultContainer) + self.defaultNotificationSpacing
  DynamicBus.NotificationsDisplayBus.Broadcast.OnNotificationCountChanged(self.DefaultData.visibleCount, totalHeight)
end
function Notifications:OnDeathsDoorChanged(isInDeathsDoor, timeRemaining, deathsDoorCooldownRemaining)
  local isInfiniteDeathsDoor = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.IsInfiniteDeathsDoor")
  if not isInfiniteDeathsDoor and not isInDeathsDoor and self.isInDeathsDoor == true and 0 < deathsDoorCooldownRemaining then
    self.deathsDoorTriggered = true
    self.deathsDoorNotificationQueued = false
    self.deathsDoorTimeRemaining = deathsDoorCooldownRemaining
  end
  self.isInDeathsDoor = isInDeathsDoor
end
function Notifications:OnRespawn()
  local vitalsEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.VitalsEntityId")
  self.deathsDoorTimeRemaining = vitalsEntityId and VitalsComponentRequestBus.Event.GetDeathsDoorCooldown(vitalsEntityId) or 0
end
function Notifications:TickDeathsDoorCooldown(deltaTime)
  if self.deathsDoorTriggered then
    local prevTime = self.deathsDoorTimeRemaining or 0
    self.deathsDoorTimeRemaining = self.deathsDoorTimeRemaining - deltaTime
    local currentTime = self.deathsDoorTimeRemaining
    if self.deathsDoorNotificationQueued == false then
      local playerHealth = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.HealthPercent")
      local isAlive = 0 < playerHealth
      if isAlive == true and self.deathsDoorTimeRemaining > 0 then
        local timeRemainingText = timeHelpers:ConvertToVerboseDurationString(self.deathsDoorTimeRemaining)
        local notificationData = NotificationData()
        notificationData.type = "Social"
        notificationData.icon = self.deathsDoorNotificationImagePath
        notificationData.title = "@ui_deathsdoorcooldown"
        notificationData.text = "@ui_deathsdoorcooldown_description " .. timeRemainingText
        notificationData.maximumDuration = 10
        self.deathsDoorCooldownNotificationId = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        self.deathsDoorNotificationQueued = true
      end
    end
    if self.deathsDoorTimeRemaining <= 0 then
      self.deathsDoorTriggered = false
      self.deathsDoorCooldownNotificationId = nil
      local notificationData = NotificationData()
      notificationData.type = "Social"
      notificationData.title = "@ui_canberevived"
      notificationData.text = "@ui_canberevived_text"
      notificationData.maximumDuration = 3
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    elseif self.deathsDoorCooldownNotificationId then
      local timeRemaining = self.deathsDoorTimeRemaining
      local timeRemainingText = timeHelpers:ConvertToVerboseDurationString(timeRemaining)
      local notificationData = {
        text = "@ui_deathsdoorcooldown_description " .. timeRemainingText
      }
      if self:UpdateNotification(self.deathsDoorCooldownNotificationId, notificationData) == false then
        self.deathsDoorCooldownNotificationId = nil
      end
    end
  end
end
function Notifications:OnPreRaidStatusChanged(status, warId)
  local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
  local isInvasion = warDetails:IsInvasion()
  self.lastPreRaidStatus = status
  local notificationTitle = ""
  local notificationText = ""
  if status == ePreRaidStatus_Selected then
    notificationTitle = isInvasion and "@ui_invasionselected_title" or "@ui_warselected_title"
    notificationText = isInvasion and "@ui_invasionselected_text" or "@ui_warselected_text"
  elseif status == ePreRaidStatus_Unselected then
    notificationTitle = isInvasion and "@ui_invasionunselected_title" or "@ui_warunselected_title"
    notificationText = isInvasion and "@ui_invasionunselected_text" or "@ui_warunselected_text"
  else
    return
  end
  local siegeStartTime = warDetails:GetConquestStartTime():Subtract(WallClockTimePoint()):ToSecondsRoundedUp()
  local notificationData = NotificationData()
  notificationData.title = notificationTitle
  notificationData.text = GetLocalizedReplacementText(notificationText, {
    territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(warDetails:GetTerritoryId()),
    startTime = timeHelpers:GetLocalizedServerTime(siegeStartTime),
    endTime = timeHelpers:GetLocalizedServerTime(siegeStartTime + dominionCommon:GetSiegeDuration())
  })
  notificationData.icon = self.warNotificationImagePath
  notificationData.maximumDuration = 5
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function Notifications:OnSignupStatusChanged(territoryId, signupStatus)
  if not self.lastPreRaidStatus or self.lastPreRaidStatus ~= ePreRaidStatus_PermissionPromoted and self.lastPreRaidStatus ~= ePreRaidStatus_PermissionDemoted then
    return
  end
  local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(territoryId)
  if not warDetails then
    return
  end
  if warDetails:GetWarPhase() == eWarPhase_Resolution or warDetails:GetWarPhase() == eWarPhase_Complete then
    return
  end
  local isInvasion = warDetails:IsInvasion()
  local notificationTitle = isInvasion and "@ui_invasionpermissionchange_title" or "@ui_warpermissionchange_title"
  local rankName = ""
  if signupStatus.permission == eRaidPermission_Normal then
    rankName = "@ui_raidpermission_normal"
  elseif signupStatus.permission == eRaidPermission_Assistant then
    rankName = "@ui_raidpermission_assistant"
  elseif signupStatus.permission == eRaidPermission_Leader then
    rankName = "@ui_raidpermission_leader"
  end
  local notificationText = ""
  if self.lastPreRaidStatus == ePreRaidStatus_PermissionPromoted then
    notificationText = isInvasion and "@ui_invasionpermissionpromoted_text" or "@ui_warpermissionpromoted_text"
  else
    notificationText = isInvasion and "@ui_invasionpermissiondemoted_text" or "@ui_warpermissiondemoted_text"
  end
  local notificationData = NotificationData()
  notificationData.title = notificationTitle
  notificationData.text = GetLocalizedReplacementText(notificationText, {
    rank = rankName,
    territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
  })
  notificationData.icon = self.warNotificationImagePath
  notificationData.maximumDuration = 5
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function Notifications:OnWarDeclarationPending(defendingGuildId, territoryId)
  local notificationData = NotificationData()
  notificationData.type = "Social"
  notificationData.title = "@ui_wardeclaration_pending_notification_title"
  notificationData.text = "@ui_wardeclaration_pending_notification_text"
  notificationData.maximumDuration = 10
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function Notifications:OnWarDeclarationUnsuccessful(defendingGuildId, territoryId)
  local notificationData = NotificationData()
  notificationData.type = "Social"
  notificationData.title = "@ui_wardeclaration_unsuccessful_notification_title"
  notificationData.text = "@ui_wardeclaration_unsuccessful_notification_text"
  notificationData.maximumDuration = 10
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function Notifications:OnWarDeclarationSuccessful(warId)
  local notificationData = NotificationData()
  notificationData.type = "Social"
  notificationData.title = "@ui_wardeclaration_successful_notification_title"
  notificationData.text = "@ui_wardeclaration_successful_notification_text"
  notificationData.maximumDuration = 10
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function Notifications:OnTeleportImminent(secondsToTeleport)
  local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.territoryId)
  if warDetails and warDetails:IsValid() and warDetails:GetWarPhase() == eWarPhase_PreWar then
    local signupStatus = RaidSetupRequestBus.Broadcast.GetSignupStatus(self.territoryId)
    if signupStatus and signupStatus.selected then
      return
    end
    self.secondsToTeleport = secondsToTeleport
    local notificationData = NotificationData()
    notificationData.type = "Social"
    notificationData.title = "@ui_notification_teleport_title"
    notificationData.text = "@ui_notification_teleport_text"
    notificationData.maximumDuration = secondsToTeleport
    notificationData.showProgress = true
    self.teleportNotificationId = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function Notifications:OnLeftTeleportArea()
  if self.teleportNotificationId then
    UiNotificationsBus.Broadcast.RescindNotification(self.teleportNotificationId, true, true)
    self.teleportNotificationId = nil
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_notification_left_teleport_area"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function Notifications:TickTeleportTimer(deltaTime)
  if self.teleportNotificationId and self.secondsToTeleport > 0 then
    self.secondsToTeleport = self.secondsToTeleport - deltaTime
  end
  if self.timeToCheckWarTeleport and 0 < self.timeToCheckWarTeleport then
    self.teleportTimer = self.teleportTimer - deltaTime
    if 0 >= self.teleportTimer then
      self.teleportTimer = self.teleportTimer + self.TIME_BETWEEN_TELEPORT_CHECKS
      self.timeToCheckWarTeleport = self.timeToCheckWarTeleport - self.TIME_BETWEEN_TELEPORT_CHECKS
      local playerPosition = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Position")
      if TerritoryComponentRequestBus.Event.IsOnWarGrid(self.territoryEntityId, playerPosition) then
        if not self.teleportNotificationId then
          self:OnTeleportImminent(remainingTime)
        end
      else
        self:OnLeftTeleportArea()
      end
    end
  end
end
function Notifications:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.entityId, self.canvasId)
  end
end
function Notifications:OnInviteFailed(reason)
  genericInviteCommon:HandleInviteFailed(reason)
end
function Notifications:AdjustNotificationYPos(newYpos)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.DefaultContainer, newYpos)
end
function Notifications:ResetYPos()
  UiTransformBus.Event.SetLocalPositionY(self.Properties.DefaultContainer, self.defaultContainerYPos)
end
return Notifications
