local CharacterCreateButton = {
  Properties = {
    CharacterName = {
      default = EntityId()
    },
    GuildCrestForeground = {
      default = EntityId()
    },
    GuildCrestBackground = {
      default = EntityId()
    },
    CreateButton = {
      default = EntityId()
    },
    DeleteButton = {
      default = EntityId()
    },
    CharacterInfoHolder = {
      default = EntityId()
    },
    CharacterEmptyHolder = {
      default = EntityId()
    },
    CharacterEmptyText = {
      default = EntityId()
    },
    LevelText = {
      default = EntityId()
    },
    WorldInfo = {
      default = EntityId()
    },
    MergeTime = {
      default = EntityId()
    },
    WorldMessageHintIcon = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    },
    Lock = {
      default = EntityId()
    },
    MoreInfoBg = {
      default = EntityId()
    },
    MoreInfoTooltip = {
      default = EntityId()
    },
    ListItemBg = {
      default = EntityId()
    }
  },
  createCharacterCallback = nil,
  createCharacterTable = nil,
  changeCharacterCallback = nil,
  changeCharacterTable = nil,
  CHARSTATUS_ACTIVE = 0,
  CHARSTATUS_CANCREATE = 1,
  CHARSTATUS_INACTIVE = 2,
  CHARSTATUS_LOCKED = 3,
  CHARSTATUS_PURCHASE_LOCKED = 4,
  isDeleteButtonShowing = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CharacterCreateButton)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function CharacterCreateButton:OnInit()
  BaseElement.OnInit(self)
  self.MoreInfoTooltip:SetSimpleTooltip("@ui_character_options")
end
function CharacterCreateButton:SetCreateCharacterCallback(command, table)
  self.createCharacterCallback = command
  self.createCharacterTable = table
end
function CharacterCreateButton:SetChangeCharacterCallback(command, table)
  self.changeCharacterCallback = command
  self.changeCharacterTable = table
end
function CharacterCreateButton:SetDeleteCharacterCallback(command, table)
  if self.Properties.DeleteButton:IsValid() then
    self.DeleteButton:SetText("@ui_deletecharacter")
    self.DeleteButton:SetCallback(command, table)
  end
end
function CharacterCreateButton:SetDeleteButtonVisible(isVisible)
  self.isDeleteButtonShowing = isVisible
  self.ScriptedEntityTweener:Stop(self.Properties.DeleteButton)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.DeleteButton, true)
    self.ScriptedEntityTweener:Play(self.Properties.DeleteButton, 0.3, {opacity = 1, ease = "QuadOut"})
    self:OnChangeCharacter()
  else
    self.ScriptedEntityTweener:Play(self.Properties.DeleteButton, 0.3, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Properties.DeleteButton, false)
      end
    })
  end
end
function CharacterCreateButton:ToggleDeleteButton()
  self.isDeleteButtonShowing = not self.isDeleteButtonShowing
  self:SetDeleteButtonVisible(self.isDeleteButtonShowing)
end
function CharacterCreateButton:SetText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.CharacterEmptyText, value, eUiTextSet_SetLocalized)
end
function CharacterCreateButton:SetSlotStatus(characterSlotStatus)
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterInfoHolder, characterSlotStatus == self.CHARSTATUS_ACTIVE or characterSlotStatus == self.CHARSTATUS_LOCKED)
  UiElementBus.Event.SetIsEnabled(self.Properties.CreateButton, characterSlotStatus == self.CHARSTATUS_CANCREATE)
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterEmptyHolder, characterSlotStatus == self.CHARSTATUS_CANCREATE or characterSlotStatus == self.CHARSTATUS_PURCHASE_LOCKED)
  UiElementBus.Event.SetIsEnabled(self.Properties.Lock, characterSlotStatus == self.CHARSTATUS_LOCKED or characterSlotStatus == self.CHARSTATUS_PURCHASE_LOCKED)
  self:OnUnselected()
end
function CharacterCreateButton:SetCharacterInfo(characterName, characterID, level)
  UiTextBus.Event.SetText(self.Properties.CharacterName, tostring(characterName))
  if self.Properties.LevelText:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelText, level ~= nil)
    if level ~= nil then
      UiTextBus.Event.SetText(self.Properties.LevelText, tostring(level + 1))
    end
  end
