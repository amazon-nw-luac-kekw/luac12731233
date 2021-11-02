local Bio = {
  Properties = {
    Name = {
      default = EntityId()
    },
    WorldName = {
      default = EntityId()
    },
    TitleSection = {
      default = EntityId()
    },
    CompanyLabel = {
      default = EntityId()
    },
    Portrait = {
      default = EntityId()
    },
    PortraitBg = {
      default = EntityId()
    },
    PortraitBackLayer = {
      default = EntityId()
    },
    PortraitMidLayer = {
      default = EntityId()
    },
    PortraitFrontLayer = {
      default = EntityId()
    },
    GuildCrest = {
      default = EntityId()
    },
    GuildName = {
      default = EntityId()
    },
    GuildRank = {
      default = EntityId()
    },
    Banner = {
      default = EntityId()
    },
    FactionName = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    },
    ReputationAmount = {
      default = EntityId()
    },
    ReputationIcon = {
      default = EntityId()
    },
    NoFactionDescription = {
      default = EntityId()
    },
    FactionRankContainer = {
      default = EntityId()
    },
    TokensContainer = {
      default = EntityId()
    },
    TokensTitle = {
      default = EntityId()
    },
    TokensAmount = {
      default = EntityId()
    },
    TokensIcon = {
      default = EntityId()
    },
    RankName = {
      default = EntityId()
    },
    BonusContainer = {
      default = EntityId()
    },
    CompanyBonusHeader = {
      default = EntityId()
    },
    CompanyBonusList = {
      default = EntityId()
    },
    FactionBonusHeader = {
      default = EntityId()
    },
    FactionBonusList = {
      default = EntityId()
    },
    ChangeFactionButton = {
      default = EntityId()
    },
    BonusV2 = {
      Container = {
        default = EntityId()
      },
      UpkeepDue = {
        Container = {
          default = EntityId()
        },
        TextEntity = {
          default = EntityId()
        },
        String = {
          default = "@ui_company_upkeep_due"
        }
      },
      Territory = {
        Dropdown = {
          default = EntityId()
        },
        Container = {
          default = EntityId()
        },
        NoBonusEntity = {
          default = EntityId()
        },
        Bonuses = {
          default = EntityId()
        },
        List = {
          default = EntityId()
        }
      },
      TownProjects = {
        Container = {
          default = EntityId()
        },
        List = {
          default = EntityId()
        }
      },
      Company = {
        Container = {
          default = EntityId()
        },
        List = {
          default = EntityId()
        }
      },
      Faction = {
        Container = {
          default = EntityId()
        },
        List = {
          default = EntityId()
        }
      },
      EquippedItems = {
        Container = {
          default = EntityId()
        },
        List = {
          default = EntityId()
        }
      },
      FactionControlPoint = {
        Container = {
          default = EntityId()
        },
        List = {
          default = EntityId()
        }
      }
    }
  },
  maxRetries = 5,
  currentRetries = 0,
  throttleEndTime = 2,
  throttleDuration = 0,
  factionCrcById = {
    [eFactionType_Faction1] = 1459346962,
    [eFactionType_Faction2] = 1410032581,
    [eFactionType_Faction3] = 4109074679
  },
  timer = 0,
  bioBonusesV2FeatureFlag = "UIFeatures.enable-bio-bonuses-v2",
  maxTerritoryToDisplay = 5,
  bonusIconBasePath = "lyshineui/images/icons/territoryincentives",
  socialComponentReady = false,
  playerBusesReady = false,
  guildComponentEnabled = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Bio)
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local InventoryUtility = RequireScript("LyShineUI.Automation.Utilities.InventoryUtility")
local FcpCommon = RequireScript("LyShineUI._Common.FactionControlPointCommon")
function Bio:OnInit()
  BaseElement.OnInit(self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", function(self, playerName)
    UiTextBus.Event.SetText(self.Properties.Name, playerName)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isLandClaimManagerAvailable)
    if isLandClaimManagerAvailable == true then
      self.isLandClaimManagerAvailable = isLandClaimManagerAvailable
    else
      self:BusDisconnect(self.landClaimHandler)
      self.landClaimHandler = nil
      self.isLandClaimManagerAvailable = false
    end
  end)
  self.entitlementBusHandler = self:BusConnect(EntitlementNotificationBus)
  self.ChangeFactionButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE)
  self.ChangeFactionButton:SetText("@ui_change_faction")
  self.ChangeFactionButton:SetCallback(self.OnChangeFactionPressed, self)
  self.bonusV2Enabled = ConfigProviderEventBus.Broadcast.GetBool(self.bioBonusesV2FeatureFlag)
  UiElementBus.Event.SetIsEnabled(self.bonusV2Enabled and self.Properties.BonusV2.Container or self.Properties.BonusContainer, true)
  UiElementBus.Event.SetIsEnabled(self.bonusV2Enabled and self.Properties.BonusContainer or self.Properties.BonusV2.Container, false)
  self.CompanyLabel:SetTextStyle(self.UIStyle.FONT_STYLE_STORE_FEATURED_TITLE)
  self.CompanyLabel:SetDividerColor(self.UIStyle.COLOR_GRAY_50)
  if self.bonusV2Enabled then
    self.territoryNameIdTable = {
      {
        text = "@Brightwood",
        id = 2
      },
      {text = "@Everfall", id = 4},
      {text = "@Reekwater", id = 5},
      {text = "@Windsward", id = 6},
      {
        text = "@Queensport",
        id = 8
      },
      {
        text = "@FirstLight",
        id = 9
      },
      {
        text = "@CutlassKeys",
        id = 10
      },
      {
        text = "@Mourningdale",
        id = 11
      },
      {
        text = "@MonarchsBluffs",
        id = 12
      },
      {
        text = "@WeaversFen",
        id = 13
      },
      {
        text = "@RestlessShore",
        id = 15
      }
    }
    self.BonusV2.Territory.Dropdown:SetDropdownScreenCanvasId(self.entityId)
    self.BonusV2.Territory.Dropdown:SetCallback(self.OnTerritorySelected, self)
    self.BonusV2.Territory.Dropdown:SetListData(self.territoryNameIdTable)
    self.BonusV2.Territory.Dropdown:SetDropdownListHeightByRows(self.maxTerritoryToDisplay)
    self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
      if rootEntityId then
        self.localPlayerEntityId = rootEntityId
        if self.playerHousingBusHandler then
          self.playerHousingBusHandler:Disconnect()
          self.playerHousingBusHandler = nil
        end
        self.playerHousingBusHandler = PlayerHousingComponentNotificationBus.Connect(self, rootEntityId)
      end
    end)
    self.SlotsToTestForBonuses = {
      {slot = ePaperDollSlotTypes_MainHandOption1},
      {slot = ePaperDollSlotTypes_MainHandOption2},
      {slot = ePaperDollSlotTypes_MainHandOption3},
      {slot = ePaperDollSlotTypes_Ring},
      {slot = ePaperDollSlotTypes_Amulet},
      {slot = ePaperDollSlotTypes_Token},
      {slot = ePaperDollSlotTypes_OffHandOption1},
      {slot = ePaperDollSlotTypes_Chest},
      {slot = ePaperDollSlotTypes_Feet},
      {slot = ePaperDollSlotTypes_Hands},
      {slot = ePaperDollSlotTypes_Head},
      {slot = ePaperDollSlotTypes_Legs}
    }
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.JavSocialComponentBus.IsReady", function(self, isReady)
    self.socialComponentReady = isReady
    if not isReady then
      return
    end
    if not self.playerIcon and self.playerId then
      self:RequestPlayerIconData()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Enabled", function(self, enabled)
    self.guildComponentEnabled = enabled
    if enabled and self.needsRankUpdate and self.rankNumber then
      self.needsRankUpdate = false
      local rankDisplayInfo = GuildsComponentBus.Broadcast.GetRankDisplayInfo(self.rankNumber)
      UiElementBus.Event.SetIsEnabled(self.Properties.GuildRank, true)
      UiTextBus.Event.SetTextWithFlags(self.Properties.GuildRank, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_company_rank", rankDisplayInfo.name), eUiTextSet_SetLocalized)
    end
  end)
  self:UpdatePlayerTitles()
  SetTextStyle(self.Properties.RankName, self.UIStyle.FONT_STYLE_SUBHEADER_WHITE)
  SetTextStyle(self.Properties.ReputationAmount, self.UIStyle.FONT_STYLE_BODY_NEW)
  UiTextBus.Event.SetTextWithFlags(self.Properties.WorldName, LyShineManagerBus.Broadcast.GetWorldName(), eUiTextSet_SetAsIs)
