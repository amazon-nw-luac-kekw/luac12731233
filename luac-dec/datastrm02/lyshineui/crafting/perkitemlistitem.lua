local PerkItemListItem = {
  Properties = {
    ItemLayout = {
      default = EntityId()
    },
    Carried = {
      default = EntityId()
    },
    CarriedText = {
      default = EntityId()
    },
    ItemInfo = {
      default = EntityId()
    },
    ItemName = {
      default = EntityId()
    },
    PerkIcon = {
      default = EntityId()
    },
    NoneIcon = {
      default = EntityId()
    },
    PerkName = {
      default = EntityId()
    },
    PerkDescription = {
      default = EntityId()
    },
    PerkItemFocus = {
      default = EntityId()
    },
    PerkItemSelected = {
      default = EntityId()
    },
    Disabled = {
      default = EntityId()
    },
    Tooltip = {
      default = EntityId()
    }
  },
  setToClear = true,
  slotId = -1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PerkItemListItem)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
function PerkItemListItem:OnInit()
  BaseElement:OnInit(self)
  self.descriptor = ItemDescriptor()
  self:SetItemLayoutOn(false)
end
function PerkItemListItem:SetEnabled(enabled, showQuantity)
  self.enabled = enabled
  UiElementBus.Event.SetIsEnabled(self.Properties.Disabled, not enabled)
  self.ItemLayout:SetQuantityEnabled(showQuantity)
end
function PerkItemListItem:SetItemLayoutOn(enabled)
  self.isItemLayoutOn = enabled
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemLayout, enabled)
  if not enabled then
    self.ScriptedEntityTweener:Set(self.Properties.ItemInfo, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.NoneIcon, {opacity = 1})
  else
    self.ScriptedEntityTweener:Set(self.Properties.ItemInfo, {opacity = 1})
    self.ScriptedEntityTweener:Set(self.Properties.NoneIcon, {opacity = 0})
  end
end
function PerkItemListItem:UpdateQuantity()
  if self.descriptor then
    local enable = self.descriptor.quantity > 0
    self:SetEnabled(enable, enable)
    if enable then
      self.ItemLayout:SetQuantity(self.descriptor.quantity)
    end
  end
end
function PerkItemListItem:SetItem(descriptor)
  self.descriptor = ItemDescriptor()
  self.descriptor.itemId = descriptor.itemId
  self.descriptor.quantity = descriptor.quantity
  if self.descriptor:IsValid() then
    self:SetItemLayoutOn(true)
    self.ItemLayout:SetModeType(self.ItemLayout.MODE_TYPE_CRAFTING_RARITY)
    self.ItemLayout:SetItemByDescriptor(descriptor)
    self:UpdateQuantity()
    UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, self.descriptor:GetDisplayName(), eUiTextSet_SetLocalized)
    local perkId = ItemDataManagerBus.Broadcast.GetDisplayPerkIdFromResource(descriptor.itemId)
    if perkId and perkId ~= 0 then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      local isAttributes = perkData.perkType == ePerkType_Inherent
      if isAttributes then
        local statString = ItemCommon:GetInherentPerkSummary(descriptor.itemId)
        UiTextBus.Event.SetTextWithFlags(self.Properties.PerkName, statString, eUiTextSet_SetLocalized)
        local perkImagePath = "lyshineui/images/icons/misc/icon_attribute_arrow.dds"
        UiImageBus.Event.SetSpritePathname(self.Properties.PerkIcon, perkImagePath)
      else
        UiTextBus.Event.SetTextWithFlags(self.Properties.PerkName, perkData.displayName, eUiTextSet_SetLocalized)
        local perkImagePath = "lyshineui/images/" .. perkData.iconPath .. ".dds"
        UiImageBus.Event.SetSpritePathname(self.Properties.PerkIcon, perkImagePath)
      end
      local staticItemData = StaticItemDataManager:GetItem(descriptor.itemId)
      self.Tooltip:SetSimpleTooltip(staticItemData.description)
    end
  else
    self:SetItemLayoutOn(false)
    self:SetEnabled(true, false)
  end
end
function PerkItemListItem:SetCallback(callback, callingTable)
  self.callbackFunction = callback
  self.callbackTable = callingTable
end
function PerkItemListItem:OnFocus()
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.PerkItemFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.45})
    self.timeline:Add(self.PerkItemFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.PerkItemFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.PerkItemFocus, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.PerkItemFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  if self.isItemLayoutOn then
    self.Tooltip:OnTooltipSetterHoverStart()
  end
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function PerkItemListItem:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.PerkItemFocus, 0.3, {opacity = 0, ease = "QuadOut"})
  self.Tooltip:OnTooltipSetterHoverEnd()
end
function PerkItemListItem:SelectIfItemId(itemId)
  if self.descriptor.itemId == itemId and self.enabled then
    self.ScriptedEntityTweener:Play(self.Properties.PerkItemSelected, 0.3, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.PerkItemFocus, 0.3, {opacity = 0, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.PerkItemSelected, 0.3, {opacity = 0, ease = "QuadOut"})
  end
end
function PerkItemListItem:OnPress(entityId)
  if not self.enabled then
    return
  end
  if self.callbackFunction ~= nil and self.callbackTable ~= nil then
    if type(self.callbackFunction) == "function" then
      self.callbackFunction(self.callbackTable, self.descriptor)
    end
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
return PerkItemListItem
