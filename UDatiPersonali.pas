unit UDatiPersonali;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, ExtCtrls, TextLabeledEdit;

type
  TfrmVisDatiPersonali = class(TForm)
    qrLogin: TADOQuery;
    btnOK: TButton;
    btnAnnulla: TButton;
    img1: TImage;
    gbDatiPersonali: TGroupBox;
    lblInfo1: TLabel;
    lblNome: TLabel;
    lblInfo2: TLabel;
    lblInfo3: TLabel;
    lblCognome: TLabel;
    lblUsername: TLabel;
    lblInfo4: TLabel;
    lblLivello: TLabel;
    gbModPassword: TGroupBox;
    edtNewPsw1: TTextLabeledEdit;
    edtNewPsw2: TTextLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure CambiaPassword;
  end;

var
  frmVisDatiPersonali: TfrmVisDatiPersonali;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmVisDatiPersonali.FormShow(Sender: TObject);
var liv: integer;
begin
  ResetCampi;
  qrLogin.SQL.Text := 'SELECT * FROM [Utenti] WHERE [Username] = ' + QuotedStr(Username);
  qrLogin.Active := True;

  lblNome.Caption := qrLogin.FieldByName('Nome').AsString;
  lblCognome.Caption := qrLogin.FieldByName('Cognome').AsString;
  lblUsername.Caption := qrLogin.FieldByName('Username').AsString;

  liv := qrLogin.FieldByName('Livello').AsInteger;
  if      liv = 1 then lblLivello.Caption := 'Amministratore'
  else if liv = 2 then lblLivello.Caption := 'Assistente - Sostituto';
  qrLogin.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmVisDatiPersonali.btnOKClick(Sender: TObject);
begin
  if (Trim(edtNewPsw1.Text) = EMPTYSTR) or (Trim(edtNewPsw2.Text) = EMPTYSTR) then
    MessageDlg('Inserire i campi richiesti.', mtWarning, [mbOk], 0)
  else
  begin
    if (Trim(edtNewPsw1.Text) <> Trim(edtNewPsw2.Text)) then
      ShowMessage(MSG_CAMPI_PSW)
    else
    begin
      CambiaPassword;
      Close;
    end;
  end;
end;

procedure TfrmVisDatiPersonali.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmVisDatiPersonali.ResetCampi;
begin
  edtNewPsw1.Text := EMPTYSTR;
  edtNewPsw2.Text := EMPTYSTR;
  edtNewPsw1.SetFocus;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmVisDatiPersonali.CambiaPassword;
begin
  try
    qrLogin.Active := True;
    qrLogin.Edit;
    qrLogin.FieldByName('Password').AsString := edtNewPsw1.Text;
    qrLogin.Post;
    qrLogin.Active := False;
    ShowMessage(MSG_PSW_MODIFICATA);
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
