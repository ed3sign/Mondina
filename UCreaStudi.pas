unit UCreaStudi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ADODB, DB, StdCtrls, ExtCtrls, TextLabeledEdit;

type
  TfrmCreaStudio = class(TForm)
    btnApplica: TButton;
    btnOK: TButton;
    btnAnnulla: TButton;
    qrQuery: TADOQuery;
    tblStudi: TADOTable;
    img1: TImage;
    gbInfo: TGroupBox;
    edtCodice: TTextLabeledEdit;
    edtNome: TTextLabeledEdit;
    procedure btnApplicaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function EsisteStudio(CodStudio: string): Boolean;
    procedure ResetCampi;
    procedure AddStudio;
  end;

var
  frmCreaStudio: TfrmCreaStudio;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ TfrmCreaStudio }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaStudio.FormShow(Sender: TObject);
begin
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaStudio.btnApplicaClick(Sender: TObject);
begin
  if (Trim(edtCodice.Text) = EMPTYSTR) or (Trim(edtNome.Text) = EMPTYSTR) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteStudio(edtCodice.Text) then ShowMessage(MSG_COD_STUDIO_ESISTENTE)
    else
    begin
      AddStudio;
      ResetCampi;
    end;
  end;
end;

procedure TfrmCreaStudio.btnOKClick(Sender: TObject);
begin
  if (Trim(edtCodice.Text) = EMPTYSTR) or (Trim(edtNome.Text) = EMPTYSTR) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteStudio(edtCodice.Text) then ShowMessage(MSG_COD_STUDIO_ESISTENTE)
    else
    begin
      AddStudio;
      Close;
    end;
  end;
end;

procedure TfrmCreaStudio.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaStudio.ResetCampi;
begin
  edtCodice.Text := EMPTYSTR;
  edtNome.Text := EMPTYSTR;
  edtCodice.SetFocus;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmCreaStudio.AddStudio;
begin
  try
    tblStudi.Active := True;
    tblStudi.Insert;
    tblStudi.FieldByName('Codice').AsString := edtCodice.Text;
    tblStudi.FieldByName('Nome').AsString := edtNome.Text;
    tblStudi.Post;
    tblStudi.Active := False;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmCreaStudio.EsisteStudio(CodStudio: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Codice] FROM [Studi] ' +
                      'WHERE [Codice] = ' + QuotedStr(CodStudio);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  EsisteStudio := res;
end;

end.
