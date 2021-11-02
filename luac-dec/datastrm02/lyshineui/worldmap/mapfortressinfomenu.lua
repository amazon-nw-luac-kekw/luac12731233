local MapFortressInfoMenu = {
  Properties = {
    TypeText = {
      default = EntityId()
    },
    NameText = {
      default = EntityId()
    },
    FortImage = {
      default = EntityId()
    },
    GovernanceContainer = {
      default = EntityId()
    },
    NoWarGovernance = {
      default = EntityId()
    },
    NotClaimedText = {
      default = EntityId()
    },
    GovernedByCrest = {
      default = EntityId()
    },
    GovernedByNameText = {
      default = EntityId()
    },
    FactionIcon = {
      default = EntityId()
    },
    FactionText = {
      default = EntityId()
    },
    TerritoryOwnershipButton = {
      default = EntityId()
    },
    WarGovernance = {
      default = EntityId()
    },
    AttackerWash = {
      default = EntityId()
    },
    AttackerCrest = {
      default = EntityId()
    },
    AttackerName = {
      default = EntityId()
    },
    DefenderWash = {
      default = EntityId()
    },
    DefenderCrest = {
      default = EntityId()
    },
    DefenderName = {
      default = EntityId()
    },
    ConflictText = {
      default = EntityId()
    },
    SiegeWindowSection = {
      default = EntityId()
    },
    SiegeWindowText = {
      default = EntityId()
    },
    SiegeWindowDivider1 = {
      default = EntityId()
    },
    SiegeWindowDivider2 = {
      default = EntityId()
    },
    BattleDescriptionContainer = {
      default = EntityId()
    },
    BattleDescriptionLabel = {
      default = EntityId()
    },
    BattleDescriptionValue = {
      default = EntityId()
    },
    BattleDescriptionBody = {
      default = EntityId()
    },
    BattleDescriptionDivider = {
      default = EntityId()
    },
    ContributionDescription = {
      default = EntityId()
    },
    WarButton = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    },
    InfluenceWarContainer = {
      default = EntityId()
    },
    InfluenceWarWidget = {
      default = EntityId()
    },
    HowDoesWarWorkText = {
      default = EntityId()
    },
    PropertyTaxAmount = {
      default = EntityId()
    },
    TradingTaxAmount = {
      default = EntityId()
    },
    CraftingFeeAmount = {
      default = EntityId()
    },
    RefiningFeeAmount = {
      default = EntityId()
    },
    PropertyTaxTooltip = {
      default = EntityId()
    },
    TradingTaxTooltip = {
      default = EntityId()
    },
    CraftingFeeTooltip = {
      default = EntityId()
    },
    RefiningFeeTooltip = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    InnButton = {
      default = EntityId()
    },
    FastTravelButton = {
      default = EntityId()
    },
    StorageButton = {
      default = EntityId()
    },
    HouseButton = {
      default = EntityId()
    },
    FastTravelContainer = {
      default = EntityId()
    },
    FastTravelErrorMessage = {
      default = EntityId()
    },
    FastTravelButtonsContainer = {
      default = EntityId()
    },
    UpgradesCompletedText = {
      default = EntityId()
    },
    Stations = {
      default = {
        EntityId()
      }
    }
  },
  epoch = WallClockTimePoint(),
  timer = 0,
  timerTickSeconds = 1,
  BATTLE_TYPE_NONE = 1,
  BATTLE_TYPE_INVASION = 2,
  BATTLE_TYPE_WAR = 3,
  basicCrestBg = "lyshineui/images/crests/backgrounds/icon_shield_shape1V1.dds",
  invasionCrestFg = "lyshineui/images/crests/foregrounds/icon_crest_44.dds",
  warButtonY = 0,
  warButtonHeight = 0,
  defaultButtonHeight = 52,
  houseIconButtonPath = "lyshineui/images/map/icon/icon_house_button.dds",
  disabledHouseIconButtonPath = "lyshineui/images/map/icon/icon_house_inactive_button.dds",
  activeInnIconButtonPath = "lyshineui/images/map/icon/icon_inn_button.dds",
  inactiveInnIconButtonPath = "lyshineui/images/map/icon/icon_inn_inactive_button.dds",
  hourglassIcon = "lyshineui/images/icons/misc/icon_hourglass.dds",
  leftMouseIcon = "lyshineui/images/icons/misc/Icon_LeftMouseButton_square.dds",
  storageIcon = "lyshineui/images/map/icon/icon_storage.dds",
  viewTaxIcon = "lyshineui/images/map/icon/icon_viewTax.dds",
  viewWarIcon = "lyshineui/images/map/icon/icon_viewWar.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MapFortressInfoMenu)
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local warDeclarationPopupHelper = RequireScript("LyShineUI.WarDeclaration.WarDeclarationPopupHelper")
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
local fastTravelCommon = RequireScript("LyShineUI._Common.FastTravelCommon")
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local TooltipCommon = RequireScript("LyShineUI._Common.TooltipCommon")
function MapFortressInfoMenu:OnInit()
  BaseElement.OnInit(self)
  self.panelTypes = mapTypes.panelTypes
  self.fastTravelPopupId = "fast_travel_popup_id"
  self.fastTravelErrorToText = fastTravelCommon.fastTravelErrorToText
  self.houses = {}
  DynamicBus.Map.Connect(self.entityId, self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.battleType = self.BATTLE_TYPE_NONE
  self.WarButton:SetCallback("OnWarButtonClick", self)
  self.WarButton:SetButtonStyle(self.WarButton.BUTTON_STYLE_HERO)
  self.CloseButton:SetCallback(self.OnFortInfoClose, self)
  self.TerritoryOwnershipButton:SetCallback(self.OnTerritoryOwnershipPressed, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_SIDE_PANEL_RIGHT)
  self.influenceEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-territory-faction-influence")
  self.territoryIncentivesEnabled = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-territory-incentives-screen")
  self.BattleDescriptionValue:SetFormat(self.BattleDescriptionValue.FORMAT_SHORTHAND)
  self.warButtonY = UiTransformBus.Event.GetLocalPositionY(self.Properties.WarButton)
  self.warButtonHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.WarButton)
  local fortText = "@ui_fortress"
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
    fortText = "@ui_settlement"
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.TypeText, fortText, eUiTextSet_SetLocalized)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootPlayerId)
    if rootPlayerId then
      self.rootPlayerId = rootPlayerId
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Social.DataSynced", function(self, synced)
    if synced then
      self.siegeDuration = WarRequestBus.Broadcast.GetWarPhaseDuration(eWarPhase_Conquest):ToHours()
    end
  end)
  self.settlementCategoryData = {
    [eSettlementProgressionCategory_Blacksmithing] = {
      index = 0,
      icon = "lyshineUI/images/icons/worldmap/worldmap_blacksmith.dds",
      name = "@ui_blacksmith"
    },
    [eSettlementProgressionCategory_Engineering] = {
      index = 1,
      icon = "lyshineUI/images/icons/worldmap/worldmap_engineering.dds",
      name = "@engineering"
    },
    [eSettlementProgressionCategory_Outfitting] = {
      index = 2,
      icon = "lyshineUI/images/icons/worldmap/worldmap_outfitting.dds",
      name = "@outfitting"
    },
    [eSettlementProgressionCategory_Cooking] = {
      index = 3,
      icon = "lyshineUI/images/icons/worldmap/worldmap_cooking.dds",
      name = "@cooking_station"
    },
    [eSettlementProgressionCategory_Alchemy] = {
      index = 4,
      icon = "lyshineUI/images/icons/worldmap/worldmap_alchemy.dds",
      name = "@ui_alchemy"
    },
    [eSettlementProgressionCategory_Carpentry] = {
      index = 5,
      icon = "lyshineUI/images/icons/worldmap/worldmap_carpentry.dds",
      name = "@carpentry_station"
    },
    [eSettlementProgressionCategory_Masonry] = {
      index = 6,
      icon = "lyshineUI/images/icons/worldmap/worldmap_masonry.dds",
      name = "@ui_masonry"
    },
    [eSettlementProgressionCategory_Weaving] = {
      index = 7,
      icon = "lyshineUI/images/icons/worldmap/worldmap_weaving.dds",
      name = "@weaving"
    },
    [eSettlementProgressionCategory_Tanning] = {
      index = 8,
      icon = "lyshineUI/images/icons/worldmap/worldmap_tannery.dds",
      name = "@tanning_station"
    },
    [eSettlementProgressionCategory_Smelting] = {
      index = 9,
      icon = "lyshineUI/images/icons/worldmap/worldmap_smelter.dds",
      name = "@smelting"
    }
  }
  self.tierColors = {
    [0] = {
      color = self.UIStyle.COLOR_TAX_LEVEL_6
    },
    [1] = {
      color = self.UIStyle.COLOR_TAX_LEVEL_4
    },
    [2] = {
      color = self.UIStyle.COLOR_TAX_LEVEL_2
    },
    [3] = {
      color = self.UIStyle.COLOR_TAX_LEVEL_1
    }
  }
