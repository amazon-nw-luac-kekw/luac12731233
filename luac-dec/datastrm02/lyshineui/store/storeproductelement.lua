local TimeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local StoreProductElement = {
  Properties = {
    Content = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    },
    ItemTitle = {
      default = EntityId()
    },
    IndividualItemTitle = {
      default = EntityId()
    },
    IndividualRewardInfo = {
      default = EntityId()
    },
    ItemDescription = {
      default = EntityId()
    },
    Mask = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    },
    BonusArt = {
      default = EntityId()
    },
    BonusPctText = {
      default = EntityId()
    },
    DiscountArt = {
      default = EntityId()
    },
    DiscountText = {
      default = EntityId()
    },
    RewardInfo = {
      default = EntityId()
    },
    RewardInfoIcon = {
      default = EntityId()
    },
    CurrencyIcon = {
      default = EntityId()
    },
    InitialPrice = {
      default = EntityId()
    },
    FinalPrice = {
      default = EntityId()
    },
    UnlockedText = {
      default = EntityId()
    },
    TimeIcon = {
      default = EntityId()
    },
    TimeInfo = {
      default = EntityId()
    },
    Line = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    SuggestedItemIndicator = {
      default = EntityId()
    },
    SpecialFrame = {
      default = EntityId()
    },
    RewardAmount = {
      default = EntityId()
    },
    BonusAmount = {
      default = EntityId()
    },
    TimeLabel = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    },
    HowToText = {
      default = EntityId()
    },
    HowToContainer = {
      default = EntityId()
    }
  },
  defaultIconImagePath = "lyshineui/images/mtx/storeItem_default.dds",
  defaultPortraitIconImagePath = "lyshineui/images/mtx/storeItem_default_portrait.dds",
  largeFeaturedItemWidth = 1170,
  largeFeaturedItemHeight = 678,
  mediumFeaturedItemWidth = 576,
  smallFeaturedItemWidth = 280,
  smallFeaturedItemHeight = 330,
  showSpecialDiscountTag = false,
  itemBackground_individualItem_offerPage = "lyshineui/images/mtx/offerBackground_individual.dds",
  itemBackground_default = "lyshineui/images/mtx/storeItemBg.dds",
  yellow_tag_path = "lyshineui/images/mtx/strip_yellow.dds",
  red_tag_path = "lyshineui/images/mtx/strip_red.dds",
  mask_rectangle = "lyshineui/images/mtx/mtx_rectangle_mask.dds",
  mask_square = "lyshineui/images/mtx/mtx_square_mask.dds",
  brush_stroke_path = "lyshineui/images/mtx/sale_strip.dds",
  kRewardTypeDisplayText = {
    [eRewardTypeEmote] = "@reward_type_emote",
    [eRewardTypeItemSkin] = "@reward_type_itemskin",
    [eRewardTypeItemDye] = "@reward_type_itemdye",
    [eRewardTypeGuildCrest] = "@reward_type_guildcrest",
    [eRewardTypeGuildForegroundColor] = "@reward_type_guildforegroundcolor",
    [eRewardTypeGuildBackgroundColor] = "@reward_type_guildbackgroundcolor",
    [eRewardTypeHousingItem] = "@reward_type_housing_item",
    [eRewardTypePlayerTitle] = "@reward_type_playertitle",
    [eRewardTypeInventoryItem] = "@reward_type_inventoryitem",
    [eRewardTypeMisc] = "@reward_type_misc",
    [eRewardTypeFictionalCurrency] = "@reward_type_fictionalcurrency",
    [eRewardTypeService] = "@ui_world_transfer_mtx"
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(StoreProductElement)
function StoreProductElement:OnInit()
  BaseElement.OnInit(self)
  self.isEnabled = true
  SetTextStyle(self.Properties.ItemTitle, self.UIStyle.FONT_STYLE_STORE_ITEM_TITLE_SMALL)
  SetTextStyle(self.Properties.RewardInfo, self.UIStyle.FONT_STYLE_STORE_REWARD_INFO)
  SetTextStyle(self.Properties.ItemDescription, self.UIStyle.FONT_STYLE_STORE_ITEM_DESCRIPTION)
  SetTextStyle(self.Properties.FinalPrice, self.UIStyle.FONT_STYLE_STORE_FINAL_PRICE)
  SetTextStyle(self.Properties.InitialPrice, self.UIStyle.FONT_STYLE_STORE_INITIAL_PRICE)
  SetTextStyle(self.Properties.DiscountText, self.UIStyle.FONT_STYLE_STORE_DISCOUNT_TEXT)
  SetTextStyle(self.Properties.TimeInfo, self.UIStyle.FONT_STYLE_STORE_TIME_INFO)
  if self.Properties.HowToText:IsValid() then
    SetTextStyle(self.Properties.HowToText, self.UIStyle.FONT_STYLE_STORE_CONTEXT_TEXT)
  end
  if self.Properties.RewardAmount:IsValid() then
    SetTextStyle(self.Properties.RewardAmount, self.UIStyle.FONT_STYLE_STORE_REWARD_AMOUNT)
  end
  if self.Properties.BonusAmount:IsValid() then
    SetTextStyle(self.Properties.BonusAmount, self.UIStyle.FONT_STYLE_STORE_BONUS_AMOUNT)
  end
  if self.Properties.UnlockedText:IsValid() then
    SetTextStyle(self.Properties.UnlockedText, self.UIStyle.FONT_STYLE_STORE_UNLOCKED_TEXT_SMALL)
  end
  if self.Properties.IndividualItemTitle:IsValid() then
    SetTextStyle(self.Properties.IndividualItemTitle, self.UIStyle.FONT_STYLE_STORE_OFFER_ITEM_TITLE)
  end
  if self.Properties.IndividualRewardInfo:IsValid() then
    SetTextStyle(self.Properties.IndividualRewardInfo, self.UIStyle.FONT_STYLE_STORE_OFFER_REWARD_INFO)
  end
  self.currencyInitialIconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.CurrencyIcon)
