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

unit Dummy_Generator;

interface

implementation

uses
   System.SysUtils, System.StrUtils, System.Classes, Vcl.StdCtrls, Base_Block, LangDefinition,
   UserFunction, DeclareList, CommonInterfaces, UserDataType, ApplicationCommon,
   ParserHelper, CommonTypes;

procedure Dummy_UserDataTypesSectionGenerator(ALines: TStringList);
var
   dataType: TUserDataType;
   field: TField;
   name, sizeStr, lRecord, enum, extModifier: string;
   b, lType: integer;
   lang: TLangDefinition;
   typesList, typesTemplate, fieldList, template: TStringList;
   typeStr, fieldStr, valStr, valStr2: string;
   fields: IEnumerable<TField>;
begin
   lang := GInfra.CurrentLang;
   if not lang.DataTypesTemplate.IsEmpty then
   begin
      template := TStringList.Create;
      typesList := TStringList.Create;
      try
         for dataType in GProject.GetUserDataTypes do
         begin
            name := dataType.GetName;
            if (name <> '') and (lang.CodeIncludeExternDataType or not dataType.chkExternal.Checked) then
            begin
               extModifier := dataType.GetExternModifier;
               template.Clear;
               case dataType.Kind of

                  dtInt:
                  if not lang.DataTypeIntMask.IsEmpty then
                  begin
                     typeStr := ReplaceStr(lang.DataTypeIntMask, PRIMARY_PLACEHOLDER, name);
                     template.Text := ReplaceStr(typeStr, '%s9', extModifier);
                  end;

                  dtReal:
                  if not lang.DataTypeRealMask.IsEmpty then
                  begin
                     typeStr := ReplaceStr(lang.DataTypeRealMask, PRIMARY_PLACEHOLDER, name);
                     template.Text := ReplaceStr(typeStr, '%s9', extModifier);
                  end;

                  dtOther:
                  if not lang.DataTypeOtherMask.IsEmpty then
                  begin
                     typeStr := ReplaceStr(lang.DataTypeOtherMask, PRIMARY_PLACEHOLDER, name);
                     typeStr := ReplaceStr(typeStr, '%s9', extModifier);
                     valStr := '';
                     fields := dataType.GetFields;
                     if fields.GetEnumerator.MoveNext then
                        valStr := Trim(fields.GetEnumerator.Current.edtName.Text);
                     template.Text := ReplaceStr(typeStr, '%s2', valStr);
                  end;

                  dtArray:
                  if not lang.DataTypeArrayMask.IsEmpty then
                  begin
                     typeStr := ReplaceStr(lang.DataTypeArrayMask, PRIMARY_PLACEHOLDER, name);
                     typeStr := ReplaceStr(typeStr, '%s9', extModifier);
                     valStr := '';
                     valStr2 := '';
                     fields := dataType.GetFields;
                     if fields.GetEnumerator.MoveNext then
                     begin
                        field := fields.GetEnumerator.Current;
                        valStr := field.cbType.Text;
                        valStr2 := lang.GetArraySizes(field.edtSize);
                     end;
                     typeStr := ReplaceStr(typeStr, '%s2', valStr);
                     template.Text := ReplaceStr(typeStr, '%s3', valStr2);
                  end;

                  dtRecord:
                  if not lang.DataTypeRecordTemplate.IsEmpty then
                  begin
                     typeStr := ReplaceStr(lang.DataTypeRecordTemplate, PRIMARY_PLACEHOLDER, name);
                     template.Text := ReplaceStr(typeStr, '%s9', extModifier);
                     fieldList := TStringList.Create;
                     try
                        for field in dataType.GetFields do
                        begin
                           sizeStr := lang.GetArraySizes(field.edtSize);
                           if sizeStr.IsEmpty then
                              fieldStr := lang.DataTypeRecordFieldMask
                           else
                              fieldStr := lang.DataTypeRecordFieldArrayMask;
                           fieldStr := ReplaceStr(fieldStr, PRIMARY_PLACEHOLDER, Trim(field.edtName.Text));
                           fieldStr := ReplaceStr(fieldStr, '%s2', field.cbType.Text);
                           fieldStr := ReplaceStr(fieldStr, '%s3', sizeStr);
                           lRecord := '';
                           enum := '';
                           lType := TParserHelper.GetType(field.cbType.Text);
                           if TParserHelper.IsRecordType(lType) then
                              lRecord := lang.FunctionHeaderArgsEntryRecord
                           else if TParserHelper.IsEnumType(lType) then
                              enum := lang.FunctionHeaderArgsEntryEnum;
                           fieldStr := ReplaceStr(fieldStr, '%s4', lRecord);
                           fieldStr := ReplaceStr(fieldStr, '%s5', enum);
                           fieldList.Add(fieldStr);
                        end;
                        TInfra.InsertTemplateLines(template, '%s2', fieldList);
                     finally
                        fieldList.Free;
                     end;
                  end;

                  dtEnum:
                  if not lang.DataTypeEnumTemplate.IsEmpty then
                  begin
                     typeStr := ReplaceStr(lang.DataTypeEnumTemplate, PRIMARY_PLACEHOLDER, name);
                     template.Text := ReplaceStr(typeStr, '%s9', extModifier);
                     valStr := '';
                     for field in dataType.GetFields do
                        valStr := valStr + Format(lang.DataTypeEnumEntryList, [Trim(field.edtName.Text)]);
                     if lang.DataTypeEnumEntryListStripCount > 0 then
                        SetLength(valStr, valStr.Length - lang.DataTypeEnumEntryListStripCount);
                     TInfra.InsertTemplateLines(template, '%s2', valStr);
                  end;

               end;
               for b := 0 to template.Count-1 do
                  typesList.AddObject(template[b], dataType)
            end;
         end;
         if typesList.Count > 0 then
         begin
            typesTemplate := TStringList.Create;
            try
               typesTemplate.Text := lang.DataTypesTemplate;
               TInfra.InsertTemplateLines(typesTemplate, PRIMARY_PLACEHOLDER, typesList);
               ALines.AddStrings(typesTemplate);
            finally
               typesTemplate.Free;
            end;
         end;
      finally
         template.Free;
         typesList.Free;
      end;
   end;
