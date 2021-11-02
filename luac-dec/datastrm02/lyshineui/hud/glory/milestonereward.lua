local MilestoneReward = {
  Properties = {
    Background = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    IconBg = {
      default = EntityId()
    },
    TextBg = {
      default = EntityId()
    },
    NameText = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  },
  DISPLAY_STATE_UNLOCKED = 0,
  DISPLAY_STATE_LOCKED = 1,
  DISPLAY_STATE_NEXT = 2
}
local BaseElement = RequireScript("LyshineUI._Common.BaseElement")
BaseElement:CreateNewElement(MilestoneReward)
function MilestoneReward:OnInit()
  SetTextStyle(self.Properties.NameText, self.UIStyle.FONT_STYLE_MILESTONE_REWARD_NAME)
end
function MilestoneReward:SetRewardData(data)
  if data.image ~= "" and self.Properties.Background:IsValid() then
    UiImageBus.Event.SetSpritePathname(self.Properties.Background, data.image)
  end
  if data.icon ~= "" and self.Properties.Icon:IsValid() then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, data.icon)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.NameText, data.name, eUiTextSet_SetLocalized)
  if self.Properties.TextBg:IsValid() then
    local textHeight = UiTextBus.Event.GetTextSize(self.Properties.NameText).y
    textHeight = textHeight + 35
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.TextBg, textHeight)
  end
  if data.tooltip ~= "" then
    self.TooltipSetter:SetSimpleTooltip(data.tooltip)
  end
end
function MilestoneReward:SetDisplayState(state)
  if state == self.DISPLAY_STATE_UNLOCKED then
    if self.Properties.Background:IsValid() then
      UiDesaturatorBus.Event.SetSaturationValue(self.Properties.Background, 1)
      UiImageBus.Event.SetColor(self.Properties.Background, self.UIStyle.COLOR_WHITE)
    end
    if self.Properties.Icon:IsValid() then
      UiDesaturatorBus.Event.SetSaturationValue(self.Properties.Icon, 1)
      UiImageBus.Event.SetColor(self.Properties.Icon, self.UIStyle.COLOR_WHITE)
    end
    if self.Properties.IconBg:IsValid() then
      UiDesaturatorBus.Event.SetSaturationValue(self.Properties.IconBg, 1)
      UiImageBus.Event.SetColor(self.Properties.IconBg, self.UIStyle.COLOR_WHITE)
    end
    if self.Properties.NameText:IsValid() then
      UiTextBus.Event.SetColor(self.Properties.NameText, self.UIStyle.COLOR_WHITE)
    end
  else
    if self.Properties.Background:IsValid() then
      UiDesaturatorBus.Event.SetSaturationValue(self.Properties.Background, 0)
      UiImageBus.Event.SetColor(self.Properties.Background, self.UIStyle.COLOR_GRAY_70)
    end
    if self.Properties.Icon:IsValid() then
      UiDesaturatorBus.Event.SetSaturationValue(self.Properties.Icon, 0)
      UiImageBus.Event.SetColor(self.Properties.Icon, self.UIStyle.COLOR_GRAY_50)
    end
    if self.Properties.IconBg:IsValid() then
      UiDesaturatorBus.Event.SetSaturationValue(self.Properties.IconBg, 0)
      UiImageBus.Event.SetColor(self.Properties.IconBg, self.UIStyle.COLOR_GRAY_50)
    end
    if self.Properties.NameText:IsValid() then
      UiTextBus.Event.SetColor(self.Properties.NameText, self.UIStyle.COLOR_GRAY_80)
    end
  end
end
return MilestoneReward
