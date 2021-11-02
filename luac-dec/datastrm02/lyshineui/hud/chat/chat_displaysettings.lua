local Chat_DisplaySettings = {
  Properties = {
    SliderPrototype = {
      default = EntityId()
    },
    CheckboxPrototype = {
      default = EntityId()
    },
    ButtonPrototype = {
      default = EntityId()
    },
    KeybindPrototype = {
      default = EntityId()
    },
    RadioButtonsPrototype = {
      default = EntityId()
    },
    OptionsList = {
      default = EntityId()
    }
  },
  sliderInputWidth = 60
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Chat_DisplaySettings)
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function Chat_DisplaySettings:OnInit()
  local chatOptionTypes = {
    Slider = 1,
    Checkbox = 2,
    Button = 3,
    Radio = 4,
    Keybind = 5
  }
  local chatOptions = {}
  table.insert(chatOptions, {
    type = chatOptionTypes.Slider,
    label = "@ui_chat_font_size",
    dataPath = "Hud.LocalPlayer.Options.Chat.ChatFontSize",
    minValue = 16,
    maxValue = 32
  })
  local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
  table.insert(chatOptions, {
    type = chatOptionTypes.Slider,
    label = "@ui_chat_message_fade_delay",
    dataPath = "Hud.LocalPlayer.Options.Chat.ChatMessageFadeDelay",
    minValue = 0,
    maxValue = 5 * timeHelpers.secondsInMinute,
    tooltip = "@ui_chat_message_fade_delay_tooltip"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Slider,
    label = "@ui_chat_message_background_opacity",
    dataPath = "Hud.LocalPlayer.Options.Chat.ChatMessageBackgroundOpacity",
    minValue = 0,
    maxValue = 100,
    tooltip = "@ui_chat_message_background_opacity_tooltip"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Slider,
    label = "@ui_chat_message_gameplay_opacity",
    dataPath = "Hud.LocalPlayer.Options.Chat.ChatMessageGameplayOpacity",
    minValue = 0,
    maxValue = 100,
    tooltip = "@ui_chat_message_gameplay_opacity_tooltip"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Checkbox,
    label = "@ui_profanity_filter",
    dataPath = "Hud.LocalPlayer.Options.Accessibility.ChatProfanityFilter",
    callbackFn = self.OnProfanityChanged,
    tooltip = "@ui_profanity_filter_desc"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Checkbox,
    label = "@ui_chat_enable_alerts",
    dataPath = "Hud.LocalPlayer.Options.Chat.ChatEnableAlerts",
    tooltip = "@ui_chat_enable_alerts_tooltip"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Checkbox,
    label = "@ui_chat_enable_close_after_send",
    dataPath = "Hud.LocalPlayer.Options.Chat.ChatCloseAfterSending",
    tooltip = "@ui_chat_enable_close_after_send_tooltip"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Checkbox,
    label = "@ui_chat_enable_always_show_time",
    dataPath = "Hud.LocalPlayer.Options.Chat.ChatAlwaysShowTimestamps"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Checkbox,
    label = "@ui_chat_enable_color_messages",
    dataPath = "Hud.LocalPlayer.Options.Chat.ChatColorMessageToChannel"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Keybind,
    label = "@ui_emote",
    keybindMapping = "toggleEmoteWindow"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Keybind,
    label = "@ui_pushtotalkkey",
    keybindMapping = "toggleMicrophoneOn"
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Button,
    label = "@ui_voicechatsettings",
    buttonText = "@ui_openvoicechatsettings",
    callback = function()
      local isDead = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Vitals.IsDead")
      if isDead then
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = "@ui_unavailable_while_dead"
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        return
      end
      LyShineManagerBus.Broadcast.SetState(3766762380)
      LyShineManagerBus.Broadcast.SetState(3493198471)
      DynamicBus.Options.Broadcast.OpenCommsScreen()
    end
  })
  table.insert(chatOptions, {
    type = chatOptionTypes.Button,
    label = "@ui_reset",
    buttonText = "@ui_restore_defaults",
    callback = function()
      local popupId = "resetChatDisplaySettings"
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_reset", "@ui_reset_chat_display_settings_warning", popupId, self, function(self, result, eventId)
        if eventId == popupId and result == ePopupResult_Yes then
          OptionsDataBus.Broadcast.ResetChatSettings()
        end
      end)
    end
  })
  self.chatOptions = chatOptions
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.clonedElements = {}
  local totalHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.OptionsList)
  for _, optionData in ipairs(chatOptions) do
    local clonedElement
    if optionData.type == chatOptionTypes.Slider then
      clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.SliderPrototype, self.Properties.OptionsList, true)
      do
        local slider = UiElementBus.Event.FindChildByName(clonedElement, "SliderWithTextInput")
        slider = self.registrar:GetEntityTable(slider)
        slider:HideCrownIcons()
        slider:SetTextInputWidth(self.sliderInputWidth)
        slider:SizeChildrenToSelf()
        slider:SetSliderMinValue(optionData.minValue)
        slider:SetSliderMaxValue(optionData.maxValue)
        slider:SetInputMaxDigits(3)
        self.dataLayer:RegisterAndExecuteDataObserver(self, optionData.dataPath, function(self, value)
          if value == nil then
            return
          end
          if tonumber(slider:GetSliderValue()) ~= tonumber(value) then
            slider:SetSliderValue(value)
          end
        end)
        slider:SetCallback(function(self, sliderTable)
          local sliderValue = slider:GetSliderValue()
          LyShineDataLayerBus.Broadcast.SetData(optionData.dataPath, sliderValue)
          local event = UiAnalyticsEvent("Chat_AccessibilityChange")
          event:AddAttribute("Label", optionData.label)
          event:AddAttribute("Value", tostring(sliderValue))
          event:Send()
        end, self)
      end
    elseif optionData.type == chatOptionTypes.Checkbox then
      clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.CheckboxPrototype, self.Properties.OptionsList, true)
      do
        local checkBox = UiElementBus.Event.FindChildByName(clonedElement, "Checkbox")
        checkBox = self.registrar:GetEntityTable(checkBox)
        checkBox:SetText(nil)
        self.dataLayer:RegisterAndExecuteDataObserver(self, optionData.dataPath, function(self, value)
          if optionData.onChangeFn then
            optionData.onChangeFn(self, value, checkBox)
          else
            checkBox:SetState(value == true)
          end
        end)
        if optionData.callbackFn then
          checkBox:SetCallback(self, optionData.callbackFn)
        else
          checkBox:SetCallback(self, function(self, isEnabled)
            LyShineDataLayerBus.Broadcast.SetData(optionData.dataPath, isEnabled == true)
            local event = UiAnalyticsEvent("Chat_AccessibilityChange")
            event:AddAttribute("Label", optionData.label)
            event:AddAttribute("Value", tostring(isEnabled))
            event:Send()
          end)
        end
      end
    elseif optionData.type == chatOptionTypes.Button then
      clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.ButtonPrototype, self.Properties.OptionsList, true)
      local button = UiElementBus.Event.FindChildByName(clonedElement, "ButtonSimple")
      button = self.registrar:GetEntityTable(button)
      button:SetText(optionData.buttonText)
      button:SetCallback(optionData.callback, self)
    elseif optionData.type == chatOptionTypes.Radio then
      clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.RadioButtonsPrototype, self.Properties.OptionsList, true)
      optionData.element = clonedElement
      do
        local radioButtonGroup = UiElementBus.Event.FindChildByName(clonedElement, "RadioButtons")
        local radioButtons = UiElementBus.Event.GetChildren(radioButtonGroup)
        for i = 1, #radioButtons do
          local button = self.registrar:GetEntityTable(radioButtons[i])
          button:AddToGroup(radioButtonGroup)
        end
        self.dataLayer:RegisterAndExecuteDataObserver(self, optionData.dataPath, function(self, channelState)
          if channelState then
            channelState = channelState + 1
            if not (0 < channelState) or not (channelState <= #radioButtons) then
              channelState = 1
            end
            UiRadioButtonGroupBus.Event.SetState(radioButtonGroup, radioButtons[channelState], true)
            local event = UiAnalyticsEvent("Chat_AccessibilityChange")
            event:AddAttribute("Label", optionData.label)
            event:AddAttribute("Value", tostring(optionData.metricsOptionsLabels[channelState]))
            event:Send()
          end
        end)
      end
    elseif optionData.type == chatOptionTypes.Keybind then
      clonedElement = CloneUiElement(self.canvasId, self.registrar, self.Properties.KeybindPrototype, self.Properties.OptionsList, true)
      local hint = UiElementBus.Event.FindDescendantByName(clonedElement, "Hint")
      hint = self.registrar:GetEntityTable(hint)
      hint:SetKeybindMapping(optionData.keybindMapping)
    end
    local labelEntity = UiElementBus.Event.FindChildByName(clonedElement, "Label")
    UiTextBus.Event.SetTextWithFlags(labelEntity, optionData.label, eUiTextSet_SetLocalized)
    if optionData.tooltip then
      local questionMarkEntityId = UiElementBus.Event.FindDescendantByName(clonedElement, "QuestionMark")
      if questionMarkEntityId then
        UiElementBus.Event.SetIsEnabled(questionMarkEntityId, true)
        local questionMark = self.registrar:GetEntityTable(questionMarkEntityId)
        questionMark:SetTooltip(optionData.tooltip)
        questionMark:SetButtonStyle(questionMark.BUTTON_STYLE_QUESTION_MARK)
        questionMark:SetSize(18)
      end
    end
    table.insert(self.clonedElements, clonedElement)
    local clonedElementHeight = UiLayoutCellBus.Event.GetTargetHeight(clonedElement)
    totalHeight = totalHeight + clonedElementHeight
  end
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, totalHeight)
end
function Chat_DisplaySettings:OnShutdown()
  if self.clonedElements then
    for _, elementId in ipairs(self.clonedElements) do
      UiElementBus.Event.DestroyElement(elementId)
    end
  end