end;

function Dummy_GetLiteralType(const AValue: string): integer;
var
   i: integer;
begin
   result := UNKNOWN_TYPE;
   if TryStrToInt(AValue, i) then
      result := GENERIC_INT_TYPE;
end;

procedure Dummy_ProgramHeaderSectionGenerator(ALines: TStringList);
var
   hdrTemplate: TStringList;
   lang: TLangDefinition;
begin
    lang := GInfra.CurrentLang;
    if not lang.ProgramHeaderTemplate.IsEmpty then
    begin
       hdrTemplate := TStringList.Create;
       try
          hdrTemplate.Text := lang.ProgramHeaderTemplate;
          TInfra.InsertTemplateLines(hdrTemplate, PRIMARY_PLACEHOLDER, GProject.Name);
          TInfra.InsertTemplateLines(hdrTemplate, '%s2', lang.Name);
          TInfra.InsertTemplateLines(hdrTemplate, '%s3', GProject.GetProgramHeader);
          TInfra.InsertTemplateLines(hdrTemplate, '%s4', DateTimeToStr(Now));
          TInfra.InsertTemplateLines(hdrTemplate, '%s5', ExtractFileName(lang.DefFile));
          TInfra.InsertTemplateLines(hdrTemplate, '%s6', lang.DefFile);
          ALines.AddStrings(hdrTemplate);
       finally
          hdrTemplate.Free;
       end;
    end;
end;

procedure Dummy_LibSectionGenerator(ALines: TStringList);
var
   i: integer;
   libList, libTemplate: TStringList;
   lang: TLangDefinition;
   libStr: string;
   isS1: boolean;
