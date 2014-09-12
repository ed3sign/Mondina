unit UProdottiRichiestiStudi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, ExtCtrls;

type
  TfrmProdottiRichiestiStudi = class(TForm)
    img1: TImage;
    btnReport: TButton;
    btnChiudi: TButton;
    gbInfo: TGroupBox;
    lblInfo1: TLabel;
    cbAnni: TComboBox;
    qrQuery: TADOQuery;
    cbStudi: TComboBox;
    lblInfo2: TLabel;
    cbTipologie: TComboBox;
    lblInfo3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadAnni;
    procedure LoadStudi;
    procedure LoadTipologie;    
  end;

var
  frmProdottiRichiestiStudi: TfrmProdottiRichiestiStudi;

implementation

{$R *.dfm}

uses dmConnection, UMessaggi, UHashTable, UReportProdottiRichiestiStudi;

var
  hsAssociazioneAS: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmProdottiRichiestiStudi.FormShow(Sender: TObject);
begin
  LoadAnni;
  LoadStudi;
  LoadTipologie;
  cbAnni.SetFocus;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmProdottiRichiestiStudi.btnReportClick(Sender: TObject);
var Anno, Studio, Tipologia: string;
begin
  if cbAnni.ItemIndex = 0 then ShowMessage(MSG_SELEZIONARE_ANNO)
  else if cbStudi.ItemIndex = 0 then ShowMessage(MSG_SELEZIONARE_STUDIO)
  else
  begin
    Anno := cbAnni.Items[cbAnni.ItemIndex];
    if cbStudi.ItemIndex = 1 then Studio := '0'
    else Studio := hsAssociazioneAS.GetKey(cbStudi.ItemIndex-2);
    Tipologia := cbTipologie.Items[cbTipologie.ItemIndex];
    frmReportProdottiRichiestiStudi.AnteprimaReport(Anno, Studio, cbStudi.Items[cbStudi.ItemIndex], Tipologia);
  end;
end;

procedure TfrmProdottiRichiestiStudi.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmProdottiRichiestiStudi.LoadAnni;
begin
  cbAnni.Clear;
  cbAnni.Items.Add(' ');
  qrQuery.SQL.Text := 'SELECT DISTINCT [Anno] FROM [Prodotti_Richiesti_Studi] ORDER BY [Anno]';
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

procedure TfrmProdottiRichiestiStudi.LoadStudi;
begin
  hsAssociazioneAS := THashTable.Create;
  cbStudi.Clear;
  cbStudi.Items.Add(' ');
  cbStudi.Items.Add('AMMINISTRATORE');
  qrQuery.SQL.Text := 'SELECT [Codice], [Nome] FROM [AssociazioneAS] ORDER BY [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsAssociazioneAS.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbStudi.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbStudi.ItemIndex := 0;
end;

procedure TfrmProdottiRichiestiStudi.LoadTipologie;
begin
  cbTipologie.Clear;
  cbTipologie.Items.Add(' ');
  qrQuery.SQL.Text := 'SELECT [Tipologia] FROM [Tipologie_Prodotti] ORDER BY [Tipologia]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    cbTipologie.Items.Add(qrQuery.FieldByName('Tipologia').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbTipologie.ItemIndex := 0;
end;

end.