end
function StoreProductElement:OnShutdown()
  TimingUtils:StopDelay(self)
end
function StoreProductElement:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function StoreProductElement:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function StoreProductElement:GetHorizontalSpacing()
  return 0
end
function StoreProductElement:SetIsEnabled(isEnabled)
  if isEnabled ~= self.isEnabled then
    self.isEnabled = isEnabled
  end
end
function StoreProductElement:OnClicked()
  if not self.isEnabled then
    return
  end
  if not self.storeProductData then
    return
  end
  self.storeProductData.cb(self.storeProductData.context, self)
end
function StoreProductElement:HoverStart()
  if self.usingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if not self.isEnabled then
    return
  end
  if not self.storeProductData then
    return
  end
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.2, {opacity = 1})
  if self.storeProductData.hoverStartCb then
    self.storeProductData.hoverStartCb(self.storeProductData.context, self)
  end
end
function StoreProductElement:HoverEnd()
  if self.usingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if not self.isEnabled then
    return
  end
  if not self.storeProductData then
    return
  end
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0})
  if self.storeProductData.hoverEndCb then
    self.storeProductData.hoverEndCb(self.storeProductData.context, self)
  end
end
function StoreProductElement:SetSpinnerShowing(isShowing)
  UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, isShowing)
  UiElementBus.Event.SetIsEnabled(self.Properties.Content, not isShowing)
  if isShowing then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
  end
