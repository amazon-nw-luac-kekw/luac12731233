local DyeColor = {
  Properties = {
    Color = {
      default = EntityId()
    },
    Decoration = {
      default = EntityId()
    },
    Count = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    IsNewIndicator = {
      default = EntityId()
    },
    EntitlementIcon = {
      default = EntityId()
    }
  },
  isHandlingEvents = true,
  index = 0
}
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DyeColor)
function DyeColor:OnInit()
  BaseElement.OnInit(self)
  UiElementBus.Event.SetIsEnabled(self.Properties.Decoration, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Count, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, true)
end
function DyeColor:OnShutdown()
end
function DyeColor:SetCallbacks(context, callback, entitlementTooltipCallback, markSeenCallback)
  self.context = context
  self.callback = callback
  self.entitlementTooltipCallback = entitlementTooltipCallback
  self.markSeenCallback = markSeenCallback
end
function DyeColor:SetHoverCallbacks(context, onHover, onUnhover)
  self.hoverContext = context
  self.onHoverCallback = onHover
  self.onUnhoverCallback = onUnhover
end
function DyeColor:SetColor(index)
  self.index = index
  UiElementBus.Event.SetIsEnabled(self.entityId, self.index > 0)
  if self.index > 0 then
    local color = ItemDataManagerBus.Broadcast.GetDyeColor(self.index)
    UiImageBus.Event.SetColor(self.Properties.Color, color)
  end
end
function DyeColor:SetCount(count)
  self.count = count
  UiTextBus.Event.SetText(self.Properties.Count, tostring(count))
  UiElementBus.Event.SetIsEnabled(self.Properties.Count, true)
end
function DyeColor:SetIsNew(isNew)
  self.isNew = isNew
  UiElementBus.Event.SetIsEnabled(self.Properties.IsNewIndicator, isNew)
  if not self.Properties.IsNewIndicator:IsValid() then
    if self.isNew then
      UiTextBus.Event.SetText(self.Properties.Count, string.format("(*) %s", tostring(self.count)))
    else
      UiTextBus.Event.SetText(self.Properties.Count, tostring(self.count))
    end
  end
end
function DyeColor:SetAvailableProducts(availableProducts, grantInfo)
  self.availableProducts = availableProducts
  if self.availableProducts and #self.availableProducts > 0 then
    if grantInfo then
      UiElementBus.Event.SetIsEnabled(self.Properties.EntitlementIcon, true)
      local sourceType = grantInfo.grantor.sourceType
      local iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      if sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_TWITCH then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_Twitch.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PRIME then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_TwitchPrime.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_PREORDER then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
      elseif sourceType == EntitlementsDataHandler.MTX_SOURCE_TYPE_STORE then
        iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      else
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.EntitlementIcon, iconTexture)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.EntitlementIcon, false)
  end
end
function DyeColor:SetItemId(itemId)
  self.itemId = itemId
end
function DyeColor:OnFocus()
  if self.isHandlingEvents then
    self.ScriptedEntityTweener:PlayC(self.Properties.Highlight, 0.15, tweenerCommon.fadeInQuadOut)
  end
  if self.isNew and self.markSeenCallback then
    self.markSeenCallback(self.context, self)
  end
  if not self.availableProducts or #self.availableProducts == 0 then
    local itemDescriptor = ItemDescriptor()
    itemDescriptor.itemId = self.itemId
    local tdi = StaticItemDataManager:GetTooltipDisplayInfo(itemDescriptor, nil)
    DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(tdi, self, nil, false, true)
  elseif self.entitlementTooltipCallback then
    self.entitlementTooltipCallback(self.context, self)
  end
  if self.hoverContext and self.onHoverCallback then
    self.onHoverCallback(self.hoverContext, self)
  end
end
function DyeColor:OnUnfocus()
  if self.isHandlingEvents then
    self.ScriptedEntityTweener:PlayC(self.Properties.Highlight, 0.15, tweenerCommon.fadeOutQuadOut)
  end
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  if self.hoverContext and self.onUnhoverCallback then
    self.onUnhoverCallback(self.hoverContext, self)
  end
end
function DyeColor:OnPress()
  if self.isHandlingEvents then
    if self.callback then
      self.callback(self.context, self)
    end
    DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  end
end
function DyeColor:SetIsHandlingEvents(isEnabled)
  self.isHandlingEvents = isEnabled
end
return DyeColor
