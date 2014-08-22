unit UCreaCassetto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ADODB, DB, StdCtrls, ExtCtrls, TextLabeledEdit;

type
  TfrmCreaCassetto = class(TForm)
    btnApplica: TButton;
    btnOK: TButton;
    btnAnnulla: TButton;
    qrQuery: TADOQuery;
    tblCassetti: TADOTable;
    gbInfo: TGroupBox;
    lblInfo1: TLabel;
    lblInfo2: TLabel;
    edtCodice: TTextLabeledEdit;
    cbStudi: TComboBox;
    cbMobili: TComboBox;
    img1: TImage;
    procedure FormShow(Sender: TObject);
    procedure cbStudiChange(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure btnApplicaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadStudi;
    procedure LoadMobili;
    procedure ResetCampi;
    function EsisteCassetto(CodCassetto: string): Boolean;
    procedure AddCassetto;
  end;

var
  frmCreaCassetto: TfrmCreaCassetto;

implementation

uses dmConnection, UHashTable, UMessaggi;

{$R *.dfm}

var
  hsStudi, hsMobili: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaCassetto.FormShow(Sender: TObject);
begin
  LoadStudi;
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaCassetto.cbStudiChange(Sender: TObject);
begin
  LoadMobili;
end;

procedure TfrmCreaCassetto.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCreaCassetto.btnApplicaClick(Sender: TObject);
begin
  if (Trim(edtCodice.Text) = EMPTYSTR) or (cbMobili.ItemIndex = -1) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteCassetto(edtCodice.Text) then ShowMessage(MSG_COD_CASSETTO_ESISTENTE)
    else
    begin
      AddCassetto;
      LoadStudi;
      ResetCampi;
    end;
  end;
end;

procedure TfrmCreaCassetto.btnOKClick(Sender: TObject);
begin
  if (Trim(edtCodice.Text) = EMPTYSTR) or (cbMobili.ItemIndex = -1) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteCassetto(edtCodice.Text) then ShowMessage(MSG_COD_CASSETTO_ESISTENTE)
    else
    begin
      AddCassetto;
      Close;
    end;
  end;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaCassetto.ResetCampi;
begin
  cbMobili.Clear;
  edtCodice.Text := EMPTYSTR;
  edtCodice.SetFocus;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmCreaCassetto.LoadMobili;
var sel: string;
begin
  sel := hsStudi.GetKey(cbStudi.ItemIndex);
  hsMobili := THashTable.Create;
  cbMobili.Clear;
  qrQuery.SQL.Text := 'SELECT * FROM [Mobili] WHERE [CodStudio] = ' + QuotedStr(sel) + ' ORDER BY [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsMobili.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbMobili.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbMobili.ItemIndex := -1;
end;

procedure TfrmCreaCassetto.LoadStudi;
begin
  hsStudi := THashTable.Create;
  cbStudi.Clear;
  qrQuery.SQL.Text := 'SELECT * FROM [Studi] ORDER BY [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsStudi.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbStudi.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbStudi.ItemIndex := -1;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmCreaCassetto.AddCassetto;
var sel: string;
begin
  try
    sel := hsMobili.GetKey(cbMobili.ItemIndex);
    tblCassetti.Active := True;
    tblCassetti.Insert;
    tblCassetti.FieldByName('Codice').AsString := edtCodice.Text;
    tblCassetti.FieldByName('CodMobile').AsString := sel;
    tblCassetti.FieldByName('CodAssociazioneAS').AsString := '0';    
    tblCassetti.Post;
    tblCassetti.Active := False;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmCreaCassetto.EsisteCassetto(CodCassetto: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Codice] FROM [Cassetti] ' +
                      'WHERE [Codice] = ' + QuotedStr(CodCassetto);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  EsisteCassetto := res;
end;

end.