begin
   lang := GInfra.CurrentLang;
   libList := GProject.GetLibraryList;
   try
      if (libList.Count > 0) and (not lang.LibTemplate.IsEmpty) and ((not lang.LibEntry.IsEmpty) or (not lang.LibEntryList.IsEmpty)) then
      begin
         libStr := '';
         libTemplate := TStringList.Create;
         try
            isS1 := lang.LibTemplate.Contains(PRIMARY_PLACEHOLDER);
            libTemplate.Text := lang.LibTemplate;
            for i := 0 to libList.Count-1 do
               libStr := libStr + Format(IfThen(isS1, lang.LibEntry + sLineBreak, lang.LibEntryList), [libList[i]]);
            if (lang.LibEntryListStripCount > 0) and not isS1 then
               SetLength(libStr, libStr.Length - lang.LibEntryListStripCount);
            TInfra.InsertTemplateLines(libTemplate, IfThen(isS1, PRIMARY_PLACEHOLDER, '%s2'), libStr, TInfra.GetLibObject);
            TInfra.InsertTemplateLines(libTemplate, IfThen(isS1, '%s2', PRIMARY_PLACEHOLDER), '');
            ALines.AddStrings(libTemplate);
         finally
            libTemplate.Free;
         end;
      end;
   finally
      libList.Free;
   end;
end;

procedure Dummy_ConstSectionGenerator(ALines: TStringList; AConstList: TConstDeclareList);
var
   i, t: integer;
   constStr, constType, constValue: string;
   lang: TLangDefinition;
   constList, constTemplate: TStringList;
   isExtern: boolean;
begin
   lang := GInfra.CurrentLang;
   if (AConstList <> nil) and (AConstList.sgList.RowCount > 2) and not lang.ConstTemplate.IsEmpty then
   begin
      constList := TStringList.Create;
      try
         for i := 1 to AConstList.sgList.RowCount-2 do
         begin
            isExtern := AConstList.GetExternalState(i) = cbChecked;
            if (isExtern and lang.CodeIncludeExternVarConst) or not isExtern then
            begin
               constValue := AConstList.sgList.Cells[CONST_VALUE_COL, i];
               constType := '';
               if Assigned(GInfra.CurrentLang.GetLiteralType) then
                  t := GInfra.CurrentLang.GetLiteralType(constValue)
               else
                  t := Dummy_GetLiteralType(constValue);
               if t <> UNKNOWN_TYPE then
                  constType := TParserHelper.GetTypeAsString(t);
               constStr := ReplaceStr(lang.ConstEntry, PRIMARY_PLACEHOLDER, AConstList.sgList.Cells[CONST_NAME_COL, i]);
               constStr := ReplaceStr(constStr, '%s2', constValue);
               constStr := ReplaceStr(constStr, '%s3', AConstList.GetExternModifier(i));
               constStr := ReplaceStr(constStr, '%s4', constType);
               constList.AddObject(constStr, AConstList);
            end;
         end;
         if constList.Count > 0 then
         begin
            constTemplate := TStringList.Create;
            try
               constTemplate.Text := lang.ConstTemplate;
               TInfra.InsertTemplateLines(constTemplate, PRIMARY_PLACEHOLDER, constList);
               ALines.AddStrings(constTemplate);
            finally
               constTemplate.Free;
            end;
         end;
      finally
         constList.Free;
      end;
   end;
end;

procedure Dummy_VarSectionGenerator(ALines: TStringList; AVarList: TVarDeclareList);
var
   lang: TLangDefinition;
   i, b, lType, dcount: integer;
   varStr, varSize, varInit, initEntry, lRecord, enum, name, typeStr: string;
   varTemplate, varList: TStringList;
   isExtern: boolean;
   dims: TArray<string>;