end
function Bio:OnChangeFactionPressed()
  LyShineManagerBus.Broadcast.SetState(1913028995)
end
function Bio:OnEntitlementsChange()
  self:UpdatePlayerTitles()
end
function Bio:UpdatePlayerTitles()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnablePlayerTitles", function(self, enablePlayerTitles)
    UiElementBus.Event.SetIsEnabled(self.Properties.TitleSection, enablePlayerTitles)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if not playerEntityId then
      return
    end
    self.playerEntityId = playerEntityId
    if self.playerBusesReady then
      self.playerId = PlayerComponentRequestsBus.Event.GetPlayerIdentification(playerEntityId)
    else
      self.playerId = nil
    end
    if self.socialComponentReady and self.playerId then
      self:RequestPlayerIconData()
    else
      self.playerIcon = nil
    end
  end)
  self.emptyCrestData = {
    backgroundColor = self.UIStyle.COLOR_GRAY_50,
    backgroundImagePath = "lyshineui/images/crests/backgrounds/icon_shield_shape1V1.dds"
  }
  self.emptyGuildName = "@ui_no_company"
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", function(self, guildId)
    self.guildId = guildId
    if not self.guildId or not self.guildId:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.GuildRank, false)
      self:UpdateGuildCrestIcon(self.emptyCrestData)
      self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.Crest")
    else
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Crest", function(self, crestData)
        if crestData then
          self:UpdateGuildCrestIcon(crestData)
        end
      end)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Name", function(self, guildName)
    if guildName and guildName ~= "" then
      UiTextBus.Event.SetText(self.Properties.GuildName, guildName)
      UiTextBus.Event.SetColor(self.Properties.GuildName, self.UIStyle.COLOR_GRAY_80)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.GuildName, self.emptyGuildName, eUiTextSet_SetLocalized)
      UiTextBus.Event.SetColor(self.Properties.GuildName, self.UIStyle.COLOR_GRAY_50)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Rank", function(self, rankNumber)
    if rankNumber and rankNumber ~= -1 then
      self.rankNumber = rankNumber
      if self.guildComponentEnabled then
        self.needsRankUpdate = false
        local rankDisplayInfo = GuildsComponentBus.Broadcast.GetRankDisplayInfo(rankNumber)
        UiElementBus.Event.SetIsEnabled(self.Properties.GuildRank, true)
        UiTextBus.Event.SetTextWithFlags(self.Properties.GuildRank, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_company_rank", rankDisplayInfo.name), eUiTextSet_SetLocalized)
      else
        self.needsRankUpdate = true
      end
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.GuildRank, false)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, faction)
    if not faction then
      return
    end
    self:SetFaction(faction)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerBusReady", function(self, isReady)
    self.playerBusesReady = isReady
    if not isReady then
      return
    end
    if not self.playerId and self.playerEntityId then
      self.playerId = PlayerComponentRequestsBus.Event.GetPlayerIdentification(self.playerEntityId)
      if not self.playerIcon and self.socialComponentReady then
        self:RequestPlayerIconData()
      end
    end
  end)