end
function MapFortressInfoMenu:OnShutdown()
  DynamicBus.Map.Disconnect(self.entityId, self)
  self.socialDataHandler:OnDeactivate()
end
function MapFortressInfoMenu:OnTick(deltaTime, timePoint)
  self.timer = self.timer + deltaTime
  if self.timer >= self.timerTickSeconds then
    self.timer = self.timer - self.timerTickSeconds
    self:UpdateWarDeclarationCoolDown()
  end
end
function MapFortressInfoMenu:StartTick()
  if not self.tickHandler then
    self.timer = 0
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function MapFortressInfoMenu:StopTick()
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function MapFortressInfoMenu:OnShowPanel(panelType, settlementId, outpostId, outpostName)
  local desiredPanel = self.panelTypes.Fortress
  if ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled") then
    desiredPanel = self.panelTypes.Town
  end
  if panelType ~= desiredPanel then
    self:SetMapFortressInfoVisibility(false)
    return
  end
  self.settlementId = settlementId
  self.name = outpostName
  self.actorId = outpostId
  if self.landClaimHandler then
    self:BusDisconnect(self.landClaimHandler)
  end
  self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, settlementId)
  local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(settlementId)
  local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(settlementId)
  self:UpdatePosition(posData)
  self:UpdateOwnership(ownerData)
  self:SetMapFortressInfoVisibility(true)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", function(self, warId)
    if not warId then
      return
    end
    local warDetails = WarDataClientRequestBus.Broadcast.GetWarDetails(warId)
    if warDetails and warDetails:GetTerritoryId() == self.settlementId then
      local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(settlementId)
      self:UpdateWarAndInvasionState(ownerData)
    end
  end)
  local taxData = LandClaimRequestBus.Broadcast.GetTerritoryGovernanceData(self.settlementId)
  UiTextBus.Event.SetText(self.Properties.PropertyTaxAmount, TerritoryDataHandler:GetTaxOrFeeDisplayText(taxData.houseFee, eTaxOrFee_PropertyTax))
  UiTextBus.Event.SetText(self.Properties.TradingTaxAmount, TerritoryDataHandler:GetTaxOrFeeDisplayText(taxData.tradingFee, eTaxOrFee_TradingTax))
  UiTextBus.Event.SetText(self.Properties.CraftingFeeAmount, TerritoryDataHandler:GetTaxOrFeeDisplayText(taxData.craftingFee, eTaxOrFee_CraftingFee))
  UiTextBus.Event.SetText(self.Properties.RefiningFeeAmount, TerritoryDataHandler:GetTaxOrFeeDisplayText(taxData.refiningFee, eTaxOrFee_RefiningFee))
  UiTextBus.Event.SetColor(self.Properties.PropertyTaxAmount, TerritoryDataHandler:GetTaxOrFeeColor(self.settlementId, eTaxOrFee_PropertyTax))
  UiTextBus.Event.SetColor(self.Properties.TradingTaxAmount, TerritoryDataHandler:GetTaxOrFeeColor(self.settlementId, eTaxOrFee_TradingTax))
  UiTextBus.Event.SetColor(self.Properties.CraftingFeeAmount, TerritoryDataHandler:GetTaxOrFeeColor(self.settlementId, eTaxOrFee_CraftingFee))
  UiTextBus.Event.SetColor(self.Properties.RefiningFeeAmount, TerritoryDataHandler:GetTaxOrFeeColor(self.settlementId, eTaxOrFee_RefiningFee))
  local propertyTaxTooltip = "@ui_property_tax" .. " : " .. TerritoryDataHandler:GetTaxOrFeeText(self.settlementId, eTaxOrFee_PropertyTax)
  local tradingTaxTooltip = "@ui_trading_tax" .. " : " .. TerritoryDataHandler:GetTaxOrFeeText(self.settlementId, eTaxOrFee_TradingTax)
  local craftingFeeTooltip = "@ui_crafting_fee" .. " : " .. TerritoryDataHandler:GetTaxOrFeeText(self.settlementId, eTaxOrFee_CraftingFee)
  local refiningFeeTooltip = "@ui_refining_fee" .. " : " .. TerritoryDataHandler:GetTaxOrFeeText(self.settlementId, eTaxOrFee_RefiningFee)
  self.PropertyTaxTooltip:SetSimpleTooltip(propertyTaxTooltip)
  self.TradingTaxTooltip:SetSimpleTooltip(tradingTaxTooltip)
  self.CraftingFeeTooltip:SetSimpleTooltip(craftingFeeTooltip)
  self.RefiningFeeTooltip:SetSimpleTooltip(refiningFeeTooltip)
  local plotEntityId = self:UpdateHousing()
  if plotEntityId and not self.playerHousingClientNotificationBusHandler then
    self.playerHousingClientNotificationBusHandler = self:BusConnect(PlayerHousingClientNotificationBus, plotEntityId)
  end
  local storageButtonData = {
    buttonText = "@ui_view_personalstorage",
    isEnabled = true,
    showQuestionMark = false,
    icon = self.storageIcon,
    callbackTable = self,
    callback = function(self)
      self:OnClickViewPersonalStorage()
    end
  }
  self.StorageButton:SetData(storageButtonData)
  self.fastTravelButtonsContainerHeight = 108
  self.fastTravelContainerHeight = 128
  self:MakeFastTravelButton(true, self.InnButton)
  local numHouses = #self.houses
  if 0 < numHouses then
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.HouseButton, self.defaultButtonHeight)
    UiElementBus.Event.SetIsEnabled(self.Properties.HouseButton, true)
    self.fastTravelButtonsContainerHeight = self.fastTravelButtonsContainerHeight + 54
    self.fastTravelContainerHeight = self.fastTravelContainerHeight + 54
    self:MakeHouseButton(false, self.HouseButton)
  else
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.HouseButton, 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.HouseButton, false)
  end
  self:MakeFastTravelButton(false, self.FastTravelButton)
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.FastTravelContainer, self.fastTravelContainerHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.FastTravelButtonsContainer, self.fastTravelButtonsContainerHeight)
  self:SetUpgradeInfo()
