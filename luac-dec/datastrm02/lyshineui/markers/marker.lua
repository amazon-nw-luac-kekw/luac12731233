local profiler = RequireScript("LyShineUI._Common.Profiler")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local Marker = {
  Properties = {
    Title = {
      default = EntityId()
    },
    HealthBar = {
      default = EntityId()
    },
    HealthBarBg = {
      default = EntityId()
    },
    HealthBarFill = {
      default = EntityId()
    },
    HealthBarDeltaFill = {
      default = EntityId()
    },
    HealthBarPulse = {
      default = EntityId()
    },
    HealthBarFrame = {
      default = EntityId()
    },
    RightSide = {
      default = EntityId()
    },
    DamageTextAnchor = {
      default = EntityId()
    },
    Collapsed = {
      default = EntityId()
    },
    Dot = {
      default = EntityId()
    },
    PartyIcon = {
      default = EntityId()
    },
    OffscreenPartyIcon = {
      default = EntityId()
    },
    Distance = {
      default = EntityId()
    },
    TargetTaggedIconHolder = {
      default = EntityId()
    },
    TargetTaggedArrow1 = {
      default = EntityId()
    },
    ObjectiveIcon = {
      default = EntityId()
    },
    StatusEffects = {
      default = EntityId()
    },
    StatusEffectsText = {
      default = EntityId()
    },
    AiThreatIndicator = {
      default = EntityId()
    },
    Player = {
      PlayerNameContainer = {
        default = EntityId()
      },
      GuildNameContainer = {
        default = EntityId()
      },
      GuildName = {
        default = EntityId()
      },
      ArrowIndicator = {
        default = EntityId()
      },
      FactionIconContainer = {
        default = EntityId()
      },
      FactionIconFront = {
        default = EntityId()
      },
      FactionIconBack = {
        default = EntityId()
      },
      StaminaBar = {
        default = EntityId()
      },
      StaminaBarBg = {
        default = EntityId()
      },
      StaminaBarFill = {
        default = EntityId()
      },
      DeathsDoor = {
        DeathsDoorContainer = {
          default = EntityId()
        },
        DeathsDoorTimer = {
          default = EntityId()
        },
        DeathsDoorIcon = {
          default = EntityId()
        }
      },
      GuildCrest = {
        CrestContainer = {
          default = EntityId()
        },
        Foreground = {
          default = EntityId()
        }
      },
      Streaming = {
        StreamingContainer = {
          default = EntityId()
        },
        ViewerCountText = {
          default = EntityId()
        }
      },
      Glory = {
        GloryContainer = {
          default = EntityId()
        },
        LevelText = {
          default = EntityId()
        },
        LevelBg = {
          default = EntityId()
        }
      },
      IsLowDetail = {default = false},
      IsFullDetail = {default = false},
      IsAi = {default = false}
    },
    Structure = {
      WarDot = {
        default = EntityId()
      }
    },
    ScreenStates = {
      OnScreen = {
        default = EntityId()
      },
      OffScreen = {
        default = EntityId()
      }
    }
  },
  PREVIOUS_LOD_LEVEL_NONE = -1,
  PREVIOUS_LOD_LEVEL_FULL = 0,
  PREVIOUS_LOD_LEVEL_MEDIUM = 1,
  PREVIOUS_LOD_LEVEL_SMALL = 2,
  NAMEPLATE_LEVEL_BG_NEUTRAL = "lyshineui/images/markers/marker_medium_neutral",
  NAMEPLATE_LEVEL_BG_PARTY = "lyshineui/images/markers/marker_medium_party",
  NAMEPLATE_LEVEL_BG_GUILD = "lyshineui/images/markers/marker_medium_guild",
  NAMEPLATE_LEVEL_BG_CRIMINAL_INTENT = "lyshineui/images/markers/marker_medium_criminalIntent",
  NAMEPLATE_LEVEL_BG_WAR = "lyshineui/images/markers/marker_medium_war",
  NAMEPLATE_LEVEL_BG_NORMAL = ".dds",
  NAMEPLATE_LEVEL_BG_STREAMING = "_streaming.dds",
  NAMEPLATE_LEVEL_BG_DUEL = "_duel.dds",
  NAMEPLATE_LEVEL_BG_STREAMING_DUEL = "_streaming_duel.dds",
  NAMEPLATE_LEVEL_BG_AI_NORMAL = ".dds",
  NAMEPLATE_LEVEL_BG_AI_SKIP_DEATHS_DOOR = "_zerg.dds",
  DEATHS_DOOR_NEUTRAL = "lyshineui/images/markers/marker_deathsDoorNeutral.dds",
  DEATHS_DOOR_PARTY = "lyshineui/images/markers/marker_deathsDoorParty.dds",
  DEATHS_DOOR_GUILD = "lyshineui/images/markers/marker_deathsDoorGuild.dds",
  DEATHS_DOOR_CRIMINAL_INTENT = "lyshineui/images/markers/marker_deathsDoorCriminalIntent.dds",
  DEATHS_DOOR_WAR = "lyshineui/images/markers/marker_deathsDoorWar.dds",
  STATUS_ICON_WAR_TARGET = "lyshineui/images/markers/marker_simple_warTarget.dds",
  STATUS_ICON_PRE_WAR = "lyshineui/images/markers/marker_simple_warPre.dds",
  criticalHealthPercent = 0.35,
  timeSinceLastHealthUpdate = 0,
  healthBarFillCanDamagePath = "lyshineui/images/markers/marker_healthbarcandamage.dds",
  healthBarBgCanDamagePath = "lyshineui/images/markers/marker_healthbarBgcandamage.dds",
  healthBarFillCannotDamagePath = "lyshineui/images/markers/marker_healthbarcannotdamage.dds",
  healthBarBgCannotDamagePath = "lyshineui/images/markers/marker_healthbarBgcannotdamage.dds",
  healthBarFillFriendly = "lyshineui/images/markers/marker_healthBarParty.dds",
  healthBarBgFriendly = "lyshineui/images/markers/marker_healthBarBgParty",
  healthBarFramePulseFriendlyPath = "lyshineui/images/markers/marker_healthBarFrameCriticalHealthFriendly.dds",
  healthBarFramePulseEnemyPath = "lyshineui/images/markers/marker_healthBarFrameCriticalHealth.dds",
  levelOffsetPosYNoStamina = 0,
  staminaBarHeight = 8,
  aiThreatHeight = 0
}
function Marker:IsPlayerFullDetail()
  return self.Properties.Player.IsFullDetail
end
function Marker:IsPlayerMediumDetail()
  return not self.Properties.Player.IsLowDetail and not self.Properties.Player.IsFullDetail
end
function Marker:IsPlayerLowDetail()
  return self.Properties.Player.IsLowDetail
end
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local registrar = RequireScript("LyShineUI.EntityRegistrar")
local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local uiStyle = RequireScript("LyShineUI._Common.UIStyle")
local raycastBatcher = RequireScript("LyShineUI._Common.RaycastBatcher")
local markerTypeData = RequireScript("LyShineUI.Markers.MarkerData")
local audioHelper = RequireScript("LyShineUI.AudioEvents")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local TitleSection = RequireScript("LyShineUI.Skills.TitleSection")
local DifficultyColors = RequireScript("LyShineUI._Common.DifficultyColors")
local zeroOpacityTable = {opacity = 0}
function Marker:OnActivate()
  self.dataLayer = dataLayer
  self.registrar = registrar
  self.tweener = tweener
  self.UIStyle = uiStyle
  self.audioHelper = audioHelper
  self.registrar:RegisterEntity(self)
  self.states = {
    onScreen = {
      currentState = 0,
      stateNames = {Screen_Enter = 1, Screen_Exit = 2}
    },
    groupFocusState = {
      currentState = 0,
      stateNames = {Group_Enter = 1, Group_Exit = 2}
    },
    interactFocusState = {
      currentState = 0,
      stateNames = {Focus_Enter = 1, Focus_Exit = 2}
    },
    healthStates = {
      currentState = 0,
      stateNames = {
        Critical_Health = 1,
        Full_Health = 2,
        GreaterHalf_Health = 3,
        LessHalf_Health = 4,
        No_Health = 5
      }
    },
    healthIdleStates = {
      currentState = 0,
      stateNames = {Idle_Health_Start = 1, Idle_Health_End = 2}
    },
    deadStates = {
      currentState = 0,
      stateNames = {
        Alive = 1,
        Dead = 2,
        InDeathsDoor = 3
      }
    },
    deathsDoor = {
      currentState = 0,
      stateNames = {EnterDeathsDoor = 1, ExitDeathsDoor = 2}
    },
    playerStates = {
      currentState = 0,
      stateNames = {NotGuildMate = 1, GuildMate = 2}
    },
    targetPvpFlag = {
      currentState = 0,
      stateNames = {TargetPvpFlagOn = 1, TargetPvpFlagOff = 2}
    },
    myPvpFlag = {
      currentState = 0,
      stateNames = {MyPvpFlagOn = 1, MyPvpFlagOff = 2}
    },
    duelStates = {
      currentState = 0,
      stateNames = {Duel_Enter = 1, Duel_Exit = 2}
    },
    guildWarStates = {
      currentState = 0,
      stateNames = {
        GuildWarPreWar = 1,
        GuildWarOn = 2,
        GuildWarOff = 3
      }
    },
    targetActiveState = {
      currentState = 0,
      stateNames = {TargetActive = 1, TargetInactive = 2}
    },
    streamingState = {
      currentState = 0,
      stateNames = {Streaming = 1, NotStreaming = 2}
    }
  }
end
function Marker:OnDeactivate()
  if self.canvasId then
    UiCanvasBus.Event.StopMultithread(self.canvasId)
  end
  if self.registrar then
    self.registrar:UnregisterEntity(self)
  end
  if self.timelineTaggedArrow then
    self.timelineTaggedArrow:Stop()
    self.tweener:TimelineDestroy(self.timelineTaggedArrow)
  end
  self.dataLayer:UnregisterObservers(self)
  if self.tickBusHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
  if self.markerId then
    DamageNumbersAnchorBus.Event.DisconnectMarkerId(self.Properties.DamageTextAnchor, self.markerId)
  end
  self.markerClass = nil
end
function Marker:EnableChildren(entityId)
  UiElementBus.Event.SetIsEnabled(entityId, true)
  UiFaderBus.Event.SetFadeValue(entityId, 1)
  local children = UiElementBus.Event.GetChildren(entityId)
  for i = 1, #children do
    self:EnableChildren(children[i])
  end
