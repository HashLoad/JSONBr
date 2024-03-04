object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 506
  ClientWidth = 705
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesktopCenter
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 681
    Height = 459
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 473
    Width = 118
    Height = 25
    Caption = 'Funcional'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 190
    Top = 473
    Width = 99
    Height = 25
    Caption = 'ObjectToJSON'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 352
    Top = 473
    Width = 121
    Height = 25
    Caption = 'JsonToObject'
    TabOrder = 3
    OnClick = Button3Click
  end
end
