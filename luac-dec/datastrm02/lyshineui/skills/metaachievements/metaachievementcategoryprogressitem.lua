local MetaAchievementCategoryProgressItem = {
  Properties = {
    Title = {
      default = EntityId()
    },
    Fraction = {
      default = EntityId()
    },
    Bar = {
      default = EntityId()
    },
    BarCap = {
      default = EntityId()
    }
  },
  progressBarWidth = 0,
  containerWidth = 0,
  barPadding = 5,
  barHeight = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(MetaAchievementCategoryProgressItem)
function MetaAchievementCategoryProgressItem:OnInit()
  BaseElement.OnInit(self)
  self.barHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.Bar)
  self.containerWidth = UiTransform2dBus.Event.GetLocalWidth(self.entityId)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.BarCap, self.barHeight)
  SetTextStyle(self.Properties.Title, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_PROGRESS_TITLE)
  SetTextStyle(self.Properties.Fraction, self.UIStyle.FONT_STYLE_ACHIEVEMENTS_PROGRESS_FRACTION_COUNT)
end
function MetaAchievementCategoryProgressItem:SetData(data, onClickedCallback, onClickedCallbackTable)
  self.data = data
  self.onClickedCallback = onClickedCallback
  self.onClickedCallbackTable = onClickedCallbackTable
  UiTextBus.Event.SetTextWithFlags(self.Properties.Title, data.title, eUiTextSet_SetLocalized)
  local fraction = GetLocalizedReplacementText("@ui_meta_achievements_summary_fraction", {
    numeratorColor = ColorRgbaToHexString(self.UIStyle.COLOR_WHITE),
    numerator = tostring(data.completedCount),
    denominatorColor = ColorRgbaToHexString(self.UIStyle.COLOR_GRAY_50),
    denominator = tostring(data.totalCount)
  })
  UiTextBus.Event.SetText(self.Properties.Fraction, fraction)
  UiImageBus.Event.SetFillAmount(self.Properties.Bar, data.completedCount / data.totalCount)
  self.progressBarWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.Bar)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.BarCap, data.completedCount / data.totalCount * self.progressBarWidth)
end
function MetaAchievementCategoryProgressItem:OnClicked()
  if self.onClickedCallbackTable ~= nil and type(self.onClickedCallback) == "function" then
    self.onClickedCallback(self.onClickedCallbackTable, self.data.id)
  end
end
function MetaAchievementCategoryProgressItem:EnableTitle(enabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.Title, enabled)
end
function MetaAchievementCategoryProgressItem:EnableProgessCount(enabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.Fraction, enabled)
end
function MetaAchievementCategoryProgressItem:ProgressCountToTopLeftPosition(enabled)
  if enabled then
    UiTransform2dBus.Event.SetOffsets(self.Properties.Fraction, UiOffsets(0, 0.5, 0, 0.5))
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Fraction, self.containerWidth * -1)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Fraction, -30)
    SetTextStyle(self.Properties.Fraction, {
      hAlignment = self.UIStyle.TEXT_HALIGN_LEFT
    })
  else
    UiTransform2dBus.Event.SetOffsets(self.Properties.Fraction, UiOffsets(1, 0.5, 1, 0.5))
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Fraction, 0)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.Fraction, 0)
    SetTextStyle(self.Properties.Fraction, {
      hAlignment = self.UIStyle.TEXT_HALIGN_RIGHT
    })
  end
end
return MetaAchievementCategoryProgressItem
