local KeyBindingListItem = {
  Properties = {
    ItemTextTitle = {
      default = EntityId()
    },
    ItemTextLabel = {
      default = EntityId()
    },
    ItemTextData = {
      default = EntityId()
    },
    ItemBg = {
      default = EntityId()
    },
    ItemFocusArrow = {
      default = EntityId()
    },
    Tooltip = {
      default = EntityId()
    }
  },
  width = nil,
  height = nil,
  pressCallback = nil,
  pressTable = nil,
  isTitle = false,
  isBinding = false,
  isHovering = false,
  canUnbind = true,
  animDuration = 0.15,
  maxBindTime = 0.5,
  bindDuration = 0,
  bindingKey = "",
  escapeKey = "escape",
  unboundKey = " "
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(KeyBindingListItem)
function KeyBindingListItem:OnInit()
  BaseElement.OnInit(self)
  self.disallowedConflicts = {}
  self.bindingData = {}
  self.mapNames = {
    "combat",
    "camera",
    "dialogue",
    "player",
    "movement",
    "ui"
  }
  SetTextStyle(self.ItemTextTitle, self.UIStyle.FONT_STYLE_KEYBIND_TITLE)
  SetTextStyle(self.ItemTextLabel, self.UIStyle.FONT_STYLE_KEYBIND_LABEL)
  SetTextStyle(self.ItemTextData, self.UIStyle.FONT_STYLE_KEYBIND_DATA)
  self.width = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  self.height = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.ignoreKeybindConflicts", function(self, ignoreKeybindConflicts)
    self.ignoreKeybindConflicts = ignoreKeybindConflicts
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_allowUnboundKeys", function(self, allowUnboundKeys)
    self.allowUnboundKeys = allowUnboundKeys
  end)
  self.Tooltip:SetSimpleTooltip("@ui_unbind_key")
end
function KeyBindingListItem:OnTick(deltaTime, timePoint)
  if self.isBinding then
    self.bindDuration = self.bindDuration + deltaTime
    if self.bindDuration > self.maxBindTime then
      self:ExecuteCallback()
    end
  end
end
function KeyBindingListItem:SetSize(width, height)
  self.width = width
  self.height = height
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.width)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.height)
end
function KeyBindingListItem:SetOptionsCallbacks(table)
  self.optionsTable = table
end
function KeyBindingListItem:GetWidth()
  return self.width
end
function KeyBindingListItem:GetHeight()
  return self.height
end
function KeyBindingListItem:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTextLabel, value, eUiTextSet_SetLocalized)
end
function KeyBindingListItem:GetText()
  return UiTextBus.Event.GetText(self.Properties.ItemTextLabel)
end
function KeyBindingListItem:SetTextColor(color)
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, 2, {textColor = color})
end
function KeyBindingListItem:SetFontSize(value)
  UiTextBus.Event.SetFontSize(self.Properties.ItemTextLabel, value)
end
function KeyBindingListItem:GetFontSize(value)
  UiTextBus.Event.GetFontSize(self.Properties.ItemTextLabel, value)
end
function KeyBindingListItem:SetCharacterSpacing(value)
  UiTextBus.Event.SetCharacterSpacing(self.Properties.ItemTextLabel, value)
end
function KeyBindingListItem:GetCharacterSpacing()
  return UiTextBus.Event.GetCharacterSpacing(self.Properties.ItemTextLabel)
end
function KeyBindingListItem:SetTextStyle(value)
  SetTextStyle(self.ItemTextLabel, value)
end
function KeyBindingListItem:SetTextData(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemTextData, value, eUiTextSet_SetLocalized)
end
function KeyBindingListItem:GetTextData()
  return UiTextBus.Event.GetText(self.Properties.ItemTextData)
end
function KeyBindingListItem:SetTextTitle(value)
  self.isTitle = true
  UiTextBus.Event.SetTextWithFlags(self.ItemTextTitle, value, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemTextLabel, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemTextData, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemBg, false)
end
function KeyBindingListItem:GetTextTitle()
  return UiTextBus.Event.GetText(self.ItemTextTitle)
end
function KeyBindingListItem:SetBindingData(data)
  self.bindingData = data
end
function KeyBindingListItem:SetDefaultData(data)
  self.defaultData = data
end
function KeyBindingListItem:SetOverrideData(data)
  self.overrideData = data
end
function KeyBindingListItem:SetIgnoredData(data)
  self.ignoredData = data
end
function KeyBindingListItem:SetIsLocked(data)
  self.isLocked = data
  if self.isLocked then
    self.ScriptedEntityTweener:Set(self.Properties.ItemBg, {opacity = 0})
  end
end
function KeyBindingListItem:IsIgnoredAction(actionName, actionMapName)
  if not self.ignoredData or type(self.ignoredData) ~= "table" then
    return false
  end
  for i, data in pairs(self.ignoredData) do
    if data.bindingName == actionName then
      return true
    end
    if data.ignoreByActionMap and data.actionMapName == actionMapName then
      return true
    end
  end
  return false