end
function MapFortressInfoMenu:MakeFastTravelButton(forInn, entity)
  self.innAtThisSettlementIsActive = PlayerHousingClientRequestBus.Broadcast.HasFastTravelPointInTerritory(self.settlementId, true)
  local buttonText = forInn and "@ui_inn_fast_travel" or "@ui_fast_travel"
  local timerText, timerIcon, costText, totalText, buttonIcon, refreshTimer, cooldownEndCallback, cooldownTimeWallClock, timerLocTag, tooltipInfo
  local showQuestionMark = false
  local buttonTextTertiary
  local fastTravelResult = PlayerHousingClientRequestBus.Broadcast.CanFastTravelToTerritory(self.settlementId, forInn == true, false)
  local canFastTravel = fastTravelResult == eCanFastTravelToSettlementResults_Success
  if forInn then
    canFastTravel = fastTravelResult == eCanFastTravelToSettlementResults_Success and self.innAtThisSettlementIsActive
    if self.innAtThisSettlementIsActive then
      buttonIcon = self.activeInnIconButtonPath
    else
      buttonIcon = self.inactiveInnIconButtonPath
    end
  else
    local azothAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount") or 0
    local fastTravelCost = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryCost(self.settlementId)
    local hasEnoughCurrency = azothAmount >= fastTravelCost
    local color = hasEnoughCurrency and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_RED
    costText = fastTravelCost
    totalText = "<font color=" .. ColorRgbaToHexString(color) .. ">" .. azothAmount .. "</font>" .. " /"
    buttonText = "@ui_fast_travel"
    timerIcon = "lyshineui/images/icon_azoth.dds"
    buttonIcon = "LyShineUI/Images/map/icon/icon_fastTravel_button.dds"
  end
  if canFastTravel then
    if forInn then
      buttonText = "@ui_inn_fast_travel"
    end
    showQuestionMark = false
  else
    local fastTravelErrorText = self.fastTravelErrorToText[fastTravelResult]
    if fastTravelResult == eCanFastTravelToSettlementResults_InCooldown and (self.innAtThisSettlementIsActive or not forInn) then
      local cooldownTime = fastTravelCommon:GetCurrentlySetInnCooldownTime()
      local timeBeforeRecall = timeHelpers:ConvertSecondsToHrsMinSecString(cooldownTime)
      tooltipInfo = "@ui_fast_travel_error_description_inCooldown"
      timerText = GetLocalizedReplacementText("@ui_fast_travel_error_inCooldown", {time = timeBeforeRecall})
      timerIcon = self.hourglassIcon
      refreshTimer = true
      cooldownEndCallback = forInn and self.OnInnCooldownTimerEnd or self.OnHouseCooldownTimerEnd
      cooldownTimeWallClock = fastTravelCommon:GetCurrentlySetInnCooldownTime(true)
      timerLocTag = "@ui_fast_travel_error_inCooldown"
    elseif fastTravelResult == eCanFastTravelToSettlementResults_InvalidDestinationTerritoryId or fastTravelResult == eCanFastTravelToSettlementResults_InvalidStartingTerritoryId then
      buttonTextTertiary = fastTravelErrorText
    end
    if forInn then
      if not self.innAtThisSettlementIsActive then
        tooltipInfo = "@ui_not_checked_in"
        showQuestionMark = true
      end
      if fastTravelResult ~= eCanFastTravelToSettlementResults_InCooldown then
        UiTextBus.Event.SetTextWithFlags(self.Properties.FastTravelErrorMessage, fastTravelErrorText, eUiTextSet_SetLocalized)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.FastTravelErrorMessage, 30)
        local textHeight = UiTextBus.Event.GetTextHeight(self.Properties.FastTravelErrorMessage)
        local spacing = 8
        self.fastTravelContainerHeight = self.fastTravelContainerHeight + textHeight + spacing
      else
        UiTextBus.Event.SetText(self.Properties.FastTravelErrorMessage, "")
        UiTransformBus.Event.SetLocalPositionY(self.Properties.FastTravelErrorMessage, 0)
      end
    end
  end
  if not forInn then
    local costs = PlayerHousingClientRequestBus.Broadcast.GetFastTravelCosts(self.settlementId)
    local distanceCost = math.floor(costs.distanceCost)
    local encumbranceCost = math.floor(costs.encumbranceCost)
    local baseCost = math.floor(costs.baseCost)
    local factionDiscountPct = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryFactionDiscountPct()
    local companyDiscountPct = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryCompanyDiscountPct()
    local attributeDiscountPct = PlayerHousingClientRequestBus.Broadcast.GetFastTravelToTerritoryAttributeDiscountPct()
    local governanceData = LandClaimRequestBus.Broadcast.GetTerritoryGovernanceData(self.settlementId)
    local overdueUpkeep = governanceData.failedToPayUpkeep
    local factionType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    local myGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
    local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.settlementId)
    local hasFactionDiscount = factionType == ownerData.faction and factionType ~= nil and factionType ~= eFactionType_None and not overdueUpkeep
    local hasCompanyDiscount = ownerData.guildId ~= nil and myGuildId == ownerData.guildId and not overdueUpkeep
    local hasAttributeDiscount = attributeDiscountPct ~= 0
    local totalCost = baseCost + distanceCost + encumbranceCost
    local totalDiscount = totalCost - costText
    local totalFCPDiscount = costs.baseCostDiscount + costs.distanceCostDiscount + costs.encumbranceCostDiscount
    tooltipInfo = {
      isDiscount = true,
      name = "@ui_tooltip_fasttravel_cost",
      totalDiscounts = totalDiscount,
      costEntries = {
        {
          name = "@ui_tooltip_base_cost",
          type = TooltipCommon.DiscountEntryTypes.Cost,
          cost = baseCost + costs.baseCostDiscount
        },
        {
          name = "@ui_tooltip_distance_cost",
          type = TooltipCommon.DiscountEntryTypes.Cost,
          cost = distanceCost + costs.distanceCostDiscount
        },
        {
          name = "@ui_tooltip_encumbrance_cost",
          type = TooltipCommon.DiscountEntryTypes.Cost,
          cost = encumbranceCost + costs.encumbranceCostDiscount
        }
      },
      costEntriesDiscounts = {
        {
          name = "@ui_fcp_fast_travel_discounts_title",
          type = TooltipCommon.DiscountEntryTypes.CostDiscounts,
          discount = totalFCPDiscount
        }
      },
      discountEntries = {
        {
          name = "@ui_tooltip_faction_discount",
          type = TooltipCommon.DiscountEntryTypes.Faction,
          discountPct = factionDiscountPct,
          hasDiscount = hasFactionDiscount,
          roundValue = true
        },
        {
          name = "@ui_tooltip_company_discount",
          type = TooltipCommon.DiscountEntryTypes.Company,
          discountPct = companyDiscountPct,
          hasDiscount = hasCompanyDiscount,
          roundValue = true,
          useRemainingValue = not hasAttributeDiscount
        }
      }
    }
    if hasAttributeDiscount then
      table.insert(tooltipInfo.discountEntries, {
        name = "@ui_tooltip_attribute_discount",
        type = TooltipCommon.DiscountEntryTypes.Attribute,
        discountPct = attributeDiscountPct,
        hasDiscount = true,
        roundValue = true,
        useRemainingValue = true
      })
    end
  end
  if buttonTextTertiary ~= nil then
    local buttonHeight = entity:SetFlyoutRowButtonTextTertiary(buttonTextTertiary)
    UiLayoutCellBus.Event.SetTargetHeight(entity.entityId, buttonHeight)
    local difference = buttonHeight - self.defaultButtonHeight
    self.fastTravelButtonsContainerHeight = self.fastTravelButtonsContainerHeight + difference
    self.fastTravelContainerHeight = self.fastTravelContainerHeight + difference
  end
  local fastTravelPopupHeader = forInn and "@ui_inn_fast_travel" or "@ui_fast_travel"
  local fastTravelPopupDesc = forInn and "@ui_inn_recall_popup_confirm" or "@ui_fast_travel_popup_confirm"
  local buttonData = {
    buttonText = buttonText,
    buttonTextTertiary = buttonTextTertiary,
    isEnabled = canFastTravel,
    forceUpdate = true,
    icon = buttonIcon,
    timer = timerText,
    cost = costText,
    total = totalText,
    bottomPadding = 0,
    timerIcon = timerIcon,
    refreshTimer = refreshTimer,
    timeWallClock = cooldownTimeWallClock,
    timerEndCallback = cooldownEndCallback,
    timerLocTag = timerLocTag,
    showQuestionMark = showQuestionMark,
    tooltipInfo = tooltipInfo,
    callbackTable = self,
    callback = function(self)
      if canFastTravel then
        self:RequestFastTravel(nil, forInn, fastTravelPopupHeader, fastTravelPopupDesc)
      end
    end
  }
  entity:SetData(buttonData)
