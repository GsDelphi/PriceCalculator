unit MainForm;

interface

uses
  Forms, FR_DSet, FR_Class, ExtCtrls, TimerModules, Classes, ActnList,
  ImgList, Controls, Grids, RzGrids, StdCtrls, RzCmboBx, RzPanel, RzRadGrp,
  RzButton, Mask, RzEdit, RzLine, RzLabel, RzTabs, RzStatus, Enothek, SysUtils;

type
  TFMain = class(TForm)
    ILMain: TImageList;
    ALMain: TActionList;
    ACCalculate: TAction;
    TPurchasePriceChanged: TBPTimer;
    APTPrint: TAction;
    APTPrintPreview: TAction;
    AQuit: TAction;
    TUnitChanged: TBPTimer;
    TProductTypeChanged: TBPTimer;
    APTRefresh: TAction;
    rPriceTable: TfrReport;
    udPriceTable: TfrUserDataset;
    RzStatusBar1: TRzStatusBar;
    RzPanel1: TRzPanel;
    PCMain: TRzPageControl;
    TSCalculator: TRzTabSheet;
    LCPurchasePrice: TRzLabel;
    LCMargin: TRzLabel;
    LCImportCost: TRzLabel;
    LCVAT: TRzLabel;
    LCSalesPriceRounded: TRzLabel;
    LCSalesPrice: TRzLabel;
    LC2: TRzLine;
    LC1: TRzLine;
    LCSummary: TRzLabel;
    LCFactor: TRzLabel;
    NECPurchasePrice: TRzNumericEdit;
    NECMargin: TRzNumericEdit;
    NECImportCost: TRzNumericEdit;
    NECVAT: TRzNumericEdit;
    NECSalesPriceRounded: TRzNumericEdit;
    NECSalesPrice: TRzNumericEdit;
    BBCCalculate: TRzBitBtn;
    NECSummary: TRzNumericEdit;
    RGCProductType: TRzRadioGroup;
    GBCUnit: TRzGroupBox;
    LCUnit: TRzLabel;
    CBCUnit: TRzComboBox;
    NECFactor: TRzNumericEdit;
    TSDefinitions: TRzTabSheet;
    SGDDefinitions: TRzStringGrid;
    BBDSave: TRzBitBtn;
    BBDCancel: TRzBitBtn;
    TSPriceTable: TRzTabSheet;
    PPTBG: TRzPanel;
    PPTBottom: TRzPanel;
    BBPTPrint: TRzBitBtn;
    BBPTPrintPreview: TRzBitBtn;
    BBPTRefresh: TRzBitBtn;
    SGPriceTable: TRzStringGrid;
    PCDefaultImportCost: TRzPanel;
    LCDefaultImportCost: TRzLabel;
    NECDefaultImportCost: TRzNumericEdit;
    VIS: TRzVersionInfoStatus;
    RzVersionInfoStatus1: TRzVersionInfoStatus;
    procedure TPurchasePriceChangedTimer(Sender: TObject);
    procedure NECPurchasePriceChange(Sender: TObject);
    procedure CBCUnitChange(Sender: TObject);
    procedure RGCProductTypeChanging(Sender: TObject; NewIndex: Integer;
      var AllowChange: Boolean);
    procedure AQuitExecute(Sender: TObject);
    procedure TUnitChangedTimer(Sender: TObject);
    procedure ACCalculateExecute(Sender: TObject);
    procedure NECPurchasePriceKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TProductTypeChangedTimer(Sender: TObject);
    procedure PCMainChange(Sender: TObject);
    procedure APTRefreshExecute(Sender: TObject);
    procedure APTPrintExecute(Sender: TObject);
    procedure APTPrintPreviewExecute(Sender: TObject);
    procedure udPriceTableCheckEOF(Sender: TObject; var Eof: Boolean);
    procedure udPriceTableFirst(Sender: TObject);
    procedure udPriceTableNext(Sender: TObject);
    procedure udPriceTablePrior(Sender: TObject);
    procedure rPriceTableGetValue(const ParName: String;
      var ParValue: Variant);
    procedure PCMainChanging(Sender: TObject; NewIndex: Integer;
      var AllowChange: Boolean);
  private
    { Private-Deklarationen }
    FSalesPriceAlgorithm: TEnothekSalesPriceAlgorithm;
    FPriceCalculator: TEnothekPriceCalculator;
    FCurrentRow: Integer;
    function GetSalesPriceAlgorithmClass: TEnothekSalesPriceAlgorithmClass;
  public
    { Public-Deklarationen }
  end;

var
  FMain: TFMain;

implementation

uses
  BusinessProcessPlugIns, DataModule;

{$R *.dfm}

procedure TFMain.TPurchasePriceChangedTimer(Sender: TObject);
begin
  ACCalculate.Execute;
end;

