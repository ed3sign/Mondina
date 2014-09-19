unit UVisRifornimentiEmergenza;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ADODB, Grids, DBGrids, ExtCtrls;

type
  TfrmRifornimentiEmergenza = class(TForm)
    img1: TImage;
    btnReport: TButton;
    btnChiudi: TButton;
    gbInfo: TGroupBox;
    cbAnni: TComboBox;
    lblInfo1: TLabel;
    qrQuery: TADOQuery;
    procedure btnReportClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
    procedure FormInit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadAnni;
  end;

var
  frmRifornimentiEmergenza: TfrmRifornimentiEmergenza;

implementation

uses dmConnection, UReportEmergenza, UMessaggi;

{$R *.dfm}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmRifornimentiEmergenza.FormInit(Sender: TObject);
begin
  LoadAnni;
  cbAnni.SetFocus;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmRifornimentiEmergenza.btnReportClick(Sender: TObject);
var Anno: string;
begin
  if cbAnni.ItemIndex = 0 then ShowMessage(MSG_SELEZIONARE_ANNO)
  else
  begin
    Anno := cbAnni.Items[cbAnni.ItemIndex];
    frmReportEmergenza.AnteprimaReport(Anno);
  end;
end;

procedure TfrmRifornimentiEmergenza.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmRifornimentiEmergenza.LoadAnni;
begin
  cbAnni.Clear;
  cbAnni.Items.Add(' ');
  qrQuery.SQL.Text := 'SELECT DISTINCT YEAR ([Data]) AS Anno FROM [RifornimentiEmergenza]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    cbAnni.Items.Add(qrQuery.FieldByName('Anno').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbAnni.ItemIndex := 0;
end;

end.