end
function MapFortressInfoMenu:MakeHouseButton(forInn, entity)
  local numHouses = #self.houses
  local myRaidId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Raid.Id")
  local isAtWar = myRaidId and myRaidId:IsValid()
  local isEncumbered = LocalPlayerUIRequestsBus.Broadcast.IsEncumbered()
  local usingAzoth = self.dataLayer:GetDataFromNode("javelin.use-azoth-currency")
  local isInArena = PlayerArenaRequestBus.Event.IsInArena(self.rootPlayerId) or PlayerArenaRequestBus.Event.IsArenaTeleportPending(self.rootPlayerId)
  local fastTravelCost = usingAzoth and 0 or PlayerHousingClientRequestBus.Broadcast.GetFastTravelCost()
  local currencyAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount")
  local hasEnoughCurrency = fastTravelCost <= currencyAmount
  local vitalsId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.VitalsEntityId")
  local isInDeathsDoor = VitalsComponentRequestBus.Event.IsDeathsDoor(vitalsId)
  local isDead = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.IsDead")
  local ownedHouseData = PlayerHousingClientRequestBus.Broadcast.GetOwnedHouseData()
  local tooltipInfo, buttonText, isEnabled, icon, skipLocalization, callbackTable, callback, timerIcon, timerText, refreshTimer, timeWallClock
  local showQuestionMark = false
  local buttonTextTertiary
  for i = 1, numHouses do
    local areTaxesPaid = false
    local isHubAvailable = true
    local taxesDueTime
    local remainingFastTravelCooldownTime = 0
    if self.houses[i] <= #ownedHouseData then
      local thisHouseData = ownedHouseData[self.houses[i]]
      areTaxesPaid = thisHouseData.taxesDue > timeHelpers:ServerNow()
      isHubAvailable = thisHouseData:IsHubAvailable()
      taxesDueTime = thisHouseData.taxesDue
      remainingFastTravelCooldownTime = PlayerHousingClientRequestBus.Broadcast.GetRemainingFastTravelCooldownTimeInSeconds(self.houses[i] - 1)
    end
    local houseText = GetLocalizedReplacementText(areTaxesPaid and "@ui_my_house_map_desc" or "@ui_my_house_map_desc_disabled", {
      location = self.name,
      number = tostring(i)
    })
    local canFastTravel = not isAtWar and remainingFastTravelCooldownTime <= 0 and isHubAvailable and not isDead and not isInDeathsDoor and not isEncumbered and hasEnoughCurrency
    if isAtWar then
      buttonText = "@ui_recall_to_house"
      tooltipInfo = "@ui_cannot_travel_in_war"
      isEnabled = false
      icon = self.houseIconButtonPath
    elseif not areTaxesPaid then
      buttonText = "@ui_pay_property_tax"
      buttonTextTertiary = "@ui_pay_property_tax_desc"
      isEnabled = true
      icon = self.houseIconButtonPath
      skipLocalization = false
      callbackTable = self
      function callback(self)
        PlayerHousingClientRequestBus.Broadcast.RequestTaxesDue(self.houses[i] - 1)
        DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true, 5, self, function(self)
          local notificationData = NotificationData()
          notificationData.type = "Minor"
          notificationData.text = "@ui_remote_house_payment_unavailable"
          UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        end)
        self.dataLayer:RegisterDataCallback(self, "Hud.Housing.OnRequestedTaxes", function(self, taxesDue)
          self.dataLayer:UnregisterObserver(self, "Hud.Housing.OnRequestedTaxes")
          DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
          DynamicBus.HousingManagement.Broadcast.OnRequestPayPropertyTaxPopup(taxesDue, taxesDueTime, self, function(self)
            local playerWallet = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.Amount") or 0
            if playerWallet < taxesDue then
              local notificationData = NotificationData()
              notificationData.type = "Minor"
              notificationData.text = "@ui_remote_house_payment_need_coin"
              UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
              return
            end
            DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true, 5, self, function(self)
              local notificationData = NotificationData()
              notificationData.type = "Minor"
              notificationData.text = "@ui_remote_house_payment_unavailable"
              UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
            end)
            PlayerHousingClientRequestBus.Broadcast.RequestPayTaxes(self.houses[i] - 1)
            self.dataLayer:RegisterDataCallback(self, "Hud.Housing.OnPayTaxResponse", function(self, success)
              self.dataLayer:UnregisterObserver(self, "Hud.Housing.OnPayTaxResponse")
              DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
              local taxesDueText = GetLocalizedReplacementText("@ui_coin_icon", {
                coin = GetLocalizedCurrency(taxesDue)
              })
              if success then
                LyShineManagerBus.Broadcast.SetState(2702338936)
                popupWrapper:RequestPopupWithParams({
                  title = "@ui_payment_successful",
                  message = "@ui_property_tax_success_desc",
                  eventId = "RemoteHousingPaySuccess",
                  buttonText = "@ui_close",
                  customData = {
                    {
                      detailType = "TextLabelAndValue",
                      label = "@ui_paid",
                      value = taxesDueText
                    }
                  }
                })
              end
            end)
          end)
        end)
      end
    elseif 0 < remainingFastTravelCooldownTime then
      if usingAzoth then
        local azothAmount = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Currency.AzothAmount")
        local cooldownResetCost = PlayerHousingClientRequestBus.Broadcast.GetFastTravelCooldownResetCost(self.houses[i] - 1)
        local canAffordResetCooldown = azothAmount >= cooldownResetCost
        local replacementText
        if canAffordResetCooldown then
          replacementText = "@ui_cannot_reset_travel_currency"
        else
          replacementText = "@ui_need_reset_travel_currency"
        end
        buttonTextTertiary = GetLocalizedReplacementText(replacementText, {
          coin = GetFormattedNumber(cooldownResetCost)
        })
        local cooldownTimeWallClock = WallClockTimePoint:Now():AddDuration(Duration.FromSecondsUnrounded(remainingFastTravelCooldownTime))
        buttonText = "@ui_recall_to_house"
        isEnabled = canAffordResetCooldown
        timerIcon = self.hourglassIcon
        timerText = timeHelpers:ConvertSecondsToHrsMinSecString(remainingFastTravelCooldownTime)
        refreshTimer = true
        timeWallClock = cooldownTimeWallClock
        icon = self.houseIconButtonPath
        callbackTable = self
        function callback(self)
          popupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_fast_travel_reset_popup", "@ui_fast_travel_reset_popup_confirm", self.fastTravelPopupId, self, function(self, result, eventId)
            if result == ePopupResult_Yes then
              PlayerHousingClientRequestBus.Broadcast.RequestResetCooldown(self.houses[i] - 1)
            end
          end)
        end
      end
    elseif isDead or isInDeathsDoor then
      buttonText = "@ui_recall_to_house"
      tooltipInfo = "@ui_cannot_travel_dead"
    elseif isInArena then
      buttonText = "@ui_recall_to_house"
      tooltipInfo = "@ui_cannot_travel_encounter"
    else
      do
        local isButtonEnabled = true
        if not isHubAvailable then
          tooltipInfo = "@ui_recall_not_available_server_error"
          isButtonEnabled = false
        elseif isEncumbered then
          tooltipInfo = "@ui_cannot_travel_encumbered"
          isButtonEnabled = false
        elseif not hasEnoughCurrency then
          tooltipInfo = GetLocalizedReplacementText("@ui_cannot_travel_currency", {
            coin = GetLocalizedCurrency(fastTravelCost)
          })
          isButtonEnabled = false
        end
        local fastTravelHeader = "@ui_my_house_map_title"
        local fastTravelDesc = "@ui_house_recall_popup_confirm"
        buttonText = "@ui_recall_to_house"
        isEnabled = isButtonEnabled
        icon = self.houseIconButtonPath
        callbackTable = self
        function callback(self)
          self:RequestFastTravel(self.houses[i] - 1, false, fastTravelHeader, fastTravelDesc)
        end
      end
    end
  end
  if buttonTextTertiary ~= nil then
    local buttonHeight = self.HouseButton:SetFlyoutRowButtonTextTertiary(buttonTextTertiary)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.HouseButton, buttonHeight)
    local difference = buttonHeight - self.defaultButtonHeight
    self.fastTravelButtonsContainerHeight = self.fastTravelButtonsContainerHeight + difference
    self.fastTravelContainerHeight = self.fastTravelContainerHeight + difference
  end
  local buttonData = {
    buttonText = buttonText,
    tooltipInfo = tooltipInfo,
    buttonTextTertiary = buttonTextTertiary,
    isEnabled = isEnabled,
    icon = icon,
    bottomPadding = 0,
    timer = timerText,
    timerIcon = timerIcon,
    timeWallClock = timeWallClock,
    refreshTimer = refreshTimer,
    showQuestionMark = showQuestionMark,
    callbackTable = callbackTable,
    callback = callback
  }
  entity:SetData(buttonData)
