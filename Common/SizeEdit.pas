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

unit SizeEdit;

interface

uses
  Vcl.Controls, Vcl.StdCtrls;

type

  TSizeEdit = class(TEdit)
     private
        function GetDimensionCount: integer;
     public
        property DimensionCount: integer read GetDimensionCount;
        constructor Create(AParent: TWinControl);
        function ParseSize: boolean;
        function GetDimensions: TArray<string>;
        procedure OnChangeSize(Sender: TObject);
  end;


implementation

uses
   System.SysUtils, System.StrUtils, System.Math, ApplicationCommon, LangDefinition, YaccLib;

constructor TSizeEdit.Create(AParent: TWinControl);
begin
   inherited Create(AParent);
   Parent := AParent;
   Text := '1';
   ShowHint := true;
   CharCase := ecUpperCase;
   Hint := i18Manager.GetString('DisableFieldValid') + sLineBreak + ReplaceStr(i18Manager.GetString('edtSizeHint'), LB_PHOLDER2, sLineBreak);
   ParentFont := false;
   Font.Style := [];
   Font.Color := BLACK_COLOR;
   DoubleBuffered := true;
   OnChange := OnChangeSize;
end;

function TSizeEdit.ParseSize: boolean;
var
   dim: string;
   i, dcount: integer;
   lang: TLangDefinition;
   dims: TArray<string>;
   goParse: boolean;
begin
   result := true;
   if GSettings.ValidateDeclaration then
   begin
      dcount := GetDimensionCount;
      if dcount < 0 then
         result := false
      else if dcount > 0 then
      begin
         lang := GInfra.GetLangDefinition(PASCAL_LANG_ID);
         goParse := (lang <> nil) and Assigned(lang.Parse);
         dims := GetDimensions;
         for i := 0 to High(dims) do
         begin
            dim := dims[i];
            if (dim <> '') and ((dim[1] = '0') or (dim[1] = '-') or (goParse and not lang.Parse(dim, yymVarSize))) then
            begin
               result := false;
               break;
            end;
         end;
      end;
   end;
end;

function TSizeEdit.GetDimensionCount: integer;
begin
   result := TInfra.GetDimensionCount(Text);
end;

function TSizeEdit.GetDimensions: TArray<string>;
begin
   result := TInfra.GetDimensions(Text);
end;

procedure TSizeEdit.OnChangeSize(Sender: TObject);
begin
   Font.Color := IfThen(ParseSize, BLACK_COLOR, NOK_COLOR);
end;

end.
