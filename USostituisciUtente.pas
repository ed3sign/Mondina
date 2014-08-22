unit USostituisciUtente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ADODB, ExtCtrls;

type
  TfrmSostituisciUtente = class(TForm)
    gbInfo: TGroupBox;
    lblInfo1: TLabel;
    lblInfo2: TLabel;
    cbUtenti1: TComboBox;
    cbUtenti2: TComboBox;
    qrQuery: TADOQuery;
    btnOK: TButton;
    btnAnnulla: TButton;
    img1: TImage;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadUtenti1;
    procedure LoadUtenti2;
    function UtenteAssociato(Username: string): Boolean;
    procedure SostituisciUtente;
  end;

var
  frmSostituisciUtente: TfrmSostituisciUtente;

implementation

uses dmConnection, UMessaggi, UHashTable, UAssociaAssistentiSostituti;

{$R *.dfm}

{ TfrmSostituisciUtente }

var
  hsUtenti1, hsUtenti2: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmSostituisciUtente.FormShow(Sender: TObject);
begin
  LoadUtenti1;
  LoadUtenti2;
  cbUtenti1.SetFocus;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmSostituisciUtente.btnOKClick(Sender: TObject);
var Username2: string;
begin
  if (cbUtenti1.ItemIndex = -1) or (cbUtenti2.ItemIndex = -1) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    Username2 := hsUtenti2.GetKey(cbUtenti2.ItemIndex);
    if UtenteAssociato(Username2) then ShowMessage(MSG_UTENTE_ASSOCIATO_SOSTITUISCI)
    else
    begin
      SostituisciUtente;
      frmAssociaAssistentiSostituti.AggiornaTabellaAssociazioniAS;
      Close;
    end;
  end;
end;

procedure TfrmSostituisciUtente.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmSostituisciUtente.LoadUtenti1;
begin
  hsUtenti1 := THashTable.Create;
  cbUtenti1.Clear;
  qrQuery.SQL.Text := 'SELECT [Username], [Cognome] + '' '' + [Nome] AS [Nominativo] ' +
                      'FROM [Utenti] ' +
                      'WHERE [Livello] = 2 ' +
                      'ORDER BY [Cognome], [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsUtenti1.Add(qrQuery.FieldByName('Username').AsString, qrQuery.FieldByName('Nominativo').AsString);
    cbUtenti1.Items.Add(qrQuery.FieldByName('Nominativo').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbUtenti1.ItemIndex := -1;
end;

procedure TfrmSostituisciUtente.LoadUtenti2;
begin
  hsUtenti2 := THashTable.Create;
  cbUtenti2.Clear;
  qrQuery.SQL.Text := 'SELECT [Username], [Cognome] + '' '' + [Nome] AS [Nominativo] ' +
                      'FROM [Utenti] ' +
                      'WHERE [Livello] = 2 ' +
                      'ORDER BY [Cognome], [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsUtenti2.Add(qrQuery.FieldByName('Username').AsString, qrQuery.FieldByName('Nominativo').AsString);
    cbUtenti2.Items.Add(qrQuery.FieldByName('Nominativo').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbUtenti2.ItemIndex := -1;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmSostituisciUtente.SostituisciUtente;
var Username1, Username2: string;
begin
  try
    Username1 := hsUtenti1.GetKey(cbUtenti1.ItemIndex);
    Username2 := hsUtenti2.GetKey(cbUtenti2.ItemIndex);
    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] ' +
                        'SET [UsernameAssistente] = ' + QuotedStr(Username2) + ' ' +
                        'WHERE [UsernameAssistente] = ' + QuotedStr(Username1);
    qrQuery.ExecSQL;

    qrQuery.SQL.Text := 'UPDATE [AssociazioneAS] ' +
                        'SET [UsernameSostituto] = ' + QuotedStr(Username2) + ' ' +
                        'WHERE [UsernameSostituto] = ' + QuotedStr(Username1);
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmSostituisciUtente.UtenteAssociato(Username: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Codice] FROM [AssociazioneAS] ' +
                      'WHERE [UsernameAssistente] = ' + QuotedStr(Username) + ' OR ' +
                            '[UsernameSostituto] = ' + QuotedStr(Username);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  UtenteAssociato := res;
end;

end.
