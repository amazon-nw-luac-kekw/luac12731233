local CharacterInfoCard = {
  Properties = {
    CharacterButton = {
      default = EntityId()
    },
    CharacterName = {
      default = EntityId()
    },
    CharacterNameSelected = {
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
    InactiveSlot = {
      default = EntityId()
    },
    PortraitForeground = {
      default = EntityId()
    },
    PortraitMidground = {
      default = EntityId()
    },
    PortraitBackground = {
      default = EntityId()
    },
    LastPlayedLabel = {
      default = EntityId()
    },
    LastPlayedText = {
      default = EntityId()
    },
    LevelText = {
      default = EntityId()
    },
    ButtonFrame = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonGlow = {
      default = EntityId()
    },
    WorldInfo = {
      default = EntityId()
    },
    RegionText = {
      default = EntityId()
    },
    MergeTime = {
      default = EntityId()
    },
    HasWorldMessageHint = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    },
    Lock = {
      default = EntityId()
    }
  },
  CHARSTATUS_ACTIVE = 0,
  CHARSTATUS_CANCREATE = 1,
  CHARSTATUS_INACTIVE = 2,
  CHARSTATUS_LOCKED = 3
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CharacterInfoCard)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function CharacterInfoCard:OnInit()
  BaseElement.OnInit(self)
  UiTextBus.Event.SetColor(self.CharacterNameSelected, self.UIStyle.COLOR_TAN)
  UiTextBus.Event.SetColor(self.LastPlayedText, self.UIStyle.COLOR_TAN)
end
function CharacterInfoCard:SetSlotStatus(characterSlotStatus)
  UiElementBus.Event.SetIsEnabled(self.Properties.CharacterButton, characterSlotStatus == self.CHARSTATUS_ACTIVE or characterSlotStatus == self.CHARSTATUS_LOCKED)
  if self.Properties.CreateButton:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.CreateButton, characterSlotStatus == self.CHARSTATUS_CANCREATE)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.InactiveSlot, characterSlotStatus == self.CHARSTATUS_INACTIVE)
  UiElementBus.Event.SetIsEnabled(self.Properties.Lock, characterSlotStatus == self.CHARSTATUS_LOCKED)
end
function CharacterInfoCard:SetCharacterInfo(characterName, characterID, level)
  UiTextBus.Event.SetText(self.Properties.CharacterName, tostring(characterName))
  if self.Properties.CharacterNameSelected:IsValid() then
    UiTextBus.Event.SetText(self.Properties.CharacterNameSelected, tostring(characterName))
  end
  if self.Properties.LevelText:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelText, level ~= nil)
    if level ~= nil then
      UiTextBus.Event.SetText(self.Properties.LevelText, tostring(level + 1))
    end
  end
end
function CharacterInfoCard:SetWorldMessageTooltip(worldMessage)
  local hasWorldMessage = worldMessage ~= nil and worldMessage ~= ""
  UiElementBus.Event.SetIsEnabled(self.Properties.HasWorldMessageHint, hasWorldMessage)
  if hasWorldMessage and self.Properties.TooltipSetter:IsValid() then
    self.TooltipSetter:SetSimpleTooltip(worldMessage)
  end
end
function CharacterInfoCard:SetWorldInfoText(worldInfo)
  UiTextBus.Event.SetText(self.Properties.WorldInfo, tostring(worldInfo))
end
function CharacterInfoCard:SetRegionText(region)
  UiTextBus.Event.SetText(self.Properties.RegionText, tostring(region))
