local TerritoryInfoBonusItem = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Name = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryInfoBonusItem)
local mapTypes = RequireScript("LyShineUI._Common.MapTypes")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
function TerritoryInfoBonusItem:OnInit()
  BaseElement.OnInit(self)
end
return TerritoryInfoBonusItem
