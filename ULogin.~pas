unit ULogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, TextLabeledEdit, DB, ADODB;

type
  TfrmLogin = class(TForm)
    btnAccedi: TButton;
    qrLogin: TADOQuery;
    btnAnnulla: TButton;
    gbContenitore: TGroupBox;
    edtPassword: TTextLabeledEdit;
    edtUsername: TTextLabeledEdit;
    img1: TImage;
    procedure btnAccediClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
  end;

var
  frmLogin: TfrmLogin;

implementation

uses dmConnection, UMain, UModAccesso, UMessaggi;

{$R *.dfm}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmLogin.btnAccediClick(Sender: TObject);
begin
  if (Trim(edtUsername.Text) = EMPTYSTR) or (Trim(edtPassword.text) = EMPTYSTR) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    qrLogin.SQL.Text := 'SELECT [Username], [Cognome] + '' '' + [Nome] AS [Nominativo], [Livello] ' +
                        'FROM [Utenti] ' +
                        'WHERE [Username] = ' + QuotedStr(edtUsername.Text) + ' AND ' +
                              '[Password] = ' + QuotedStr(edtPassword.Text);
    qrLogin.Active := True;

    if qrLogin.IsEmpty then ShowMessage(MSG_NO_LOGIN)
    else
    begin
      frmMain.Caption := 'Magazzino - ' + qrLogin.FieldByName('Nominativo').AsString + ' - ';
      Username := qrLogin.FieldByName('Username').AsString;
      LivelloUtente := qrLogin.FieldByName('Livello').AsString;
      CodAssociazioneAS := '0';
      qrLogin.Active := False;

      if LivelloUtente = '1' then
      begin
        frmMain.Caption := frmMain.Caption + 'Amministratore';
        frmMain.ImpostaPermessi('1');
      end
      else if LivelloUtente = '2' then frmLoginModAccesso.ShowModal;
      Close;
    end;
  end;
end;

procedure TfrmLogin.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmLogin.ResetCampi;
begin
  edtUsername.Text := EMPTYSTR;
  edtPassword.Text := EMPTYSTR;
  edtUsername.SetFocus;
end;

end.
