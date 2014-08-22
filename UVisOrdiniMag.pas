unit UVisOrdiniMag;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NumberEdit, StdCtrls, Grids, DBGrids, TextEdit, ExtCtrls, DB,
  ADODB, TextLabeledEdit;

type
  TfrmVisOrdiniMag = class(TForm)
    gbFiltro: TGroupBox;
    btnChiudi: TButton;
    qrProdotti: TADOQuery;
    dsProdotti: TDataSource;
    cbStato: TComboBox;
    lblInfo1: TLabel;
    edtFiltroProd: TTextLabeledEdit;
    qrQuery: TADOQuery;
    img1: TImage;
    gbInfo: TGroupBox;
    dgProdotti: TDBGrid;
    lblInfo3: TLabel;
    lblProdSel: TLabel;
    gbAnnulla: TGroupBox;
    lblInfo2: TLabel;
    lblInfo5: TLabel;
    Bevel1: TBevel;
    lblNomeProd: TLabel;
    lblQtaOrdinata: TLabel;
    btnAnnullaComando: TButton;
    btnOrdineRicevuto: TButton;
    Button1: TButton;
    bntAnnullaOrdine: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dgProdottiCellClick(Column: TColumn);
    procedure edtFiltroProdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnChiudiClick(Sender: TObject);
    procedure cbStatoChange(Sender: TObject);
    procedure btnRifornisciClick(Sender: TObject);
    procedure btnAddOrdClick(Sender: TObject);
    procedure btnOrdineRicevutoClick(Sender: TObject);
    procedure btnAnnullaComandoClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadProdotti;
    procedure ModificaProdotto;
    function EsisteProdottoOrdinato(CodProd, Anno: string) : Boolean;
    function GetAnnoStr: string;
  end;

var
  frmVisOrdiniMag: TfrmVisOrdiniMag;
  codProd : string;
  nome : string;
  newTotal : Integer;

implementation

uses dmConnection, UMessaggi, URifornisciCassetti, UNuovoOrdine,
  UVisMagazzino;

{$R *.dfm}

{ TfrmVisMagazzino }

var
  CodiceProdotto: string;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmVisOrdiniMag.FormShow(Sender: TObject);
begin
  LoadProdotti;
  cbStato.SetFocus;

end;

procedure TfrmVisOrdiniMag.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmVisOrdiniMag.dgProdottiCellClick(Column: TColumn);
begin
  if not qrProdotti.IsEmpty then
  begin
    lblProdSel.Caption := qrProdotti.FieldByName('NomeProdotto').AsString;
    nome := qrProdotti.FieldByName('NomeProdotto').AsString;
    codProd := qrProdotti.FieldByName('CodiceAcquisto').AsString;
    if (cbStato.ItemIndex = 0) then
  begin
    bntAnnullaOrdine.Visible := True;
    btnOrdineRicevuto.Visible := False;
  end;
  if (cbStato.ItemIndex = 1) then
  begin
    bntAnnullaOrdine.Visible := False;
    btnOrdineRicevuto.Visible := True;
  end;
    qrQuery.Active := False;
    end;
end;

procedure TfrmVisOrdiniMag.edtFiltroProdKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  LoadProdotti;
end;

procedure TfrmVisOrdiniMag.cbStatoChange(Sender: TObject);
begin
  bntAnnullaOrdine.Visible := False;
  btnOrdineRicevuto.Visible := False;
  LoadProdotti;
end;

procedure TfrmVisOrdiniMag.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVisOrdiniMag.btnRifornisciClick(Sender: TObject);
begin
  frmRifornisciCassetti.ShowModal;
end;

procedure TfrmVisOrdiniMag.btnAddOrdClick(Sender: TObject);
begin
  frmOrdinaProd.ShowModal;
end;

procedure TfrmVisOrdiniMag.btnAnnullaComandoClick(Sender: TObject);
begin

end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmVisOrdiniMag.LoadProdotti;
begin
  qrProdotti.Active := False;
  qrProdotti.SQL.Text := 'SELECT * ' +
                         'FROM [OrdiniMagazzino] ' +
                         'WHERE [Consegnato] = ' + QuotedStr(cbStato.Items[cbStato.ItemIndex]);

    if edtFiltroProd.Text <> EMPTYSTR then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([NomeProdotto] LIKE ' + QuotedStr('%' + edtFiltroProd.Text + '%') + ')';

  qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' ORDER BY [NomeProdotto]';
  qrProdotti.Active := True;
end;




{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmVisOrdiniMag.ModificaProdotto;
var
  CodProd, Anno: string;
  QtaMax: Integer;
begin
  try
    CodProd := qrProdotti.FieldByName('Codice').AsString;
    Anno := GetAnnoStr;

    qrProdotti.Edit;
    qrProdotti.FieldByName('QtaTotale').AsInteger := qrProdotti.FieldByName('QtaTotale').AsInteger + qtaMax;
    qrProdotti.Post;
    
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmVisOrdiniMag.EsisteProdottoOrdinato(CodProd, Anno: string): Boolean;
var ris: Boolean;
begin
  ris := True;
  qrQuery.SQL.Text := 'SELECT * FROM [Prodotti_Ordinati] ' +
                      'WHERE [CodProdotto] = ' + CodProd + ' AND ' +
                            '[Anno] = ' + Anno;
  qrQuery.Active := True;
  if qrQuery.IsEmpty then ris := False;
  qrQuery.Active := False;
  EsisteProdottoOrdinato := ris;
end;

function TfrmVisOrdiniMag.GetAnnoStr: string;
var
  myYear, myMonth, myDay : Word;
begin
  DecodeDate(Date, myYear, myMonth, myDay);
  GetAnnoStr := IntToStr(myYear);
end;

procedure TfrmVisOrdiniMag.btnOrdineRicevutoClick(Sender: TObject);
var
  tot, qtaOrd, qtaTot : Integer;
begin
  gbAnnulla.Visible := True;
  lblNomeProd.Caption := qrProdotti.FieldByName('NomeProdotto').AsString;
  lblQtaOrdinata.Caption := qrProdotti.FieldByName('qtaOrdinata').AsString;
  qrQuery.SQL.Text := 'UPDATE [OrdiniMagazzino] ' +
                        'SET [Consegnato] = "Consegnato"'+
                        'WHERE [CodiceAcquisto] = "' + codProd + '" AND [NomeProdotto] = "' + nome + '";';
  qrQuery.ExecSQL;

  qrQuery.SQL.Text := 'SELECT [qtaOrdinata] FROM [OrdiniMagazzino] WHERE [CodiceAcquisto] = "' + codProd + '" AND [NomeProdotto] = "' + nome + '";';
  qrQuery.Open;
  qtaOrd := qrQuery.Fields[0].AsInteger;
  qrQuery.SQL.Text := 'SELECT [QtaTotale] FROM [Prodotti] WHERE [Nome] = "' + nome + '";';
  qrQuery.Open;
  qtaTot := qrQuery.Fields[0].AsInteger;
  tot :=  qtaOrd + qtaTot ;

  qrQuery.SQL.Text := 'UPDATE [Prodotti] SET [QtaTotale]= ' + IntToStr(tot) + ' WHERE [Nome] = "' + nome + '";';
  qrQuery.ExecSQL;

  LoadProdotti;
end;

procedure TfrmVisOrdiniMag.Button1Click(Sender: TObject);
begin
  frmVisOrdiniMag.Close;
  frmVisMagazzino.Show;
end;

end.
