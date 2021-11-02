local DyeSelectorRow = {
  Properties = {
    PrimarySelector = {
      default = EntityId(),
      order = 1
    },
    SecondarySelector = {
      default = EntityId(),
      order = 2
    },
    AccentSelector = {
      default = EntityId(),
      order = 3
    },
    TintSelector = {
      default = EntityId(),
      order = 4
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(DyeSelectorRow)
function DyeSelectorRow:OnInit()
  BaseElement.OnInit(self)
  self.dyeData = DyeData()
  self.selectorList = {}
  table.insert(self.selectorList, self.PrimarySelector)
  table.insert(self.selectorList, self.SecondarySelector)
  table.insert(self.selectorList, self.AccentSelector)
  table.insert(self.selectorList, self.TintSelector)
  for i = 1, #self.selectorList do
    self.selectorList[i]:SetCallback(self, self.OnColorChanged)
  end
end
function DyeSelectorRow:SetSlot(slotId)
  self.slotId = slotId
end
function DyeSelectorRow:SetCallback(context, callback)
  self.context = context
  self.callback = callback
end
function DyeSelectorRow:SetPicker(picker)
  for i = 1, #self.selectorList do
    self.selectorList[i]:SetPicker(picker)
  end
end
function DyeSelectorRow:OnColorChanged()
  if self.callback and self.slotId then
    self.callback(self.context, self.slotId, self:GetDyeData())
  end
end
function DyeSelectorRow:GetDyeData()
  self.dyeData.rColorId = self.PrimarySelector:GetColor()
  self.dyeData.gColorId = self.SecondarySelector:GetColor()
  self.dyeData.bColorId = self.AccentSelector:GetColor()
  self.dyeData.aColorId = self.TintSelector:GetColor()
  return self.dyeData
end
function DyeSelectorRow:GetColorsUsed()
  local dyesUsed = {}
  for i = 1, #self.selectorList do
    local selector = self.selectorList[i]
    local colorId = selector:GetColor()
    if colorId ~= selector:GetInitialColor() then
      dyesUsed[colorId] = dyesUsed[colorId] and dyesUsed[colorId] + 1 or 1
    end
  end
  return dyesUsed
end
function DyeSelectorRow:SetColors(primary, secondary, accent, tint)
  self.PrimarySelector:SetInitialColor(primary)
  self.SecondarySelector:SetInitialColor(secondary)
  self.AccentSelector:SetInitialColor(accent)
  self.TintSelector:SetInitialColor(tint)
end
function DyeSelectorRow:SetDyeSlotsEnabled(primary, secondary, accent, tint)
  UiElementBus.Event.SetIsEnabled(self.Properties.PrimarySelector, primary)
  UiElementBus.Event.SetIsEnabled(self.Properties.SecondarySelector, secondary)
  UiElementBus.Event.SetIsEnabled(self.Properties.AccentSelector, accent)
  UiElementBus.Event.SetIsEnabled(self.Properties.TintSelector, tint)
end
function DyeSelectorRow:HasChanges()
  for i = 1, #self.selectorList do
    local selector = self.selectorList[i]
    if selector:GetColor() ~= selector:GetInitialColor() then
      return true
    end
  end
  return false
end
function DyeSelectorRow:ClearColors()
  self.dyeData.rColorId = 0
  self.dyeData.gColorId = 0
  self.dyeData.bColorId = 0
  self.dyeData.aColorId = 0
  for i = 1, #self.selectorList do
    self.selectorList[i]:SetInitialColor(0)
  end
end
function DyeSelectorRow:SetIsEnabled(isEnabled)
  UiElementBus.Event.SetIsEnabled(self.entityId, isEnabled)
end
return DyeSelectorRow