end
function Bio:UpdateGuildCrestIcon(crestData)
  self.GuildCrest:SetIcon(crestData)
  self.GuildCrest:SetForegroundVisibility(crestData.foregroundImagePath ~= nil)
end
function Bio:SetPortraitWithPlayerIcon(playerIcon)
  UiImageBus.Event.SetSpritePathname(self.Properties.PortraitBackLayer, playerIcon.backgroundImagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.PortraitMidLayer, playerIcon.midgroundImagePath)
  UiImageBus.Event.SetSpritePathname(self.Properties.PortraitFrontLayer, playerIcon.foregroundImagePath)
end
function Bio:SetFaction(faction)
  local factionSettings = FactionCommon.factionInfoTable[faction]
  UiTextBus.Event.SetTextWithFlags(self.Properties.FactionName, factionSettings.factionName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.FactionName, factionSettings.crestBgColorLight)
  UiImageBus.Event.SetColor(self.Properties.Banner, factionSettings.crestBgColor)
  UiImageBus.Event.SetColor(self.Properties.PortraitBg, factionSettings.crestBgColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.PortraitBg, faction ~= eFactionType_None)
  UiImageBus.Event.SetSpritePathname(self.Properties.FactionIcon, factionSettings.crestFg)
  UiImageBus.Event.SetColor(self.Properties.FactionIcon, factionSettings.crestBgColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionIcon, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.NoFactionDescription, faction == eFactionType_None)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionRankContainer, faction ~= eFactionType_None)
  UiElementBus.Event.SetIsEnabled(self.Properties.TokensContainer, faction ~= eFactionType_None)
  if faction ~= eFactionType_None then
    local currencyImagePath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(faction) .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.TokensIcon, currencyImagePath)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TokensTitle, "@owg_currency", eUiTextSet_SetLocalized)
    local reputationImagePath = "lyshineui/images/icons/objectives/reward_factionreputation" .. tostring(faction) .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.ReputationIcon, reputationImagePath)
  end
  self.faction = faction
  self.factionCrc = self.factionCrcById[self.faction]
end
function Bio:UpdateWallet()
  if self.faction and self.faction ~= eFactionType_None then
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local currentRank = CategoricalProgressionRequestBus.Event.GetRank(playerEntityId, self.factionCrc)
    local rankName = FactionCommon.factionInfoTable[self.faction].rankNames[currentRank + 1]
    UiTextBus.Event.SetTextWithFlags(self.Properties.RankName, rankName, eUiTextSet_SetLocalized)
    local currentReputation = CategoricalProgressionRequestBus.Event.GetProgression(playerEntityId, self.factionCrc)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ReputationAmount, GetFormattedNumber(currentReputation), eUiTextSet_SetAsIs)
    local reputationLabel = GetLocalizedReplacementText("@owg_guildreputation_name", {
      FactionCommon.factionInfoTable[self.faction].factionName
    })
    local nextRankName = FactionCommon.factionInfoTable[self.faction].rankNames[currentRank + 2]
    if nextRankName then
      local maxReputation = CategoricalProgressionRequestBus.Event.GetMaxPointsForRank(playerEntityId, self.factionCrc, currentRank)
      local toNextRank = GetLocalizedReplacementText("@owg_influence_to_rank", {
        influence = GetFormattedNumber(maxReputation - currentReputation),
        rankName = nextRankName
      })
      self.ReputationIcon:SetSimpleTooltip(reputationLabel .. [[


]] .. toNextRank)
    else
      self.ReputationIcon:SetSimpleTooltip(reputationLabel)
    end
    local progressionEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.EventNotificationEntityId")
    local factionTokensId = FactionRequestBus.Event.GetFactionTokensProgressionIdFromType(playerEntityId, self.faction)
    local currentTokens = CategoricalProgressionRequestBus.Event.GetProgression(progressionEntityId, factionTokensId)
    local tokensText = GetFormattedNumber(currentTokens)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TokensAmount, tokensText, eUiTextSet_SetAsIs)
  end
end
function Bio:SetScreenVisible(isVisible)
  if isVisible == self.screenVisible then
    return
  end
  self.screenVisible = isVisible
  if self.screenVisible == true then
    self.ScriptedEntityTweener:PlayFromC(self.entityId, 0.15, {opacity = 0}, tweenerCommon.fadeInQuadOut)
    self:UpdateWallet()
  else
    self.BonusV2.Territory.Dropdown:Collapse()
  end
end
function Bio:TransitionIn()
  if self.bonusV2Enabled then
    self.territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    local selectedTerritory = 1
    for index = 1, #self.territoryNameIdTable do
      if self.territoryNameIdTable[index].id == self.territoryId then
        selectedTerritory = index
        break
      end
    end
    self.BonusV2.Territory.Dropdown:SetSelectedItemData(self.territoryNameIdTable[selectedTerritory])
  end
  self:SetupBonuses()
  self:UpdateFactionButton()
  self:SetScreenVisible(true)
