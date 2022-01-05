unit main;

{$mode delphiunicode}
{$codepage UTF8}

{$WARN 5091 off : Local variable "$1" of a managed type does not seem to be initialized}
{$WARN 4105 off : Implicit string type conversion with potential data loss from "$1" to "$2"}
interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ExtDlgs, ComCtrls, Types;

type

  { TFormMain }

  TFormMain = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    ButtonLoad: TButton;
    ButtonSave: TButton;
    CheckBoxScale: TCheckBox;
    ComboBoxPalette: TComboBox;
    ImageDither: TImage;
    ImageListPalette: TImageList;
    ImageOrigin: TImage;
    Label1: TLabel;
    Label2: TLabel;
    LabelOrigin: TLabel;
    LabelDither: TLabel;
    OpenPictureDialog: TOpenPictureDialog;
    Panel1: TPanel;
    PanelMain: TPanel;
    PanelOrigin: TPanel;
    PanelDither: TPanel;
    SavePictureDialog: TSavePictureDialog;
    ScrollBoxOrigin: TScrollBox;
    ScrollBoxDither: TScrollBox;
    TrackBarDitherPower: TTrackBar;
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure CheckBoxScaleChange(Sender: TObject);
    procedure ComboBoxPaletteChange(Sender: TObject);
    procedure ComboBoxPaletteDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure PanelMainResize(Sender: TObject);
    procedure ScrollBoxDitherPaint(Sender: TObject);
    procedure ScrollBoxOriginPaint(Sender: TObject);
    procedure TrackBarDitherPowerChange(Sender: TObject);
  private
    procedure DitherImage;
    procedure UpdateImagesSize;
  public

  end;

var
  FormMain: TFormMain;

implementation

uses
  BitmapPixels, Dither;

type
  TPaletteEntry = record
    Name: string;
    Palette: array of TPixel;
  end;

const
  Palettes: array of TPaletteEntry = [
    (
      Name: 'Solar Eclipse';
      Palette:
      [
        $FFFFFCFE,
        $FFFFC200,
        $FFFF2A00,
        $FF11070A
      ]
    ),
    (
      Name: 'Monochrome';
      Palette:
      [
        $FFFFFFFF,
        $FF000000
      ]
    ),
    (
      Name: 'Gray 4';
      Palette:
      [
        $FF000000,
        $FF676767,
        $FFb6b6b6,
        $FFffffff
      ]
    ),
    (
      Name: 'Lemon Lime GB';
      Palette:
      [
        $FFcdb81b,
        $FFafb525,
        $FF87b133,
        $FF5fad41
      ]
    ),
    (
      Name: 'Pollen 8';
      Palette:
      [
        $FF73464C,
        $FFAB5675,
        $FFEE6A7C,
        $FFFFA7A5,
        $FFFFE07E,
        $FFFFE7D6,
        $FF72DCBB,
        $FF34ACBA
      ]
    ),
    (
      Name: 'PC 88';
      Palette:
      [
        $FF0000DB,
        $FF00B6DB,
        $FF00DB6D,
        $FFFFB600,
        $FFFF926D,
        $FFDB0000,
        $FFDBDBDB,
        $FF000000
      ]
    ),
    (
      Name: 'Pico 8';
      Palette:
      [
        $FF000000,
        $FF1D2B53,
        $FF7E2553,
        $FF008751,
        $FFAB5236,
        $FF5F574F,
        $FFC2C3C7,
        $FFFFF1E8,
        $FFFF004D,
        $FFFFA300,
        $FFFFEC27,
        $FF00E436,
        $FF29ADFF,
        $FF83769C,
        $FFFF77A8,
        $FFFFCCAA
      ]
    ),
    (
      Name: 'Apple II Lo Res';
      Palette:
      [
        $FF000000,
        $FF515c16,
        $FF843d52,
        $FFea7d27,
        $FF514888,
        $FFe85def,
        $FFf5b7c9,
        $FF006752,
        $FF00c82c,
        $FF919191,
        $FFc9d199,
        $FF00a6f0,
        $FF98dbc9,
        $FFc8c1f7,
        $FFffffff
      ]
    ),
    (
      Name: 'Commodore 64';
      Palette:
      [
        $FF000000,
        $FF626262,
        $FF898989,
        $FFadadad,
        $FFffffff,
        $FF9f4e44,
        $FFcb7e75,
        $FF6d5412,
        $FFa1683c,
        $FFc9d487,
        $FF9ae29b,
        $FF5cab5e,
        $FF6abfc6,
        $FF887ecb,
        $FF50459b,
        $FFa057a3
      ]
    ),
    (
      Name: 'Funky Future';
      Palette:
      [
        $FF2b0f54,
        $FFab1f65,
        $FFff4f69,
        $FFfff7f8,
        $FFff8142,
        $FFffda45,
        $FF3368dc,
        $FF49e7ec
      ]
    ),
    (
      Name: 'ArgeeBey';
      Palette:
      [
        $FF000000,
        $FF1f246a,
        $FF8a1181,
        $FFd14444,
        $FF2ca53e,
        $FF68cbcb,
        $FFe3c72d,
        $FFffffff
      ]
    ),
    (
      Name: 'FuzzyFour';
      Palette:
      [
        $FF302387,
        $FFff3796,
        $FF00faac,
        $FFfffdaf
      ]
    ),
    (
      Name: 'Ceral GB';
      Palette:
      [
        $FF2b061e,
        $FF875053,
        $FFd8c86e,
        $FFffeed6
      ]
    )
  ];

