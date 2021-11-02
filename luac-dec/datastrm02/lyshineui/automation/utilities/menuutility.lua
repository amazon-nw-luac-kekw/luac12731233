local Logger = RequireScript("LyShineUI.Automation.Logger")
local InputUtility = RequireScript("LyShineUI.Automation.Utilities.InputUtility")
local TimerHandled = RequireScript("LyShineUI.Automation.Utilities.TimerHandled")
local TimerHandler = RequireScript("LyShineUI.Automation.Utilities.TimerHandler")
local Registrar = RequireScript("LyShineUI.EntityRegistrar")
local MenuStack = RequireScript("LyShineUI.Automation.MenuStack")
local MenuUtility = {ScrollExtremeStep = 1000, WaitForMenuTimeout = 3}
MenuUtility.Anchors = {
  TopLeft = {x = 0, y = 0},
  TopCenter = {x = 0.5, y = 0},
  TopRight = {x = 1, y = 0},
  CenterLeft = {x = 0, y = 0.5},
  Center = {x = 0.5, y = 0.5},
  CenterRight = {x = 1, y = 0.5},
  BotLeft = {x = 0, y = 1},
  BotCenter = {x = 0.5, y = 1},
  BotRight = {x = 1, y = 1}
}
local function Log(msg)
  Logger:Log("[MenuUtility] " .. tostring(msg))
end
function MenuUtility:GetEntityTable(entityId)
  if type(entityId) == "table" then
    return entityId
  else
    return Registrar:GetEntityTable(entityId)
  end
end
function MenuUtility:GetEntityId(entity)
  if type(entity) == "table" then
    return entity.entityId
  else
    return entity
  end
end
function MenuUtility:IsEnabled(obj)
  return UiElementBus.Event.IsEnabled(self:GetEntityId(obj))
end
function MenuUtility:GetChildren(obj)
  return UiElementBus.Event.GetChildren(self:GetEntityId(obj))
end
function MenuUtility:GetChildByName(obj, name)
  return UiElementBus.Event.FindChildByName(self:GetEntityId(obj), name)
end
function MenuUtility:GetParent(obj)
  return UiElementBus.Event.GetParent(self:GetEntityId(obj))
end
function MenuUtility:GetObjectViewportSize(obj)
  local objId = self:GetEntityId(obj)
  local rect = UiTransformBus.Event.GetViewportSpaceRect(objId)
  return Vector2(rect:GetWidth(), rect:GetHeight())
end
function MenuUtility:GetObjectLocalSize(obj)
  local objId = self:GetEntityId(obj)
  return Vector2(UiTransform2dBus.Event.GetLocalWidth(objId), UiTransform2dBus.Event.GetLocalHeight(objId))
end
local function GetPosition(obj, anchor, positionFun, sizeFun)
  local objId = MenuUtility:GetEntityId(obj)
  anchor = anchor or MenuUtility.Anchors.Center
  local pivot = UiTransformBus.Event.GetPivot(objId)
  local pos = positionFun(objId)
  local size = sizeFun(MenuUtility, objId)
  pos.x = pos.x + size.x * (anchor.x - pivot.x)
  pos.y = pos.y + size.y * (anchor.y - pivot.y)
  return pos
end
function MenuUtility:GetObjectViewportPosition(obj, anchor)
  return GetPosition(obj, anchor, UiTransformBus.Event.GetViewportPosition, self.GetObjectViewportSize)
end
function MenuUtility:GetObjectLocalPosition(obj, anchor)
  return GetPosition(obj, anchor, UiTransformBus.Event.GetLocalPosition, self.GetObjectLocalSize)
end
function MenuUtility:ClickAtObject(obj, anchor)
  self:ClickAt(self:GetObjectViewportPosition(obj, anchor))
end
function MenuUtility:ClickAt(position)
  InputUtility:SetCursorPosition(position)
  InputUtility:PressLeftClick()
end
function MenuUtility:DragAndDropObjects(fromObj, toObj)
  local posFrom = self:GetObjectViewportPosition(fromObj, self.Anchors.Center)
  local posTo = self:GetObjectViewportPosition(toObj, self.Anchors.Center)
  InputUtility:ClickAndDrag(posFrom, posTo, true)
end
function MenuUtility:DragAndDropWithSmallMovement(startPosition, targetPosition)
  local smallMovement = Vector2(startPosition.x + 5, startPosition.y + 5)
  InputUtility:ClickAndDrag(startPosition, smallMovement, false)
  InputUtility:SetCursorPosition(targetPosition)
  InputUtility:ReleaseLeftClick()
