unit UVisProdottiPerAssistente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, StdCtrls, Grids, DBGrids, ExtCtrls;

type
  TfrmProdottiPerAssistente = class(TForm)
    img1: TImage;
    btnReport: TButton;
    btnChiudi: TButton;
    qrProdotti: TADOQuery;
    gbInfo: TGroupBox;
    lblInfo1: TLabel;
    cbIntervalli: TComboBox;
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
  frmProdottiPerAssistente: TfrmProdottiPerAssistente;

implementation

uses Math, UMessaggi, UReportProdottiPerAssistente, dmConnection;

{$R *.dfm}

const
  NUM_COLONNE = 10;

{ **************************************************************************** }
{ *** Finestra *************************************************************** }

procedure TfrmProdottiPerAssistente.FormShow(Sender: TObject);
begin
  qrProdotti.SQL.Text := 'TRANSFORM Sum([qr1].[QtaUsata]) AS [SommaDiQtaUsata] ' +
                         'SELECT [qr1].[Nome] ' +
                         'FROM (SELECT [Prodotti].[Codice], [Prodotti].[Nome], [Prodotti_Cassetti].[QtaUsata], ' +
                                      '[AssociazioneAS].[Nome] + ''$$$'' + [AssociazioneAS].[UsernameAssistente] + '' (a)$$$'' + ' +
                                      '[AssociazioneAS].[UsernameSostituto] + '' (s)'' AS [Nominativo] ' +
                               'FROM [AssociazioneAS] INNER JOIN ([Cassetti] INNER JOIN ([Prodotti] INNER JOIN [Prodotti_Cassetti] ' +
                                    'ON [Prodotti].[Codice] = [Prodotti_Cassetti].[CodProdotto]) ' +
                                    'ON [Cassetti].[Codice] = [Prodotti_Cassetti].[CodCassetto]) ' +
                                    'ON [AssociazioneAS].[Codice] = [Cassetti].[CodAssociazioneAS]) AS [qr1] ' +
                         'INNER JOIN ' +
                              '(SELECT DISTINCT ([Prodotti].[Codice]) ' +
                               'FROM [Prodotti] INNER JOIN [Prodotti_Cassetti] ON [Prodotti].[Codice] = [Prodotti_Cassetti].[CodProdotto] ' +
                               'WHERE ([Prodotti_Cassetti].[QtaUsata] > 0) ) AS [qr2] ' +
                         'ON [qr1].[Codice] = [qr2].[Codice] ' +
                         'GROUP BY [qr1].[Nome] ' +
                         'PIVOT [qr1].[Nominativo]';
                                                  
  qrProdotti.Active := True;
  LoadPagine;
  cbIntervalli.SetFocus;
end;

procedure TfrmProdottiPerAssistente.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  qrProdotti.Active := False;
end;

{ **************************************************************************** }
{ *** Load ******************************************************************* }

procedure TfrmProdottiPerAssistente.LoadPagine;
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

procedure TfrmProdottiPerAssistente.btnReportClick(Sender: TObject);
var lInf, lSup: Integer;
begin
  if cbIntervalli.ItemIndex = 0 then ShowMessage(MSG_SELEZIONARE_PAGINA)
  else
  begin
    lInf := ((cbIntervalli.ItemIndex-1) * NUM_COLONNE) + 1;
    if cbIntervalli.ItemIndex = cbIntervalli.Items.Count-1 then lSup := qrProdotti.Fields.Count - 1
    else lSup := lInf + (NUM_COLONNE - 1);
    frmReportProdottiPerAssistente.AnteprimaReport(lInf, lSup);
  end;
end;

procedure TfrmProdottiPerAssistente.btnChiudiClick(Sender: TObject);
begin
  Close;
end;

end.
