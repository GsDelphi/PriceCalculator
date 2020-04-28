unit Enothek;

interface

uses
  BusinessProcessPlugins, Math;

type
  TEnothekSalesPriceAlgorithm = class(TSalesPriceAlgorithm)
  private
  protected
    FImportCost: Currency;
    FStockCost: Currency;
    FVolume: Integer;
    function GetAddVAT: Boolean; virtual;
    function GetFactor: Currency; virtual; abstract;
    function GetImportCost: Currency;
    function GetMargin: Currency;
    function GetSalesPrice: Currency; override;
    function GetStockCost: Currency;
    function GetVAT: Currency;
    function GetVATPerCent: Currency; virtual;
  public
    constructor Create; override;

    property Volume: Integer read FVolume write FVolume;
    property Factor: Currency read GetFactor;
    property DefaultImportCost: Currency read FImportCost write FImportCost;
    property ImportCost: Currency read GetImportCost;
    property StockCost: Currency read FStockCost write FStockCost;
    property VAT: Currency read GetVAT;
    property VAT_PerCent: Currency read GetVATPerCent;
    property AddVAT: Boolean read GetAddVAT;
    property Margin: Currency read GetMargin;
  end;

  TEnothekSalesPriceAlgorithmClass = class of TEnothekSalesPriceAlgorithm;

  TEnothekCommonSalesPriceAlgorithm = class(TEnothekSalesPriceAlgorithm)
  protected
    function GetAddVAT: Boolean; override;
    function GetFactor: Currency; override;
    function GetVATPerCent: Currency; override;
  end;

  TEnothekBredMilkSalesPriceAlgorithm = class(TEnothekCommonSalesPriceAlgorithm)
  protected
    function GetFactor: Currency; override;
  end;

  TEnothekLocalWineSalesPriceAlgorithm = class(TEnothekSalesPriceAlgorithm)
  protected
    function GetFactor: Currency; override;
  end;

  TEnothekImportWineSalesPriceAlgorithm = class(TEnothekSalesPriceAlgorithm)
  protected
    function GetFactor: Currency; override;
  end;

  TEnothekSelfImportedWineSalesPriceAlgorithm = class(TEnothekSalesPriceAlgorithm)
  protected
    function GetFactor: Currency; override;
  public
    constructor Create; override;
  end;

  TEnothekSelfImportedFoamSweetWineSalesPriceAlgorithm = class(TEnothekSelfImportedWineSalesPriceAlgorithm)
  public
    constructor Create; override;
  end;

  TEnothekSelfImportedCustomWineSalesPriceAlgorithm = class(TEnothekSelfImportedWineSalesPriceAlgorithm);

  TEnothekPriceCalculator = class(TPriceCalculator)
  protected
    function GetNsme: String; override;
  public
    function Round(APrice: Currency): Currency; override;
  end;

function GetFirstAmount: Currency;
function GetNextAmount: Currency;
function GetAmountCount: Integer;

implementation

resourcestring
  sEnothekPriceCalculator = 'Enothek Preisrechner';

var
  lLastAmount: Currency;

function GetFirstAmount: Currency;
begin
  lLastAmount := 0.05;
  Result := lLastAmount;
end;

function GetNextAmount: Currency;
begin
  if (lLastAmount < 5) then
    lLastAmount := lLastAmount + 0.05
  else if (lLastAmount < 20) then
    lLastAmount := lLastAmount + 0.10
  else if (lLastAmount < 30) then
    lLastAmount := lLastAmount + 0.50
  else if (lLastAmount < 50) then
    lLastAmount := lLastAmount + 1.00
  else if (lLastAmount < 100) then
    lLastAmount := lLastAmount + 5.00
  else if (lLastAmount < 200) then
    lLastAmount := lLastAmount + 10.00
  else
    lLastAmount := 0;

  Result := lLastAmount;
end;

function GetAmountCount: Integer;
begin
  GetFirstAmount;
  Result := 1;
  while (GetNextAmount > 0) do
    Inc(Result);
end;

{ TEnothekPriceCalculator }

function TEnothekPriceCalculator.GetNsme: String;
begin
  Result := sEnothekPriceCalculator;
end;

