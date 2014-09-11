unit UReportProdottiConsegnati;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportProdottiConsegnati = class(TForm)
    qrReport: TQuickRep;
    qrbTitolo: TQRBand;
    lblInfo1: TQRLabel;
    lblInfo2: TQRLabel;
    qrbDettagli: TQRBand;
    lblNome: TQRDBText;
    qrProdotti: TADOQuery;
    QRSysData1: TQRSysData;
    QRTextFilter1: TQRTextFilter;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AnteprimaReport(Anno: string);
  end;

var
  frmReportProdottiConsegnati: TfrmReportProdottiConsegnati;

implementation

{$R *.dfm}

{ TfrmReportMagazzino4 }


{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportProdottiConsegnati.AnteprimaReport(Anno: string);
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