end
function StoreProductElement:UpdateExpiration()
  local timeToExpire = TimeHelpers.secondsInYear
  local discountTimeToExpire = TimeHelpers.secondsInYear
  if self.storeProductData.offer.productExpirationValid then
    timeToExpire = self.storeProductData.offer.productExpiration:Subtract(TimeHelpers:ServerNow()):ToSeconds()
  end
  if self.storeProductData.offer.discountExpirationValid then
    discountTimeToExpire = self.storeProductData.offer.discountExpiration:Subtract(TimeHelpers:ServerNow()):ToSeconds()
  end
  if self.storeProductData.offer.productStartValid and self.storeProductData.offer.productStart > TimeHelpers:ServerNow() then
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeInfo, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.DiscountArt, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.DiscountText, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeInfo, "@ui_mtx_coming_soon", eUiTextSet_SetLocalized)
    return
  end
  if timeToExpire >= TimeHelpers.secondsInYear then
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeInfo, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeIcon, false)
    if self.Properties.TimeLabel:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.TimeLabel, false)
    end
    SetTextStyle(self.Properties.DiscountText, self.UIStyle.FONT_STYLE_STORE_DISCOUNT_TEXT)
  else
    SetTextStyle(self.Properties.DiscountText, self.UIStyle.FONT_STYLE_STORE_LIMITED_OFFER_TEXT)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeInfo, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DiscountArt, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DiscountText, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.DiscountText, "@ui_limited_time", eUiTextSet_SetLocalized)
    local delayTime
    if timeToExpire < 0 then
      timeToExpire = 0
      if self.storeProductData.offerExpiredCb then
        self.storeProductData.offerExpiredCb(self.storeProductData.context, self)
      end
    elseif timeToExpire <= 2 * TimeHelpers.secondsInMinute then
      delayTime = 1
    elseif timeToExpire <= 2 * TimeHelpers.secondsInHour then
      delayTime = TimeHelpers.secondsInMinute
    elseif timeToExpire <= 2 * TimeHelpers.secondsInDay then
      delayTime = TimeHelpers.secondsInHour
    else
      delayTime = TimeHelpers.secondsInDay
    end
    if delayTime then
      TimingUtils:Delay(delayTime, self, self.UpdateExpiration)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeInfo, TimeHelpers:ConvertToShorthandString(timeToExpire, false, true), eUiTextSet_SetLocalized)
    if self.featured or self.escapeMenu then
      UiImageBus.Event.SetSpritePathname(self.Properties.DiscountArt, self.yellow_tag_path)
      UiImageBus.Event.SetColor(self.Properties.DiscountArt, self.UIStyle.COLOR_WHITE)
      SetTextStyle(self.Properties.DiscountText, self.UIStyle.FONT_STYLE_STORE_DISCOUNT_TEXT)
    else
      UiImageBus.Event.SetSpritePathname(self.Properties.DiscountArt, self.brush_stroke_path)
      UiImageBus.Event.SetColor(self.Properties.DiscountArt, self.UIStyle.COLOR_STORE_LIMITED_TIME_OFFER)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.DiscountArt, 168)
    end
    if self.offer or self.popup then
      if self.singleReward then
        UiImageBus.Event.SetSpritePathname(self.Properties.DiscountArt, self.brush_stroke_path)
        UiImageBus.Event.SetColor(self.Properties.DiscountArt, self.UIStyle.COLOR_YELLOW)
        SetTextStyle(self.Properties.DiscountText, self.UIStyle.FONT_STYLE_STORE_LIMITED_OFFER_TEXT)
      else
        UiImageBus.Event.SetSpritePathname(self.Properties.DiscountArt, self.yellow_tag_path)
        UiImageBus.Event.SetColor(self.Properties.DiscountArt, self.UIStyle.COLOR_WHITE)
        SetTextStyle(self.Properties.DiscountText, self.UIStyle.FONT_STYLE_STORE_DISCOUNT_TEXT)
      end
    end
    if self.offer then
      if self.singleReward then
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.DiscountArt, 200)
        UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountArt, Vector2(26, 78))
        UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountText, Vector2(24, -4))
      else
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.DiscountArt, 500)
        UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountArt, Vector2(42, 88))
        UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountText, Vector2(8, 0))
      end
      if self.Properties.TimeLabel:IsValid() then
        UiElementBus.Event.SetIsEnabled(self.Properties.TimeLabel, true)
      end
    elseif self.popup then
      local offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.DiscountText)
      if self.singleReward then
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.DiscountArt, 200)
        if self.Properties.DiscountArt:IsValid() then
          UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountArt, Vector2(88, 2))
        end
        UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.DiscountText, self.UIStyle.TEXT_HALIGN_CENTER)
        offsets.left = -4
        UiTransform2dBus.Event.SetOffsets(self.Properties.DiscountText, offsets)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.DiscountText, -4)
      else
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.DiscountArt, 558)
        if self.Properties.DiscountArt:IsValid() then
          UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountArt, Vector2(0, -4))
        end
        UiTransformBus.Event.SetLocalPositionY(self.Properties.DiscountText, 0)
        offsets.left = 8
        UiTransform2dBus.Event.SetOffsets(self.Properties.DiscountText, offsets)
        UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.DiscountText, self.UIStyle.TEXT_HALIGN_LEFT)
      end
    end
  end
end
function StoreProductElement:UpdateDiscountExpiration()
  local discountTimeToExpire = TimeHelpers.secondsInYear
  if self.storeProductData.offer.discountExpirationValid then
    discountTimeToExpire = self.storeProductData.offer.discountExpiration:Subtract(TimeHelpers:ServerNow()):ToSeconds()
  end
  SetTextStyle(self.Properties.DiscountText, self.UIStyle.FONT_STYLE_STORE_DISCOUNT_TEXT)
  if discountTimeToExpire >= TimeHelpers.secondsInYear then
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeInfo, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeIcon, false)
    if self.Properties.TimeLabel:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.TimeLabel, false)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeInfo, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DiscountArt, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DiscountText, true)
    local delayTime
    if discountTimeToExpire < 0 then
      discountTimeToExpire = 0
      self:UpdatePrice(storeProductData)
    elseif discountTimeToExpire <= 2 * TimeHelpers.secondsInMinute then
      delayTime = 1
    elseif discountTimeToExpire <= 2 * TimeHelpers.secondsInHour then
      delayTime = TimeHelpers.secondsInMinute
    elseif discountTimeToExpire <= 2 * TimeHelpers.secondsInDay then
      delayTime = TimeHelpers.secondsInHour
    else
      delayTime = TimeHelpers.secondsInDay
    end
    if delayTime then
      TimingUtils:Delay(delayTime, self, self.UpdateDiscountExpiration)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.TimeInfo, TimeHelpers:ConvertToShorthandString(discountTimeToExpire, false, true), eUiTextSet_SetLocalized)
  end
