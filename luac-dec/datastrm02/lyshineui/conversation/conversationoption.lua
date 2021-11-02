local ConversationOption = {
  Properties = {
    Button = {
      default = EntityId()
    },
    DifficultyText = {
      default = EntityId()
    },
    UseCtaStyle = {default = false}
  },
  callback = nil,
  callbackTable = nil,
  defaultButtonHeight = 0,
  factionIdToName = {
    "@ui_faction_name1",
    "@ui_faction_name2",
    "@ui_faction_name3"
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ConversationOption)
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives/ObjectiveTypeData")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local DifficultyColors = RequireScript("LyShineUI._Common.DifficultyColors")
function ConversationOption:OnInit()
  BaseElement.OnInit(self)
  self.targetHeight = UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
  self.defaultButtonHeight = self.targetHeight
  self:SetIsVisible(false)
  self.Button:SetButtonStyle(self.Button.BUTTON_STYLE_DIALOGUE)
  self.Button:SetCallback(self.OnPress, self)
  self.Button:SetAnimPositionDuration(0)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PlayerName", function(self, playerName)
    self.playerName = playerName
  end)
  if self.Properties.DifficultyText:IsValid() then
    local difficultyStyle = DeepClone(self.UIStyle.FONT_STYLE_SUBHEADER)
    difficultyStyle.fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR
    SetTextStyle(self.Properties.DifficultyText, difficultyStyle)
  end
end
function ConversationOption:GetFactionAlignmentLoc(factionType)
  local factionLoc = self.factionIdToName[factionType]
  factionLoc = factionLoc or "@ui_faction_unaligned"
  return factionLoc
end
function ConversationOption:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
end
function ConversationOption:SetupConversationOption(optionData, callback, callbackTable, typeOverride)
  self.callback = callback
  self.callbackTable = callbackTable
  if optionData then
    self.optionType = optionData.optionType
    self.optionId = optionData.dataId
    self.optionText = optionData.text
    local visualOptionType = typeOverride or optionData.optionType
    local interactEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.InteractEntityId")
    local npcFaction
    local rootEntityId = TransformBus.Event.GetRootId(interactEntityId)
    if rootEntityId then
      local npcData = NpcComponentRequestBus.Event.GetNpcData(rootEntityId)
      if npcData then
        npcFaction = npcData.GetNpcFactionAlignment(npcData.id)
      end
    end
    local factionLoc = self:GetFactionAlignmentLoc(self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction"))
    local factionName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(factionLoc)
    local buttonText = GetLocalizedReplacementText(optionData.text, {
      playerName = self.playerName,
      playerFaction = factionName,
      npcFaction = self:GetFactionAlignmentLoc(npcFaction)
    })
    self.Button:SetText(buttonText)
    local iconPath = "lyshineui/images/icons/misc/icon_dialogue.dds"
    local iconColor = self.UIStyle.COLOR_WHITE
    local textColor = self.UIStyle.COLOR_WHITE
    local _
    if visualOptionType == eConversationOptionType_ObjectiveDetails then
      iconPath, iconColor = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(ObjectiveInstanceId(optionData.dataId))
    elseif visualOptionType == eConversationOptionType_ChooseFaction then
      local factionStyleData = FactionCommon.factionInfoTable[npcFaction]
      iconPath = factionStyleData.crestFgSmall
      iconColor = factionStyleData.crestBgColor
      textColor = self.UIStyle.COLOR_WHITE
    elseif visualOptionType == eConversationOptionType_AcceptObjective then
      iconPath, iconColor, _, textColor = ObjectiveTypeData:GetObjectiveIconByObjectiveInstanceId(ObjectiveInstanceId(optionData.dataId))
      if optionData.optionType == eConversationOptionType_ContinueDialogue then
        textColor = self.UIStyle.COLOR_WHITE
      end
    elseif visualOptionType == eConversationOptionType_CompleteObjective then
      iconPath, iconColor, textColor = ObjectiveTypeData:GetObjectiveIconForCompletion()
      if optionData.optionType == eConversationOptionType_ContinueDialogue then
        textColor = self.UIStyle.COLOR_WHITE
      end
    elseif visualOptionType == eConversationOptionType_OpenFactionBoard then
      iconPath, iconColor, textColor = ObjectiveTypeData:GetObjectiveIconByType(eObjectiveType_Mission)
    elseif visualOptionType == eConversationOptionType_OpenCommunityBoard then
      iconPath, iconColor, textColor = ObjectiveTypeData:GetObjectiveIconByType(eObjectiveType_CommunityGoal)
    elseif visualOptionType == eConversationOptionType_OpenInn then
      iconPath = "lyshineui/images/icons/misc/icon_more.dds"
      iconColor = self.UIStyle.COLOR_SKYBLUE
      textColor = self.UIStyle.COLOR_SKYBLUE
    elseif visualOptionType == eConversationOptionType_RefreshConversation then
      iconPath = "lyshineui/images/icons/misc/icon_refresh.dds"
      iconColor = self.UIStyle.COLOR_GRAY_70
      textColor = self.UIStyle.COLOR_GRAY_70
    end
    self.Button:SetSecondaryIconPath(iconPath)
    self.Button:SetSecondaryIconColor(iconColor)
    self.Button:SetTextColor(textColor)
    local resizedButtonHeight = self.Button:GetHeight()
    if resizedButtonHeight > self.defaultButtonHeight then
      UiLayoutCellBus.Event.SetTargetHeight(self.entityId, resizedButtonHeight)
    else
      UiLayoutCellBus.Event.SetTargetHeight(self.entityId, self.defaultButtonHeight)
    end
  end
  self:SetIsVisible(optionData ~= nil)
end
function ConversationOption:SetIndex(index, skipUpdateHint)
  local prefixString
  if index then
    prefixString = tostring(index) .. "."
  end
  self.Button:SetTextPrefix(prefixString)
  if not skipUpdateHint then
    if index == 1 then
      self.Button:SetHint("ui_interact", true, "ui")
    else
      self.Button:SetHint(nil)
    end
  end
end
function ConversationOption:SetHint(hintText, isKeybindName, actionMap)
  self.Button:SetHint(hintText, isKeybindName, actionMap)
end
function ConversationOption:SetIconPath(iconPath)
  self.Button:SetSecondaryIconPath(iconPath)
end
function ConversationOption:SetIconColor(iconColor)
  self.Button:SetSecondaryIconColor(iconColor)
end
function ConversationOption:SetDifficultyLevel(difficultyLevel)
  if self.Properties.DifficultyText:IsValid() then
    local hasDifficulty = difficultyLevel ~= nil and tonumber(difficultyLevel) > 0
    UiElementBus.Event.SetIsEnabled(self.Properties.DifficultyText, hasDifficulty)
    if hasDifficulty then
      local difficultyColor = DifficultyColors:GetColor(difficultyLevel)
      local difficultyString = GetLocalizedReplacementText("@objective_recommendedlevellong", {level = difficultyLevel})
      UiTextBus.Event.SetText(self.Properties.DifficultyText, difficultyString)
      UiTextBus.Event.SetColor(self.Properties.DifficultyText, difficultyColor)
    end
  end
end
function ConversationOption:SetIsVisible(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  UiElementBus.Event.SetIsEnabled(self.entityId, self.isVisible)
  if isVisible then
    self.ScriptedEntityTweener:Set(self.entityId, {opacity = 0})
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.15, tweenerCommon.fadeInQuadOut)
  end
end
function ConversationOption:OnPress()
  if self.callbackTable and type(self.callback) == "function" then
    self.callback(self.callbackTable, self.optionType, self.optionId)
  end
end
return ConversationOption