end
function CharacterCreateButton:SetWorldMessageTooltip(worldMessage)
  local hasWorldMessage = worldMessage ~= nil and worldMessage ~= ""
  UiElementBus.Event.SetIsEnabled(self.Properties.WorldMessageHintIcon, hasWorldMessage)
  if hasWorldMessage then
    self.TooltipSetter:SetSimpleTooltip(worldMessage)
  end
  local deleteButtonPosX = hasWorldMessage and 290 or 240
  self.ScriptedEntityTweener:Set(self.Properties.DeleteButton, {x = deleteButtonPosX})
end
function CharacterCreateButton:SetWorldInfoText(worldInfo)
  UiTextBus.Event.SetText(self.Properties.WorldInfo, tostring(worldInfo))
end
function CharacterCreateButton:SetMergeTime(mergeTimeSeconds)
  if not self.Properties.MergeTime:IsValid() then
    return
  end
  self:SetMergeTimeVisible(false)
  timingUtils:Delay(1, self, function(self)
    self:SetMergeTimeVisible(true)
    local now = os.time()
    local timeRemainingSeconds = mergeTimeSeconds - now
    local timeUntilMergeText = "..."
    if 0 < timeRemainingSeconds then
      timeUntilMergeText = timeHelpers:ConvertToShorthandString(timeRemainingSeconds, false)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.MergeTime, timeUntilMergeText, eUiTextSet_SetLocalized)
    if timeRemainingSeconds <= 0 then
      timingUtils:StopDelay(self)
    end
  end, true)
end
function CharacterCreateButton:SetMergeTimeVisible(isVisible)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.MergeTime, true)
    self.ScriptedEntityTweener:Set(self.Properties.CharacterName, {y = -3})
    self.ScriptedEntityTweener:Set(self.Properties.WorldInfo, {y = 22})
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.MergeTime, false)
    self.ScriptedEntityTweener:Set(self.Properties.CharacterName, {y = 7})
    self.ScriptedEntityTweener:Set(self.Properties.WorldInfo, {y = 32})
  end
end
function CharacterCreateButton:SetGuildCrest(crestData, useSmallImages)
  local crestValid = crestData and crestData:IsValid()
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestBackground, crestValid)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestForeground, crestValid)
  if crestValid then
    if self.Properties.GuildCrestBackground:IsValid() and #crestData.backgroundImagePath > 0 then
      local imagePath = crestData.backgroundImagePath
      if useSmallImages then
        imagePath = GetSmallImagePath(crestData.backgroundImagePath)
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.GuildCrestBackground, imagePath)
      UiImageBus.Event.SetColor(self.Properties.GuildCrestBackground, crestData.backgroundColor)
    end
    if self.Properties.GuildCrestForeground:IsValid() and 0 < #crestData.foregroundImagePath then
      local imagePath = crestData.foregroundImagePath
      if useSmallImages then
        imagePath = GetSmallImagePath(crestData.foregroundImagePath)
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.GuildCrestForeground, imagePath)
      UiImageBus.Event.SetColor(self.Properties.GuildCrestForeground, crestData.foregroundColor)
    end
  end
end
function CharacterCreateButton:OnFocus()
  self.ListItemBg:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnSelectCharacterHover)
end
function CharacterCreateButton:OnUnfocus()
  local isSelectedState = UiRadioButtonBus.Event.GetState(self.Properties.CharacterInfoHolder)
  if isSelectedState == true then
    self:OnSelected()
  else
    self:OnUnselected()
  end
end
function CharacterCreateButton:OnMoreInfoFocus()
  self.ScriptedEntityTweener:Play(self.Properties.MoreInfoBg, 0.3, {opacity = 0.3, ease = "QuadOut"})
  self.MoreInfoTooltip:OnTooltipSetterHoverStart()
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ButtonSimpleText)
end
function CharacterCreateButton:OnMoreInfoUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.MoreInfoBg, 0.3, {opacity = 0.1, ease = "QuadOut"})
  self.MoreInfoTooltip:OnTooltipSetterHoverEnd()
end
function CharacterCreateButton:OnSelected()
  self.ListItemBg:OnFocus()
end
function CharacterCreateButton:OnUnselected()
  self:SetDeleteButtonVisible(false)
  self.ListItemBg:OnUnfocus()
end
function CharacterCreateButton:OnPress()
  if type(self.createCharacterCallback) == "function" and self.createCharacterTable ~= nil then
    self.createCharacterCallback(self.createCharacterTable, self)
  end
end
function CharacterCreateButton:OnChangeCharacter()
  if type(self.changeCharacterCallback) == "function" and self.changeCharacterTable ~= nil then
    self.changeCharacterCallback(self.changeCharacterTable, self)
  end
end
return CharacterCreateButton