end
function StoreProductElement:ShowSuggestedOfferIndicator(isEnabled)
  if self.Properties.SuggestedItemIndicator:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.SuggestedItemIndicator, isEnabled)
  end
end
function StoreProductElement:UpdatePrice(storeProductData)
  local finalPrice = storeProductData.offer.finalPrice
  local originalPrice = storeProductData.offer.originalPrice
  local currencyCode = not self.isFictional and storeProductData.offer.currencyCode or nil
  local priceOverrideText = storeProductData.offer.metadata and storeProductData.offer.metadata.priceOverrideText or nil
  if priceOverrideText then
    finalPrice = 0
    originalPrice = 0
  end
  if finalPrice < originalPrice then
    local discount = string.format("%.0f%%", math.floor(100 * (1 - finalPrice / originalPrice)))
    local discountLocString = self.showSpecialDiscountTag and "@ui_discount_off_bold" or "@ui_discount_off"
    local discountText = GetLocalizedReplacementText(discountLocString, {number = discount})
    if self.Properties.DiscountArt:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.DiscountArt, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.DiscountText, true)
      UiTextBus.Event.SetTextWithFlags(self.Properties.DiscountText, discountText, eUiTextSet_SetLocalized)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.InitialPrice, true)
    if self.showSpecialDiscountTag then
      UiElementBus.Event.SetIsEnabled(self.Properties.SpecialFrame, true)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.SpecialFrame, false)
    end
    if self.offer or self.popup then
      if self.singleReward then
        UiImageBus.Event.SetSpritePathname(self.Properties.DiscountArt, self.brush_stroke_path)
        UiImageBus.Event.SetColor(self.Properties.DiscountArt, self.UIStyle.COLOR_RED_DARK)
      else
        UiImageBus.Event.SetSpritePathname(self.Properties.DiscountArt, self.red_tag_path)
        UiImageBus.Event.SetColor(self.Properties.DiscountArt, self.UIStyle.COLOR_WHITE)
      end
    end
    if self.offer then
      if self.singleReward then
        UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountArt, Vector2(26, 78))
        UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountText, Vector2(42, -4))
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.DiscountArt, 168)
      else
        UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountArt, Vector2(42, 88))
        UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountText, Vector2(8, 0))
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.DiscountArt, 500)
      end
    elseif self.popup then
      local offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.DiscountText)
      if self.singleReward then
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.DiscountArt, 144)
        if self.Properties.DiscountArt:IsValid() then
          UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountArt, Vector2(88, 2))
        end
        UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.DiscountText, self.UIStyle.TEXT_HALIGN_CENTER)
        offsets.left = -4
        UiTransform2dBus.Event.SetOffsets(self.Properties.DiscountText, offsets)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.DiscountText, -4)
      else
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.DiscountArt, 558)
        if self.Properties.DiscountArt:IsValid() then
          UiTransformBus.Event.SetLocalPosition(self.Properties.DiscountArt, Vector2(0, -4))
        end
        offsets.left = 8
        UiTransform2dBus.Event.SetOffsets(self.Properties.DiscountText, offsets)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.DiscountText, 0)
        UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.DiscountText, self.UIStyle.TEXT_HALIGN_LEFT)
      end
    end
  else
    if self.Properties.DiscountArt:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.DiscountArt, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.DiscountText, false)
    end
    if self.Properties.TimeIcon:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.TimeIcon, false)
    end
    if self.Properties.TimeLabel:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.TimeLabel, false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.InitialPrice, false)
  end
  local final = ""
  local original = ""
  if self.displayType == "Popup" then
    if final == original then
      UiTransformBus.Event.SetLocalPositionY(self.Properties.IndividualItemTitle, 40)
    else
      UiTransformBus.Event.SetLocalPositionY(self.Properties.IndividualItemTitle, 28)
    end
  end
  local currencyIconWidth = self.currencyInitialIconWidth
  if currencyCode then
    final = GetLocalizedRealWorldCurrency(finalPrice, currencyCode)
    original = GetLocalizedRealWorldCurrency(originalPrice, currencyCode)
    currencyIconWidth = 0
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.CurrencyIcon, 0)
  else
    final = GetLocalizedNumber(finalPrice)
    original = GetLocalizedNumber(originalPrice)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.CurrencyIcon, self.currencyInitialIconWidth)
    currencyIconWidth = self.currencyInitialIconWidth
  end
  if final == original then
    original = ""
  end
  if priceOverrideText then
    original = ""
    final = priceOverrideText
  end
  if final == "0" then
    final = "@ui_free"
    currencyIconWidth = 0
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.CurrencyIcon, 0)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.FinalPrice, final, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.InitialPrice, original, eUiTextSet_SetAsIs)
  if self.displayType == "Offer" or self.displayType == "Featured" or self.displayType == "Portrait" then
    local finalPriceTextWidth = UiTextBus.Event.GetTextSize(self.Properties.FinalPrice).x
    local initialPriceTextWidth = UiTextBus.Event.GetTextSize(self.Properties.InitialPrice).x
    local spacing = 10
    local totalWidth = currencyIconWidth + finalPriceTextWidth + initialPriceTextWidth + spacing - 2
    UiTransformBus.Event.SetLocalPositionX(self.Properties.CurrencyIcon, totalWidth / 2)
  end
