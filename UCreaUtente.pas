unit UCreaUtente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ADODB, DB, ExtCtrls, TextLabeledEdit;

type
  TfrmCreaUtente = class(TForm)
    gbDatiPersonali: TGroupBox;
    edtCognome: TTextLabeledEdit;
    edtNome: TTextLabeledEdit;
    btnApplica: TButton;
    btnOK: TButton;
    btnAnnulla: TButton;
    qrUsername: TADOQuery;
    tblUtenti: TADOTable;
    gbDatiLogin: TGroupBox;
    cbLivello: TComboBox;
    edtPsw1: TTextLabeledEdit;
    edtUsername: TTextLabeledEdit;
    lblInfo1: TLabel;
    edtPsw2: TTextLabeledEdit;
    img1: TImage;
    procedure btnAnnullaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnApplicaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    function EsisteUtente(Username: string): Boolean;
    procedure AddUtente;
  end;

var
  frmCreaUtente: TfrmCreaUtente;

implementation

uses UMessaggi, dmConnection;

{$R *.dfm}

{ TfrmCreaUtente }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaUtente.FormShow(Sender: TObject);
begin
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaUtente.btnApplicaClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (Trim(edtCognome.Text) = EMPTYSTR) or
     (cbLivello.ItemIndex = 0) or (Trim(edtUsername.Text) = EMPTYSTR) or
     (Trim(edtPsw1.Text) = EMPTYSTR) or (Trim(edtPsw2.Text) = EMPTYSTR) then

    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if Trim(edtPsw1.Text) <> Trim(edtPsw2.Text) then ShowMessage(MSG_CAMPI_PSW)
    else
    begin
      if EsisteUtente(edtUsername.Text) then ShowMessage(MSG_USERNAME_ESISTENTE)
      else
      begin
        AddUtente;
        ResetCampi;
      end;
    end;
  end;
end;

procedure TfrmCreaUtente.btnOKClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (Trim(edtCognome.Text) = EMPTYSTR) or
     (cbLivello.ItemIndex = 0) or (Trim(edtUsername.Text) = EMPTYSTR) or
     (Trim(edtPsw1.Text) = EMPTYSTR) or (Trim(edtPsw2.Text) = EMPTYSTR) then

    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if Trim(edtPsw1.Text) <> Trim(edtPsw2.Text) then ShowMessage(MSG_CAMPI_PSW)
    else
    begin
      if EsisteUtente(edtUsername.Text) then ShowMessage(MSG_USERNAME_ESISTENTE)
      else
      begin
        AddUtente;
        Close;
      end;
    end;
  end;
end;

procedure TfrmCreaUtente.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaUtente.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;
  edtCognome.Text := EMPTYSTR;
  edtUsername.Text := EMPTYSTR;
  edtPsw1.Text := EMPTYSTR;
  edtPsw2.Text := EMPTYSTR;
  cbLivello.ItemIndex := 0;
  edtNome.SetFocus;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmCreaUtente.AddUtente;
begin
  try
    tblUtenti.Active := True;
    tblUtenti.Insert;
    tblUtenti.FieldByName('Nome').AsString := edtNome.Text;
    tblUtenti.FieldByName('Cognome').AsString := edtCognome.Text;
    tblUtenti.FieldByName('Username').AsString := edtUsername.Text;
    tblUtenti.FieldByName('Password').AsString := edtPsw1.Text;
    tblUtenti.FieldByName('Livello').AsInteger := cbLivello.ItemIndex;
    tblUtenti.Post;
    tblUtenti.Active := False;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmCreaUtente.EsisteUtente(Username: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrUsername.SQL.Text := 'SELECT [Username] FROM [Utenti] ' +
                         'WHERE [Username] = ' + QuotedStr(Username);
  qrUsername.Active := True;
  if qrUsername.IsEmpty then res := False;
  qrUsername.Active := False;
  EsisteUtente := res;
end;

end.
