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

{ This unit contains thread implementation to highlight TCustomEdits while }
{ switching nodes on TreeView_Form.tvFlowChart tree}

unit FlashThread;

interface

uses
   StdCtrls, Classes, Controls, CommonInterfaces;

type

   THackEdit = class(TCustomEdit);

   TFlashThread = class(TThread)
   private
      FFocusInfo: TFocusInfo;
      procedure PerformFlash;
   protected
      procedure Execute; override;
   public
      constructor Create(const AFocusInfo: TFocusInfo);
   end;


implementation

uses
   Graphics, SysUtils;

const
   SLEEP_TIME = 400;

constructor TFlashThread.Create(const AFocusInfo: TFocusInfo);
begin
   inherited Create(false);
   FFocusInfo := AFocusInfo;
   FreeOnTerminate := true;
end;

procedure TFlashThread.Execute;
begin
   Synchronize(PerformFlash);
end;

procedure TFlashThread.PerformFlash;
var
   lFontColor: TColor;
begin
   if FFocusInfo.FocusEdit <> nil then
   begin
      with THackEdit(FFocusInfo.FocusEdit) do
      begin
         lFontColor := Font.Color;
         Font.Color := Color;
         Color := lFontColor;
         Repaint;
         Sleep(SLEEP_TIME);
         Color := Font.Color;
         Font.Color := lFontColor;
         Repaint;
         if FFocusInfo.ActiveControl = nil then
         begin
            if FFocusInfo.SelStart >= 0 then
            begin
               SelStart := FFocusInfo.SelStart;
               SelLength := Length(FFocusInfo.SelText);
            end;
            if CanFocus then SetFocus;
         end
         else if FFocusInfo.ActiveControl.CanFocus then
         begin
            FFocusInfo.ActiveControl.SetFocus;
            if FFocusInfo.FocusEditForm <> nil then
               FFocusInfo.FocusEditForm.ActiveControl := FFocusInfo.FocusEdit;
         end;
      end;
   end;
end;

end.
