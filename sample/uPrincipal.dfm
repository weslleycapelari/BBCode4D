object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'BBCode4D Sample'
  ClientHeight = 632
  ClientWidth = 895
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object pnlBody: TPanel
    Left = 0
    Top = 0
    Width = 895
    Height = 632
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 704
    object GroupBox1: TGroupBox
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 397
      Height = 624
      Align = alLeft
      Caption = 'Memo Edit (BBCode)'
      TabOrder = 0
      object mmoBBCode: TMemo
        AlignWithMargins = True
        Left = 5
        Top = 20
        Width = 387
        Height = 599
        Align = alClient
        Lines.Strings = (
          '[b]Texto em negrito[/b]'
          '[i]Texto em it'#225'lico[/i]'
          '[u]Texto sublinhado[/u]'
          '[s]Texto riscado[/s]'
          '[o]Texto com contorno[/o]'
          '[lower]TEXTO EM CAIXA BAIXA[/lower]'
          '[upper]texto em caixa alta[/upper]'
          '[small]Texto Pequeno[/small]'
          'Texto subscrito X[sub]2[/sub]'
          'Texto superscrito X[sup]2[/sup]'
          '[shadow]Texto com sombra[/shadow]'
          '[color=red]Texto vermelho[/color]'
          '[size=24]Texto com tamanho 24[/size]'
          '[font=Arial]Texto em Arial[/font]'
          '[align=right]Texto '#224' direita[/align]'
          
            '[align=justify]Texto Justificado - Lorem ipsum dolor sit amet, c' +
            'onsectetur adipiscing elit, sed do eiusmod tempor incididunt ut ' +
            'labore et dolore magna aliqua. Ut enim ad minim veniam, quis nos' +
            'trud exercitation ullamco laboris nisi ut aliquip ex ea commodo ' +
            'consequat. Duis aute irure dolor in reprehenderit in voluptate v' +
            'elit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint' +
            ' occaecat cupidatat non proident, sunt in culpa qui officia dese' +
            'runt mollit anim id est laborum.[/align]'
          '[align=center]Texto centralizado[/align]'
          '[align=left]Texto '#224' esquerda[/align]'
          '[url]https://www.example.com[/url]'
          '[url=https://www.example.com]Link para o site de exemplo[/url]'
          '[email]example@example.com[/email]'
          
            '[email=example@example.com]Enviar e-mail para example@example.co' +
            'm[/email]'
          '[list]'
          '[li]Item 1[/li]'
          '[li]Item 2[/li]'
          '[li]Item 3[/li]'
          '[/list]'
          '[list=1]'
          '[li]Item 1[/li]'
          '[li]Item 2[/li]'
          '[li]Item 3[/li]'
          '[/list]'
          '[list=a]'
          '[li]Item 1[/li]'
          '[li]Item 2[/li]'
          '[li]Item 3[/li]'
          '[/list]'
          '[list=I]'
          '[li]Item 1[/li]'
          '[li]Item 2[/li]'
          '[li]Item 3[/li]'
          '[/list]'
          '[ul]'
          '[li]Item 1[/li]'
          '[li]Item 2[/li]'
          '[li]Item 3[/li]'
          '[/ul]'
          '[ol]'
          '[li]Item 1[/li]'
          '[li]Item 2[/li]'
          '[li]Item 3[/li]'
          '[/ol]'
          '[img]https://picsum.photos/id/237/536/354[/img]'
          
            '[img width=536 height=354]https://picsum.photos/id/237/536/354[/' +
            'img]'
          '[img=536x354]https://picsum.photos/id/237/536/354[/img]')
        ScrollBars = ssBoth
        TabOrder = 0
        OnChange = mmoBBCodeChange
        ExplicitWidth = 686
        ExplicitHeight = 204
      end
    end
    object GroupBox2: TGroupBox
      AlignWithMargins = True
      Left = 407
      Top = 4
      Width = 484
      Height = 624
      Align = alClient
      Caption = 'Rich Edit'
      TabOrder = 1
      ExplicitLeft = 4
      ExplicitTop = 239
      ExplicitWidth = 696
      ExplicitHeight = 389
      object redtBBCode: TRichEdit
        AlignWithMargins = True
        Left = 5
        Top = 20
        Width = 474
        Height = 599
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
        ExplicitWidth = 686
        ExplicitHeight = 364
      end
    end
  end
end
