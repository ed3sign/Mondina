unit UAggiornaUtente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, Grids, DBGrids, ExtCtrls, StdCtrls, TextLabeledEdit;

type
  TfrmAggiornaUtente = class(TForm)
    dsUtenti: TDataSource;
    btnChiudi: TButton;
    qrUtenti: TADOQuery;
    qrQuery: TADOQuery;
    img1: TImage;
    Utenti: TGroupBox;
    dgUtenti: TDBGrid;
    lblInfo2: TLabel;
    lblUtenteSel: TLabel;
    gbInfo: TGroupBox;
    gbComandi: TGroupBox;
    btnModifica: TButton;
    btnElimina: TButton;
    gbModifica: TGroupBox;
    gbDatiPersonali: TGroupBox;
    edtCognome: TTextLabeledEdit;
    edtNome: TTextLabeledEdit;
    gbDatiLogin: TGroupBox;
    lblInfo1: TLabel;
    cbLivello: TComboBox;
    edtPsw1: TTextLabeledEdit;
    edtPsw2: TTextLabeledEdit;
    btnOK: TButton;
    btnAnnulla: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dgUtentiCellClick(Column: TColumn);
    procedure btnModificaClick(Sender: TObject);
    procedure btnEliminaClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure CancellaRecord;
    procedure ModificaRecord;
    procedure RiempiCampi;
    function UtenteAssociato(Username: string): Boolean;
  end;

var
  frmAggiornaUtente: TfrmAggiornaUtente;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAggiornaUtente.FormShow(Sender: TObject);
begin
  ResetCampi;
  qrUtenti.SQL.Text := 'SELECT * FROM [Utenti] ' +
                       'WHERE [Username] <> ''admin'' ORDER BY [Cognome], [Nome]';
  qrUtenti.Active := True;
end;

procedure TfrmAggiornaUtente.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrUtenti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAggiornaUtente.dgUtentiCellClick(Column: TColumn);
begin
  if not qrUtenti.IsEmpty then
  begin
    lblUtenteSel.Caption := qrUtenti.FieldByName('Username').AsString;
    gbModifica.Visible := False;
    gbComandi.Visible := True;
  end;
end;

procedure TfrmAggiornaUtente.btnModificaClick(Sender: TObject);
begin
  RiempiCampi;
  gbComandi.Visible := False;
  gbModifica.Visible := True;
end;

procedure TfrmAggiornaUtente.btnEliminaClick(Sender: TObject);
var ris: Integer;
begin
  gbComandi.Visible := False;
  ris := MessageDlg(MSG_ELIMINA_RECORD, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
   if UtenteAssociato(lblUtenteSel.Caption) then ShowMessage(MSG_UTENTE_ASSOCIATO_ELIMINA)
   else CancellaRecord;
  end;
  lblUtenteSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaUtente.btnAnnullaClick(Sender: TObject);
begin
  gbModifica.Visible := False;
  lblUtenteSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaUtente.btnOKClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (Trim(edtCognome.Text) = EMPTYSTR) or
     (Trim(edtPsw1.Text) = EMPTYSTR) or (Trim(edtPsw2.Text) = EMPTYSTR) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if Trim(edtPsw1.Text) <> Trim(edtPsw2.Text) then ShowMessage(MSG_CAMPI_PSW)
    else
    begin
      if (cbLivello.ItemIndex = 0) and
         (UtenteAssociato(lblUtenteSel.Caption)) then ShowMessage(MSG_UTENTE_ASSOCIATO_MODIFICA)
      else
      begin
        ModificaRecord;
        gbModifica.Visible := False;
        lblUtenteSel.Caption := EMPTYSTR;
      end;
    end;
  end;
end;

procedure TfrmAggiornaUtente.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAggiornaUtente.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;
  edtCognome.Text := EMPTYSTR;
  edtPsw1.Text := EMPTYSTR;
  edtPsw2.Text := EMPTYSTR;
  cbLivello.ItemIndex := 0;

  lblUtenteSel.Caption := EMPTYSTR;
  gbComandi.Visible := False;
  gbModifica.Visible := False;
  btnChiudi.SetFocus;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmAggiornaUtente.RiempiCampi;
begin
  edtNome.Text := qrUtenti.FieldByName('Nome').AsString;
  edtCognome.Text := qrUtenti.FieldByName('Cognome').AsString;
  edtPsw1.Text := qrUtenti.FieldByName('Password').AsString;
  edtPsw2.Text := qrUtenti.FieldByName('Password').AsString;
  cbLivello.ItemIndex := qrUtenti.FieldByName('Livello').AsInteger - 1;
end;

function TfrmAggiornaUtente.UtenteAssociato(Username: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Codice] FROM [AssociazioneAS] ' +
                      'WHERE [UsernameAssistente] = ' + QuotedStr(Username) + ' OR ' +
                            '[UsernameSostituto] = ' + QuotedStr(Username);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then
  begin
    qrQuery.Active := False;
    qrQuery.SQL.Text := 'SELECT [Username] FROM [Prodotti_Persi] ' +
                        'WHERE [Username] = ' + QuotedStr(Username);
    qrQuery.Active := True;
    if qrQuery.IsEmpty then res := False;
    qrQuery.Active := False;                              
  end;
  qrQuery.Active := False;
  UtenteAssociato := res;
end;

procedure TfrmAggiornaUtente.CancellaRecord;
begin
  try
    qrUtenti.Delete;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAggiornaUtente.ModificaRecord;
begin
  try
    qrUtenti.Edit;
    qrUtenti.FieldByName('Nome').AsString := edtNome.Text;
    qrUtenti.FieldByName('Cognome').AsString := edtCognome.Text;
    qrUtenti.FieldByName('Password').AsString := edtPsw1.Text;
    qrUtenti.FieldByName('Livello').AsInteger := cbLivello.ItemIndex + 1;
    qrUtenti.Post;
    qrUtenti.Active := False;
    qrUtenti.Active := True;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