end
function KeyBindingListItem:SetAllowConflicts(allowConflicts)
  self.allowConflicts = allowConflicts
end
function KeyBindingListItem:SetDisallowedConflictData(disallowedConflicts)
  if disallowedConflicts then
    self.disallowedConflicts = disallowedConflicts
  end
end
function KeyBindingListItem:LocalizeKeyName(keyName)
  local keyLoc = "@cc_" .. keyName
  local localizedKeyName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(keyLoc)
  if keyLoc == localizedKeyName then
    keyLoc = "@" .. keyName
    localizedKeyName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(keyLoc)
    if keyLoc == localizedKeyName then
      localizedKeyName = keyName
    end
  end
  return localizedKeyName
end
function KeyBindingListItem:UpdateKeybinding()
  if self.overrideData then
    self:SetTextData(self.overrideData)
    return
  end
  if #self.bindingData == 0 then
    return
  end
  local bindingEntry = self.bindingData[1]
  local currentKeyValue = LyShineManagerBus.Broadcast.GetKeybind(bindingEntry.bindingName, bindingEntry.actionMapName)
  if currentKeyValue then
    local locText = self:LocalizeKeyName(currentKeyValue)
    self:SetTextData(locText)
  else
    Log("KeyBindingListItem::UpdateKeybinding : No key binding available for current binding(" .. tostring(bindingEntry.bindingName) .. "), reverting to use default data (" .. tostring(self.defaultData) .. ").")
    self:SetTextData(self.defaultData)
  end
end
function KeyBindingListItem:OnFocus()
  self.isHovering = true
  if self.isTitle or self.isBinding or self.isLocked then
    return
  end
  local currentText = self:GetTextData()
  if currentText ~= "" and currentText ~= self.unboundKey then
    self.Tooltip:OnTooltipSetterHoverStart()
  end
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, self.animDuration, {
    textColor = self.UIStyle.COLOR_GRAY_70
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextData, self.animDuration, {
    textColor = self.UIStyle.COLOR_WHITE
  })
  self.bgTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.bgTimeline:Add(self.Properties.ItemBg, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.6})
  self.bgTimeline:Add(self.Properties.ItemBg, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.8})
  self.bgTimeline:Add(self.Properties.ItemBg, self.UIStyle.DURATION_TIMELINE_HOLD, {
    opacity = 0.8,
    onComplete = function()
      self.bgTimeline:Play()
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemBg, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.8, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ItemBg, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 0.8,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.bgTimeline:Play()
    end
  })
  self.ItemBg:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_OptionsListItem)
end
function KeyBindingListItem:OnUnfocus()
  self.isHovering = false
  if self.isTitle or self.isBinding or self.isLocked then
    return
  end
  self.Tooltip:OnTooltipSetterHoverEnd()
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, self.animDuration, {
    textColor = self.UIStyle.COLOR_GRAY_50
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemTextData, self.animDuration, {
    textColor = self.UIStyle.COLOR_GRAY_90
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemBg, self.animDuration, {opacity = 0.5, ease = "QuadIn"})
  self.ItemBg:OnUnfocus()
end
function KeyBindingListItem:FlashWarning()
  if self.isTitle then
    return
  end
  self.bgTimeline = self.ScriptedEntityTweener:TimelineCreate()
  self.bgTimeline:Add(self.Properties.ItemBg, 0.35, {
    opacity = 1,
    imgColor = self.UIStyle.COLOR_RED
  })
  self.bgTimeline:Add(self.Properties.ItemBg, 0.15, {
    opacity = 1,
    imgColor = self.UIStyle.COLOR_RED
  })
  self.bgTimeline:Add(self.Properties.ItemBg, 0.4, {
    opacity = 0.8,
    imgColor = self.UIStyle.COLOR_RED
  })
  self.bgTimeline:Add(self.Properties.ItemBg, 0.3, {
    opacity = 0.5,
    imgColor = self.UIStyle.COLOR_WHITE
  })
  self.bgTimeline:Play()
end
function KeyBindingListItem:OnBindingStart()
  if not self.isBinding then
    self.isBinding = true
    self.ScriptedEntityTweener:Play(self.Properties.ItemTextLabel, self.animDuration, {
      textColor = self.UIStyle.COLOR_TAN_LIGHT
    })
    self.ScriptedEntityTweener:Play(self.Properties.ItemTextData, self.animDuration, {
      textColor = self.UIStyle.COLOR_WHITE
    })
    self.bgTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.bgTimeline:Add(self.Properties.ItemBg, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.bgTimeline:Add(self.Properties.ItemBg, self.UIStyle.DURATION_TIMELINE_HOLD, {opacity = 1})
    self.bgTimeline:Add(self.Properties.ItemBg, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
      opacity = 0.8,
      onComplete = function()
        self.bgTimeline:Play()
      end
    })
    self.bgTimeline:Play()
    self.arrowTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.arrowTimeline:Add(self.Properties.ItemFocusArrow, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.8, x = 20})
    self.arrowTimeline:Add(self.Properties.ItemFocusArrow, self.UIStyle.DURATION_TIMELINE_HOLD, {opacity = 0.8, x = 20})
    self.arrowTimeline:Add(self.Properties.ItemFocusArrow, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
      opacity = 1,
      x = 15,
      onComplete = function()
        self.arrowTimeline:Play()
      end
    })
    self.arrowTimeline:Play()
    self.audioHelper:PlaySound(self.audioHelper.Accept)
    self.keyInputNotificationBus = self:BusConnect(KeyInputNotificationBus)
  end
