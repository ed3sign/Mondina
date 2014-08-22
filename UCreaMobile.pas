unit UCreaMobile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ADODB, DB, ExtCtrls, TextLabeledEdit;

type
  TfrmCreaMobile = class(TForm)
    btnApplica: TButton;
    btnOK: TButton;
    btnAnnulla: TButton;
    qrQuery: TADOQuery;
    tblMobili: TADOTable;
    img1: TImage;
    gbInfo: TGroupBox;
    edtCodice: TTextLabeledEdit;
    cbStudi: TComboBox;
    edtNome: TTextLabeledEdit;
    lblInfo1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnApplicaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadStudi;
    procedure ResetCampi;
    function EsisteMobile(CodMobile: string): Boolean;
    procedure AddMobile;
  end;

var
  frmCreaMobile: TfrmCreaMobile;

implementation

uses dmConnection, UMessaggi, UHashTable;

{$R *.dfm}

{ TfrmCreaMobile }

var
  hsStudi: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmCreaMobile.FormShow(Sender: TObject);
begin
  LoadStudi;
  ResetCampi;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmCreaMobile.btnApplicaClick(Sender: TObject);
begin
  if (Trim(edtCodice.Text) = EMPTYSTR) or (Trim(edtNome.Text) = EMPTYSTR) or
     (cbStudi.ItemIndex = -1) then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteMobile(edtCodice.Text) then ShowMessage(MSG_COD_MOBILE_ESISTENTE)
    else
    begin
      AddMobile;
      LoadStudi;
      ResetCampi;
    end;
  end;
end;

procedure TfrmCreaMobile.btnOKClick(Sender: TObject);
begin
  if (Trim(edtCodice.Text) = EMPTYSTR) or (Trim(edtNome.Text) = EMPTYSTR) or
     (cbStudi.ItemIndex = -1) then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    if EsisteMobile(edtCodice.Text) then ShowMessage(MSG_COD_MOBILE_ESISTENTE)
    else
    begin
      AddMobile;
      Close;
    end;
  end;
end;

procedure TfrmCreaMobile.btnAnnullaClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmCreaMobile.ResetCampi;
begin
  edtCodice.Text := EMPTYSTR;
  edtNome.Text := EMPTYSTR;
  edtCodice.SetFocus;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmCreaMobile.LoadStudi;
begin
  hsStudi := THashTable.Create;
  cbStudi.Clear;
  qrQuery.SQL.Text := 'SELECT * FROM [Studi] ORDER BY [Nome]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    hsStudi.Add(qrQuery.FieldByName('Codice').AsString, qrQuery.FieldByName('Nome').AsString);
    cbStudi.Items.Add(qrQuery.FieldByName('Nome').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbStudi.ItemIndex := -1;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmCreaMobile.AddMobile;
var sel: string;
begin
  try
    sel := hsStudi.GetKey(cbStudi.ItemIndex);
    tblMobili.Active := True;
    tblMobili.Insert;
    tblMobili.FieldByName('Codice').AsString := edtCodice.Text;
    tblMobili.FieldByName('Nome').AsString := edtNome.Text;
    tblMobili.FieldByName('CodStudio').AsString := sel;
    tblMobili.Post;
    tblMobili.Active := False;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmCreaMobile.EsisteMobile(CodMobile: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Codice] FROM [Mobili] ' +
                      'WHERE [Codice] = ' + QuotedStr(CodMobile);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  EsisteMobile := res;
end;

end.