end
function Marker:Init(dataPath, interactTypeChangedCallbackData)
  self.interactTypeChangedCallbackData = interactTypeChangedCallbackData
  self.originalHealthBarFillColor = UiImageBus.Event.GetColor(self.Properties.HealthBarFill)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.defaultAiDifficultyIconData = {
    creatureTypes = {
      4251095822,
      251659281,
      4072591649
    },
    framePath = "lyshineui/images/markers/marker_healthBarFrameSoloMinus.dds",
    levelFrame = "lyshineui/images/markers/marker_ai_level_bg_soloMinus",
    staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameSoloMinus.dds",
    isBoss = false,
    levelOffsetPosY = 17,
    healthHeightOffset = 11,
    threatHeight = 26,
    showLevel = true
  }
  self.aiDifficultyIcons = {
    {
      creatureTypes = {3839772741},
      framePath = "lyshineui/images/markers/marker_healthBarFrameCritter.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_critter",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameSoloMinus.dds",
      isBoss = false,
      levelOffsetPosY = 17,
      healthHeightOffset = 11,
      threatHeight = 26,
      showLevel = false
    },
    {
      creatureTypes = {
        4251095822,
        251659281,
        4072591649,
        3626430564
      },
      framePath = "lyshineui/images/markers/marker_healthBarFrameSoloMinus.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_soloMinus",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameSoloMinus.dds",
      isBoss = false,
      levelOffsetPosY = 17,
      healthHeightOffset = 11,
      threatHeight = 26,
      showLevel = true
    },
    {
      creatureTypes = {
        335623739,
        841332802,
        884577660
      },
      framePath = "lyshineui/images/markers/marker_healthBarFrameSoloPlus.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_soloPlus",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameSoloPlus.dds",
      isBoss = false,
      levelOffsetPosY = 17,
      healthHeightOffset = 11,
      threatHeight = 26,
      showLevel = true
    },
    {
      creatureTypes = {2092844419, 4256833172},
      framePath = "lyshineui/images/markers/marker_healthBarFrameGroupMinus.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_groupMinus",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameGroupMinus.dds",
      isBoss = false,
      levelOffsetPosY = 23,
      healthHeightOffset = 16,
      threatHeight = 31,
      showLevel = true
    },
    {
      creatureTypes = {
        1841317061,
        1299769218,
        3616382481
      },
      framePath = "lyshineui/images/markers/marker_healthBarFrameGroup.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_group",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameGroup.dds",
      isBoss = false,
      levelOffsetPosY = 23,
      healthHeightOffset = 16,
      threatHeight = 31,
      showLevel = true
    },
    {
      creatureTypes = {
        2514346166,
        2101709862,
        349813665
      },
      framePath = "lyshineui/images/markers/marker_healthBarFrameGroupPlus.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_groupPlus",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameGroupPlus.dds",
      allyFrame = "lyshineui/images/markers/marker_ai_level_bg_groupPlus_ally",
      isBoss = false,
      levelOffsetPosY = 23,
      healthHeightOffset = 16,
      threatHeight = 31,
      showLevel = true
    },
    {
      creatureTypes = {
        1056859706,
        1374655532,
        3096195353
      },
      framePath = "lyshineui/images/markers/marker_healthBarFrameBoss.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_boss",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameBoss.dds",
      isBoss = true,
      levelOffsetPosY = 23,
      healthHeightOffset = 16,
      threatHeight = 31,
      showLevel = true
    },
    {
      creatureTypes = {1743641251, 2852090628},
      framePath = "lyshineui/images/markers/marker_healthBarFrameSoloPlus.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_dungeonMinus",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameSoloPlus.dds",
      isBoss = false,
      levelOffsetPosY = 17,
      healthHeightOffset = 11,
      threatHeight = 26,
      showLevel = true
    },
    {
      creatureTypes = {1073356688},
      framePath = "lyshineui/images/markers/marker_healthBarFrameDungeon.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_dungeon",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameGroup.dds",
      isBoss = false,
      levelOffsetPosY = 23,
      healthHeightOffset = 16,
      threatHeight = 31,
      showLevel = true
    },
    {
      creatureTypes = {
        2699750651,
        2391703446,
        530135454
      },
      framePath = "lyshineui/images/markers/marker_healthBarFrameGroupPlus.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_groupPlus",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameGroupPlus.dds",
      isBoss = false,
      levelOffsetPosY = 23,
      healthHeightOffset = 16,
      threatHeight = 31,
      showLevel = true
    },
    {
      creatureTypes = {3438364633, 3075236427},
      framePath = "lyshineui/images/markers/marker_healthBarFrameBoss.dds",
      levelFrame = "lyshineui/images/markers/marker_ai_level_bg_boss",
      staminaFrame = "lyshineui/images/markers/marker_staminaBarFrameBoss.dds",
      isBoss = true,
      levelOffsetPosY = 23,
      healthHeightOffset = 16,
      threatHeight = 31,
      showLevel = true
    }
  }
  self.healthBarPulseColorFriendly = self.UIStyle.COLOR_WHITE
  self.healthBarPulseColorEnemy = self.UIStyle.COLOR_RED
  self.markerClass = UiMarkerBus.Event.GetMarker(self.entityId)
  self.dataPathPrefix = dataPath
  local isLowDetail = self:IsPlayerLowDetail()
  UiElementBus.Event.SetIsEnabled(self.Properties.ScreenStates.OffScreen, false)
  self.dataLayer:RegisterAndExecuteDataCallback(self, self.dataPathPrefix .. ".PrevLodLevel", function(self, prevLodLevel)
    self.prevLodLevel = prevLodLevel
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".IsVisible", self.SetIsVisible)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".Type", self.SetType)
  self.dataLayer:RegisterAndExecuteDataCallback(self, self.dataPathPrefix .. ".MarkerComponentId", function(self, markerId)
    if not markerId then
      return
    end
    self.markerId = markerId
    self.markerIdStr = tostring(markerId)
    self.markerClass:Initialize(markerId)
    self.isFirstHealthUpdate = true
  end)
  self.dataLayer:RegisterDataCallback(self, dataPath .. ".StopUpdate", function(self, _)
    self.markerClass:Uninitialize()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.nameplateStatusEffects", function(self, statusEffectsEnabled)
    self.statusEffectsEnabled = statusEffectsEnabled
    UiElementBus.Event.SetIsEnabled(self.Properties.StatusEffects, statusEffectsEnabled)
    if statusEffectsEnabled and self.Properties.StatusEffects:IsValid() then
      local statusEffects = UiElementBus.Event.GetChildren(self.Properties.StatusEffects)
      for i = 1, #statusEffects do
        local effect = self.registrar:GetEntityTable(statusEffects[i])
        effect:InitializeToMarkerDatapath(self.dataPathPrefix, i)
        effect:SetVisibilityCallback(self.OnStatusEffectVisibilityChanged, self)
      end
    end
  end)
  if not isLowDetail then
    self.staminaBarHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Player.StaminaBar)
    self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".HealthMax", function(self, myHealth)
      if self.typeInfo and self.typeInfo.scaleHealthBar then
        local averageHealth = AiHealthDataManagerBus.Broadcast.GetAverageHealth()
        local scaleFactor = (myHealth - averageHealth) / averageHealth
        scaleFactor = Clamp((scaleFactor + 1) / 2, 0, 1)
        local healthWidth = scaleFactor * (self.typeInfo.maxHealthWidth - self.typeInfo.minHealthWidth) + self.typeInfo.minHealthWidth
        self.healthWidth = healthWidth
      end
    end)
    self.dataLayer:RegisterAndExecuteDataCallback(self, self.dataPathPrefix .. ".EnemyDifficulty", function(self, creatureDifficultyCrcValue)
      if not creatureDifficultyCrcValue then
        return
      end
      self.creatureDifficultyCrcValue = creatureDifficultyCrcValue
      self:RefreshAiNameplate()
    end)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".EntityName", self.OnEntityNameChanged)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".PlayerTitle", function(self, playerTitleId)
    if playerTitleId and (not self.playerTitleId or self.playerTitleId ~= playerTitleId) then
      self.playerTitleId = playerTitleId
      local neutralTitleId = JavSocialComponentBus.Broadcast.GetNeutralTitleId(playerTitleId)
      if neutralTitleId ~= 2140143823 then
        local currentPronounType = JavSocialComponentBus.Broadcast.GetPronounTypeFromPronounTitleId(playerTitleId)
        local titleData = JavSocialComponentBus.Broadcast.GetTitleData(neutralTitleId)
        self.title = TitleSection:GetGenderedTitleString(currentPronounType, titleData)
      else
        self.title = nil
      end
      self:UpdatePlayerTitle()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".PlayerId", function(self, playerId)
    if not playerId then
      return
    end
    self.isPlayer = true
    self.playerId = playerId
    UiTextBus.Event.SetText(self.Properties.Title, self.playerId.playerName)
    UiElementBus.Event.SetIsEnabled(self.Properties.Title, true)
    self:UpdateMyPvpFlag(self.myPvpFlag)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".StaminaBaseMax", function(self, staminaBaseMax)
    self.staminaBaseMax = staminaBaseMax
    self:UpdateStaminaVisibility()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.nameplateStamina", function(self, staminaEnabled)
    self.staminaEnabled = staminaEnabled
    UiElementBus.Event.SetIsEnabled(self.Properties.Player.StaminaBar, staminaEnabled == true)
    if staminaEnabled and self.Properties.Player.StaminaBar:IsValid() then
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".StaminaPercent", self.UpdateStaminaPercent)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".CrestData", self.UpdateCrestData)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".IsGuildMate", self.UpdateGuildState)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".IsDead", self.UpdateIsDead)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".InDeathsDoorTimeFull", function(self, deathsDoorFullTime)
    self.deathsDoorFullTime = deathsDoorFullTime
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".InDeathsDoor.TimeRemaining", function(self, timeRemaining)
    self.deathsDoorTime = timeRemaining
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".InDeathsDoor", self.UpdateDeathsDoor)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".IsStreaming", self.UpdateStreaming)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".Level", self.UpdateLevel)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".SkipDeathsDoor", self.UpdateSkipDeathsDoor)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".IsPvpFlagged", self.UpdateTargetPvpFlag)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PvpFlag", self.UpdateMyPvpFlag)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".GuildId", self.UpdateGuildId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".RaidId", self.UpdateRaidId)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", self.UpdateGuildWarState)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".RankName", self.UpdateRankName)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".GuildName", self.UpdateGuildName)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".GroupDisplayId", self.UpdateGroup)
  self.dataLayer:RegisterAndExecuteDataCallback(self, self.dataPathPrefix .. ".HealthPercent", self.UpdateHealthPercent)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".IsTargetActive", self.UpdateTargetActive)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".HasVitals", self.UpdateHasVitals)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".GameModeEntityId", self.UpdateGameMode)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".IsTargetingPlayer", self.UpdateIsTargetingPlayer)
  if not isLowDetail then
    self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".FocusState", self.UpdateFocusState)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".StatusEffectsText", self.UpdateStatusEffectsText)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".IsTargetTagged", function(self, isTargetTagged)
    self:SetTargetTaggedVisible(isTargetTagged)
  end)
  local ObjectiveTypeData = RequireScript("LyShineUI.Objectives.ObjectiveTypeData")
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".IsMissionTarget", function(self, isMissionTarget)
    self.isMissionTarget = isMissionTarget ~= nil and isMissionTarget ~= -1
    UiElementBus.Event.SetIsEnabled(self.Properties.ObjectiveIcon, self.isMissionTarget)
    if self.isMissionTarget then
      local objectiveTypeData = ObjectiveTypeData:GetType(isMissionTarget)
      UiImageBus.Event.SetSpritePathname(self.Properties.ObjectiveIcon, objectiveTypeData.iconPath)
      UiImageBus.Event.SetColor(self.Properties.ObjectiveIcon, objectiveTypeData.iconColor)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, localPlayerFactionType)
    self.localPlayerFactionType = localPlayerFactionType
    if self.isPlayer then
      self:SetPrioritizedPlayerNameTextColor()
      self:SetPrioritizedPlayerHealthBarColor()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".FactionType", function(self, factionType)
    if not factionType then
      return
    end
    self.factionType = factionType
    local factionData = factionCommon.factionInfoTable[factionType]
    UiElementBus.Event.SetIsEnabled(self.Properties.Player.FactionIconContainer, factionData ~= nil)
    if factionData then
      local factionImage = factionData.crestBgSmall
      local factionColorBg = factionData.crestBgColor
      local factionImageOutline = factionData.crestFgSmallOutline
      local enableGuildForeground = self.guildName ~= ""
      if not enableGuildForeground then
        factionImage = factionData.crestFgSmall
        UiElementBus.Event.SetIsEnabled(self.Properties.Player.FactionIconBack, true)
        UiImageBus.Event.SetSpritePathname(self.Properties.Player.FactionIconBack, factionImageOutline)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.Player.FactionIconBack, false)
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.Player.FactionIconFront, factionImage)
      UiImageBus.Event.SetColor(self.Properties.Player.FactionIconFront, factionColorBg)
    end
    self:SetPrioritizedPlayerNameTextColor()
    self:SetPrioritizedPlayerHealthBarColor()
    self:UpdateIsShowingGuildCrest()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HealingTarget.Name", function(self, name)
    if name and 0 < #name then
      self.isUsingTargetedHealing = true
    else
      self.isUsingTargetedHealing = false
    end
    if self.isPlayer then
      self:UpdateSecondRowGuildNameOrHealthbar(true)
      self:SetPrioritizedPlayerNameTextColor()
      self:SetPrioritizedPlayerHealthBarColor()
    end
  end)
