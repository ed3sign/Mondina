unit UReportProdottiPerAssistente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, ADODB, QRCtrls, grimgctrl, QuickRpt, ExtCtrls, QRExport,
  QRPDFFilt;

type
  TfrmReportProdottiPerAssistente = class(TForm)
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
  frmReportProdottiPerAssistente: TfrmReportProdottiPerAssistente;

implementation

uses dmConnection;

{$R *.dfm}

{ TfrmReportMagazzino5 }

var
  qrCampi: array of TQRDBText;
  qrTitoli: array of TQRLabel;
  qrLinee: array of TQRPDFShape;

{ **************************************************************************** }
{ *** Gestione *************************************************************** }

procedure TfrmReportProdottiPerAssistente.AnteprimaReport(lInf, lSup: Integer);
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
  lblInfo1.Caption := 'Prodotti Utilizzati - ' + DateToStr(Date);
  CreaCampiVariabili(lInf, lSup);
  qrReport.PreviewModal;
  DistruggiCampiVariabili;
  qrProdotti.Active := False;
end;

procedure TfrmReportProdottiPerAssistente.CreaCampiVariabili(lInf, lSup: Integer);
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

procedure TfrmReportProdottiPerAssistente.CreaCampo(PosX, iCampo, lInf: Integer);
var s: string;
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
  //ShowMessage(qrProdotti.Fields.Fields[iCampo+lInf].AsString);

  while not qrProdotti.Eof do
  begin
  if qrProdotti.Fields.Fields[iCampo+lInf].AsInteger = 0 then
  begin
    qrProdotti.Edit;
    qrProdotti.Fields.Fields[iCampo+lInf].Text := '';
  end;
  qrProdotti.Next;
  end;
  
  qrCampi[iCampo].DataField := qrProdotti.Fields.Fields[iCampo+lInf].DisplayName;

  s := qrProdotti.Fields.Fields[iCampo+lInf].DisplayName;
  s := StringReplace(s, '$$$', Chr(13), [rfReplaceAll]);

  qrTitoli[iCampo] := TQRLabel.Create(qrbTitolo);
  qrTitoli[iCampo].Parent := qrbTitolo;
  qrTitoli[iCampo].Name := 'Titolo' + IntToStr(iCampo);
  qrTitoli[iCampo].Font.Name := 'Verdana';
  qrTitoli[iCampo].Font.Size := 6;
  qrTitoli[iCampo].Transparent := True;
  qrTitoli[iCampo].AutoSize := False;
  qrTitoli[iCampo].Top := 48;
  qrTitoli[iCampo].Left := PosX;
  qrTitoli[iCampo].Width := 50;
  qrTitoli[iCampo].Height := 57;
  qrTitoli[iCampo].Font.Style := [fsBold];
  qrTitoli[iCampo].Caption := s;

  qrLinee[iCampo] := TQRPDFShape.Create(qrbTitolo);
  qrLinee[iCampo].Parent := qrbTitolo;
  qrLinee[iCampo].Name := 'Linea' + IntToStr(iCampo);
  qrLinee[iCampo].Width := 1;
  qrLinee[iCampo].Height := 660;
  qrLinee[iCampo].Top := 48;
  qrLinee[iCampo].Left := PosX-5;
end;

procedure TfrmReportProdottiPerAssistente.DistruggiCampiVariabili;
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
