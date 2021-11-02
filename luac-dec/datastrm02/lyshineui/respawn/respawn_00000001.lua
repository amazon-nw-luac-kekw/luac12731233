local RespawnScreen = {
  Properties = {
    KilledByContainer = {
      default = EntityId()
    },
    KilledByTitle = {
      default = EntityId()
    },
    KilledByName = {
      default = EntityId()
    },
    KilledByMask = {
      default = EntityId()
    },
    KilledByNameTweenValue = {
      default = EntityId()
    },
    KilledByLine1 = {
      default = EntityId()
    },
    KilledByLine2 = {
      default = EntityId()
    },
    TwitchViewersHolder = {
      default = EntityId()
    },
    TwitchViewersTitle = {
      default = EntityId()
    },
    TwitchViewersNumber = {
      default = EntityId()
    },
    TwitchViewersIcon = {
      default = EntityId()
    },
    RespawnTimerHolder = {
      default = EntityId()
    },
    RespawnTimerPrimaryTitle = {
      default = EntityId()
    },
    RespawnTimerSecondaryTitle = {
      default = EntityId()
    },
    RespawnTimer = {
      default = EntityId()
    },
    RespawnMapHolder = {
      default = EntityId()
    },
    RespawnMapTitle = {
      default = EntityId()
    },
    RespawnMapLine = {
      default = EntityId()
    },
    RespawnMapButtonAccept = {
      default = EntityId()
    },
    SpectateMapButtonAccept = {
      default = EntityId()
    },
    RespawnMapListHolder = {
      default = EntityId()
    },
    RespawnMapListItemClone = {
      default = EntityId()
    },
    MapElement = {
      default = EntityId()
    },
    RespawnMapListContent = {
      default = EntityId()
    },
    RespawnFtueHolder = {
      default = EntityId()
    },
    RespawnFtueButtonAccept = {
      default = EntityId()
    },
    RespawnFtueMessage = {
      default = EntityId()
    },
    StatHolder = {
      default = EntityId()
    },
    StatHolderLine = {
      default = EntityId()
    },
    StatRowClone = {
      default = EntityId()
    },
    VerticalDivider = {
      default = EntityId()
    },
    Scrollbox = {
      default = EntityId()
    },
    MainBg = {
      default = EntityId()
    },
    Vignette = {
      default = EntityId()
    },
    BlueFadeCornerBg = {
      default = EntityId()
    },
    RespawnSpinner = {
      default = EntityId()
    },
    SpectateSpinner = {
      default = EntityId()
    },
    DroppedItemsContainer = {
      default = EntityId()
    },
    DroppedItemsNotInUse = {
      default = EntityId()
    },
    DroppedItemTitle = {
      default = EntityId()
    },
    DroppedItems = {
      default = {
        EntityId()
      }
    },
    DurabilityLossInformation = {
      default = EntityId()
    }
  },
  timeToRespawn = 0,
  isDead = false,
  deathPosition = Vector3(0, 0, 0),
  tickBusHandler = nil,
  uiPlayerHomeComponentBusHandler = nil,
  hasDeathData = nil,
  isTimeToRespawnDataSet = nil,
  isDeadDataSet = nil,
  isTwitchStreamer = nil,
  twitchIconPath = "lyshineui/images/icons/twitch/iconTwitchPurpleBg.png",
  isDebug = false,
  isInDungeon = false,
  isInOutpostRush = false,
  outpostRushMatchEnded = false,
  isInSiegeWar = false,
  siegeWarMatchEnded = false,
  isSpectating = false,
  waitingToSpectate = false,
  checkingIfCanSpectate = false,
  checkIfCanSpectateTimer = 0,
  checkIfCanSpectateInterval = 1,
  waitingToSpectateTimer = 0,
  waitingToSpectateTimeout = 10,
  localPlayerUIRequestsBusHandler = nil,
  loadingScreenHandler = nil,
  isFtue = false,
  itemDroppedIndex = 0
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(RespawnScreen)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(RespawnScreen)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local territoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function RespawnScreen:OnInit()
  BaseScreen.OnInit(self)
  self.statRowsElements = {}
  self.cryHandlers = {}
  self.respawnListItemElements = {}
  self.cooldownObservers = {}
  self.audioHelper = RequireScript("LyShineUI.AudioEvents")
  self.selectedHomeId = ""
  self.tickBusHandler = nil
  self.waitingToShowRespawnScreen = false
  self.waitingToSpectate = false
  self.waitingToSpectateTimer = 0
  DynamicBus.RespawnScreen.Connect(self.entityId, self)
  local isLoadingScreenShowing = LoadScreenBus.Broadcast.IsLoadingScreenShown()
  if isLoadingScreenShowing then
    self.isFirstLoad = true
    self.loadingScreenHandler = self:BusConnect(LoadScreenNotificationBus, self.entityId)
  end
  self.cryactionsToFunctions = {
    ui_cancel = function()
      if LyShineManagerBus.Broadcast.IsInState(3326371288) then
        LyShineManagerBus.Broadcast.ToggleState(3326371288)
      else
        LyShineManagerBus.Broadcast.ToggleState(921475099)
      end
    end,
    ui_start_pause = function()
      LyShineManagerBus.Broadcast.ToggleState(3326371288)
    end
  }
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    self.randomRespawnLocStr = "@ui_mudflats_location"
    UiElementBus.Event.SetIsEnabled(self.Properties.StatHolderLine, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.VerticalDivider, false)
  else
    self.randomRespawnLocStr = "@ui_random_location"
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
      if rootPlayerId then
        self.rootPlayerId = rootPlayerId
        if GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(self.rootPlayerId) ~= 0 then
          self.randomRespawnLocStr = "@ui_dungeon_entrance_respawn_location"
        end
      end
    end)
    UiElementBus.Event.SetIsEnabled(self.Properties.StatHolderLine, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.VerticalDivider, true)
  end
  self.respawnTypesWithCooldownTrigger = {
    Home = true,
    Inn = true,
    Dungeon = true
  }
  local statRowsToCache = 3
  for i = 1, statRowsToCache do
    self:GetStatRowEntity()
  end
  self:HideStatClones()
  self:SetVisualElements()
  self:SetScreenVisible(false)
  self:SetRespawnMapVisible(false)
  if self.isDebug then
    self:SetScreenVisible(true)
  end
  if self.uiLoaderHandler then
    DynamicBus.UiLoader.Disconnect(self.entityId, self)
  end
  self.uiLoaderHandler = DynamicBus.UiLoader.Connect(self.entityId, self)
  self.localPlayerUIRequestsBusHandler = self:BusConnect(LocalPlayerEventsBus)
  self:BusConnect(GroupsUINotificationBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      if self.vitalsNotificationHandler then
        self:BusDisconnect(self.vitalsNotificationHandler)
      end
      self.vitalsNotificationHandler = self:BusConnect(VitalsComponentNotificationBus, rootEntityId)
      self.participantBusHandler = self:BusConnect(GameModeParticipantComponentNotificationBus, rootEntityId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.uiPlayerHomeComponentBusHandler = self:BusConnect(UiPlayerHomeComponentNotificationsBus, playerEntityId)
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.OnRevived", function(self, playerEntityId)
    if UiCanvasBus.Event.GetEnabled(self.canvasId) then
      self:OnLoadingScreenShown()
    else
      self:ResetDeathDataFlags()
    end
  end)
  for i = 0, #self.DroppedItems do
    self.DroppedItems[i]:SetTooltipEnabled(true)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Siege.SiegePhase", function(self, isInSiege)
    self.isInWarSiegePhase = isInSiege
  end)
