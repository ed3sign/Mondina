unit UVisProdottiPerTipologia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, ADODB;

type
  TfrmProdottiPerTipologia = class(TForm)
    btnChiudi: TButton;
    btnReport: TButton;
    qrQuery: TADOQuery;
    img1: TImage;
    gbInfo: TGroupBox;
    cbTipologia: TComboBox;
    lblInfo1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadTipologie;
  end;

var
  frmProdottiPerTipologia: TfrmProdottiPerTipologia;

implementation

uses dmConnection , UReportProdottiPerTipologia;

{$R *.dfm}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmProdottiPerTipologia.FormShow(Sender: TObject);
begin
  LoadTipologie;
  cbTipologia.SetFocus;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmProdottiPerTipologia.btnReportClick(Sender: TObject);
var
  Tipologia: string;
begin
  Tipologia := cbTipologia.Items[cbTipologia.ItemIndex];
  frmReportProdottiPerTipologia.AnteprimaReport(Tipologia);
end;

procedure TfrmProdottiPerTipologia.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmProdottiPerTipologia.LoadTipologie;
begin
  cbTipologia.Clear;
  cbTipologia.Items.Add(' ');
  qrQuery.SQL.Text := 'SELECT [Tipologia] FROM [Tipologie_Prodotti] ORDER BY [Tipologia]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    cbTipologia.Items.Add(qrQuery.FieldByName('Tipologia').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbTipologia.ItemIndex := 0;  
end;

end.