{$R *.lfm}

{ TFormMain }

procedure TFormMain.ButtonLoadClick(Sender: TObject);
begin
  if OpenPictureDialog.Execute then
  begin
    ImageOrigin.Picture.LoadFromFile(OpenPictureDialog.FileName);
    DitherImage;
    UpdateImagesSize;
  end;
end;

procedure TFormMain.ButtonSaveClick(Sender: TObject);
begin
  if SavePictureDialog.Execute then
  begin
    ImageDither.Picture.SaveToFile(SavePictureDialog.FileName);
  end;
end;

procedure TFormMain.CheckBoxScaleChange(Sender: TObject);
begin
  UpdateImagesSize;
end;

procedure TFormMain.ComboBoxPaletteChange(Sender: TObject);
begin
  DitherImage;
end;

procedure TFormMain.ComboBoxPaletteDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
const
  MaxColorCount = 64;
var
  Count, I: Integer;
  Color: TPixelRec;
  OldColor: TColor;
begin
  TComboBox(Control).Canvas.FillRect(ARect);

  OldColor := TComboBox(Control).Canvas.Brush.Color;
  Count := Length(Palettes[Index].Palette);
  for I := 0 to Count - 1 do
  begin
    Color := TPixelRec(Palettes[Index].Palette[I]);
    TComboBox(Control).Canvas.Brush.Color := RGBToColor(Color.R, Color.G, Color.B);
    TComboBox(Control).Canvas.FillRect(
      ARect.Left + I * (MaxColorCount div Count) + 2,
      ARect.Top + 1,
      ARect.Left + (I + 1) * (MaxColorCount div Count) + 2,
      ARect.Bottom - 1
    );
  end;

  TComboBox(Control).Canvas.Brush.Color := OldColor;
  ARect.Left := ARect.Left + MaxColorCount + 2;
  TComboBox(Control).Canvas.TextOut(ARect.Left, ARect.Top, TComboBox(Control).Items[Index]);
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  PaletteEntry: TPaletteEntry;
begin
  for PaletteEntry in Palettes do
  begin
    ComboBoxPalette.Items.Add(PaletteEntry.Name);
  end;

  // defaults
  ComboBoxPalette.ItemIndex := 0;
  TrackBarDitherPower.Position := 200;
  CheckBoxScale.Checked := False;

  DitherImage;
  UpdateImagesSize;
end;

procedure TFormMain.PanelMainResize(Sender: TObject);
begin
  PanelOrigin.Width :=
    (PanelMain.ClientWidth - PanelMain.ChildSizing.HorizontalSpacing - PanelMain.BorderWidth * 2) div 2 - 1;
end;

procedure TFormMain.ScrollBoxDitherPaint(Sender: TObject);
begin
  // это ужастный хак
  ScrollBoxOrigin.VertScrollBar.Position := ScrollBoxDither.VertScrollBar.Position;
  ScrollBoxOrigin.HorzScrollBar.Position := ScrollBoxDither.HorzScrollBar.Position;
end;

procedure TFormMain.ScrollBoxOriginPaint(Sender: TObject);
begin
  // это ужастный хак
  ScrollBoxDither.VertScrollBar.Position := ScrollBoxOrigin.VertScrollBar.Position;
  ScrollBoxDither.HorzScrollBar.Position := ScrollBoxOrigin.HorzScrollBar.Position;
end;

procedure TFormMain.TrackBarDitherPowerChange(Sender: TObject);
begin
  DitherImage;
end;

procedure TFormMain.DitherImage;
var
  DitherBitmap: TBitmap;
  BitmapData: TBitmapData;
begin
  // создаем временный bitmap
  DitherBitmap := TBitmap.Create();
  try
    // копируем в него ImageOrigin
    DitherBitmap.Assign(ImageOrigin.Picture.Bitmap);

    // получаем доступ к пикселам временного bitmap
    BitmapData.Map(DitherBitmap, TAccessMode.ReadWrite, False);
    try
      // дизеринг (смотри Dither.pas)
      FloydSteinbergDithering(BitmapData, Palettes[ComboBoxPalette.ItemIndex].Palette, TrackBarDitherPower.Position);
    finally
      BitmapData.Unmap();
    end;

    // применяем временный bitmap к ImageDither
    ImageDither.Picture.Assign(DitherBitmap);

  finally
    DitherBitmap.Free();
  end;

  ImageDither.Refresh;
end;

procedure TFormMain.UpdateImagesSize;
var
  Scale: Integer;
begin
  if CheckBoxScale.Checked then
    Scale := 2
  else
    Scale := 1;

  ImageOrigin.Width := ImageOrigin.Picture.Width * Scale;
  ImageOrigin.Height := ImageOrigin.Picture.Height * Scale;
  ImageDither.Width := ImageDither.Picture.Width * Scale;
  ImageDither.Height := ImageDither.Picture.Height * Scale;
end;

end.

