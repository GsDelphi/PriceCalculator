unit BusinessProcessPlugIns;

interface

uses
  Classes;

type
  TBusinessProcessPlugin = class
  protected
    function GetNsme: String; virtual; abstract;
  public
    constructor Create; virtual;

    property Name: String read GetNsme;
  end;

  TSalesPriceAlgorithmClass = class of TSalesPriceAlgorithm;

  TSalesPriceAlgorithm = class(TBusinessProcessPlugin)
  protected
    FPurchasePrice: Currency;
    function GetSalesPrice: Currency; virtual; abstract;
  public
    constructor Create; override;

    property PurchasePrice: Currency read FPurchasePrice write FPurchasePrice;
    property SalesPrice: Currency read GetSalesPrice;
  end;

  TSalesPriceList = class(TList)
  protected
    function GetItem(Index: Integer): Currency;
    procedure SetItem(Index: Integer; ASalesPrice: Currency);
  public
    constructor Create;

    function Add(ASalesPrice: Currency): Integer;
    function Extract(Item: Currency): Currency;
    function Remove(ASalesPrice: Currency): Integer;
    function IndexOf(ASalesPrice: Currency): Integer;
    procedure Insert(Index: Integer; ASalesPrice: Currency);
    function First: Currency;
    function Last: Currency;
    property Items[Index: Integer]: Currency read GetItem write SetItem; default;
  end;

  TPriceCalculator = class(TBusinessProcessPlugin)
  private
    function GetSalesPriceList: TSalesPriceList; virtual; abstract;
  public
    function Round(APrice: Currency): Currency; virtual; abstract;

    property SalesPriceList: TSalesPriceList read GetSalesPriceList;
  end;

implementation

{ TSalesPriceAlgorithm }

constructor TSalesPriceAlgorithm.Create;
begin
  inherited;

  FPurchasePrice := 0;
end;

{ TBusinessProcessPlugin }

constructor TBusinessProcessPlugin.Create;
begin
  inherited Create;
end;

{ TSalesPriceList }

function TSalesPriceList.Add(ASalesPrice: Currency): Integer;
begin
  Result := IndexOf(ASalesPrice);

  if (Result = -1) then
    Result := inherited Add(TObject(ASalesPrice));
end;

constructor TSalesPriceList.Create;
begin

end;

function TSalesPriceList.Extract(Item: Currency): Currency;
begin

end;

function TSalesPriceList.First: Currency;
begin

end;

function TSalesPriceList.GetItem(Index: Integer): Currency;
begin

end;

function TSalesPriceList.IndexOf(ASalesPrice: Currency): Integer;
begin

end;

procedure TSalesPriceList.Insert(Index: Integer; ASalesPrice: Currency);
begin

end;

function TSalesPriceList.Last: Currency;
begin

end;

function TSalesPriceList.Remove(ASalesPrice: Currency): Integer;
begin

end;

procedure TSalesPriceList.SetItem(Index: Integer; ASalesPrice: Currency);
begin

end;

end.
