unit UReportProdottiPersi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportProdottiPersi = class(TForm)
    qrReport: TQuickRep;
    qrbTitolo: TQRBand;
    lblInfo1: TQRLabel;
    QRPDFShape1: TQRPDFShape;
    lblInfo2: TQRLabel;
    qrbDettagli: TQRBand;
    lblNome: TQRDBText;
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
    procedure CreaCampo(PosX, iCampo, lInf: Integer);
    procedure CreaCampiVariabili(lInf, lSup: Integer);
    procedure DistruggiCampiVariabili;
    procedure AnteprimaReport(lInf, lSup: Integer);    
  end;

var
  frmReportProdottiPersi: TfrmReportProdottiPersi;

implementation

{$R *.dfm}

{ TfrmReportProdottiPersi }

var
  qrCampi: array of TQRDBText;
  qrTitoli: array of TQRLabel;
  qrLinee: array of TQRPDFShape;

procedure TfrmReportProdottiPersi.AnteprimaReport(lInf, lSup: Integer);
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
  lblInfo1.Caption := 'Prodotti Persi - ' + DateToStr(Date);
  CreaCampiVariabili(lInf, lSup);
  qrReport.PreviewModal;
  DistruggiCampiVariabili;
  qrProdotti.Active := False;
end;

procedure TfrmReportProdottiPersi.CreaCampiVariabili(lInf, lSup: Integer);
var i, x, incX, numCampi: Integer;
begin
  numCampi := lSup - lInf + 1;
  SetLength(qrCampi, numCampi);
  SetLength(qrTitoli, numCampi);
  SetLength(qrLinee, numCampi);
  x := 400;
  incX := 60;
  for i := 0 to High(qrCampi) do
  begin
    CreaCampo(x, i, lInf);
    x := x + incX;
  end;
end;

procedure TfrmReportProdottiPersi.CreaCampo(PosX, iCampo, lInf: Integer);
begin
  qrCampi[iCampo] := TQRDBText.Create(qrbDettagli);
  qrCampi[iCampo].Parent := qrbDettagli;
  qrCampi[iCampo].Name := 'Campo' + IntToStr(iCampo);
  qrCampi[iCampo].Font.Name := 'Verdana';
  qrCampi[iCampo].Font.Size := 8;
  qrCampi[iCampo].Transparent := True;
  qrCampi[iCampo].AutoSize := False;
  qrCampi[iCampo].Top := 1;
  qrCampi[iCampo].Left := PosX;
  qrCampi[iCampo].Width := 50;
  qrCampi[iCampo].DataSet := qrProdotti;
  qrCampi[iCampo].DataField := qrProdotti.Fields.Fields[iCampo+lInf].DisplayName;

  qrTitoli[iCampo] := TQRLabel.Create(qrbTitolo);
  qrTitoli[iCampo].Parent := qrbTitolo;
  qrTitoli[iCampo].Name := 'Titolo' + IntToStr(iCampo);
  qrTitoli[iCampo].Font.Name := 'Verdana';
  qrTitoli[iCampo].Font.Size := 6;
  qrCampi[iCampo].Transparent := True;
  qrTitoli[iCampo].AutoSize := False;
  qrTitoli[iCampo].Top := 48;
  qrTitoli[iCampo].Left := PosX;
  qrTitoli[iCampo].Width := 50;
  qrTitoli[iCampo].Height := 40;
  qrTitoli[iCampo].Font.Style := [fsBold];
  qrTitoli[iCampo].Caption := qrProdotti.Fields.Fields[iCampo+lInf].DisplayName;

  qrLinee[iCampo] := TQRPDFShape.Create(qrbTitolo);
  qrLinee[iCampo].Parent := qrbTitolo;
  qrLinee[iCampo].Name := 'Linea' + IntToStr(iCampo);
  qrLinee[iCampo].Width := 1;
  qrLinee[iCampo].Height := 660;
  qrLinee[iCampo].Top := 48;
  qrLinee[iCampo].Left := PosX-5;  
end;

procedure TfrmReportProdottiPersi.DistruggiCampiVariabili;
var i: Integer;
begin
  for i := 0 to High(qrCampi) do
  begin
    qrCampi[i].Free;
    qrTitoli[i].Free;
    qrLinee[i].Free;    
  end;
end;

end.