function TEnothekPriceCalculator.Round(APrice: Currency): Currency;
begin
  if (APrice < 9.95) then
    Result := SimpleRoundTo(APrice, -1)
  else if (APrice < 10.25) then
    Result := 9.9
  else if (APrice < 10.55) then
    Result := 10.5
  else if (APrice < 31) then
  begin
    if ((Trunc(APrice) mod 10) = 0) then
    begin
      if ((APrice - Trunc(APrice)) < 0.5) then
        Result := Trunc(APrice) - 0.2
      else
        Result := Trunc(APrice) + 1
    end
    else if ((Trunc(APrice) Mod 10) = 1) And ((APrice - Trunc(APrice)) < 0.14) then
      Result := Trunc(APrice)
    else
    begin
      if ((APrice - Trunc(APrice)) > 0.645) then
        Result := Trunc(APrice) + 0.8
      else if ((APrice - Trunc(APrice)) > 0.345) then
        Result := Trunc(APrice) + 0.5
      else if ((APrice - Trunc(APrice)) > 0.145) then
        Result := Trunc(APrice) + 0.2
      else
        Result := Trunc(APrice) - 1 + 0.8
    end;
  end
  else if (APrice < 49) then
  begin
    if ((Trunc(APrice) Mod 10) = 0) then
    begin
      if ((APrice - Trunc(APrice)) < 0.5) then
        Result := Trunc(APrice) - 0.5
      else
        Result := Trunc(APrice) + 1
    end
    else
    begin
      if ((APrice - Trunc(APrice)) < 0.24) then
        Result := Trunc(APrice)
      else if ((APrice - Trunc(APrice)) < 0.75) then
        Result := Trunc(APrice) + 0.5
      else
        Result := Trunc(APrice) + 1
    end;
  end
  else if (APrice < 50.5) then
    Result := 49.5
  else //if (APrice < 195) then
  begin
    if ((Trunc(APrice) Mod 10) = 0) then
    begin
      if ((APrice - Trunc(APrice)) < 0.5) then
        Result := Trunc(APrice) - 1
      else
        Result := Trunc(APrice) + 1
    end
    else if ((Trunc(APrice) Mod 10) = 9) then
      Result := Trunc(APrice)
    else
    begin
      if ((APrice - Trunc(APrice)) < 0.5) then
        Result := Trunc(APrice)
      else
        Result := Trunc(APrice) + 1
    end;
  end
{  else
  begin
    if ((Trunc(APrice) Mod 100) < 5) then
    begin
      if ((APrice - Trunc(APrice)) < 0.5) then
        Result := Trunc(APrice) - 5
      else
        Result := Trunc(APrice) + 1
    end
    else
    begin
      if ((APrice - Trunc(APrice)) < 0.5) then
          Result := Trunc(APrice)
      else
          Result := Trunc(APrice) + 1
    end;
  end;}
end;

{ TEnothekSalesPriceAlgorithm }

constructor TEnothekSalesPriceAlgorithm.Create;
begin
  inherited;

  FImportCost := 0;
  FStockCost := 0;
  FVolume := 750;
end;

function TEnothekSalesPriceAlgorithm.GetAddVAT: Boolean;
begin
  Result := true;
end;

function TEnothekSalesPriceAlgorithm.GetImportCost: Currency;
begin
  Result := FImportCost * Volume / 750;
end;

function TEnothekSalesPriceAlgorithm.GetMargin: Currency;
begin
  Result := PurchasePrice * (Factor - 1);

  if (Result > 25) then
    Result := 25;
end;

function TEnothekSalesPriceAlgorithm.GetSalesPrice: Currency;
begin
  Result := PurchasePrice + Margin + ImportCost + StockCost;

  if AddVAT then
    Result := Result * 100 / (100 - VAT_PerCent);
end;

function TEnothekSalesPriceAlgorithm.GetStockCost: Currency;
begin
  Result := FStockCost;
end;

function TEnothekSalesPriceAlgorithm.GetVAT: Currency;
begin
  Result := SalesPrice * VAT_PerCent / 100;
end;

function TEnothekSalesPriceAlgorithm.GetVATPerCent: Currency;
begin
  Result := 7.6;
end;

{ TEnothekCommonSalesPriceAlgorithm }

function TEnothekCommonSalesPriceAlgorithm.GetAddVAT: Boolean;
begin
  Result := true;
end;

function TEnothekCommonSalesPriceAlgorithm.GetFactor: Currency;
begin
  Result := 1.7 * (100 - VAT_PerCent) / 100;
end;

function TEnothekCommonSalesPriceAlgorithm.GetVATPerCent: Currency;
begin
  Result := 2.4;
end;

{ TEnothekBredMilkSalesPriceAlgorithm }

function TEnothekBredMilkSalesPriceAlgorithm.GetFactor: Currency;
begin
  Result := 1.5 * (100 - VAT_PerCent) / 100;
end;

{ TEnothekLocalWineSalesPriceAlgorithm }

function TEnothekLocalWineSalesPriceAlgorithm.GetFactor: Currency;
begin
  Result := (1 / Ln(Power(PurchasePrice + 29, 0.33)) + 0.68);
end;

{ TEnothekImportWineSalesPriceAlgorithm }

function TEnothekImportWineSalesPriceAlgorithm.GetFactor: Currency;
begin
  Result := (1 / Ln(Power(PurchasePrice + 29, 0.25)) + 0.67) * 0.9;
end;

{ TEnothekSelfImportedWineSalesPriceAlgorithm }

constructor TEnothekSelfImportedWineSalesPriceAlgorithm.Create;
begin
  inherited;

  FImportCost := 2.5;
end;

function TEnothekSelfImportedWineSalesPriceAlgorithm.GetFactor: Currency;
begin
  Result := 0.8 * Cos(0.05 * Sqrt(PurchasePrice) + 1.6) + 2.04;
end;

{ TEnothekSelfImportedFoamSweetWineSalesPriceAlgorithm }

constructor TEnothekSelfImportedFoamSweetWineSalesPriceAlgorithm.Create;
begin
  inherited;

  FImportCost := 3.0;
end;

end.

Private Function GetFactorStandard(PurchasePrice As Double) As Double
    GetFactorStandard = (1 / Log((PurchasePrice + 29) ^ 0.25) + 0.67) * GetSalesCalculator.Worksheets("Definitionen").Range("B3").Value
End Function

Private Function GetFactorSwiss(PurchasePrice As Double) As Double
    GetFactorSwiss = (1 / Log((PurchasePrice + 29) ^ 0.33) + 0.82) * GetSalesCalculator.Worksheets("Definitionen").Range("B4").Value
End Function

Private Function GetFactorSelfImport(PurchasePrice As Double) As Double
    GetFactorSelfImport = (0.8 * Cos(0.05 * Sqr(PurchasePrice) + 1.6) + 2.04) * GetSalesCalculator.Worksheets("Definitionen").Range("B5").Value
End Function