end
function RespawnScreen:SetScreenData()
  if self.isInOutpostRush and self.outpostRushMatchEnded then
    return
  end
  if self.isInSiegeWar and self.siegeWarMatchEnded then
    return
  end
  UiTextBus.Event.SetText(self.RespawnTimer, string.format(":%02.f", self.timeToRespawn))
  self.waitingToShowRespawnScreen = self.timeToRespawn > 0
  if self.waitingToShowRespawnScreen then
    self:SetIsTicking(true)
  end
  if self.isDead then
    self:SetRespawnList()
    LyShineManagerBus.Broadcast.QueueState(3901667439)
    if not self.hasDeathData then
      self:OnDeathRecap()
    end
    if self.waitingToShowRespawnScreen then
      self:SetScreenVisible(true)
      self:SetRespawnMapVisible(false)
    else
      self:SetScreenVisible(false)
      self:SetRespawnMapVisible(true)
    end
    if #self.cryHandlers == 0 then
      for cryAction, _ in pairs(self.cryactionsToFunctions) do
        table.insert(self.cryHandlers, self:BusConnect(CryActionNotificationsBus, cryAction))
      end
    end
    local isSpectatorEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-spectator") and not FtueSystemRequestBus.Broadcast.IsFtue()
    self:SetSpectateButtonVisible(isSpectatorEnabled)
    if isSpectatorEnabled then
      self.checkingIfCanSpectate = true
      self:SetIsTicking(true)
    end
    local text = "@ui_item_durability_loss"
    if self.isInOutpostRush then
      text = "@ui_durability_loss_outpost_rush"
    elseif self.isInWarSiegePhase then
      text = "@ui_durability_loss_war"
    elseif self.isKilledByPlayerInPvP then
      text = "@ui_item_durability_loss_pvp"
    else
      text = "@ui_item_durability_loss"
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.DurabilityLossInformation, text, eUiTextSet_SetLocalized)
  end
end
function RespawnScreen:SetIsTicking(isEnabled)
  if isEnabled then
    if self.tickBusHandler == nil then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  elseif self.tickBusHandler ~= nil then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function RespawnScreen:SetVisualElements()
  local killedByTitleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 32,
    fontColor = self.UIStyle.COLOR_WHITE,
    characterSpacing = 550
  }
  local killedByNameStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = self.UIStyle.FONT_SIZE_DEATH_TITLE_PRIMARY,
    fontColor = self.UIStyle.COLOR_RED_DARK,
    characterSpacing = 180
  }
  local twitchViewersNumberStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 55,
    fontColor = self.UIStyle.COLOR_WHITE,
    characterSpacing = 100
  }
  local respawnPrimaryTitleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 24,
    fontColor = self.UIStyle.COLOR_TAN,
    characterSpacing = 100
  }
  local respawnTimerStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_CASLON,
    fontSize = 88,
    fontColor = self.UIStyle.COLOR_WHITE
  }
  SetTextStyle(self.KilledByTitle, killedByTitleStyle)
  SetTextStyle(self.KilledByName, killedByNameStyle)
  SetTextStyle(self.TwitchViewersTitle, self.UIStyle.FONT_STYLE_DEATH_STAT_LABEL_GRAY)
  SetTextStyle(self.TwitchViewersNumber, twitchViewersNumberStyle)
  SetTextStyle(self.RespawnMapTitle, self.UIStyle.FONT_STYLE_DEATH_STAT_LABEL_TAN)
  SetTextStyle(self.RespawnTimerPrimaryTitle, respawnPrimaryTitleStyle)
  SetTextStyle(self.RespawnTimer, respawnTimerStyle)
  UiTextBus.Event.SetTextWithFlags(self.TwitchViewersTitle, "@ui_viewers_watched", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.RespawnTimerPrimaryTitle, "@ui_respawn_available_in", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.RespawnMapTitle, "@ui_deathrecap_respawn_points", eUiTextSet_SetLocalized)
  self.TwitchViewersIcon:SetIcon(self.twitchIconPath)
  local textElementWidth = UiTransform2dBus.Event.GetLocalWidth(self.TwitchViewersNumber)
  local textWidth = UiTextBus.Event.GetTextWidth(self.TwitchViewersNumber)
  local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.TwitchViewersIcon.entityId)
  local iconSpacing = 15
  local offsetOverallPosX = iconWidth / 2
  local offsetIconPosX = (textElementWidth - textWidth) / 2 - (iconWidth + iconSpacing)
  self.ScriptedEntityTweener:Set(self.TwitchViewersIcon.entityId, {
    x = offsetIconPosX + offsetOverallPosX
  })
  self.ScriptedEntityTweener:Set(self.TwitchViewersNumber, {x = offsetOverallPosX})
  self.RespawnMapButtonAccept:SetText("@ui_respawn")
  self.RespawnMapButtonAccept:SetSoundOnPress(self.audioHelper.OnRespawn)
  self.RespawnMapButtonAccept:SetCallback(self.OnRespawnButtonPressed, self)
  self.RespawnMapButtonAccept:SetButtonStyle(self.RespawnMapButtonAccept.BUTTON_STYLE_HERO)
  self.RespawnMapButtonAccept:StartStopImageSequence(true)
  self.SpectateMapButtonAccept:SetText("@ui_spectate")
  self.SpectateMapButtonAccept:SetTextCasing(self.UIStyle.TEXT_CASING_UPPER)
  self.SpectateMapButtonAccept:SetFontSize(46)
  self.SpectateMapButtonAccept:SetSoundOnPress(self.audioHelper.OnRespawn)
  self.SpectateMapButtonAccept:SetCallback(self.OnSpectate, self)
  if self.isFtue then
    local respawnFtueMessageStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_PICA,
      fontSize = 38
    }
    SetTextStyle(self.RespawnFtueMessage, respawnFtueMessageStyle)
    UiTextBus.Event.SetTextWithFlags(self.RespawnFtueMessage, "@ftue_respawn_message", eUiTextSet_SetLocalized)
    self.RespawnFtueButtonAccept:SetText("@ui_respawn")
    self.RespawnFtueButtonAccept:SetTextCasing(self.UIStyle.TEXT_CASING_UPPER)
    self.RespawnFtueButtonAccept:SetFontSize(46)
    self.RespawnFtueButtonAccept:SetSoundOnPress(self.audioHelper.OnRespawn)
    self.RespawnFtueButtonAccept:SetCallback(self.OnRespawnButtonPressed, self)
  end
end
function RespawnScreen:SetScreenVisible(isVisible)
  local initialDelay = 0
  if self.isDebug then
    initialDelay = 0.5
    self:SetDebugData()
  end
  if isVisible then
    self.ScriptedEntityTweener:Set(self.KilledByContainer, {opacity = 1})
    self.ScriptedEntityTweener:Play(self.KilledByMask, 4, {scaleX = 0}, {
      scaleX = 1,
      ease = "QuadOut",
      delay = initialDelay
    })
    local durationLetterSpacing = 4.5
    self.ScriptedEntityTweener:Play(self.KilledByName, 2, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = initialDelay + 1.6
    })
    self.ScriptedEntityTweener:Play(self.KilledByName, durationLetterSpacing, {textCharacterSpace = 100}, {
      textCharacterSpace = 400,
      ease = "QuadOut",
      delay = initialDelay + 1.6
    })
    self.ScriptedEntityTweener:Play(self.KilledByLine1, 1.5, {scaleX = 0}, {
      scaleX = 1,
      ease = "QuadOut",
      delay = initialDelay + 0.55
    })
    self.ScriptedEntityTweener:Play(self.KilledByLine1, 2, {opacity = 0}, {
      opacity = 0.8,
      ease = "QuadOut",
      delay = initialDelay + 0.55
    })
    self.ScriptedEntityTweener:Play(self.KilledByLine2, 1.5, {scaleX = 0}, {
      scaleX = 1,
      ease = "QuadOut",
      delay = initialDelay + 1.5
    })
    self.ScriptedEntityTweener:Play(self.KilledByLine2, 2, {opacity = 0}, {
      opacity = 0.8,
      ease = "QuadOut",
      delay = initialDelay + 1.5
    })
    if self.isTwitchStreamer then
      self.ScriptedEntityTweener:Play(self.TwitchViewersHolder, 1.5, {opacity = 0}, {
        opacity = 1,
        ease = "QuadOut",
        delay = initialDelay + 3
      })
    else
      self.ScriptedEntityTweener:Set(self.TwitchViewersHolder, {opacity = 0})
    end
    self.ScriptedEntityTweener:Play(self.RespawnTimerHolder, 1.5, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = initialDelay + 3
    })
    if self.isDebug then
      self.ScriptedEntityTweener:Play(self.Vignette, 5, {scaleX = 1.25, scaleY = 1.25}, {
        scaleX = 1,
        scaleY = 1,
        ease = "QuadOut",
        delay = initialDelay + 0.65,
        onComplete = function()
          self:SetRespawnMapVisible(true)
        end
      })
      self.ScriptedEntityTweener:Play(self.Vignette, 8, {opacity = 0}, {
        opacity = 0.8,
        ease = "QuadOut",
        delay = initialDelay + 0.65
      })
    else
      self.ScriptedEntityTweener:Play(self.Vignette, 5, {scaleX = 1.25, scaleY = 1.25}, {
        scaleX = 1,
        scaleY = 1,
        ease = "QuadOut",
        delay = initialDelay + 0.65
      })
      self.ScriptedEntityTweener:Play(self.Vignette, 8, {opacity = 0}, {
        opacity = 0.8,
        ease = "QuadOut",
        delay = initialDelay + 0.65
      })
    end
  else
    self.ScriptedEntityTweener:Stop(self.TwitchViewersHolder, {opacity = 0})
    self.ScriptedEntityTweener:Stop(self.KilledByMask, {opacity = 0})
    self.ScriptedEntityTweener:Stop(self.KilledByLine1, {opacity = 0})
    self.ScriptedEntityTweener:Stop(self.KilledByLine2, {opacity = 0})
    self.ScriptedEntityTweener:Stop(self.RespawnTimerHolder, {opacity = 0})
    self.ScriptedEntityTweener:Stop(self.KilledByName, {opacity = 0})
    self.ScriptedEntityTweener:Stop(self.Vignette, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.TwitchViewersHolder, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.KilledByMask, {scaleX = 0})
    self.ScriptedEntityTweener:Set(self.KilledByLine1, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.KilledByLine2, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.RespawnTimerHolder, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.KilledByName, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Vignette, {opacity = 0})
  end
