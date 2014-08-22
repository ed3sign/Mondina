unit UModAccesso;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, ADODB;

type
  TfrmLoginModAccesso = class(TForm)
    qrQuery: TADOQuery;
    gbAssociazione: TGroupBox;
    cbEntra: TButton;
    cbAssociazione: TComboBox;
    gbInfo: TGroupBox;
    btnAssistente: TButton;
    btnSostituto: TButton;
    procedure btnAssistenteClick(Sender: TObject);
    procedure btnSostitutoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure cbEntraClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function EsisteUtenteAssistente(Username: string): Boolean;
    function EsisteUtenteSostituto(Username: string): Boolean;
    procedure LoadNomeAssociazioneAssistenti;
    procedure LoadNomeAssociazioneSostituti;    
    procedure ResetCampi;
  end;

var
  frmLoginModAccesso: TfrmLoginModAccesso;

implementation

uses UMain, dmConnection, UHashTable;

{$R *.dfm}

var
  hsAssociazione: THashTable;
  StatoUtente: string;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmLoginModAccesso.FormShow(Sender: TObject);
begin
  StatoUtente := EMPTYSTR;
  ResetCampi;
  if EsisteUtenteAssistente(Username) then btnAssistente.Enabled := True;
  if EsisteUtenteSostituto(Username) then btnSostituto.Enabled := True;
end;

procedure TfrmLoginModAccesso.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if CodAssociazioneAS = EMPTYSTR then
  begin
    frmMain.Caption := frmMain.Caption + 'Nessun Accesso Come Assistente - Sostituto';
    frmMain.ImpostaPermessi('0');
  end
  else
  begin
    frmMain.Caption := frmMain.Caption + StatoUtente + ' (' + cbAssociazione.Items[cbAssociazione.ItemIndex] + ')';
    frmMain.ImpostaPermessi('2');
  end;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmLoginModAccesso.btnAssistenteClick(Sender: TObject);
begin
  StatoUtente := 'Assistente';
  LoadNomeAssociazioneAssistenti;
  gbAssociazione.Visible := True;
end;

procedure TfrmLoginModAccesso.btnSostitutoClick(Sender: TObject);
begin
  StatoUtente := 'Sostituto';
  LoadNomeAssociazioneSostituti;
  gbAssociazione.Visible := True;
end;

procedure TfrmLoginModAccesso.cbEntraClick(Sender: TObject);
var sel: string;
begin
  sel := hsAssociazione.GetKey(cbAssociazione.ItemIndex);
  CodAssociazioneAS := sel;
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmLoginModAccesso.ResetCampi;
begin
  btnAssistente.Enabled := False;
  btnSostituto.Enabled := False;
  gbAssociazione.Visible := False;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmLoginModAccesso.LoadNomeAssociazioneAssistenti;
begin
  hsAssociazione := THashTable.Create;
  cbAssociazione.Clear;
  qrQuery.SQL.Text := 'SELECT [Codice], [Nome] FROM [AssociazioneAS] ' +
                      'WHERE [UsernameAssistente] = ' + QuotedStr(Username) + ' ' +
                      'ORDER BY [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsAssociazione.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbAssociazione.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbAssociazione.ItemIndex := 0;
end;

procedure TfrmLoginModAccesso.LoadNomeAssociazioneSostituti;
begin
  hsAssociazione := THashTable.Create;
  cbAssociazione.Clear;
  qrQuery.SQL.Text := 'SELECT [Codice], [Nome] FROM [AssociazioneAS] ' +
                      'WHERE [UsernameSostituto] = ' + QuotedStr(Username) + ' ' +
                      'ORDER BY [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsAssociazione.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbAssociazione.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbAssociazione.ItemIndex := 0;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

function TfrmLoginModAccesso.EsisteUtenteAssistente(Username: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Codice] FROM [AssociazioneAS] ' +
                      'WHERE [UsernameAssistente] = ' + QuotedStr(Username);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  EsisteUtenteAssistente := res;
end;

function TfrmLoginModAccesso.EsisteUtenteSostituto(Username: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Codice] FROM [AssociazioneAS] ' +
                      'WHERE [UsernameSostituto] = ' + QuotedStr(Username);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  EsisteUtenteSostituto := res;
end;

end.
