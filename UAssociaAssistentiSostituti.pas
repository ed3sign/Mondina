unit UAssociaAssistentiSostituti;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, ADODB, Grids, DBGrids, StdCtrls, Spin,
  TextLabeledEdit;

type
  TfrmAssociaAssistentiSostituti = class(TForm)
    gbUtenti: TGroupBox;
    lblInfo3: TLabel;
    lblAssociazioneSel: TLabel;
    dgUtenti: TDBGrid;
    qrUtenti: TADOQuery;
    dsUtenti: TDataSource;
    qrQuery: TADOQuery;
    img1: TImage;
    btnSuGiu: TSpinButton;
    gbInfo: TGroupBox;
    gbModifica: TGroupBox;
    lblInfo1: TLabel;
    lblInfo2: TLabel;
    Bevel1: TBevel;
    edtNome: TTextLabeledEdit;
    cbAssistenti: TComboBox;
    cbSostituti: TComboBox;
    btnAnnulla: TButton;
    btnOK: TButton;
    btnChiudi: TButton;
    gbComandi: TGroupBox;
    btnModifica: TButton;
    btnElimina: TButton;
    btnSostituisciUtente: TButton;
    btnNuovaAssociazione: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dgUtentiCellClick(Column: TColumn);
    procedure btnSuGiuDownClick(Sender: TObject);
    procedure btnSuGiuUpClick(Sender: TObject);
    procedure btnModificaClick(Sender: TObject);
    procedure btnEliminaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure btnNuovaAssociazioneClick(Sender: TObject);
    procedure btnSostituisciUtenteClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure ResetCampiSuGiu;
    procedure SpostaSu(Pos: Integer);
    procedure SpostaGiu(Pos: Integer);
    function GetPosizioneMax: Integer;
    procedure RiempiCampi;
    function AssociazioneCollegata(CodAssociazione: string): Boolean;
    procedure ModificaRecord;
    procedure CancellaRecord;
    procedure LoadAssistenti;
    procedure LoadSostituti;
    procedure AggiornaTabellaAssociazioniAS;    
  end;

var
  frmAssociaAssistentiSostituti: TfrmAssociaAssistentiSostituti;

implementation

uses UMessaggi, UHashTable, UCreaAssociazioneAS, USostituisciUtente;

{$R *.dfm}

var
  hsAssistenti, hsSostituti: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAssociaAssistentiSostituti.FormShow(Sender: TObject);
begin
  qrUtenti.SQL.Text := 'SELECT DISTINCT ([AssociazioneAS].[Codice]), ' +
                               '[AssociazioneAS].[Posizione], [AssociazioneAS].[Nome], ' +
                               '[qrAssistente].[NominativoAssistente], [qrSostituto].[NominativoSostituto] ' +
                       'FROM [AssociazioneAS], ( ' +
                            'SELECT [Utenti].[Cognome] + '' '' + [Utenti].[Nome] AS [NominativoAssistente], [Utenti].[Username] ' +
                            'FROM [AssociazioneAS] INNER JOIN [Utenti] ON [AssociazioneAS].[UsernameAssistente]=[Utenti].[Username] ' +
                            ') AS [qrAssistente], ( ' +
                            'SELECT [Utenti].[Cognome] + '' '' + [Utenti].[Nome] AS [NominativoSostituto], [Utenti].[Username] ' +
                            'FROM [AssociazioneAS] INNER JOIN [Utenti] ON [AssociazioneAS].[UsernameSostituto]=[Utenti].[Username] ' +
                            ') AS [qrSostituto] ' +
                       'WHERE [AssociazioneAS].[UsernameAssistente] = [qrAssistente].[Username] AND ' +
                             '[AssociazioneAS].[UsernameSostituto] = [qrSostituto].[Username] ' +
                       'ORDER BY [AssociazioneAS].[Posizione]';

  qrUtenti.Active := True;
  ResetCampi;
end;

procedure TfrmAssociaAssistentiSostituti.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrUtenti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAssociaAssistentiSostituti.dgUtentiCellClick(
  Column: TColumn);
begin
  if not qrUtenti.IsEmpty then
  begin
    lblAssociazioneSel.Caption := qrUtenti.FieldByName('Nome').AsString;
    btnSuGiu.Visible := True;
    gbModifica.Visible := False;
    gbComandi.Visible := True;
  end;
end;

procedure TfrmAssociaAssistentiSostituti.btnSuGiuDownClick(
  Sender: TObject);