begin
   lang := GInfra.CurrentLang;
   if (AVarList <> nil) and (AVarList.sgList.RowCount > 2) and not lang.VarTemplate.IsEmpty then
   begin
      varList := TStringList.Create;
      try
         for i := 1 to AVarList.sgList.RowCount-2 do
         begin
            varSize := '';
            name := AVarList.sgList.Cells[VAR_NAME_COL, i];
            typeStr := AVarList.sgList.Cells[VAR_TYPE_COL, i];
            isExtern := AVarList.GetExternalState(i) = cbChecked;
            if (isExtern and lang.CodeIncludeExternVarConst) or not isExtern then
            begin
               dcount := AVarList.GetDimensionCount(name);
               if dcount > 0 then
               begin
                  dims := AVarList.GetDimensions(name);
                  for b := 0 to High(dims) do
                     varSize := varSize + Format(lang.VarEntryArraySize, [dims[b]]);
                  if lang.VarEntryArraySizeStripCount > 0 then
                     SetLength(varSize, varSize.Length - lang.VarEntryArraySizeStripCount);
                  varStr := ReplaceStr(lang.VarEntryArray, PRIMARY_PLACEHOLDER, name);
                  varStr := ReplaceStr(varStr, '%s3', varSize);
               end
               else
                  varStr := ReplaceStr(lang.VarEntry, PRIMARY_PLACEHOLDER, name);
               varStr := ReplaceStr(varStr, '%s2', typeStr);
               varInit := AVarList.sgList.Cells[VAR_INIT_COL, i];
               if not varInit.IsEmpty then
               begin
                  initEntry := IfThen(isExtern, lang.VarEntryInitExtern, lang.VarEntryInit);
                  if not initEntry.IsEmpty then
                     varInit := ReplaceStr(initEntry, PRIMARY_PLACEHOLDER, varInit);
               end;
               varStr := ReplaceStr(varStr, '%s4', varInit);
               lType := TParserHelper.GetType(typeStr);
               lRecord := '';
               enum := '';
               if TParserHelper.IsRecordType(lType) then
                  lRecord := lang.FunctionHeaderArgsEntryRecord
               else if TParserHelper.IsEnumType(lType) then
                  enum := lang.FunctionHeaderArgsEntryEnum;
               varStr := ReplaceStr(varStr, '%s5', lRecord);
               varStr := ReplaceStr(varStr, '%s6', enum);
               varStr := ReplaceStr(varStr, '%s7', AVarList.GetExternModifier(i));
               varList.AddObject(varStr, AVarList);
            end;
         end;
         if varList.Count > 0 then
         begin
            varTemplate := TStringList.Create;
            try
               varTemplate.Text := lang.VarTemplate;
               TInfra.InsertTemplateLines(varTemplate, PRIMARY_PLACEHOLDER, varList);
               ALines.AddStrings(varTemplate);
            finally
               varTemplate.Free;
            end;
         end;
      finally
         varList.Free;
      end;
   end;
end;

procedure Dummy_MainFunctionSectionGenerator(ALines: TStringList; ADeep: integer);
var
   block: TBlock;
begin
   block := GProject.GetMainBlock;
   if block <> nil then
      block.GenerateCode(ALines, GInfra.CurrentLang.Name, ADeep);
end;

procedure Dummy_UserFunctionsSectionGenerator(ALines: TStringList; ASkipBodyGen: boolean);
var
   func: TUserFunction;
   param: TParameter;
   name, argList, paramStr, ref, lArray, lRecord, enum, defValue, hText, typeArray, isStatic, memDesc: string;
   lang: TLangDefinition;
   headerTemplate, varList, funcTemplate, bodyTemplate, funcList, funcsTemplate: TStringList;
   intType: integer;
   isTypeNotNone: boolean;
