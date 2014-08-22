unit UVisProdottiPersiSelPagina;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, ExtCtrls;

type
  TfrmProdottiPersiSelPagina = class(TForm)
    img1: TImage;
    btnReport: TButton;
    btnChiudi: TButton;
    gbInfo: TGroupBox;
    lblInfo1: TLabel;
    cbIntervalli: TComboBox;
    qrProdotti: TADOQuery;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnReportClick(Sender: TObject);
    procedure btnChiudiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadPagine;    
  end;

var
  frmProdottiPersiSelPagina: TfrmProdottiPersiSelPagina;

implementation

uses Math, dmConnection, UMessaggi, UReportProdottiPersi;

{$R *.dfm}

const
  NUM_COLONNE = 10;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmProdottiPersiSelPagina.FormShow(Sender: TObject);
begin
  qrProdotti.SQL.Text := 'TRANSFORM Sum([qr1].[QtaPersa]) AS [SommaDiQtaPersa] ' +
                         'SELECT [qr1].[Nome] ' +
                         'FROM (SELECT [Prodotti].[Nome], [Prodotti_Persi].[QtaPersa], ' +
                                      '[Utenti].[Cognome] + '' '' + [Utenti].[Nome] AS [Nominativo] ' +
                               'FROM [Utenti] INNER JOIN ([Prodotti] INNER JOIN [Prodotti_Persi] ' +
                               'ON [Prodotti].[Codice] = [Prodotti_Persi].[CodProdotto]) ' +
                               'ON [Utenti].[Username] = [Prodotti_Persi].[Username]) AS [qr1] ' +
                         'GROUP BY [qr1].[Nome] ' +
                         'PIVOT [qr1].[Nominativo]';
  qrProdotti.Active := True;
  LoadPagine;
  cbIntervalli.SetFocus;
end;

procedure TfrmProdottiPersiSelPagina.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmProdottiPersiSelPagina.LoadPagine;
var
  numCampiVar: Integer;
  numOpz, i: Integer;
begin
  numCampiVar := qrProdotti.Fields.Count - 1;
  numOpz := Ceil(numCampiVar / NUM_COLONNE);
  cbIntervalli.Clear;
  cbIntervalli.Items.Add(' ');
  for i := 1 to NumOpz do
  begin
    cbIntervalli.Items.Add('Pagina ' + IntToStr(i));
  end;
  cbIntervalli.ItemIndex := 0;
end;

{ **************************************************************************** }
{ *** Componenti ************************************************************* }

procedure TfrmProdottiPersiSelPagina.btnReportClick(Sender: TObject);
var lInf, lSup: Integer;
begin
  if cbIntervalli.ItemIndex = 0 then ShowMessage(MSG_SELEZIONARE_PAGINA)
  else
  begin
    lInf := ((cbIntervalli.ItemIndex-1) * NUM_COLONNE) + 1;
    if cbIntervalli.ItemIndex = cbIntervalli.Items.Count-1 then lSup := qrProdotti.Fields.Count - 1
    else lSup := lInf + (NUM_COLONNE - 1);
    frmReportProdottiPersi.AnteprimaReport(lInf, lSup);
  end;
end;

procedure TfrmProdottiPersiSelPagina.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

end.
