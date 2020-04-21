object frmMain: TfrmMain
  Left = 428
  Top = 189
  Caption = 'Custom Title Bar Test'
  ClientHeight = 342
  ClientWidth = 533
  Color = clBtnFace
  Constraints.MinHeight = 329
  Constraints.MinWidth = 383
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.Enabled = True
  OldCreateOrder = False
  OnActivate = FormActivate
  DesignSize = (
    533
    342)
  PixelsPerInch = 96
  TextHeight = 15
  object btnClose: TSpeedButton
    Left = 217
    Top = 311
    Width = 75
    Height = 25
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akBottom]
    Caption = '&Close'
    OnClick = btnCloseClick
    ExplicitLeft = 139
    ExplicitTop = 264
  end
  object SpeedButton1: TSpeedButton
    Left = 296
    Top = 2
    Width = 95
    Height = 25
    Caption = 'Me too!!! Yay!'
  end
  object SpeedButton2: TSpeedButton
    Left = 368
    Top = 96
    Width = 23
    Height = 22
  end
  object SpeedButton3: TSpeedButton
    Left = 170
    Top = 2
    Width = 87
    Height = 22
    Caption = 'I am  a Button!'
  end
  inline ClientFrame: TfraMain
    Left = 0
    Top = 32
    Width = 468
    Height = 249
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alCustom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    ExplicitTop = 32
    ExplicitWidth = 468
    ExplicitHeight = 249
    inherited chkEnableCustomFrame: TCheckBox
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
    end
    inherited grpBorderIcons: TGroupBox
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      inherited chkSysMenu: TCheckBox
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
      inherited chkMinimize: TCheckBox
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
      inherited chkMaximize: TCheckBox
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
    end
    inherited grpBorderStyle: TGroupBox
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      inherited rdoSingle: TRadioButton
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
      inherited rdoSizeable: TRadioButton
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
      inherited rdoDialog: TRadioButton
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
      inherited rdoToolWindow: TRadioButton
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
      inherited rdoSizeableToolWindow: TRadioButton
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
    end
    inherited chkGlassFooter: TCheckBox
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
    end
    inherited grpIcon: TGroupBox
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      inherited btnResetIcon: TButton
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
      inherited btnLoadIcon: TButton
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
      end
    end
    inherited grpCaption: TGroupBox
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      inherited edtCaption: TEdit
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        ExplicitHeight = 21
      end
    end
  end
end
