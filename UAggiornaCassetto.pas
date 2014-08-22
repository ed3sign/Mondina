unit UAggiornaCassetto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ADODB, DB, StdCtrls, ExtCtrls, TextLabeledEdit, Grids, DBGrids;

type
  TfrmAggiornaCassetto = class(TForm)
    img1: TImage;
    btnChiudi: TButton;
    gbCassetti: TGroupBox;
    lblInfo2: TLabel;
    lblCassettoSel: TLabel;
    dgCassetti: TDBGrid;
    gbInfo: TGroupBox;
    gbComandi: TGroupBox;
    btnModifica: TButton;
    btnElimina: TButton;
    gbModifica: TGroupBox;
    Bevel1: TBevel;
    lblInfo1: TLabel;
    btnAnnulla: TButton;
    btnOK: TButton;
    cbStudi: TComboBox;
    dsCassetti: TDataSource;
    qrQuery: TADOQuery;
    cbMobili: TComboBox;
    Label1: TLabel;
    qrCassetti: TADOQuery;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dgCassettiCellClick(Column: TColumn);
    procedure btnModificaClick(Sender: TObject);
    procedure btnEliminaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
    procedure cbStudiChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure CancellaRecord;
    procedure ModificaRecord;
    procedure RiempiCampi;
    function CassettoCollegato(CodCassetto: string): Boolean;
    function GetNomeStudioDelCassetto(CodCassetto: string): string;
    function GetNomeMobileDelCassetto(CodCassetto: string): string;
    procedure LoadStudi;
    procedure LoadMobili;
  end;

var
  frmAggiornaCassetto: TfrmAggiornaCassetto;

implementation

uses dmConnection, UMessaggi, UHashTable;

{$R *.dfm}

var
  hsStudi, hsMobili: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAggiornaCassetto.FormShow(Sender: TObject);
begin
  ResetCampi;
  qrCassetti.SQL.Text := 'SELECT * FROM [Cassetti] ORDER BY [CodMobile], [Codice]';
  qrCassetti.Active := True;
end;

procedure TfrmAggiornaCassetto.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrCassetti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAggiornaCassetto.btnModificaClick(Sender: TObject);
begin
  RiempiCampi;
  gbComandi.Visible := False;
  gbModifica.Visible := True;
end;

procedure TfrmAggiornaCassetto.btnEliminaClick(Sender: TObject);
var ris: Integer;
begin
  gbComandi.Visible := False;
  ris := MessageDlg(MSG_ELIMINA_RECORD, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
   if CassettoCollegato(lblCassettoSel.Caption) then Showmessage(MSG_CASSETTO_COLLEGATO)
   else CancellaRecord;
  end;
  lblCassettoSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaCassetto.btnOKClick(Sender: TObject);
begin
  ModificaRecord;
  gbModifica.Visible := False;
  lblCassettoSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaCassetto.btnAnnullaClick(Sender: TObject);
begin
  gbModifica.Visible := False;
  lblCassettoSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaCassetto.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAggiornaCassetto.dgCassettiCellClick(Column: TColumn);
begin
  if not qrCassetti.IsEmpty then
  begin
    lblCassettoSel.Caption := qrCassetti.FieldByName('Codice').AsString;
    gbModifica.Visible := False;
    gbComandi.Visible := True;
  end;
end;

procedure TfrmAggiornaCassetto.cbStudiChange(Sender: TObject);
begin
  LoadMobili;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAggiornaCassetto.ResetCampi;
begin
  cbStudi.Clear;
  cbMobili.Clear;
  lblCassettoSel.Caption := EMPTYSTR;
  gbComandi.Visible := False;
  gbModifica.Visible := False;
  btnChiudi.SetFocus;  
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmAggiornaCassetto.LoadMobili;
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
  cbMobili.ItemIndex := 0;
end;

procedure TfrmAggiornaCassetto.LoadStudi;
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
  cbStudi.ItemIndex := 0;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmAggiornaCassetto.ModificaRecord;
var sel: string;
begin
  try
    sel := hsMobili.GetKey(cbMobili.ItemIndex);
    qrCassetti.Edit;
    qrCassetti.FieldByName('CodMobile').AsString := sel;
    qrCassetti.Post;
    qrCassetti.Active := False;
    qrCassetti.Active := True;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAggiornaCassetto.CancellaRecord;
begin
  try
    qrCassetti.Delete;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmAggiornaCassetto.CassettoCollegato(CodCassetto: string): Boolean;
var
  res: Boolean;
  CodAssociazioneAS: string;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [CodAssociazioneAS] FROM [Cassetti] ' +
                      'WHERE [Codice] = ' + QuotedStr(CodCassetto);
  qrQuery.Active := True;
  codAssociazioneAS := qrQuery.FieldByName('CodAssociazioneAS').AsString;
  if CodAssociazioneAS = '0' then
  begin
    qrQuery.Active := False;
    qrQuery.SQL.Text := 'SELECT [CodCassetto] FROM [Prodotti_Cassetti] ' +
                        'WHERE [CodCassetto] = ' + QuotedStr(CodCassetto);
    qrQuery.Active := True;
    if qrQuery.IsEmpty then res := False;
    qrQuery.Active := False;
  end;
  qrQuery.Active := False;
  CassettoCollegato := res;
end;

function TfrmAggiornaCassetto.GetNomeMobileDelCassetto(CodCassetto: string): string;
var res: string;
begin
  res := '';
  qrQuery.SQL.Text := 'SELECT [Mobili].[Nome] ' +
                      'FROM [Mobili] INNER JOIN [Cassetti] ' +
                           'ON [Mobili].[Codice] = [Cassetti].[CodMobile] ' +
                      'WHERE [Cassetti].[Codice] = ' + QuotedStr(CodCassetto);

  qrQuery.Active := True;
  if not qrQuery.IsEmpty then res := qrQuery.FieldByName('Nome').AsString;
  qrQuery.Active := False;
  GetNomeMobileDelCassetto := res;
end;

function TfrmAggiornaCassetto.GetNomeStudioDelCassetto(CodCassetto: string): string;
var res: string;
begin
  res := '';
  qrQuery.SQL.Text := 'SELECT [Studi].[Nome] ' +
                      'FROM ([Studi] INNER JOIN [Mobili] ON [Studi].[Codice] = [Mobili].[CodStudio]) ' +
                            'INNER JOIN [Cassetti] ON [Mobili].[Codice] = [Cassetti].[CodMobile] ' +
                      'WHERE [Cassetti].[Codice] = ' + QuotedStr(CodCassetto);
  qrQuery.Active := True;
  if not qrQuery.IsEmpty then res := qrQuery.FieldByName('Nome').AsString;
  qrQuery.Active := False;
  GetNomeStudioDelCassetto := res;
end;

procedure TfrmAggiornaCassetto.RiempiCampi;
var codCassetto, nomeStudio, nomeCassetto: string;
begin
  codCassetto := lblCassettoSel.Caption;
  nomeStudio := GetNomeStudioDelCassetto(codCassetto);
  nomeCassetto := GetNomeMobileDelCassetto(codCassetto);

  LoadStudi;
  cbStudi.ItemIndex := cbStudi.Items.IndexOf(nomeStudio);
  LoadMobili;
  cbMobili.ItemIndex := cbMobili.Items.IndexOf(nomeCassetto);
end;

end.