end
function MenuUtility:DragAndDropObjectsWithSmallMovement(fromObj, toObj)
  local posFrom = self:GetObjectViewportPosition(fromObj, self.Anchors.Center)
  local posTo = self:GetObjectViewportPosition(toObj, self.Anchors.Center)
  self:DragAndDropWithSmallMovement(posFrom, posTo)
end
function MenuUtility:InBoundsViewport(inner, outer)
  local innerPosition = self:GetObjectViewportPosition(inner, self.Anchors.TopLeft)
  local innerSize = self:GetObjectViewportSize(inner)
  local outerPosition = self:GetObjectViewportPosition(outer, self.Anchors.TopLeft)
  local outerSize = self:GetObjectViewportSize(outer)
  return self:InBounds(innerPosition, innerSize, outerPosition, outerSize)
end
function MenuUtility:InBoundsLocal(inner, outer)
  local innerPosition = self:GetObjectLocalPosition(inner, self.Anchors.TopLeft)
  local innerSize = self:GetObjectLocalSize(inner)
  local outerPosition = self:GetObjectLocalPosition(outer, self.Anchors.TopLeft)
  local outerSize = self:GetObjectLocalSize(outer)
  return self:InBounds(innerPosition, innerSize, outerPosition, outerSize)
end
function MenuUtility:InBounds(innerPosition, innerSize, outerPosition, outerSize)
  local inBounds = Vector2(0, 0)
  local function positionCalculation(key)
    if innerPosition[key] < outerPosition[key] then
      inBounds[key] = outerPosition[key] - innerPosition[key]
    elseif innerPosition[key] + innerSize[key] > outerPosition[key] + outerSize[key] then
      if innerSize[key] > outerSize[key] then
        inBounds[key] = outerPosition[key] - innerPosition[key]
      else
        inBounds[key] = outerPosition[key] + outerSize[key] - innerPosition[key] - innerSize[key]
      end
    end
  end
  positionCalculation("x")
  positionCalculation("y")
  return inBounds
end
function MenuUtility:ClickButton(button)
  local pos = self:GetObjectViewportPosition(button, self.Anchors.Center)
  self:ClickAt(pos)
end
function MenuUtility:GoToTabByIndex(tabbedList, index)
  local tabbedListT = self:GetEntityTable(tabbedList)
  local tab = tabbedListT:GetTab(index)
  self:ClickButton(tab)
end
function MenuUtility:GoToTabByText(tabbedList, text)
  local tabbedListT = self:GetEntityTable(tabbedList)
  local tab
  for i = 1, tabbedListT:GetTabCount() do
    local currentTab = tabbedListT:GetTab(i)
    if currentTab.tabData.text == text then
      tab = currentTab
      break
    end
  end
  self:ClickButton(tab)
end
function MenuUtility:GetSelectedTabTextAndIndex(tabbedList)
  local tabbedListT = self:GetEntityTable(tabbedList)
  local tabData = tabbedListT:GetSelectedTabData()
  if tabData ~= nil then
    return tabData.text, tabData.tabIndex
  else
    Log("Warning: No tab selected")
    return nil
  end
end
function MenuUtility:GetSliderValue(slider)
  return self:GetEntityTable(slider):GetValue()
end
function MenuUtility:GetSliderPercentage(slider)
  return self:GetEntityTable(slider):GetSliderPercentage() * 100
end
function MenuUtility:MoveToSliderPercentage(slider, perc)
  perc = Clamp(perc, 0, 100)
  local sliderT = self:GetEntityTable(slider)
  local sliderLeft = self:GetObjectViewportPosition(sliderT.Properties.SliderFillSlice, self.Anchors.CenterLeft)
  local size = self:GetObjectViewportSize(sliderT.Properties.SliderFillSlice)
  local startPos = self:GetObjectViewportPosition(sliderT.Properties.SliderHandleHolder, self.Anchors.Center)
  local endPos = Vector2(sliderLeft.x + size.x * perc / 100, sliderLeft.y)
  InputUtility:ClickAndDrag(startPos, endPos, true)
  coroutine.yield()
  return endPos.x
end
function MenuUtility:SetSliderValue(slider, value)
  local sliderT = self:GetEntityTable(slider)
  local sliderMin = sliderT:GetMinValue()
  local sliderMax = sliderT:GetMaxValue()
  local value = Clamp(value, sliderMin, sliderMax)
  self:SetSliderPercentage(slider, value / (sliderMax - sliderMin) * 100)
