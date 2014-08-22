unit UVisProdottiPersi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DB, ADODB, Grids, DBGrids, StdCtrls, TextLabeledEdit;

type
  TfrmProdottiPersi = class(TForm)
    gbFiltro: TGroupBox;
    edtCognome: TTextLabeledEdit;
    gbInfo: TGroupBox;
    dgProdotti: TDBGrid;
    qrProdotti: TADOQuery;
    dsProdotti: TDataSource;
    btnChiudi: TButton;
    btnEliminaTutti: TButton;
    qrQuery: TADOQuery;
    btnInserisci: TButton;
    btnElimina: TButton;
    lblInfo1: TLabel;
    lblProdPersoSel: TLabel;
    img1: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnChiudiClick(Sender: TObject);
    procedure edtCognomeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnEliminaTuttiClick(Sender: TObject);
    procedure btnInserisciClick(Sender: TObject);
    procedure btnEliminaClick(Sender: TObject);
    procedure dgProdottiCellClick(Column: TColumn);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ResetCampi;
    procedure LoadProdotti;
    procedure ResetCampiLoadProdotti;
    procedure ResetCampiPulsanti;
    procedure CancellaTuttiRecord;
    procedure CancellaRecord;
  end;

var
  frmProdottiPersi: TfrmProdottiPersi;

implementation

uses dmConnection, UMessaggi, UCreaProdottoPerso;

{$R *.dfm}

{ TfrmProdottiPersi }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmProdottiPersi.FormShow(Sender: TObject);
begin
  ResetCampi;
  LoadProdotti;
end;

procedure TfrmProdottiPersi.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmProdottiPersi.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmProdottiPersi.edtCognomeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  LoadProdotti;
  ResetCampiLoadProdotti;
end;

procedure TfrmProdottiPersi.btnEliminaTuttiClick(Sender: TObject);
var ris: Integer;
begin
  ResetCampiPulsanti;
  ris := MessageDlg(MSG_ELIMINA_PRODOTTI_PERSI, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
    CancellaTuttiRecord;
    LoadProdotti;
  end;
end;

procedure TfrmProdottiPersi.btnInserisciClick(Sender: TObject);
begin
  ResetCampiPulsanti;
  frmCreaProdottoPerso.ShowModal;
end;

procedure TfrmProdottiPersi.dgProdottiCellClick(Column: TColumn);
begin
  if not qrProdotti.IsEmpty then
  begin
    lblProdPersoSel.Caption := qrProdotti.FieldByName('NomeProdotto').AsString;
    btnElimina.Enabled := True;
  end;
end;

{ **************************************************************************** }
{ *** Reset ****************************************************************** }

procedure TfrmProdottiPersi.ResetCampi;
begin
  edtCognome.Text := EMPTYSTR;
  lblProdPersoSel.Caption := EMPTYSTR;
  btnElimina.Enabled := False;
  edtCognome.SetFocus;
end;

procedure TfrmProdottiPersi.ResetCampiLoadProdotti;
begin
  lblProdPersoSel.Caption := EMPTYSTR;
  btnElimina.Enabled := False;
end;

procedure TfrmProdottiPersi.ResetCampiPulsanti;
begin
  ResetCampi;
  LoadProdotti;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmProdottiPersi.LoadProdotti;
begin
  qrProdotti.Active := False;
  qrProdotti.SQL.Text := 'SELECT [Prodotti_Persi].[Codice], [Prodotti_Persi].[Data], [Utenti].[Cognome], [Utenti].[Nome], ' +
                                '[Utenti].[Cognome] + '' '' + [Utenti].[Nome] AS [Nominativo], ' +
                                '[Prodotti_Persi].[Stato], [Prodotti].[Nome] AS [NomeProdotto], [Prodotti_Persi].[QtaPersa] ' +
                         'FROM [Prodotti] INNER JOIN ([Utenti] INNER JOIN [Prodotti_Persi] ' +
                              'ON [Utenti].[Username] = [Prodotti_Persi].[Username]) ' +
                              'ON [Prodotti].[Codice] = [Prodotti_Persi].[CodProdotto] ' +
                         'WHERE (1 = 1)';

  if edtCognome.Text <> EMPTYSTR then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([Utenti].[Cognome] LIKE ' + QuotedStr('%' + edtCognome.Text + '%') + ')';

  qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' ORDER BY [Data], [Utenti].[Cognome], [Utenti].[Nome]';
  qrProdotti.Active := True;
end;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmProdottiPersi.CancellaTuttiRecord;
begin
  try
    qrQuery.SQL.Text := 'DELETE FROM [Prodotti_Persi]';
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

procedure TfrmProdottiPersi.btnEliminaClick(Sender: TObject);
var ris: Integer;
begin
  ris := MessageDlg(MSG_ELIMINA_RECORD, mtWarning, [mbYes, mbNo], 0);
  if ris = mrYes then
  begin
    CancellaRecord;
    LoadProdotti;
    btnElimina.Enabled := False;
    lblProdPersoSel.Caption := EMPTYSTR;
  end;
end;

procedure TfrmProdottiPersi.CancellaRecord;
var Cod: string;
begin
  try
    Cod := qrProdotti.FieldByName('Codice').AsString;
    qrQuery.SQL.Text := 'DELETE FROM [Prodotti_Persi] WHERE [Codice] = ' + Cod;
    qrQuery.ExecSQL;
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

end.