begin
   lang := GInfra.CurrentLang;
   if not lang.FunctionsTemplate.IsEmpty then
   begin
      funcList := TStringList.Create;
      try
         for func in GProject.GetUserFunctions do
         begin
            name := func.GetName;
            if (name <> '') and (lang.CodeIncludeExternFunction or not func.Header.chkExternal.Checked) and not lang.FunctionTemplate.IsEmpty then
            begin
               // assemble list of function parameters
               argList := '';
               for param in func.Header.GetParameters do
               begin
                  paramStr := ReplaceStr(lang.FunctionHeaderArgsEntryMask, PRIMARY_PLACEHOLDER, Trim(param.edtName.Text));
                  paramStr := ReplaceStr(paramStr, '%s2', param.cbType.Text);
                  ref := '';
                  lArray := '';
                  lRecord := '';
                  enum := '';
                  if param.chkReference.Checked then
                     ref := lang.FunctionHeaderArgsEntryRef;
                  if param.chkTable.Checked then
                     lArray := lang.FunctionHeaderArgsEntryArray;
                  intType := TParserHelper.GetType(param.cbType.Text);
                  if TParserHelper.IsRecordType(intType) then
                     lRecord := lang.FunctionHeaderArgsEntryRecord
                  else if TParserHelper.IsEnumType(intType) then
                     enum := lang.FunctionHeaderArgsEntryEnum;
                  defValue := Trim(param.edtDefault.Text);
                  if not defValue.IsEmpty then
                     defValue := ReplaceStr(lang.FunctionHeaderArgsEntryDefault, '%s', defValue);
                  paramStr := ReplaceStr(paramStr, '%s3', ref);
                  paramStr := ReplaceStr(paramStr, '%s4', lArray);
                  paramStr := ReplaceStr(paramStr, '%s5', lRecord);
                  paramStr := ReplaceStr(paramStr, '%s6', enum);
                  paramStr := ReplaceStr(paramStr, '%s7', defValue);
                  argList := argList + paramStr;
               end;

               if lang.FunctionHeaderArgsStripCount > 0 then
                  SetLength(argList, argList.Length - lang.FunctionHeaderArgsStripCount);

               // assemble function header line
               isTypeNotNone := func.Header.cbType.ItemIndex > 0;
               if isTypeNotNone then
                  typeArray := IfThen(func.Header.chkArrayType.Checked, lang.FunctionHeaderTypeArray, lang.FunctionHeaderTypeNotArray)
               else
                  typeArray := '';

               if func.Header.chkStatic.Visible then
                  isStatic := IfThen(func.Header.chkStatic.Checked, lang.FunctionHeaderStatic, lang.FunctionHeaderNotStatic)
               else
                  isStatic := '';

               hText := IfThen(func.Header.chkConstructor.Checked, lang.ConstructorHeaderTemplate, lang.FunctionHeaderTemplate);
               hText := ReplaceStr(hText, PRIMARY_PLACEHOLDER, name);
               hText := ReplaceStr(hText, '%s3', argList);
               hText := ReplaceStr(hText, '%s4', IfThen(isTypeNotNone, func.Header.cbType.Text));
               hText := ReplaceStr(hText, '%s5', IfThen(isTypeNotNone, lang.FunctionHeaderTypeNotNone1, lang.FunctionHeaderTypeNone1));
               hText := ReplaceStr(hText, '%s6', IfThen(isTypeNotNone, lang.FunctionHeaderTypeNotNone2, lang.FunctionHeaderTypeNone2));
               hText := ReplaceStr(hText, '%s7', func.Header.GetExternModifier);
               hText := ReplaceStr(hText, '%s8', typeArray);
               hText := ReplaceStr(hText, '%s9', isStatic);

               headerTemplate := TStringList.Create;
               try
                  headerTemplate.Text := hText;
                  if ASkipBodyGen then
                  begin
                     TInfra.InsertTemplateLines(headerTemplate, '%s2', nil);
                     funcList.AddStrings(headerTemplate);
                  end
                  else
                  begin
                     memDesc := '';
                     if func.Header.chkInclDescCode.Checked then
                        memDesc := TrimRight(func.Header.memDesc.Text);
                     if memDesc.IsEmpty then
                        TInfra.InsertTemplateLines(headerTemplate, '%s2', nil)
                     else
                        headerTemplate.Text := ReplaceStr(headerTemplate.Text, '%s2', memDesc);

                     funcTemplate := TStringList.Create;
                     try
                        funcTemplate.Text := lang.FunctionTemplate;
                        TInfra.InsertTemplateLines(funcTemplate, PRIMARY_PLACEHOLDER, headerTemplate, func.Header);
                        varList := TStringList.Create;
                        try
                           if Assigned(lang.VarSectionGenerator) then
                              lang.VarSectionGenerator(varList, func.Header.LocalVars)
                           else
                              Dummy_VarSectionGenerator(varList, func.Header.LocalVars);
                           TInfra.InsertTemplateLines(funcTemplate, '%s2', varList);
                        finally
                           varList.Free;
                        end;
                        if func.Body <> nil then
                        begin
                           bodyTemplate := TStringList.Create;
                           try
                              func.Body.GenerateCode(bodyTemplate, lang.Name, 0);
                              TInfra.InsertTemplateLines(funcTemplate, '%s3', bodyTemplate);
                           finally
                              bodyTemplate.Free;
                           end;
                           func.Body.GenerateTemplateSection(funcList, funcTemplate, lang.Name, 0);
                        end;
                     finally
                        funcTemplate.Free;
                     end;
                  end;
               finally
                  headerTemplate.Free;
               end;
            end;
         end;
         if funcList.Count > 0 then
         begin
            funcsTemplate := TStringList.Create;
            try
               funcsTemplate.Text := lang.FunctionsTemplate;
               TInfra.InsertTemplateLines(funcsTemplate, PRIMARY_PLACEHOLDER, funcList);
               ALines.AddStrings(funcsTemplate);
            finally
               funcsTemplate.Free;
            end;
         end;
      finally
         funcList.Free;
      end;
   end;
