unit UAggiornaStudio;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, ExtCtrls, TextLabeledEdit, Grids, DBGrids;

type
  TfrmAggiornaStudio = class(TForm)
    img1: TImage;
    btnChiudi: TButton;
    gbStudi: TGroupBox;
    lblInfo2: TLabel;
    lblStudioSel: TLabel;
    dgStudi: TDBGrid;
    gbInfo: TGroupBox;
    gbComandi: TGroupBox;
    btnModifica: TButton;
    btnElimina: TButton;
    gbModifica: TGroupBox;
    btnOK: TButton;
    btnAnnulla: TButton;
    dsStudi: TDataSource;
    qrQuery: TADOQuery;
    edtNome: TTextLabeledEdit;
    Bevel1: TBevel;
    qrStudi: TADOQuery;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure dgStudiCellClick(Column: TColumn);
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
    function StudioCollegato(CodStudio: string): Boolean;
  end;

var
  frmAggiornaStudio: TfrmAggiornaStudio;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ TfrmAggiornaStudio }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAggiornaStudio.FormShow(Sender: TObject);
begin
  ResetCampi;
  qrStudi.SQL.Text := 'SELECT * FROM [Studi] ORDER BY [Codice]';
  qrStudi.Active := True;
end;

procedure TfrmAggiornaStudio.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrStudi.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAggiornaStudio.dgStudiCellClick(Column: TColumn);
begin
  if not qrStudi.IsEmpty then
  begin
    lblStudioSel.Caption := qrStudi.FieldByName('Codice').AsString;
    gbModifica.Visible := False;
    gbComandi.Visible := True;
  end;
end;

procedure TfrmAggiornaStudio.btnModificaClick(Sender: TObject);
begin
  RiempiCampi;
  gbComandi.Visible := False;
  gbModifica.Visible := True;
end;

procedure TfrmAggiornaStudio.btnEliminaClick(Sender: TObject);
var ris: Integer;
begin
  gbComandi.Visible := False;
  ris := MessageDlg(MSG_ELIMINA_RECORD, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
   if StudioCollegato(lblStudioSel.Caption) then Showmessage(MSG_STUDIO_COLLEGATO)
   else CancellaRecord;
  end;
  lblStudioSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaStudio.btnOKClick(Sender: TObject);
begin
  if Trim(edtNome.Text) = EMPTYSTR then ShowMessage(MSG_INSERIRE_DATI)
  else
  begin
    ModificaRecord;
    gbModifica.Visible := False;
    lblStudioSel.Caption := EMPTYSTR;
  end;
end;

procedure TfrmAggiornaStudio.btnAnnullaClick(Sender: TObject);
begin
  gbModifica.Visible := False;
  lblStudioSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaStudio.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAggiornaStudio.ResetCampi;
begin
  edtNome.Text := EMPTYSTR;

  lblStudioSel.Caption := EMPTYSTR;
  gbComandi.Visible := False;
  gbModifica.Visible := False;
  btnChiudi.SetFocus;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmAggiornaStudio.CancellaRecord;
begin
  try
    qrStudi.Delete;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAggiornaStudio.ModificaRecord;
begin
  try
    qrStudi.Edit;
    qrStudi.FieldByName('Nome').AsString := edtNome.Text;
    qrStudi.Post;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmAggiornaStudio.RiempiCampi;
begin
  edtNome.Text := qrStudi.FieldByName('Nome').AsString;
end;

function TfrmAggiornaStudio.StudioCollegato(CodStudio: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [CodStudio] FROM [Mobili] ' +
                      'WHERE [CodStudio] = ' + QuotedStr(CodStudio);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  StudioCollegato := res;
end;

end.