end
function Bio:TransitionOut()
  self.TitleSection.ChangeTitleWindow:TransitionOut()
  self:SetScreenVisible(false)
end
function Bio:HasActiveTimer()
  return self.updateFactionCooldown or self.updateProjectBonusTimers
end
function Bio:UpdateTickHandler()
  if self.isRetrying or self:HasActiveTimer() then
    if self.tickBusHandler == nil then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  elseif self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
    self.timer = 0
  end
end
function Bio:UpdateFactionButton()
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-faction-changing") == false or self.faction == eFactionType_None then
    UiElementBus.Event.SetIsEnabled(self.Properties.ChangeFactionButton, false)
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ChangeFactionButton, false)
    return
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ChangeFactionButton, true)
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.ChangeFactionButton, true)
  end
  local faction = self.faction == eFactionType_Faction1 and eFactionType_Faction2 or eFactionType_Faction1
  local result = FactionRequestBus.Event.CanSetFactionWithResults(self.playerEntityId, faction)
  local canChangeFaction = result == eCanSetFactionResults_Success or result == eCanSetFactionResults_FactionHasMostTerritory
  self.ChangeFactionButton:SetEnabled(canChangeFaction, 0)
  if canChangeFaction then
    self.ChangeFactionButton:SetTextStyle(self.UIStyle.FONT_STYLE_BUTTON_SIMPLE)
  end
  self.updateFactionCooldown = result == eCanSetFactionResults_OnCooldown
  self:UpdateTickHandler()
  local tooltipMsg = ""
  if not self.updateFactionCooldown then
    if result == eCanSetFactionResults_FlaggedForPvp then
      tooltipMsg = "@ui_faction_cant_pvp"
    elseif result == eCanSetFactionResults_NotInASanctuary then
      tooltipMsg = "@ui_faction_cant_sanctuary"
    elseif result == eCanSetFactionResults_InACompany then
      tooltipMsg = "@ui_faction_cant_company"
    elseif result == eCanSetFactionResults_InAWar then
      tooltipMsg = "@ui_faction_cant_war"
    elseif result == eCanSetFactionResults_InsufficientAzoth then
      local azothCost = FactionRequestBus.Event.GetFactionChangeAzothCost(self.playerEntityId)
      tooltipMsg = GetLocalizedReplacementText("@ui_change_faction_azoth_required", {
        tostring(azothCost)
      })
    end
  end
  self.ChangeFactionButton:SetTooltip(tooltipMsg)
end
function Bio:UpdateChangeFactionTimer()
  local cooldownEndTimePoint = FactionRequestBus.Event.GetCooldownEndTime(self.playerEntityId)
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local cooldownRemainingInSeconds = cooldownEndTimePoint:Subtract(now):ToSeconds()
  local factionTimeLeft = timeHelpers:ConvertToShorthandString(cooldownRemainingInSeconds, true, true)
  if 0 < cooldownRemainingInSeconds then
    self.ChangeFactionButton:SetText(GetLocalizedReplacementText("@ui_change_faction_cooldown", {factionTimeLeft}))
    self.ChangeFactionButton:SetTooltip(GetLocalizedReplacementText("@ui_faction_cant_cooldown", {factionTimeLeft}))
  else
    self.ChangeFactionButton:SetText("@ui_change_faction")
    self.ChangeFactionButton:SetTooltip("")
    self.updateFactionCooldown = false
    self:UpdateTickHandler()
  end
