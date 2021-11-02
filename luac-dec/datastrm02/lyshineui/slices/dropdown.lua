local Dropdown = {
  Properties = {
    DropdownText = {
      default = EntityId()
    },
    DropdownBg = {
      default = EntityId()
    },
    DropdownFrame = {
      default = EntityId()
    },
    DropdownTexture = {
      default = EntityId()
    },
    DropdownFocusGlow = {
      default = EntityId()
    },
    DropdownArrow = {
      default = EntityId()
    },
    DropdownHolder = {
      default = EntityId()
    },
    DropdownHolderMask = {
      default = EntityId()
    },
    DropdownListHolder = {
      default = EntityId()
    },
    DropdownListHolderMask = {
      default = EntityId()
    },
    DropdownListScrollBox = {
      default = EntityId()
    },
    DropdownListScrollBar = {
      default = EntityId()
    },
    DropdownListBg = {
      default = EntityId()
    },
    DropdownSelectedImage = {
      default = EntityId()
    },
    DropdownSpinnerBg = {
      default = EntityId()
    },
    DropdownSpinner = {
      default = EntityId()
    },
    ButtonTooltipSetter = {
      default = EntityId()
    },
    IsCheckboxDropdown = {default = false},
    ListItemPrototype = {
      default = EntityId()
    },
    ListItemSlice = {
      default = "LyShineUI/Slices/DropdownListItem"
    }
  },
  mWidth = 0,
  mHeight = 0,
  mListItemsTotal = 0,
  mListHeight = 250,
  mListHeightRows = nil,
  mListItemSpacing = 3,
  mListInitPosY = -500,
  mPreviousItem = nil,
  mPreviousItemData = nil,
  mSelectedItem = nil,
  mSelectedItemData = nil,
  mFocusedItem = nil,
  mCallback = nil,
  mCallbackTable = nil,
  mOpenCallback = nil,
  mOpenCallbackTable = nil,
  mCloseCallback = nil,
  mCloseCallbackTable = nil,
  mItemFocusCallback = nil,
  mItemFocusCallbackTable = nil,
  mItemsReadyCallback = nil,
  mItemsReadyCallbackTable = nil,
  mIsEnabled = true,
  mIsUsingTooltip = false,
  mCachedPrototypeElement = nil,
  mImageAlignment = 1,
  IMAGE_ALIGNMENT_LEFT = 0,
  IMAGE_ALIGNMENT_RIGHT = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Dropdown)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(Dropdown)
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function Dropdown:OnInit()
  BaseElement.OnInit(self)
  if self.Properties.IsCheckboxDropdown then
    self.Properties.ListItemSlice = "LyShineUI/Slices/CheckboxDropdownListItem"
  end
  self.mListItems = {}
  if not self.DropdownListBg or type(self.DropdownListBg) ~= "table" then
    return
  end
  SetTextStyle(self.Properties.DropdownText, self.UIStyle.FONT_STYLE_DROPDOWN_SELECTED)
  self.ScriptedEntityTweener:Set(self.Properties.DropdownBg, {
    opacity = 1,
    imgColor = self.UIStyle.COLOR_DARKER_ORANGE
  })
  self.ScriptedEntityTweener:Set(self.Properties.DropdownTexture, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.DropdownFocusGlow, {
    opacity = 0,
    imgColor = self.UIStyle.COLOR_BRIGHT_ORANGE
  })
  local frameAlpha = 0.6
  self:SetLineColor(self.UIStyle.COLOR_MEDIUM_ORANGE)
  self.ScriptedEntityTweener:Set(self.Properties.DropdownFrame, {opacity = frameAlpha})
  self.mWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.mHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.DropdownListBg:OnInit()
  self.DropdownListBg:SetFrameTextureVisible(false)
  self:SetListBgAlpha(0.85)
  self:SetDropdownListHeight(self.mListHeight)
  UiElementBus.Event.SetIsEnabled(self.DropdownSelectedImage, false)
  if self.Properties.ListItemPrototype:IsValid() then
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    self.mCachedPrototypeElement = UiCanvasBus.Event.CreateChildElement(canvasId, "Prototypes")
    UiElementBus.Event.SetIsEnabled(self.mCachedPrototypeElement, false)
    self.mListItemsTotal = 1
  end
  self.spawnData = {}