end
function MenuUtility:SetSliderPercentage(slider, perc)
  perc = Clamp(perc, 0, 100)
  local sliderT = self:GetEntityTable(slider)
  local sliderLeft = self:GetObjectViewportPosition(sliderT.Properties.SliderFillSlice, self.Anchors.CenterLeft)
  local size = self:GetObjectViewportSize(sliderT.Properties.SliderFillSlice)
  self:MoveToSliderPercentage(slider, 0)
  local p50 = self:MoveToSliderPercentage(slider, 50)
  local v50 = self:GetSliderPercentage(slider)
  local p100 = self:MoveToSliderPercentage(slider, 100)
  local v100 = self:GetSliderPercentage(slider)
  local p0 = self:MoveToSliderPercentage(slider, 0)
  local v0 = self:GetSliderPercentage(slider)
  local W = p100 * p100 - p0 * p0
  local L = p50 * p50 - p0 * p0
  local T = p50 - p0
  local K = p100 - p0
  local a = ((v100 - v0) * T - (v50 - v0) * K) / (W * T - K * L)
  local b = (v50 - v0 - a * L) / T
  local c = v0 - a * p0 * p0 - b * p0
  local pos = (math.sqrt(math.abs(b * b + 4 * a * (perc - c))) - b) / (2 * a)
  if perc < 50 then
    self:MoveToSliderPercentage(slider, 100)
  end
  coroutine.yield()
  local startPos = self:GetObjectViewportPosition(sliderT.Properties.SliderHandleHolder, self.Anchors.Center)
  local endPos = Vector2(pos, sliderLeft.y)
  InputUtility:ClickAndDrag(startPos, endPos, true)
end
function MenuUtility:GetRadioButtonState(button)
  local buttonId = self:GetEntityId(button)
  return UiRadioButtonBus.Event.GetState(buttonId)
end
function MenuUtility:GetToggleState(toggle)
  local toggleT = self:GetEntityTable(toggle)
  return self:GetRadioButtonState(toggleT.Properties.ToggleButton2)
end
function MenuUtility:SetToggleState(toggle, state)
  local toggleT = self:GetEntityTable(toggle)
  local toClick = toggleT.Properties.ToggleButton1
  if state then
    toClick = toggleT.Properties.ToggleButton2
  end
  self:ClickButton(toClick)
end
function MenuUtility:ChangeToggleState(toggle)
  self:SetToggleState(toggle, not self:GetToggleState(toggle))
end
function MenuUtility:GetGridItemListChildren(grid)
  local gridT = self:GetEntityTable(grid)
  local rows = self:GetChildren(gridT.Properties.Content)
  local allChildren = {}
  for i = 1, #rows do
    rowT = self:GetEntityTable(rows[i])
    local gridElements = rowT.gridItemElements
    if gridElements then
      for j = 1, #gridElements do
        table.insert(allChildren, gridElements[j])
      end
    end
  end
  return allChildren
end
function MenuUtility:GetScrollBoxContent(scrollBox)
  return UiScrollBoxBus.Event.GetContentEntity(self:GetEntityId(scrollBox))
end
function MenuUtility:GetScrollBoxChildren(scrollBox)
  return self:GetChildren(self:GetScrollBoxContent(scrollBox))
end
function MenuUtility:ScrollBoxScrollVertical(scrollBox, distanceFunction)
  local scrollBoxId = self:GetEntityId(scrollBox)
  local centerPosition = self:GetObjectViewportPosition(scrollBox, self.Anchors.Center)
  InputUtility:SetCursorPosition(centerPosition)
  local distancePre = distanceFunction()
  local roundAbsUp = function(num)
    if 0 < num then
      return math.ceil(num)
    end
    return math.floor(num)
  end
  if distancePre ~= 0 then
    local distancePost = distancePre
    local input = 0
    while distancePost == distancePre do
      input = input + roundAbsUp(distancePre)
      InputUtility:Scroll(input, 1)
      coroutine.yield()
      distancePost = distanceFunction()
    end
    if distancePost ~= 0 then
      local coeff = math.abs(input) / (math.abs(distancePre) - math.abs(distancePost))
      InputUtility:Scroll(roundAbsUp(distancePost * coeff), 1)
      coroutine.yield()
    end
  end
end
function MenuUtility:ScrollBoxScrollVerticalToIndex(scrollBox, mask, index)
  local scrollBoxId = self:GetEntityId(scrollBox)
  local childList = self:GetScrollBoxChildren(scrollBoxId)
  self:ScrollBoxScrollVerticalToObject(scrollBoxId, mask, childList[index])
end
function MenuUtility:ScrollBoxScrollVerticalToObject(scrollBox, mask, obj)
  local function distFunc()
    return MenuUtility:InBoundsViewport(obj, mask).y
  end
  self:ScrollBoxScrollVertical(scrollBox, distFunc)
