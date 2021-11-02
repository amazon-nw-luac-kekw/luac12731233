local RewardLayout = {
  Properties = {
    IsMiniLayout = {default = false},
    ContentContainer = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    NumberText = {
      default = EntityId()
    },
    LabelText = {
      default = EntityId()
    },
    Flash = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(RewardLayout)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function RewardLayout:OnInit()
  self.numberTextWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.NumberText)
  self.iconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Icon)
  if self.Properties.IsMiniLayout then
    SetTextStyle(self.Properties.NumberText, self.UIStyle.FONT_STYLE_NUMBER_SMALL)
  end
end
function RewardLayout:SetRewardType(type, labelOverride, iconPathoverride)
  local iconPath, iconColor
  local label = ""
  if type == ObjectiveDataHelper.REWARD_TYPES.FACTION_REPUTATION then
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    iconPath = "lyshineui/images/icons/objectives/reward_factionreputation" .. faction .. ".dds"
    iconColor = self.UIStyle.COLOR_WHITE
    label = GetLocalizedReplacementText("@ui_factionreputation", {
      faction = FactionCommon.factionInfoTable[faction].factionName
    })
  elseif type == ObjectiveDataHelper.REWARD_TYPES.CURRENCY then
    iconPath = "lyshineui/images/icons/objectives/reward_coin.dds"
    iconColor = self.UIStyle.COLOR_WHITE
    label = "@ui_currency"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.XP then
    iconPath = "lyshineui/images/icons/objectives/reward_xp.dds"
    iconColor = self.UIStyle.COLOR_YELLOW_GOLD
    label = "@ui_xp"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.COMMUNITY_POINTS then
    iconPath = "lyshineui/images/icons/objectives/reward_community.dds"
    iconColor = self.UIStyle.COLOR_YELLOW_MUTED
    label = "@ui_projectpoints"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.TERRITORY_STANDING then
    iconPath = "lyshineui/images/icons/objectives/reward_territoryStanding.dds"
    iconColor = self.UIStyle.COLOR_WHITE
    label = "@ui_territory_standing_short"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.CATEGORICAL then
    iconPath = ""
    iconColor = self.UIStyle.COLOR_WHITE
    label = ""
  elseif type == ObjectiveDataHelper.REWARD_TYPES.AZOTH then
    iconPath = "lyshineui/images/icon_azoth.dds"
    iconColor = self.UIStyle.COLOR_WHITE
    label = "@ui_azoth_currency"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.FACTION_INFLUENCE then
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    iconPath = "lyshineui/images/icons/objectives/reward_factionreputation" .. tostring(faction) .. ".dds"
    iconColor = self.UIStyle.COLOR_WHITE
    label = "@ui_faction_influence"
  elseif type == ObjectiveDataHelper.REWARD_TYPES.FACTION_TOKENS then
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    iconPath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(faction) .. ".dds"
    iconColor = self.UIStyle.COLOR_WHITE
    label = GetLocalizedReplacementText("@ui_factioncurrency", {
      faction = FactionCommon.factionInfoTable[faction].factionName
    })
  elseif type == "CustomText" then
    iconColor = self.UIStyle.COLOR_WHITE
  else
    Debug.Log("[WARNING] RewardLayout given unexpected reward type of " .. tostring(type))
    iconPath = "ERROR"
    iconColor = self.UIStyle.COLOR_WHITE
    label = "ERROR"
  end
  if labelOverride then
    label = labelOverride
  end
  if iconPathoverride then
    iconPath = iconPathoverride
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Icon, iconPath ~= nil)
  if iconPath then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconPath)
  end
  UiImageBus.Event.SetColor(self.Properties.Icon, iconColor)
  if self.Properties.LabelText:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.LabelText, label, eUiTextSet_SetLocalized)
  end
  if self.Properties.TooltipSetter:IsValid() then
    self.TooltipSetter:SetSimpleTooltip(label)
  end
end
function RewardLayout:SetRewardValue(value)
  if type(value) == "number" then
    value = GetLocalizedNumber(value)
  end
  UiTextBus.Event.SetText(self.Properties.NumberText, tostring(value))
end
function RewardLayout:SetRewardIcon(iconPath, iconColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.Icon, iconPath ~= nil)
  if iconPath then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconPath)
    if iconColor then
      UiImageBus.Event.SetColor(self.Properties.Icon, iconColor)
    end
  end
end
function RewardLayout:AnimateIn(delay)
  delay = delay or 0
  UiFaderBus.Event.SetFadeValue(self.Properties.ContentContainer, 0)
  self.ScriptedEntityTweener:PlayC(self.entityId, delay, tweenerCommon.fadeInQuadOut, nil, function()
    UiElementBus.Event.SetIsEnabled(self.Properties.Flash, true)
    self.ScriptedEntityTweener:Set(self.Properties.Flash, {scaleX = 0.05, scaleY = 1.5})
    self.ScriptedEntityTweener:PlayC(self.Properties.Flash, 0.25, tweenerCommon.rewardLayoutFlash1)
    self.ScriptedEntityTweener:PlayC(self.Properties.Flash, 0.1, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.Flash, 0.15, tweenerCommon.rewardLayoutFlash2, 0.1)
    self.ScriptedEntityTweener:PlayC(self.Properties.ContentContainer, 0.2, tweenerCommon.fadeInQuadOut, 0.1, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.Flash, false)
    end)
  end)
end
return RewardLayout