end
function KeyBindingListItem:OnBindingEnd()
  if self.isBinding then
    self.isBinding = false
    if self.bindingKey ~= "" then
      local matchingActions = self:FindConflictingAction(self.bindingKey)
      if #matchingActions == 0 then
        self:RebindAction(self.bindingKey)
      else
        self:FlashWarning()
        if self.optionsTable ~= nil then
          self.optionsTable:ShowKeyAlreadyBoundWarning(self, matchingActions)
        end
      end
    end
    if self.isHovering then
      self:OnFocus()
    else
      self:OnUnfocus()
    end
    self.ScriptedEntityTweener:Play(self.Properties.ItemFocusArrow, self.animDuration, {
      opacity = 0,
      x = 0,
      ease = "QuadIn"
    })
    self:BusDisconnect(self.keyInputNotificationBus)
    self.keyInputNotificationBus = nil
    self:BusDisconnect(self.tickBus)
    self.tickBus = nil
  end
end
function KeyBindingListItem:FindConflictingAction(keyName)
  local matchingActions = {}
  if self.ignoreKeybindConflicts then
    return matchingActions
  end
  if not self.allowConflicts then
    for i = 1, #self.mapNames do
      local foundActionList = LyShineManagerBus.Broadcast.GetActionInMapByKey(keyName, self.mapNames[i])
      for j = 1, #foundActionList do
        if self.bindingData[1].bindingName ~= foundActionList[j] and not self:IsIgnoredAction(foundActionList[j]) then
          table.insert(matchingActions, foundActionList[j])
        end
      end
    end
  end
  local keyLoc = "@cc_" .. keyName
  local localizedKeyName = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@cc_" .. keyName)
  if keyLoc == localizedKeyName then
    localizedKeyName = keyName
  end
  for _, bindingEntry in ipairs(self.disallowedConflicts) do
    local usedKey = LyShineManagerBus.Broadcast.GetKeybind(bindingEntry.bindingName, bindingEntry.actionMapName)
    if usedKey == localizedKeyName then
      table.insert(matchingActions, bindingEntry.bindingName)
    end
  end
  return matchingActions
end
function KeyBindingListItem:RebindAction(newKey, skipSave)
  for i = 1, #self.bindingData do
    GameRequestsBus.Broadcast.RebindAction(self.bindingData[i].bindingName, self.bindingData[i].actionMapName, newKey)
  end
  if not skipSave then
    GameRequestsBus.Broadcast.SaveRebindData()
  end
  self:UpdateKeybinding()
  self:ResetBindingKey()
end
function KeyBindingListItem:SetCanUnbind(canUnbind)
  self.canUnbind = canUnbind
  local tooltip = self.canUnbind and "@ui_unbind_key" or "@ui_unbind_key_disabled"
  self.Tooltip:SetSimpleTooltip(tooltip)
end
function KeyBindingListItem:CanUnbindAction()
  return self.allowUnboundKeys and self.canUnbind and not self.isBinding
end
function KeyBindingListItem:UnbindAction(skipSave)
  if not self:CanUnbindAction() then
    return
  end
  self:RebindAction(self.unboundKey, skipSave)
end
function KeyBindingListItem:GetBindingKey()
  return self.bindingKey
end
function KeyBindingListItem:ResetBindingKey()
  self.bindingKey = ""
end
function KeyBindingListItem:OnKeyPressed(keyName)
  if keyName == self.escapeKey then
    return
  end
  self.bindingKey = keyName
  self.bindDuration = 0
  if not self.tickBus then
    self.tickBus = self:BusConnect(DynamicBus.UITickBus)
  end
end
function KeyBindingListItem:OnKeyReleased(keyName)
  if keyName == self.escapeKey or self.bindingKey == keyName then
    self:ExecuteCallback()
  end
end
function KeyBindingListItem:OnClick()
  if not self.isBinding then
    self:ExecuteCallback()
  end
end
function KeyBindingListItem:OnRightClick()
  self:UnbindAction()
  self.Tooltip:OnTooltipSetterHoverEnd()
end
function KeyBindingListItem:ExecuteCallback()
  if self.optionsTable ~= nil and not self.isLocked then
    self.optionsTable:SelectKeybindingRow(self)
  end
end
function KeyBindingListItem:OnShutdown()
  if self.bgTimeline ~= nil then
    self.bgTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.bgTimeline)
  end
  if self.arrowTimeline ~= nil then
    self.arrowTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.arrowTimeline)
  end
end
return KeyBindingListItem
