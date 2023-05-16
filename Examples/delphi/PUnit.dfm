object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 66
    Top = 30
    Width = 499
    Height = 166
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 66
    Top = 222
    Width = 118
    Height = 25
    Caption = 'Funcional'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 462
    Top = 222
    Width = 99
    Height = 25
    Caption = 'ObjectToJSON'
    TabOrder = 2
    OnClick = Button2Click
  end
end
