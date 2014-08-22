unit UAggiornaMobile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ADODB, DB, StdCtrls, ExtCtrls, TextLabeledEdit, Grids, DBGrids;

type
  TfrmAggiornaMobile = class(TForm)
    img1: TImage;
    btnChiudi: TButton;
    gbMobili: TGroupBox;
    lblInfo2: TLabel;
    lblMobileSel: TLabel;
    dgMobili: TDBGrid;
    gbInfo: TGroupBox;
    gbComandi: TGroupBox;
    btnModifica: TButton;
    btnElimina: TButton;
    gbModifica: TGroupBox;
    dsMobili: TDataSource;
    qrQuery: TADOQuery;
    btnAnnulla: TButton;
    btnOK: TButton;
    Bevel1: TBevel;
    cbStudi: TComboBox;
    edtNome: TTextLabeledEdit;
    lblInfo1: TLabel;
    qrMobili: TADOQuery;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dgMobiliCellClick(Column: TColumn);
    procedure btnModificaClick(Sender: TObject);
    procedure btnEliminaClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAnnullaClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure CancellaRecord;
    procedure ModificaRecord;
    procedure RiempiCampi;
    function MobileCollegato(CodMobile: string): Boolean;
    function GetNomeStudioDaCodice(CodStudio: string): string;
    procedure LoadStudi;
  end;

var
  frmAggiornaMobile: TfrmAggiornaMobile;

implementation

uses UHashTable, dmConnection, UMessaggi;

{$R *.dfm}

{ TfrmAggiornaMobile }

var
  hsStudi: THashTable;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAggiornaMobile.FormShow(Sender: TObject);
begin
  ResetCampi;
  qrMobili.SQL.Text := 'SELECT * FROM [Mobili] ORDER BY [CodStudio], [Codice]';
  qrMobili.Active := True;
end;

procedure TfrmAggiornaMobile.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrMobili.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAggiornaMobile.dgMobiliCellClick(Column: TColumn);
begin
  if not qrMobili.IsEmpty then
  begin
    lblMobileSel.Caption := qrMobili.FieldByName('Codice').AsString;
    gbModifica.Visible := False;
    gbComandi.Visible := True;
  end;
end;

procedure TfrmAggiornaMobile.btnModificaClick(Sender: TObject);
begin
  RiempiCampi;
  gbComandi.Visible := False;
  gbModifica.Visible := True;
end;

procedure TfrmAggiornaMobile.btnEliminaClick(Sender: TObject);
var ris: Integer;
begin
  gbComandi.Visible := False;
  ris := MessageDlg(MSG_ELIMINA_RECORD, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
   if MobileCollegato(lblMobileSel.Caption) then Showmessage(MSG_MOBILE_COLLEGATO)
   else CancellaRecord;
  end;
  lblMobileSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaMobile.btnOKClick(Sender: TObject);
begin
  if (Trim(edtNome.Text) = EMPTYSTR) or (cbStudi.ItemIndex = -1) then
    ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    ModificaRecord;
    gbModifica.Visible := False;
    lblMobileSel.Caption := EMPTYSTR;
  end;
end;

procedure TfrmAggiornaMobile.btnAnnullaClick(Sender: TObject);
begin
  gbModifica.Visible := False;
  lblMobileSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaMobile.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAggiornaMobile.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;
  cbStudi.Clear;

  lblMobileSel.Caption := EMPTYSTR;
  gbComandi.Visible := False;
  gbModifica.Visible := False;
  btnChiudi.SetFocus;  
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmAggiornaMobile.LoadStudi;
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

function TfrmAggiornaMobile.MobileCollegato(CodMobile: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [CodMobile] FROM [Cassetti] ' +
                      'WHERE [CodMobile] = ' + QuotedStr(CodMobile);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  MobileCollegato := res;
end;

function TfrmAggiornaMobile.GetNomeStudioDaCodice(CodStudio: string): string;
var res: string;
begin
  res := '';
  qrQuery.SQL.Text := 'SELECT [Nome] FROM [Studi] ' +
                      'WHERE [Codice] = ' + QuotedStr(CodStudio);
  qrQuery.Active := True;
  if not qrQuery.IsEmpty then res := qrQuery.FieldByName('Nome').AsString;
  qrQuery.Active := False;
  GetNomeStudioDaCodice := res;
end;

procedure TfrmAggiornaMobile.ModificaRecord;
var sel: string;
begin
  try
    sel := hsStudi.GetKey(cbStudi.ItemIndex);
    qrMobili.Edit;
    qrMobili.FieldByName('Nome').AsString := edtNome.Text;
    qrMobili.FieldByName('CodStudio').AsString := sel;
    qrMobili.Post;
    qrMobili.Active := False;
    qrMobili.Active := True;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAggiornaMobile.CancellaRecord;
begin
  try
    qrMobili.Delete;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAggiornaMobile.RiempiCampi;
var nomeStudio: string;
begin
  LoadStudi;
  edtNome.Text := qrMobili.FieldByName('Nome').AsString;
  nomeStudio := GetNomeStudioDaCodice(qrMobili.FieldByName('CodStudio').AsString);
  cbStudi.ItemIndex := cbStudi.Items.IndexOf(nomeStudio);
end;

end.