var Pos: Integer;
begin
  Pos := qrUtenti.FieldByName('Posizione').AsInteger;
  if Pos < GetPosizioneMax then
  begin
    SpostaGiu(Pos);
    ResetCampiSuGiu;
  end;
end;

procedure TfrmAssociaAssistentiSostituti.btnSuGiuUpClick(Sender: TObject);
var Pos: Integer;
begin
  Pos := qrUtenti.FieldByName('Posizione').AsInteger;
  if Pos > 1 then
  begin
    SpostaSu(Pos);
    ResetCampiSuGiu;
  end;
end;

procedure TfrmAssociaAssistentiSostituti.btnModificaClick(Sender: TObject);
begin
  RiempiCampi;
  gbComandi.Visible := False;
  btnSuGiu.Visible := False;
  gbModifica.Visible := True;
end;

procedure TfrmAssociaAssistentiSostituti.btnEliminaClick(Sender: TObject);
var
  ris: Integer;
  CodAssociazione: string;
begin
  gbComandi.Visible := False;
  btnSuGiu.Visible := False;
  ris := MessageDlg(MSG_ELIMINA_RECORD, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
    CodAssociazione := qrUtenti.FieldByName('Codice').AsString;
    if AssociazioneCollegata(CodAssociazione) then Showmessage(MSG_ASSOCIAZIONE_COLLEGATA)
    else CancellaRecord;
  end;
  lblAssociazioneSel.Caption := EMPTYSTR;
end;

procedure TfrmAssociaAssistentiSostituti.btnOKClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    ModificaRecord;
    gbModifica.Visible := False;
    lblAssociazioneSel.Caption := EMPTYSTR;
  end;
end;

procedure TfrmAssociaAssistentiSostituti.btnAnnullaClick(Sender: TObject);
begin
  gbModifica.Visible := False;
  lblAssociazioneSel.Caption := EMPTYSTR;
end;

procedure TfrmAssociaAssistentiSostituti.btnNuovaAssociazioneClick(
  Sender: TObject);
begin
  ResetCampi;
  frmCreaAssociazioneAS.ShowModal;
end;

procedure TfrmAssociaAssistentiSostituti.btnSostituisciUtenteClick(
  Sender: TObject);
begin
  ResetCampi;
  frmSostituisciUtente.ShowModal;
end;

procedure TfrmAssociaAssistentiSostituti.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAssociaAssistentiSostituti.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;
  cbAssistenti.Clear;
  cbSostituti.Clear;

  lblAssociazioneSel.Caption := EMPTYSTR;
  gbModifica.Visible := False;
  gbComandi.Visible := False;
  btnSuGiu.Visible := False;
end;

procedure TfrmAssociaAssistentiSostituti.ResetCampiSuGiu;
begin
  lblAssociazioneSel.Caption := EMPTYSTR;
  gbComandi.Visible := False;
  btnSuGiu.Visible := False;
  btnChiudi.SetFocus;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmAssociaAssistentiSostituti.LoadAssistenti;
begin
  hsAssistenti := THashTable.Create;
  cbAssistenti.Clear;
  qrQuery.SQL.Text := 'SELECT [Username], [Cognome] + '' '' + [Nome] AS [Nominativo] ' +
                      'FROM [Utenti] ' +
                      'WHERE [Livello] = 2 ' +
                      'ORDER BY [Cognome], [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsAssistenti.Add(qrQuery.FieldByName('Username').AsString, qrQuery.FieldByName('Nominativo').AsString);
    cbAssistenti.Items.Add(qrQuery.FieldByName('Nominativo').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbAssistenti.ItemIndex := -1;
end;

procedure TfrmAssociaAssistentiSostituti.LoadSostituti;
begin
  hsSostituti := THashTable.Create;
  cbSostituti.Clear;
  qrQuery.SQL.Text := 'SELECT [Username], [Cognome] + '' '' + [Nome] AS [Nominativo] ' +
                      'FROM [Utenti] ' +
                      'WHERE [Livello] = 2 ' +
                      'ORDER BY [Cognome], [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsSostituti.Add(qrQuery.FieldByName('Username').AsString, qrQuery.FieldByName('Nominativo').AsString);
    cbSostituti.Items.Add(qrQuery.FieldByName('Nominativo').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbSostituti.ItemIndex := -1;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

function TfrmAssociaAssistentiSostituti.GetPosizioneMax: Integer;
var Pos: Integer;
begin
  Pos := 0;
  qrQuery.SQL.Text := 'SELECT Max([Posizione]) AS [Posizione] FROM [AssociazioneAS]';
  qrQuery.Active := True;
  if not qrQuery.IsEmpty then Pos := qrQuery.FieldByName('Posizione').AsInteger;
  qrQuery.Active := False;
  GetPosizioneMax := Pos;
end;

procedure TfrmAssociaAssistentiSostituti.SpostaGiu(Pos: Integer);
begin
  try
    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] SET [Posizione] = 0 WHERE [Posizione] = ' + IntToStr(Pos);
    qrQuery.ExecSQL;
    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] SET [Posizione] = ' + IntToStr(Pos) + ' WHERE [Posizione] = ' + IntToStr(Pos+1);
    qrQuery.ExecSQL;
    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] SET [Posizione] = ' + IntToStr(Pos+1) + ' WHERE [Posizione] = 0';
    qrQuery.ExecSQL;
    qrUtenti.Active := False;
    qrUtenti.Active := True;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAssociaAssistentiSostituti.SpostaSu(Pos: Integer);