end
function Dropdown:SetDropdownListHeight(height)
  self.mListHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.DropdownHolderMask, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.DropdownHolderMask, self.mListHeight)
  UiTransform2dBus.Event.SetLocalWidth(self.DropdownHolder, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.DropdownHolder, self.mListHeight)
  UiTransform2dBus.Event.SetLocalWidth(self.DropdownListHolderMask, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.DropdownListHolderMask, self.mListHeight)
  UiTransform2dBus.Event.SetLocalHeight(self.DropdownListScrollBox, self.mListHeight)
  self.DropdownListBg:SetSize(self.mWidth - 2, self.mListHeight - 1)
end
function Dropdown:SetDropdownListHeightByRows(numbeOfRows)
  self.mListHeightRows = numbeOfRows
end
function Dropdown:SetDropdownScreenCanvasId(entityId)
  UiDropdownBus.Event.SetExpandedParentId(self.entityId, entityId)
end
function Dropdown:SetCallback(command, table)
  self.mCallback = command
  self.mCallbackTable = table
end
function Dropdown:SetItemFocusCallback(command, table)
  self.mItemFocusCallback = command
  self.mItemFocusCallbackTable = table
end
function Dropdown:SetItemsReadyCallback(command, table)
  self.mItemsReadyCallback = command
  self.mItemsReadyCallbackTable = table
end
function Dropdown:SetOpenCallback(command, table)
  self.mOpenCallback = command
  self.mOpenCallbackTable = table
end
function Dropdown:SetPreOpenCallback(command, table)
  self.preOpenCallback = command
  self.preOpenCallbackTable = table
end
function Dropdown:SetCloseCallback(command, table)
  self.mCloseCallback = command
  self.mCloseCallbackTable = table
end
function Dropdown:SetText(value, skipLocalization)
  if skipLocalization then
    UiTextBus.Event.SetText(self.Properties.DropdownText, value)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.DropdownText, value, eUiTextSet_SetLocalized)
  end
end
function Dropdown:GetText()
  return UiTextBus.Event.GetText(self.DropdownText)
end
function Dropdown:SetRightText(index, text)
  local listItem = self.mListItems[index]
  if listItem then
    listItem:SetTextRight(text)
  end
end
function Dropdown:SetImageAlignment(alignment)
  if self.mImageAlignment ~= alignment then
    if alignment == self.IMAGE_ALIGNMENT_LEFT then
      UiTransform2dBus.Event.SetAnchorsScript(self.Properties.DropdownSelectedImage, UiAnchors(0, 0.5, 0, 0.5))
      UiTransform2dBus.Event.SetOffsets(self.Properties.DropdownText, UiOffsets(48, 2, -50, 2))
    else
      UiTransform2dBus.Event.SetAnchorsScript(self.Properties.DropdownSelectedImage, UiAnchors(1, 0.5, 1, 0.5))
      UiTransform2dBus.Event.SetOffsets(self.Properties.DropdownText, UiOffsets(20, 2, -50, 2))
    end
  end
  self.mImageAlignment = alignment
end
function Dropdown:SetImageSize(value)
  self.ScriptedEntityTweener:Set(self.Properties.DropdownSelectedImage, {w = value, h = value})
end
function Dropdown:SetImagePositionY(value)
  self.ScriptedEntityTweener:Set(self.Properties.DropdownSelectedImage, {y = value})
end
function Dropdown:SetImagePositionX(value)
  self.ScriptedEntityTweener:Set(self.Properties.DropdownSelectedImage, {x = value})
end
function Dropdown:SetCheckboxState(index, isChecked)
  local listItem = self.mListItems[index]
  if listItem then
    listItem:SetState(isChecked)
  end
end
function Dropdown:OnCheckboxChanged(data, isChecked)
  if self.mCallback ~= nil and self.mCallbackTable ~= nil then
    self.mCallback(self.mCallbackTable, data, isChecked)
  end
end
function Dropdown:SetDropdownTooltip(value)
  if value == nil or value == "" then
    self.mIsUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, false)
  else
    self.mIsUsingTooltip = true
    self.ButtonTooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.ButtonTooltipSetter, true)
  end
