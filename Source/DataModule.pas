unit DataModule;

interface

uses
  Classes, RzStatus;

type
  TDM = class(TDataModule)
    VersionInfo: TRzVersionInfo;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  DM: TDM;

implementation

{$R *.dfm}

end.