end
function RespawnScreen:SetRespawnMapVisible(isVisible)
  local initialDelay = 0.5
  if isVisible == true then
    self.MapElement:SetGradient(0.5)
    local localPlayerRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
    local isInRaid = localPlayerRaidId ~= nil and localPlayerRaidId:IsValid()
    if isInRaid then
      if not self.zoomedInForWar then
        self.MapElement:SetZoom(1, true)
        self.MapElement:CenterToPosition(self.deathPosition, true)
        self.zoomedInForWar = true
      end
    elseif self.zoomedInForWar then
      self.MapElement:SetZoom(4, true)
      self.MapElement:CenterToPosition(self.deathPosition, true)
      self.zoomedInForWar = false
    end
    if self.isInDungeon then
      if not self.zoomedInForDungeon then
        self.MapElement:SetZoom(2, true)
        self.MapElement:CenterToPosition(self.deathPosition, true)
        self.zoomedInForDungeon = true
      end
    elseif self.zoomedInForDungeon then
      self.MapElement:SetZoom(4, true)
      self.MapElement:CenterToPosition(self.deathPosition, true)
      self.zoomedInForDungeon = false
    end
    self.ScriptedEntityTweener:Play(self.RespawnTimerHolder, 1, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Vignette, 1, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.KilledByContainer, 1, {opacity = 0, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.MainBg, 1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Set(self.Properties.BlueFadeCornerBg, {opacity = 0})
    self.ScriptedEntityTweener:Play(self.Properties.BlueFadeCornerBg, 2, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = initialDelay * 2
    })
    self.ScriptedEntityTweener:Set(self.StatHolder, {opacity = 1})
    self.StatHolderLine:SetVisible(true, 2)
    self.StatHolderLine:SetColor(self.UIStyle.COLOR_TAN)
    self.VerticalDivider:SetVisible(true, 2)
    self.VerticalDivider:SetColor(self.UIStyle.COLOR_TAN)
    local animDelay = 0.5
    local animDuration = 1.8
    local offsetPosX = 350
    for i = 1, #self.statRowsElements do
      if not self.statRowsElements[i].isCached then
        local currentItem = self.statRowsElements[i].entityId
        local initPosX = self.statRowsElements[i].initPosX
        UiElementBus.Event.SetIsEnabled(currentItem, true)
        self.ScriptedEntityTweener:Play(currentItem, 1.5, {opacity = 0}, {
          opacity = 1,
          ease = "QuadOut",
          delay = initialDelay + animDelay * i
        })
        if i ~= #self.statRowsElements then
          self.ScriptedEntityTweener:Play(currentItem, animDuration, {
            x = initPosX + offsetPosX
          }, {
            x = initPosX,
            ease = "QuadOut",
            delay = initialDelay
          })
        end
      end
    end
    self.ScriptedEntityTweener:Play(self.Properties.DurabilityLossInformation, 1.5, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = initialDelay * 2
    })
    local mapDelay = 0.4
    local elementToShow = self.RespawnMapHolder
    if self.isFtue then
      elementToShow = self.RespawnFtueHolder
    end
    UiElementBus.Event.SetIsEnabled(elementToShow, true)
    self.ScriptedEntityTweener:Play(elementToShow, 2, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = initialDelay + mapDelay
    })
    self.audioHelper:PlaySound(self.audioHelper.Screen_RespawnOpen)
    self.audioHelper:onUIStateChanged(self.audioHelper.UIState_RespawnScreen)
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_RespawnScreen)
  else
    self.ScriptedEntityTweener:Set(self.Properties.BlueFadeCornerBg, {opacity = 0})
    self.ScriptedEntityTweener:Stop(self.MainBg)
    self.ScriptedEntityTweener:Stop(self.RespawnMapHolder)
    self.ScriptedEntityTweener:Set(self.MainBg, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.StatHolder, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.RespawnMapHolder, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.DurabilityLossInformation, {opacity = 0})
    for i = 1, #self.statRowsElements do
      if not self.statRowsElements[i].isCached then
        local currentItem = self.statRowsElements[i].entityId
        local initPosX = self.statRowsElements[i].initPosX
        self.ScriptedEntityTweener:Stop(currentItem)
        self.ScriptedEntityTweener:Set(currentItem, {opacity = 0, x = initPosX})
      end
    end
    UiElementBus.Event.SetIsEnabled(self.RespawnMapHolder, false)
    UiElementBus.Event.SetIsEnabled(self.RespawnFtueHolder, false)
  end
  self.MapElement:SetIsVisible(isVisible)
  self.MapElement:SetZoomEnabled(false)
end
function RespawnScreen:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if fromState == 4143822268 then
    self.isSpectating = false
    return
  end
  self.MapElement.MarkersLayer:SetRespondingToDataUpdates(true)
  self.MapElement.MarkersLayer:SetIsVisible(true)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Position", function(self, position)
    if not position then
      return
    end
    if self.deathPosition:GetDistanceSq(position) > 20 then
      self.deathPosition = position
      self.MapElement:CenterToPosition(self.deathPosition, true)
      self:SetRespawnList()
    end
  end)
  self.dataLayer:RegisterObserver(self, "Hud.LocalPlayer.HomePoints.Count", self.OnHomePointsCountChanged)
  self.dataLayer:RegisterDataCallback(self, "Hud.Housing.NumOwnedHouses", self.OnHomePointsCountChanged)
  if not toState == 3901667439 then
    self:SetRespawnButtonVisible(false)
  end
