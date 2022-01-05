unit Dither;

{$mode delphiunicode}

interface

uses
  Classes, SysUtils, BitmapPixels;

procedure FloydSteinbergDithering(const Image: TBitmapData; const Palette: array of TPixel; const Power: Byte);

implementation

function CalcColorDist(const Color1, Color2: TPixelRec): Integer;
var
  DistR, DistG, DistB: Integer;
begin
  DistR := Color1.R - Color2.R;
  DistG := Color1.G - Color2.G;
  DistB := Color1.B - Color2.B;

  Result := DistR * DistR + DistG * DistG + DistB * DistB;
end;

function FindClosestColor(const Color: TPixelRec; const Palette: array of TPixel): TPixelRec;
var
  MinDist: Integer;
  PaletteColor: TPixelRec;
begin
  if Length(Palette) = 0 then
    Exit($FF000000);

  MinDist := High(Integer);
  for PaletteColor in Palette do
  begin
    if MinDist > CalcColorDist(Color, TPixelRec(PaletteColor)) then
    begin
      Result := TPixelRec(PaletteColor);
      MinDist := CalcColorDist(Color, TPixelRec(PaletteColor));
    end;
  end;
end;

type
  TDitherColorError = record
    R: Integer;
    G: Integer;
    B: Integer;
  end;

function ClipByte(const Value: Integer): Byte;
begin
  if Value > 255 then
    Exit(255)
  else if Value < 0 then
    Exit(0);

  Result := Value;
end;

procedure FloydSteinbergDithering(const Image: TBitmapData; const Palette: array of TPixel; const Power: Byte);
var
  X, Y, I: Integer;
  Color, NewColor: TPixelRec;
  Error: TDitherColorError;
  CurrLineError: array of TDitherColorError;
  NextLineError: array of TDitherColorError;
begin
  SetLength(CurrLineError, Image.Width + 2);
  SetLength(NextLineError, Image.Width + 2);

  for Y := 0 to Image.Height - 1 do
  begin
    for X := 0 to Image.Width - 1 do
    begin
      Color := Image.Pixels[X, Y];

      Color.A := 255;
      Color.R := ClipByte(Color.R + (CurrLineError[X + 1].R * Power div 16) div 255);
      Color.G := ClipByte(Color.G + (CurrLineError[X + 1].G * Power div 16) div 255);
      Color.B := ClipByte(Color.B + (CurrLineError[X + 1].B * Power div 16) div 255);

      NewColor := FindClosestColor(Color, Palette);

      Image.Pixels[X, Y] := NewColor;

      Error.R := Color.R - NewColor.R;
      Error.G := Color.G - NewColor.G;
      Error.B := Color.B - NewColor.B;

      // [             *     7/16(0) ]
      // [ 3/16(1)  5/16(2)  1/16(3) ]
      // 0
      CurrLineError[X + 2].R := CurrLineError[X + 2].R + 7 * Error.R;
      CurrLineError[X + 2].G := CurrLineError[X + 2].G + 7 * Error.G;
      CurrLineError[X + 2].B := CurrLineError[X + 2].B + 7 * Error.B;
      // 1
      NextLineError[X + 0].R := NextLineError[X + 0].R + 3 * Error.R;
      NextLineError[X + 0].G := NextLineError[X + 0].G + 3 * Error.G;
      NextLineError[X + 0].B := NextLineError[X + 0].B + 3 * Error.B;
      // 2
      NextLineError[X + 1].R := NextLineError[X + 1].R + 5 * Error.R;
      NextLineError[X + 1].G := NextLineError[X + 1].G + 5 * Error.G;
      NextLineError[X + 1].B := NextLineError[X + 1].B + 5 * Error.B;
      // 3
      NextLineError[X + 2].R := NextLineError[X + 2].R + 1 * Error.R;
      NextLineError[X + 2].G := NextLineError[X + 2].G + 1 * Error.G;
      NextLineError[X + 2].B := NextLineError[X + 2].B + 1 * Error.B;
    end;

    for I := 0 to High(CurrLineError) do
    begin
      CurrLineError[I] := NextLineError[I];
      NextLineError[I] := Default(TDitherColorError);
    end;
  end;
end;

end.

