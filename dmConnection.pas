unit dmConnection;

interface

uses
  SysUtils, Classes, DB, ADODB;

type
  TdmCnt = class(TDataModule)
    AdoCnt: TADOConnection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  NOME_TXT = 'DBConfig.cfg';
  CNT_STRING = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=';

var
  dmCnt: TdmCnt;
  
  Username: string;
  LivelloUtente: string;
  CodAssociazioneAS: string;
  
implementation

{$R *.dfm}

end.
