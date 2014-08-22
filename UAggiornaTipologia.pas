unit UAggiornaTipologia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ADODB, DB, Grids, DBGrids, StdCtrls, ExtCtrls;

type
  TfrmAggiornaTipologia = class(TForm)
    img1: TImage;
    btnChiudi: TButton;
    gbTipologie: TGroupBox;
    lblInfo2: TLabel;
    lblTipologiaSel: TLabel;
    dgTipologie: TDBGrid;
    gbInfo: TGroupBox;
    gbComandi: TGroupBox;
    btnElimina: TButton;
    dsTipologie: TDataSource;
    qrQuery: TADOQuery;
    qrTipologie: TADOQuery;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure dgTipologieCellClick(Column: TColumn);
    procedure btnEliminaClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure CancellaRecord;
    procedure ResetCampi;
    function TipologiaCollegata(CodTipologia: string): Boolean;
  end;

var
  frmAggiornaTipologia: TfrmAggiornaTipologia;

implementation

uses dmConnection, UMessaggi;

{$R *.dfm}

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmAggiornaTipologia.FormShow(Sender: TObject);
begin
  ResetCampi;
  qrTipologie.SQL.Text := 'SELECT * FROM [Tipologie_Prodotti] ORDER BY [Tipologia]';
  qrTipologie.Active := True;
end;

procedure TfrmAggiornaTipologia.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  qrTipologie.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmAggiornaTipologia.dgTipologieCellClick(Column: TColumn);
begin
  if not qrTipologie.IsEmpty then
  begin
    lblTipologiaSel.Caption := qrTipologie.FieldByName('Tipologia').AsString;
    gbComandi.Visible := True;
  end;
end;

procedure TfrmAggiornaTipologia.btnEliminaClick(Sender: TObject);
var ris: Integer;
begin
  gbComandi.Visible := False;
  ris := MessageDlg(MSG_ELIMINA_RECORD, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
   if TipologiaCollegata(lblTipologiaSel.Caption) then Showmessage(MSG_TIPOLOGIA_COLLEGATA)
   else CancellaRecord;
  end;
  lblTipologiaSel.Caption := EMPTYSTR;
end;

procedure TfrmAggiornaTipologia.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmAggiornaTipologia.ResetCampi;
begin
  lblTipologiaSel.Caption := EMPTYSTR;
  gbComandi.Visible := False;
  btnChiudi.SetFocus;  
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmAggiornaTipologia.CancellaRecord;
begin
  try
    qrTipologie.Delete;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmAggiornaTipologia.TipologiaCollegata(CodTipologia: string): Boolean;
var res: Boolean;
begin
  res := True;
  qrQuery.SQL.Text := 'SELECT [Tipologia] FROM [Prodotti] ' +
                      'WHERE [Tipologia] = ' + QuotedStr(CodTipologia);
  qrQuery.Active := True;
  if qrQuery.IsEmpty then res := False;
  qrQuery.Active := False;
  TipologiaCollegata := res;
end;

end.