end
function MapFortressInfoMenu:RequestFastTravel(houseIndex, forInn, fastTravelText, fastTravelDesc)
  popupWrapper:RequestPopup(ePopupButtons_YesNo, fastTravelText, fastTravelDesc, self.fastTravelPopupId, self, function(self, result, eventId)
    if eventId == self.fastTravelPopupId and result == ePopupResult_Yes then
      local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
      local numMissionsAbandonedOnFastTravel = ObjectivesComponentRequestBus.Event.GetNumObjectivesCannotFastTravel(playerEntityId)
      local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
      if interactorEntity then
        UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
      end
      if numMissionsAbandonedOnFastTravel == 0 then
        if houseIndex then
          self:RequestHouseFastTravel(houseIndex)
        else
          self:RequestSettlementFastTravel(forInn)
        end
      else
        do
          local confirmAbandonText = GetLocalizedReplacementText("@ui_fast_travel_mission_abandon_confirm", {count = numMissionsAbandonedOnFastTravel})
          local abandonMissionsId = "HousingFastTravelAbandon"
          popupWrapper:RequestPopup(ePopupButtons_YesNo, "@owg_action_abandon", confirmAbandonText, abandonMissionsId, self, function(self, result, eventId)
            if eventId == abandonMissionsId and result == ePopupResult_Yes then
              if houseIndex then
                self:RequestHouseFastTravel(houseIndex)
              else
                self:RequestSettlementFastTravel(forInn)
              end
            end
          end)
        end
      end
    end
  end)
end
function MapFortressInfoMenu:RequestHouseFastTravel(houseIndex)
  PlayerHousingClientRequestBus.Broadcast.RequestFastTravelToHome(houseIndex)
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function MapFortressInfoMenu:RequestSettlementFastTravel(forInn)
  PlayerHousingClientRequestBus.Broadcast.RequestFastTravelToTerritory(self.settlementId, forInn == true, false)
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function MapFortressInfoMenu:UpdateHousing(taxesPaid)
  if taxesPaid == nil then
    ClearTable(self.houses)
    local ownedHouses = PlayerHousingClientRequestBus.Broadcast.GetOwnedHouseData()
    if #ownedHouses == 0 then
      return
    end
    local hasUnpaidTaxes = false
    local plotEntityId
    for i = 1, #ownedHouses do
      local houseData = ownedHouses[i]
      local territoryId = MapComponentBus.Broadcast.GetContainingTerritory(houseData.housingPlotPos)
      if territoryId == self.settlementId then
        plotEntityId = PlayerHousingClientRequestBus.Broadcast.GetPlotEntityIdFromOwnedHouseData(houseData)
        hasUnpaidTaxes = houseData.taxesDue <= timeHelpers:ServerNow()
        table.insert(self.houses, i)
        break
      end
    end
    self.houseIconButtonPath = hasUnpaidTaxes and self.disabledHouseIconButtonPath or "lyshineui/images/map/icon/icon_house_button.dds"
    return plotEntityId
  else
    self.houseIconButtonPath = taxesPaid and "lyshineui/images/map/icon/icon_house_button.dds" or self.disabledHouseIconButtonPath
  end
end
function MapFortressInfoMenu:OnTaxesPaid()
  self:UpdateHousing(true)
end
function MapFortressInfoMenu:OnTaxesDue()
  self:UpdateHousing(false)
end
function MapFortressInfoMenu:OnClickViewPersonalStorage()
  DynamicBus.Map.Broadcast.OnShowPanel(self.panelTypes.Storage, self.actorId, self.name)
end
function MapFortressInfoMenu:IsCursorOnFortressInfoContainer()
  if self.isVisible then
    local screenPoint = CursorBus.Broadcast.GetCursorPosition()
    local viewportRect = UiTransformBus.Event.GetViewportSpaceRect(self.entityId)
    local viewportLeft = viewportRect:GetCenterX() - viewportRect:GetWidth() / 2
    if viewportLeft <= screenPoint.x then
      return true
    end
  end
  return false
end
function MapFortressInfoMenu:UpdatePosition(posData)
  if posData then
    local territoryName = posData.territoryName
    if territoryName == nil or territoryName == "" then
      local vec2Pos = Vector2(posData.worldPos.x, posData.worldPos.y)
      local tract = MapComponentBus.Broadcast.GetTractAtPosition(vec2Pos)
      territoryName = "@" .. tract
    end
    local upgradeType = eTerritoryUpgradeType_Fortress
    local sourceNameText = "@ui_fortress_header"
    local factionControlEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.faction-control.enabled")
    if factionControlEnabled then
      upgradeType = eTerritoryUpgradeType_Settlement
      sourceNameText = "@ui_township_header"
    end
    local tierInfo = TerritoryDataHandler:GetUpgradeTierInfoByTerritoryId(self.settlementId, upgradeType)
    local nameText = GetLocalizedReplacementText(sourceNameText, {
      name = territoryName,
      tier = tierInfo.name
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.NameText, nameText, eUiTextSet_SetAsIs)
    local imagePath = "lyshineui/images/map/panelImages/mapPanel_fort" .. self.settlementId .. ".dds"
    local invalidImagePath = "lyshineui/images/map/panelImages/mapPanel_fort_default.dds"
    if factionControlEnabled then
      imagePath = "lyshineui/images/map/panelImages/mapPanel_settlement" .. self.settlementId .. ".dds"
      invalidImagePath = "lyshineui/images/map/panelImages/mapPanel_settlement_default.dds"
    end
    if not LyShineScriptBindRequestBus.Broadcast.IsFileExists(imagePath) then
      imagePath = invalidImagePath
    end
    UiImageBus.Event.SetSpritePathname(self.Properties.FortImage, imagePath)
    self.territoryName = territoryName
  end
end
function MapFortressInfoMenu:UpdateOwnership(ownerData)
  self.guildId = ownerData.guildId
  self.guildName = ownerData.guildName
  self.guildCrestData = ownerData.guildCrestData
  self.isClaimed = self.guildId and self.guildId:IsValid()
  UiElementBus.Event.SetIsEnabled(self.Properties.GovernedByNameText, self.isClaimed)
  UiElementBus.Event.SetIsEnabled(self.Properties.NotClaimedText, not self.isClaimed)
  UiElementBus.Event.SetIsEnabled(self.Properties.FactionText, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.BattleDescriptionContainer, self.isClaimed)
  UiElementBus.Event.SetIsEnabled(self.Properties.BattleDescriptionDivider, self.isClaimed)
  UiElementBus.Event.SetIsEnabled(self.Properties.SiegeWindowSection, self.isClaimed)
  UiElementBus.Event.SetIsEnabled(self.Properties.ButtonContainer, self.isClaimed)
  UiElementBus.Event.SetIsEnabled(self.Properties.SiegeWindowDivider1, self.isClaimed)
  UiElementBus.Event.SetIsEnabled(self.Properties.SiegeWindowDivider2, self.isClaimed)
  if self.isClaimed then
    UiTextBus.Event.SetText(self.Properties.GovernedByNameText, ownerData.guildName)
    UiTextBus.Event.SetText(self.Properties.DefenderName, ownerData.guildName)
    self.GovernedByCrest:SetIcon(ownerData.guildCrestData)
    self.DefenderCrest:SetIcon(ownerData.guildCrestData)
    UiImageBus.Event.SetColor(self.Properties.DefenderWash, ownerData.guildCrestData.backgroundColor)
    self:UpdateAsyncGuildData()
    self:UpdateWarAndInvasionState(ownerData)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.SiegeWindowSection, 21)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.InfluenceWarContainer, 100)
    UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceWarContainer, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.NoWarGovernance, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceWarContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.WarGovernance, false)
    local noneFactionData = FactionCommon.factionInfoTable[eFactionType_None]
    self.GovernedByCrest:SetBackground(self.basicCrestBg, noneFactionData.crestBgColor)
    self.GovernedByCrest:SetForeground(noneFactionData.crestFg, noneFactionData.crestFgColor)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.BattleDescriptionContainer, 0)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.SiegeWindowSection, 0)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.InfluenceWarContainer, 0)
  end
  local guildIdValid = ownerData.guildId and ownerData.guildId:IsValid()
  if guildIdValid then
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionText, false)
  end
  local enableTerritoryOwnershipButton = self.territoryIncentivesEnabled and ownerData.faction ~= eFactionType_None
  enableTerritoryOwnershipButton = enableTerritoryOwnershipButton
  UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryOwnershipButton, enableTerritoryOwnershipButton)
