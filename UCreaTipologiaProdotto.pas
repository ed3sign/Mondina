unit UCreaTipologiaProdotto;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, TextLabeledEdit, ADODB, DB;

type
  TfrmCreaTipologiaProdotto = class(TForm)
    qrQuery: TADOQuery;
    tblTipologia: TADOTable;
    btnApplica: TButton;
    btnOK: TButton;
    btnAnnulla: TButton;
    img1: TImage;
    gbInfo: TGroupBox;
    edtNome: TTextLabeledEdit;
    procedure btnApplicaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function EsisteTipologia(Tipologia: string): Boolean;
    procedure ResetCampi;
    procedure AddTipologia;
  end;

var
  frmCreaTipologiaProdotto: TfrmCreaTipologiaProdotto;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ TfrmCreaTipologiaProdotto }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaTipologiaProdotto.FormShow(Sender: TObject);
begin
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaTipologiaProdotto.btnApplicaClick(Sender: TObject);
begin
  if Trim(edtNome.Text) = EMPTYSTR then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteTipologia(edtNome.Text) then ShowMessage(MSG_COD_TIPOLOGIA_ESISTENTE)
    else
    begin
      AddTipologia;
      ResetCampi;
    end;
  end;
end;

procedure TfrmCreaTipologiaProdotto.btnOKClick(Sender: TObject);
begin
  if Trim(edtNome.Text) = EMPTYSTR then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteTipologia(edtNome.Text) then ShowMessage(MSG_COD_TIPOLOGIA_ESISTENTE)
    else
    begin
      AddTipologia;
      Close;
    end;
  end;
end;

procedure TfrmCreaTipologiaProdotto.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaTipologiaProdotto.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;
  edtNome.SetFocus;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmCreaTipologiaProdotto.AddTipologia;
begin
  try
    tblTipologia.Active := True;
    tblTipologia.Insert;
    tblTipologia.FieldByName('Tipologia').AsString := edtNome.Text;
    tblTipologia.Post;
    tblTipologia.Active := False;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmCreaTipologiaProdotto.EsisteTipologia(Tipologia: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Tipologia] FROM [Tipologie_Prodotti] ' +
                      'WHERE [Tipologia] = ' + QuotedStr(Tipologia);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  EsisteTipologia := res;
end;

end.
