local RequiredResource = {
  Properties = {
    ItemLayout = {
      default = EntityId()
    },
    TextName = {
      default = EntityId()
    },
    TextRequiredCount = {
      default = EntityId()
    },
    TextCurrentCount = {
      default = EntityId()
    },
    CurrentCountRequirementsMetColor = {
      default = Color(1, 1, 1, 1)
    },
    CurrentCountRequirementsNotMetColor = {
      default = Color(1, 1, 1, 1)
    },
    ShowRequiredCountOnIcon = {
      default = false,
      description = "If true, ItemLayout shows the required count.  If false, it shows the player's current count"
    }
  },
  mCurrentCount = 0,
  mRequiredCount = 0,
  mItemDescriptor = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RequiredResource)
function RequiredResource:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    self.inventoryId = data
  end)
  if type(self.ItemLayout) == "table" then
    self.ItemLayout:ConnectContainerBus(self.ItemLayout.entityId)
    self.ItemLayout:SetTooltipEnabled(true)
    self.ItemLayout:SetModeType(self.ItemLayout.MODE_TYPE_CRAFTING)
  end
end
function RequiredResource:SetData(itemDescriptor)
  self.mItemDescriptor = itemDescriptor
  if self.TextName:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.TextName, self.mItemDescriptor:GetDisplayName(), eUiTextSet_SetLocalized)
  end
  self:SetRequiredCount(self.mItemDescriptor.quantity)
  self:UpdateCurrentCount()
end
function RequiredResource:UpdateCurrentCount()
  if self.mItemDescriptor == nil then
    return
  end
  local itemCount = ContainerRequestBus.Event.GetItemCount(self.inventoryId, self.mItemDescriptor, true, false, false)
  self:SetCurrentCount(itemCount)
end
function RequiredResource:SetCurrentCount(count)
  self.mCurrentCount = count
  if not self.ShowRequiredCountOnIcon then
    self.mItemDescriptor.quantity = count
    ItemContainerBus.Event.SetItemByName(self.Properties.ItemLayout, self.mItemDescriptor:GetItemKey(), "", self.mItemDescriptor.quantity)
  end
  UiTextBus.Event.SetText(self.Properties.TextCurrentCount, tostring(count))
  self:OnCountChanged()
end
function RequiredResource:SetRequiredCount(count)
  self.mRequiredCount = count
  if self.ShowRequiredCountOnIcon then
    self.mItemDescriptor.quantity = count
    ItemContainerBus.Event.SetItemByName(self.Properties.ItemLayout, self.mItemDescriptor:GetItemKey(), "", self.mItemDescriptor.quantity)
  end
  if self.TextRequiredCount:IsValid() then
    UiTextBus.Event.SetText(self.Properties.TextRequiredCount, tostring("/ " .. count))
  end
  self:OnCountChanged()
end
function RequiredResource:OnCountChanged()
  if self.TextCurrentCount:IsValid() then
    if self.mCurrentCount < self.mRequiredCount then
      UiTextBus.Event.SetColor(self.Properties.TextCurrentCount, self.CurrentCountRequirementsNotMetColor)
    else
      UiTextBus.Event.SetColor(self.Properties.TextCurrentCount, self.CurrentCountRequirementsMetColor)
    end
  end
end
function RequiredResource:GetCurrentCount()
  return self.mCurrentCount
end
function RequiredResource:GetRequiredCount()
  return self.mRequiredCount
end
function RequiredResource:OnShutdown()
end
return RequiredResource