procedure TFMain.NECPurchasePriceChange(Sender: TObject);
begin
  TPurchasePriceChanged.ReStart;
end;

procedure TFMain.CBCUnitChange(Sender: TObject);
begin
  TUnitChanged.ReStart;
end;

procedure TFMain.RGCProductTypeChanging(Sender: TObject;
  NewIndex: Integer; var AllowChange: Boolean);
begin
  TProductTypeChanged.ReStart;
end;

procedure TFMain.AQuitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFMain.TUnitChangedTimer(Sender: TObject);
begin
  ACCalculate.Execute;
  CBCUnit.SetFocus;
end;

procedure TFMain.ACCalculateExecute(Sender: TObject);
resourcestring
  sAddVAT = ' + MWSt  (%2.2f%%)';
  sVATIncluded = ' davon MWSt  (%2.2f%%)';
var
  i,
  c,
  v: Integer;
begin
  for i := 0 to ComponentCount - 1 do
    if Components[i] is TTimer then
      (Components[i] as TBPTimer).Stop;

  if Assigned(FSalesPriceAlgorithm) then
    if (FSalesPriceAlgorithm.ClassType <> GetSalesPriceAlgorithmClass) then
      FreeAndNil(FSalesPriceAlgorithm);

  if not Assigned(FSalesPriceAlgorithm) then
    FSalesPriceAlgorithm := GetSalesPriceAlgorithmClass.Create;

  if (RGCProductType.ItemIndex = 6) then
    FSalesPriceAlgorithm.DefaultImportCost := NECDefaultImportCost.Value;

  Val(CBCUnit.Text, v, c);
  if (c > 0) then
  begin
    v := StrToIntDef(Copy(CBCUnit.Text, 1, c - 1), 75);
    CBCUnit.Text := IntToStr(v) + ' cl';
  end
  else
    v := StrToIntDef(CBCUnit.Text, 75);

  FSalesPriceAlgorithm.Volume := v * 10;
  FSalesPriceAlgorithm.PurchasePrice := NECPurchasePrice.Value;
  NECFactor.Value := FSalesPriceAlgorithm.Factor;
  NECMargin.Value := FSalesPriceAlgorithm.Margin;
  NECImportCost.Value := FSalesPriceAlgorithm.ImportCost;
  NECDefaultImportCost.Value := FSalesPriceAlgorithm.DefaultImportCost;
  NECSummary.Value := FSalesPriceAlgorithm.PurchasePrice + FSalesPriceAlgorithm.Margin + FSalesPriceAlgorithm.ImportCost;
  NECVAT.Value := FSalesPriceAlgorithm.VAT;
  NECSalesPrice.Value := FSalesPriceAlgorithm.SalesPrice;
  NECSalesPriceRounded.Value := FPriceCalculator.Round(FSalesPriceAlgorithm.SalesPrice);

  if FSalesPriceAlgorithm.AddVAT then
    LCVAT.Caption := Format(sAddVAT, [FSalesPriceAlgorithm.VAT_PerCent])
  else
    LCVAT.Caption := Format(sVATIncluded, [FSalesPriceAlgorithm.VAT_PerCent]);

  if (ActiveControl = NECPurchasePrice) then
  begin
    BBCCalculate.SetFocus;
    NECPurchasePrice.SetFocus;
  end;
  
  NECPurchasePrice.SelectAll;

  for i := 0 to ComponentCount - 1 do
    if Components[i] is TTimer then
      (Components[i] as TBPTimer).Stop;
end;

function TFMain.GetSalesPriceAlgorithmClass: TEnothekSalesPriceAlgorithmClass;
begin
  case RGCProductType.ItemIndex of
    0: Result := TEnothekBredMilkSalesPriceAlgorithm;
    2: Result := TEnothekLocalWineSalesPriceAlgorithm;
    3: Result := TEnothekImportWineSalesPriceAlgorithm;
    4: Result := TEnothekSelfImportedWineSalesPriceAlgorithm;
    5: Result := TEnothekSelfImportedFoamSweetWineSalesPriceAlgorithm;
    6: Result := TEnothekSelfImportedCustomWineSalesPriceAlgorithm;
  else
    Result := TEnothekCommonSalesPriceAlgorithm;
  end;
end;

procedure TFMain.NECPurchasePriceKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
    ACCalculate.Execute;
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  FSalesPriceAlgorithm := nil;
  FPriceCalculator := TEnothekPriceCalculator.Create;
  TSDefinitions.TabVisible := false;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
  PCMain.ActivePage := TSCalculator;
  RGCProductType.ItemIndex := 3;
  NECPurchasePrice.SetFocus;
end;