end
function Dropdown:SetListItemEnabled(index, isEnabled)
  local listItem = self.mListItems[index]
  if listItem then
    listItem:SetEnabled(isEnabled)
  end
end
function Dropdown:SetListItemTooltip(index, value)
  local listItem = self.mListItems[index]
  if listItem then
    listItem:SetTooltip(value)
  end
end
function Dropdown:SetSelectedItemData(itemData)
  if itemData.text ~= nil then
    self:SetText(itemData.text)
    if itemData.textColor then
      self:SetTextColor(itemData.textColor)
    end
    if self.mPreviousItemData == nil then
      self.mPreviousItemData = itemData
    else
      self.mPreviousItemData = self.mSelectedItemData
    end
    if itemData.itemIndex ~= nil then
      self.mSelectedItem = self.mListItems[itemData.itemIndex]
    end
    self.mSelectedItemData = itemData
  end
end
function Dropdown:GetSelectedItem()
  return self.mSelectedItem
end
function Dropdown:GetSelectedItemData()
  return self.mSelectedItemData
end
function Dropdown:GetPreviousSelectedItemData()
  return self.mPreviousItemData == nil and self.mSelectedItemData or self.mPreviousItemData
end
function Dropdown:SetSize(width, height)
  self.mWidth = width
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function Dropdown:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.DropdownText, 0.3, {textColor = color})
  self.textColor = color
end
function Dropdown:SetWidth(width)
  self.mWidth = width
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
end
function Dropdown:SetHeight(height)
  self.mHeight = height
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
end
function Dropdown:GetWidth()
  return self.mWidth
end
function Dropdown:GetHeight()
  return self.mHeight