end
function MapFortressInfoMenu:UpdateAsyncGuildData()
  local myGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local isMyGuild = self.guildId == myGuildId
  if isMyGuild then
    local siegeWindow = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.SiegeWindow")
    self:SetSiegeWindowText(siegeWindow)
    self.ownerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Faction")
    self:SetFactionInfo()
  else
    self.socialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
      local guildData
      if 0 < #result then
        guildData = type(result[1]) == "table" and result[1].guildData or result[1]
      else
        Log("ERR - MapFortressInfoMenu:UpdateAsyncGuildData: GuildData request returned with no data")
        return
      end
      if guildData and guildData:IsValid() then
        self:SetSiegeWindowText(guildData.siegeWindow)
        self.ownerFaction = guildData.faction
        self:SetFactionInfo()
        local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.settlementId)
        self:UpdateWarAndInvasionState(ownerData)
      end
    end, self.GuildRequestFailed, self.guildId)
  end
  self:UpdateFactionInfluenceMeters()
end
function MapFortressInfoMenu:UpdateFactionInfluenceMeters()
  FactionCommon:GetFaction(self.guildId, function(self, owningFaction, owningCrest)
    if not owningFaction then
      self.InfluenceWarWidget:SetIsEnabled(false)
    else
      local influenceData = LandClaimRequestBus.Broadcast.GetTerritoryFactionInfluencePercentages(self.settlementId)
      self.InfluenceWarWidget:SetInfluenceWarData(self.territoryName, owningFaction, owningCrest, influenceData)
      self.InfluenceWarWidget:SetIsEnabled(true)
    end
  end, self)
end
function MapFortressInfoMenu:OnTerritoryFactionInfluenceChanged(claimKey, influenceData)
  if claimKey ~= self.settlementId then
    return
  end
  self:UpdateFactionInfluenceMeters()
end
function MapFortressInfoMenu:UpdateConflictDetails(conflictFaction, alreadyAtWar, warDetails)
  local isInConflict = conflictFaction ~= eFactionType_None
  local lotteryEndTime = LandClaimRequestBus.Broadcast.GetTerritoryConflictLotteryEndTime(self.settlementId)
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local remainingLotteryTime = lotteryEndTime:Subtract(now):ToSeconds()
  local hasLotteryStarted = 0 < remainingLotteryTime
  local showWarState = alreadyAtWar or hasLotteryStarted
  UiElementBus.Event.SetIsEnabled(self.Properties.NoWarGovernance, not showWarState)
  UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceWarContainer, not showWarState)
  UiElementBus.Event.SetIsEnabled(self.Properties.WarGovernance, showWarState)
  local governanceHeight = showWarState and 235 or 133
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.GovernanceContainer, governanceHeight)
  local showContribution = false
  if alreadyAtWar and warDetails then
    local warPhase = warDetails:GetWarPhase()
    local isConflict = warPhase == eWarPhase_Conquest
    local isResolution = warPhase == eWarPhase_Resolution
    if self.battleType ~= self.BATTLE_TYPE_INVASION then
      if isConflict or isResolution then
        UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, isConflict and "@ui_encounter_ongoingwar" or "@ui_fortressinfo_resolveingwarlabel", eUiTextSet_SetLocalized)
        local descriptionLabel = isConflict and "@ui_fortressinfo_ongoingwarlabel" or "@ui_fortressinfo_resolveingwarlabel"
        UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionLabel, descriptionLabel, eUiTextSet_SetLocalized)
        UiElementBus.Event.SetIsEnabled(self.Properties.BattleDescriptionValue, false)
        self.isShowingBattleTimer = false
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_upcomingwar", eUiTextSet_SetLocalized)
        UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionLabel, "@ui_fortressinfo_upcomingwarlabel", eUiTextSet_SetLocalized)
        local siegeStartTime = warDetails:GetConquestStartTime():Subtract(now):ToSecondsRoundedUp()
        UiElementBus.Event.SetIsEnabled(self.Properties.BattleDescriptionValue, true)
        self.BattleDescriptionValue:SetCurrentCountdownTime(siegeStartTime)
        self.isShowingBattleTimer = true
      end
      UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionBody, "@ui_fortressinfo_atwardescription", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWorkText, "@ui_how_does_war_work", eUiTextSet_SetLocalized)
    else
      self.AttackerCrest:SetBackground(self.basicCrestBg, self.UIStyle.COLOR_RED_DEEP)
      self.AttackerCrest:SetForeground(self.invasionCrestFg, self.UIStyle.COLOR_RED)
      UiImageBus.Event.SetColor(self.Properties.AttackerWash, self.UIStyle.COLOR_RED_DARK)
      UiTextBus.Event.SetTextWithFlags(self.Properties.AttackerName, "@ui_fortressinfo_invasionattackername", eUiTextSet_SetLocalized)
      UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionBody, "@ui_fortressinfo_invasiondescription", eUiTextSet_SetLocalized)
      if isConflict or isResolution then
        UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, isConflict and "@ui_encounter_ongoinginvasion" or "@ui_fortressinfo_resolvinginvasion", eUiTextSet_SetLocalized)
        local descriptionLabel = isConflict and "@ui_fortressinfo_ongoinginvasion" or "@ui_fortressinfo_resolvinginvasion"
        UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionLabel, descriptionLabel, eUiTextSet_SetLocalized)
        UiElementBus.Event.SetIsEnabled(self.Properties.BattleDescriptionValue, false)
        self.isShowingBattleTimer = false
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_encounter_upcominginvasion", eUiTextSet_SetLocalized)
        UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionLabel, "@ui_fortressinfo_invasion", eUiTextSet_SetLocalized)
        local invasionStartTime = warDetails:GetConquestStartTime():Subtract(now):ToSecondsRoundedUp()
        UiElementBus.Event.SetIsEnabled(self.Properties.BattleDescriptionValue, true)
        self.BattleDescriptionValue:SetCurrentCountdownTime(invasionStartTime)
        self.isShowingBattleTimer = true
      end
      UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWorkText, "@ui_how_does_invasion_work", eUiTextSet_SetLocalized)
    end
  elseif isInConflict then
    UiTextBus.Event.SetTextWithFlags(self.Properties.ConflictText, "@ui_in_conflict", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionLabel, "@ui_fortressinfo_timetodeclare", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWorkText, "@ui_how_does_war_work", eUiTextSet_SetLocalized)
    local timeRemainingToDeclare
    if hasLotteryStarted then
      UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionBody, "@ui_fortressinfo_lotterydescription", eUiTextSet_SetLocalized)
      timeRemainingToDeclare = remainingLotteryTime
      UiElementBus.Event.SetIsEnabled(self.Properties.AttackerCrest, false)
      UiTextBus.Event.SetTextWithFlags(self.Properties.AttackerName, "@ui_unknown", eUiTextSet_SetLocalized)
      UiImageBus.Event.SetColor(self.Properties.AttackerWash, self.UIStyle.COLOR_GRAY_50)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionBody, "@ui_fortressinfo_conflictdescription", eUiTextSet_SetLocalized)
      local configDurationMins = ConfigProviderEventBus.Broadcast.GetUInt64("javelin.territory-conflict-duration-minutes")
      local conflictStartTime = LandClaimRequestBus.Broadcast.GetTerritoryConflictStartTime(self.settlementId)
      local endTime = conflictStartTime:AddDuration(Duration.FromMinutesUnrounded(configDurationMins))
      timeRemainingToDeclare = endTime:Subtract(now):ToSeconds()
    end
    showContribution = true
    UiElementBus.Event.SetIsEnabled(self.Properties.BattleDescriptionValue, true)
    local isInWarLockoutPeriod = JavSocialComponentBus.Broadcast.IsInWarLockoutPeriod(self.settlementId)
    if isInWarLockoutPeriod then
      self.BattleDescriptionValue:OverrideTimeText("@ui_fortressinfo_timetodeclare_paused_invasion")
      self.isShowingBattleTimer = false
    else
      self.BattleDescriptionValue:SetCurrentCountdownTime(timeRemainingToDeclare)
      self.isShowingBattleTimer = true
    end
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionLabel, "@ui_fortressinfo_noconflict", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.BattleDescriptionBody, "@ui_fortressinfo_noconflictdescription", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.HowDoesWarWorkText, "@ui_how_does_war_work", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.BattleDescriptionValue, false)
    self.isShowingBattleTimer = false
    showContribution = true
  end
  local contributionDescriptionHeight = 0
  if showContribution then
    UiElementBus.Event.SetIsEnabled(self.Properties.ContributionDescription, true)
    local guildHasContribution = WarRequestBus.Broadcast.DoesGuildHaveInfluenceToDeclareWar(self.settlementId)
    if guildHasContribution then
      local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
      local contributionIsRequired = LandClaimRequestBus.Broadcast.GetTerritoryRequiresGuildContribution(self.settlementId, playerFaction)
      if contributionIsRequired then
        UiTextBus.Event.SetTextWithFlags(self.Properties.ContributionDescription, "@ui_fortressinfo_hascontribution", eUiTextSet_SetLocalized)
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.ContributionDescription, "@ui_fortressinfo_contributionnotrequired", eUiTextSet_SetLocalized)
      end
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.ContributionDescription, "@ui_fortressinfo_insufficientcontribution", eUiTextSet_SetLocalized)
    end
    contributionDescriptionHeight = UiTextBus.Event.GetTextHeight(self.Properties.ContributionDescription)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ContributionDescription, false)
  end
  local descriptionBodyHeight = UiTextBus.Event.GetTextHeight(self.Properties.BattleDescriptionBody)
  local margin = 24
  local buttonContainerY = self.warButtonY + descriptionBodyHeight + contributionDescriptionHeight + margin
  local lowerPadding = 76
  UiLayoutCellBus.Event.SetTargetHeight(self.Properties.BattleDescriptionContainer, buttonContainerY + self.warButtonHeight + lowerPadding)
  self:UpdateBattleTimeTicking()
