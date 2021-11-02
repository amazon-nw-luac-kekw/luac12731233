local RewardListItem = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    RewardValue = {
      default = EntityId()
    },
    RewardText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RewardListItem)
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function RewardListItem:OnInit()
  SetTextStyle(self.Properties.RewardText, self.UIStyle.STANDARD_BODY_TEXT_TAN)
  SetTextStyle(self.Properties.RewardValue, self.UIStyle.FONT_STYLE_OBJECTIVE_JOURNAL_REWARDS)
end
function RewardListItem:SetRewardType(type, stringReplacementTable, rewardTextOverride, iconPathOverride)
  local iconPath, iconColor, rewardText
  if stringReplacementTable == nil then
    stringReplacementTable = {}
  end
  if type == ObjectiveDataHelper.REWARD_TYPES.FACTION_REPUTATION then
    local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    iconPath = "lyshineui/images/icons/objectives/reward_factionreputation" .. playerFaction .. ".dds"
    iconColor = self.UIStyle.COLOR_WHITE
    rewardText = "@ui_factionreputation"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.CURRENCY then
    iconPath = "lyshineui/images/icons/objectives/reward_coin.dds"
    iconColor = self.UIStyle.COLOR_WHITE
    rewardText = "@ui_coin"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.XP then
    iconPath = "lyshineui/images/icons/objectives/reward_xp.dds"
    iconColor = self.UIStyle.COLOR_YELLOW_GOLD
    rewardText = "@ui_xp"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.COMMUNITY_POINTS then
    iconPath = "lyshineui/images/icons/objectives/reward_community.dds"
    iconColor = self.UIStyle.COLOR_YELLOW_MUTED
    rewardText = "@ui_projectpoints"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.TERRITORY_STANDING then
    iconPath = "lyshineui/images/icons/objectives/reward_territoryStanding.dds"
    iconColor = self.UIStyle.COLOR_WHITE
    rewardText = "@ui_territory_standinglabel"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.CATEGORICAL then
    iconPath = ""
    iconColor = self.UIStyle.COLOR_WHITE
    rewardText = ""
  elseif type == ObjectiveDataHelper.REWARD_TYPES.AZOTH then
    iconPath = "lyshineui/images/icon_azoth.dds"
    iconColor = self.UIStyle.COLOR_WHITE
    rewardText = "@ui_azoth_currency"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.FACTION_INFLUENCE then
    local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    iconPath = FactionCommon.factionInfoTable[playerFaction].crestFgSmall
    iconColor = FactionCommon.factionInfoTable[playerFaction].crestBgColor
    rewardText = "@ui_factioninfluence"
    stringReplacementTable.faction = FactionCommon.factionInfoTable[playerFaction].factionName
  elseif type == ObjectiveDataHelper.REWARD_TYPES.FACTION_TOKENS then
    local playerFaction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    iconPath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(playerFaction) .. ".dds"
    iconColor = self.UIStyle.COLOR_WHITE
    rewardText = "@ui_factioncurrency"
  else
    Debug.Log("[WARNING] RewardListItem given unexpected reward type of " .. tostring(type))
    iconPath = "ERROR"
    iconColor = self.UIStyle.COLOR_WHITE
  end
  if rewardTextOverride then
    rewardText = rewardTextOverride
  end
  if iconPathOverride then
    iconPath = iconPathOverride
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconPath)
  UiImageBus.Event.SetColor(self.Properties.Icon, iconColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardText, rewardText ~= nil)
  if rewardText ~= nil then
    local localizedRewardText = GetLocalizedReplacementText(rewardText, stringReplacementTable)
    UiTextBus.Event.SetText(self.Properties.RewardText, localizedRewardText)
  end
end
function RewardListItem:SetRewardValue(value)
  if type(value) == "number" then
    value = GetLocalizedNumber(value)
  end
  UiTextBus.Event.SetText(self.Properties.RewardValue, tostring(value))
end
return RewardListItem
