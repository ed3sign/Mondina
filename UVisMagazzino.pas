unit UVisMagazzino;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NumberEdit, StdCtrls, Grids, DBGrids, TextEdit, ExtCtrls, DB,
  ADODB, TextLabeledEdit, NumberLabeledEdit;

type
  TfrmVisMagazzino = class(TForm)
    gbFiltro: TGroupBox;
    btnChiudi: TButton;
    btnRifornisci: TButton;
    qrProdotti: TADOQuery;
    dsProdotti: TDataSource;
    cbTipologie: TComboBox;
    lblInfo1: TLabel;
    edtFiltroProd: TTextLabeledEdit;
    qrQuery: TADOQuery;
    img1: TImage;
    gbInfo: TGroupBox;
    dgProdotti: TDBGrid;
    lblInfo3: TLabel;
    lblProdSel: TLabel;
    btnAddOrd: TButton;
    btnChageForm: TButton;
    gbSottrai: TGroupBox;
    ntbSottrai: TNumberLabeledEdit;
    btnOk: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dgProdottiCellClick(Column: TColumn);
    procedure edtFiltroProdKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnChiudiClick(Sender: TObject);
    procedure cbTipologieChange(Sender: TObject);
    procedure btnRifornisciClick(Sender: TObject);
    procedure btnAddOrdClick(Sender: TObject);
    procedure btnChageFormClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadProdotti;
    procedure ModificaProdotto;
    procedure LoadTipologie;
    function EsisteProdottoOrdinato(CodProd, Anno: string) : Boolean;
    procedure InserisciProdottoOrdinato(CodProd, Anno: string; Qta: Integer);
    function GetAnnoStr: string;
  end;

var
  frmVisMagazzino: TfrmVisMagazzino;

implementation

uses dmConnection, UMessaggi, URifornisciCassetti, UNuovoOrdine,
  UCreaOrdine,
  UVisOrdiniMag;

{$R *.dfm}

{ TfrmVisMagazzino }

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmVisMagazzino.FormShow(Sender: TObject);
begin
  LoadTipologie;
  LoadProdotti;
  cbTipologie.SetFocus;
end;

procedure TfrmVisMagazzino.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmVisMagazzino.dgProdottiCellClick(Column: TColumn);
begin
  if not qrProdotti.IsEmpty then
  begin
    lblProdSel.Caption := qrProdotti.FieldByName('Nome').AsString;
    btnAddOrd.Visible := True;
    gbSottrai.Visible := True;
  end;
end;

procedure TfrmVisMagazzino.edtFiltroProdKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  LoadProdotti;
end;

procedure TfrmVisMagazzino.cbTipologieChange(Sender: TObject);
begin
  LoadProdotti;
end;

procedure TfrmVisMagazzino.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVisMagazzino.btnRifornisciClick(Sender: TObject);
begin
  frmRifornisciCassetti.ShowModal;
end;

procedure TfrmVisMagazzino.btnAddOrdClick(Sender: TObject);
begin
  frmCreaOrdine.ShowModal;
end;
{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmVisMagazzino.LoadTipologie;
begin
  cbTipologie.Clear;
  cbTipologie.Items.Add(' ');
  qrQuery.SQL.Text := 'SELECT [Tipologia] FROM [Tipologie_Prodotti] ORDER BY [Tipologia]';
  qrQuery.Active := True;
  qrQuery.First;
  while not qrQuery.Eof do
  begin
    cbTipologie.Items.Add(qrQuery.FieldByName('Tipologia').AsString);
    qrQuery.Next;
  end;
  qrQuery.Active := False;
  cbTipologie.ItemIndex := 0;
end;

procedure TfrmVisMagazzino.LoadProdotti;
begin
  qrProdotti.Active := False;
  qrProdotti.SQL.Text := 'SELECT * ' +
                         'FROM [Prodotti] ' + 
                         'WHERE (1 = 1)';

  if cbTipologie.ItemIndex > 0 then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([Tipologia] = ' + QuotedStr(cbTipologie.Items[cbTipologie.ItemIndex]) + ')';

  if edtFiltroProd.Text <> EMPTYSTR then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text +
                           ' AND ([Nome] LIKE ' + QuotedStr('%' + edtFiltroProd.Text + '%') + ')';

  qrProdotti.SQL.Text := qrProdotti.SQL.Text + ' ORDER BY [Nome]';
  qrProdotti.Active := True;
end;


{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmVisMagazzino.ModificaProdotto;
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

    InserisciProdottoOrdinato(CodProd, Anno, QtaMax);
  except
    ShowMessage(MSG_ERRORE_SCRITTURA_DB);
  end;
end;

function TfrmVisMagazzino.EsisteProdottoOrdinato(CodProd, Anno: string): Boolean;
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

function TfrmVisMagazzino.GetAnnoStr: string;
var
  myYear, myMonth, myDay : Word;
begin
  DecodeDate(Date, myYear, myMonth, myDay);
  GetAnnoStr := IntToStr(myYear);
end;

procedure TfrmVisMagazzino.InserisciProdottoOrdinato(CodProd, Anno: string; Qta: Integer);
begin
  if EsisteProdottoOrdinato(CodProd, Anno) then
    qrQuery.SQL.Text := 'UPDATE [Prodotti_Ordinati] ' +
                        'SET [QtaOrdinata] = [QtaOrdinata] + ' + IntToStr(Qta) + ' ' +
                        'WHERE [CodProdotto] = ' + CodProd + ' AND [Anno] = ' + Anno
  else
    qrQuery.SQL.Text := 'INSERT INTO [Prodotti_Ordinati] ([CodProdotto], [Anno], [QtaOrdinata]) ' +
                        'VALUES (' + CodProd + ', ' + Anno + ', ' + IntToStr(Qta) + ')';

  qrQuery.ExecSQL;
end;

procedure TfrmVisMagazzino.btnChageFormClick(Sender: TObject);
begin
  frmVisMagazzino.Close;
  frmVisOrdiniMag.Show;
end;

procedure TfrmVisMagazzino.btnOkClick(Sender: TObject);
var
  buttonSelected : Integer;
  qta : Integer;
  qtaMag : Integer;
  totsot: Integer;
  nome : String;
begin
  qtaMag := qrProdotti.FieldByName('QtaTotale').AsInteger;
  nome := qrProdotti.FieldByName('Nome').AsString;
  qta := StrToIntDef(ntbSottrai.Text, 0);
  totsot := qtaMag-qta;

  if (ntbSottrai.Text=EMPTYSTR) Or (qta<=0) then
    buttonSelected := MessageDlg('La Quantità indicata non è valida!',mtWarning,
                              [mbOk], 0)
  else
  // Show a custom dialog
  buttonSelected := MessageDlg('Vuoi Sottrarre '+IntToStr(qta)+' '+nome+'/i?',mtConfirmation,
                              [mbYes,mbCancel], 0);

  // Show the button type selected
  if buttonSelected = mrYes    then
    qrQuery.SQL.Text := 'UPDATE [Prodotti] ' +
                        'SET [QtaTotale] = '+IntToStr(totsot)+
                        ' WHERE [Nome] = "' + nome + '";';
  qrQuery.ExecSQL;
  LoadProdotti;


end;

end.