end
function RespawnScreen:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if not self.selfRequestingExit and toState ~= 849925872 then
    Debug.Log("ERROR - Some other UI tried to close the respawn screen, stack = " .. debug.traceback())
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
    LyShineManagerBus.Broadcast.TransitionOutComplete()
    LyShineManagerBus.Broadcast.QueueState(3901667439)
    return
  end
  self.selfRequestingExit = nil
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Position")
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.HomePoints.Count")
  self.dataLayer:UnregisterObserver(self, "Hud.Housing.NumOwnedHouses")
  self:ResetMapButtons()
  self.StatHolderLine:SetVisible(false)
  self.VerticalDivider:SetVisible(false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if toState == 4143822268 then
    self.isSpectating = true
    return
  end
  self:UnregisterCooldownObservers()
  self.MapElement.MarkersLayer:SetRespondingToDataUpdates(false)
  self.MapElement.MarkersLayer:SetIsVisible(false)
  self:HideStatClones()
  self:SetScreenVisible(false)
  self:SetRespawnMapVisible(false)
  if self.spectatorBusHandler ~= nil then
    self.spectatorBusHandler:Disconnect()
    self.spectatorBusHandler = nil
  end
  for _, handler in pairs(self.cryHandlers) do
    self:BusDisconnect(handler)
  end
  ClearTable(self.cryHandlers)
  self:SetIsTicking(false)
end
function RespawnScreen:SetRespawnListSize(count)
  local childList = UiElementBus.Event.GetChildren(self.Properties.RespawnMapListHolder)
  for i = 1, #childList do
    UiElementBus.Event.SetIsEnabled(childList[i], i <= count)
  end
  ClearTable(self.respawnListItemElements)
end
function RespawnScreen:ResetDeathDataFlags()
  self.isTimeToRespawnDataSet = nil
  self.isDeadDataSet = nil
  self.isDead = nil
  self.timeToRespawn = nil
end
function RespawnScreen:OnTick(deltaTime, timePoint)
  if self.waitingToShowRespawnScreen then
    local prevtime = math.ceil(self.timeToRespawn)
    self.timeToRespawn = self.timeToRespawn - deltaTime
    local curtime = math.ceil(self.timeToRespawn)
    if prevtime ~= curtime then
      UiTextBus.Event.SetText(self.RespawnTimer, string.format("%02.f", math.max(curtime, 0)))
      AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Respawn_Countdown", curtime)
      if self.timeToRespawn <= 0 then
        self.waitingToShowRespawnScreen = false
        self:SetRespawnList()
        self:SetRespawnMapVisible(true)
        AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Respawn_Countdown", 30)
      end
    end
  end
  if self.checkingIfCanSpectate then
    self.checkIfCanSpectateTimer = self.checkIfCanSpectateTimer + deltaTime
    if self.checkIfCanSpectateTimer >= self.checkIfCanSpectateInterval then
      self.checkIfCanSpectateTimer = 0
      LocalPlayerUIRequestsBus.Broadcast.RequestCanSpectate()
    end
  end
  if self.waitingToSpectate then
    self.waitingToSpectateTimer = self.waitingToSpectateTimer + deltaTime
    if self.waitingToSpectateTimer >= self.waitingToSpectateTimeout then
      self.waitingToSpectateTimer = 0
      self:OnRequestSpectateFailed()
    end
  end
end
function RespawnScreen:GetCooldownString(cooldown, isOverloaded, taxesPaid, isOutOfRange, maxRespawnDistance)
  local cooldownString
  local isWarning = false
  if taxesPaid == nil then
    taxesPaid = true
  end
  if tonumber(cooldown) > 0 then
    if isOutOfRange then
      cooldownString = GetLocalizedReplacementText("@ui_deathrecap_respawn_out_of_range_with_cooldown", {
        time = timeHelpers:ConvertToShorthandString(math.floor(cooldown), true),
        distance = DistanceToText(maxRespawnDistance)
      })
    else
      cooldownString = GetLocalizedReplacementText("@ui_respawn_time_remaining", {
        time = timeHelpers:ConvertToShorthandString(math.floor(cooldown), true)
      })
    end
    isWarning = true
  elseif isOutOfRange then
    cooldownString = GetLocalizedReplacementText("@ui_deathrecap_respawn_out_of_range", {
      distance = DistanceToText(maxRespawnDistance)
    })
    isWarning = true
  elseif isOverloaded then
    cooldownString = "@ui_deathrecap_respawn_overloaded"
    isWarning = true
  elseif not taxesPaid then
    cooldownString = "@ui_housing_disabled"
    isWarning = true
  else
    cooldownString = "@ui_deathrecap_respawn_ready"
  end
  return cooldownString, isWarning
end
function RespawnScreen:GetHomePointDataFromNode(currentDataNode, nodeIndex)
  local cooldown = currentDataNode.CooldownEnd:GetData()
  local isOverloaded = currentDataNode.IsOverloaded:GetData()
  local position = currentDataNode.Position:GetData()
  local distance = position:GetDistance(self.deathPosition)
  local isAvailable = currentDataNode.IsAvailable:GetData()
  local typeName = currentDataNode.Type:GetData()
  local cooldownText = self:GetCooldownString(cooldown, isOverloaded)
  local maxRespawnDistance = currentDataNode.MaxRespawnDistance:GetData()
  local isOutOfRange = 0 < maxRespawnDistance and distance > maxRespawnDistance
  local data = {
    id = currentDataNode.GDEID:GetData(),
    name = currentDataNode.Name:GetData(),
    position = position,
    hasCooldown = currentDataNode.Cooldown:GetData(),
    cooldown = cooldown,
    cooldownString = cooldownText,
    distance = distance,
    distanceString = DistanceToText(distance),
    dataNodeIndex = nodeIndex,
    isOverloaded = isOverloaded,
    isAvailable = isAvailable,
    typeName = typeName,
    maxRespawnDistance = maxRespawnDistance,
    isOutOfRange = isOutOfRange
  }
  return data
end
function RespawnScreen:UpdateHomePointEntriesFromNode(homePointsDataNode, isInRaid)
  local homePointData = {}
  local homePointCount = homePointsDataNode.Count:GetData() or 0
  local currentChildCount = UiElementBus.Event.GetNumChildElements(self.Properties.RespawnMapListHolder)
  for i = 1, homePointCount do
    local currentDataNode = homePointsDataNode[tostring(i)]
    local hideFromRespawn = currentDataNode.IsHiddenFromRespawn:GetData()
    local hideBasedOnRaidStatus = isInRaid and currentDataNode.Type:GetData() ~= "Raid" or not isInRaid and currentDataNode.Type:GetData() == "Raid"
    local hideBasedOnDungeonStatus = self.isInDungeon and currentDataNode.Type:GetData() ~= "Dungeon" or not self.isInDungeon and currentDataNode.Type:GetData() == "Dungeon"
    if not hideFromRespawn and not hideBasedOnRaidStatus and not hideBasedOnDungeonStatus then
      local data = self:GetHomePointDataFromNode(currentDataNode, tostring(i))
      homePointData[#homePointData + 1] = data
    end
  end
  local respawnPointCount = #homePointData
  local hasRandomSpawnPoint = false
  if respawnPointCount == 0 then
    respawnPointCount = respawnPointCount + 1
    hasRandomSpawnPoint = true
  end
  if currentChildCount <= respawnPointCount then
    UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.RespawnMapListHolder, respawnPointCount)
  end
  self:SetRespawnListSize(respawnPointCount)
  table.sort(homePointData, function(a, b)
    if a.hasCooldown ~= b.hasCooldown then
      return b.hasCooldown
    end
    if a.isOverloaded ~= b.isOverloaded then
      return b.isOverloaded
    end
    return a.distance < b.distance
  end)
  self:UnregisterCooldownObservers()
  local invalidTerritoryId = 0
  local freeRespawnTerritoryId = invalidTerritoryId
  for index, homeData in ipairs(homePointData) do
    if homeData.name == "@Respawn_OutpostName" then
      freeRespawnTerritoryId = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryIdByPosition(homeData.position, true)
    end
    if homeData.name == "@Respawn_OutpostName" or homeData.typeName == "Inn" then
      local containingTerritory = MapComponentBus.Broadcast.GetContainingTerritory(homeData.position)
      local territoryName = territoryDataHandler:GetTerritoryNameFromTerritoryId(containingTerritory)
      homeData.secondaryText = territoryName
    end
  end
  if freeRespawnTerritoryId ~= invalidTerritoryId then
    for index, homeData in ipairs(homePointData) do
      if self.respawnTypesWithCooldownTrigger[homeData.typeName] then
        local thisTerritoryid = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryIdByPosition(homeData.position, true)
        if thisTerritoryid == freeRespawnTerritoryId then
          homeData.forceSetDisabled = true
          homeData.tooltipText = "@ui_disable_respawn_near_territory"
        end
      end
    end
  end
  for index, homeData in ipairs(homePointData) do
    local selectable = not homeData.hasCooldown and homeData.isAvailable and not homeData.forceSetDisabled and not homeData.isOutOfRange
    if homeData.typeName == "Camp" then
      if homeData.hasCooldown then
        homeData.tooltipText = "@ui_camp_cooldown_tooltip"
      else
        homeData.tooltipText = nil
      end
    elseif homeData.hasCooldown then
      homeData.tooltipText = nil
    end
    self:UpdateEntry(index, homeData.id, homeData.name, homeData.cooldown, homeData.isOverloaded, homeData.distanceString, homeData.position, selectable, homeData.dataNodeIndex, homeData.typeName, homeData.tooltipText, homeData.secondaryText, homeData.forceSetDisabled, homeData.isOutOfRange, homeData.maxRespawnDistance)
  end
  if hasRandomSpawnPoint then
    local randomRespawnString = "?"
    if self.isInDungeon and self.rootPlayerId then
      local teleportLocation = GameModeParticipantComponentRequestBus.Event.GetDungeonTeamTeleportData(self.rootPlayerId)
      local distance = teleportLocation:GetDistance(self.deathPosition)
      randomRespawnString = DistanceToText(distance)
    end
    self:UpdateEntry(respawnPointCount, "", self.randomRespawnLocStr, 0, false, randomRespawnString, self.deathPosition, true)
  end
  if self.waitingToShowRespawnScreen then
    self:SetIsTicking(true)
  end
  return respawnPointCount
end
function RespawnScreen:SetRespawnList()
  local localPlayerRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  local isInRaid = localPlayerRaidId ~= nil and localPlayerRaidId:IsValid()
  self.isInDungeon = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
    if rootPlayerId then
      self.rootPlayerId = rootPlayerId
      if GameModeParticipantComponentRequestBus.Event.GetCurrentDungeonGameModeId(self.rootPlayerId) ~= 0 then
        self.randomRespawnLocStr = "@ui_dungeon_entrance_respawn_location"
        self.isInDungeon = true
      end
    end
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.RespawnTimerHolder, isInRaid or self.isTimeToRespawnDataSet)
  local totalHomePointsToDisplay = 1
  local homePointsDataNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HomePoints")
  if homePointsDataNode then
    totalHomePointsToDisplay = self:UpdateHomePointEntriesFromNode(homePointsDataNode, isInRaid, self.isInDungeon)
  else
    UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.RespawnMapListHolder, 1)
    self:SetRespawnListSize(1)
    self:UpdateEntry(totalHomePointsToDisplay, "", self.randomRespawnLocStr, 0, false, "?", self.deathPosition, true)
  end
  self:UpdateSelectedChild()
  local itemHeight = self.respawnListItemElements[1]:GetHeight()
  local itemSpacing = UiLayoutColumnBus.Event.GetSpacing(self.RespawnMapListHolder)
  local listHeight = #self.respawnListItemElements * (itemHeight + itemSpacing)
  UiTransform2dBus.Event.SetLocalHeight(self.RespawnMapListContent, listHeight)
  UiScrollBoxBus.Event.SetScrollOffsetY(self.Properties.Scrollbox, 210)
