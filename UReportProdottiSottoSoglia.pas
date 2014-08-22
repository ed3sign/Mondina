unit UReportProdottiSottoSoglia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportProdottiSottoSoglia = class(TForm)
    qrReport: TQuickRep;
    qrbTitolo: TQRBand;
    lblInfo1: TQRLabel;
    QRPDFShape1: TQRPDFShape;
    lblInfo2: TQRLabel;
    qrbDettagli: TQRBand;
    lblNome: TQRDBText;
    qrProdotti: TADOQuery;
    lblCodAcquisto: TQRDBText;
    lblFornitore: TQRDBText;
    lblCostoConf: TQRDBText;
    lblInfo3: TQRLabel;
    lblInfo4: TQRLabel;
    lblInfo5: TQRLabel;
    QRPDFShape2: TQRPDFShape;
    lblInfo6: TQRLabel;
    lblQtaTotale: TQRDBText;
    lblInfo7: TQRLabel;
    lblSoglia: TQRDBText;
    QRSysData1: TQRSysData;
    QRTextFilter1: TQRTextFilter;
    QRPDFFilter1: TQRPDFFilter;
    QRExcelFilter1: TQRExcelFilter;
    QRRTFFilter1: TQRRTFFilter;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AnteprimaReport;
  end;

var
  frmReportProdottiSottoSoglia: TfrmReportProdottiSottoSoglia;

implementation

uses dmConnection;

{$R *.dfm}

{ TfrmReportMagazzino1 }

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportProdottiSottoSoglia.AnteprimaReport;
begin
  qrProdotti.SQL.Text := 'SELECT * FROM [Prodotti] ' +
                         'WHERE [QtaTotale] < [Soglia] ' +
                         'ORDER BY [Fornitore], [Nome]';
                           
  qrProdotti.Active := True;
  lblInfo1.Caption := 'Prodotti Sotto Soglia - ' + DateToStr(Date);
  qrReport.PreviewModal;
  qrProdotti.Active := False;
end;

end.