end
function Marker:RefreshAiNameplate()
  self.refreshAiNameplate = true
end
function Marker:UpdateAiNameplate()
  if not self.refreshAiNameplate then
    return
  end
  self.refreshAiNameplate = false
  local creatureDifficultyCrcValue = self.creatureDifficultyCrcValue
  local difficultyFrame = self.defaultAiDifficultyIconData.framePath
  local levelFrame = self.defaultAiDifficultyIconData.levelFrame
  local levelOffsetPosY = self.defaultAiDifficultyIconData.levelOffsetPosY
  local threatHeight = self.defaultAiDifficultyIconData.threatHeight
  local healthHeightOffset = self.defaultAiDifficultyIconData.healthHeightOffset
  local showLevel = true
  local isBoss = false
  local staminaFrame = self.defaultAiDifficultyIconData.staminaFrame
  for _, difficultyData in ipairs(self.aiDifficultyIcons) do
    for _, creatureType in pairs(difficultyData.creatureTypes) do
      if creatureType == creatureDifficultyCrcValue then
        difficultyFrame = difficultyData.framePath
        if self.affiliation and self.affiliation == eTemporaryAffiliationRelationship_Friendly and difficultyData.allyFrame then
          levelFrame = difficultyData.allyFrame
        else
          levelFrame = difficultyData.levelFrame
        end
        levelOffsetPosY = difficultyData.levelOffsetPosY
        threatHeight = difficultyData.threatHeight
        healthHeightOffset = difficultyData.healthHeightOffset
        staminaFrame = difficultyData.staminaFrame
        showLevel = difficultyData.showLevel
        isBoss = difficultyData.isBoss
        break
      end
    end
  end
  self.isBoss = isBoss
  local levelTextColor = self.isBoss and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_BLACK
  UiTextBus.Event.SetColor(self.Properties.Player.Glory.LevelText, levelTextColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.Player.Glory.LevelText, not self.skipDeathsDoor)
  if difficultyFrame then
    UiImageBus.Event.SetSpritePathname(self.Properties.HealthBarFrame, difficultyFrame)
  end
  if levelFrame then
    levelFrame = self.skipDeathsDoor and levelFrame .. self.NAMEPLATE_LEVEL_BG_AI_SKIP_DEATHS_DOOR or levelFrame .. self.NAMEPLATE_LEVEL_BG_AI_NORMAL
    UiImageBus.Event.SetSpritePathname(self.Properties.Player.Glory.LevelBg, levelFrame)
  end
  if staminaFrame and self.Properties.Player.StaminaBarBg then
    UiImageBus.Event.SetSpritePathname(self.Properties.Player.StaminaBarBg, staminaFrame)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Player.Glory.GloryContainer, showLevel)
  if levelOffsetPosY then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Player.Glory.GloryContainer, levelOffsetPosY)
    self.levelOffsetPosYNoStamina = levelOffsetPosY
  end
  if threatHeight then
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.AiThreatIndicator, threatHeight)
    self.aiThreatHeight = threatHeight
  end
  if self.healthWidth then
    self:SetHealthWidth(self.healthWidth, healthHeightOffset)
  end
end
function Marker:SetHealthWidth(healthWidth, healthHeightOffset)
  self.healthWidth = healthWidth
  if self.Properties.Player.IsAi then
    local healthBarFrameOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.HealthBarFrame)
    local threatOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.AiThreatIndicator)
    healthBarFrameOffsets.right = 7
    healthBarFrameOffsets.left = -7
    threatOffsets.right = 10
    threatOffsets.left = -10
    if self.isBoss then
      healthWidth = healthWidth + 125
      healthBarFrameOffsets.right = 16
      healthBarFrameOffsets.left = -16
      threatOffsets.right = 1
      threatOffsets.left = -1
    end
    UiTransform2dBus.Event.SetOffsets(self.Properties.HealthBarFrame, healthBarFrameOffsets)
    UiTransform2dBus.Event.SetOffsets(self.Properties.AiThreatIndicator, threatOffsets)
    if healthHeightOffset then
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.HealthBarBg, healthHeightOffset)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.HealthBarFill, healthHeightOffset)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.HealthBarDeltaFill, healthHeightOffset)
      if self.Properties.Player.StaminaBar then
        UiTransformBus.Event.SetLocalPositionY(self.Properties.Player.StaminaBar, healthHeightOffset + 1)
      end
    end
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Title, healthWidth)
  else
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.HealthBarFrame, healthWidth)
  end
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.HealthBar, healthWidth)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.HealthBarBg, healthWidth - 6)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.HealthBarFill, healthWidth - 6)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.HealthBarDeltaFill, healthWidth - 6)
  if self.Properties.Player.StaminaBar then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Player.StaminaBar, healthWidth)
  end
  if self.Properties.Player.StaminaBarBg then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Player.StaminaBarBg, healthWidth + 14)
  end
  if self.Properties.Player.StaminaBarFill then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Player.StaminaBarFill, healthWidth - 8)
  end
end
function Marker:SetType(typeName)
  if typeName then
    self.originalTypeInfo = markerTypeData:GetTypeInfo(typeName)
    self.typeInfo = ShallowCopy(self.originalTypeInfo)
    local useEntityName = self.typeInfo.useEntityName == true
    UiElementBus.Event.SetIsEnabled(self.Properties.Title, useEntityName)
    self.shouldTick = self.typeInfo.timeToFadeHealth ~= nil
    if self.shouldTick and not self.tickBusHandler then
      self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
    elseif not self.shouldTick and self.tickBusHandler then
      DynamicBus.UITickBus.Disconnect(self.entityId, self)
      self.tickBusHandler = nil
    end
  end
end
function Marker:UpdateStatusEffectsText(statusEffectsText)
  if not statusEffectsText or not self.Properties.StatusEffectsText:IsValid() then
    return
  end
  local showStatusEffectsText = 0 < #statusEffectsText
  UiElementBus.Event.SetIsEnabled(self.Properties.StatusEffectsText, showStatusEffectsText)
  if showStatusEffectsText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.StatusEffectsText, statusEffectsText, eUiTextSet_SetAsIs)
  end
  self.showStatusEffectsText = showStatusEffectsText
  self:UpdateVerticalPositions()