end
function MapFortressInfoMenu:SetSiegeWindowText(siegeWindow)
  local text = dominionCommon:GetSiegeWindowText(siegeWindow, self.siegeDuration)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SiegeWindowText, text, eUiTextSet_SetAsIs)
  UiElementBus.Event.SetIsEnabled(self.Properties.SiegeWindowText, true)
end
function MapFortressInfoMenu:SetFactionInfo()
  local factionData = FactionCommon.factionInfoTable[self.ownerFaction]
  if factionData then
    UiElementBus.Event.SetIsEnabled(self.Properties.FactionText, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.FactionIcon, factionData.crestBgSmall)
    UiImageBus.Event.SetColor(self.Properties.FactionIcon, factionData.crestBgColor)
    UiTextBus.Event.SetTextWithFlags(self.Properties.FactionText, factionData.factionName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.FactionText, factionData.chatColor)
  end
end
function MapFortressInfoMenu:UpdateWarAndInvasionState(ownerData)
  local validWarDetails
  if self.settlementId ~= 0 then
    local warDetails = WarDataServiceBus.Broadcast.GetWarForTerritory(self.settlementId)
    if warDetails:IsValid() and warDetails:IsWarActive() then
      validWarDetails = warDetails
    end
  end
  if validWarDetails then
    if validWarDetails:IsInvasion() then
      self.battleType = self.BATTLE_TYPE_INVASION
    else
      self.battleType = self.BATTLE_TYPE_WAR
    end
  else
    self.battleType = self.BATTLE_TYPE_NONE
  end
  local isResolution = validWarDetails and validWarDetails:GetWarPhase() == eWarPhase_Resolution
  local isCurrentlyWarring = false
  if validWarDetails then
    isCurrentlyWarring = validWarDetails:GetWarPhase() == eWarPhase_War or validWarDetails:GetWarPhase() == eWarPhase_Conquest
  end
  local signupStatus = RaidSetupRequestBus.Broadcast.GetSignupStatus(self.settlementId)
  local isAtWarOrInInvasion = self.battleType == self.BATTLE_TYPE_INVASION or self.battleType == self.BATTLE_TYPE_WAR
  if isAtWarOrInInvasion then
    if isResolution then
      self.WarButton:SetText("@ui_fortressinfo_button_declarewar")
    elseif not signupStatus or signupStatus.side == eRaidSide_None then
      local buttonText = self.battleType == self.BATTLE_TYPE_WAR and "@ui_fortressinfo_button_warsignup" or "@ui_fortressinfo_button_invasionsignup"
      self.WarButton:SetText(buttonText)
    else
      self.WarButton:SetText("@ui_fortressinfo_button_warstatus")
    end
    local siegeStartTime = validWarDetails:GetConquestStartTime():Subtract(self.epoch):ToSecondsRoundedUp()
    local dateString = timeHelpers:GetLocalizedAbbrevDate(siegeStartTime)
    if self.battleType == self.BATTLE_TYPE_WAR then
      local otherGuildId = validWarDetails:GetOtherGuild(self.guildId)
      local ready = self.socialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
        local guildData
        if 0 < #result then
          guildData = type(result[1]) == "table" and result[1].guildData or result[1]
        else
          Log("ERR - MapFortressInfoMenu:UpdateWarAndInvasionState: GuildData request returned with no data")
          return
        end
        if guildData and guildData:IsValid() then
          UiElementBus.Event.SetIsEnabled(self.Properties.AttackerCrest, true)
          self.AttackerCrest:SetIcon(guildData.crestData)
          UiTextBus.Event.SetText(self.Properties.AttackerName, guildData.guildName)
          UiImageBus.Event.SetColor(self.Properties.AttackerWash, guildData.crestData.backgroundColor)
        end
      end, self.GuildRequestFailed, otherGuildId)
      if not ready then
        UiElementBus.Event.SetIsEnabled(self.Properties.AttackerCrest, false)
      end
    end
  else
    self.WarButton:SetText("@ui_fortressinfo_button_declarewar")
  end
  local buttonEnabled = false
  local playerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local playerIsInAGuild = playerGuildId and playerGuildId:IsValid()
  local sameGuild = playerIsInAGuild and playerGuildId == self.guildId
  local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
  local sameFaction = playerFaction == self.ownerFaction
  local hasPermission = GuildsComponentBus.Broadcast.HasPrivilege(eGuildPrivilegeId_Declare_War)
  local conflictFaction = LandClaimRequestBus.Broadcast.GetTerritoryConflictFaction(self.settlementId)
  local canDeclareWar = false
  local isInConflict = conflictFaction ~= eFactionType_None and playerFaction == conflictFaction
  local conflictsWithInvasion = WarRequestBus.Broadcast.DoesWarConflictWithInvasion(self.guildId, self.settlementId)
  local guildHasContribution = WarRequestBus.Broadcast.DoesGuildHaveInfluenceToDeclareWar(self.settlementId)
  local isGuildInActiveWarLottery = GuildsComponentBus.Broadcast.IsGuildInActiveWarLottery()
  if not isAtWarOrInInvasion then
    canDeclareWar = self.battleType == self.BATTLE_TYPE_NONE and not self.declareWarCoolDownEndTime and playerIsInAGuild and not sameGuild and hasPermission and not sameFaction and not conflictsWithInvasion and guildHasContribution and (isInConflict or not self.influenceEnabled) and not isGuildInActiveWarLottery
    buttonEnabled = canDeclareWar
  else
    local allowRemoteSignup = ConfigProviderEventBus.Broadcast.GetBool("javelin.social.enable-war-signup-from-map")
    buttonEnabled = not isResolution and (allowRemoteSignup or signupStatus and signupStatus.side ~= eRaidSide_None)
  end
  if buttonEnabled then
    self.WarButton:SetEnabled(true)
    local tooltip
    if canDeclareWar and self.influenceEnabled then
      tooltip = "@ui_war_refund_tooltip"
    end
    self.WarButton:SetTooltip(tooltip)
  else
    self.WarButton:SetEnabled(false)
    local tooltipText
    if not isAtWarOrInInvasion then
      if not playerIsInAGuild then
        tooltipText = "@ui_war_declare_fail_notInAGuild"
      elseif sameGuild then
        tooltipText = "@ui_war_declare_fail_ownguild"
      elseif not hasPermission then
        tooltipText = "@ui_war_declare_fail_noPermissions"
      elseif sameFaction then
        tooltipText = "@ui_war_declare_fail_SameFaction"
      elseif conflictsWithInvasion then
        tooltipText = "@ui_war_declare_fail_invasionScheduled"
      elseif isCurrentlyWarring then
        tooltipText = "@ui_war_declare_fail_conflictResolving"
      elseif not guildHasContribution then
        tooltipText = "@ui_war_declare_fail_InsufficientContribution"
      elseif not isInConflict and self.influenceEnabled then
        tooltipText = "@ui_not_in_conflict"
      elseif isGuildInActiveWarLottery then
        tooltipText = "@ui_war_declare_fail_alreadyInLottery"
      elseif self.declareWarCoolDownEndTime then
        self:StartTick()
        self:UpdateWarDeclarationCoolDown()
      end
    elseif isResolution then
      tooltipText = "@ui_war_declare_fail_conflictResolving"
    end
    self.WarButton:SetTooltip(tooltipText)
  end
  self:UpdateConflictDetails(conflictFaction, validWarDetails ~= nil, validWarDetails)
