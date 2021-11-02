local MetaAchievementRewardItem = {
  Properties = {
    RewardIcon = {
      default = EntityId()
    },
    RewardType = {
      default = EntityId()
    },
    RewardTitle = {
      default = EntityId()
    },
    AchievementIcon = {
      default = EntityId()
    },
    AchievementIconBorder = {
      default = EntityId()
    },
    AchievementTitle = {
      default = EntityId()
    },
    AchievementDesc = {
      default = EntityId()
    }
  },
  iconPathPattern = "LyShineUI/Images/%s.dds"
}
local TitleSection = RequireScript("LyShineUI.Skills.TitleSection")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MetaAchievementRewardItem)
function MetaAchievementRewardItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.RewardType, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_SUMMARY_HEADING)
  SetTextStyle(self.Properties.RewardTitle, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_REWARDS_TITLE)
  SetTextStyle(self.Properties.AchievementTitle, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_ITEM_TITLE)
  SetTextStyle(self.Properties.AchievementDesc, self.UIStyle.STANDARD_BODY_TEXT_GREEN)
end
function MetaAchievementRewardItem:SetData(data, titleId)
  local itemData = data.itemData
  if titleId ~= 0 then
    local rewardIconPath = string.format(self.iconPathPattern, "Entitlements/NewTitleIcon")
    UiImageBus.Event.SetSpritePathname(self.Properties.RewardIcon, rewardIconPath)
    UiTextBus.Event.SetTextWithFlags(self.Properties.RewardType, "@ui_meta_achievements_reward_type_title", eUiTextSet_SetLocalized)
    local currentPronounType = JavSocialComponentBus.Broadcast.GetTitlePronounType()
    local titleData = JavSocialComponentBus.Broadcast.GetTitleData(titleId)
    local genderedTitle = TitleSection:GetGenderedTitleString(currentPronounType, titleData)
    UiTextBus.Event.SetTextWithFlags(self.Properties.RewardTitle, genderedTitle, eUiTextSet_SetLocalized)
    local achievementIconPath = string.format(self.iconPathPattern, itemData.icon)
    UiImageBus.Event.SetSpritePathname(self.Properties.AchievementIcon, achievementIconPath)
    self.AchievementIconBorder:SetBorder(self.UIStyle.COLOR_GREEN_BRIGHT, 2)
    UiTextBus.Event.SetTextWithFlags(self.Properties.AchievementTitle, itemData.title, eUiTextSet_SetLocalized)
    local descriptionText = GetLocalizedReplacementText(itemData.description, {
      number = GetLocalizedNumber(data.isDisplayOneIndexed and itemData.total + 1 or itemData.total)
    })
    UiTextBus.Event.SetText(self.Properties.AchievementDesc, descriptionText)
  end
  local titlesize = UiTextBus.Event.GetTextHeight(self.Properties.RewardTitle)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.RewardTitle, titlesize)
end
return MetaAchievementRewardItem
