unit UReportProdottiOrdinati;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportProdottiOrdinati = class(TForm)
    qrReport: TQuickRep;
    qrbTitolo: TQRBand;
    lblInfo1: TQRLabel;
    QRPDFShape1: TQRPDFShape;
    lblInfo2: TQRLabel;
    lblInfo3: TQRLabel;
    lblInfo4: TQRLabel;
    qrbDettagli: TQRBand;
    lblNome: TQRDBText;
    lblFornitore: TQRDBText;
    lblQtaOrdinata: TQRDBText;
    QRPDFShape2: TQRPDFShape;
    qrProdotti: TADOQuery;
    lblQtaSpesa: TQRDBText;
    QRLabel1: TQRLabel;
    QRSysData1: TQRSysData;
    QRExcelFilter1: TQRExcelFilter;
    QRPDFFilter1: TQRPDFFilter;
    QRTextFilter1: TQRTextFilter;
    QRRTFFilter1: TQRRTFFilter;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AnteprimaReport(Anno: string);
  end;

var
  frmReportProdottiOrdinati: TfrmReportProdottiOrdinati;

implementation

{$R *.dfm}

{ TfrmReportMagazzino4 }


{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportProdottiOrdinati.AnteprimaReport(Anno: string);
begin
  qrProdotti.SQL.Text := 'SELECT [Prodotti].[Nome], [Prodotti].[Fornitore], [Prodotti_Ordinati].[QtaOrdinata], ' +
                                '[Prodotti_Ordinati].[QtaOrdinata] * [Prodotti].[CostoUnitario] AS [QtaSpesa] ' +
                         'FROM [Prodotti] INNER JOIN [Prodotti_Ordinati] ' +
                              'ON [Prodotti].[Codice] = [Prodotti_Ordinati].[CodProdotto] ' +
                         'WHERE [Prodotti_Ordinati].[Anno] = ' + Anno + ' ' +
                         'ORDER BY [Fornitore], [Nome]';

  qrProdotti.Active := True;
  lblInfo1.Caption := 'Prodotti Ordinati - ' + Anno;
  qrReport.PreviewModal;
  qrProdotti.Active := False;
end;

end.