end
function Marker:SetTargetTaggedVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.TargetTaggedIconHolder, true)
    if not self.timelineTaggedArrow then
      self.timelineTaggedArrow = self.tweener:TimelineCreate()
      self.timelineTaggedArrow:Add(self.Properties.TargetTaggedArrow1, 0.35, {y = -10})
      self.timelineTaggedArrow:Add(self.Properties.TargetTaggedArrow1, 0.05, {y = -10})
      self.timelineTaggedArrow:Add(self.Properties.TargetTaggedArrow1, 0.55, {
        y = 0,
        onComplete = function()
          self.timelineTaggedArrow:Play()
        end
      })
    end
    local animDuartion = 0.25
    local arrowAlpha = 0.6
    self.tweener:Play(self.Properties.TargetTaggedArrow1, animDuartion, {opacity = 0, y = -50}, {
      opacity = arrowAlpha,
      y = 0,
      ease = "QuadOut"
    })
    self.tweener:Play(self.Properties.TargetTaggedArrow1, 0.1, {
      opacity = arrowAlpha,
      ease = "QuadOut",
      delay = animDuartion,
      onComplete = function()
        self.timelineTaggedArrow:Play()
      end
    })
    self.audioHelper:PlaySound(self.audioHelper.Ping_TargetDrop)
  else
    self.tweener:Play(self.Properties.TargetTaggedArrow1, 0.15, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        if self.timelineTaggedArrow then
          self.timelineTaggedArrow:Stop()
        end
        UiElementBus.Event.SetIsEnabled(self.Properties.TargetTaggedIconHolder, false)
      end
    })
  end
end
function Marker:OnEntityNameChanged(entityName)
  entityName = entityName or ""
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, entityName, eUiTextSet_SetLocalized)
end
function Marker:UpdateFocusState(hasFocus)
  if hasFocus == nil then
    return
  end
  self.hasFocus = hasFocus
  local interactStates = self.states.interactFocusState
  if not self.originalTypeInfo and self.markerId then
    self:SetType(MarkerRequestBus.Event.GetType(self.markerId))
  end
  if self.originalTypeInfo then
    self:SetState(interactStates, self.hasFocus and interactStates.stateNames.Focus_Enter or interactStates.stateNames.Focus_Exit)
  end
  if self.interactTypeChangedCallbackData and self.typeInfo then
    self.interactTypeChangedCallbackData.callback(self.interactTypeChangedCallbackData.callingSelf, self.typeInfo.useGatherableInteract, self.hasFocus, self.markerIdStr)
  end
end
function Marker:UpdateTargetActive(isActive)
  if isActive == nil then
    return
  end
  local targetStates = self.states.targetActiveState
  self:SetState(targetStates, isActive and targetStates.stateNames.TargetActive or targetStates.stateNames.TargetInactive)
end
function Marker:SetHealthState(health, isFirstUpdate)
  local healthStates = self.states.healthStates
  local stateIndex = -1
  if health <= 0 then
    stateIndex = healthStates.stateNames.No_Health
  elseif health <= self.criticalHealthPercent then
    stateIndex = healthStates.stateNames.Critical_Health
  elseif health <= 0.5 then
    stateIndex = healthStates.stateNames.LessHalf_Health
  elseif 1 <= health then
    stateIndex = healthStates.stateNames.Full_Health
  elseif 0.5 < health then
    stateIndex = healthStates.stateNames.GreaterHalf_Health
  end
  if 0 <= stateIndex then
    self:SetState(healthStates, stateIndex, isFirstUpdate)
  end
end
function Marker:SetIsVisible(isVisible)
  local isEnabled = isVisible == true
  UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
  self.currentVisibility = isEnabled
  if isEnabled then
    if self.shouldTick and not self.tickBusHandler then
      self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
    end
    self:UpdatePlayerNameTextColor()
    self:UpdatePlayerHealthBarColor()
    local animDuration = 0.25
    local scaleGlorySmall = 0.7
    local scaleGloryMedium = 1
    local scaleGloryFull = 1
    local sizeCrestSmall = 30
    local sizeCrestMedium = 42
    local sizeCrestFull = 42
    if self:IsPlayerLowDetail() then
      if self.prevLodLevel ~= self.PREVIOUS_LOD_LEVEL_MEDIUM and self.prevLodLevel ~= self.PREVIOUS_LOD_LEVEL_FULL then
        self.tweener:Set(self.Properties.Player.PlayerNameContainer, zeroOpacityTable)
        self.tweener:Set(self.Properties.Player.GuildNameContainer, zeroOpacityTable)
        self.tweener:PlayC(self.Properties.Player.PlayerNameContainer, 0.25, tweenerCommon.fadeInQuadOut)
        self.tweener:PlayC(self.Properties.Player.GuildNameContainer, 0.25, tweenerCommon.fadeInQuadOut)
      end
      if self.isHealthShowing then
        self.tweener:PlayC(self.Properties.HealthBar, 0.25, tweenerCommon.fadeInQuadOut)
      else
        self.tweener:Stop(self.Properties.HealthBar)
        self.tweener:Set(self.Properties.HealthBar, zeroOpacityTable)
      end
      if self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_NONE then
        self.tweener:Set(self.Properties.Player.GuildCrest.CrestContainer, {
          opacity = 0,
          w = sizeCrestSmall,
          h = sizeCrestSmall
        })
        self.tweener:PlayC(self.Properties.Player.GuildCrest.CrestContainer, animDuration, tweenerCommon.markerCrestMedium)
        self.tweener:Set(self.Properties.Player.Glory.GloryContainer, {scaleX = scaleGlorySmall, scaleY = scaleGlorySmall})
        self.tweener:PlayC(self.Properties.Player.Glory.GloryContainer, animDuration, tweenerCommon.markerGloryMedium)
        self.tweener:Set(self.Properties.Player.FactionIconContainer, {
          opacity = 0,
          w = sizeCrestSmall,
          h = sizeCrestSmall
        })
        self.tweener:PlayC(self.Properties.Player.FactionIconContainer, animDuration, tweenerCommon.markerCrestMedium)
      elseif self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_FULL then
        self.tweener:Set(self.Properties.Player.GuildCrest.CrestContainer, {w = sizeCrestFull, h = sizeCrestFull})
        self.tweener:PlayC(self.Properties.Player.GuildCrest.CrestContainer, animDuration, tweenerCommon.markerCrestMedium)
        self.tweener:Set(self.Properties.Player.Glory.GloryContainer, {scaleX = scaleGloryFull, scaleY = scaleGloryFull})
        self.tweener:PlayC(self.Properties.Player.Glory.GloryContainer, animDuration, tweenerCommon.markerGloryMedium)
        self.tweener:Set(self.Properties.Player.FactionIconContainer, {w = sizeCrestFull, h = sizeCrestFull})
        self.tweener:PlayC(self.Properties.Player.FactionIconContainer, animDuration, tweenerCommon.markerCrestMedium)
      elseif self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_MEDIUM then
        self.tweener:Set(self.Properties.Player.GuildCrest.CrestContainer, {
          opacity = 1,
          w = sizeCrestMedium,
          h = sizeCrestMedium
        })
        self.tweener:Set(self.Properties.Player.Glory.GloryContainer, {
          opacity = 1,
          scaleX = scaleGloryMedium,
          scaleY = scaleGloryMedium
        })
        self.tweener:Set(self.Properties.Player.FactionIconContainer, {
          opacity = 1,
          w = sizeCrestMedium,
          h = sizeCrestMedium
        })
      elseif self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_SMALL then
        self.tweener:Set(self.Properties.Player.GuildCrest.CrestContainer, {
          opacity = 0,
          w = sizeCrestSmall,
          h = sizeCrestSmall
        })
        self.tweener:PlayC(self.Properties.Player.GuildCrest.CrestContainer, animDuration, tweenerCommon.markerCrestMedium)
        self.tweener:Set(self.Properties.Player.Glory.GloryContainer, {scaleX = scaleGlorySmall, scaleY = scaleGlorySmall})
        self.tweener:PlayC(self.Properties.Player.Glory.GloryContainer, animDuration, tweenerCommon.markerGloryMedium)
        self.tweener:Set(self.Properties.Player.FactionIconContainer, {
          opacity = 0,
          w = sizeCrestSmall,
          h = sizeCrestSmall
        })
        self.tweener:PlayC(self.Properties.Player.FactionIconContainer, animDuration, tweenerCommon.markerCrestMedium)
      end
    end
    if self:IsPlayerFullDetail() then
      if self.prevLodLevel ~= self.PREVIOUS_LOD_LEVEL_MEDIUM and self.prevLodLevel ~= self.PREVIOUS_LOD_LEVEL_FULL then
        self.tweener:Set(self.Properties.Player.PlayerNameContainer, zeroOpacityTable)
        self.tweener:Set(self.Properties.Player.GuildNameContainer, zeroOpacityTable)
        self.tweener:PlayC(self.Properties.Player.PlayerNameContainer, 0.25, tweenerCommon.fadeInQuadOut)
        self.tweener:PlayC(self.Properties.Player.GuildNameContainer, 0.25, tweenerCommon.fadeInQuadOut)
      end
      if self.isHealthShowing then
        self.tweener:PlayC(self.Properties.HealthBar, 0.25, tweenerCommon.fadeInQuadOut)
      else
        self.tweener:Stop(self.Properties.HealthBar)
        self.tweener:Set(self.Properties.HealthBar, zeroOpacityTable)
      end
      if self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_NONE then
        self.tweener:Set(self.Properties.Player.GuildCrest.CrestContainer, {
          opacity = 0,
          w = sizeCrestMedium,
          h = sizeCrestMedium
        })
        self.tweener:PlayC(self.Properties.Player.GuildCrest.CrestContainer, animDuration, tweenerCommon.markerCrestFull)
        self.tweener:Set(self.Properties.Player.Glory.GloryContainer, {scaleX = scaleGlorySmall, scaleY = scaleGlorySmall})
        self.tweener:PlayC(self.Properties.Player.Glory.GloryContainer, animDuration, tweenerCommon.markerGloryFull)
        self.tweener:Set(self.Properties.Player.FactionIconContainer, {
          opacity = 0,
          w = sizeCrestMedium,
          h = sizeCrestMedium
        })
        self.tweener:PlayC(self.Properties.Player.FactionIconContainer, animDuration, tweenerCommon.markerCrestFull)
      elseif self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_FULL then
        self.tweener:Set(self.Properties.Player.GuildCrest.CrestContainer, {
          opacity = 1,
          w = sizeCrestFull,
          h = sizeCrestFull
        })
        self.tweener:Set(self.Properties.Player.Glory.GloryContainer, {
          opacity = 1,
          scaleX = scaleGloryFull,
          scaleY = scaleGloryFull
        })
        self.tweener:Set(self.Properties.Player.FactionIconContainer, {
          opacity = 1,
          w = sizeCrestFull,
          h = sizeCrestFull
        })
      elseif self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_MEDIUM then
        self.tweener:Set(self.Properties.Player.GuildCrest.CrestContainer, {w = sizeCrestMedium, h = sizeCrestMedium})
        self.tweener:PlayC(self.Properties.Player.GuildCrest.CrestContainer, animDuration, tweenerCommon.markerCrestFull)
        self.tweener:Set(self.Properties.Player.Glory.GloryContainer, {scaleX = scaleGloryMedium, scaleY = scaleGloryMedium})
        self.tweener:PlayC(self.Properties.Player.Glory.GloryContainer, animDuration, tweenerCommon.markerGloryFull)
        self.tweener:Set(self.Properties.Player.FactionIconContainer, {w = sizeCrestMedium, h = sizeCrestMedium})
        self.tweener:PlayC(self.Properties.Player.FactionIconContainer, animDuration, tweenerCommon.markerCrestFull)
      elseif self.prevLodLevel == self.PREVIOUS_LOD_LEVEL_SMALL then
        self.tweener:Set(self.Properties.Player.GuildCrest.CrestContainer, {
          opacity = 0,
          w = sizeCrestMedium,
          h = sizeCrestMedium
        })
        self.tweener:PlayC(self.Properties.Player.GuildCrest.CrestContainer, animDuration, tweenerCommon.markerCrestFull)
        self.tweener:Set(self.Properties.Player.Glory.GloryContainer, {scaleX = scaleGlorySmall, scaleY = scaleGlorySmall})
        self.tweener:PlayC(self.Properties.Player.Glory.GloryContainer, animDuration, tweenerCommon.markerGloryFull)
        self.tweener:Set(self.Properties.Player.FactionIconContainer, {
          opacity = 0,
          w = sizeCrestMedium,
          h = sizeCrestMedium
        })
        self.tweener:PlayC(self.Properties.Player.FactionIconContainer, animDuration, tweenerCommon.markerCrestFull)
      end
    end
    if self.markerId then
      DamageNumbersAnchorBus.Event.ConnectMarkerId(self.Properties.DamageTextAnchor, self.markerId)
    end
  else
    if self.tickBusHandler then
      DynamicBus.UITickBus.Disconnect(self.entityId, self)
      self.tickBusHandler = nil
    end
    if self.markerId then
      DamageNumbersAnchorBus.Event.DisconnectMarkerId(self.Properties.DamageTextAnchor, self.markerId)
    end
    if self.healthBarColorDataPath then
      LyShineDataLayerBus.Broadcast.Delete(self.healthBarColorDataPath)
      self.healthBarColorDataPath = nil
    end
    if self.targetNameColorDataPath then
      LyShineDataLayerBus.Broadcast.Delete(self.targetNameColorDataPath)
      self.targetNameColorDataPath = nil
    end
  end
