object frmReportProdottiPersi: TfrmReportProdottiPersi
  Left = 151
  Top = 138
  BorderStyle = bsDialog
  Caption = 'Report Prodotti Persi'
  ClientHeight = 635
  ClientWidth = 1152
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object qrReport: TQuickRep
    Left = 13
    Top = 9
    Width = 1123
    Height = 794
    Frame.Color = clBlack
    Frame.DrawTop = False
    Frame.DrawBottom = False
    Frame.DrawLeft = False
    Frame.DrawRight = False
    DataSet = qrProdotti
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    Functions.Strings = (
      'PAGENUMBER'
      'COLUMNNUMBER'
      'REPORTTITLE'
      'QRSTRINGSBAND1'
      'QRLOOPBAND1')
    Functions.DATA = (
      '0'
      '0'
      #39#39
      #39#39
      '0')
    Options = [FirstPageHeader, LastPageFooter]
    Page.Columns = 1
    Page.Orientation = poLandscape
    Page.PaperSize = A4
    Page.Values = (
      100.000000000000000000
      2100.000000000000000000
      100.000000000000000000
      2970.000000000000000000
      100.000000000000000000
      100.000000000000000000
      0.000000000000000000)
    PrinterSettings.Copies = 1
    PrinterSettings.OutputBin = Auto
    PrinterSettings.Duplex = False
    PrinterSettings.FirstPage = 0
    PrinterSettings.LastPage = 0
    PrinterSettings.UseStandardprinter = False
    PrinterSettings.UseCustomBinCode = False
    PrinterSettings.CustomBinCode = 0
    PrinterSettings.ExtendedDuplex = 0
    PrinterSettings.UseCustomPaperCode = False
    PrinterSettings.CustomPaperCode = 0
    PrinterSettings.PrintMetaFile = False
    PrinterSettings.PrintQuality = 0
    PrinterSettings.Collate = 0
    PrinterSettings.ColorOption = 0
    PrintIfEmpty = True
    SnapToGrid = True
    Units = MM
    Zoom = 100
    PrevFormStyle = fsNormal
    PreviewInitialState = wsNormal
    PrevInitialZoom = qrZoomToFit
    object qrbTitolo: TQRBand
      Left = 38
      Top = 38
      Width = 1047
      Height = 99
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      TransparentBand = False
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        261.937500000000000000
        2770.187500000000000000)
      PreCaluculateBandHeight = False
      KeepOnOnePage = False
      BandType = rbPageHeader
      object lblInfo1: TQRLabel
        Left = 16
        Top = 16
        Width = 99
        Height = 17
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          44.979166666666670000
          42.333333333333330000
          42.333333333333330000
          261.937500000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = True
        AutoStretch = False
        Caption = 'Prodotti Persi'
        Color = clWhite
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Verdana'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = False
        WordWrap = True
        FontSize = 10
      end
      object QRPDFShape1: TQRPDFShape
        Left = 16
        Top = 35
        Width = 1009
        Height = 5
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          13.229166666666670000
          42.333333333333330000
          92.604166666666670000
          2669.645833333333000000)
        VertAdjust = 0
        ShapeType = qrsRectangle
      end
      object lblInfo2: TQRLabel
        Left = 16
        Top = 48
        Width = 200
        Height = 40
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          105.833333333333300000
          42.333333333333330000
          127.000000000000000000
          529.166666666666700000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Caption = 'Prodotto'
        Color = clWhite
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -8
        Font.Name = 'Verdana'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = False
        WordWrap = True
        FontSize = 6
      end
      object QRSysData1: TQRSysData
        Left = 975
        Top = 16
        Width = 50
        Height = 17
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          44.979166666666670000
          2579.687500000000000000
          42.333333333333330000
          132.291666666666700000)
        Alignment = taRightJustify
        AlignToBand = False
        AutoSize = False
        Color = clWhite
        Data = qrsPageNumber
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        Transparent = False
        FontSize = 8
      end
    end
    object qrbDettagli: TQRBand
      Left = 38
      Top = 137
      Width = 1047
      Height = 25
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      TransparentBand = True
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        66.145833333333330000
        2770.187500000000000000)
      PreCaluculateBandHeight = False
      KeepOnOnePage = False
      BandType = rbDetail
      object lblNome: TQRDBText
        Left = 16
        Top = 1
        Width = 375
        Height = 17
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          44.979166666666670000
          42.333333333333330000
          2.645833333333333000
          992.187500000000000000)
        Alignment = taLeftJustify
        AlignToBand = False
        AutoSize = False
        AutoStretch = False
        Color = clWhite
        DataSet = qrProdotti
        DataField = 'Nome'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Verdana'
        Font.Style = []
        ParentFont = False
        Transparent = False
        WordWrap = True
        FontSize = 8
      end
      object QRPDFShape2: TQRPDFShape
        Left = 16
        Top = 18
        Width = 1009
        Height = 1
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          2.645833333333333000
          42.333333333333330000
          47.625000000000000000
          2669.645833333333000000)
        VertAdjust = 0
        ShapeType = qrsRectangle
      end
    end
  end
  object qrProdotti: TADOQuery
    Connection = dmCnt.AdoCnt
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'TRANSFORM Sum(qrM.QtaUsata) AS SommaDiQtaUsata'
      'SELECT qrM.Prodotti.Nome, Sum(qrM.QtaUsata) AS Totale'
      
        'FROM [SELECT Prodotti.Nome, Studi.Nome, Prodotti_Cassetti.QtaUsa' +
        'ta'
      
        'FROM Prodotti INNER JOIN (Studi INNER JOIN (Mobili INNER JOIN (C' +
        'assetti INNER JOIN Prodotti_Cassetti ON Cassetti.Codice = Prodot' +
        'ti_Cassetti.CodCassetto) ON Mobili.Codice = Cassetti.CodMobile) ' +
        'ON Studi.Codice = Mobili.CodStudio) ON Prodotti.Codice = Prodott' +
        'i_Cassetti.CodProdotto'
      ''
      ' ]. AS qrM'
      'GROUP BY qrM.Prodotti.Nome'
      'PIVOT qrM.Studi.Nome;')
    Left = 14
    Top = 30
  end
  object QRExcelFilter1: TQRExcelFilter
    Left = 285
    Top = 11
  end
  object QRPDFFilter1: TQRPDFFilter
    CompressionOn = False
    Left = 245
    Top = 11
  end
  object QRTextFilter1: TQRTextFilter
    Left = 205
    Top = 11
  end
  object QRRTFFilter1: TQRRTFFilter
    Left = 325
    Top = 9
  end
end
