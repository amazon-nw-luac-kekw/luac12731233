local MilestoneHeader = {
  Properties = {
    OutlineBg = {
      default = EntityId()
    },
    LevelText = {
      default = EntityId()
    },
    Container = {
      default = EntityId()
    }
  },
  nextMilestoneDiamondPath = "lyshineui/images/glory/nextMilestoneDiamond.dds",
  otherMilestoneDiamondPath = "lyshineui/images/glory/genericMilestoneDiamond.dds",
  DISPLAY_STATE_UNLOCKED = 0,
  DISPLAY_STATE_LOCKED = 1,
  DISPLAY_STATE_NEXT = 2
}
local BaseElement = RequireScript("LyshineUI._Common.BaseElement")
BaseElement:CreateNewElement(MilestoneHeader)
function MilestoneHeader:OnInit()
end
function MilestoneHeader:SetLevel(level)
  UiTextBus.Event.SetText(self.Properties.LevelText, level)
end
function MilestoneHeader:SetDisplayState(state)
  if state == self.currentDisplayState then
    return
  end
  local diamondPath = self.otherMilestoneDiamondPath
  local diamondColor = self.UIStyle.COLOR_WHITE
  local textColor = self.UIStyle.COLOR_GRAY_80
  local entryColor = self.UIStyle.COLOR_GRAY_80
  if state == self.DISPLAY_STATE_NEXT then
    diamondPath = self.nextMilestoneDiamondPath
    textColor = self.UIStyle.COLOR_YELLOW
    entryColor = self.UIStyle.COLOR_WHITE
  elseif state == self.DISPLAY_STATE_LOCKED then
    diamondColor = self.UIStyle.COLOR_GRAY_30
    textColor = self.UIStyle.COLOR_GRAY_50
    entryColor = self.UIStyle.COLOR_GRAY_50
  end
  if self.Properties.OutlineBg then
    UiImageBus.Event.SetSpritePathname(self.Properties.OutlineBg, diamondPath)
    UiImageBus.Event.SetColor(self.Properties.OutlineBg, diamondColor)
  end
  UiTextBus.Event.SetColor(self.Properties.LevelText, textColor)
  local children = UiElementBus.Event.GetChildren(self.Properties.Container)
  for i = 1, #children do
    local entityTable = self.registrar:GetEntityTable(children[i])
    entityTable:SetColor(entryColor)
  end
  self.currentDisplayState = state
end
return MilestoneHeader