end
function Marker:UpdateIsShowingGuildCrest()
  local showGuildCrest = not self.isInWar
  UiElementBus.Event.SetIsEnabled(self.Properties.Player.GuildCrest.CrestContainer, showGuildCrest)
  UiElementBus.Event.SetIsEnabled(self.Properties.Player.GuildNameContainer, showGuildCrest)
  if self.factionType then
    UiElementBus.Event.SetIsEnabled(self.Properties.Player.FactionIconContainer, not self.isInWar)
  end
  if self:IsPlayerMediumDetail() then
    local levelScale = showGuildCrest and 1 or 1.15
    UiTransformBus.Event.SetScale(self.Properties.Player.Glory.GloryContainer, Vector2(levelScale, levelScale))
    if showGuildCrest then
      self:ReCenterGuildNameplate()
    else
      self:ReCenterNameplate()
    end
  else
    self:SetPlayerNamePosition()
  end
end
function Marker:SetPlayerNamePosition()
  if not self:IsPlayerMediumDetail() then
    local showGuildCrest = not self.isInWar
    local hasGuildName = self.guildName ~= nil and self.guildName ~= ""
    local hasTitle = self.title ~= nil and self.title ~= ""
    local hasEmptyTitleLine = not hasGuildName and not hasTitle
    local initPlayerNamePosY = -44
    local initPlayerNamePosX = 41
    local initGuildNamePosY = -24
    local initTwitchPosY = 10
    local initStatusEffectsPosX = 146
    local initStatusEffectsPosY = -3
    local offsetPosY = 17
    local offsetPosX = -10
    local newNamePosY = initPlayerNamePosY
    local newNamePosX = initPlayerNamePosX
    local newGuildNamePosY = initGuildNamePosY
    local newTwitchPosY = initTwitchPosY
    local newStatusEffectsPosX = initStatusEffectsPosX
    local newStatusEffectsPosY = initStatusEffectsPosY
    local deathsDoorInteractOffsetPosY = -50
    if not showGuildCrest or hasEmptyTitleLine then
      newNamePosY = initPlayerNamePosY + offsetPosY
      newNamePosX = initPlayerNamePosX + offsetPosX
    end
    if not self.isHealthShowing then
      local isStreaming = self:IsInState(self.states.streamingState, "Streaming")
      local playerNamePosY = isStreaming and -30 or -22
      local guildNamePosY = isStreaming and -10 or -2
      newStatusEffectsPosY = isStreaming and 10 or 17
      local namePosX = 31
      if not showGuildCrest or hasEmptyTitleLine then
        playerNamePosY = -13
        newStatusEffectsPosY = 10
      end
      newNamePosY = playerNamePosY
      newNamePosX = namePosX
      newGuildNamePosY = guildNamePosY
      newTwitchPosY = initTwitchPosY
      newStatusEffectsPosX = isStreaming and 104 or 30
    end
    local interactStates = self.states.interactFocusState
    if self:IsInState(self.states.interactFocusState, "Focus_Enter") then
      newNamePosY = newNamePosY + deathsDoorInteractOffsetPosY
      newGuildNamePosY = newGuildNamePosY + deathsDoorInteractOffsetPosY
      newTwitchPosY = newTwitchPosY + deathsDoorInteractOffsetPosY
    end
    self.tweener:Set(self.Properties.Player.PlayerNameContainer, {y = newNamePosY, x = newNamePosX})
    self.tweener:Set(self.Properties.Player.GuildNameContainer, {y = newGuildNamePosY, x = newNamePosX})
    self.tweener:Set(self.Properties.Player.Streaming.StreamingContainer, {y = newTwitchPosY})
    self.tweener:Set(self.Properties.StatusEffects, {x = newStatusEffectsPosX, y = newStatusEffectsPosY})
  end
end
function Marker:UpdateDeathsDoor(inDeathsDoor)
  UiElementBus.Event.SetIsEnabled(self.Properties.Player.DeathsDoor.DeathsDoorContainer, inDeathsDoor)
  if inDeathsDoor then
    local deadStates = self.states.deadStates
    self:SetState(deadStates, deadStates.stateNames.InDeathsDoor)
    self:SetState(self.states.deathsDoor, self.states.deathsDoor.stateNames.EnterDeathsDoor)
  elseif self:IsInState(self.states.deathsDoor, "EnterDeathsDoor") then
    local deathsDoor = self.states.deathsDoor
    self:SetState(deathsDoor, deathsDoor.stateNames.ExitDeathsDoor)
  else
    self.states.deathsDoor.currentState = self.states.deathsDoor.stateNames.ExitDeathsDoor
  end
end
function Marker:UpdateIsDead(isDead)
  if isDead == nil then
    return
  end
  local deadStates = self.states.deadStates
  self:SetState(deadStates, isDead and deadStates.stateNames.Dead or deadStates.stateNames.Alive)
  self:UpdateSecondRowGuildNameOrHealthbar(true)
end
function Marker:UpdateTargetPvpFlag(isTargetPvpFlagEnabled)
  if isTargetPvpFlagEnabled == nil then
    return
  end
  local targetPvpFlag = self.states.targetPvpFlag
  self:SetState(targetPvpFlag, isTargetPvpFlagEnabled and targetPvpFlag.stateNames.TargetPvpFlagOn or targetPvpFlag.stateNames.TargetPvpFlagOff)
end
function Marker:UpdateMyPvpFlag(pvpFlag)
  self.myPvpFlag = pvpFlag
  if self.isPlayer then
    if pvpFlag == nil then
      return
    end
    local isPvpEnabled = pvpFlag == ePvpFlag_On
    local myPvpFlag = self.states.myPvpFlag
    self:SetState(myPvpFlag, isPvpEnabled and myPvpFlag.stateNames.MyPvpFlagOn or myPvpFlag.stateNames.MyPvpFlagOff)
  end
end
function Marker:UpdateStreaming(isStreaming)
  if self.states.streamingState.currentState ~= 0 or isStreaming then
    local streamingStates = self.states.streamingState
    self:SetState(streamingStates, isStreaming and streamingStates.stateNames.Streaming or streamingStates.stateNames.NotStreaming)
  end
end
function Marker:UpdateLevel(level)
  if level then
    UiTextBus.Event.SetText(self.Properties.Player.Glory.LevelText, tostring(level))
    if not self.isPlayer then
      local difficultyTextColor = DifficultyColors:GetColor(level)
      UiTextBus.Event.SetColor(self.Properties.Title, difficultyTextColor)
    end
  end
end
function Marker:UpdateSkipDeathsDoor(skip)
  self.skipDeathsDoor = skip
end
function Marker:UpdateAffiliation(affiliation)
  if self.affiliation == affiliation then
    return
  end
  self.affiliation = affiliation
  if not self.isPlayer and affiliation == eTemporaryAffiliationRelationship_Friendly then
    UiImageBus.Event.SetSpritePathname(self.Properties.HealthBarFill, self.healthBarFillFriendly)
    UiImageBus.Event.SetSpritePathname(self.Properties.HealthBarBg, self.healthBarBgFriendly)
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.HealthBarFill, self.healthBarFillCanDamagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.HealthBarBg, self.healthBarBgCanDamagePath)
  end
  self:RefreshAiNameplate()
