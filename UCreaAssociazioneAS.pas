unit UCreaAssociazioneAS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, TextLabeledEdit, ADODB, DB;

type
  TfrmCreaAssociazioneAS = class(TForm)
    img1: TImage;
    gbInfo: TGroupBox;
    edtNome: TTextLabeledEdit;
    btnApplica: TButton;
    btnOK: TButton;
    btnAnnulla: TButton;
    cbAssistenti: TComboBox;
    lblInfo1: TLabel;
    cbSostituti: TComboBox;
    lblInfo2: TLabel;
    tblAssociazioneAS: TADOTable;
    qrQuery: TADOQuery;
    procedure FormShow(Sender: TObject);
    procedure btnApplicaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadAssistenti;
    procedure LoadSostituti;
    procedure ResetCampi;
    procedure AddAssociazioneAS;
    function GetPosizioneMax: Integer;
  end;

var
  frmCreaAssociazioneAS: TfrmCreaAssociazioneAS;

implementation

uses dmConnection, UHashTable, UMessaggi, UAssociaAssistentiSostituti;

{$R *.dfm}

{ TfrmCreaAssociazioneAS }

var
  hsAssistenti, hsSostituti: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaAssociazioneAS.FormShow(Sender: TObject);
begin
  LoadAssistenti;
  LoadSostituti;
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaAssociazioneAS.btnApplicaClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (cbAssistenti.ItemIndex = -1) or
     (cbSostituti.ItemIndex = -1) then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    AddAssociazioneAS;
    frmAssociaAssistentiSostituti.AggiornaTabellaAssociazioniAS;
    LoadAssistenti;
    LoadSostituti;
    ResetCampi;
  end;
end;

procedure TfrmCreaAssociazioneAS.btnOKClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (cbAssistenti.ItemIndex = -1) or
     (cbSostituti.ItemIndex = -1) then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    AddAssociazioneAS;
    frmAssociaAssistentiSostituti.AggiornaTabellaAssociazioniAS;
    Close;
  end;
end;

procedure TfrmCreaAssociazioneAS.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaAssociazioneAS.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;
  edtNome.SetFocus;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmCreaAssociazioneAS.LoadAssistenti;
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

procedure TfrmCreaAssociazioneAS.LoadSostituti;
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


procedure TfrmCreaAssociazioneAS.AddAssociazioneAS;
var selAss, selSost: string;
begin
  try
    selAss := hsAssistenti.GetKey(cbAssistenti.ItemIndex);
    selSost := hsSostituti.GetKey(cbSostituti.ItemIndex);
    tblAssociazioneAS.Active := True;
    tblAssociazioneAS.Insert;
    tblAssociazioneAS.FieldByName('Posizione').AsInteger := GetPosizioneMax + 1;
    tblAssociazioneAS.FieldByName('Nome').AsString := edtNome.Text;
    tblAssociazioneAS.FieldByName('UsernameAssistente').AsString := selAss;
    tblAssociazioneAS.FieldByName('UsernameSostituto').AsString := selSost;
    tblAssociazioneAS.Post;
    tblAssociazioneAS.Active := False;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmCreaAssociazioneAS.GetPosizioneMax: Integer;
var Pos: Integer;
begin
  Pos := 0;
  qrQuery.SQL.Text := 'SELECT Max([Posizione]) AS [Posizione] FROM [AssociazioneAS]';
  qrQuery.Active := True;
  if not qrQuery.IsEmpty then Pos := qrQuery.FieldByName('Posizione').AsInteger;
  qrQuery.Active := False;
  GetPosizioneMax := Pos;
end;

end.
