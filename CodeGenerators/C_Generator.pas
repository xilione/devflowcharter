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


 
{ This unit contains stuff to support C code generation }

unit C_Generator;

interface

const
        C_STRING_DELIM = #34;
        C_CHAR_DELIM   = #39;
var
        // flags to include header files
        io_flag,          // stdio.h
        math_flag,        // math.h
        str_flag: byte;   // string.h
        // datatype indexes used to evaluate expression type
        C_INT_TYPE,
        C_REAL_TYPE,
        C_CHAR_TYPE,
        C_CHAR_PTR_TYPE: integer;

implementation

uses
   System.SysUtils, System.StrUtils, System.Classes, SynHighlighterCpp, Vcl.Graphics,
   Main_Block, ApplicationCommon, LangDefinition, ParserHelper;

var
   cLang: TLangDefinition;

procedure C_ExecuteBeforeGeneration;
begin
   // execute parse to set _flag variables
   io_flag   := 0;
   math_flag := 0;
   str_flag  := 0;
   if GProject <> nil then
      GProject.RefreshStatements;
end;

procedure C_LibSectionGenerator(ALines: TStringList);
var
   libList: TStringList;
   libIncl, lib: string;
begin
   libList := GProject.GetLibraryList;
   try
      if math_flag <> 0 then
         libList.Add('math');
      if str_flag <> 0 then
         libList.Add('string');
      if io_flag <> 0 then
         libList.Add('stdio');
      for lib in libList do
      begin
         libIncl := lib;
         if not lib.Contains('.') then
            libIncl := libIncl + cLang.LibraryExt;
         if not lib.Contains('"') then
            libIncl := '<' + libIncl + '>';
         libIncl := '#include ' + libIncl;
         ALines.AddObject(libIncl, TInfra.GetLibObject);
      end;
   finally
      libList.Free;
   end;
end;

procedure C_MainFunctionSectionGenerator(ALines: TStringList; ADeep: integer);
var
   lBlock: TMainBlock;
begin
   if GProject <> nil then
   begin
      lBlock := GProject.GetMainBlock;
      if lBlock <> nil then
         lBlock.GenerateCode(ALines, cLang.Name, ADeep);
   end;
end;

procedure C_SetHLighterAttrs;
var
   hlighter: TSynCppSyn;
   bkgColor: TColor;
begin
   if (cLang <> nil) and (cLang.HighLighter is TSynCppSyn) then
   begin
      bkgColor := GSettings.EditorBkgColor;
      hlighter := TSynCppSyn(cLang.HighLighter);
      hlighter.StringAttri.Foreground     := GSettings.EditorStringColor;
      hlighter.StringAttri.Background     := bkgColor;
      hlighter.CharAttri.Foreground       := GSettings.EditorStringColor;
      hlighter.CharAttri.Background       := bkgColor;
      hlighter.NumberAttri.Foreground     := GSettings.EditorNumberColor;
      hlighter.NumberAttri.Background     := bkgColor;
      hlighter.FloatAttri.Foreground      := GSettings.EditorNumberColor;
      hlighter.FloatAttri.Background      := bkgColor;
      hlighter.HexAttri.Foreground        := GSettings.EditorNumberColor;
      hlighter.HexAttri.Background        := bkgColor;
      hlighter.OctalAttri.Foreground      := GSettings.EditorNumberColor;
      hlighter.OctalAttri.Background      := bkgColor;
      hlighter.CommentAttri.Foreground    := GSettings.EditorCommentColor;
      hlighter.CommentAttri.Background    := bkgColor;
      hlighter.DirecAttri.Foreground      := GSettings.EditorCommentColor;
      hlighter.DirecAttri.Background      := bkgColor;
      hlighter.KeyAttri.Foreground        := GSettings.EditorKeywordColor;
      hlighter.KeyAttri.Background        := bkgColor;
      hlighter.IdentifierAttri.Foreground := GSettings.EditorIdentColor;
      hlighter.IdentifierAttri.Background := bkgColor;
   end;
end;

function C_GetLiteralType(const AValue: string): integer;
var
   i, len: integer;
   f: double;
begin
   result := UNKNOWN_TYPE;
   len := AValue.Length;
   if len > 0 then
   begin
      if not TryStrToInt(AValue, i) then
      begin
         if not TryStrToFloat(AValue, f) then
         begin
            if (len > 1) and (AValue[1] = C_STRING_DELIM) and (AValue[len] = C_STRING_DELIM) then
               result := C_CHAR_PTR_TYPE
            else if (len = 3) and (AValue[1] = C_CHAR_DELIM) and (AValue[3] = C_CHAR_DELIM) then
               result := C_CHAR_TYPE
            else if AValue = 'NULL' then
               result := GENERIC_PTR_TYPE;
         end
         else
            result := C_REAL_TYPE;
      end
      else
         result := C_INT_TYPE;
   end;
end;

function C_IsPointerType(const AType: string): boolean;
begin
   result := (AType.Length > 1) and AType.EndsWith('*');
end;

function C_GetOriginalType(const AType: string): string;
begin
   result := AType;
   if C_IsPointerType(result) then
      SetLength(result, result.Length - 1);
end;

function C_SkipFuncBodyGen: boolean;
begin
   result := false;
end;

initialization

   C_INT_TYPE      := TParserHelper.GetType('int', C_LANG_ID);
   C_REAL_TYPE     := TParserHelper.GetType('float', C_LANG_ID);
   C_CHAR_TYPE     := TParserHelper.GetType('char', C_LANG_ID);
   C_CHAR_PTR_TYPE := TParserHelper.GetType('char*', C_LANG_ID);

   cLang := GInfra.GetLangDefinition(C_LANG_ID);
   if cLang <> nil then
   begin
      cLang.ExecuteBeforeGeneration :=  C_ExecuteBeforeGeneration;
      cLang.LibSectionGenerator := C_LibSectionGenerator;
      cLang.MainFunctionSectionGenerator := C_MainFunctionSectionGenerator;
      cLang.SetHLighterAttrs := C_SetHLighterAttrs;
      cLang.GetLiteralType := C_GetLiteralType;
      cLang.IsPointerType := C_IsPointerType;
      cLang.GetOriginalType := C_GetOriginalType;
      cLang.SkipFuncBodyGen := C_SkipFuncBodyGen;
   end;
   
end.