end;

function Dummy_FileContentsGenerator(ALines: TStringList; ASkipBodyGenerate: boolean): boolean;
var
   fileTemplate, headerTemplate, mainFuncTemplate, libTemplate, constTemplate,
   varTemplate, funcTemplate, dataTypeTemplate: TStringList;
   currLang: TLangDefinition;
   i: integer;
begin

   currLang := GInfra.CurrentLang;

   if currLang.FileContentsTemplate.IsEmpty then
      Exit(false);

   try
      // generate program header section
      headerTemplate := TStringList.Create;
      if Assigned(currLang.ProgramHeaderSectionGenerator) then
         currLang.ProgramHeaderSectionGenerator(headerTemplate)
      else
         Dummy_ProgramHeaderSectionGenerator(headerTemplate);

      // generate libraries section
      libTemplate := TStringList.Create;
      if Assigned(currLang.LibSectionGenerator) then
         currLang.LibSectionGenerator(libTemplate)
      else
         Dummy_LibSectionGenerator(libTemplate);

     // generate global constants section
     constTemplate := TStringList.Create;
     if currLang.EnabledConsts then
     begin
        if Assigned(currLang.ConstSectionGenerator) then
           currLang.ConstSectionGenerator(constTemplate, GProject.GlobalConsts)
        else
           Dummy_ConstSectionGenerator(constTemplate, GProject.GlobalConsts);
     end;

     // generate global variables section
     varTemplate := TStringList.Create;
     if currLang.EnabledVars then
     begin
        if Assigned(currLang.VarSectionGenerator) then
           currLang.VarSectionGenerator(varTemplate, GProject.GlobalVars)
        else
           Dummy_VarSectionGenerator(varTemplate, GProject.GlobalVars);
      end;

     // generate user data types section
     dataTypeTemplate := TStringList.Create;
     if currLang.EnabledUserDataTypes then
     begin
        if Assigned(currLang.UserDataTypesSectionGenerator) then
           currLang.UserDataTypesSectionGenerator(dataTypeTemplate)
        else
           Dummy_UserDataTypesSectionGenerator(dataTypeTemplate);
     end;

     // generate user functions section
     funcTemplate := TStringList.Create;
     if currLang.EnabledUserFunctionHeader then
     begin
        if Assigned(currLang.UserFunctionsSectionGenerator) then
           currLang.UserFunctionsSectionGenerator(funcTemplate, ASkipBodyGenerate)
        else
           Dummy_UserFunctionsSectionGenerator(funcTemplate, ASkipBodyGenerate);
     end;

      // generate main function section
      mainFuncTemplate := TStringList.Create;
      if Assigned(currLang.MainFunctionSectionGenerator) then
         currLang.MainFunctionSectionGenerator(mainFuncTemplate, 0)
      else
         Dummy_MainFunctionSectionGenerator(mainFuncTemplate, 0);

      fileTemplate := TStringList.Create;
      fileTemplate.Text := currLang.FileContentsTemplate;
      TInfra.InsertTemplateLines(fileTemplate, PRIMARY_PLACEHOLDER, GProject.Name);
      TInfra.InsertTemplateLines(fileTemplate, '%s2', headerTemplate);
      i := TInfra.InsertTemplateLines(fileTemplate, '%s3', libTemplate);
      GProject.SetLibSectionOffset(i);
      TInfra.InsertTemplateLines(fileTemplate, '%s4', constTemplate);
      TInfra.InsertTemplateLines(fileTemplate, '%s5', varTemplate);
      TInfra.InsertTemplateLines(fileTemplate, '%s6', dataTypeTemplate);
      TInfra.InsertTemplateLines(fileTemplate, '%s7', funcTemplate);
      TInfra.InsertTemplateLines(fileTemplate, '%s8', mainFuncTemplate);
      ALines.AddStrings(fileTemplate);
   finally
      fileTemplate.Free;
      headerTemplate.Free;
      mainFuncTemplate.Free;
      libTemplate.Free;
      constTemplate.Free;
      varTemplate.Free;
      funcTemplate.Free;
      dataTypeTemplate.Free;
   end;

   result := true;