begin
  try
    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] SET [Posizione] = 0 WHERE [Posizione] = ' + IntToStr(Pos);
    qrQuery.ExecSQL;
    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] SET [Posizione] = ' + IntToStr(Pos) + ' WHERE [Posizione] = ' + IntToStr(Pos-1);
    qrQuery.ExecSQL;
    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] SET [Posizione] = ' + IntToStr(Pos-1) + ' WHERE [Posizione] = 0';
    qrQuery.ExecSQL;
    qrUtenti.Active := False;
    qrUtenti.Active := True;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmAssociaAssistentiSostituti.AssociazioneCollegata(CodAssociazione: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [CodAssociazioneAS] FROM [Cassetti] ' +
                      'WHERE [CodAssociazioneAS] = ' + CodAssociazione;
  qrQuery.Active := True;
  if qrQuery.IsEmpty then
  begin
    qrQuery.Active := False;
    qrQuery.SQL.Text := 'SELECT [CodAssociazioneAS] FROM [Prodotti_Richiesti_Studi] ' +
                        'WHERE [CodAssociazioneAS] = ' + CodAssociazione;
    qrQuery.Active := True;
    if qrQuery.IsEmpty then res := False;
    qrQuery.Active := False;
  end;
  qrQuery.Active := False;
  AssociazioneCollegata := res;
end;

procedure TfrmAssociaAssistentiSostituti.RiempiCampi;
var nome: String;
begin
  LoadAssistenti;
  LoadSostituti;
  edtNome.Text := qrUtenti.FieldByName('Nome').AsString;;
  nome := qrUtenti.FieldByName('NominativoAssistente').AsString;
  cbAssistenti.ItemIndex := cbAssistenti.Items.IndexOf(nome);
  nome := qrUtenti.FieldByName('NominativoSostituto').AsString;
  cbSostituti.ItemIndex := cbSostituti.Items.IndexOf(nome);
end;

procedure TfrmAssociaAssistentiSostituti.CancellaRecord;
var Pos: string;
begin
  try
    Pos := qrUtenti.FieldByName('Posizione').AsString;
    qrUtenti.Delete;
    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] ' +
                        'SET [Posizione] = [Posizione]-1 ' +
                        'WHERE [Posizione] > ' + Pos;
    qrQuery.ExecSQL;
    qrUtenti.Active := False;
    qrUtenti.Active := True;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAssociaAssistentiSostituti.ModificaRecord;
var UserAss, UserSost, CodAssociazione: string;
begin
  try
    UserAss := hsAssistenti.GetKey(cbAssistenti.ItemIndex);
    UserSost := hsSostituti.GetKey(cbSostituti.ItemIndex);
    CodAssociazione := qrUtenti.FieldByName('Codice').AsString;
    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] ' +
                        'SET [Nome] = ' + QuotedStr(edtNome.Text) + ', ' +
                            '[UsernameAssistente] = ' + QuotedStr(UserAss) + ', ' +
                            '[UsernameSostituto] = ' + QuotedStr(UserSost) + ' ' +
                            'WHERE [Codice] = ' + CodAssociazione;
    qrQuery.ExecSQL;
    qrUtenti.Active := False;
    qrUtenti.Active := True;    
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAssociaAssistentiSostituti.AggiornaTabellaAssociazioniAS;
begin
  qrUtenti.Active := False;
  qrUtenti.Active := True;
end;

end.
