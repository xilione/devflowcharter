{
   Copyright (C) 2006 The devFlowcharter project.
   The initial author of this file is Michal Domagala.

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
}



unit InOut_Block;

interface

uses
   Vcl.Graphics, Base_Block, CommonInterfaces;

type

   TInOutBlock = class(TBlock)
      protected
         FLabel,
         FLabelSegoe: string;
         constructor Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; const AText: string; AId: integer = ID_INVALID; AdjustWidth: boolean = false); overload;
         procedure Paint; override;
         procedure PutTextControls; override;
   end;

   TInputBlock = class(TInOutBlock)
      public
         constructor Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; AId: integer = ID_INVALID; AdjustWidth: boolean = false); overload;
         constructor Create(ABranch: TBranch); overload;
         function Clone(ABranch: TBranch): TBlock; override;
   end;

   TOutputBlock = class(TInOutBlock)
      public
         constructor Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; AId: integer = ID_INVALID; AdjustWidth: boolean = false); overload;
         constructor Create(ABranch: TBranch); overload;
         function Clone(ABranch: TBranch): TBlock; override;
   end;

implementation

uses
   Vcl.Controls, System.Classes, WinApi.Windows, System.Types, System.UITypes, System.Math,
   ApplicationCommon, CommonTypes;

constructor TInOutBlock.Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; const AText: string; AId: integer = ID_INVALID; AdjustWidth: boolean = false);
var
   w: integer;
begin

   inherited Create(ABranch, ALeft, ATop, AWidth, AHeight, AId);

   FStatement.Anchors := [akRight, akLeft, akTop];
   FShape := shpParallel;
   FStatement.Color := GSettings.GetShapeColor(FShape);
   FStatement.Text := AText;
   PutTextControls;
   if AdjustWidth then
   begin
      w :=  TInfra.GetTextWidth(FStatement.Text, FStatement) + FStatement.Left + 20;
      if Width < w then
         Width := w;
   end;
   w := GInfra.CurrentLang.InOutCursorPos;
   FStatement.SelStart := IfThen(w <= 0, Length(FStatement.Text) + w, w - 1);
   BottomHook := Width div 2;
   BottomPoint.X := BottomHook;
   BottomPoint.Y := 30;
   IPoint.X := BottomHook + 30;
   IPoint.Y := 40;
   TopHook.X := BottomHook;
   Constraints.MinWidth := 150;
   Constraints.MinHeight := 61;
end;

constructor TInputBlock.Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; AId: integer = ID_INVALID; AdjustWidth: boolean = false);
begin
   FType := blInput;
   FLabel := i18Manager.GetString('CaptionIn');
   FLabelSegoe := GInfra.CurrentLang.LabelIn;
   inherited Create(ABranch, ALeft, ATop, AWidth, AHeight, GInfra.CurrentLang.InputFunction, AId, AdjustWidth);
end;

constructor TOutputBlock.Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; AId: integer = ID_INVALID; AdjustWidth: boolean = false);
begin
   FType := blOutput;
   FLabel := i18Manager.GetString('CaptionOut');
   FLabelSegoe := GInfra.CurrentLang.LabelOut;
   inherited Create(ABranch, ALeft, ATop, AWidth, AHeight, GInfra.CurrentLang.OutputFunction, AId, AdjustWidth);
end;

function TInputBlock.Clone(ABranch: TBranch): TBlock;
begin
   result := TInputBlock.Create(ABranch, Left, Top, Width, Height);
   result.CloneFrom(Self);
end;

function TOutputBlock.Clone(ABranch: TBranch): TBlock;
begin
   result := TOutputBlock.Create(ABranch, Left, Top, Width, Height);
   result.CloneFrom(Self);
end;

constructor TInputBlock.Create(ABranch: TBranch);
begin
   Create(ABranch, 0, 0, 150, 61, ID_INVALID, true);
end;

constructor TOutputBlock.Create(ABranch: TBranch);
begin
   Create(ABranch, 0, 0, 150, 61, ID_INVALID, true);
end;

procedure TInOutBlock.Paint;
var
   R: TRect;
   w: integer;
   fontStyles: TFontStyles;
   lColor: TColor;
begin
   inherited;
   w := Canvas.TextWidth(FLabel);
   DrawArrow(BottomPoint, BottomPoint.X, Height-1);
   Canvas.Brush.Style := bsClear;
   lColor := GSettings.GetShapeColor(FShape);
   if lColor <> GSettings.DesktopColor then
      Canvas.Brush.Color := lColor;
   Canvas.Polygon([Point(20, 0),
                   Point(Width-1, 0),
                   Point(Width-21, 30),
                   Point(0, 30),
                   Point(20, 0)]);
   Canvas.MoveTo(w+32, 0);
   Canvas.LineTo(w+12, 30);
   fontStyles := Canvas.Font.Style;
   Canvas.Font.Style := [];
   R := Rect(17, 15-(Canvas.TextHeight('X') div 2), w+17, 23);
   DrawText(Canvas.Handle, PChar(FLabel), -1, R, DT_CENTER);
   Canvas.Font.Style := fontStyles;
   DrawBlockLabel(5, 30, FLabelSegoe);
   DrawI;
end;

procedure TInOutBlock.PutTextControls;
var
   t, l: integer;
begin
   l := Canvas.TextWidth(FLabel);
   case FStatement.Font.Size of
      12: l := l + 37;
      10: l := l + 33;
   else
      l := l + 30;
   end;
   t := 17 - FStatement.Height div 2;
   if t + FStatement.Height > 29 then
      t := 30 - FStatement.Height;
   if t < 4 then
      l := l + 4 - t;
   FStatement.SetBounds(l, t, Width-l-20, FStatement.Height);
end;

end.