end
function Dropdown:StartSpinner()
  local fadeDuration = 0.25
  UiElementBus.Event.SetIsEnabled(self.DropdownSpinnerBg, true)
  self.ScriptedEntityTweener:Play(self.DropdownSpinnerBg, fadeDuration, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.DropdownSpinner, 1, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  self:SetEnableDropdownUsage(false)
end
function Dropdown:StopSpinner()
  local fadeDuration = 0.25
  self.ScriptedEntityTweener:Play(self.DropdownSpinnerBg, fadeDuration, {
    opacity = 0,
    ease = "QuadOut",
    onComplete = function()
      self.ScriptedEntityTweener:Stop(self.DropdownSpinner)
      UiElementBus.Event.SetIsEnabled(self.DropdownSpinnerBg, false)
    end
  })
  self:SetEnableDropdownUsage(true)
end
function Dropdown:SetListData(listItems)
  local usingPrototype = self.Properties.ListItemPrototype:IsValid()
  local prototypeList
  if usingPrototype then
    local cachedElements = UiElementBus.Event.GetChildren(self.mCachedPrototypeElement)
    local numToSpawn = #listItems - (self.mListItemsTotal + #cachedElements)
    prototypeList = {
      self.Properties.ListItemPrototype
    }
    if 0 <= numToSpawn then
      local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
      for i = 1, numToSpawn do
        local cloneTable = CloneUiElement(canvasId, self.registrar, self.Properties.ListItemPrototype, self.Properties.DropdownListHolder, true)
        table.insert(prototypeList, cloneTable.entityId)
      end
      local invalidEntityId = EntityId()
      for i = 1, #cachedElements do
        UiElementBus.Event.Reparent(cachedElements[i], self.Properties.DropdownListHolder, invalidEntityId)
        table.insert(prototypeList, cachedElements[i])
      end
    elseif #self.mListItems > #listItems then
      for i = #listItems, #self.mListItems do
        local currentListItem = self.mListItems[i].entityId
        UiElementBus.Event.Reparent(currentListItem, self.mCachedPrototypeElement, invalidEntityId)
      end
    else
      local numCacheNeeded = #listItems - #self.mListItems
      for i = 1, numCacheNeeded do
        UiElementBus.Event.Reparent(cachedElements[i], self.Properties.DropdownListHolder, invalidEntityId)
        table.insert(prototypeList, cachedElements[i])
      end
    end
  else
    local childElements = UiElementBus.Event.GetChildren(self.Properties.DropdownListHolder)
    if childElements then
      for i = 1, #childElements do
        UiElementBus.Event.DestroyElement(childElements[i])
      end
    end
    for _, spawnData in pairs(self.spawnData) do
      spawnData.deleteOnSpawn = true
    end
    self.mSelectedItem = nil
    self.mPreviousItem = nil
  end
  ClearTable(self.mListItems)
  self.mListItemsTotal = #listItems
  if not usingPrototype then
    self:BusConnect(UiSpawnerNotificationBus, self.DropdownListHolder)
  end
  for i = 1, #listItems do
    local data = listItems[i]
    data.itemIndex = i
    if usingPrototype then
      self:OnListItemSpawned(self.registrar:GetEntityTable(prototypeList[i]), listItems[i])
    else
      self:SpawnSlice(self.DropdownListHolder, self.ListItemSlice, self.OnListItemSpawned, data)
      table.insert(self.spawnData, data)
    end
  end
  UiTransformBus.Event.SetLocalPosition(self.DropdownHolder, Vector2(0, self.mListInitPosY))
  self.mFocusedItem = nil
  self:Collapse()
  self.mIsEnabled = self.mListItemsTotal > 0
end
function Dropdown:SetStaticHeightPadding(heightPadding)
  self.mStaticHeightPadding = heightPadding
end
function Dropdown:OnListItemSpawned(entity, data)
  for index, spawnData in pairs(self.spawnData) do
    if data == spawnData then
      self.spawnData[index] = nil
      if spawnData.deleteOnSpawn then
        UiElementBus.Event.DestroyElement(entity.entityId)
        return
      end
      break
    end
  end
  self.mListItems[data.itemIndex] = entity
  entity:SetText(data.text)
  data.owner = self
  entity:SetData(data)
  if data.textColor then
    entity:SetTextColor(data.textColor)
  end
  if self.Properties.IsCheckboxDropdown then
    local textRight = data.textRight ~= nil and data.textRight or ""
    entity:SetTextRight(data.textRight)
    entity:SetCallback(self.OnCheckboxChanged, self)
  end
  UiDropdownOptionBus.Event.SetOwningDropdown(entity.entityId, self.entityId)
  if data.text == self:GetText() then
    self.mSelectedItem = entity
    self.mSelectedItemData = data
  end
  local itemHeight = entity:GetHeight()
  if self.mListHeightRows ~= nil and data.itemIndex == 1 then
    local dropdownHeight = (itemHeight + self.mListItemSpacing) * self.mListHeightRows
    self:SetDropdownListHeight(dropdownHeight)
  end
  local listHeight = (itemHeight + self.mListItemSpacing) * #self.mListItems
  if self.mStaticHeightPadding then
    listHeight = listHeight + self.mStaticHeightPadding
  end
  UiTransform2dBus.Event.SetLocalHeight(self.DropdownListHolder, listHeight)
  if #self.mListItems >= self.mListItemsTotal then
    if self.mItemsReadyCallback ~= nil and self.mItemsReadyCallbackTable ~= nil then
      self.mItemsReadyCallback(self.mItemsReadyCallbackTable)
    end
    self:SetDropdownListIsEnabled(false)
  end
end
function Dropdown:OnFocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverStart()
  end
  if not self.mIsEnabled then
    return
  end
  local animDuration1 = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:Play(self.Properties.DropdownTexture, animDuration1, {opacity = 0.1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.DropdownFrame, animDuration1, {opacity = 0.8, ease = "QuadOut"})
  if not self.timeline then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.DropdownFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.3})
    self.timeline:Add(self.DropdownFocusGlow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.4})
    self.timeline:Add(self.DropdownFocusGlow, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 0.4,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.DropdownFocusGlow, animDuration1, {opacity = 0.4, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.DropdownFocusGlow, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.4,
    delay = animDuration1,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.OnHover_Dropdown)
end
function Dropdown:OnUnfocus()
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  if not self.mIsEnabled then
    return
  end
  local animDuration1 = 0.15
  local animDuration2 = 0
  self.ScriptedEntityTweener:Play(self.Properties.DropdownTexture, animDuration1, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.DropdownFrame, animDuration1, {opacity = 0.6, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.DropdownFocusGlow, animDuration1, {opacity = 0, ease = "QuadIn"})
  if self.isShown then
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    local mouse = UiCanvasBus.Event.GetMousePosition(canvasId)
    local entityRect = UiTransformBus.Event.GetViewportSpaceRect(self.entityId)
    local top = entityRect:GetCenterY() - entityRect:GetHeight() / 2
    local halfWidth = entityRect:GetWidth() / 2
    local left = entityRect:GetCenterX() - halfWidth
    local right = entityRect:GetCenterX() + halfWidth
    if left > mouse.x or right < mouse.x or not self.openAbove and top > mouse.y or self.openAbove and top < mouse.y then
      self:Collapse()
    end
  end
end
function Dropdown:SetEnableDropdownUsage(enabled)
  self.mIsEnabled = enabled
  UiElementBus.Event.SetIsEnabled(self.DropdownArrow, enabled)
  local children = UiElementBus.Event.GetChildren(self.Properties.DropdownFrame)
  for idx = 1, #children do
    UiElementBus.Event.SetIsEnabled(children[idx], enabled)
  end
end
function Dropdown:OnItemFocus(index)
  if self.mFocusedItem and self.mFocusedItem ~= self.mListItems[index] then
    self.mFocusedItem:OnUnfocus()
  end
  self.mFocusedItem = self.mListItems[index]
  if self.isShown and self.mItemFocusCallback ~= nil and self.mItemFocusCallbackTable ~= nil then
    local focusedItemData = self.mFocusedItem:GetData()
    self.mItemFocusCallback(self.mItemFocusCallbackTable, focusedItemData)
  end
end
function Dropdown:SetForceOpenUpwards(openUp)
  self.openUp = openUp
end
function Dropdown:OnShowDropdown()
  local scrollbarWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.DropdownListScrollBar)
  local dropdownListHolderWidth = UiElementBus.Event.IsEnabled(self.Properties.DropdownListScrollBar) and self.mWidth - scrollbarWidth or self.mWidth - 2
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.DropdownListHolder, dropdownListHolderWidth)
  if not self.mIsEnabled then
    return
  end
  if self.isShown then
    self:Collapse()
    return
  end
  if self.preOpenCallback ~= nil and self.preOpenCallbackTable ~= nil then
    self.preOpenCallback(self.preOpenCallbackTable, self.entityId)
  end
  timingUtils:StopDelay(self)
  timingUtils:Delay(0.5, self, function(self)
    local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
    local canvasEnabled = UiCanvasBus.Event.GetEnabled(canvasId)
    local isStillEnabled = UiElementBus.Event.GetAreElementAndAncestorsEnabled(self.entityId)
    if not isStillEnabled or not canvasEnabled then
      self:OnHideDropdown()
    end
  end, true)
  if self.mIsUsingTooltip then
    self.ButtonTooltipSetter:OnTooltipSetterHoverEnd()
  end
  self.isShown = true
  self:SetListItemsAnimating(true)
  self:SetDropdownListIsEnabled(true)
  if self.mSelectedItem ~= nil then
    self.mSelectedItem:OnFocus()
    local itemHeight = self.mSelectedItem:GetHeight()
    local itemIndex = self.mSelectedItemData.itemIndex
    local listHeightRows = self.mListHeightRows or 1
    local scrollPosY = (itemHeight + self.mListItemSpacing) * (itemIndex - 1)
    UiScrollBoxBus.Event.SetScrollOffset(self.DropdownListScrollBox, Vector2(0, -scrollPosY))
  end
  local viewportSize = LyShineScriptBindRequestBus.Broadcast.GetViewportSize()
  local holderRect = UiTransformBus.Event.GetViewportSpaceRect(self.DropdownHolderMask)
  local holderBottom = holderRect:GetCenterY() + holderRect:GetHeight() / 2
  self.openAbove = self.openUp or holderBottom > viewportSize.y
  if self.openAbove then
    local maskY = UiTransformBus.Event.GetLocalPositionY(self.DropdownHolderMask) - (self.mHeight + self.mListHeight)
    UiTransformBus.Event.SetLocalPositionY(self.DropdownHolderMask, maskY)
  end
  local startY = self.openAbove and self.mListHeight or self.mListInitPosY
  self.ScriptedEntityTweener:Play(self.DropdownHolder, 0.3, {y = startY}, {
    y = 0,
    ease = "QuadOut",
    onComplete = function()
      self:SetListItemsAnimating(false)
    end
  })
  self.DropdownListBg:SetLineVisible(true, 1.4)
  if self.mOpenCallback ~= nil and self.mOpenCallbackTable ~= nil then
    self.mOpenCallback(self.mOpenCallbackTable, self.entityId)
  end
  self.audioHelper:PlaySound(self.audioHelper.Accept)
