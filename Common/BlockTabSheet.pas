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



unit BlockTabSheet;

interface

uses
   Classes, ComCtrls, Forms, CommonInterfaces, Controls, Main_Form;

type

   TBlockTabSheet = class(TTabSheet)
   private
      FForm: TMainForm;
   public
      constructor Create(AMainForm: TMainForm);
      property Form: TMainForm read FForm;
   protected
      procedure PageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
   end;

implementation

uses
   Graphics, ApplicationCommon, Types;

constructor TBlockTabSheet.Create(AMainForm: TMainForm);
begin
   inherited Create(AMainForm.pgcPages);
   Parent := AMainForm.pgcPages;
   PageControl := AMainForm.pgcPages;
   FForm := AMainForm;
   ParentFont := false;
   Font.Color := clNavy;
   Brush.Color := GSettings.DesktopColor;
   Align := alClient;
   PopupMenu := AMainForm.pmPages;
   OnMouseUp := PageMouseUp;
end;

procedure TBlockTabSheet.PageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   lPoint: TPoint;
begin
   if (Button = mbRight) and (GProject <> nil) then
   begin
      lPoint := ClientToScreen(Point(X, Y));
      PopupMenu.PopupComponent := Self;
      PopupMenu.Popup(lPoint.X, lPoint.Y);
   end;
end;

end.