end
function Bio:UpdateProjectBonusTimers()
  local timersToRemove = {}
  for timerIndex = 1, #self.projectBonusTimers do
    local projectBonusTimer = self.projectBonusTimers[timerIndex]
    projectBonusTimer.timeRemaining = projectBonusTimer.timeRemaining - 1
    if projectBonusTimer.timeRemaining > 0 then
      UiTextBus.Event.SetText(projectBonusTimer.valueElementId, self:FormatNumber(projectBonusTimer.timeRemaining, false, false, false, true))
      self.projectBonusTimers[timerIndex].timeRemaining = projectBonusTimer.timeRemaining
    else
      table.insert(timersToRemove, timerIndex)
    end
  end
  if 0 < #timersToRemove then
    if #self.projectBonusTimers == #timersToRemove then
      self.updateProjectBonusTimers = false
      self:UpdateTickHandler()
      self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.TownProjects.Container, false, false, EntityId())
    else
      for removeIndex = #timersToRemove, 1 do
        local timerToRemove = self.projectBonusTimers[timersToRemove[removeIndex]]
        UiElementBus.Event.DestroyElement(timerToRemove.elementId)
        table.remove(self.projectBonusTimers, timersToRemove[removeIndex])
      end
      self:ResizeBonusList(self.Properties.BonusV2.TownProjects.List, self.Properties.BonusV2.TownProjects.Container, #self.projectBonusTimers)
    end
  end
end
function Bio:OnTerritorySelected(listItem, listItemData)
  if listItemData.id and listItemData.id ~= self.territoryId then
    self.territoryId = listItemData.id
    self:SetupBonuses()
  end
end
function Bio:OnResidentDataReceived(territoryIds, residentData)
  if self.localPlayerEntityId == nil then
    return
  end
  self.projectBonusTimers = {}
  local projectBonuses = {}
  for idIndex = 1, #territoryIds do
    local residentTerritoryId = territoryIds[idIndex]
    if residentTerritoryId == self.territoryId then
      local statusEffects = residentData[idIndex].statusEffectsData
      for seIndex = 1, #statusEffects do
        local statusEffect = statusEffects[seIndex]
        local endTimestamp = statusEffect.endTimestamp
        local timeLeft = endTimestamp:Subtract(timeHelpers:ServerNow()):ToSeconds()
        if 0 < timeLeft then
          local statusEffect = StatusEffectsRequestBus.Event.GetStatusEffectDataByCrc(self.localPlayerEntityId, statusEffect.effectId)
          if statusEffect ~= nil then
            table.insert(projectBonuses, {
              bonusName = statusEffect.name,
              bonusValue = timeLeft,
              isTime = true,
              tooltip = statusEffect.description,
              bonusIcon = statusEffect.icon
            })
            table.insert(self.projectBonusTimers, {
              timeRemaining = timeLeft,
              elementId = nil,
              valueElementId = nil
            })
          end
        end
      end
      break
    end
  end
  self.updateProjectBonusTimers = #projectBonuses ~= 0
  if self.updateProjectBonusTimers then
    self.projectBonusTimer = 0
    self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Territory.NoBonusEntity, false, false, EntityId())
    UiElementBus.Event.SetIsEnabled(self.Properties.BonusV2.TownProjects.Container, true)
    local appearBefore = UiElementBus.Event.IsEnabled(self.Properties.BonusV2.EquippedItems.Container) and self.Properties.BonusV2.EquippedItems.Container or UiElementBus.Event.IsEnabled(self.Properties.BonusV2.UpkeepDue.Container) and self.Properties.BonusV2.UpkeepDue.Container or UiElementBus.Event.IsEnabled(self.Properties.BonusV2.Company.Container) and self.Properties.BonusV2.Company.Container or UiElementBus.Event.IsEnabled(self.Properties.BonusV2.Faction.Container) and self.Properties.BonusV2.Faction.Container or UiElementBus.Event.IsEnabled(self.Properties.BonusV2.FactionControlPoint.Container) and self.Properties.BonusV2.FactionControlPoint.Container or EntityId()
    UiElementBus.Event.Reparent(self.Properties.BonusV2.TownProjects.Container, self.Properties.BonusV2.Territory.Container, appearBefore)
    self:PopulateBonusList(self.Properties.BonusV2.TownProjects.List, self.Properties.BonusV2.TownProjects.Container, projectBonuses, false)
    for i = 1, #projectBonuses do
      local childElementId = UiElementBus.Event.GetChild(self.Properties.BonusV2.TownProjects.List, i - 1)
      local valueElementId = UiElementBus.Event.FindChildByName(childElementId, "Value")
      self.projectBonusTimers[i].elementId = childElementId
      self.projectBonusTimers[i].valueElementId = valueElementId
    end
  end
  self:UpdateTickHandler()
end
function Bio:ShowOrHideTerritoryBonus(bonusContainerId, show, inUpkeepContainer, showBeforeId)
  UiElementBus.Event.SetIsEnabled(bonusContainerId, show)
  UiElementBus.Event.Reparent(bonusContainerId, show and (inUpkeepContainer and self.Properties.BonusV2.UpkeepDue.Container or self.Properties.BonusV2.Territory.Container) or self.Properties.BonusV2.Container, showBeforeId)
