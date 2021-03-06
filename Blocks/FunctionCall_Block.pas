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



unit FunctionCall_Block;

interface

uses
   Vcl.Graphics, Base_Block, CommonInterfaces;

type

   TFunctionCallBlock = class(TBlock)
      public
         constructor Create(ABranch: TBranch); overload;
         constructor Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; AId: integer = ID_INVALID); overload;
         function Clone(ABranch: TBranch): TBlock; override;
      protected
         procedure Paint; override;
   end;


implementation

uses
   Vcl.Controls, Vcl.Forms, System.Classes, System.Types, ApplicationCommon, CommonTypes;

constructor TFunctionCallBlock.Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; AId: integer = ID_INVALID);
begin
   FType := blFuncCall;
   inherited Create(ABranch, ALeft, ATop, AWidth, AHeight, AId);

   FStatement.SetBounds(10, 1, AWidth-20, 19);
   FStatement.Anchors := [akRight, akLeft, akTop];
   FStatement.SetLRMargins(1, 1);
   FStatement.Color := GSettings.GetShapeColor(shpRoutine);

   FShape := shpRoutine;
   BottomHook := AWidth div 2;
   BottomPoint.X := BottomHook;
   BottomPoint.Y := FStatement.BoundsRect.Bottom + 1;
   IPoint.X := BottomHook + 30;
   IPoint.Y := BottomPoint.Y + 8;
   TopHook.X := BottomHook;
   Constraints.MinWidth := 140;
   Constraints.MinHeight := 51;
end;

function TFunctionCallBlock.Clone(ABranch: TBranch): TBlock;
begin
   result := TFunctionCallBlock.Create(ABranch, Left, Top, Width, Height);
   result.CloneFrom(Self);
end;

constructor TFunctionCallBlock.Create(ABranch: TBranch);
begin
   Create(ABranch, 0, 0, 140, 51);
end;

procedure TFunctionCallBlock.Paint;
var
   br: TPoint;
   lColor: TColor;
   r: TRect;
begin
   inherited;
   Canvas.Brush.Style := bsClear;
   lColor := GSettings.GetShapeColor(FShape);
   if lColor <> GSettings.DesktopColor then
      Canvas.Brush.Color := lColor;
   br := FStatement.BoundsRect.BottomRight;
   Inc(br.Y);
   BottomPoint.Y := br.Y;
   IPoint.Y := br.Y + 8;
   r := Rect(0, FStatement.Top-1, Width, br.Y);
   Canvas.Rectangle(r);
   DrawBlockLabel(5, br.Y, GInfra.CurrentLang.LabelFuncCall);
   DrawArrow(BottomPoint, BottomPoint.X, Height-1);
   r := Rect(FStatement.Left-4, FStatement.Top-1, FStatement.Left-1, br.Y);
   Canvas.Rectangle(r);
   r.SetLocation(br.X+1, r.Top);
   Canvas.Rectangle(r);
   DrawI;
end;

end.