procedure TFMain.TProductTypeChangedTimer(Sender: TObject);
begin
  TProductTypeChanged.Stop;

  GBCUnit.Visible := (RGCProductType.ItemIndex > 3);
  NECDefaultImportCost.ReadOnly := (RGCProductType.ItemIndex <> 6);
  NECDefaultImportCost.TabStop := (RGCProductType.ItemIndex = 6);

  if (RGCProductType.ItemIndex = 6) then
    NECDefaultImportCost.SetFocus
  else if (RGCProductType.ItemIndex > 3) then
    CBCUnit.SetFocus;

  ACCalculate.Execute;
end;

procedure TFMain.PCMainChange(Sender: TObject);
begin
  if (PCMain.ActivePage = TSPriceTable) then
    APTRefresh.Execute;
end;

procedure TFMain.APTRefreshExecute(Sender: TObject);
resourcestring
  sAmount = 'EKP';
var
  Col,
  Row: Integer;
  Amount: Currency;
  SPAs: array [1..6] of TEnothekSalesPriceAlgorithm;
  PC: TEnothekPriceCalculator;
begin
  SPAs[1] := TEnothekCommonSalesPriceAlgorithm.Create;
  SPAs[2] := TEnothekBredMilkSalesPriceAlgorithm.Create;
  SPAs[3] := TEnothekLocalWineSalesPriceAlgorithm.Create;
  SPAs[4] := TEnothekImportWineSalesPriceAlgorithm.Create;
  SPAs[5] := TEnothekSelfImportedWineSalesPriceAlgorithm.Create;
  SPAs[6] := TEnothekSelfImportedFoamSweetWineSalesPriceAlgorithm.Create;
  PC := TEnothekPriceCalculator.Create;

  try
    SGPriceTable.ColCount := 7;
    SGPriceTable.RowCount := 1;
    SGPriceTable.Cells[0, 0] := sAmount;
    SGPriceTable.Cells[1, 0] := RGCProductType.Items[1];
    SGPriceTable.Cells[2, 0] := RGCProductType.Items[0];
    SGPriceTable.Cells[3, 0] := RGCProductType.Items[2];
    SGPriceTable.Cells[4, 0] := RGCProductType.Items[3];
    SGPriceTable.Cells[5, 0] := RGCProductType.Items[4];
    SGPriceTable.Cells[6, 0] := RGCProductType.Items[5];

    SGPriceTable.ColWidths[0] := 40;
    for Col := 1 to 6 do
      SGPriceTable.ColWidths[Col] := SGPriceTable.Canvas.TextWidth(SGPriceTable.Cells[Col, 0]) + 8;

    Amount := GetFirstAmount;
    Row := 1;

    while (Amount > 0) do
    begin
      SGPriceTable.RowCount := Row + 1;
      SGPriceTable.Cells[0, Row] := FormatFloat(',0.00', Amount);

      for Col := 1 to 6 do
      begin
        SPAs[Col].PurchasePrice := Amount;
        SGPriceTable.Cells[Col, Row] := FormatFloat(',0.00', PC.Round(SPAs[Col].SalesPrice));
      end;

      Amount := GetNextAmount;
      Inc(Row);
    end;

    SGPriceTable.FixedCols := 1;
    SGPriceTable.FixedRows := 1;
  finally
    PC.Free;
    SPAs[6].Free;
    SPAs[5].Free;
    SPAs[4].Free;
    SPAs[3].Free;
    SPAs[2].Free;
    SPAs[1].Free;
  end;
end;

procedure TFMain.APTPrintExecute(Sender: TObject);
begin
  if rPriceTable.PrepareReport then
    rPriceTable.PrintPreparedReportDlg;
end;

procedure TFMain.APTPrintPreviewExecute(Sender: TObject);
begin
  if rPriceTable.PrepareReport then
    rPriceTable.ShowPreparedReport;
end;

procedure TFMain.udPriceTableCheckEOF(Sender: TObject; var Eof: Boolean);
begin
  Eof := FCurrentRow >= SGPriceTable.RowCount;
end;

procedure TFMain.udPriceTableFirst(Sender: TObject);
begin
  FCurrentRow := 1;
end;

procedure TFMain.udPriceTableNext(Sender: TObject);
begin
  Inc(FCurrentRow);
end;

procedure TFMain.udPriceTablePrior(Sender: TObject);
begin
  Dec(FCurrentRow);
end;

procedure TFMain.rPriceTableGetValue(const ParName: String;
  var ParValue: Variant);
begin
  if (Copy(ParName, 1, 3) = 'Col') then
    ParValue := SGPriceTable.Cells[StrToInt(Copy(ParName, 4, 1)), FCurrentRow]
  else if (Copy(ParName, 1, 4) = 'TCol') then
    ParValue := SGPriceTable.Cells[StrToInt(Copy(ParName, 5, 1)), 0]
end;

procedure TFMain.PCMainChanging(Sender: TObject; NewIndex: Integer;
  var AllowChange: Boolean);
begin
  AllowChange := (NewIndex <> TSDefinitions.TabIndex);
end;

end.