end
function RespawnScreen:OnHomePointsCountChanged()
  self.ScriptedEntityTweener:Stop(self.Properties.RespawnSpinner)
  self.ScriptedEntityTweener:Set(self.Properties.RespawnSpinner, {rotation = 0, opacity = 0})
  self:SetRespawnList()
end
function RespawnScreen:UpdateSelectedChild()
  local closestEntity
  local closestDistance = math.huge
  for i = 1, #self.respawnListItemElements do
    local currentItem = self.respawnListItemElements[i]
    local currentItemData = currentItem:GetData()
    local homeId = currentItemData.homeId
    local isValid = currentItemData.isValidHome
    if homeId ~= "" and isValid then
      local distance = currentItemData.homePosition:GetDistanceSq(self.deathPosition)
      if closestDistance > distance then
        closestEntity = currentItem
        closestDistance = distance
      end
    end
  end
  local itemToSelect
  if closestEntity then
    itemToSelect = closestEntity
  else
    itemToSelect = self.respawnListItemElements[#self.respawnListItemElements]
  end
  itemToSelect:UpdateSelectedItem()
  UiRadioButtonGroupBus.Event.SetState(self.RespawnMapListHolder, itemToSelect.entityId, true)
end
function RespawnScreen:UnregisterCooldownObservers()
  for _, path in pairs(self.cooldownObservers) do
    self.dataLayer:UnregisterObserver(self, path)
  end
  ClearTable(self.cooldownObservers)
end
function RespawnScreen:UpdateEntry(index, id, name, cooldown, isOverloaded, distanceString, position, selectable, dataNodeIndex, typeName, tooltipText, secondaryText, forceSetDisabled, isOutOfRange, maxRespawnDistance)
  local childId = UiElementBus.Event.GetChild(self.Properties.RespawnMapListHolder, index - 1)
  UiElementBus.Event.SetIsEnabled(childId, true)
  local currentItem = self.registrar:GetEntityTable(childId)
  local isHome = typeName == "Home"
  local taxesPaid = true
  local secondaryText = secondaryText and secondaryText or nil
  if isHome then
    name = "@ui_my_house_map_title"
    local thisRespawnPointTerritoryId = MapComponentBus.Broadcast.GetContainingTerritory(position)
    local ownedHouses = PlayerHousingClientRequestBus.Broadcast.GetOwnedHouseData()
    for i = 1, #ownedHouses do
      local houseData = ownedHouses[i]
      local territoryId = MapComponentBus.Broadcast.GetContainingTerritory(houseData.housingPlotPos)
      if territoryId == thisRespawnPointTerritoryId then
        taxesPaid = houseData.taxesDue > timeHelpers:ServerNow()
        break
      end
    end
    local territoryName = territoryDataHandler:GetTerritoryNameFromTerritoryId(thisRespawnPointTerritoryId)
    secondaryText = GetLocalizedReplacementText("@ui_respawn_home_location", {territoryName = territoryName})
    if not taxesPaid then
      selectable = false
      secondaryText = GetLocalizedReplacementText("@ui_respawn_home_location_unpaid", {territoryName = territoryName})
    end
  end
  if self.isInDungeon then
    local iconpath = "LyShineUI/Images/Map/Icon/icon_map_respawn.png"
    currentItem:SetListIcon(iconpath)
  end
  currentItem:SetText(name)
  currentItem:SetSecondaryText(secondaryText)
  currentItem:SetTextDistance(distanceString, isOutOfRange)
  currentItem:OnUnselected()
  local cooldownString, isWarning = self:GetCooldownString(cooldown, isOverloaded, taxesPaid, isOutOfRange, maxRespawnDistance)
  currentItem:SetTextCooldown(cooldownString, isWarning)
  local itemData = {
    homeId = id,
    homePosition = position,
    isValidHome = selectable,
    taxesPaid = taxesPaid,
    typeName = typeName
  }
  currentItem:SetData(itemData)
  currentItem:SetCallback("OnSelect", self)
  if dataNodeIndex then
    local cooldownPath = "Hud.LocalPlayer.HomePoints." .. dataNodeIndex .. ".CooldownEnd"
    self.cooldownObservers[#self.cooldownObservers + 1] = cooldownPath
    self.dataLayer:RegisterDataObserver(self, cooldownPath, function(self, cooldownEnd)
      currentItem:SetTextCooldown(self:GetCooldownString(cooldownEnd, isOverloaded, taxesPaid, isOutOfRange, maxRespawnDistance))
      if cooldownEnd <= 0 then
        currentItem:SetTooltip(nil)
      end
      local isAvailable = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HomePoints." .. dataNodeIndex .. ".IsAvailable")
      local isValidHome = cooldownEnd <= 0 and isAvailable and not forceSetDisabled and not isOutOfRange
      itemData.isValidHome = isValidHome
      if self.selectedHomeId == id then
        self:SetRespawnButtonVisible(itemData.isValidHome and itemData.taxesPaid)
      end
    end)
  end
  currentItem:SetTooltip(tooltipText)
  table.insert(self.respawnListItemElements, currentItem)
end
function RespawnScreen:OnRespawnRequestFailed()
  self.ScriptedEntityTweener:Stop(self.Properties.RespawnSpinner)
  self.ScriptedEntityTweener:Set(self.Properties.RespawnSpinner, {rotation = 0, opacity = 0})
  self:SetSpectateButtonInteractive(true)
  self:SetRespawnButtonInteractive(true)
  if self.loadingScreenHandler then
    self:BusDisconnect(self.loadingScreenHandler)
    self.loadingScreenHandler = nil
  end
  self:SetScreenData()
end
function RespawnScreen:OnRespawnButtonPressed(entityId, actionName)
  if self.doesRespawnResetCooldown then
    do
      local respawnPopupId = "RespawnSelectionPopupId"
      popupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_confirm_respawn_cooldown", "@ui_confirm_respawn_cooldown_desc", respawnPopupId, self, function(self, result, eventId)
        if eventId == respawnPopupId and result == ePopupResult_Yes then
          self:TriggerRespawn()
        end
      end)
    end
  else
    self:TriggerRespawn()
  end
end
function RespawnScreen:TriggerRespawn()
  if not self.loadingScreenHandler then
    self.loadingScreenHandler = self:BusConnect(LoadScreenNotificationBus, self.entityId)
  end
  self:SetSpectateButtonInteractive(false)
  self:SetRespawnButtonInteractive(false)
  local isRandomRespawn = self.selectedHomeId == ""
  LocalPlayerUIRequestsBus.Broadcast.RequestRespawn(isRandomRespawn, self.selectedHomeId)
end
function RespawnScreen:OnSpectate(entityId, actionName)
  self:SetSpectateButtonInteractive(false)
  self:SetRespawnButtonInteractive(false)
  self.checkingIfCanSpectate = false
  self.waitingToSpectate = true
  self.waitingToSpectateTimer = 0
  LocalPlayerUIRequestsBus.Broadcast.RequestSpectate()
  self.ScriptedEntityTweener:Play(self.Properties.SpectateSpinner, 1, {rotation = 0, opacity = 1}, {timesToPlay = -1, rotation = 359})
end
function RespawnScreen:OnSelect(entity, data)
  self.selectedHomeId = data.homeId
  if self.selectedHomeId == "" then
    self.MapElement:CenterToPosition(self.deathPosition)
  else
    self.MapElement:CenterToPosition(data.homePosition)
  end
  self:SetRespawnButtonVisible(data.isValidHome and data.taxesPaid)
  self.doesRespawnResetCooldown = self.respawnTypesWithCooldownTrigger[data.typeName]
end
function RespawnScreen:SetRespawnButtonVisible(isVisible)
  self.RespawnMapButtonAccept:SetEnabled(isVisible)
  if UiElementBus.Event.IsEnabled(self.Properties.RespawnTimerHolder) then
    self.ScriptedEntityTweener:Set(self.Properties.RespawnTimerHolder, {opacity = 0})
  end
end
function RespawnScreen:SetRespawnButtonInteractive(isInteractive)
  if self.isFtue then
    self.RespawnFtueButtonAccept:SetEnabled(isInteractive)
  else
    self.RespawnMapButtonAccept:SetEnabled(isInteractive)
  end
end
function RespawnScreen:SetSpectateButtonVisible(isVisible)
  if isVisible then
    if self.respawnButtonWasMoved then
      local posY = -120
      UiTransformBus.Event.SetLocalPositionY(self.Properties.RespawnMapButtonAccept, posY)
      self.respawnButtonWasMoved = false
    end
  elseif not self.respawnButtonWasMoved then
    local posY = -40
    UiTransformBus.Event.SetLocalPositionY(self.Properties.RespawnMapButtonAccept, posY)
    self.respawnButtonWasMoved = true
  end
  UiElementBus.Event.SetIsEnabled(self.SpectateMapButtonAccept.entityId, isVisible)
end
function RespawnScreen:SetSpectateButtonInteractive(isInteractive)
  self.SpectateMapButtonAccept:SetEnabled(isInteractive)
end
function RespawnScreen:SetSpectateButtonGreyed(isGreyed)
  local opacity = 0
  if isGreyed then
    opacity = 0.65
  else
    opacity = 1
  end
  self.ScriptedEntityTweener:Set(self.Properties.SpectateMapButtonAccept, {opacity = opacity})
end
function RespawnScreen:OnDeathRecap(data)
  self.hasDeathData = data ~= nil
  self.isKilledByPlayerInPvP = false
  local statsData = {}
  local killerName = self.hasDeathData and data.killerName or nil
  local hasKillerName = killerName ~= nil and killerName ~= ""
  if self.hasDeathData and data.isStreaming then
    self.isTwitchStreamer = true
    self.twitchViewCount = GetLocalizedNumber(data.viewerCount)
    UiTextBus.Event.SetText(self.TwitchViewersNumber, self.twitchViewCount)
    local textElementWidth = UiTransform2dBus.Event.GetLocalWidth(self.TwitchViewersNumber)
    local textWidth = UiTextBus.Event.GetTextWidth(self.TwitchViewersNumber)
    local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.TwitchViewersIcon.entityId)
    local iconSpacing = 15
    local offsetOverallPosX = iconWidth / 2
    local offsetIconPosX = (textElementWidth - textWidth) / 2 - (iconWidth + iconSpacing)
    self.ScriptedEntityTweener:Set(self.TwitchViewersIcon.entityId, {
      x = offsetIconPosX + offsetOverallPosX
    })
    self.ScriptedEntityTweener:Set(self.TwitchViewersNumber, {x = offsetOverallPosX})
  else
    self.isTwitchStreamer = false
    self.twitchViewCount = nil
  end
  if self.hasDeathData and data.isKilledByPlayer then
    local localPlayerPvpFlag = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.PvpFlag")
    self.isKilledByPlayerInPvP = localPlayerPvpFlag == ePvpFlag_On
    UiElementBus.Event.SetIsEnabled(self.KilledByTitle, true)
    local killedText = "@ui_killedby"
    UiTextBus.Event.SetTextWithFlags(self.KilledByTitle, killedText, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.KilledByName, killerName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextCase(self.KilledByName, self.UIStyle.TEXT_CASING_NORMAL)
    local killerGuildName = data.guildName
    local killerNameData = {
      text = killedText,
      data = killerName,
      dataExtra = killerGuildName,
      twitchViewers = self.twitchViewCount,
      isPlayer = true
    }
    table.insert(statsData, killerNameData)
    local itemData = ItemDataManagerBus.Broadcast.GetItemData(data.itemDescriptor.itemId)
    self.weaponTdi = nil
    if itemData then
      local descriptor = data.itemDescriptor
      self.weaponTdi = StaticItemDataManager:GetTooltipDisplayInfo(descriptor)
      local itemIconPath = "LyShineUI/Images/Icons/Items/%s.dds"
      self.murderWeaponImagePath = string.format(itemIconPath, itemData.itemType .. "/" .. itemData.icon)
      local killerUsedData = {
        text = "@ui_deathrecap_killed_with",
        data = itemData.displayName,
        dataExtra = ""
      }
      table.insert(statsData, killerUsedData)
    end
  else
    statsData.noIcon = true
    if hasKillerName then
      UiElementBus.Event.SetIsEnabled(self.KilledByTitle, true)
      UiTextBus.Event.SetTextWithFlags(self.KilledByTitle, "@ui_killedby", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.KilledByName, killerName, eUiTextSet_SetLocalized)
      local killerNameData = {
        text = "@ui_killedby",
        data = killerName,
        dataExtra = ""
      }
      table.insert(statsData, killerNameData)
    else
      UiElementBus.Event.SetIsEnabled(self.KilledByTitle, false)
      UiTextBus.Event.SetTextWithFlags(self.KilledByName, "@ui_youdied", eUiTextSet_SetLocalized)
      local killerNameData = {
        text = "",
        data = "@ui_youdied",
        dataExtra = ""
      }
      statsData.hideLine = true
      table.insert(statsData, killerNameData)
    end
    UiTextBus.Event.SetTextCase(self.KilledByName, self.UIStyle.TEXT_CASING_UPPER)
  end
  if self.hasDeathData then
    local timeAlive = timeHelpers:ConvertToShorthandString(data.secondsSinceLastRevive)
    local bestTime = timeHelpers:ConvertToShorthandString(data.bestSurvivalTimeSeconds)
    local isPersonalBest = data.secondsSinceLastRevive > data.bestSurvivalTimeSeconds and "@ui_deathrecap_new_personal_best" or ""
    local timeAliveData = {
      text = "@ui_deathrecap_survived_for",
      data = timeAlive,
      dataExtra = isPersonalBest
    }
  end
  self:HideStatClones()
  for i = 1, #statsData do
    local currentItem, itemData = self:GetStatRowEntity()
    local itemSpacing = 40
    local itemWidth = currentItem:GetWidth()
    local offsetPosX = 210
    local offsetPosY = 84
    local itemLocation = statsData[i].text == "@ui_deathrecap_killed_with" and 960 or (itemSpacing + itemWidth) * (i - 1) + offsetPosX
    UiTransformBus.Event.SetLocalPosition(currentItem.entityId, Vector2(itemLocation, offsetPosY))
    currentItem:SetStatInfoHolderPositionX(0)
    if statsData.noIcon then
      currentItem:SetNoIconOffset()
    end
    if statsData.hideLine then
      currentItem:ShowStatLine(false)
    else
      currentItem:ShowStatLine(true)
    end
    currentItem:SetText(statsData[i].text)
    currentItem:SetTextData(statsData[i].data)
    currentItem:SetTextDataExtra(statsData[i].dataExtra)
    currentItem:SetTwitchInfo(self.twitchIconPath, statsData[i].twitchViewers)
    if statsData[i].isPlayer then
      currentItem:SetStatStyle(currentItem.STYLE_TYPE_KILLER)
      currentItem:SetPlayerLevelText("")
      currentItem:SetGuildCrestIcon(false)
      currentItem:SetFactionIcon(false)
      SocialDataHandler:GetPlayerIdentificationByName_ServerCall(self, function(self, result)
        if 0 < #result then
          local playerId = result[1].playerId
          currentItem:SetPlayerId(playerId)
          SocialDataHandler:GetRemotePlayerLevelData_ServerCall(self, function(self, result)
            if #result == 0 then
              Debug.Log("ERR - Killer level not found")
              return
            end
            local killerLevel = result[1].playerLevel + 1
            currentItem:SetPlayerLevelText(killerLevel)
          end, function()
            Debug.Log("ERR - Could not retrieve level info from playerId")
          end, playerId:GetCharacterIdString())
          SocialDataHandler:GetRemotePlayerFaction_ServerCall(self, function(self, result)
            if 0 < #result then
              local playerFaction = {
                faction = result[1].playerFaction
              }
              local killerFaction = playerFaction.faction
              if killerFaction then
                if not data.guildName or data.guildName == "" then
                  local killerFactionIcon = FactionCommon.factionInfoTable[killerFaction].crestFgSmall
                  local killerFactionName = FactionCommon.factionInfoTable[killerFaction].factionName
                  local killerFactionColor = FactionCommon.factionInfoTable[killerFaction].crestBgColor
                  local killerFactionTable = {backgroundImagePath = killerFactionIcon, backgroundColor = killerFactionColor}
                  currentItem:SetFactionIcon(true, killerFactionIcon, killerFactionColor)
                  local factionText = "<font color=" .. ColorRgbaToHexString(killerFactionColor) .. ">" .. killerFactionName .. "</font>"
                  currentItem:SetTextDataExtra(factionText)
                  currentItem:SetStatInfoHolderPositionX(-32)
                else
                  currentItem:SetGuildCrestIcon(true, data.guildCrestData)
                  currentItem:SetFactionIcon(false)
                end
              end
            else
              Log("ERR - Could not retrieve faction from playerId")
              return
            end
          end, function()
            Log("ERR - Could not retrieve faction info from playerId")
          end, playerId:GetCharacterIdString())
        end
      end, function(self)
        Debug.Log("ERR - Could not retrieve playerId")
      end, killerName)
    elseif statsData[i].text == "@ui_killedby" or statsData[i].text == "" then
      currentItem:SetStatStyle(currentItem.STYLE_TYPE_KILLER_NPC)
      local offsetPosY = 112
      UiTransformBus.Event.SetLocalPositionY(currentItem.entityId, offsetPosY)
    elseif statsData[i].text == "@ui_deathrecap_killed_with" then
      currentItem:SetStatStyle(currentItem.STYLE_TYPE_KILLER_USED)
      currentItem:SetFocusCallback("OnWeaponTextFocus", self)
      currentItem:SetUnfocusCallback("OnWeaponTextUnfocus", self)
      if self.murderWeaponImagePath then
        currentItem:SetWeaponIcon(self.murderWeaponImagePath)
      end
    elseif statsData[i].text == "@ui_deathrecap_survived_for" then
      currentItem:SetStatStyle(currentItem.STYLE_TYPE_SURVIVED)
    end
    itemData.initPosX = itemLocation
  end
end
function RespawnScreen:GetStatRowEntity()
  local currentItem, itemData
  for _, data in ipairs(self.statRowsElements) do
    if data.isCached then
      itemData = data
      currentItem = itemData.itemTable
      break
    end
  end
  if itemData then
    UiElementBus.Event.Reparent(itemData.entityId, self.Properties.StatHolder, EntityId())
  else
    currentItem = self:CloneElement(self.Properties.StatRowClone, self.Properties.StatHolder, false)
    UiTransformBus.Event.SetLocalPositionX(currentItem.entityId, 200)
    itemData = {
      entityId = currentItem.entityId,
      itemTable = currentItem
    }
    table.insert(self.statRowsElements, itemData)
  end
  itemData.isCached = false
  return currentItem, itemData
end
function RespawnScreen:HideStatClones()
  for _, itemData in ipairs(self.statRowsElements) do
    if not itemData.isCached then
      UiElementBus.Event.SetIsEnabled(itemData.entityId, false)
      UiElementBus.Event.Reparent(itemData.entityId, self.entityId, EntityId())
      itemData.isCached = true
    end
  end
end
function RespawnScreen:OnRequestCanSpectateResponse(canSpectate)
  if self.checkingIfCanSpectate then
    self:SetSpectateButtonGreyed(not canSpectate)
    self:SetSpectateButtonInteractive(canSpectate)
  end
end
function RespawnScreen:OnRequestSpectateFailed()
  self.checkingIfCanSpectate = true
  self.waitingToSpectate = false
  self:ResetMapButtons()
  self:SetSpectateButtonGreyed(true)
  self:SetSpectateButtonInteractive(false)
end
function RespawnScreen:OnWeaponTextFocus()
  if self.weaponTdi then
    DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(self.weaponTdi, self, nil)
  end
end
function RespawnScreen:OnWeaponTextUnfocus()
  if self.weaponTdi then
    DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  end
end
function RespawnScreen:OnUiLoadingComplete()
  if self.uiLoaderHandler then
    self.uiLoaderHandler = nil
    DynamicBus.UiLoader.Disconnect(self.entityId, self)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    if isDead == nil then
      return
    end
    self.isDead = isDead
    self.isDeadDataSet = true
    if self.isTimeToRespawnDataSet and self.isDeadDataSet then
      self:SetScreenData()
    end
    if not isDead and (self.waitingToShowRespawnScreen or UiCanvasBus.Event.GetEnabled(self.canvasId)) then
      self:OnLoadingScreenShown()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnPlayerDeath", function(self, timeToRespawn)
    if timeToRespawn == nil then
      return
    end
    if self.isTimeToRespawnDataSet == nil then
      self.timeToRespawn = timeToRespawn
      self.isTimeToRespawnDataSet = true
      if self.isTimeToRespawnDataSet and self.isDeadDataSet then
        self:SetScreenData()
      end
    end
  end)
