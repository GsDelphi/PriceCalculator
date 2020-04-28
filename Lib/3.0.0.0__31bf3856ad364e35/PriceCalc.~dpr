program PriceCalc;

uses
  ExceptionLog,
  ELInit,
  AppModules,
  Forms,
  MainForm in 'MainForm.pas' {FMain},
  DataModule in 'DataModule.pas' {DM: TDataModule},
  Enothek in 'Enothek.pas',
  BusinessProcessPlugIns in 'BusinessProcessPlugIns.pas';

{$R *.res}

begin
  if ChangeToAlreadyRunningProcessAndTerminate('Preisrechner', true, true, true) then
    Exit;

  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