end
function StoreProductElement:SetStoreProductData(storeProductData, displayType)
  if not storeProductData then
    return
  end
  self.displayType = displayType
  self.showSpecialDiscountTag = false
  self.featured = false
  self.escapeMenu = false
  self.offer = false
  self.popup = false
  self.list = false
  local width = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Icon)
  local height = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Icon)
  local imageProperty = "landscapeImage"
  if width == height then
    if width <= 70 then
      imageProperty = "thumbnailImage"
    else
      imageProperty = "squareImage"
    end
  else
    imageProperty = height >= width * 1.4 and "portraitImage" or "landscapeImage"
  end
  self.storeProductData = storeProductData
  local rewards = EntitlementsDataHandler:GetRewardsForOffer(storeProductData.offer)
  local productType = EntitlementsDataHandler:GetProductTypeText(rewards)
  local productTypeIcon = EntitlementsDataHandler:GetProductTypeIcon(rewards)
  local productTypeTooltip = EntitlementsDataHandler:GetProductTypeTooltipText(rewards)
  self.singleReward = false
  if #rewards == 1 then
    self.singleReward = true
  else
    self.singleReward = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.BonusAmount, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.BonusArt, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.BonusPctText, false)
  if displayType == "Featured" then
    self.featured = true
    self.escapeMenu = false
    self.offer = false
    self.popup = false
    self.list = false
    local entityWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
    local entityHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
    local largeRectangleLayout = entityWidth == self.largeFeaturedItemWidth and entityHeight == self.largeFeaturedItemHeight
    local mediumRectangleLayout = entityWidth == self.mediumFeaturedItemWidth and entityHeight == self.smallFeaturedItemHeight
    local mediumSquareLayout = entityWidth == self.mediumFeaturedItemWidth and entityHeight == self.largeFeaturedItemHeight
    local smallSquareLayout = entityWidth == self.smallFeaturedItemWidth and entityHeight == self.smallFeaturedItemHeight
    if self.Properties.Mask:IsValid() then
      UiTransform2dBus.Event.SetAnchorsScript(self.Properties.Mask, UiAnchors(0.5, 0, 0.5, 0))
      UiTransformBus.Event.SetPivot(self.Properties.Mask, Vector2(0.5, 0))
    end
    if largeRectangleLayout then
      imageProperty = "landscapeImage"
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, self.largeFeaturedItemWidth)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, self.largeFeaturedItemHeight)
      if self.Properties.Mask:IsValid() then
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.Mask, self.largeFeaturedItemWidth)
        UiTransform2dBus.Event.SetLocalHeight(self.Properties.Mask, self.largeFeaturedItemHeight)
        UiImageBus.Event.SetSpritePathname(self.Properties.Mask, self.mask_rectangle)
      end
    elseif mediumRectangleLayout then
      imageProperty = "landscapeImage"
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, self.mediumFeaturedItemWidth)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, self.smallFeaturedItemHeight)
      if self.Properties.Mask:IsValid() then
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.Mask, self.mediumFeaturedItemWidth)
        UiTransform2dBus.Event.SetLocalHeight(self.Properties.Mask, self.smallFeaturedItemHeight)
        UiImageBus.Event.SetSpritePathname(self.Properties.Mask, self.mask_rectangle)
      end
    elseif mediumSquareLayout then
      imageProperty = "squareImage"
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, self.mediumFeaturedItemWidth)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, self.mediumFeaturedItemWidth)
      if self.Properties.Mask:IsValid() then
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.Mask, self.mediumFeaturedItemWidth)
        UiTransform2dBus.Event.SetLocalHeight(self.Properties.Mask, self.mediumFeaturedItemWidth)
        UiImageBus.Event.SetSpritePathname(self.Properties.Mask, self.mask_square)
      end
    elseif smallSquareLayout then
      imageProperty = "squareImage"
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.Icon, self.smallFeaturedItemWidth)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.Icon, self.smallFeaturedItemWidth)
      if self.Properties.Mask:IsValid() then
        UiTransform2dBus.Event.SetLocalWidth(self.Properties.Mask, self.smallFeaturedItemWidth)
        UiTransform2dBus.Event.SetLocalHeight(self.Properties.Mask, self.smallFeaturedItemWidth)
        UiImageBus.Event.SetSpritePathname(self.Properties.Mask, self.mask_square)
      end
    end
  elseif displayType == "Offer" then
    if self.Properties.Mask:IsValid() then
      UiTransform2dBus.Event.SetAnchorsScript(self.Properties.Mask, UiAnchors(0, 0, 1, 1))
      UiTransformBus.Event.SetPivot(self.Properties.Mask, Vector2(0.5, 0.5))
    end
    self.featured = false
    self.escapeMenu = false
    self.offer = true
    self.popup = false
    self.list = false
    local bgHeight = 106
    UiElementBus.Event.SetIsEnabled(self.Properties.Icon, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.Bg, self.itemBackground_default)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTitle, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardInfo, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.Line, true)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemDescription, 12)
    if self.Properties.IndividualItemTitle:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.IndividualItemTitle, false)
    end
    if self.Properties.IndividualRewardInfo:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.IndividualRewardInfo, false)
    end
    if #rewards == 1 then
      bgHeight = 108
      UiElementBus.Event.SetIsEnabled(self.Properties.Icon, false)
      UiImageBus.Event.SetSpritePathname(self.Properties.Bg, self.itemBackground_individualItem_offerPage)
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemTitle, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.RewardInfo, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.IndividualItemTitle, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.IndividualRewardInfo, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.Line, false)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemDescription, 34)
    elseif 1 < #rewards and #rewards < 6 then
      bgHeight = 296
    elseif 5 < #rewards and #rewards < 11 then
      bgHeight = 378
    elseif 10 < #rewards then
      bgHeight = 460
    end
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Bg, bgHeight)
    if self.Properties.TimeLabel:IsValid() then
      local labelTextWidth = UiTextBus.Event.GetTextSize(self.Properties.TimeLabel).x
      local timeTextWidth = UiTextBus.Event.GetTextSize(self.Properties.TimeInfo).x
      local spacing = 6
      local iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.TimeIcon)
      local totalWidth = labelTextWidth + timeTextWidth + iconWidth + spacing - 2
      local newPos = totalWidth / 2
      UiTransformBus.Event.SetLocalPositionX(self.Properties.TimeLabel, -newPos)
    end
  elseif displayType == "Popup" then
    if self.Properties.Mask:IsValid() then
      UiTransform2dBus.Event.SetAnchorsScript(self.Properties.Mask, UiAnchors(0, 0, 1, 1))
      UiTransformBus.Event.SetPivot(self.Properties.Mask, Vector2(0.5, 0.5))
    end
    self.featured = false
    self.escapeMenu = false
    self.offer = false
    self.popup = true
    self.list = false
    UiElementBus.Event.SetIsEnabled(self.Properties.Line, false)
    if #rewards == 1 then
      UiElementBus.Event.SetIsEnabled(self.Properties.Icon, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.Bg, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.IndividualItemTitle, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.IndividualRewardInfo, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemTitle, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.RewardInfo, false)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.Icon, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.Bg, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.IndividualItemTitle, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.IndividualRewardInfo, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemTitle, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.RewardInfo, true)
    end
  elseif displayType == "Portrait" then
    if self.Properties.Mask:IsValid() then
      UiTransform2dBus.Event.SetAnchorsScript(self.Properties.Mask, UiAnchors(0, 0, 1, 1))
      UiTransformBus.Event.SetPivot(self.Properties.Mask, Vector2(0.5, 0.5))
    end
    self.showSpecialDiscountTag = true
    self.featured = false
    self.escapeMenu = false
    self.offer = false
    self.popup = false
    self.list = false
    if #rewards == 1 then
      local amount = rewards[1].amount
      local bonusAmount = rewards[1].bonusAmount or 0
      local totalAmount = GetLocalizedNumber(amount - bonusAmount)
      UiTextBus.Event.SetTextWithFlags(self.Properties.RewardAmount, totalAmount, eUiTextSet_SetAsIs)
      if self.Properties.BonusAmount:IsValid() then
        if 0 < bonusAmount then
          UiElementBus.Event.SetIsEnabled(self.Properties.BonusAmount, true)
          UiElementBus.Event.SetIsEnabled(self.Properties.BonusArt, true)
          UiElementBus.Event.SetIsEnabled(self.Properties.BonusPctText, true)
          local bonus = GetLocalizedNumber(bonusAmount)
          UiTextBus.Event.SetTextWithFlags(self.Properties.BonusAmount, GetLocalizedReplacementText("@ui_bonus_marks", {bonus = bonus}), eUiTextSet_SetAsIs)
          local pct = math.floor(100 * bonusAmount / (amount - bonusAmount))
          UiTextBus.Event.SetTextWithFlags(self.Properties.BonusPctText, GetLocalizedReplacementText("@ui_bonus_percent", {bonusPct = pct}), eUiTextSet_SetAsIs)
        else
          UiElementBus.Event.SetIsEnabled(self.Properties.BonusAmount, false)
          UiElementBus.Event.SetIsEnabled(self.Properties.BonusArt, false)
          UiElementBus.Event.SetIsEnabled(self.Properties.BonusPctText, false)
        end
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.RewardAmount, true)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.RewardAmount, false)
    end
  elseif displayType == "Celebration" then
    self.featured = false
    self.escapeMenu = false
    self.offer = false
    self.popup = false
    self.list = false
    UiElementBus.Event.SetIsEnabled(self.Properties.Line, false)
    if #rewards == 1 then
      UiElementBus.Event.SetIsEnabled(self.Properties.Bg, false)
      if self.Properties.Mask:IsValid() then
        UiImageBus.Event.SetSpritePathname(self.Properties.Mask, "")
      end
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.Bg, true)
      if self.Properties.Mask:IsValid() then
        UiImageBus.Event.SetSpritePathname(self.Properties.Mask, self.mask_rectangle)
      end
    end
  elseif displayType == "EscapeMenu" then
    self.featured = false
    self.escapeMenu = true
    self.offer = false
    self.popup = false
    self.list = false
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardInfo, false)
  else
    self.featured = false
    self.escapeMenu = false
    self.offer = false
    self.popup = false
    self.list = true
  end
  if storeProductData.offer.productData[imageProperty] and storeProductData.offer.productData[imageProperty] ~= "" then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, storeProductData.offer.productData[imageProperty])
  else
    local defaultImage = height >= width * 1.4 and self.defaultPortraitIconImagePath or self.defaultIconImagePath
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, defaultImage)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTitle, storeProductData.offer.productData.displayName, eUiTextSet_SetLocalized)
  self.productTypeDisplayText = productType
  local productTypeDisplayIcon = productTypeIcon
  local productTypeDisplayTooltip = productTypeTooltip
  if 1 < #rewards then
    self.productTypeDisplayText = "@ui_bundle"
    productTypeDisplayIcon = "lyshineui/images/mtx/reward_type_bundle.dds"
    productTypeDisplayTooltip = "@ui_bundle_tooltip"
    if self.Properties.HowToContainer:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.HowToContainer, false)
    end
  elseif self.Properties.HowToContainer:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.HowToContainer, true)
  end
  if self.Properties.HowToText:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.HowToText, productTypeDisplayTooltip, eUiTextSet_SetLocalized)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.RewardInfo, self.productTypeDisplayText, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.RewardInfoIcon, productTypeDisplayIcon)
  local showPrice = false
  if storeProductData.showPrice then
    if self.displayType == "Offer" and self.productTypeDisplayText == "@reward_type_service" then
      showPrice = false
    else
      showPrice = true
    end
  else
    showPrice = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.CurrencyIcon, showPrice)
  self.isFictional = storeProductData.offer.isFictional
  self:UpdatePrice(storeProductData)
  if storeProductData.offer.discountExpirationValid and storeProductData.offer.productExpirationValid then
    if storeProductData.offer.discountExpiration < storeProductData.offer.productExpiration then
      self:UpdateDiscountExpiration()
    else
      self:UpdateExpiration()
    end
  elseif storeProductData.offer.discountExpirationValid then
    self:UpdateDiscountExpiration()
  elseif storeProductData.offer.productExpirationValid then
    self:UpdateExpiration()
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeInfo, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TimeLabel, false)
  end
  if self.Properties.IndividualRewardInfo:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.IndividualRewardInfo, self.productTypeDisplayText, eUiTextSet_SetLocalized)
  end
  if self.Properties.IndividualItemTitle:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.IndividualItemTitle, storeProductData.offer.productData.displayName, eUiTextSet_SetLocalized)
  end
  if self.Properties.ItemDescription:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.ItemDescription, storeProductData.offer.productData.description, eUiTextSet_SetLocalized)
  end
  if self.Properties.UnlockedText:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.UnlockedText, not storeProductData.showPrice)
  end