end
function MapFortressInfoMenu:UpdateWarDeclarationCoolDown()
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local remainingSeconds = self.declareWarCoolDownEndTime:Subtract(now):ToSeconds()
  if 0 <= remainingSeconds then
    local remainingTime = timeHelpers:ConvertToShorthandString(remainingSeconds, true)
    local text = GetLocalizedReplacementText("@ui_fortressinfo_wardeclarationcooldown", {time = remainingTime})
    self.WarButton:SetTooltip(text)
  else
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.WarButton, true)
    self:StopTick()
    self.WarButton:SetTooltip(nil)
  end
end
function MapFortressInfoMenu:GuildRequestFailed(reason)
  if reason == eSocialRequestFailureReasonThrottled then
    Log("ERR - MapFortressInfoMenu:GuildRequestFailed: Throttled")
  elseif reason == eSocialRequestFailureReasonTimeout then
    Log("ERR - MapFortressInfoMenu:GuildRequestFailed: Timed Out")
  end
end
function MapFortressInfoMenu:OnClaimOwnerChanged(settlementId, newOwnerData)
  if self.settlementId ~= settlementId then
    return
  end
  self:UpdateOwnership(newOwnerData)
end
function MapFortressInfoMenu:SetMapFortressInfoVisibility(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  self.WarButton:StartStopImageSequence(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
    self.ScriptedEntityTweener:Play(self.entityId, 0.35, {
      x = 0,
      alpha = 1,
      ease = "QuadOut"
    })
    self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.LandClaimManager.WarInfluenceChanged", function(self, warInfluenceChanged)
      self:UpdateFactionInfluenceMeters()
    end)
  else
    if self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
    end
    self.landClaimHandler = nil
    self:StopTick()
    self.ScriptedEntityTweener:Play(self.entityId, 0.25, {
      x = 600,
      alpha = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.entityId, false)
      end
    })
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId")
    self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.LandClaimManager.WarInfluenceChanged")
    if self.playerHousingClientNotificationBusHandler then
      self:BusDisconnect(self.playerHousingClientNotificationBusHandler)
      self.playerHousingClientNotificationBusHandler = nil
    end
  end
  self:UpdateBattleTimeTicking()
end
function MapFortressInfoMenu:UpdateBattleTimeTicking()
  local shouldTick = self.isVisible and self.isShowingBattleTimer
  self.BattleDescriptionValue:SetTicking(shouldTick)
end
function MapFortressInfoMenu:OnWarButtonClick()
  local isAtWarOrInInvasion = self.battleType == self.BATTLE_TYPE_INVASION or self.battleType == self.BATTLE_TYPE_WAR
  if isAtWarOrInInvasion then
    LyShineManagerBus.Broadcast.SetState(1319313135)
    RaidSetupRequestBus.Broadcast.RequestRemoteInteract(self.settlementId)
    DynamicBus.Raid.Broadcast.SetIsRemoteInteract(true)
  else
    warDeclarationPopupHelper:ShowWarDeclarationPopup(self.guildId, self.guildName, self.guildCrestData, self.settlementId)
  end
end
function MapFortressInfoMenu:OnFortInfoClose()
  self:SetMapFortressInfoVisibility(false)
end
function MapFortressInfoMenu:OnShowWarTutorial()
  local isInvasion = self.battleType == self.BATTLE_TYPE_INVASION
  local gameMode = isInvasion and GameModeCommon.GAMEMODE_INVASION or GameModeCommon.GAMEMODE_WAR
  DynamicBus.WarTutorialPopup.Broadcast.ShowWarTutorialPopup(gameMode)
end
function MapFortressInfoMenu:OnTerritoryOwnershipPressed()
  if self.settlementId == nil then
    return
  end
  DynamicBus.TerritoryIncentivesNotifications.Broadcast.OnRequestTerritoryIncentivesScreen(self.settlementId)
end
function MapFortressInfoMenu:SetUpgradeInfo()
  local summaryData = LandClaimRequestBus.Broadcast.GetTerritoryProgressionData(self.settlementId)
  local availableTerritoryUpgrades = summaryData.territoryUpgrades
  local totalUpgradesDone = 0
  if self.isClaimed then
    for i = 1, #availableTerritoryUpgrades do
      local upgradeData = availableTerritoryUpgrades[i]
      local category = upgradeData.category
      local categoryLevel = upgradeData.categoryLevel
      for j = 0, #self.settlementCategoryData do
        if category == self.settlementCategoryData[j].index then
          totalUpgradesDone = totalUpgradesDone + categoryLevel
          local tierText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_station_tier", categoryLevel + 2)
          UiTextBus.Event.SetTextWithFlags(self.Properties.Stations[j], tierText, eUiTextSet_SetAsIs)
          local icon = UiElementBus.Event.FindChildByName(self.Properties.Stations[j], "Icon")
          UiImageBus.Event.SetSpritePathname(icon, self.settlementCategoryData[j].icon)
          local tooltip = UiElementBus.Event.FindChildByName(self.Properties.Stations[j], "TooltipSetter")
          tooltip = self.registrar:GetEntityTable(tooltip)
          tooltip:SetSimpleTooltip(self.settlementCategoryData[j].name)
          local tierColor = self.tierColors[categoryLevel].color
          UiTextBus.Event.SetColor(self.Properties.Stations[j], tierColor)
        end
      end
    end
  else
    for j = 0, #self.settlementCategoryData do
      local tierText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_station_tier", 2)
      UiTextBus.Event.SetTextWithFlags(self.Properties.Stations[j], tierText, eUiTextSet_SetAsIs)
      local icon = UiElementBus.Event.FindChildByName(self.Properties.Stations[j], "Icon")
      UiImageBus.Event.SetSpritePathname(icon, self.settlementCategoryData[j].icon)
      local tooltip = UiElementBus.Event.FindChildByName(self.Properties.Stations[j], "TooltipSetter")
      tooltip = self.registrar:GetEntityTable(tooltip)
      tooltip:SetSimpleTooltip(self.settlementCategoryData[j].name)
      local tierColor = self.tierColors[0].color
      UiTextBus.Event.SetColor(self.Properties.Stations[j], tierColor)
    end
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.UpgradesCompletedText, totalUpgradesDone, eUiTextSet_SetAsIs)
end
return MapFortressInfoMenu
