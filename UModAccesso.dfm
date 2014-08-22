object frmLoginModAccesso: TfrmLoginModAccesso
  Left = 501
  Top = 357
  BorderStyle = bsDialog
  Caption = 'Modalit'#224' di Accesso'
  ClientHeight = 186
  ClientWidth = 199
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbAssociazione: TGroupBox
    Left = 7
    Top = 80
    Width = 185
    Height = 97
    TabOrder = 1
    object cbEntra: TButton
      Left = 55
      Top = 56
      Width = 75
      Height = 25
      Caption = 'Entra'
      TabOrder = 1
      OnClick = cbEntraClick
    end
    object cbAssociazione: TComboBox
      Left = 16
      Top = 24
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object gbInfo: TGroupBox
    Left = 8
    Top = 8
    Width = 185
    Height = 65
    TabOrder = 0
    object btnAssistente: TButton
      Left = 10
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Assistente'
      TabOrder = 0
      OnClick = btnAssistenteClick
    end
    object btnSostituto: TButton
      Left = 94
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Sostituto'
      TabOrder = 1
      OnClick = btnSostitutoClick
    end
  end
  object qrQuery: TADOQuery
    Connection = dmCnt.AdoCnt
    Parameters = <>
    Left = 26
    Top = 144
  end
end
