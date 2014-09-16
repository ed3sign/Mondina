unit UReportProdottiPerTipologia;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportProdottiPerTipologia = class(TForm)
    qrReport: TQuickRep;
    qrbTitolo: TQRBand;
    lblInfo1: TQRLabel;
    QRPDFShape1: TQRPDFShape;
    lblInfo2: TQRLabel;
    lblInfo3: TQRLabel;
    lblInfo4: TQRLabel;
    qrbDettagli: TQRBand;
    lblNome: TQRDBText;
    lblQtaTotale: TQRDBText;
    lblTipologia: TQRDBText;
    QRPDFShape2: TQRPDFShape;
    qrProdotti: TADOQuery;
    QRSysData1: TQRSysData;
    QRExcelFilter1: TQRExcelFilter;
    QRPDFFilter1: TQRPDFFilter;
    QRTextFilter1: TQRTextFilter;
    QRRTFFilter1: TQRRTFFilter;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AnteprimaReport(Tipologia: string);
  end;

var
  frmReportProdottiPerTipologia: TfrmReportProdottiPerTipologia;

implementation

uses dmConnection;

{$R *.dfm}

{ TfrmReportMagazzino3 }

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportProdottiPerTipologia.AnteprimaReport(Tipologia: string);
begin
  if Tipologia = ' ' then
      qrProdotti.SQL.Text := 'SELECT * FROM [Prodotti] ORDER BY [Tipologia], [Nome]'
  else
    qrProdotti.SQL.Text := 'SELECT * FROM [Prodotti] ' +
                           'WHERE [Tipologia] = ' + QuotedStr(Tipologia) + ' ' +
                           'ORDER BY [Tipologia], [Nome]';

  qrProdotti.Active := True;
  lblInfo1.Caption := 'Prodotti Per Tipologia - ' + DateToStr(Date);
  qrReport.PreviewModal;
  qrProdotti.Active := False;
end;

end.
