local TradeSkills_DetailPanel = {
  Properties = {
    LevelCircle = {
      default = EntityId()
    },
    ExperienceText = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    MidLine = {
      default = EntityId()
    },
    DescriptionContainer = {
      default = EntityId()
    },
    DescriptionLabel = {
      default = EntityId()
    },
    DescriptionRangeLayout = {
      default = EntityId()
    },
    DescriptionValue1Bg = {
      default = EntityId()
    },
    DescriptionValue1Text = {
      default = EntityId()
    },
    DescriptionValue2Bg = {
      default = EntityId()
    },
    DescriptionValue2Text = {
      default = EntityId()
    },
    DescriptionSeparator = {
      default = EntityId()
    },
    DescriptionTableLayout = {
      default = EntityId()
    },
    GearScoreBonuses = {
      default = {
        EntityId()
      }
    },
    RequiresContainer = {
      default = EntityId()
    },
    RequiresLabel = {
      default = EntityId()
    },
    Requires1Icon = {
      default = EntityId()
    },
    Requires1Text = {
      default = EntityId()
    },
    Requires2Icon = {
      default = EntityId()
    },
    Requires2Text = {
      default = EntityId()
    }
  },
  descriptionValueOffset = 56,
  requirementOffset = 96,
  largeIconSize = 192,
  smallIconSize = 112
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TradeSkills_DetailPanel)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function TradeSkills_DetailPanel:OnInit()
  BaseElement.OnInit(self)
  self.skillsToHideDescription = {
    "@ui_woodworking",
    "@ui_leatherworking",
    "@ui_weaving",
    "@ui_stonecutting",
    "@ui_smelting",
    "@ui_furnishing",
    "@ui_cooking"
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    if not setLang then
      return
    end
    for i = 0, #self.Properties.GearScoreBonuses do
      local labelEntity = UiElementBus.Event.FindChildByName(self.Properties.GearScoreBonuses[i], "Label")
      local labelText = GetLocalizedReplacementText("@crafting_tierlabel", {
        tierLevel = " <font face=\"lyshineui/fonts/Pica_Italic.font\">" .. GetRomanFromNumber(i + 1) .. "</font>"
      })
      UiTextBus.Event.SetText(labelEntity, labelText)
    end
  end)
end
function TradeSkills_DetailPanel:OnSetDetailPanel(levelData, title, icon)
  self.LevelCircle:SetLevel(levelData.currentLevel)
  self.LevelCircle:SetProgress(levelData.progressPercent)
  self.LevelCircle:SetIcon(icon)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, title, eUiTextSet_SetLocalized)
  self.isHidingDescription = IsInsideTable(self.skillsToHideDescription, title)
  UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionContainer, not self.isHidingDescription)
  if levelData.currentLevel < levelData.maxRank then
    local pointsText = GetLocalizedReplacementText("@ui_points_to_level", {
      points = levelData.nextLevelXp - levelData.currentXp,
      level = levelData.currentLevel + 1
    })
    UiTextBus.Event.SetText(self.Properties.ExperienceText, pointsText)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.ExperienceText, "@ui_tradeskill_mastered", eUiTextSet_SetLocalized)
  end
  self.MidLine:SetVisible(false, 0)
  self.MidLine:SetVisible(true, 0.7, {delay = 0.3})
end
function TradeSkills_DetailPanel:SetGearScoreBonuses(descriptionLabelText, tierData)
  if self.isHidingDescription then
    return
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionLabel, descriptionLabelText, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionRangeLayout, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionTableLayout, true)
  for i = 1, #tierData do
    local value1Text = UiElementBus.Event.FindChildByName(self.Properties.GearScoreBonuses[i - 1], "Value1")
    UiTextBus.Event.SetTextWithFlags(value1Text, tierData[i].minValue, eUiTextSet_SetAsIs)
    local value2Text = UiElementBus.Event.FindChildByName(self.Properties.GearScoreBonuses[i - 1], "Value2")
    UiTextBus.Event.SetTextWithFlags(value2Text, tierData[i].maxValue, eUiTextSet_SetAsIs)
  end
end
function TradeSkills_DetailPanel:SetDescription(descriptionLabelText, value1, value2)
  if self.isHidingDescription then
    return
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionLabel, descriptionLabelText, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionValue1Text, value1, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionRangeLayout, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionTableLayout, false)
  if value2 ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionSeparator, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionValue2Bg, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionValue2Text, value2, eUiTextSet_SetLocalized)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.DescriptionValue1Bg, -1 * self.descriptionValueOffset)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionSeparator, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionValue2Bg, false)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.DescriptionValue1Bg, 0)
  end
end
function TradeSkills_DetailPanel:SetRequirements(requiresLabelText, req1Text, req1Icon, req2Text, req2Icon, useSmallIcon)
  if requiresLabelText ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.RequiresContainer, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.RequiresLabel, requiresLabelText, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Requires1Text, req1Text, eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.Requires1Icon, req1Icon)
    if req2Text ~= nil then
      UiElementBus.Event.SetIsEnabled(self.Properties.Requires2Icon, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.Requires2Text, true)
      UiTextBus.Event.SetTextWithFlags(self.Properties.Requires2Text, req2Text, eUiTextSet_SetLocalized)
      UiImageBus.Event.SetSpritePathname(self.Properties.Requires2Icon, req2Icon)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.Requires1Icon, -1 * self.requirementOffset)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.Requires1Text, -1 * self.requirementOffset)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.Requires2Icon, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.Requires2Text, false)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.Requires1Icon, 0)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.Requires1Text, 0)
    end
    local iconSize = useSmallIcon and self.smallIconSize or self.largeIconSize
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Requires1Icon, iconSize)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Requires1Icon, iconSize)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Requires2Icon, iconSize)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.Requires2Icon, iconSize)
    local iconColor = useSmallIcon and self.UIStyle.COLOR_GRAY_80 or self.UIStyle.COLOR_WHITE
    UiImageBus.Event.SetColor(self.Properties.Requires1Icon, iconColor)
    UiImageBus.Event.SetColor(self.Properties.Requires2Icon, iconColor)
  end
end
return TradeSkills_DetailPanel