end
function RespawnScreen:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.RespawnScreen.Disconnect(self.entityId, self)
  if self.tickBusHandler ~= nil then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  if self.uiPlayerHomeComponentBusHandler ~= nil then
    self:BusDisconnect(self.uiPlayerHomeComponentBusHandler)
    self.uiPlayerHomeComponentBusHandler = nil
  end
  if self.uiLoaderHandler then
    self.uiLoaderHandler = nil
    DynamicBus.UiLoader.Disconnect(self.entityId, self)
  end
  for i = 1, #self.statRowsElements do
    local currentItem = self.statRowsElements[i].entityId
    UiElementBus.Event.DestroyElement(currentItem)
  end
  ClearTable(self.statRowsElements)
end
function RespawnScreen:SetDebugData()
  UiTextBus.Event.SetTextWithFlags(self.KilledByTitle, "@ui_killedby", eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.KilledByName, "Rockzillah", eUiTextSet_SetLocalized)
  self:UpdateEntry(1, "", "@ui_random_location", 0, false, "?", self.deathPosition, true)
  self:UpdateEntry(2, "", "@ui_random_location", 0, false, "?", self.deathPosition, true)
  self:UpdateEntry(3, "", "@ui_random_location", 0, false, "?", self.deathPosition, true)
  local debugData = {
    {
      text = "@ui_murderedby",
      data = "Rockzillah",
      dataExtra = "Hands of Time"
    },
    {
      text = "@ui_deathrecap_killed_with",
      data = "Wooden Straight Sword",
      dataExtra = ""
    },
    {
      text = "@ui_viewers_watched",
      data = "1,219",
      dataExtra = ""
    },
    {
      text = "@ui_deathrecap_survived_for",
      data = "8m 39s",
      dataExtra = "@ui_deathrecap_new_personal_best"
    }
  }
  for i = 1, #debugData do
    local currentItem, itemData = self:GetStatRowEntity()
    local itemSpacing = 40
    local itemWidth = currentItem:GetWidth()
    local offsetPosX = 1450
    local itemLocation = debugData[i].text == "@ui_deathrecap_survived_for" and offsetPosX or (itemSpacing + itemWidth) * (i - 1)
    UiTransformBus.Event.SetLocalPosition(currentItem.entityId, Vector2(itemLocation, 0))
    currentItem:SetText(debugData[i].text)
    currentItem:SetTextData(debugData[i].data)
    currentItem:SetTextDataExtra(debugData[i].dataExtra)
    if debugData[i].text == "@ui_murderedby" then
      currentItem:SetStatStyle(currentItem.STYLE_TYPE_KILLER)
      local guildIconData = {
        bacgroundImagePath = "lyshineui/Images/crests/backgrounds/icon_shield_shape2V5.png",
        backgroundColor = self.UIStyle.COLOR_GRAY_80,
        foregroundImagePath = "lyshineui/Images/crests/foregrounds/icon_crest_12.png",
        foregroundColor = self.UIStyle.COLOR_RED_DARK
      }
      local playerIconData = {
        bacgroundImagePath = "LyShineUI/Images/charactercreation/Layered/Male/male-asian-asian-1.png",
        foregroundImagePath = "LyShineUI/Images/charactercreation/Layered/Male/male-male-african01.png",
        midgroundImagePath = "LyShineUI/Images/charactercreation/Layered/Male/male-male-downcurl01.png"
      }
      currentItem:SetGuildCrestIcon(true, guildIconData)
    elseif debugData[i].text == "@ui_deathrecap_killed_with" then
      currentItem:SetStatStyle(currentItem.STYLE_TYPE_KILLER_USED)
    elseif debugData[i].text == "@ui_deathrecap_killedby" then
      currentItem:SetStatStyle(currentItem.STYLE_TYPE_KILLER_NPC)
    elseif debugData[i].text == "@ui_viewers_watched" then
      currentItem:SetStatStyle(currentItem.STYLE_TYPE_TWITCH)
      currentItem:SetTwitchIcon(self.twitchIconPath)
    elseif debugData[i].text == "@ui_deathrecap_survived_for" then
      currentItem:SetStatStyle(currentItem.STYLE_TYPE_SURVIVED)
    end
    itemData.initPosX = itemLocation
  end