end
function Marker:UpdateHealthPercent(health)
  if not health then
    return
  end
  local isFirstUpdate = self.isFirstHealthUpdate
  local curHealthScale = UiTransformBus.Event.GetScale(self.Properties.HealthBarFill)
  self:SetHealthState(health, isFirstUpdate)
  if health < curHealthScale.x or isFirstUpdate then
    if isFirstUpdate then
      UiTransformBus.Event.SetScaleX(self.Properties.HealthBarDeltaFill, health)
    else
      local delay = self.typeInfo.barVFXDelay
      self.tweener:Play(self.Properties.HealthBarDeltaFill, 0.3, {scaleX = health, delay = delay})
    end
  end
  local healthIdleState = self.states.healthIdleStates
  if isFirstUpdate then
    self:SetState(healthIdleState, health < 1 and healthIdleState.stateNames.Idle_Health_End or healthIdleState.stateNames.Idle_Health_Start, true)
    self.isFirstHealthUpdate = false
    self.timeSinceLastHealthUpdate = 0
  elseif health < curHealthScale.x or health - curHealthScale.x > 0.1 then
    self:SetState(healthIdleState, healthIdleState.stateNames.Idle_Health_End)
    self.timeSinceLastHealthUpdate = 0
  end
  curHealthScale.x = health
  UiTransformBus.Event.SetScale(self.Properties.HealthBarFill, curHealthScale)
end
function Marker:UpdateStaminaVisibility()
  if not self.staminaPercent then
    return false
  end
  local enableStamina = self.isPlayer and self.staminaPercent < 1 or self.staminaBaseMax and 1 < self.staminaBaseMax
  UiElementBus.Event.SetIsEnabled(self.Properties.Player.StaminaBar, self.staminaEnabled and enableStamina)
  return enableStamina
end
function Marker:UpdateStaminaPercent(staminaPercent)
  if staminaPercent then
    UiTransformBus.Event.SetScaleX(self.Properties.Player.StaminaBarFill, staminaPercent)
    self.staminaPercent = staminaPercent
    local enableStamina = self:UpdateStaminaVisibility()
    if self.isPlayer then
      local showStaminaBar = false
      if self:IsInState(self.states.targetPvpFlag, "TargetPvpFlagOn") and self:IsInOpposingFaction() and enableStamina then
        showStaminaBar = true
      end
      if self:IsInState(self.states.duelStates, "Duel_Enter") and enableStamina then
        showStaminaBar = true
      end
      if showStaminaBar then
        self:UpdateSecondRowGuildNameOrHealthbar(true, nil, nil, true)
      end
    end
    if self.Properties.Player.IsAi then
      local levelOffsetPosY = self.levelOffsetPosYNoStamina
      local treatHeight = self.aiThreatHeight
      if enableStamina then
        levelOffsetPosY = levelOffsetPosY + self.staminaBarHeight
        treatHeight = treatHeight + self.staminaBarHeight
      end
      UiTransformBus.Event.SetLocalPositionY(self.Properties.Player.Glory.GloryContainer, levelOffsetPosY)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.AiThreatIndicator, treatHeight)
    end
  end
end
function Marker:ReCenterNameplate()
  if self:IsPlayerMediumDetail() then
    self.tweener:Set(self.Properties.RightSide, {y = -43, x = 54})
  end
end
function Marker:ReCenterGuildNameplate()
  self.tweener:Set(self.Properties.RightSide, {y = -71.5, x = 48.5})
end
function Marker:UpdateGuildWarState()
  if self.typeInfo and self.typeInfo.hasGuildWarData then
    local guildWarStates = self.states.guildWarStates
    local isWarTarget = false
    if not self.raidId or not self.raidId:IsValid() then
      self.isWarFriendly = false
      self.isWarEnemy = false
      self.isInWar = false
    else
      isWarTarget = dominionCommon:IsAtWarWithRaid(self.raidId)
      self.isWarFriendly = dominionCommon:IsFriendlyWithRaid(self.raidId)
      self.isWarEnemy = isWarTarget
      self.isInWar = self.isWarFriendly or self.isWarEnemy
    end
    self.showWarInteractHealthIcon = true
    self:SetState(guildWarStates, isWarTarget and guildWarStates.stateNames.GuildWarOn or guildWarStates.stateNames.GuildWarOff)
    self:UpdateIsShowingGuildCrest()
  end
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-game-mode-outpost-rush") then
    self:UpdateOutpostRushState()
  end
end
function Marker:UpdateOutpostRushState()
  local localPlayerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  if not localPlayerRootEntityId then
    return
  end
  local localPlayerGameModeEntityId = GameModeParticipantComponentRequestBus.Event.GetGameModeEntityId(localPlayerRootEntityId, 2444859928)
  if localPlayerGameModeEntityId and localPlayerGameModeEntityId:IsValid() then
    do
      local dataPathPrefix = "GameMode." .. tostring(localPlayerGameModeEntityId)
      self.dataLayer:RegisterAndExecuteDataObserver(self, dataPathPrefix .. ".ParticipantCount", function(self, count)
        if not count then
          return
        end
        local localPlayerCharacterId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CharacterId")
        local markerTeamIndex, localTeamIndex
        for i = 1, count do
          local participantNode = self.dataLayer:GetDataNode(dataPathPrefix .. ".Participant" .. i)
          local participantCharacterId = participantNode.characterIdString:GetData()
          if participantCharacterId == localPlayerCharacterId then
            localTeamIndex = participantNode.teamIdx:GetData()
          elseif self.playerId and participantCharacterId == self.playerId:GetCharacterIdString() then
            markerTeamIndex = participantNode.teamIdx:GetData()
          end
          if markerTeamIndex and localTeamIndex then
            break
          end
        end
        if not markerTeamIndex and not localTeamIndex then
          return
        end
        self.isWarFriendly = markerTeamIndex and localTeamIndex and markerTeamIndex == localTeamIndex
        self.isWarEnemy = not self.isWarFriendly
        self.isInWar = true
        self.showWarInteractHealthIcon = false
        local guildWarStates = self.states.guildWarStates
        self:SetState(guildWarStates, self.isWarEnemy and guildWarStates.stateNames.GuildWarOn or guildWarStates.stateNames.GuildWarOff)
        self:UpdateIsShowingGuildCrest()
        self.dataLayer:UnregisterObserver(self, dataPathPrefix .. ".ParticipantCount")
      end)
      self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataPathPrefix .. ".Affiliation", self.UpdateAffiliation)
    end
  else
    self:UpdateAffiliation()
    self.dataLayer:UnregisterObserver(self, self.dataPathPrefix .. ".Affiliation")
  end
end
function Marker:UpdateHasVitals(hasVitals)
  self.hasVitals = hasVitals
  if not self.hasVitals then
    UiElementBus.Event.SetIsEnabled(self.Properties.HealthBar, false)
  end
end
function Marker:UpdateGameMode(gameModeEntityId)
  if gameModeEntityId == nil then
    return
  end
  local duelStates = self.states.duelStates
  self.isDuelOpponent = nil
  self:SetPrioritizedPlayerNameTextColor()
  self:SetPrioritizedPlayerHealthBarColor()
  if gameModeEntityId:IsValid() then
    local localRootEntityId = dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    if GameModeParticipantComponentRequestBus.Event.IsInGameMode(localRootEntityId, 2612307810) then
      local localGameModeEntityId = GameModeParticipantComponentRequestBus.Event.GetGameModeEntityId(localRootEntityId, 2612307810)
      local localPlayerIsInDuel = localGameModeEntityId == gameModeEntityId
      if localPlayerIsInDuel then
        do
          local dataPathPrefix = "GameMode." .. tostring(gameModeEntityId)
          self.dataLayer:RegisterAndExecuteDataObserver(self, dataPathPrefix .. ".ParticipantCount", function(self, count)
            if not count then
              return
            end
            local localPlayerCharacterId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CharacterId")
            local markerTeamIndex, localTeamIndex
            for i = 1, count do
              local participantNode = self.dataLayer:GetDataNode(dataPathPrefix .. ".Participant" .. i)
              local participantCharacterId = participantNode.characterIdString:GetData()
              if participantCharacterId == localPlayerCharacterId then
                localTeamIndex = participantNode.teamIdx:GetData()
              elseif participantCharacterId == self.playerId:GetCharacterIdString() then
                markerTeamIndex = participantNode.teamIdx:GetData()
              end
              if markerTeamIndex and localTeamIndex then
                break
              end
            end
            self.isDuelOpponent = markerTeamIndex and localTeamIndex and markerTeamIndex ~= localTeamIndex
            self.dataLayer:UnregisterObserver(self, dataPathPrefix .. ".ParticipantCount")
          end)
        end
      end
    end
    self:SetState(duelStates, duelStates.stateNames.Duel_Enter, true)
  else
    self:SetState(duelStates, duelStates.stateNames.Duel_Exit)
  end
end
function Marker:UpdateIsTargetingPlayer(isTargetingPlayer)
  if isTargetingPlayer == nil then
    return
  end
  self.isTargetingPlayer = isTargetingPlayer
  if self.isTargetingPlayer then
    self.tweener:PlayC(self.Properties.AiThreatIndicator, 0.25, tweenerCommon.fadeInQuadOut)
  else
    self.tweener:PlayC(self.Properties.AiThreatIndicator, 0.25, tweenerCommon.fadeOutQuadOut)
  end
end
function Marker:UpdateGuildId(guildId)
  self.guildId = guildId
  local guildValid = self.guildId and self.guildId:IsValid()
  self:UpdateSecondRowGuildNameOrHealthbar(nil, guildValid)
end
function Marker:UpdateRaidId(raidId)
  self.raidId = raidId
  self:UpdateGuildWarState()
end
function Marker:UpdateRankName(rankName)
  self.rankName = rankName or ""
  self:SetPlayerDescriptionText()
end
function Marker:UpdateGuildName(guildName)
  self.guildName = guildName or ""
  self:SetPlayerDescriptionText()
end
function Marker:UpdatePlayerTitle()
  self:SetPlayerNamePosition()
  self:SetPlayerDescriptionText()