end
function Bio:SetupBonuses()
  UiElementBus.Event.SetIsEnabled(self.bonusV2Enabled and self.Properties.BonusV2.Container or self.Properties.BonusContainer, false)
  if not self.bonusV2Enabled then
    self.territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  end
  if self.territoryId == nil then
    return
  end
  local territoryOwnerGuildData = TerritoryDataHandler:GetGoverningGuildData(self.territoryId)
  if territoryOwnerGuildData == 0 then
    return
  end
  local sameGuild = self.guildId and self.guildId:IsValid() and territoryOwnerGuildData.guildId == self.guildId
  local ownsFactionControlPoint = false
  local factionControlEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled")
  if factionControlEnabled and self.isLandClaimManagerAvailable then
    if self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
    end
    self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.territoryId)
    if self.faction ~= eFactionType_None and self.faction == LandClaimRequestBus.Broadcast.GetFactionControlOwner(self.territoryId) then
      ownsFactionControlPoint = true
    end
  end
  FactionCommon:GetFaction(territoryOwnerGuildData.guildId, function(self, owningFaction, owningCrest)
    local sameFaction = self.faction ~= eFactionType_None and self.faction == owningFaction
    local territoryNameFromId = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryId)
    if territoryNameFromId == nil or territoryNameFromId == "" then
      territoryNameFromId = "@ui_eow_invalid_territory_id"
    end
    repeat
      if not self.bonusV2Enabled then
        if true then
          do
            local companyHeaderText = GetLocalizedReplacementText("@ui_company_bonus_title", {territoryName = territoryNameFromId})
            UiTextBus.Event.SetTextWithFlags(self.Properties.CompanyBonusHeader, companyHeaderText, eUiTextSet_SetAsIs)
            local factionHeaderText = GetLocalizedReplacementText("@ui_faction_bonus_title", {territoryName = territoryNameFromId})
            UiTextBus.Event.SetTextWithFlags(self.Properties.FactionBonusHeader, factionHeaderText, eUiTextSet_SetAsIs)
            local companyBonuses = {
              {
                bonusName = "@ui_company_bonus_tax",
                bonusValue = self.sameGuild and LocalPlayerUIRequestsBus.Broadcast.GetControllingCompanyTaxModifier() or 0,
                isPercent = true,
                roundValue = true
              },
              {
                bonusName = "@ui_company_bonus_houseprice",
                bonusValue = self.sameGuild and LocalPlayerUIRequestsBus.Broadcast.GetControllingCompanyHouseCostModifier() or 0,
                isPercent = true,
                roundValue = true
              }
            }
            local factionBonuses = {
              {
                bonusName = "@ui_faction_bonus_luck",
                bonusValue = self.sameFaction and LocalPlayerUIRequestsBus.Broadcast.GetControllingFactionLuckModifier() or 0,
                numberFormat = "+%d"
              },
              {
                bonusName = "@ui_faction_bonus_gaathering",
                bonusValue = self.sameFaction and LocalPlayerUIRequestsBus.Broadcast.GetControllingFactionGatherModifier() or 0,
                isPercent = true,
                roundValue = true
              }
            }
            self:PopulateBonusList(self.Properties.CompanyBonusList, nil, companyBonuses, nil)
            self:PopulateBonusList(self.Properties.FactionBonusList, nil, factionBonuses, nil)
          end
          break -- pseudo-goto
        else
          local allSlotBonuseIds = {}
          for slotIndex = 1, #self.SlotsToTestForBonuses do
            local slot = self.SlotsToTestForBonuses[slotIndex]
            local slotDescriptor = InventoryUtility:GetSlotItemDescriptor(slot)
            if slotDescriptor then
              local slotPerkCount = slotDescriptor:GetPerkCount()
              for i = 0, slotPerkCount - 1 do
                local perkId = slotDescriptor:GetPerk(i)
                if perkId ~= 0 then
                  table.insert(allSlotBonuseIds, perkId)
                end
              end
            end
          end
          local uniqueSlotBonusIds = {}
          local sbHash = {}
          for _, v in ipairs(allSlotBonuseIds) do
            if not sbHash[v] then
              table.insert(uniqueSlotBonusIds, v)
              sbHash[v] = true
            end
          end
        end
      end
      local anyBonuses = sameGuild or sameFaction or ownsFactionControlPoint
      if not anyBonuses then
        self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Territory.NoBonusEntity, true, false, EntityId())
        self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Territory.Bonuses, false, false, EntityId())
        self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Faction.Container, false, false, EntityId())
        self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Company.Container, false, false, EntityId())
        self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.UpkeepDue.Container, false, false, EntityId())
        self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.EquippedItems.Container, false, false, EntityId())
        self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.FactionControlPoint.Container, false, false, EntityId())
      else
        self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Territory.NoBonusEntity, false, false, EntityId())
        if factionControlEnabled then
          local territoryBonuses = FcpCommon:GetTerritoryBonuses(self.territoryId, true)
          if not ownsFactionControlPoint or #territoryBonuses == 0 then
            self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Territory.Bonuses, false, false, EntityId())
          else
            self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Territory.Bonuses, true, false, EntityId())
            self:PopulateBonusList(self.Properties.BonusV2.Territory.List, self.Properties.BonusV2.Territory.Bonuses, territoryBonuses, false)
          end
        else
          if true then
            repeat
              self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Territory.Bonuses, false, false, EntityId())
              do break end -- pseudo-goto
              self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.EquippedItems.Container, true, false, EntityId())
              local slotBonuses = {}
              for slotIndex = 1, #uniqueSlotBonusIds do
                local slotBonusId = uniqueSlotBonusIds[slotIndex]
                local statusEffect = StatusEffectsRequestBus.Event.GetStatusEffectDataByCrc(self.localPlayerEntityId, slotBonusId)
                if statusEffect ~= nil then
                  table.insert(slotBonuses, {
                    bonusName = statusEffect.name,
                    tooltip = statusEffect.description,
                    bonusIcon = statusEffect.icon
                  })
                  if statusEffect.potencyMax ~= 0 then
                    slotBonuses[#slotBonuses].bonusValue = statusEffect.potencyMax
                    slotBonuses[#slotBonuses].roundValue = true
                  end
                end
              end
              self:PopulateBonusList(self.Properties.BonusV2.EquippedItems.List, self.Properties.BonusV2.EquippedItems.Container, slotBonuses, false)
            until true
        end
        else
          self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.EquippedItems.Container, false, false, EntityId())
        end
        if factionControlEnabled and ownsFactionControlPoint then
          self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.FactionControlPoint.Container, true, false, EntityId())
          local factionBonuses = FcpCommon:GetFactionBonuses(self.territoryId, true)
          self:PopulateBonusList(self.Properties.BonusV2.FactionControlPoint.List, self.Properties.BonusV2.FactionControlPoint.Container, factionBonuses, false)
        else
          self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.FactionControlPoint.Container, false, false, EntityId())
        end
        local upkeepDue = TerritoryDataHandler:IsUpkeepOverdue(self.territoryId)
        if upkeepDue and sameGuild and sameFaction then
          local localizedText = GetLocalizedReplacementText(self.Properties.BonusV2.UpkeepDue.String, {territoryName = territoryNameFromId})
          UiTextBus.Event.SetText(self.Properties.BonusV2.UpkeepDue.TextEntity, localizedText)
          self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.UpkeepDue.Container, true, false, EntityId())
        else
          self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.UpkeepDue.Container, false, false, EntityId())
        end
        if sameGuild then
          self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Company.Container, true, upkeepDue, EntityId())
          local companyBonuses = {
            {
              bonusName = "@ui_company_bonus_tax",
              bonusValue = LocalPlayerUIRequestsBus.Broadcast.GetControllingCompanyTaxModifier(),
              isPercent = true,
              roundValue = true,
              bonusIcon = "taxDiscount"
            },
            {
              bonusName = "@ui_company_bonus_houseprice",
              bonusValue = LocalPlayerUIRequestsBus.Broadcast.GetControllingCompanyHouseCostModifier(),
              isPercent = true,
              roundValue = true,
              bonusIcon = "housePurchaseDiscount"
            },
            {
              bonusName = "@ui_company_fast_travel_discount",
              bonusValue = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryCompanyDiscountPct() + PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryFactionDiscountPct(),
              numberFormat = "%d%%",
              bonusIcon = "fastTravelDiscount"
            }
          }
          self:PopulateBonusList(self.Properties.BonusV2.Company.List, self.Properties.BonusV2.Company.Container, companyBonuses, upkeepDue)
        else
          self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Company.Container, false, false, EntityId())
        end
        if sameFaction then
          self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Faction.Container, true, upkeepDue, EntityId())
          local factionBonuses = {
            {
              bonusName = "@ui_faction_bonus_luck",
              bonusValue = LocalPlayerUIRequestsBus.Broadcast.GetControllingFactionLuckModifier(),
              numberFormat = "+%d",
              bonusIcon = "luckBonus"
            },
            {
              bonusName = "@ui_faction_bonus_gaathering",
              bonusValue = LocalPlayerUIRequestsBus.Broadcast.GetControllingFactionGatherModifier(),
              isPercent = true,
              roundValue = true,
              bonusIcon = "gatheringBonus"
            }
          }
          if not sameGuild then
            table.insert(factionBonuses, {
              bonusName = "@ui_faction_fast_travel_discount",
              bonusValue = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryFactionDiscountPct(),
              numberFormat = "%d%%",
              bonusIcon = "fastTravelDiscount"
            })
          end
          self:PopulateBonusList(self.Properties.BonusV2.Faction.List, self.Properties.BonusV2.Faction.Container, factionBonuses, upkeepDue)
        else
          self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.Faction.Container, false, false, EntityId())
        end
      end
      self:ShowOrHideTerritoryBonus(self.Properties.BonusV2.TownProjects.Container, false, false, EntityId())
      PlayerHousingClientRequestBus.Broadcast.RequestResidentData()
    until true
    UiElementBus.Event.SetIsEnabled(self.bonusV2Enabled and self.Properties.BonusV2.Container or self.Properties.BonusContainer, true)
  end, self)