end
function CharacterInfoCard:SetMergeTime(mergeTimeSeconds)
  if not self.Properties.MergeTime:IsValid() then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.MergeTime, false)
  timingUtils:Delay(1, self, function(self)
    UiElementBus.Event.SetIsEnabled(self.Properties.MergeTime, true)
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
function CharacterInfoCard:SetCharacterNameColor(value)
  UiTextBus.Event.SetColor(self.Properties.CharacterName, value)
  UiTextBus.Event.SetColor(self.Properties.CharacterNameSelected, value)
end
function CharacterInfoCard:SetGuildCrest(crestData, useSmallImages)
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
function CharacterInfoCard:SetPortrait(portraitData)
  if self.Properties.PortraitBackground:IsValid() then
    UiImageBus.Event.SetSpritePathname(self.Properties.PortraitBackground, portraitData.backgroundImagePath)
  end
  if self.Properties.PortraitMidground:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.PortraitMidground, #portraitData.midgroundImagePath > 0)
    UiImageBus.Event.SetSpritePathname(self.Properties.PortraitMidground, portraitData.midgroundImagePath)
  end
  if self.Properties.PortraitForeground:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.PortraitForeground, 0 < #portraitData.foregroundImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.PortraitForeground, portraitData.foregroundImagePath)
  end
end
function CharacterInfoCard:SetLastPlayed(elapsedSeconds)
  if self.Properties.LastPlayedText:IsValid() then
    local timeText = "@ui_lastplayed: "
    if elapsedSeconds == nil or elapsedSeconds == 0 then
      timeText = timeText .. "-"
    else
      local timestring = timeHelpers:ConvertToLargestTimeEstimate(elapsedSeconds, true)
      timeText = timeText .. timestring
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.LastPlayedText, timeText, eUiTextSet_SetLocalized)
  end
end
function CharacterInfoCard:OnFocus()
  local animDuration = 0.15
  self.ScriptedEntityTweener:Play(self.CharacterNameSelected, animDuration, {
    textColor = self.UIStyle.COLOR_WHITE,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.LastPlayedText, animDuration, {
    textColor = self.UIStyle.COLOR_GRAY_80,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.ButtonFrame, animDuration, {opacity = 0.8, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration, {opacity = 1, ease = "QuadOut"})
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.ButtonGlow, 0.35, {opacity = 0.5})
    self.timeline:Add(self.ButtonGlow, 0.05, {opacity = 0.5})
    self.timeline:Add(self.ButtonGlow, 0.3, {
      opacity = 0.2,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.timeline:Play()
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnSelectCharacterHover)
end
function CharacterInfoCard:OnUnfocus()
  local isSelectedState = UiRadioButtonBus.Event.GetState(self.CharacterButton)
  if isSelectedState == true then
    local animDuration = 0.15
    self.ScriptedEntityTweener:Play(self.ButtonFrame, animDuration, {opacity = 0.8, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.ButtonGlow, animDuration, {opacity = 0.1})
  else
    self:OnUnselected()
  end
end
function CharacterInfoCard:OnSelected()
  local animDuration = 0.15
  self.ScriptedEntityTweener:Play(self.CharacterNameSelected, animDuration, {
    textColor = self.UIStyle.COLOR_WHITE,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.LastPlayedText, animDuration, {
    textColor = self.UIStyle.COLOR_GRAY_80,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.ButtonFrame, animDuration, {opacity = 0.8, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.ButtonGlow, animDuration, {opacity = 0.1, ease = "QuadIn"})
end
function CharacterInfoCard:OnUnselected()
  local animDuration = 0.15
  local serverMessageAlpha = self.isServerMessageVisible and self.textDisabledAlpha or 1
  self.ScriptedEntityTweener:Play(self.CharacterNameSelected, animDuration, {
    textColor = self.UIStyle.COLOR_TAN,
    opacity = serverMessageAlpha,
    ease = "QuadIn"
  })
  self.ScriptedEntityTweener:Play(self.LastPlayedText, animDuration, {
    textColor = self.UIStyle.COLOR_TAN,
    opacity = serverMessageAlpha,
    ease = "QuadIn"
  })
  self.ScriptedEntityTweener:Play(self.ButtonFrame, animDuration, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.ButtonFocus, animDuration, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.ButtonGlow, animDuration, {opacity = 0, ease = "QuadIn"})
end
function CharacterInfoCard:SetCreateCharacterCallback(callback, table)
  if self.Properties.CreateButton:IsValid() then
    self.CreateButton:SetText("@ui_createcharacter")
    self.CreateButton:SetCallback(callback, table)
    self.CreateButton:SetSoundOnFocus(self.audioHelper.FrontEnd_OnCreateCharacterHover)
    self.CreateButton:SetSoundOnPress(self.audioHelper.FrontEnd_OnCreateCharacterBeginPress)
  end
end
return CharacterInfoCard