end
function Marker:SetPlayerDescriptionText()
  local locText = ""
  if self:IsPlayerLowDetail() or self:IsPlayerMediumDetail() then
    if self.title ~= nil and self.title ~= "" then
      locText = GetLocalizedReplacementText("@ui_noguildonlytitle", {
        playerTitle = self.title
      })
    end
  elseif self.title ~= nil and self.title ~= "" and self.guildName and self.guildName ~= "" and self.rankName and self.rankName ~= "" then
    locText = GetLocalizedReplacementText("@ui_guildnamewithrankandtitle", {
      guildName = self.guildName,
      rankName = self.rankName,
      playerTitle = self.title
    })
  elseif self.title ~= nil and self.title ~= "" and (self.guildName == nil or self.guildName == "") then
    locText = GetLocalizedReplacementText("@ui_noguildonlytitle", {
      playerTitle = self.title
    })
  elseif (self.title == nil or self.title == "") and self.guildName and self.guildName ~= "" and self.rankName and self.rankName ~= "" then
    locText = GetLocalizedReplacementText("@ui_guildnamewithrank", {
      guildName = self.guildName,
      rankName = self.rankName
    })
  end
  UiTextBus.Event.SetText(self.Properties.Player.GuildName, locText)
  local enableGuildForeground = self.guildName ~= ""
  UiElementBus.Event.SetIsEnabled(self.Properties.Player.GuildCrest.Foreground, enableGuildForeground)
  if self.factionType then
    local factionData = factionCommon.factionInfoTable[self.factionType]
    local factionImageOutline = factionData.crestFgSmallOutline
    local factionImage
    if enableGuildForeground then
      factionImage = factionData.crestBgSmall
      UiElementBus.Event.SetIsEnabled(self.Properties.Player.FactionIconBack, false)
    else
      factionImage = factionData.crestFgSmall
      UiElementBus.Event.SetIsEnabled(self.Properties.Player.FactionIconBack, true)
      UiImageBus.Event.SetSpritePathname(self.Properties.Player.FactionIconBack, factionImageOutline)
    end
    UiImageBus.Event.SetSpritePathname(self.Properties.Player.FactionIconFront, factionImage)
  end
end
function Marker:UpdateGroup(groupDisplayId)
  if groupDisplayId and self.groupDisplayId ~= groupDisplayId then
    self.groupDisplayId = groupDisplayId
    local isThisMarkerInGroup = self.groupDisplayId > 0
    if isThisMarkerInGroup then
      self.groupMemberColor = self.UIStyle.COLOR_GROUP_MEMBERS[self.groupDisplayId]
      self.groupMemberIcon = self.UIStyle.ICONS_GROUP_MEMBERS[self.groupDisplayId]
    end
    local groupFocusState = self.states.groupFocusState
    self:SetState(groupFocusState, isThisMarkerInGroup and groupFocusState.stateNames.Group_Enter or groupFocusState.stateNames.Group_Exit, true)
  end
end
function Marker:UpdateSecondRowGuildNameOrHealthbar(updateHealthBar, showGuildName, showTwitch, showStamina)
  local guildOpacity = 0
  local healthbarOpacity = 0
  local healthAnimDelay = 3
  local twitchOpacity = 0
  if showGuildName then
    guildOpacity = 1
  end
  local showHealthBar
  if updateHealthBar then
    showHealthBar = showStamina or not self:IsInState(self.states.deadStates, "Dead") and not self:IsInState(self.states.healthStates, "Full_Health") and not self:IsInState(self.states.healthStates, "No_Health")
  end
  if self.isUsingTargetedHealing and not self:IsInState(self.states.deadStates, "Dead") and not self:IsInState(self.states.healthStates, "No_Health") then
    showHealthBar = true
  end
  if showHealthBar then
    healthbarOpacity = 1
    healthAnimDelay = 0
  end
  if showTwitch then
    twitchOpacity = 1
  end
  if showGuildName ~= nil and self:IsPlayerMediumDetail() then
    self.tweener:Play(self.Properties.Player.GuildNameContainer, 0.25, {opacity = guildOpacity})
  end
  if showHealthBar ~= nil and self.isHealthShowing ~= showHealthBar then
    self.isHealthShowing = showHealthBar
    self.tweener:Stop(self.Properties.HealthBar)
    if not self:IsPlayerMediumDetail() then
      self.tweener:Play(self.Properties.HealthBar, 0.25, {opacity = healthbarOpacity, ease = "QuadOut"})
    else
      self.tweener:Play(self.Properties.HealthBar, 0.25, {delay = healthAnimDelay, opacity = healthbarOpacity})
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.HealthBar, self.isHealthShowing)
  end
  if showTwitch ~= nil then
    self.isTwitchShowing = showTwitch
    if self:IsPlayerFullDetail() then
      self.tweener:Play(self.Properties.Player.Streaming.StreamingContainer, 0.25, {opacity = twitchOpacity})
    else
      self.tweener:Play(self.Properties.Player.Streaming.StreamingContainer, 0.25, {opacity = twitchOpacity})
    end
  end
  self:SetPlayerNamePosition()
end
function Marker:UpdateGuildState(isGuildMate)
  local playerStates = self.states.playerStates
  self.isGuildMate = isGuildMate
  if isGuildMate then
    self:SetState(playerStates, playerStates.stateNames.GuildMate)
  else
    self:SetState(playerStates, playerStates.stateNames.NotGuildMate)
  end
end
function Marker:UpdateCrestData(crestData)
  if not crestData then
    return
  end
  local bgImage = crestData.backgroundImagePath
  local crestBackgroundPath = GetSmallImagePath(crestData.backgroundImagePath)
  local crestForegroundPath = GetSmallImagePath(crestData.foregroundImagePath)
  local crestBackgroundColor = crestData.backgroundColor
  local crestForegroundColor = crestData.foregroundColor
  if crestBackgroundPath == "" or crestForegroundPath == "" then
    crestBackgroundPath = "lyshineui/images/crests/backgrounds/icon_shield_shape1V1_small.dds"
    local useVarient1 = true
    local crestNum = useVarient1 and 30 or 1
    crestForegroundPath = "lyshineui/images/crests/foregrounds/icon_crest_" .. crestNum .. "_small.dds"
    crestBackgroundColor = useVarient1 and self.UIStyle.COLOR_BLUE_DARK or self.UIStyle.COLOR_GREEN
    crestForegroundColor = useVarient1 and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_TAN
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Player.GuildCrest.Foreground, crestForegroundPath)
  UiImageBus.Event.SetColor(self.Properties.Player.GuildCrest.Foreground, crestForegroundColor)
end
function Marker:IsInState(stateGroup, stateName)
  return stateGroup.currentState == stateGroup.stateNames[stateName]
end
function Marker:GetStateName(stateData, stateIndex)
  for stateName, index in pairs(stateData.stateNames) do
    if stateIndex == index then
      return stateName
    end
  end
end
function Marker:SetState(stateData, stateIndex, forceState)
  local currentState = stateData.currentState
  if self.originalTypeInfo and self.originalTypeInfo.States and (currentState ~= stateIndex or forceState) then
    stateData.currentState = stateIndex
    local stateName = self:GetStateName(stateData, stateIndex)
    local stateInfo = self.originalTypeInfo.States[stateName]
    if not stateInfo then
      return
    end
    local lastFadeDistance = self.typeInfo.fadeDistance
    Merge(self.typeInfo, stateInfo, false, true, true)
    if stateInfo.callbackFunction then
      stateInfo.callbackFunction(self)
    end
  end
end
function Marker:RestoreCurrentState(stateData)
  self:SetState(stateData, stateData.currentState, true)
end
function Marker:SetPrioritizedPlayerNameTextColor()
  self.updatePlayerNameTextColor = true
end
function Marker:SetPrioritizedPlayerHealthBarColor()
  self.updatePlayerHealthBarColor = true
end
function Marker:UpdateOnScreenState()
end
function Marker:OnTick(deltaTime, timePoint)
  self.timeSinceLastHealthUpdate = self.timeSinceLastHealthUpdate + deltaTime
  if self.timeSinceLastHealthUpdate > self.typeInfo.timeToFadeHealth then
    local healthIdleState = self.states.healthIdleStates
    self:SetState(healthIdleState, healthIdleState.stateNames.Idle_Health_Start)
    self.timeSinceLastHealthUpdate = 0
  end
  self:UpdatePlayerNameTextColor()
  self:UpdatePlayerHealthBarColor()
  self:UpdateAiNameplate()
end
function Marker:IsInOpposingFaction()
  return self.localPlayerFactionType ~= self.factionType
end
function Marker:GetLevelBgSprite(path)
  local isStreaming = self:IsInState(self.states.streamingState, "Streaming")
  local isInDuel = self:IsInState(self.states.duelStates, "Duel_Enter")
  if isStreaming and isInDuel then
    return path .. self.NAMEPLATE_LEVEL_BG_STREAMING_DUEL
  elseif isStreaming then
    return path .. self.NAMEPLATE_LEVEL_BG_STREAMING
  elseif isInDuel then
    return path .. self.NAMEPLATE_LEVEL_BG_DUEL
  else
    return path .. self.NAMEPLATE_LEVEL_BG_NORMAL
  end
