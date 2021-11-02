local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local RewardGridItem = {
  Properties = {
    Name = {
      default = EntityId()
    },
    RewardAmount = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Unlocked = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    Button = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RewardGridItem)
function RewardGridItem:OnInit()
  BaseElement.OnInit(self)
end
function RewardGridItem:OnShutdown()
end
function RewardGridItem:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function RewardGridItem:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function RewardGridItem:GetHorizontalSpacing()
  return 21
end
function RewardGridItem:SetGridItemData(itemData)
  self.itemData = itemData
  UiElementBus.Event.SetIsEnabled(self.entityId, self.itemData ~= nil)
  if not itemData then
    return
  end
  self.rewardItemData = EntitlementsDataHandler:GetEntitlementDisplayInfo(itemData.rewardInfo.rewardType, itemData.rewardInfo.rewardId)
  if itemData.isSelected then
    self.selected = true
    self.ScriptedEntityTweener:Set(self.Properties.Hover, {opacity = 1})
  else
    self.ScriptedEntityTweener:Set(self.Properties.Hover, {opacity = 0})
    self.selected = false
  end
  if itemData.isSingleReward then
    UiLayoutCellBus.Event.SetTargetWidth(self.entityId, 86)
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, 102)
    UiLayoutCellBus.Event.SetMinHeight(self.entityId, 102)
  else
    UiLayoutCellBus.Event.SetTargetWidth(self.entityId, 68)
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, 86)
    UiLayoutCellBus.Event.SetMinHeight(self.entityId, 86)
  end
  if itemData.rewardInfo.isConsumable then
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardAmount, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.RewardAmount, GetLocalizedNumber(itemData.rewardInfo.amount), eUiTextSet_SetAsIs)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.RewardAmount, false)
  end
  if EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(itemData.rewardInfo.rewardType, itemData.rewardInfo.rewardId) then
    if itemData.rewardInfo.isConsumable then
      UiElementBus.Event.SetIsEnabled(self.Properties.Unlocked, false)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.Unlocked, true)
    end
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Unlocked, false)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Name, self.rewardItemData.itemDescription, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.rewardItemData.spritePath)
  UiImageBus.Event.SetColor(self.Properties.Icon, self.rewardItemData.spriteColor)
end
function RewardGridItem:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ItemDraggable)
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.2, {opacity = 1})
  if type(self.itemData.cbHoverBegin) == "function" and self.itemData.cbContext ~= nil then
    self.itemData.cbHoverBegin(self.itemData.cbContext, self)
  end
end
function RewardGridItem:OnUnfocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  if not self.selected then
    if type(self.unfocusCallback) == "function" and self.unfocusCallbackTable ~= nil then
      self.unfocusCallback(self.unfocusCallbackTable, self)
    end
    self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0})
    if type(self.itemData.cbHoverEnd) == "function" and self.itemData.cbContext ~= nil then
      self.itemData.cbHoverEnd(self.itemData.cbContext, self)
    end
  end
  if self.timeline ~= nil then
    self.timeline:Stop()
  end
end
function RewardGridItem:OnPress()
  if self.itemData.cb then
    self.itemData.cb(self.itemData.cbContext, self)
  end
end
return RewardGridItem