end
function StoreProductElement:SetTooltip(value)
  if value == nil or value == "" then
    self.usingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.ButtonTooltipSetter.entityId, false)
  else
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    self.usingTooltip = true
    UiElementBus.Event.SetIsEnabled(self.ButtonTooltipSetter.entityId, true)
  end
end
function StoreProductElement:StyleFeaturedElementByType(width, displayType)
  local offsets = UiTransform2dBus.Event.GetOffsets(self.Properties.RewardInfo)
  local lineOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.Line)
  UiTextBus.Event.SetColor(self.Properties.TimeInfo, self.UIStyle.COLOR_WHITE)
  self.displayType = displayType
  if displayType == "Offer" then
    SetTextStyle(self.Properties.ItemTitle, self.UIStyle.FONT_STYLE_STORE_OFFER_ITEM_TITLE)
    SetTextStyle(self.Properties.RewardInfo, self.UIStyle.FONT_STYLE_STORE_OFFER_REWARD_INFO)
    SetTextStyle(self.Properties.FinalPrice, self.UIStyle.FONT_STYLE_STORE_FINAL_PRICE_FEATURED)
    UiTextBus.Event.SetFontSize(self.Properties.DiscountText, 28)
    UiTextBus.Event.SetColor(self.Properties.TimeInfo, self.UIStyle.COLOR_YELLOW)
  elseif displayType == "Featured" then
    SetTextStyle(self.Properties.RewardInfo, self.UIStyle.FONT_STYLE_STORE_REWARD_INFO)
    if width == self.largeFeaturedItemWidth then
      SetTextStyle(self.Properties.ItemTitle, self.UIStyle.FONT_STYLE_STORE_ITEM_TITLE_LARGE)
      offsets.left = 40
      offsets.right = -40
      lineOffsets.left = 40
      lineOffsets.right = -40
    elseif width == self.mediumFeaturedItemWidth then
      SetTextStyle(self.Properties.ItemTitle, self.UIStyle.FONT_STYLE_STORE_ITEM_TITLE_MEDIUM)
      offsets.left = 30
      offsets.right = -30
      lineOffsets.left = 30
      lineOffsets.right = -30
    elseif width == self.smallFeaturedItemWidth then
      SetTextStyle(self.Properties.ItemTitle, self.UIStyle.FONT_STYLE_STORE_ITEM_TITLE_SMALL)
      offsets.left = 20
      offsets.right = -20
      lineOffsets.left = 20
      lineOffsets.right = -20
    end
    UiTransform2dBus.Event.SetOffsets(self.Properties.RewardInfo, offsets)
    UiTransform2dBus.Event.SetOffsets(self.Properties.Line, lineOffsets)
    SetTextStyle(self.Properties.FinalPrice, self.UIStyle.FONT_STYLE_STORE_FINAL_PRICE_FEATURED)
    SetTextStyle(self.Properties.InitialPrice, self.UIStyle.FONT_STYLE_STORE_INITIAL_PRICE_FEATURED)
    UiTextBus.Event.SetFontSize(self.Properties.DiscountText, 28)
    UiElementBus.Event.SetIsEnabled(self.Properties.Line, true)
  elseif displayType == "Popup" then
    SetTextStyle(self.Properties.ItemTitle, self.UIStyle.FONT_STYLE_STORE_POPUP_ITEM_TITLE)
    SetTextStyle(self.Properties.RewardInfo, self.UIStyle.FONT_STYLE_STORE_OFFER_REWARD_INFO)
    UiTextBus.Event.SetFontSize(self.Properties.DiscountText, 28)
  elseif displayType == "EscapeMenu" then
    SetTextStyle(self.Properties.ItemTitle, self.UIStyle.FONT_STYLE_STORE_ESCAPE_ITEM_TITLE)
    SetTextStyle(self.Properties.RewardInfo, self.UIStyle.FONT_STYLE_STORE_ESCAPE_REWARD_INFO)
    UiTextBus.Event.SetFontSize(self.Properties.DiscountText, 24)
    SetTextStyle(self.Properties.FinalPrice, self.UIStyle.FONT_STYLE_STORE_ESCAPE_FINAL_PRICE)
    SetTextStyle(self.Properties.InitialPrice, self.UIStyle.FONT_STYLE_STORE_INITIAL_PRICE)
    SetTextStyle(self.Properties.TimeInfo, self.UIStyle.FONT_STYLE_STORE_ESCAPE_TIME_INFO)
    local margin = 20
    local initialPriceTextWidth = UiTextBus.Event.GetTextSize(self.Properties.InitialPrice).x
    local spacing = initialPriceTextWidth == 0 and 0 or 8
    local total = margin + initialPriceTextWidth + spacing
    UiTransformBus.Event.SetLocalPositionX(self.Properties.FinalPrice, total)
  elseif displayType == "Portrait" then
    SetTextStyle(self.Properties.FinalPrice, self.UIStyle.FONT_STYLE_STORE_FINAL_PRICE_PORTRAIT)
    SetTextStyle(self.Properties.ItemTitle, self.UIStyle.FONT_STYLE_STORE_PORTRAIT_ITEM_TITLE)
    SetTextStyle(self.Properties.DiscountText, self.UIStyle.FONT_STYLE_STORE_SPECIAL_DISCOUNT_TEXT)
    UiTextBus.Event.SetFontSize(self.Properties.DiscountText, 32)
  elseif displayType == "Celebration" then
    SetTextStyle(self.Properties.ItemTitle, self.UIStyle.FONT_STYLE_STORE_CELEBRATION_ITEM_TITLE)
    SetTextStyle(self.Properties.RewardInfo, self.UIStyle.FONT_STYLE_STORE_CELEBRATION_ITEM_TYPE)
  end
end
return StoreProductElement
