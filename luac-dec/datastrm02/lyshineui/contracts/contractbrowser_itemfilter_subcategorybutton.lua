local ContractBrowser_ItemFilter_SubCategoryButton = {
  Properties = {
    ImageContainer = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    },
    ImageBg = {
      default = EntityId()
    },
    Label = {
      default = EntityId()
    },
    Tier = {
      default = EntityId()
    },
    AvailableSellOrdersLabel = {
      default = EntityId()
    },
    AvailableBuyOrdersLabel = {
      default = EntityId()
    },
    AvailableSellOrdersTooltip = {
      default = EntityId()
    },
    AvailableBuyOrdersTooltip = {
      default = EntityId()
    },
    HoverGlow = {
      default = EntityId()
    },
    Hash = {
      default = EntityId()
    },
    SelectedLine = {
      default = EntityId()
    },
    Detail = {
      default = EntityId()
    }
  },
  buttonHeight = 72,
  squareItemBg = "lyshineui/images/contracts/contracts_squareItemBg.dds",
  circleItemBg = "lyshineui/images/crafting/crafting_itemRarityBg0.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ContractBrowser_ItemFilter_SubCategoryButton)
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function ContractBrowser_ItemFilter_SubCategoryButton:OnInit()
  BaseElement.OnInit(self)
end
function ContractBrowser_ItemFilter_SubCategoryButton:SetVisible(isVisible)
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, isVisible and self.buttonHeight or 0)
end
function ContractBrowser_ItemFilter_SubCategoryButton:SetSubcategoryDisplay(displayInfo)
  self.enabled = displayInfo.enabled
  if displayInfo.displayImage then
    if displayInfo.imagePath ~= nil then
      UiElementBus.Event.SetIsEnabled(self.Properties.ImageContainer, true)
      UiImageBus.Event.SetSpritePathname(self.Properties.Image, displayInfo.imagePath)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.ImageContainer, false)
    end
    if displayInfo.tier ~= nil then
      UiTextBus.Event.SetTextWithFlags(self.Properties.Tier, GetRomanFromNumber(displayInfo.tier), eUiTextSet_SetAsIs)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.Tier, "", eUiTextSet_SetAsIs)
    end
    if displayInfo.isRectangle then
      self.ScriptedEntityTweener:Set(self.Properties.Label, {x = 108, w = 208})
    else
      self.ScriptedEntityTweener:Set(self.Properties.Label, {x = 68, w = 254})
    end
    if displayInfo.itemType == "Resource" or displayInfo.itemType == "HousingItem" then
      UiImageBus.Event.SetSpritePathname(self.Properties.ImageBg, self.circleItemBg)
    elseif displayInfo.itemType == "Ammo" or displayInfo.itemType == "Consumable" then
      UiImageBus.Event.SetSpritePathname(self.Properties.ImageBg, self.squareItemBg)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ImageContainer, false)
    self.ScriptedEntityTweener:Set(self.Properties.Label, {x = 0, w = 300})
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ImageBg, false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Label, displayInfo.text, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.Detail, true)
  UiTextBus.Event.SetText(self.Properties.AvailableSellOrdersLabel, "")
  UiTextBus.Event.SetText(self.Properties.AvailableBuyOrdersLabel, "")
  self.buttonHeight = displayInfo.buttonHeight
  local numOrdersData = displayInfo.numOrdersData
  numOrdersData.contractType = eContractType_Sell
  numOrdersData.outposts = displayInfo.selectedOutposts
  numOrdersData.itemId = displayInfo.itemId
  contractsDataHandler:GetNumItemContracts(self, function(self, sellOrdersText)
    UiTextBus.Event.SetTextWithFlags(self.Properties.AvailableSellOrdersLabel, sellOrdersText, eUiTextSet_SetLocalized)
    if sellOrdersText == "" then
      UiElementBus.Event.SetIsEnabled(self.Properties.AvailableSellOrdersLabel, false)
      self.AvailableSellOrdersTooltip:SetSimpleTooltip(nil)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.AvailableSellOrdersLabel, true)
      local orderTooltip = GetLocalizedReplacementText("@ui_order_tooltip", {number = sellOrdersText})
      self.AvailableSellOrdersTooltip:SetSimpleTooltip(orderTooltip)
    end
  end, nil, numOrdersData)
  numOrdersData.contractType = eContractType_Buy
  contractsDataHandler:GetNumItemContracts(self, function(self, buyOrdersText)
    UiTextBus.Event.SetTextWithFlags(self.Properties.AvailableBuyOrdersLabel, buyOrdersText, eUiTextSet_SetLocalized)
    if buyOrdersText == "" then
      UiElementBus.Event.SetIsEnabled(self.Properties.AvailableBuyOrdersLabel, false)
      self.AvailableBuyOrdersTooltip:SetSimpleTooltip(nil)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.AvailableSellOrdersLabel, true)
      local orderTooltip = GetLocalizedReplacementText("@ui_order_tooltip", {number = buyOrdersText})
      self.AvailableBuyOrdersTooltip:SetSimpleTooltip(orderTooltip)
    end
  end, nil, numOrdersData)
  if displayInfo.textStyle then
    SetTextStyle(self.Properties.Label, displayInfo.textStyle)
  end
  self.itemId = displayInfo.itemId
  self.callbackInfo = {
    filterId = displayInfo.filterId,
    callbackFn = displayInfo.callbackFn,
    callbackSelf = displayInfo.callbackSelf
  }
end
function ContractBrowser_ItemFilter_SubCategoryButton:SetLabelPositionToDefault()
  self.ScriptedEntityTweener:Set(self.Properties.Label, {x = 0, w = 300})
end
function ContractBrowser_ItemFilter_SubCategoryButton:OnSelected(entityId)
  if not self.enabled then
    return
  end
  if self.callbackInfo then
    self.callbackInfo.callbackFn(self.callbackInfo.callbackSelf, self.callbackInfo.filterId)
  end
end
function ContractBrowser_ItemFilter_SubCategoryButton:OnFocus()
  if not self.enabled then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.HoverGlow, true)
  UiElementBus.Event.SetIsEnabled(self.SelectedLine, true)
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.HoverGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.7})
    self.timeline:Add(self.HoverGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.HoverGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.HoverGlow, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.HoverGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  UiElementBus.Event.SetIsEnabled(self.Hash, true)
  self.ScriptedEntityTweener:Play(self.Hash, 0.1, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Label, 0.1, {
    textColor = self.UIStyle.COLOR_TAN
  }, {
    textColor = self.UIStyle.COLOR_WHITE,
    ease = "QuadOut"
  })
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Tab_Hover)
end
function ContractBrowser_ItemFilter_SubCategoryButton:OnUnfocus()
  if not self.enabled then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.SelectedLine, false)
  self.ScriptedEntityTweener:Play(self.HoverGlow, 0.2, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Hash, 0.05, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Label, 0.05, {
    textColor = self.UIStyle.COLOR_WHITE
  }, {
    textColor = self.UIStyle.COLOR_TAN,
    ease = "QuadOut"
  })
end
function ContractBrowser_ItemFilter_SubCategoryButton:OnPress()
  if not self.enabled then
    return
  end
  self.audioHelper:PlaySound(self.audioHelper.Contracts_ListItem_Select)
end
function ContractBrowser_ItemFilter_SubCategoryButton:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return ContractBrowser_ItemFilter_SubCategoryButton