end
function Dropdown:OnHideDropdown()
  self.isShown = false
  timingUtils:StopDelay(self)
  self:SetListItemsAnimating(true)
  self:SetDropdownListIsEnabled(true)
  local endY = self.openAbove and self.mListHeight or self.mListInitPosY
  self.ScriptedEntityTweener:Play(self.DropdownHolder, 0.2, {
    y = endY,
    ease = "QuadIn",
    onComplete = function()
      self:SetDropdownListIsEnabled(false)
      self:SetListItemsAnimating(false)
      if self.mFocusedItem then
        self.mFocusedItem:OnUnfocus()
      end
      self.mFocusedItem = nil
      UiDropdownBus.Event.CollapseAnimationFinish(self.entityId)
      UiTransformBus.Event.SetLocalPositionY(self.DropdownHolderMask, 0)
    end
  })
  if self.mCloseCallback ~= nil and self.mCloseCallbackTable ~= nil then
    self.mCloseCallback(self.mCloseCallbackTable, self.entityId)
  end
  self.DropdownListBg:SetLineVisible(false, 1.2)
end
function Dropdown:OnOptionSelected()
  local listItem = self.registrar:GetEntityTable(UiDropdownBus.Event.GetValue(self.entityId))
  local listItemData = listItem:GetData()
  if listItem.mIsEnabled == false then
    return
  end
  self.mPreviousItem = self.mSelectedItem
  self.mPreviousItemData = self.mSelectedItemData
  self.mSelectedItem = listItem
  self.mSelectedItemData = listItemData
  self:SetText(listItemData.text)
  if listItemData.textColor then
    self:SetTextColor(listItemData.textColor)
  end
  if self.mCallback ~= nil and self.mCallbackTable ~= nil then
    if type(self.mCallback) == "function" then
      self.mCallback(self.mCallbackTable, listItem, listItemData, self)
    else
      self.mCallbackTable[self.mCallback](self.mCallbackTable, listItem, listItemData, self)
    end
  end
  self:Collapse()