end;

function Dummy_GetPointerTypeName(const AValue: string): string;
begin
   result := Format(GInfra.CurrentLang.PointerTypeMask, [AValue]);
end;

function Dummy_SkipFuncBodyGen: boolean;
begin
   result := false;
end;

function Dummy_GetUserTypeDesc(ADataType: TUserDataType): string;
var
   kind: string;
begin
   result := GInfra.CurrentLang.UserTypeDesc;
   if not result.IsEmpty then
   begin
      result := ReplaceStr(result, PRIMARY_PLACEHOLDER, ADataType.edtName.Text);
      kind := '';
      if ADataType.rgTypeBox.ItemIndex <> -1 then
         kind := ADataType.rgTypeBox.Items[ADataType.rgTypeBox.ItemIndex];
      result := ReplaceStr(result, '%s2', kind);
   end;
end;

function Dummy_GetMainProgramDesc: string;
begin
   result := i18Manager.GetString(GInfra.CurrentLang.ProgramLabelKey);
   result := ReplaceStr(result, PRIMARY_PLACEHOLDER, GProject.Name);
end;

function Dummy_GetUserFuncDesc(AHeader: TUserFunctionHeader; AFullParams: boolean = true; AIncludeDesc: boolean = true): string;
var
   params, desc, lType, key, lb, arrayType: string;
   lang: TLangDefinition;
   param: TParameter;
begin
   result := '';
   if AHeader <> nil then
   begin
      lang := GInfra.CurrentLang;
      desc := '';
      lType := AHeader.cbType.Text;
      key := '';
      lb := '';
      arrayType := IfThen(AHeader.chkArrayType.Checked, lang.FunctionHeaderTypeArray, lang.FunctionHeaderTypeNotArray);
      if AHeader.chkConstructor.Checked then
         key := lang.ConstructorLabelKey
      else if AHeader.cbType.ItemIndex > 0 then
         key := lang.FunctionLabelKey
      else
         key := lang.ProcedureLabelKey;
      if (AHeader.ParameterCount > 1) and not AFullParams then
         params := '...'
      else
      begin
         params := '';
         for param in AHeader.GetParameters do
         begin
            if not params.IsEmpty then
               params := params + ', ';
            params := params + param.cbType.Text + IfThen(param.chkTable.Checked, '[] ', ' ') + Trim(param.edtName.Text);
         end;
      end;
      if AIncludeDesc then
      begin
         desc := AHeader.memDesc.Text;
         lb := sLineBreak;
      end;
      if not key.IsEmpty then
      begin
         result := i18Manager.GetString(key);
         result := ReplaceStr(result, LB_PHOLDER2, lb);
         result := ReplaceStr(result, PRIMARY_PLACEHOLDER, Trim(AHeader.edtName.Text));
         result := ReplaceStr(result, '%s2', params);
         result := ReplaceStr(result, '%s3', lType);
         result := ReplaceStr(result, '%s4', desc);
         result := ReplaceStr(result, '%s5', arrayType);
         result := ReplaceStr(result, '%s6', AHeader.GetExternModifier);
      end;
   end;
