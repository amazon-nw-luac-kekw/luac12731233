local TabbedList = {
  Properties = {
    Mask = {
      default = EntityId()
    },
    TabbedListRadioGroup = {
      default = EntityId()
    },
    VerticalListButtonClone = {
      default = EntityId()
    },
    VerticalListBg = {
      default = EntityId()
    },
    VerticalListSelectedGlowHolder = {
      default = EntityId()
    },
    VerticalListSelectedGlowMask = {
      default = EntityId()
    },
    VerticalListSelectedGlow = {
      default = EntityId()
    },
    HorizonalListButtonClone = {
      default = EntityId()
    },
    IsHorizontal = {default = false},
    EnableVerticalGlowHolder = {default = true},
    EnableBg = {default = true}
  },
  width = 0,
  height = 0,
  listItems = {},
  verticalSelectedGlowOffsetPosY = -213,
  verticalListOffsetPosY = 10,
  horizontalListOffetPosY = 180,
  horizontalListMaskOffsetTop = -200,
  horizontalListMaskOffsetBottom = 300,
  horizontalListOffetPosX = -3
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TabbedList)
function TabbedList:OnInit()
  BaseElement.OnInit(self)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.VerticalListBg, self.width)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  UiElementBus.Event.SetIsEnabled(self.Properties.VerticalListSelectedGlowHolder, self.Properties.EnableVerticalGlowHolder)
  UiElementBus.Event.SetIsEnabled(self.Properties.VerticalListBg, self.Properties.EnableBg)
  if self.Properties.IsHorizontal then
    UiTransform2dBus.Event.SetOffsets(self.Properties.Mask, UiOffsets(0, self.horizontalListMaskOffsetTop, 600, self.horizontalListMaskOffsetBottom))
    UiTransformBus.Event.SetLocalPosition(self.Properties.TabbedListRadioGroup, Vector2(self.horizontalListOffetPosX, self.horizontalListOffetPosY))
    UiElementBus.Event.SetIsEnabled(self.Properties.VerticalListBg, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.VerticalListSelectedGlowHolder, false)
  end
end
function TabbedList:SetListData(listItems, callbackTable)
  local contentHeight = 0
  for i = 1, #listItems do
    local data = listItems[i]
    data.itemIndex = i
    local buttonToClone = self.Properties.IsHorizontal and self.Properties.HorizonalListButtonClone or self.Properties.VerticalListButtonClone
    local currentButton = CloneUiElement(self.canvasId, self.registrar, buttonToClone, self.Properties.TabbedListRadioGroup, true)
    UiRadioButtonGroupBus.Event.AddRadioButton(self.Properties.TabbedListRadioGroup, currentButton.entityId)
    if data.style then
      currentButton:SetButtonStyle(data.style)
    end
    if data.width then
      currentButton:SetWidth(data.width)
    end
    if data.height then
      currentButton:SetHeight(data.height)
    end
    if self.Properties.IsHorizontal then
      local buttonWidth = currentButton:GetWidth()
      local buttonSpacing = 0
      local currentButtonPosX = (buttonWidth + buttonSpacing) * (data.itemIndex - 1)
      UiTransformBus.Event.SetLocalPositionX(currentButton.entityId, currentButtonPosX)
      self.horizontalButtonHeight = currentButton:GetHeight()
      if data.itemIndex == #listItems then
        currentButton:SetLastIndex(true)
      end
    else
      local buttonHeight = currentButton:GetHeight()
      local buttonSpacing = 0
      contentHeight = self.verticalListOffsetPosY + #listItems * (buttonHeight + buttonSpacing)
      local currentButtonPosY = self.verticalListOffsetPosY + (buttonHeight + buttonSpacing) * (data.itemIndex - 1)
      UiTransformBus.Event.SetLocalPositionY(currentButton.entityId, currentButtonPosY)
      currentButton:SetWidth(self.width)
      currentButton:SetSelectedCallback(self.SetSelectedGlow, self)
      local below = math.max(self.height, contentHeight) - (currentButtonPosY + currentButton:GetHeight())
      currentButton:SetLowerBound(below)
    end
    currentButton:SetIndex(data.itemIndex)
    if data.text then
      currentButton:SetText(data.text)
    end
    if data.secondaryText then
      currentButton:SetSecondaryText(data.secondaryText)
    end
    if data.tooltipText then
      currentButton:SetTooltip(data.tooltipText)
    end
    if data.iconPath then
      currentButton:SetIconPath(data.iconPath)
    end
    if data.iconValue then
      currentButton:SetIconValue(data.iconValue)
    end
    if data.glowOffsetWidth then
      currentButton:SetGlowOffsetWidth(data.glowOffsetWidth)
    end
    if data.callback then
      currentButton:SetCallback(data.callback, callbackTable)
    end
    self.listItems[data.itemIndex] = currentButton
  end
  if not self.Properties.IsHorizontal then
    local bottomPadding = 10
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.TabbedListRadioGroup, contentHeight + bottomPadding)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.VerticalListSelectedGlowHolder, math.max(contentHeight, self.height))
  else
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.TabbedListRadioGroup, self.horizontalButtonHeight)
  end
end
function TabbedList:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function TabbedList:SetWidth(width)
  self.width = width
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.VerticalListBg, self.width)
end
function TabbedList:GetWidth()
  return self.width
end
function TabbedList:SetHeight(height)
  self.height = height
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function TabbedList:GetHeight()
  return self.height
end
function TabbedList:GetIndex(index)
  return self.listItems[index]
end
function TabbedList:SetSelected(index, visualOnly)
  local selectedButton = self.listItems[index]
  if selectedButton then
    UiRadioButtonGroupBus.Event.SetState(self.Properties.TabbedListRadioGroup, selectedButton.entityId, true)
    selectedButton:OnSelect(visualOnly)
  end
end
function TabbedList:SetUnselected()
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.TabbedListRadioGroup)
  local entityTable = self.registrar:GetEntityTable(selectedItem)
  UiRadioButtonGroupBus.Event.SetState(self.Properties.TabbedListRadioGroup, selectedItem, false)
  if entityTable then
    entityTable:OnUnselected()
  end
end
function TabbedList:GetSelected()
  local selectedItem = UiRadioButtonGroupBus.Event.GetState(self.Properties.TabbedListRadioGroup)
  local entityTable = self.registrar:GetEntityTable(selectedItem)
  return entityTable
end
function TabbedList:SetSelectedGlow(entityId)
  local selectedIndex = entityId:GetIndex()
  local buttonWidth = entityId:GetWidth()
  local buttonHeight = entityId:GetHeight()
  local positionX = buttonWidth
  local positionY = buttonHeight * selectedIndex + self.verticalSelectedGlowOffsetPosY
  self.ScriptedEntityTweener:Set(self.Properties.VerticalListSelectedGlowHolder, {x = positionX})
  self.ScriptedEntityTweener:Play(self.Properties.VerticalListSelectedGlowMask, 0.3, {y = positionY, ease = "QuadOut"})
end
return TabbedList