end
function Chat_DisplaySettings:OnProfanityChanged(isEnabled)
  if isEnabled then
    DynamicBus.Options.Broadcast.EnableChatProfanityFilter()
  else
    DynamicBus.Options.Broadcast.DisableChatProfanityFilter()
  end
  local event = UiAnalyticsEvent("Chat_AccessibilityChange")
  event:AddAttribute("Label", "ProfanityFilter")
  event:AddAttribute("Value", tostring(isEnabled))
  event:Send()
end
function Chat_DisplaySettings:OnCompactViewChanged(isEnabled)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Options.Chat.ChatUseCompactView", isEnabled and 2 or 0)
  local event = UiAnalyticsEvent("Chat_AccessibilityChange")
  event:AddAttribute("Label", "CompactViewChanged")
  event:AddAttribute("Value", tostring(isEnabled))
  event:Send()
end
function Chat_DisplaySettings:OnRadioButtonChanged(radioGroupEntityId)
  for _, optionData in ipairs(self.chatOptions) do
    if optionData.radioOptions then
      local radioButtons = UiElementBus.Event.FindChildByName(optionData.element, "RadioButtons")
      if radioButtons == radioGroupEntityId then
        local checkedButtonId = UiRadioButtonGroupBus.Event.GetState(radioGroupEntityId)
        local radioButtonIndex = UiElementBus.Event.GetIndexOfChildByEntityId(radioGroupEntityId, checkedButtonId)
        local selectedOption = optionData.radioOptions[radioButtonIndex + 1]
        LyShineDataLayerBus.Broadcast.SetData(optionData.dataPath, selectedOption)
        break
      end
    end
  end
end
return Chat_DisplaySettings
