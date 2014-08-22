unit UVisProdottiOrdinati;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ADODB, Grids, DBGrids, ExtCtrls;

type
  TfrmProdottiOrdinati = class(TForm)
    img1: TImage;
    btnReport: TButton;
    btnChiudi: TButton;
    gbInfo: TGroupBox;
    cbAnni: TComboBox;
    lblInfo1: TLabel;
    qrQuery: TADOQuery;
    procedure FormShow(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadAnni;
  end;

var
  frmProdottiOrdinati: TfrmProdottiOrdinati;

implementation

uses dmConnection, UReportProdottiOrdinati, UMessaggi;

{$R *.dfm}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmProdottiOrdinati.FormShow(Sender: TObject);
begin
  LoadAnni;
  cbAnni.SetFocus;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmProdottiOrdinati.btnReportClick(Sender: TObject);
var Anno: string;
begin
  if cbAnni.ItemIndex = 0 then ShowMessage(MSG_SELEZIONARE_ANNO)
  else
  begin
    Anno := cbAnni.Items[cbAnni.ItemIndex];
    frmReportProdottiOrdinati.AnteprimaReport(Anno);
  end;
end;

procedure TfrmProdottiOrdinati.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmProdottiOrdinati.LoadAnni;
begin
  cbAnni.Clear;
  cbAnni.Items.Add(' ');
  qrQuery.SQL.Text := 'SELECT DISTINCT [Anno] FROM [Prodotti_Ordinati] ORDER BY [Anno]';
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
