local HomePurchase = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    NoDiscount = {
      PriceContainer = {
        default = EntityId()
      },
      TaxContainer = {
        default = EntityId()
      },
      HousePrice = {
        default = EntityId()
      },
      PropertyTax = {
        default = EntityId()
      }
    },
    Discount = {
      PriceContainer = {
        default = EntityId()
      },
      TaxContainer = {
        default = EntityId()
      },
      HousePrice = {
        Normal = {
          default = EntityId()
        },
        Discounted = {
          default = EntityId()
        },
        DiscountTooltip = {
          default = EntityId()
        }
      },
      Tax = {
        Normal = {
          default = EntityId()
        },
        Discounted = {
          default = EntityId()
        },
        DiscountTooltip = {
          default = EntityId()
        }
      }
    },
    PreviewButton = {
      default = EntityId()
    },
    PurchaseButton = {
      default = EntityId()
    },
    PurchaseSuccessContainer = {
      default = EntityId()
    },
    PurchaseSuccessDetailText = {
      default = EntityId()
    },
    PurchaseSuccessCloseButton = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    BackgroundContainer = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    },
    NeedTerritoryStandingMessage = {
      default = EntityId()
    },
    NeedTerritoryStandingMessageText = {
      default = EntityId()
    },
    HouseTypeItemsValueText = {
      default = EntityId()
    },
    HouseTypeCooldownValueText = {
      default = EntityId()
    },
    HouseTypeTrophiesText = {
      default = EntityId()
    },
    HouseTypeTrophiesValueText = {
      default = EntityId()
    },
    ItemQuestionMark = {
      default = EntityId()
    }
  },
  purchaseHouseProgressionId = 972880053,
  abandonPopupId = "AbandonHousePopupId",
  purchasePopupId = "PurchaseHousePopupId"
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(HomePurchase)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local TooltipCommon = RequireScript("LyShineUI._Common.TooltipCommon")
function HomePurchase:OnInit()
  BaseScreen.OnInit(self)
  self.PreviewButton:SetText("@ui_house_preview")
  self.PreviewButton:SetCallback(self.OnPreviewHouse, self)
  self.PurchaseButton:SetCallback(self.OnRequestPurchaseHouse, self)
  self.PurchaseSuccessCloseButton:SetCallback(self.OnClosePurchaseSuccess, self)
  self.PurchaseButton:SetButtonStyle(self.PurchaseButton.BUTTON_STYLE_HERO)
  self.ScreenHeader:SetText("@ui_housing_purchase_house")
  self.ScreenHeader:SetHintCallback(self.OnHomeBackButton, self)
  self.ScreenHeader:SetStyle(self.ScreenHeader.SCREEN_HEADER_STYLE_COIN)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
  self.ItemQuestionMark:SetButtonStyle(self.ItemQuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    if playerEntityId then
      local staticRewardData = ProgressionPointRequestBus.Event.GetStaticProgressionPointData(playerEntityId, self.purchaseHouseProgressionId)
      local territoryRequiredRank = staticRewardData.requiredProgressionLevel
      local territoryBonusText = GetLocalizedReplacementText("@ui_house_purchase_error_territory_bonus_desc", {standingRank = territoryRequiredRank})
      UiTextBus.Event.SetText(self.Properties.NeedTerritoryStandingMessageText, territoryBonusText)
    end
  end)
  AdjustElementToCanvasSize(self.Properties.PurchaseSuccessContainer, self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
end
function HomePurchase:OnShutdown()
  BaseScreen.OnShutdown(self)
end
function HomePurchase:OnTransitionIn(fromStateName, fromLevelName, toStateName, toLevelName)
  self:InitializeBuyHouseData()
  JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_HousingPurchase", 0.5)
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.BackgroundContainer, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.BackgroundContainer, 0.5, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = 0.2
  })
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 13
  self.targetDOFBlur = 0.5
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 0.5,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function HomePurchase:OnTransitionOut(fromStateName, fromLevelName, toStateName, toLevelName)
  self.PurchaseButton:StartStopImageSequence(false)
  self:OnClosePurchaseSuccess()
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_HousingPurchase", 0.5)
  local interactorEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.BackgroundContainer, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function HomePurchase:InitializeBuyHouseData()
  local guildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  local territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  local isPartOfOwningGuild = guildId and guildId ~= 0 and territoryId and TerritoryDataHandler:GetGoverningGuildId(territoryId) == guildId
  local taxesOverdue = TerritoryDataHandler:IsUpkeepOverdue(territoryId)
  local plotEntityId = PlayerHousingClientRequestBus.Broadcast.GetInteractionHousingPlotEntityId()
  local houseNumberCostMultiplier = PlayerHousingClientRequestBus.Broadcast.GetHouseNumberCostMultiplier(plotEntityId)
  local basePlotCost = HousingPlotRequestBus.Event.GetPlotCost(plotEntityId)
  local baseTaxRate = HousingPlotRequestBus.Event.GetTaxesCost(plotEntityId)
  local territoryBonusDiscount = PlayerHousingClientRequestBus.Broadcast.GetPropertyTaxModifierTerritory(self.playerEntityId, territoryId)
  local factionControlDiscount = PlayerHousingClientRequestBus.Broadcast.GetPropertyTaxModifierFactionControl(self.playerEntityId, territoryId)
  local isFirstHouse = not PlayerHousingClientRequestBus.Broadcast.GetHasPurchasedHouse()
  local firstHouseDiscount = isFirstHouse and LocalPlayerUIRequestsBus.Broadcast.GetFirstHouseDiscountModifier() or 1
  local companyDiscountIsValid = isPartOfOwningGuild and not taxesOverdue
  local showPriceDiscount = companyDiscountIsValid or isFirstHouse
  local showTaxDiscount = companyDiscountIsValid or 0 < factionControlDiscount or 0 < territoryBonusDiscount
  UiElementBus.Event.SetIsEnabled(self.Properties.NoDiscount.PriceContainer, not showPriceDiscount)
  UiElementBus.Event.SetIsEnabled(self.Properties.Discount.PriceContainer, showPriceDiscount)
  UiElementBus.Event.SetIsEnabled(self.Properties.NoDiscount.TaxContainer, not showTaxDiscount)
  UiElementBus.Event.SetIsEnabled(self.Properties.Discount.TaxContainer, showTaxDiscount)
  local housePrice
  if showPriceDiscount then
    local owningGuildHouseCostModifier = companyDiscountIsValid and LocalPlayerUIRequestsBus.Broadcast.GetControllingCompanyHouseCostModifier() or 0
    basePlotCost = basePlotCost * houseNumberCostMultiplier
    local basePrice = GetLocalizedReplacementText("@ui_coin_icon", {
      coin = GetLocalizedCurrency(basePlotCost)
    })
    local discountedPrice = basePlotCost * (1 - owningGuildHouseCostModifier) * firstHouseDiscount
    UiTextBus.Event.SetText(self.Properties.Discount.HousePrice.Normal, basePrice)
    housePrice = GetLocalizedReplacementText("@ui_coin_icon", {
      coin = GetLocalizedCurrency(discountedPrice)
    })
    UiTextBus.Event.SetText(self.Properties.Discount.HousePrice.Discounted, housePrice)
    local discountedPricePercent = math.floor(owningGuildHouseCostModifier * 100 + 0.5)
    local priceTooltipInfo = {
      isDiscount = true,
      name = "@ui_house_purchase_confirm_popup_title",
      useLocalizedCurrency = true,
      costEntries = {
        {
          name = "@ui_house_price",
          type = TooltipCommon.DiscountEntryTypes.Cost,
          cost = basePlotCost
        }
      },
      discountEntries = {}
    }
    if companyDiscountIsValid then
      table.insert(priceTooltipInfo.discountEntries, {
        name = "@ui_tooltip_company_discount",
        type = TooltipCommon.DiscountEntryTypes.Company,
        discountPct = discountedPricePercent,
        hasMultiplicativeDiscount = companyDiscountIsValid and 0.1 < discountedPricePercent
      })
    end
    if isFirstHouse then
      table.insert(priceTooltipInfo.discountEntries, {
        name = "@ui_tooltip_firsthouse_discount",
        type = TooltipCommon.DiscountEntryTypes.TerritoryStanding,
        discountPct = (1 - firstHouseDiscount) * 100,
        hasMultiplicativeDiscount = true
      })
    end
    self.Discount.HousePrice.DiscountTooltip:SetTooltipInfo(priceTooltipInfo)
  else
    local houseCostMultiplier = PlayerHousingClientRequestBus.Broadcast.GetHousingCostMultiplier(plotEntityId, true)
    housePrice = GetLocalizedReplacementText("@ui_coin_icon", {
      coin = GetLocalizedCurrency(basePlotCost * houseCostMultiplier)
    })
    UiTextBus.Event.SetText(self.Properties.NoDiscount.HousePrice, housePrice)
  end
  if showTaxDiscount then
    local owningGuildTaxCostModifier = companyDiscountIsValid and LocalPlayerUIRequestsBus.Broadcast.GetControllingCompanyTaxModifier() or 0
    baseTaxRate = baseTaxRate * houseNumberCostMultiplier
    local baseTax = GetLocalizedReplacementText("@ui_house_property_tax_desc", {
      coin = GetLocalizedCurrency(baseTaxRate)
    })
    UiTextBus.Event.SetText(self.Properties.Discount.Tax.Normal, baseTax)
    local discountedTax = baseTaxRate * (1 - territoryBonusDiscount) * (1 - factionControlDiscount) * (1 - owningGuildTaxCostModifier)
    local propertyTaxText = GetLocalizedReplacementText("@ui_house_property_tax_desc", {
      coin = GetLocalizedCurrency(discountedTax)
    })
    UiTextBus.Event.SetText(self.Properties.Discount.Tax.Discounted, propertyTaxText)
    local discountedTaxPercent = math.floor(owningGuildTaxCostModifier * 100 + 0.5)
    local taxTooltipInfo = {
      isDiscount = true,
      name = "@ui_house_tax",
      useLocalizedCurrency = true,
      costEntries = {
        {
          name = "@ui_house_tax",
          type = TooltipCommon.DiscountEntryTypes.Cost,
          cost = baseTaxRate
        }
      },
      discountEntries = {}
    }
    if companyDiscountIsValid then
      table.insert(taxTooltipInfo.discountEntries, {
        name = "@ui_tooltip_company_discount",
        type = TooltipCommon.DiscountEntryTypes.Company,
        discountPct = discountedTaxPercent,
        hasMultiplicativeDiscount = companyDiscountIsValid and 0.1 < discountedTaxPercent
      })
    end
    if 0 < territoryBonusDiscount then
      table.insert(taxTooltipInfo.discountEntries, {
        name = "@ui_tooltip_standing_discount",
        type = TooltipCommon.DiscountEntryTypes.TerritoryStanding,
        discountPct = territoryBonusDiscount * 100,
        hasMultiplicativeDiscount = true
      })
    end
    if 0 < factionControlDiscount then
      table.insert(taxTooltipInfo.discountEntries, {
        name = "@ui_tooltip_faction_discount",
        type = TooltipCommon.DiscountEntryTypes.Faction,
        discountPct = factionControlDiscount * 100,
        hasMultiplicativeDiscount = true
      })
    end
    self.Discount.Tax.DiscountTooltip:SetTooltipInfo(taxTooltipInfo)
  else
    local propertyTaxText = GetLocalizedReplacementText("@ui_house_property_tax_desc", {
      coin = GetLocalizedCurrency(baseTaxRate)
    })
    UiTextBus.Event.SetText(self.Properties.NoDiscount.PropertyTax, propertyTaxText)
  end
  local canPreviewHouse = true
  UiElementBus.Event.SetIsEnabled(self.Properties.PreviewButton, canPreviewHouse)
  local territoryName = TerritoryDataHandler:GetTerritoryNameFromTerritoryId(territoryId)
  local buttonText, tooltipText
  local canPurchasePlotReason = PlayerHousingClientRequestBus.Broadcast.CanPurchasePlot()
  local previewButtonPosY = -106
  local showNeedPermissionBonusMessage = false
  local showPurchaseButton = true
  local houseTypeData = HousingPlotRequestBus.Event.GetHouseTypeData(plotEntityId)
  if canPurchasePlotReason == eCanPurchasePlotReturnResults_AlreadyHasHomeOnPlot then
    tooltipText = "@ui_house_already_owned"
  elseif canPurchasePlotReason == eCanPurchasePlotReturnResults_PlotFull then
    tooltipText = "@ui_house_purchase_error_full"
  elseif canPurchasePlotReason == eCanPurchasePlotReturnResults_AtMaxHomesOwned then
    tooltipText = "@ui_max_homes_owned"
  elseif canPurchasePlotReason == eCanPurchasePlotReturnResults_AtMaxHousePerTerritory then
    tooltipText = "@ui_max_homes_owned_territory"
  elseif canPurchasePlotReason == eCanPurchasePlotReturnResults_NeedsLevel then
    levelReq = PlayerHousingClientRequestBus.Broadcast.GetPlayerHousingLevelReq()
    local ownedHouses = PlayerHousingClientRequestBus.Broadcast.GetOwnedHouseData()
    if #ownedHouses == 0 then
      tooltipText = GetLocalizedReplacementText("@ui_home_purchase_error_level_first", {level = levelReq})
    else
      tooltipText = GetLocalizedReplacementText("@ui_home_purchase_error_level", {level = levelReq})
    end
  elseif canPurchasePlotReason == eCanPurchasePlotReturnResults_NeedsStanding then
    local territoryRequiredRank = 0
    if houseTypeData then
      territoryRequiredRank = houseTypeData.territoryStandingRequiredRank
    end
    tooltipText = GetLocalizedReplacementText("@ui_house_purchase_error_standing", {standingRank = territoryRequiredRank, standingName = territoryName})
  elseif canPurchasePlotReason == eCanPurchasePlotReturnResults_NeedsTerritoryBonus then
    tooltipText = GetLocalizedReplacementText("@ui_house_purchase_error_territory_bonus", {standingName = territoryName})
    previewButtonPosY = 5
    showNeedPermissionBonusMessage = true
    showPurchaseButton = false
  elseif canPurchasePlotReason == eCanPurchasePlotReturnResults_NeedsCoin then
    tooltipText = "@ui_housing_cant_afford"
  elseif canPurchasePlotReason ~= eCanPurchasePlotReturnResults_Success then
    tooltipText = "@ui_house_purchase_error_unknown"
  end
  buttonText = GetLocalizedReplacementText("@ui_house_purchase", {
    coinText = GetLocalizedCurrency(housePrice)
  })
  self.PurchaseButton:SetText(buttonText)
  self.PurchaseButton:SetTooltip(tooltipText)
  self.PurchaseButton:SetEnabled(canPurchasePlotReason == eCanPurchasePlotReturnResults_Success)
  UiElementBus.Event.SetIsEnabled(self.Properties.PurchaseButton, showPurchaseButton)
  self.PurchaseButton:StartStopImageSequence(showPurchaseButton)
  UiElementBus.Event.SetIsEnabled(self.Properties.NeedTerritoryStandingMessage, showNeedPermissionBonusMessage)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.PreviewButton, previewButtonPosY)
  if houseTypeData and houseTypeData:IsValid() then
    UiTextBus.Event.SetText(self.Properties.HouseTypeItemsValueText, houseTypeData.maxTotalHousingItems)
    UiTextBus.Event.SetText(self.Properties.HouseTypeCooldownValueText, TimeHelpers:ConvertToTwoLargestTimeEstimate(houseTypeData.fastTravelCooldownSeconds))
    local trophyTag = 700226175
    local petTag = 217098342
    local lightTag = 2843505350
    local storageTag = 4244664680
    local tagLimits = {
      [trophyTag] = 0,
      [petTag] = 0,
      [lightTag] = 0,
      [storageTag] = 0
    }
    for i = 1, #houseTypeData.maxHousingItemsPerTag do
      tagPair = houseTypeData.maxHousingItemsPerTag[i]
      tagCrc = tagPair.first
      limit = tagPair.second
      if tagLimits[tagCrc] then
        tagLimits[tagCrc] = limit
      end
    end
    local trophyLimit = tagLimits[trophyTag]
    UiElementBus.Event.SetIsEnabled(self.Properties.HouseTypeTrophiesText, trophyLimit)
    UiElementBus.Event.SetIsEnabled(self.Properties.HouseTypeTrophiesValueText, trophyLimit)
    if trophyLimit then
      UiTextBus.Event.SetText(self.Properties.HouseTypeTrophiesValueText, trophyLimit)
    end
    local petLimit = tagLimits[petTag]
    local lightLimit = tagLimits[lightTag]
    local storageLimit = tagLimits[storageTag]
    local showItemLimitTooltip = 0 < petLimit and 0 < lightLimit and 0 < storageLimit
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemQuestionMark, showItemLimitTooltip)
    if showItemLimitTooltip then
      itemLimitTooltipText = GetLocalizedReplacementText("@ui_house_type_items_limits", {
        numPets = petLimit,
        petPluralOrSingle = petLimit == 1 and "@ui_house_type_pet_singular" or "@ui_house_type_pet_plural",
        numLights = lightLimit,
        lightPluralOrSingle = lightLimit == 1 and "@ui_house_type_light_singular" or "@ui_house_type_light_plural",
        numStorage = storageLimit,
        storagePluralOrSingle = storageLimit == 1 and "@ui_house_type_storage_chest_singular" or "@ui_house_type_storage_chest_plural"
      })
      self.ItemQuestionMark:SetTooltip(itemLimitTooltipText)
    end
  end