end
function MenuUtility:ScrollBoxScrollVerticalBy(scrollBox, targetDistance)
  local content = self:GetScrollBoxContent(scrollBox)
  local contentStartPosition = self:GetObjectViewportPosition(content, self.Anchors.TopLeft)
  local function distFunc()
    local contentPosition = MenuUtility:GetObjectViewportPosition(content, MenuUtility.Anchors.TopLeft)
    return contentStartPosition.y - contentPosition.y - targetDistance
  end
  self:ScrollBoxScrollVertical(scrollBox, distFunc)
end
function MenuUtility:ScrollBoxScrollVerticalToExtreme(scrollBox, bottom)
  local scrollBoxId = self:GetEntityId(scrollBox)
  local content = self:GetScrollBoxContent(scrollBox)
  local locationPre = self:GetObjectViewportPosition(content, self.Anchors.TopLeft)
  local centerPosition = self:GetObjectViewportPosition(scrollBox, self.Anchors.Center)
  InputUtility:SetCursorPosition(centerPosition)
  local input = self.ScrollExtremeStep
  if bottom then
    input = -input
  end
  while true do
    InputUtility:Scroll(input, 1)
    coroutine.yield()
    local locationPost = self:GetObjectViewportPosition(content, self.Anchors.TopLeft)
    if locationPost == locationPre then
      break
    end
    locationPre = locationPost
  end
end
function MenuUtility:GetDynamicScrollBoxChildern(scrollBox)
  local scrollBoxId = self:GetEntityId(scrollBox)
  local children = {}
  local index = 0
  while true do
    local child = UiDynamicScrollBoxBus.Event.GetChildAtElementIndex(scrollBoxId, index)
    if child:IsValid() then
      table.insert(children, child)
    else
      break
    end
    index = index + 1
  end
  return children
end
function MenuUtility:GetDropDownSelectedItemData(dropDown)
  local dropDownT = self:GetEntityTable(dropDown)
  return dropDownT:GetSelectedItemData()
end
function MenuUtility:GetDropDownSelectedItem(dropDown)
  local dropDownT = self:GetEntityTable(dropDown)
  return dropDownT:GetSelectedItem()
end
function MenuUtility:GetDropDownChildren(dropDown)
  local dropDownT = self:GetEntityTable(dropDown)
  return self:GetScrollBoxChildren(dropDownT.Properties.DropdownListScrollBox)
end
function MenuUtility:SelectDropDownOptionIndex(dropDown, index)
  local dropDownT = self:GetEntityTable(dropDown)
  self:ClickButton(dropDownT)
  TimerHandler:Sleep(1)
  self:ScrollBoxScrollVerticalToIndex(dropDownT.Properties.DropdownListScrollBox, dropDownT.Properties.DropdownListHolderMask, index)
  local children = self:GetDropDownChildren(dropDownT)
  local position = self:GetObjectViewportPosition(children[index], self.Anchors.Center)
  self:ClickAt(position)
end
function MenuUtility:OpenMenu(screenName, logAlias, openFunc, closeFunc, checkFunc, stateCRC)
  Log("Info: Opening " .. logAlias)
  if checkFunc() then
    Log("Info: " .. logAlias .. " already opened and on top")
  elseif MenuStack:IsOnStack(screenName) then
    Log("Info: " .. logAlias .. " already opened, bringing it to top")
    MenuStack:PopUntil(screenName, true)
  else
    if not MenuStack:IsEmpty() then
      Log("Warning: Menu stack is not empty, closing everything")
      MenuStack:Clear()
    end
    MenuStack:Push(openFunc, screenName, closeFunc, stateCRC)
  end
end
function MenuUtility:WaitForMenu(openMenu, checkFunc)
  openMenu()
  Log("Info: Waiting for menu")
  local timer = TimerHandler:GetTimer(self.WaitForMenuTimeout)
  while not checkFunc() do
    coroutine.yield()
    if timer:TimeUp() then
      Log("Warning: Menu didn't open in time, attempting to open it again")
      MenuStack:Clear()
      coroutine.yield()
      timer = TimerHandler:GetTimer(self.WaitForMenuTimeout)
      openMenu()
    end
  end
  Log("Info: Menu opened")
end
function MenuUtility:CloseMenu(screenName, logAlias)
  Log("Info: Closing " .. logAlias)
  if not MenuStack:IsOnStack(screenName) then
    Log("Warning: " .. logAlias .. " not opened")
  else
    MenuStack:PopUntil(screenName)
  end
end
return MenuUtility