end
function Marker:UpdatePlayerNameTextColor()
  if self.updatePlayerNameTextColor then
    self.updatePlayerNameTextColor = nil
    if self.isWarFriendly then
      self.typeInfo.nameTextColor = self.UIStyle.COLOR_NAMEPLATE_GROUP
      self.typeInfo.deathsDoorPath = self.DEATHS_DOOR_PARTY
      self.typeInfo.levelBgSprite = self:GetLevelBgSprite(self.NAMEPLATE_LEVEL_BG_PARTY)
      self.typeInfo.levelTextColor = self.UIStyle.COLOR_HEALTHBAR_PVP_FRIENDLY
    elseif self.isWarEnemy then
      self.typeInfo.nameTextColor = self.UIStyle.COLOR_NAMEPLATE_WAR
      self.typeInfo.deathsDoorPath = self.DEATHS_DOOR_WAR
      self.typeInfo.levelBgSprite = self:GetLevelBgSprite(self.NAMEPLATE_LEVEL_BG_WAR)
      self.typeInfo.levelTextColor = self.UIStyle.COLOR_BLACK
    elseif self:IsInState(self.states.duelStates, "Duel_Enter") and self.isDuelOpponent then
      self.typeInfo.nameTextColor = self.UIStyle.COLOR_NAMEPLATE_WAR
      self.typeInfo.deathsDoorPath = self.DEATHS_DOOR_WAR
      self.typeInfo.levelBgSprite = self:GetLevelBgSprite(self.NAMEPLATE_LEVEL_BG_WAR)
      self.typeInfo.levelTextColor = self.UIStyle.COLOR_BLACK
    elseif self:IsInState(self.states.groupFocusState, "Group_Enter") then
      self.typeInfo.nameTextColor = self.UIStyle.COLOR_NAMEPLATE_GROUP
      self.typeInfo.deathsDoorPath = self.DEATHS_DOOR_PARTY
      self.typeInfo.levelBgSprite = self:GetLevelBgSprite(self.NAMEPLATE_LEVEL_BG_PARTY)
      self.typeInfo.levelTextColor = self.UIStyle.COLOR_HEALTHBAR_GROUP
    elseif self:IsInState(self.states.playerStates, "GuildMate") then
      self.typeInfo.nameTextColor = self.UIStyle.COLOR_NAMEPLATE_GUILD
      self.typeInfo.deathsDoorPath = self.DEATHS_DOOR_GUILD
      self.typeInfo.levelBgSprite = self:GetLevelBgSprite(self.NAMEPLATE_LEVEL_BG_GUILD)
      self.typeInfo.levelTextColor = self.UIStyle.COLOR_HEALTHBAR_GUILD
    elseif self:IsInState(self.states.targetPvpFlag, "TargetPvpFlagOff") then
      self.typeInfo.nameTextColor = self.UIStyle.COLOR_NAMEPLATE_TARGET_CRIMINAL_INTENT_OFF
      self.typeInfo.deathsDoorPath = self.DEATHS_DOOR_NEUTRAL
      self.typeInfo.levelBgSprite = self:GetLevelBgSprite(self.NAMEPLATE_LEVEL_BG_NEUTRAL)
      self.typeInfo.levelTextColor = self.UIStyle.COLOR_WHITE
    elseif self:IsInState(self.states.targetPvpFlag, "TargetPvpFlagOn") and self:IsInOpposingFaction() then
      self.typeInfo.nameTextColor = self.UIStyle.COLOR_NAMEPLATE_WAR
      self.typeInfo.deathsDoorPath = self.DEATHS_DOOR_CRIMINAL_INTENT
      self.typeInfo.levelBgSprite = self:GetLevelBgSprite(self.NAMEPLATE_LEVEL_BG_CRIMINAL_INTENT)
      self.typeInfo.levelTextColor = self.UIStyle.COLOR_BLACK
    else
      self.typeInfo.nameTextColor = self.UIStyle.COLOR_NAMEPLATE_DEFAULT
      self.typeInfo.deathsDoorPath = self.DEATHS_DOOR_NEUTRAL
      self.typeInfo.levelBgSprite = self:GetLevelBgSprite(self.NAMEPLATE_LEVEL_BG_NEUTRAL)
      self.typeInfo.levelTextColor = self.UIStyle.COLOR_WHITE
    end
    if self.playerId and self.playerId.playerName then
      self.targetNameColorDataPath = "Hud.Marker.HealingTargetNameColor." .. self.playerId.playerName
      LyShineDataLayerBus.Broadcast.SetData(self.targetNameColorDataPath, self.typeInfo.nameTextColor)
    end
    if not self:IsPlayerMediumDetail() then
      UiImageBus.Event.SetSpritePathname(self.Properties.Player.DeathsDoor.DeathsDoorIcon, self.typeInfo.deathsDoorPath)
      UiImageBus.Event.SetSpritePathname(self.Properties.Player.Glory.LevelBg, self.typeInfo.levelBgSprite)
      UiTextBus.Event.SetColor(self.Properties.Player.Glory.LevelText, self.typeInfo.levelTextColor)
    end
    UiTextBus.Event.SetColor(self.Properties.Title, self.typeInfo.nameTextColor)
  end
end
function Marker:UpdatePlayerHealthBarColor()
  if self.isPlayer and self.updatePlayerHealthBarColor then
    self.updatePlayerHealthBarColor = nil
    if self.isWarFriendly then
      self.typeInfo.barColor = self.UIStyle.COLOR_HEALTHBAR_PVP_FRIENDLY
      self.typeInfo.barFillSprite = self.healthBarFillCannotDamagePath
      self.typeInfo.barBgSprite = self.healthBarBgCannotDamagePath
      self.typeInfo.barPulseColor = self.healthBarPulseColorFriendly
      self.typeInfo.barFramePulseSprite = self.healthBarFramePulseFriendlyPath
    elseif self.isWarEnemy then
      self.typeInfo.barColor = self.UIStyle.COLOR_HEALTHBAR_WAR
      self.typeInfo.barFillSprite = self.healthBarFillCanDamagePath
      self.typeInfo.barBgSprite = self.healthBarBgCanDamagePath
      self.typeInfo.barPulseColor = self.healthBarPulseColorEnemy
      self.typeInfo.barFramePulseSprite = self.healthBarFramePulseEnemyPath
    elseif self:IsInState(self.states.guildWarStates, "GuildWarOn") then
      self.typeInfo.barColor = self.UIStyle.COLOR_HEALTHBAR_WAR
      self.typeInfo.barFillSprite = self.healthBarFillCanDamagePath
      self.typeInfo.barBgSprite = self.healthBarBgCanDamagePath
      self.typeInfo.barPulseColor = self.healthBarPulseColorEnemy
      self.typeInfo.barFramePulseSprite = self.healthBarFramePulseEnemyPath
    elseif self:IsInState(self.states.duelStates, "Duel_Enter") and self.isDuelOpponent then
      self.typeInfo.barColor = self.UIStyle.COLOR_HEALTHBAR_WAR
      self.typeInfo.barFillSprite = self.healthBarFillCanDamagePath
      self.typeInfo.barBgSprite = self.healthBarBgCanDamagePath
      self.typeInfo.barPulseColor = self.healthBarPulseColorEnemy
      self.typeInfo.barFramePulseSprite = self.healthBarFramePulseEnemyPath
    elseif self:IsInState(self.states.groupFocusState, "Group_Enter") then
      self.typeInfo.barColor = self.UIStyle.COLOR_HEALTHBAR_GROUP
      self.typeInfo.barFillSprite = self.healthBarFillCannotDamagePath
      self.typeInfo.barBgSprite = self.healthBarBgCannotDamagePath
      self.typeInfo.barPulseColor = self.healthBarPulseColorFriendly
      self.typeInfo.barFramePulseSprite = self.healthBarFramePulseFriendlyPath
    elseif self:IsInState(self.states.playerStates, "GuildMate") then
      self.typeInfo.barColor = self.UIStyle.COLOR_HEALTHBAR_GUILD
      self.typeInfo.barFillSprite = self.healthBarFillCannotDamagePath
      self.typeInfo.barBgSprite = self.healthBarBgCannotDamagePath
      self.typeInfo.barPulseColor = self.healthBarPulseColorFriendly
      self.typeInfo.barFramePulseSprite = self.healthBarFramePulseFriendlyPath
    elseif self:IsInState(self.states.myPvpFlag, "MyPvpFlagOn") and self:IsInState(self.states.targetPvpFlag, "TargetPvpFlagOn") and self:IsInOpposingFaction() then
      self.typeInfo.barColor = self.UIStyle.COLOR_HEALTHBAR_PVP
      self.typeInfo.barFillSprite = self.healthBarFillCanDamagePath
      self.typeInfo.barBgSprite = self.healthBarBgCanDamagePath
      self.typeInfo.barPulseColor = self.healthBarPulseColorEnemy
      self.typeInfo.barFramePulseSprite = self.healthBarFramePulseEnemyPath
    else
      self.typeInfo.barColor = self.UIStyle.COLOR_HEALTHBAR_DEFAULT
      self.typeInfo.barFillSprite = self.healthBarFillCannotDamagePath
      self.typeInfo.barBgSprite = self.healthBarBgCannotDamagePath
      self.typeInfo.barPulseColor = self.healthBarPulseColorFriendly
      self.typeInfo.barFramePulseSprite = self.healthBarFramePulseFriendlyPath
    end
    if self.playerId and self.playerId.playerName then
      self.healthBarColorDataPath = "Hud.Marker.HealthBarColor." .. self.playerId.playerName
      LyShineDataLayerBus.Broadcast.SetData(self.healthBarColorDataPath, self.typeInfo.barColor)
    end
    UiImageBus.Event.SetColor(self.Properties.HealthBarFill, self.typeInfo.barColor)
    UiImageBus.Event.SetColor(self.Properties.HealthBarPulse, self.typeInfo.barPulseColor)
    UiImageBus.Event.SetSpritePathname(self.Properties.HealthBarFill, self.typeInfo.barFillSprite)
    UiImageBus.Event.SetSpritePathname(self.Properties.HealthBarBg, self.typeInfo.barBgSprite)
  end
end
function Marker:OnStatusEffectVisibilityChanged()
  if self.Properties.Player.IsAi then
    local statusEffectWidth = 36
    local statusEffectMargin = 6
    local offset = 2
    local statusEffects = UiElementBus.Event.GetChildren(self.Properties.StatusEffects)
    local enabledEffects = 0
    if statusEffects then
      for i = 1, #statusEffects do
        if UiElementBus.Event.IsEnabled(statusEffects[i]) then
          enabledEffects = enabledEffects + 1
        end
      end
    end
    if 0 < enabledEffects then
      local totalWidth = enabledEffects * statusEffectWidth + (enabledEffects - 1) * statusEffectMargin
      UiTransformBus.Event.SetLocalPositionX(self.Properties.StatusEffects, -totalWidth / 2 + offset)
    end
    self.showStatusEffectsIcons = 0 < enabledEffects
    self:UpdateVerticalPositions()
  end
end
function Marker:UpdateVerticalPositions()
  local titleY = -53
  local statusEffectsY = -63
  local objectiveIconY = -52
  local targetTaggedIconY = -78
  if self.showStatusEffectsText then
    local statusEffectsTextHeight = 20
    titleY = titleY - statusEffectsTextHeight
    statusEffectsY = statusEffectsY - statusEffectsTextHeight
    objectiveIconY = objectiveIconY - statusEffectsTextHeight
    targetTaggedIconY = targetTaggedIconY - statusEffectsTextHeight
  end
  if self.showStatusEffectsIcons then
    local statusEffectsIconHeight = 40
    objectiveIconY = objectiveIconY - statusEffectsIconHeight
    targetTaggedIconY = targetTaggedIconY - statusEffectsIconHeight
  end
  if self.Properties.Title:IsValid() then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Title, titleY)
  end
  if self.Properties.StatusEffects:IsValid() then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.StatusEffects, statusEffectsY)
  end
  if self.Properties.ObjectiveIcon:IsValid() then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ObjectiveIcon, objectiveIconY)
  end
  if self.Properties.TargetTaggedIconHolder:IsValid() then
    UiTransformBus.Event.SetLocalPositionY(self.Properties.TargetTaggedIconHolder, targetTaggedIconY)
  end
end
return Marker
