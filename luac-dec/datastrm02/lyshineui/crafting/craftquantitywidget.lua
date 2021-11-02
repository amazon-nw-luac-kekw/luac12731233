local CraftQuantityWidget = {
  Properties = {
    MinusButton = {
      default = EntityId()
    },
    PlusButton = {
      default = EntityId()
    },
    Minimum = {
      default = EntityId()
    },
    Maximum = {
      default = EntityId()
    },
    Slider = {
      default = EntityId()
    }
  },
  recipeData = nil,
  curValue = 0,
  maxValue = 0,
  recipePanel = nil,
  minimumQuantityToCraft = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CraftQuantityWidget)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function CraftQuantityWidget:OnInit()
  self.PlusButton:SetText("")
  self.PlusButton:SetCallback("IncrementSlider", self)
  self.PlusButton:SetIconPath("lyshineui/images/icons/crafting/icon_crafting_plus.png")
  self.PlusButton:SetIconPositionX(1)
  self.PlusButton:SetSoundOnPress(self.audioHelper.Crafting_Increment)
  self.MinusButton:SetText("")
  self.MinusButton:SetCallback("DecrementSlider", self)
  self.MinusButton:SetIconPath("lyshineui/images/icons/crafting/icon_crafting_minus.png")
  self.MinusButton:SetIconPositionX(1)
  self.MinusButton:SetSoundOnPress(self.audioHelper.Crafting_Increment)
  self.Slider.Slider:SetCallback("SliderChanged", self)
  self.Slider.Slider:SetSliderReleasedCallback(self.SliderReleased, self)
  self.Slider.Slider.Properties.snapToIntegers = true
  self.Slider:SetSliderStyle(self.Slider.SLIDER_STYLE_2)
  self.Slider:SetSliderTextVisible(false)
end
function CraftQuantityWidget:SliderReleased()
end
function CraftQuantityWidget:SetRecipeTable(table)
  self.recipePanel = table
end
function CraftQuantityWidget:IncrementSlider()
  local value = tonumber(self.Slider.Slider:GetValue())
  local newValue = value + 1
  if newValue <= self.maxValue then
    self.Slider:SetSliderValue(newValue)
  end
end
function CraftQuantityWidget:DecrementSlider()
  local value = tonumber(self.Slider.Slider:GetValue())
  local newValue = value - 1
  local minValue = self.Slider.Slider:GetMinValue()
  if newValue >= minValue then
    self.Slider:SetSliderValue(newValue)
  end
end
function CraftQuantityWidget:SetSliderValue(newValue)
  local minValue = self.Slider.Slider:GetMinValue()
  if newValue >= minValue and newValue <= self.maxValue then
    self.Slider:SetSliderValue(newValue)
  end
end
function CraftQuantityWidget:SliderChanged(slider)
  local value = tonumber(slider:GetValue())
  if value < self.minimumQuantityToCraft then
    slider:SetSliderValue(self.minimumQuantityToCraft)
  end
  if value > self.maxValue then
    value = self.maxValue
  end
  self.recipePanel:SetCraftQuantity(value)
  if value >= self.maxValue then
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PlusButton, false)
    self.ScriptedEntityTweener:Play(self.Properties.PlusButton, 0, {opacity = 0.5})
  else
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PlusButton, true)
    self.ScriptedEntityTweener:Play(self.Properties.PlusButton, 0, {opacity = 1})
  end
  if value <= self.minimumQuantityToCraft then
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.MinusButton, false)
    self.ScriptedEntityTweener:Play(self.Properties.MinusButton, 0, {opacity = 0.5})
  else
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.MinusButton, true)
    self.ScriptedEntityTweener:Play(self.Properties.MinusButton, 0, {opacity = 1})
  end
end
function CraftQuantityWidget:SetData(data)
  self.recipeData = data
  self:UpdateQuantities()
end
function CraftQuantityWidget:IsVisible()
  return self.isVisible
end
function CraftQuantityWidget:UpdateQuantities()
  if not self.recipeData then
    return
  end
  self.maxValue = 0
  local maxQuantity = self.recipePanel:GetMaxQuantity()
  if 0 < maxQuantity then
    self.Slider:SetSliderMaxValue(maxQuantity)
    self.maxValue = maxQuantity
    self.Slider:SetSliderMinValue(self.minimumQuantityToCraft)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Maximum, tostring(maxQuantity), eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Minimum, tostring(self.minimumQuantityToCraft), eUiTextSet_SetAsIs)
    self.Slider:SetSliderValue(1)
    self.recipePanel:SetCraftQuantity(1)
    self.isVisible = 1 < maxQuantity
  else
    self.recipePanel:SetCraftQuantity(0)
    self.isVisible = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Slider, self.isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.PlusButton, self.isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.MinusButton, self.isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Maximum, self.isVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Minimum, self.isVisible)
end
return CraftQuantityWidget