end
function RespawnScreen:OnCryAction(actionName)
  if self.isSpectating then
    return
  end
  local actionFunc = self.cryactionsToFunctions[actionName]
  if actionFunc then
    actionFunc()
  end
end
function RespawnScreen:ResetMapButtons()
  self.ScriptedEntityTweener:Stop(self.Properties.RespawnSpinner)
  self.ScriptedEntityTweener:Set(self.Properties.RespawnSpinner, {rotation = 0, opacity = 0})
  self.ScriptedEntityTweener:Stop(self.Properties.SpectateSpinner)
  self.ScriptedEntityTweener:Set(self.Properties.SpectateSpinner, {rotation = 0, opacity = 0})
  self:SetSpectateButtonInteractive(true)
  self:SetRespawnButtonInteractive(true)
  self:SetSpectateButtonGreyed(false)
end
function RespawnScreen:OnLoadingScreenShown()
  self.selfRequestingExit = true
  LyShineManagerBus.Broadcast.ExitState(3326371288)
  LyShineManagerBus.Broadcast.ExitState(921475099)
  LyShineManagerBus.Broadcast.ExitState(3901667439)
  LyShineManagerBus.Broadcast.SetState(2702338936)
  self:ResetDeathDataFlags()
  self.ScriptedEntityTweener:Stop(self.Properties.RespawnSpinner)
  self.ScriptedEntityTweener:Set(self.Properties.RespawnSpinner, {rotation = 0, opacity = 0})
  if self.isInOutpostRush then
    for i = 0, #self.Properties.DroppedItems do
      UiElementBus.Event.Reparent(self.Properties.DroppedItems[i], self.Properties.DroppedItemsNotInUse, EntityId())
    end
    self.itemDroppedIndex = 0
  end