end
function HomePurchase:OnPreviewHouse()
  PlayerHousingClientRequestBus.Broadcast.RequestEnterPlot(-1, false, false)
  self:OnHomeBackButton()
end
function HomePurchase:OnRequestPurchaseHouse()
  local alreadyOwnsHouse = false
  if alreadyOwnsHouse then
    local currentHouseName = "OldHouse"
    self.oldHouseName = currentHouseName
    local abandonPopupDesc = GetLocalizedReplacementText("@ui_house_abandon_popup_desc", {houseName = currentHouseName})
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_house_abandon_popup_title", abandonPopupDesc, self.abandonPopupId, self, self.OnPopupResult)
  else
    PopupWrapper:RequestPopupWithParams({
      title = "@ui_house_purchase_confirm_popup_title",
      message = "@ui_house_purchase_confirm_popup_desc",
      eventId = self.purchasePopupId,
      callerSelf = self,
      callback = self.OnPopupResult,
      buttonsYesNo = true,
      yesButtonText = "@ui_house_purchase_confirm_popup_yes_button",
      noButtonText = "@ui_house_purchase_confirm_popup_no_button"
    })
  end
end
function HomePurchase:OnPopupResult(result, eventId)
  if eventId == self.abandonPopupId then
    if result ~= ePopupResult_Yes then
      return
    end
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = GetLocalizedReplacementText("@ui_house_abandon_notification", {
      houseName = self.oldHouseName
    })
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    PlayerHousingClientRequestBus.Broadcast.RequestAbandonHome()
  elseif eventId == self.purchasePopupId then
    if result ~= ePopupResult_Yes then
      return
    end
    PlayerHousingClientRequestBus.Broadcast.RequestPurchaseHome()
    local claimKey = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
    local territoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
    local settlementName = territoryDataHandler:GetTerritoryNameFromTerritoryId(claimKey)
    UiTextBus.Event.SetTextWithFlags(self.Properties.PurchaseSuccessDetailText, GetLocalizedReplacementText("@ui_house_purchased_detail", {settlementName = settlementName}), eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.PurchaseSuccessContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
    self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
      opacity = 1,
      y = 0,
      ease = "QuadOut",
      delay = 0.2
    })
  end
end
function HomePurchase:OnClosePurchaseSuccess()
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 1, y = 0}, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    delay = 0.2,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.PurchaseSuccessContainer, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
      self:OnHomeBackButton()
    end
  })
end
function HomePurchase:OnHomeBackButton()
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function HomePurchase:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.Properties.PurchaseSuccessContainer, self.canvasId)
  end
end
function HomePurchase:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
return HomePurchase