end
function Bio:FormatNumber(stat, isPercent, numberFormat, roundValue, isTime)
  if isTime then
    local hours = string.format("%02.f", math.floor(stat / 3600))
    local mins = string.format("%02.f", math.floor(stat / 60 - hours * 60))
    local secs = string.format("%02.f", math.floor(stat - hours * 3600 - mins * 60))
    return hours .. ":" .. mins .. ":" .. secs
  end
  if isPercent and numberFormat then
    returnVal = string.format(numberFormat .. "%%", stat * 100)
  elseif isPercent then
    if roundValue then
      returnVal = string.format("%d%%", math.floor(stat * 100 + 0.5))
    else
      returnVal = string.format("%.2f%%", stat * 100)
    end
  elseif numberFormat then
    returnVal = string.format(numberFormat, stat)
  elseif roundValue then
    returnVal = math.floor(stat + 0.5)
  else
    returnVal = math.ceil(stat)
  end
  return LocalizeDecimalSeparators(returnVal)
end
function Bio:PopulateBonusList(listEntityId, containerEntityId, bonusList, upkeepDue)
  UiDynamicLayoutBus.Event.SetNumChildElements(listEntityId, #bonusList)
  for i = 1, #bonusList do
    local childElement = UiElementBus.Event.GetChild(listEntityId, i - 1)
    local nameId = UiElementBus.Event.FindChildByName(childElement, "Name")
    UiTextBus.Event.SetTextWithFlags(nameId, bonusList[i].bonusName, eUiTextSet_SetLocalized)
    local valueId = UiElementBus.Event.FindChildByName(childElement, "Value")
    if bonusList[i].bonusValue and not bonusList[i].formattedBonusValue then
      UiElementBus.Event.SetIsEnabled(valueId, true)
      UiTextBus.Event.SetText(valueId, self:FormatNumber(bonusList[i].bonusValue, bonusList[i].isPercent, bonusList[i].numberFormat, bonusList[i].roundValue, bonusList[i].isTime))
    else
      UiElementBus.Event.SetIsEnabled(valueId, false)
    end
    if self.bonusV2Enabled then
      local iconId = UiElementBus.Event.FindChildByName(childElement, "Icon")
      if bonusList[i].bonusIcon and bonusList[i].bonusIcon ~= "" then
        local imagePath = string.format("%s/%s.dds", self.bonusIconBasePath, bonusList[i].bonusIcon)
        UiImageBus.Event.SetSpritePathname(iconId, imagePath)
        UiElementBus.Event.SetIsEnabled(iconId, true)
      else
        UiElementBus.Event.SetIsEnabled(iconId, false)
      end
      if not UiElementBus.Event.IsEnabled(iconId) then
        local iconImagePath = bonusList[i].imagePath
        if iconImagePath and LyShineScriptBindRequestBus.Broadcast.IsFileExists(iconImagePath) then
          UiImageBus.Event.SetSpritePathname(iconId, iconImagePath)
          UiElementBus.Event.SetIsEnabled(iconId, true)
        end
      end
      if bonusList[i].formattedBonusValue then
        UiElementBus.Event.SetIsEnabled(valueId, true)
        UiTextBus.Event.SetText(valueId, bonusList[i].formattedBonusValue)
      end
      local tooltipSetterId = UiElementBus.Event.FindChildByName(childElement, "StatTooltipSetter")
      if bonusList[i].tooltip and bonusList[i].tooltip ~= "" then
        local tooltipSetter = self.registrar:GetEntityTable(tooltipSetterId)
        tooltipSetter:SetSimpleTooltip(bonusList[i].tooltip)
        UiElementBus.Event.SetIsEnabled(tooltipSetterId, true)
      else
        UiElementBus.Event.SetIsEnabled(tooltipSetterId, false)
      end
      local lineId = UiElementBus.Event.FindChildByName(childElement, "UpkeepLine")
      if lineId:IsValid() then
        UiElementBus.Event.SetIsEnabled(lineId, upkeepDue)
        local icon = UiElementBus.Event.FindChildByName(childElement, "Icon")
        local name = UiElementBus.Event.FindChildByName(childElement, "Name")
        local value = UiElementBus.Event.FindChildByName(childElement, "Value")
        if upkeepDue then
          UiImageBus.Event.SetColor(icon, self.UIStyle.COLOR_RED_MEDIUM)
          UiTextBus.Event.SetColor(name, self.UIStyle.COLOR_RED_MEDIUM)
          UiTextBus.Event.SetColor(value, self.UIStyle.COLOR_RED_MEDIUM)
        else
          UiImageBus.Event.SetColor(icon, self.UIStyle.COLOR_WHITE)
          UiTextBus.Event.SetColor(name, self.UIStyle.COLOR_WHITE)
          UiTextBus.Event.SetColor(value, self.UIStyle.COLOR_WHITE)
        end
      end
    end
  end
  if self.bonusV2Enabled then
    self:ResizeBonusList(listEntityId, containerEntityId, #bonusList)
  end
end
function Bio:ResizeBonusList(listEntityId, containerEntityId, elementCount)
  local childElements = UiElementBus.Event.GetChildren(listEntityId)
  if childElements == 0 or elementCount == 0 then
    return
  end
  local childElement = UiElementBus.Event.GetChild(listEntityId, 0)
  local childHeight = UiTransform2dBus.Event.GetLocalHeight(childElement)
  local padding = UiLayoutColumnBus.Event.GetPadding(listEntityId)
  local spacing = UiLayoutColumnBus.Event.GetSpacing(listEntityId)
  local targetHeight = childHeight * elementCount + spacing * (elementCount - 1) + padding.top + padding.bottom
  UiLayoutCellBus.Event.SetTargetHeight(listEntityId, targetHeight)
  targetHeight = 0
  local childElementsCount = UiElementBus.Event.GetNumChildElements(containerEntityId)
  for i = 1, childElementsCount do
    local childElement = UiElementBus.Event.GetChild(containerEntityId, i - 1)
    targetHeight = targetHeight + UiLayoutCellBus.Event.GetTargetHeight(childElement)
  end
  padding = UiLayoutColumnBus.Event.GetPadding(containerEntityId)
  spacing = UiLayoutColumnBus.Event.GetSpacing(containerEntityId)
  targetHeight = targetHeight + spacing * (childElementsCount - 1) + padding.top + padding.bottom
  UiLayoutCellBus.Event.SetTargetHeight(containerEntityId, targetHeight)
end
function Bio:RequestPlayerIconData()
  self.playerIcon = nil
  return self.socialDataHandler:GetRemotePlayerIconData_ServerCall(self, self.OnRemotePlayerIconDataReady, self.OnRemotePlayerIconDataFailed, self.playerId:GetCharacterIdString())
end
function Bio:OnRemotePlayerIconDataReady(result)
  if #result == 0 then
    self:SetIsRetrying(true)
    local playerName = self.playerId and self.playerId.playerName or ""
    Log("ERR - Bio:OnRemotePlayerIconDataReady: No result icons :: " .. tostring(playerName))
    return
  end
  self.playerIcon = result[1].playerIcon:Clone()
  self:SetPortraitWithPlayerIcon(self.playerIcon)
  self.iconLoaded = true
end
function Bio:OnRemotePlayerIconDataFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - Bio:OnRemotePlayerLevelDataFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - Bio:OnRemotePlayerLevelDataFailed: Timed Out")
  end
end
function Bio:SetIsRetrying(isRetrying)
  self.isRetrying = isRetrying and self.currentRetries < self.maxRetries and not self.iconLoaded
  self:UpdateTickHandler()
end
function Bio:OnTick(deltaTime, timepoint)
  if self:HasActiveTimer() then
    self.timer = self.timer + deltaTime
    if self.timer >= 1 then
      self.timer = self.timer - 1
      if self.updateFactionCooldown then
        self:UpdateChangeFactionTimer()
      end
      if self.bonusV2Enabled and self.updateProjectBonusTimers then
        self:UpdateProjectBonusTimers()
      end
    end
    return
  end
  self.throttleDuration = self.throttleDuration + deltaTime
  if self.throttleDuration >= self.throttleEndTime then
    self:RequestPlayerIconData()
    self.throttleDuration = 0
    self.currentRetries = self.currentRetries + 1
    if self.currentRetries > self.maxRetries then
      self:SetIsRetrying(false)
    end
  end
end
return Bio