end
function RespawnScreen:OnLoadingScreenDismissed()
  if self.isFirstLoad and self.isTimeToRespawnDataSet and self.isDeadDataSet and self.isDead then
    self:SetRespawnList()
  end
  if self.isFirstLoad and self.loadingScreenHandler then
    self:BusDisconnect(self.loadingScreenHandler)
    self.loadingScreenHandler = nil
  end
  self.isFirstLoad = false
end
function RespawnScreen:OnEnteredGameMode(gameModeEntityId, gameModeId)
  self.isInOutpostRush = false
  if gameModeId == 2444859928 then
    self.gameModeEntityId = gameModeEntityId
    self.isInOutpostRush = true
    self.outpostRushMatchEnded = false
    UiElementBus.Event.SetIsEnabled(self.Properties.DroppedItemsContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DroppedItemTitle, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.DroppedItemTitle, "@inv_DroppedItems", eUiTextSet_SetLocalized)
  end
end
function RespawnScreen:OnExitedGameMode(gameModeEntityId)
  if self.gameModeEntityId == gameModeEntityId and self.isInOutpostRush then
    self.isInOutpostRush = false
    self.outpostRushMatchEnded = false
    UiElementBus.Event.SetIsEnabled(self.Properties.DroppedItemsContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.DroppedItemTitle, false)
    self.gameModeEntityId = nil
  end
end
function RespawnScreen:OnItemDroppedOnDeath(slot)
  if slot and self.itemDroppedIndex <= #self.Properties.DroppedItems then
    UiElementBus.Event.Reparent(self.Properties.DroppedItems[self.itemDroppedIndex], self.Properties.DroppedItemsContainer, EntityId())
    self.DroppedItems[self.itemDroppedIndex]:SetItem(slot)
    self.itemDroppedIndex = self.itemDroppedIndex + 1
  end
end
function RespawnScreen:OnOutpostRushMatchEnded()
  if self.isInOutpostRush then
    self.outpostRushMatchEnded = true
  end
end
function RespawnScreen:OnSiegeWarfareStarted(warId)
  self.isInSiegeWar = true
  self.siegeWarMatchEnded = false
end
function RespawnScreen:OnSiegeWarfareEnded(isWin, resolutionPhaseEndTimePoint)
  if self.isInSiegeWar then
    self.siegeWarMatchEnded = true
  end
end
function RespawnScreen:OnSiegeWarfareCompleted(reason)
  self.isInSiegeWar = false
  self.siegeWarMatchEnded = false
end
return RespawnScreen
