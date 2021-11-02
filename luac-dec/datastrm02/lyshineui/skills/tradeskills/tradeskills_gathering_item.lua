local TradeSkills_Gathering_Item = {
  Properties = {
    ImageIcon = {
      default = EntityId()
    },
    ImageLabel = {
      default = EntityId()
    },
    LevelCircleLabel1 = {
      default = EntityId()
    },
    LevelCircle1 = {
      default = EntityId()
    },
    LevelCircleLabel2 = {
      default = EntityId()
    },
    LevelCircle2 = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TradeSkills_Gathering_Item)
function TradeSkills_Gathering_Item:OnInit()
  SetTextStyle(self.Properties.ImageLabel, self.UIStyle.FONT_STYLE_GATHERING_ITEM_TITLE)
end
function TradeSkills_Gathering_Item:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function TradeSkills_Gathering_Item:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function TradeSkills_Gathering_Item:GetHorizontalSpacing()
  return 10
end
function TradeSkills_Gathering_Item:SetGridItemData(gridItemData)
  UiElementBus.Event.SetIsEnabled(self.entityId, gridItemData ~= nil)
  if gridItemData then
    local currentSkillLevel = gridItemData.currentSkillLevel or 0
    local canHarvest = currentSkillLevel >= gridItemData.level1
    UiImageBus.Event.SetSpritePathname(self.Properties.ImageIcon, gridItemData.image)
    UiImageBus.Event.SetColor(self.Properties.ImageIcon, canHarvest and self.UIStyle.COLOR_WHITE or self.UIStyle.COLOR_GRAY_50)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ImageLabel, gridItemData.imageLabel, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.ImageLabel, canHarvest and self.UIStyle.COLOR_GRAY_90 or self.UIStyle.COLOR_GRAY_60)
    UiTextBus.Event.SetTextWithFlags(self.Properties.LevelCircleLabel1, gridItemData.label1, eUiTextSet_SetLocalized)
    self.LevelCircle1:SetLevel(gridItemData.level1)
    self.LevelCircle1:SetDisplayType(canHarvest and self.LevelCircle1.DISPLAY_TYPE_NORMAL or self.LevelCircle1.DISPLAY_TYPE_DIM)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelCircle2, gridItemData.level2 ~= nil)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelCircleLabel2, gridItemData.level2 ~= nil)
    if gridItemData.level2 then
      local noTrackingLevel = gridItemData.level2 == -1
      local displayType = self.LevelCircle2.DISPLAY_TYPE_NORMAL
      if noTrackingLevel or currentSkillLevel < gridItemData.level2 then
        displayType = self.LevelCircle2.DISPLAY_TYPE_DIM
      end
      UiTextBus.Event.SetTextWithFlags(self.Properties.LevelCircleLabel2, gridItemData.label2, eUiTextSet_SetLocalized)
      self.LevelCircle2:SetLevel(noTrackingLevel and "-" or gridItemData.level2)
      self.LevelCircle2:SetDisplayType(displayType)
      UiLayoutCellBus.Event.SetTargetHeight(self.entityId, 460)
    else
      UiLayoutCellBus.Event.SetTargetHeight(self.entityId, 376)
    end
  end
end
return TradeSkills_Gathering_Item