end
function Dropdown:SetDropdownListIsEnabled(isEnabled)
  if isEnabled ~= nil then
    UiElementBus.Event.SetIsEnabled(self.DropdownHolderMask, isEnabled)
  end
end
function Dropdown:SetListItemsAnimating(isAnimating)
  for i = 1, #self.mListItems do
    local listItem = self.mListItems[i]
    if listItem and listItem.SetIsAnimating ~= nil and type(listItem.SetIsAnimating) == "function" then
      listItem:SetIsAnimating(isAnimating)
    end
  end
end
function Dropdown:SetLineColor(color)
  UiImageBus.Event.SetColor(self.Properties.DropdownFrame, color)
end
function Dropdown:SetListBgAlpha(alpha)
  self.DropdownListBg:SetFillAlpha(alpha)
end
function Dropdown:OnShutdown()
  timingUtils:StopDelay(self)
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function Dropdown:SetSelectedImage(pathname)
  local show = pathname and type(pathname) == "string" and string.len(pathname) > 0
  if show then
    UiImageBus.Event.SetSpritePathname(self.DropdownSelectedImage, pathname)
  end
  UiElementBus.Event.SetIsEnabled(self.DropdownSelectedImage, show)
end
function Dropdown:SetTextStyle(value)
  SetTextStyle(self.DropdownText, value)
end
function Dropdown:Collapse()
  UiDropdownBus.Event.Collapse(self.entityId)
end
return Dropdown
