object fraMain: TfraMain
  Left = 0
  Top = 0
  Width = 369
  Height = 254
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentBackground = False
  ParentFont = False
  TabOrder = 0
  object chkEnableCustomFrame: TCheckBox
    Left = 8
    Top = 8
    Width = 353
    Height = 34
    Caption = 
      '&Enable custom frame.  Insofar as this demo works correctly, cha' +
      'nging this setting should make next to no difference.'
    TabOrder = 0
    WordWrap = True
    OnClick = chkEnableCustomFrameClick
  end
  object grpBorderIcons: TGroupBox
    Left = 8
    Top = 94
    Width = 113
    Height = 89
    Caption = ' &Border icons '
    ParentBackground = False
    TabOrder = 2
    object chkSysMenu: TCheckBox
      Left = 8
      Top = 18
      Width = 97
      Height = 17
      Caption = 'System menu'
      TabOrder = 0
      OnClick = chkBorderIconClick
    end
    object chkMinimize: TCheckBox
      Left = 8
      Top = 41
      Width = 97
      Height = 17
      Caption = 'Minimise'
      TabOrder = 1
      OnClick = chkBorderIconClick
    end
    object chkMaximize: TCheckBox
      Left = 8
      Top = 64
      Width = 97
      Height = 17
      Caption = 'Maximise'
      TabOrder = 2
      OnClick = chkBorderIconClick
    end
  end
  object grpBorderStyle: TGroupBox
    Left = 131
    Top = 94
    Width = 230
    Height = 89
    Caption = ' Border &style '
    ParentBackground = False
    TabOrder = 3
    object rdoSingle: TRadioButton
      Left = 8
      Top = 18
      Width = 77
      Height = 17
      Caption = 'Single'
      TabOrder = 0
      OnClick = rdoBorderStyleClick
    end
    object rdoSizeable: TRadioButton
      Left = 8
      Top = 41
      Width = 77
      Height = 17
      Caption = 'Sizeable'
      TabOrder = 1
      OnClick = rdoBorderStyleClick
    end
    object rdoDialog: TRadioButton
      Left = 8
      Top = 64
      Width = 69
      Height = 17
      Caption = 'Dialog'
      TabOrder = 2
      OnClick = rdoBorderStyleClick
    end
    object rdoToolWindow: TRadioButton
      Left = 90
      Top = 18
      Width = 95
      Height = 17
      Caption = 'Tool window'
      TabOrder = 3
      OnClick = rdoBorderStyleClick
    end
    object rdoSizeableToolWindow: TRadioButton
      Left = 90
      Top = 41
      Width = 136
      Height = 17
      Caption = 'Sizeable tool window'
      TabOrder = 4
      OnClick = rdoBorderStyleClick
    end
  end
  object chkGlassFooter: TCheckBox
    Left = 8
    Top = 51
    Width = 349
    Height = 34
    Caption = 
      'E&xtend glass at bottom of form. This setting is independent fro' +
      'm the first.'
    TabOrder = 1
    WordWrap = True
    OnClick = chkGlassFooterClick
  end
  object grpIcon: TGroupBox
    Left = 188
    Top = 191
    Width = 173
    Height = 56
    Caption = ' Icon '
    TabOrder = 5
    object btnResetIcon: TButton
      Left = 8
      Top = 20
      Width = 75
      Height = 25
      Caption = '&Reset'
      Enabled = False
      TabOrder = 0
      OnClick = btnResetIconClick
    end
    object btnLoadIcon: TButton
      Left = 89
      Top = 20
      Width = 75
      Height = 25
      Caption = '&Load...'
      TabOrder = 1
      OnClick = btnLoadIconClick
    end
  end
  object grpCaption: TGroupBox
    Left = 8
    Top = 191
    Width = 169
    Height = 56
    Caption = ' &Caption '
    TabOrder = 4
    object edtCaption: TEdit
      Left = 8
      Top = 21
      Width = 153
      Height = 23
      TabOrder = 0
      OnChange = edtCaptionChange
    end
  end
  object dlgLoadIcon: TOpenPictureDialog
    DefaultExt = 'ico'
    Filter = 'Icons (*.ico)|*.ico'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Title = 'Load icon'
    Left = 160
    Top = 224
  end
end
