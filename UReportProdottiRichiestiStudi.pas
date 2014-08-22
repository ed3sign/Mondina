unit UReportProdottiRichiestiStudi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, QRExport, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRPDFFilt, DB,
  ADODB;

type
  TfrmReportProdottiRichiestiStudi = class(TForm)
    qrProdotti: TADOQuery;
    QRTextFilter1: TQRTextFilter;
    QRPDFFilter1: TQRPDFFilter;
    QRExcelFilter1: TQRExcelFilter;
    qrReport: TQuickRep;
    qrbTitolo: TQRBand;
    lblInfo1: TQRLabel;
    QRPDFShape1: TQRPDFShape;
    lblInfo2: TQRLabel;
    lblInfo3: TQRLabel;
    lblInfo4: TQRLabel;
    QRLabel1: TQRLabel;
    QRSysData1: TQRSysData;
    qrbDettagli: TQRBand;
    lblNome: TQRDBText;
    lblFornitore: TQRDBText;
    lblQtaOrdinata: TQRDBText;
    QRPDFShape2: TQRPDFShape;
    lblQtaSpesa: TQRDBText;
    QRRTFFilter1: TQRRTFFilter;
    lblInfo5: TQRLabel;
    lblInfo6: TQRLabel;
    QRPDFShape3: TQRPDFShape;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AnteprimaReport(Anno, CodStudio, NomeStudio, Tipologia: string);
  end;

var
  frmReportProdottiRichiestiStudi: TfrmReportProdottiRichiestiStudi;

implementation

{$R *.dfm}

{ TForm1 }

procedure TfrmReportProdottiRichiestiStudi.AnteprimaReport(Anno, CodStudio, NomeStudio, Tipologia: string);
begin
  qrProdotti.SQL.Text := 'SELECT [Prodotti].[Tipologia], [Prodotti].[Nome], [Prodotti_Richiesti_Studi].[QtaRichiesta], ' +
                                '[Prodotti].[CostoUnitario] * [Prodotti_Richiesti_Studi].[QtaRichiesta] AS [QtaSpesa] ' +
                         'FROM [Prodotti] RIGHT OUTER JOIN ([AssociazioneAS] RIGHT OUTER JOIN [Prodotti_Richiesti_Studi] ON ' +
                              '[AssociazioneAS].[Codice] = [Prodotti_Richiesti_Studi].[CodAssociazioneAS]) ON ' +
                              '[Prodotti].[Codice] = [Prodotti_Richiesti_Studi].[CodProdotto] ' +
                         'WHERE [Prodotti_Richiesti_Studi].[CodAssociazioneAS] = ' + CodStudio + ' ' +
                         'AND [Prodotti_Richiesti_Studi].[Anno] = ' + Anno + ' ';

  if Tipologia <> ' ' then
    qrProdotti.SQL.Text := qrProdotti.SQL.Text + 'AND [Prodotti].[Tipologia] = ' + QuotedStr(Tipologia) + ' ';

  qrProdotti.SQL.Text := qrProdotti.SQL.Text + 'ORDER BY [Prodotti].[Tipologia], [Prodotti].[Nome]';
  qrProdotti.Active := True;
  lblInfo1.Caption := 'Prodotti Richiesti dagli Studi - ' + Anno;

  if CodStudio = '0' then lblInfo5.Caption := 'Studio: AMMINISTRATORE'
  else lblInfo5.Caption := 'Studio: ' + NomeStudio;

  if Tipologia = ' ' then lblInfo6.Caption := 'Tipologia: TUTTE'
  else lblInfo6.Caption := 'Tipologia: ' + Tipologia;

  qrReport.PreviewModal;
  qrProdotti.Active := False;
end;

end.
