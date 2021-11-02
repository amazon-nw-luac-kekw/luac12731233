local MilestoneEntry = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Name = {
      default = EntityId()
    },
    Bg = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyshineUI._Common.BaseElement")
BaseElement:CreateNewElement(MilestoneEntry)
function MilestoneEntry:OnInit()
end
function MilestoneEntry:SetColor(color)
  UiImageBus.Event.SetColor(self.Properties.Icon, color)
  UiTextBus.Event.SetColor(self.Properties.Name, color)
end
return MilestoneEntry
