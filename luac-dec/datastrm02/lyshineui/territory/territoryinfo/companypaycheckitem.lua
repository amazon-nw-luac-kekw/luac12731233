local CompanyPaycheckItem = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Units = {
      default = EntityId()
    },
    Amount = {
      default = EntityId()
    },
    UnitsText = {
      default = "@ui_units_units"
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CompanyPaycheckItem)
function CompanyPaycheckItem:OnInit()
  BaseElement.OnInit(self)
end
function CompanyPaycheckItem:SetItem(units, amount)
  UiTextBus.Event.SetText(self.Properties.Amount, GetLocalizedCurrency(amount))
  local text = GetLocalizedReplacementText(self.Properties.UnitsText, {units = units})
  UiTextBus.Event.SetText(self.Properties.Units, text)
end
return CompanyPaycheckItem