end;

function Dummy_GetUserFuncHeaderDesc(AHeader: TUserFunctionHeader): string;
var
   lang: TLangDefinition;
   template, parms: TStringList;
   parmString, returnString: string;
   parm: TParameter;
   i: integer;
begin
   result := '';
   lang := GInfra.CurrentLang;
   if (AHeader <> nil) and not lang.FunctionHeaderDescTemplate.IsEmpty then
   begin
       template := TStringList.Create;
       parms := TStringList.Create;
       try
          template.Text := ReplaceStr(lang.FunctionHeaderDescTemplate, PRIMARY_PLACEHOLDER, Trim(AHeader.edtName.Text));
          template.Text := ReplaceStr(template.Text, '%s2', AHeader.cbType.Text);

          if not lang.FunctionHeaderDescParmMask.IsEmpty then
          begin
             i := 1;
             for parm in AHeader.GetParameters do
             begin
                parmString := ReplaceStr(lang.FunctionHeaderDescParmMask, PRIMARY_PLACEHOLDER, Trim(parm.edtName.Text));
                parmString := ReplaceStr(parmString, '%s2', parm.cbType.Text);
                parmString := ReplaceStr(parmString, '%s3', Trim(parm.edtDefault.Text));
                parmString := ReplaceStr(parmString, '%s4', i.ToString);
                parms.Add(parmString);
                Inc(i);
             end;
          end;
          if parms.Count > 0 then
             TInfra.InsertTemplateLines(template, '%s3', parms)
          else
             TInfra.DeleteLinesContaining(template, '%s3');

          if AHeader.chkConstructor.Checked or (AHeader.cbType.ItemIndex = 0) then
             TInfra.DeleteLinesContaining(template, '%s4')
          else
          begin
             returnString := ReplaceStr(lang.FunctionHeaderDescReturnMask, PRIMARY_PLACEHOLDER, AHeader.cbType.Text);
             template.Text := ReplaceStr(template.Text, '%s4', returnString);
          end;

          result := template.Text;
       finally
          parms.Free;
          template.Free;
       end;
   end;
end;

initialization

   with GInfra.DummyLang do
   begin
      EnabledUserFunctionBody := true;
      EnabledExplorer := true;
      MainFunctionSectionGenerator := Dummy_MainFunctionSectionGenerator;
      UserFunctionsSectionGenerator := Dummy_UserFunctionsSectionGenerator;
      VarSectionGenerator := Dummy_VarSectionGenerator;
      ProgramHeaderSectionGenerator := Dummy_ProgramHeaderSectionGenerator;
      LibSectionGenerator := Dummy_LibSectionGenerator;
      ConstSectionGenerator := Dummy_ConstSectionGenerator;
      UserDataTypesSectionGenerator := Dummy_UserDataTypesSectionGenerator;
      FileContentsGenerator := Dummy_FileContentsGenerator;
      GetLiteralType := Dummy_GetLiteralType;
      GetPointerTypeName := Dummy_GetPointerTypeName;
      GetUserFuncDesc := Dummy_GetUserFuncDesc;
      GetUserFuncHeaderDesc := Dummy_GetUserFuncHeaderDesc;
      GetUserTypeDesc := Dummy_GetUserTypeDesc;
      GetMainProgramDesc := Dummy_GetMainProgramDesc;
      SkipFuncBodyGen := Dummy_SkipFuncBodyGen;
   end;

   // it really sucks but this must be executed here due to initialization order
   GSettings.ResetCurrentLangName;

end.
