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


{ This unit contains definition of two base classes: TBlock and TGroupBlock }

unit Base_Block;

interface

uses
   WinApi.Windows, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Controls, Vcl.Graphics,
   WinApi.Messages, System.SysUtils, System.Classes, Vcl.ComCtrls, System.UITypes,
   Generics.Collections, Statement, OmniXML, BaseEnumerator, CommonInterfaces, CommonTypes,
   BlockTabSheet, Comment, MemoEx;

const
   PRIMARY_BRANCH_IDX = 1;
   LAST_LINE = -1;
   D_LEFT = 0;
   D_BOTTOM = 1;
   D_RIGHT = 2;
   D_TOP = 3;
   D_LEFT_CLOSE = 4;
   
type

   TInitParms = record
      Width: integer;
      Height: integer;
      BottomHook: integer;
      TopHook: integer;
      BottomPoint: TPoint;
      P2X: integer;
      BranchPoint: TPoint;
      IPoint: TPoint;
      HeightAffix: integer;
   end;

   TGroupBlock = class;
   TBranch = class;

   TBlock = class(TCustomControl, IIdentifiable, IFocusable, IExportable, IMemoEx)
      private
         FParentBlock: TGroupBlock;
         FParentBranch: TBranch;
         FId: integer;
         function IsInSelect(const APoint: TPoint): boolean;
      protected
         FType: TBlockType;
         FStatement: TStatement;
         FTopParentBlock: TGroupBlock;
         FHResize,
         FVResize,
         FRefreshMode,
         FFrame,
         FMouseLeave: boolean;
         FShape: TColorShape;
         procedure MyOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
         procedure MyOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
         procedure MyOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); virtual;
         procedure MyOnCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean); virtual;
         procedure MyOnDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
         procedure MyOnDragDrop(Sender, Source: TObject; X, Y: Integer);
         procedure MyOnChange(Sender: TObject);
         procedure MyOnDblClick(Sender: TObject);
         procedure OnChangeMemo(Sender: TObject); virtual;
         procedure WMMouseLeave(var Msg: TMessage); message WM_MOUSELEAVE;
         procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
         procedure NCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
         procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
         procedure WMExitSizeMove(var Msg: TWMMove); message WM_EXITSIZEMOVE;
         procedure WMWindowPosChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
         procedure Paint; override;
         procedure DrawI;
         function DrawTextLabel(x, y: integer; const AText: string; rightJust: boolean = false; downJust: boolean = false): TRect;
         procedure DrawBlockLabel(x, y: integer; const AText: string; rightJust: boolean = false; downJust: boolean = false);
         function GetId: integer;
         function PerformEditorUpdate: boolean;
         procedure SelectBlock(const APoint: TPoint);
         procedure SetCursor(const APoint: TPoint);
         procedure SetFrame(AValue: boolean);
         procedure PutTextControls; virtual;
         procedure DrawArrowTo(const aTo: TPoint; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone); overload;
         procedure DrawArrowTo(toX, toY: integer; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone); overload;
         procedure DrawArrow(const aFrom, aTo: TPoint; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone); overload;
         procedure DrawArrow(fromX, fromY, toX, toY: integer; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone); overload;
         procedure DrawArrow(fromX, fromY: integer; const aTo: TPoint; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone); overload;
         procedure DrawArrow(const aFrom: TPoint; toX, toY: integer; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone); overload;
         function GetEllipseTextRect(ax, ay: integer; const AText: string): TRect;
         function DrawEllipsedText(ax, ay: integer; const AText: string): TRect;
         procedure MoveComments(x, y: integer);
         function GetUndoObject: TObject; virtual;
         function IsInFront(AControl: TWinControl): boolean;
         procedure SetPage(APage: TBlockTabSheet); virtual;
         function GetPage: TBlockTabSheet; virtual;
         procedure CreateParams(var Params: TCreateParams); override;
         procedure OnWindowPosChanged(x, y: integer); virtual;
         function ProcessComments: boolean;
         function IsForeParent(AParent: TObject): boolean;
         function GetErrorMsg(AEdit: TCustomEdit): string;
         procedure SaveInXML2(ATag: IXMLElement);
         procedure ExitSizeMove;
      public
         BottomPoint: TPoint;    // points to arrow at the bottom of the block
         IPoint: TPoint;          // points to I mark
         BottomHook: integer;
         TopHook: TPoint;
         Ired: Integer;           // indicates active arrow; -1: none, 0: bottom, 1: branch1, 2: branch2 and so on...
         property Frame: boolean read FFrame write SetFrame;
         property TopParentBlock: TGroupBlock read FTopParentBlock;
         property Page: TBlockTabSheet read GetPage write SetPage;
         property ParentBlock: TGroupBlock read FParentBlock;
         property BType: TBlockType read FType default blUnknown;
         property ParentBranch: TBranch read FParentBranch;
         property Id: integer read GetId;
         constructor Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; AId: integer = ID_INVALID);
         destructor Destroy; override;
         function Clone(ABranch: TBranch): TBlock; virtual;
         procedure ChangeColor(AColor: TColor); virtual;
         procedure SetFontStyle(const AStyle: TFontStyles);
         procedure SetFontSize(ASize: integer);
         function GetFont: TFont;
         procedure SetFont(AFont: TFont);
         procedure RefreshStatements;
         procedure PopulateComboBoxes; virtual;
         function GenerateCode(ALines: TStringList; const ALangId: string; ADeep: integer; AFromLine: integer = LAST_LINE): integer; virtual;
         function GetFromXML(ATag: IXMLElement): TErrorType; virtual;
         procedure SaveInXML(ATag: IXMLElement); virtual;
         function FillTemplate(const ALangId: string; const ATemplate: string = ''): string; virtual;
         function FillCodedTemplate(const ALangId: string): string; virtual;
         function GetDescTemplate(const ALangId: string): string; virtual;
         function GetTextControl: TCustomEdit; virtual;
         function GenerateTree(AParentNode: TTreeNode): TTreeNode; virtual;
         function IsCursorSelect: boolean;
         function IsCursorResize: boolean;
         function CanInsertReturnBlock: boolean; virtual;
         procedure ExportToXMLTag(ATag: IXMLElement);
         function ImportFromXMLTag(ATag: IXMLElement; ASelect: boolean = false): TErrorType;
         procedure ExportToGraphic(AGraphic: TGraphic); virtual;
         procedure UpdateEditor(AEdit: TCustomEdit); virtual;
         function SkipUpdateEditor: boolean;
         function RetrieveFocus(AInfo: TFocusInfo): boolean; virtual;
         function CanBeFocused: boolean; virtual;
         function FindLastRow(AStart: integer; ALines: TStrings): integer; virtual;
         procedure GenerateDefaultTemplate(ALines: TStringList; const ALangId: string; ADeep: integer);
         procedure GenerateTemplateSection(ALines: TStringList; ATemplate: TStringList; const ALangId: string; ADeep: integer); overload; virtual;
         procedure GenerateTemplateSection(ALines: TStringList; const ATemplate: string; const ALangId: string; ADeep: integer); overload;
         function GetMemoEx: TMemoEx; virtual;
         function FocusOnTextControl(AInfo: TFocusInfo): boolean;
         procedure ClearSelection;
         procedure ChangeFrame;
         procedure RepaintAll;
         function Next: TBlock;
         function Prev: TBlock;
         function CountErrWarn: TErrWarnCount; virtual;
         function LockDrawing: boolean;
         procedure UnLockDrawing;
         function GetFocusColor: TColor;
         function Remove(ANode: TTreeNodeWithFriend = nil): boolean; virtual;
         function CanRemove: boolean;
         function IsBoldDesc: boolean; virtual;
         function GetComments(AInFront: boolean = false): IEnumerable<TComment>;
         function GetPinComments: IEnumerable<TComment>;
         procedure SetVisible(AVisible: boolean; ASetComments: boolean = true); virtual;
         procedure BringAllToFront;
         function PinComments: integer;
         function UnPinComments: integer; virtual;
         procedure CloneComments(ASource: TBlock);
         procedure ImportCommentsFromXML(ATag: IXMLElement);
         procedure CloneFrom(ABlock: TBlock); virtual;
         function GetExportFileName: string; virtual;
         function ExportToXMLFile(const AFile: string): TErrorType; virtual;
         procedure OnMouseLeave(AClearRed: boolean = true); virtual;
      published
         property Color;
         property OnMouseDown;
         property OnResize;
   end;

   TGroupBlock = class(TBlock)    // block which can aggregate child blocks
      protected
         FBlockImportMode,
         FDrawingFlag: boolean;
         FMemoFolder: TMemoEx;
         FInitParms: TInitParms;
         FBranchList: TObjectList<TBranch>;
         FTrueLabel,
         FFalseLabel: string;
         FFixedBranches: integer;
         FDiamond: array[D_LEFT..D_LEFT_CLOSE] of TPoint;
         procedure MyOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); override;
         procedure MyOnCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean); override;
         procedure SetWidth(AMinX: integer); virtual;
         procedure LinkBlocks(const idx: integer = PRIMARY_BRANCH_IDX-1);
         procedure Paint; override;
         function ExtractBranchIndex(const AStr: string): integer;
         function GetDiamondTop: TPoint; virtual;
         procedure AfterRemovingBranch; virtual;
      public
         Branch: TBranch;     // primary branch to order child blocks
         Expanded: boolean;
         FFoldParms: TInitParms;
         property BlockImportMode: boolean read FBlockImportMode write FBlockImportMode;
         constructor Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; const AHook: TPoint; AId: integer = ID_INVALID);
         destructor Destroy; override;
         procedure ResizeHorz(AContinue: boolean); virtual;
         procedure ResizeVert(AContinue: boolean); virtual;
         function GenerateNestedCode(ALines: TStringList; ABranchInd, ADeep: integer; const ALangId: string): integer;
         procedure ExpandFold(AResize: boolean); virtual;
         function GetBranch(idx: integer): TBranch;
         function FindLastRow(AStart: integer; ALines: TStrings): integer; override;
         procedure ChangeColor(AColor: TColor); override;
         function GenerateTree(AParentNode: TTreeNode): TTreeNode; override;
         function AddBranch(const AHook: TPoint; ABranchId: integer = ID_INVALID; ABranchStmntId: integer = ID_INVALID): TBranch; virtual;
         procedure ExpandAll;
         function HasFoldedBlocks: boolean;
         procedure PopulateComboBoxes; override;
         function GetMemoEx: TMemoEx; override;
         function CanInsertReturnBlock: boolean; override;
         function GetFromXML(ATag: IXMLElement): TErrorType; override;
         procedure SaveInXML(ATag: IXMLElement); override;
         procedure GenerateTemplateSection(ALines: TStringList; ATemplate: TStringList; const ALangId: string; ADeep: integer); override;
         function GetBlocks(AIndex: integer = PRIMARY_BRANCH_IDX-1): IEnumerable<TBlock>;
         procedure ResizeWithDrawLock;
         function GetFoldedText: string;
         procedure SetFoldedText(const AText: string);
         function CountErrWarn: TErrWarnCount; override;
         procedure SetVisible(AVisible: boolean; ASetComments: boolean = true); override;
         function CanBeFocused: boolean; override;
         function UnPinComments: integer; override;
         procedure CloneFrom(ABlock: TBlock); override;
         procedure OnMouseLeave(AClearRed: boolean = true); override;
         function GetBranchIndexByControl(AControl: TControl): integer;
         function RemoveBranch(AIndex: integer): boolean;
         function Remove(ANode: TTreeNodeWithFriend = nil): boolean; override;
   end;

   TBranch = class(TList<TBlock>, IIdentifiable)
      private
         FParentBlock: TGroupBlock;
         FRmvBlockIdx: integer;
         FId: integer;
         function GetHeight: integer;
         function GetId: integer;
         function _AddRef: Integer; stdcall;
         function _Release: Integer; stdcall;
         function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
      public
         Hook: TPoint;           // hook determines position of blocks within a branch in parent window coordinates
         Statement: TStatement;
         property ParentBlock: TGroupBlock read FParentBlock;
         property Height: integer read GetHeight;
         property Id: integer read GetId;
         constructor Create(const AParent: TGroupBlock; const AHook: TPoint; const AId: integer = ID_INVALID);
         destructor Destroy; override;
         procedure InsertAfter(ANewBlock, ABlock: TBlock);
         function FindInstanceOf(AClass: TClass): integer;
         function Remove(ABlock: TBlock): integer;
         procedure UndoRemove(ABlock: TBlock);
         function GetMostRight: integer;
   end;

implementation

uses
   System.StrUtils, Vcl.Menus, System.Types, System.Math, System.Rtti, Main_Block,
   Return_Block, ApplicationCommon, BlockFactory, UserFunction, XMLProcessor,
   Navigator_Form, LangDefinition, FlashThread, Main_Form;

type
   THackControl = class(TControl);
   THackCustomEdit = class(TCustomEdit);

constructor TBlock.Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: integer; AId: integer = ID_INVALID);
begin

   if ABranch <> nil then
   begin
      FParentBlock := ABranch.ParentBlock;
      FTopParentBlock := FParentBlock.TopParentBlock;
      inherited Create(FParentBlock);
      Parent := FParentBlock;
      FParentBranch := ABranch;
   end
   else                                     // current object is TMainBlock class
   begin
      FTopParentBlock := TGroupBlock(Self);
      inherited Create(Page.Form);
      Parent := Page.Box;
   end;

   ParentFont  := true;
   ParentColor := true;
   Ctl3D       := false;
   Color       := Page.Box.Color;
   Font.Name   := GSettings.FlowchartFontName;
   PopupMenu   := Page.Form.pmPages;
   DoubleBuffered := GSettings.EnableDBuffering;
   ControlStyle := ControlStyle + [csOpaque];
   ParentBackground := false;
   Canvas.TextFlags := Canvas.TextFlags or ETO_OPAQUE;
   SetBounds(ALeft, ATop, AWidth, AHeight);

   FId := GProject.Register(Self, AId);
   FStatement := TStatement.Create(Self);
   FMouseLeave := true;
   FShape := shpRectangle;
   FStatement.Color := GSettings.GetShapeColor(FShape);
   Ired := -1;

   OnMouseDown := MyOnMouseDown;
   OnMouseUp   := MyOnMouseUp;
   OnMouseMove := MyOnMouseMove;
   OnCanResize := MyOnCanResize;
   OnDblClick  := MyOnDblClick;
   OnDragOver  := MyOnDragOver;
   OnDragDrop  := MyOnDragDrop;
end;

constructor TGroupBlock.Create(ABranch: TBranch; ALeft, ATop, AWidth, AHeight: Integer; const AHook: TPoint; AId: integer = ID_INVALID);
begin

   inherited Create(ABranch, ALeft, ATop, AWidth, AHeight, AId);

   FStatement.Width := 65;

   FMemoFolder := TMemoEx.Create(Self);
   with FMemoFolder do
   begin
      Parent := Self;
      Visible := false;
      SetBounds(4, 4, 132, 55);
      DoubleBuffered := true;
      Color := GSettings.GetShapeColor(shpFolder);
      Font.Assign(FStatement.Font);
      OnMouseDown := Self.OnMouseDown;
      Font.Color := clNavy;
      OnChange := Self.OnChangeMemo;
   end;

   Expanded := true;

   FFixedBranches := 1;

   FFoldParms.Width := 140;
   FFoldParms.Height := 91;

   FShape := shpDiamond;
   FStatement.Color := GSettings.GetShapeColor(FShape);

   FTrueLabel := i18Manager.GetString('CaptionTrue');
   FFalseLabel := i18Manager.GetString('CaptionFalse');

   FBranchList := TObjectList<TBranch>.Create;
   FBranchList.Add(nil);

   Branch := AddBranch(AHook);
end;

procedure TBlock.CloneFrom(ABlock: TBlock);
var
   edit, editSrc: TCustomEdit;
begin
   if ABlock <> nil then
   begin
      Visible := ABlock.Visible;
      SetFont(ABlock.Font);
      editSrc := ABlock.GetTextControl;
      edit := GetTextControl;
      if edit <> nil then
      begin
         if editSrc <> nil then
         begin
            edit.Text := editSrc.Text;
            edit.BoundsRect := editSrc.BoundsRect;
            edit.Visible := editSrc.Visible;
            edit.SelStart := editSrc.SelStart;
         end;
         if edit.CanFocus then
            edit.SetFocus;
      end;
   end;
end;

procedure TGroupBlock.CloneFrom(ABlock: TBlock);
var
   grpBlock: TGroupBlock;
   newBlock, prevBlock, block: TBlock;
   lBranch, lBranch2: TBranch;
   i: integer;
begin
   inherited CloneFrom(ABlock);
   if ABlock is TGroupBlock then
   begin
      grpBlock := TGroupBlock(ABlock);
      FMemoFolder.CloneFrom(grpBlock.FMemoFolder);
      if not grpBlock.Expanded then
      begin
         Expanded := false;
         FFoldParms := grpBlock.FFoldParms;
         Constraints.MinWidth := 140;
         Constraints.MinHeight := 54;
         Width := grpBlock.Width;
         Height := grpBlock.Height;
         FMemoFolder.SetBounds(4, 4, Width-8, Height-36);
         FMemoFolder.Anchors := [akRight, akLeft, akBottom, akTop];
         BottomHook := Width div 2;
         BottomPoint.X := BottomHook;
         BottomPoint.Y := Height - 28;
         IPoint.X := BottomHook + 30;
         IPoint.Y := FMemoFolder.Height + 15;
         TopHook.X := BottomHook;
         FMemoFolder.Visible := true;
      end
      else
      begin
         FFoldParms.Width := grpBlock.FFoldParms.Width;
         FFoldParms.Height := grpBlock.FFoldParms.Height;
      end;
      for i := PRIMARY_BRANCH_IDX to grpBlock.FBranchList.Count-1 do
      begin
         lBranch := grpBlock.FBranchList[i];
         lBranch2 := GetBranch(i);
         if lBranch2 = nil then
            lBranch2 := AddBranch(lBranch.Hook);
         prevBlock := nil;
         for block in lBranch do
         begin
            newBlock := block.Clone(lBranch2);
            lBranch2.InsertAfter(newBlock, prevBlock);
            prevBlock := lBranch2.Last;
         end;
      end;
   end;
end;

destructor TBlock.Destroy;
var
   comment: TComment;
begin
   for comment in GetPinComments do
      comment.Free;
   if Self = GClpbrd.Instance then
      GClpbrd.Instance := nil;
   if Self = GClpbrd.UndoObject then
      GClpbrd.UndoObject := nil;
   GProject.UnRegister(Self);
   inherited Destroy;
end;

destructor TGroupBlock.Destroy;
begin
   Hide;
   Page.Box.SetScrollBars;
   FBranchList.Free;
   inherited Destroy;
end;

procedure TBlock.CreateParams(var Params: TCreateParams);
begin
   inherited CreateParams(Params);
   Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TBlock.WMExitSizeMove(var Msg: TWMMove);
var
   memo: TMemoEx;
begin
   inherited;
   ExitSizeMove;
   memo := GetMemoEx;
   if memo <> nil then
      memo.UpdateScrolls;
end;

procedure TBlock.ExitSizeMove;
var
   lock: boolean;
begin
   if FHResize or FVResize then
   begin
      lock := LockDrawing;
      try
         if FHResize then
         begin
            if FParentBlock <> nil then
               FParentBlock.ResizeHorz(true);
            FHResize := false;
         end;
         if FVResize then
         begin
            if Self is TGroupBlock then
               TGroupBlock(Self).LinkBlocks;
            if FParentBlock <> nil then
               FParentBlock.ResizeVert(true);
            FVResize := false;
         end;
      finally
         if lock then
            UnLockDrawing;
      end;
      GProject.SetChanged;
      if FParentBlock = nil then
         BringAllToFront;
      NavigatorForm.Invalidate;
   end;
end;

procedure TBlock.CloneComments(ASource: TBlock);
var
   newComment, comment: TComment;
   unPin: boolean;
   lPage: TBlockTabSheet;
begin
   if ASource <> nil then
   begin
      lPage := Page;
      unPin := ASource.PinComments > 0;
      try
         for comment in ASource.GetPinComments do
         begin
            newComment := comment.Clone(lPage);
            newComment.PinControl := Self;
         end;
         UnPinComments;
      finally
         if unPin then
            ASource.UnPinComments;
      end;
   end;
end;

procedure TBlock.MyOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   p: TPoint;
begin
   p := Point(X, Y);
   SelectBlock(p);
   SetCursor(p);
   if Rect(BottomPoint.X-5, BottomPoint.Y, BottomPoint.X+5, Height).Contains(p) then
   begin
      DrawArrow(BottomPoint, BottomPoint.X, Height-1, arrEnd, clRed);
      Ired := 0;
      Cursor := TCursor(GCustomCursor);
   end
   else if Ired = 0 then
   begin
      DrawArrow(BottomPoint, BottomPoint.X, Height-1);
      Ired := -1;
      Cursor := crDefault;
   end;
end;

procedure TGroupBlock.MyOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
   i: integer;
   p: PPoint;
begin
   if Expanded then
   begin
      for i := PRIMARY_BRANCH_IDX to FBranchList.Count-1 do
      begin
         p := @FBranchList[i].Hook;
         if Rect(p.X-5, TopHook.Y, p.X+5, p.Y).Contains(Point(X, Y)) then
         begin
            DrawArrow(p.X, TopHook.Y, p^, arrEnd, clRed);
            Ired := i;
            Cursor := TCursor(GCustomCursor);
            break;
         end
         else if Ired = i then
         begin
            DrawArrow(p.X, TopHook.Y, p^);
            Ired := -1;
            Cursor := crDefault;
            break;
         end;
      end;
   end;
   inherited MyOnMouseMove(Sender, Shift, X, Y);
end;

procedure TBlock.SetCursor(const APoint: TPoint);
begin
   if FFrame and Rect(Width-5, 0, Width, Height-5).Contains(APoint) then
      Cursor := crSizeWE
   else if FFrame and Rect(0, Height-5, Width-5, Height).Contains(APoint) then
      Cursor := crSizeNS
   else if FFrame and Rect(Width-5, Height-5, Width, Height).Contains(APoint) then
      Cursor := crSizeNWSE
   else if IsCursorResize then
      Cursor := crDefault;
end;

function TBlock.IsForeParent(AParent: TObject): boolean;
var
   lParent: TWinControl;
begin
   result := false;
   if AParent <> nil then
   begin
      lParent := Parent;
      while lParent is TBlock do
      begin
         if lParent = AParent then
         begin
            result := true;
            break;
         end;
         lParent := lParent.Parent;
      end;
   end;
end;

procedure TBlock.MyOnDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
   isShift: boolean;
   shiftState: TShiftState;
begin
   isShift := GetAsyncKeyState(vkShift) <> 0;
   if isShift then
      shiftState := [ssShift]
   else
      shiftState := [];
   MyOnMouseMove(Sender, shiftState, X, Y);
   if (Ired < 0) or (not (Source is TBlock)) or (Source is TMainBlock) or (Source is TReturnBlock) or ((not isShift) and ((Source = Self) or IsForeParent(Source))) then
      Accept := false;
end;

procedure TBlock.MyOnDragDrop(Sender, Source: TObject; X, Y: Integer);
var
   srcPage: TBlockTabSheet;
   mForm: TMainForm;
   menuItem: TMenuItem;
   inst: TControl;
   uobj: TObject;
   lock: boolean;
begin
   if Source is TBlock then
   begin
      lock := false;
      srcPage := TBlock(Source).Page;
      srcPage.Form.pmPages.PopupComponent := TBlock(Source);
      if GetAsyncKeyState(vkShift) <> 0 then
         menuItem := srcPage.Form.miCopy
      else
      begin
         menuItem := srcPage.Form.miCut;
         lock := TBlock(Source).LockDrawing;
      end;
      inst := GClpbrd.Instance;
      uobj := GClpbrd.UndoObject;
      GClpbrd.Instance := nil;
      GClpbrd.UndoObject := nil;
      mForm := Page.Form;
      try
         menuItem.OnClick(menuItem);
         mForm.pmPages.PopupComponent := Self;
         mForm.miPaste.OnClick(mForm.miPaste);
      finally
         GClpbrd.Instance := inst;
         GClpbrd.UndoObject := uobj;
         if lock then
            TBlock(Source).UnLockDrawing;
      end;
   end;
end;

procedure TBlock.WMMouseLeave(var Msg: TMessage);
begin
   inherited;
   if FMouseLeave then
      OnMouseLeave
   else
      FMouseLeave := true;
end;

procedure TBlock.OnMouseLeave(AClearRed: boolean = true);
begin
   if Cursor <> crDefault then
      Cursor := crDefault;
   ClearSelection;
   if Ired = 0 then
      DrawArrow(BottomPoint, BottomPoint.X, Height-1);
   if AClearRed then
      Ired := -1;
   if FVResize or FHResize then
      SendMessage(Handle, WM_NCHITTEST, 0, 0);
end;

procedure TGroupBlock.OnMouseLeave(AClearRed: boolean = true);
var
   p: PPoint;
   lBranch: TBranch;
begin
   lBranch := GetBranch(Ired);
   if lBranch <> nil then
   begin
      p := @lBranch.Hook;
      DrawArrow(p.X, TopHook.Y, p^);
   end;
   inherited OnMouseLeave(AClearRed);
end;

procedure TBlock.MyOnCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
   Resize := (NewWidth >= Constraints.MinWidth) and (NewHeight >= Constraints.MinHeight);
   if FHResize and Resize then
   begin
      BottomPoint.X := NewWidth div 2;
      TopHook.X := BottomPoint.X;
      IPoint.X := BottomPoint.X + 30;
   end;
end;

procedure TGroupBlock.MyOnCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
   Resize := (NewWidth >= Constraints.MinWidth) and (NewHeight >= Constraints.MinHeight);
   if FHResize and Resize then
   begin
      if Expanded then
         Inc(BottomPoint.X, NewWidth-Width)
      else
      begin
         BottomPoint.X := NewWidth div 2;
         TopHook.X := BottomPoint.X;
         IPoint.X := BottomPoint.X + 30;
      end;
   end;
   if FVResize and Resize then
   begin
      if Expanded then
         Inc(Branch.Hook.Y, NewHeight-Height)
      else
      begin
         IPoint.Y := NewHeight - 21;
         BottomPoint.Y := NewHeight - 28;
      end;
   end;
end;

procedure TBlock.MyOnDblClick(Sender: TObject);
begin
   if IsCursorSelect then
      ChangeFrame;
end;

procedure TBlock.ChangeFrame;
begin
   Frame := not Frame;
end;

function TGroupBlock.GenerateNestedCode(ALines: TStringList; ABranchInd, ADeep: integer; const ALangId: string): integer;
var
   block: TBlock;
   lBranch: TBranch;
begin
   result := 0;
   lBranch := GetBranch(ABranchInd);
   if lBranch <> nil then
   begin
      for block in lBranch do
          result := result + block.GenerateCode(ALines, ALangId, ADeep);
   end;
end;

function TBlock.GetTextControl: TCustomEdit;
begin
   result := FStatement;
end;

function TBlock.IsInSelect(const APoint: TPoint): boolean;
begin
   result := Bounds(IPoint.X-5, IPoint.Y, 10, 10).Contains(APoint);
end;

procedure TBlock.MyOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   menuItem: TMenuItem;
   mForm: TMainForm;
begin
   if Button = mbLeft then
   begin
      if IsInSelect(Point(X, Y)) then
         BeginDrag(false, 3)
      else if not IsCursorResize then
      begin          // drag entire flowchart
         ReleaseCapture;
         FTopParentBlock.BringAllToFront;
         SendMessage(FTopParentBlock.Handle, WM_SYSCOMMAND, $F012, 0);
         FTopParentBlock.OnResize(FTopParentBlock);
         if Ired >= 0 then
         begin
            mForm := Page.Form;
            menuItem := nil;
            case GCustomCursor of
               crInstr:       menuItem := mForm.miInstr;
               crMultiInstr:  menuItem := mForm.miMultiInstr;
               crIfElse:      menuItem := mForm.miIfElse;
               crWhile:       menuItem := mForm.miWhile;
               crFor:         menuItem := mForm.miFor;
               crRepeat:      menuItem := mForm.miRepeat;
               crInput:       menuItem := mForm.miInput;
               crOutput:      menuItem := mForm.miOutput;
               crFuncCall:    menuItem := mForm.miRoutineCall;
               crIf:          menuItem := mForm.miIf;
               crCase:        menuItem := mForm.miCase;
               crFolder:      menuItem := mForm.miFolder;
               crText:        menuItem := mForm.miText;
               crReturn:
               begin
                  if CanInsertReturnBlock then
                     menuItem := mForm.miReturn;
               end;
            end;
            if menuItem <> nil then
            begin
               PopupMenu.PopupComponent := Self;
               menuItem.OnClick(menuItem);
            end;
         end;
      end;
   end;
end;

function TBlock.Clone(ABranch: TBranch): TBlock;
begin
{}
end;

procedure TBlock.NCHitTest(var Msg: TWMNCHitTest);
begin
   inherited;
   if GetAsyncKeyState(vkLButton) <> 0 then
   begin
      FMouseLeave := false;
      case Cursor of
         crSizeWE:
         begin
            Msg.Result := HTRIGHT;
            FHResize := true;
            BringToFront;
         end;
         crSizeNS:
         begin
            Msg.Result := HTBOTTOM;
            FVResize := true;
            BringToFront;
         end;
         crSizeNWSE:
         begin
            Msg.Result := HTBOTTOMRIGHT;
            FHResize := true;
            FVResize := true;
            BringToFront;
         end;
      end;
   end;
end;

procedure TBlock.MyOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   p: TPoint;
begin
   if Button = mbRight then
   begin
      p := ClientToScreen(Point(X, Y));
      PopupMenu.PopupComponent := Self;
      FMouseLeave := false;
      PopupMenu.Popup(p.X, p.Y);
   end;
end;

procedure TBlock.SetFrame(AValue: boolean);
begin
   if FFrame <> AValue then
   begin
      FFrame := AValue;
      GProject.SetChanged;
      ClearSelection;
      Invalidate;
      if FFrame then
         TInfra.GetEditorForm.SelectCodeRange(Self)
      else
         TInfra.GetEditorForm.UnSelectCodeRange(Self);
   end;
end;

procedure TGroupBlock.ResizeWithDrawLock;
var
   lock: boolean;
begin
   lock := LockDrawing;
   try
      ResizeHorz(true);
      ResizeVert(true);
   finally
      if lock then
         UnlockDrawing;
   end;
end;

procedure TGroupBlock.ResizeVert(AContinue: boolean);
begin
   Height := Branch.Height + Branch.Hook.Y + FInitParms.HeightAffix;
   LinkBlocks;
   if AContinue and (FParentBlock <> nil) then
      FParentBlock.ResizeVert(AContinue);
end;

procedure TGroupBlock.ResizeHorz(AContinue: boolean);
var
   xLeft, xRight: integer;
   block: TBlock;
begin

   Branch.Hook.X := FInitParms.BranchPoint.X;
   TopHook.X := Branch.Hook.X;
   LinkBlocks;

   if Branch.Count = 0 then   // case if primary branch is empty
   begin
      Width := FInitParms.Width;
      BottomHook := FInitParms.BottomHook;
      BottomPoint.X := FInitParms.BottomPoint.X;
   end
   else
   begin
      // resize in left direction
      xLeft := 30;   // 30 - left margin
      for block in Branch do
          xLeft := Min(xLeft, block.Left);

      Branch.Hook.X := Branch.Hook.X + 30 - xLeft;
      TopHook.X := Branch.Hook.X;
      LinkBlocks;
      BottomHook := Branch.Last.Left + Branch.Last.BottomPoint.X;

      // resize in right direction
      xRight := 0;
      for block in Branch do
          xRight := Max(xRight, block.BoundsRect.Right);

      SetWidth(xRight);  // set final width
   end;

   if FParentBlock <> nil then
   begin
      if AContinue then
         FParentBlock.ResizeHorz(AContinue);
   end
   else if GSettings.ShowFuncLabels then
      RepaintAll;

end;

procedure TGroupBlock.SetWidth(AMinX: integer);
begin
{}
end;

procedure TGroupBlock.LinkBlocks(const idx: integer = PRIMARY_BRANCH_IDX-1);
var
   block, blockPrev: TBlock;
   i, first, last: integer;
   p: TPoint;
   lBranch: TBranch;
begin
   if GetBranch(idx) <> nil then
   begin
      first := idx;
      last := idx;
   end
   else
   begin
      first := PRIMARY_BRANCH_IDX;
      last := FBranchList.Count - 1;
   end;
   for i := first to last do
   begin
      blockPrev := nil;
      lBranch := FBranchList[i];
      for block in lBranch do
      begin
         if blockPrev <> nil then
            p := Point(blockPrev.BottomPoint.X+blockPrev.Left-block.TopHook.X, blockPrev.BoundsRect.Bottom)
         else
            p := Point(lBranch.Hook.X-block.TopHook.X, lBranch.Hook.Y+1);
         TInfra.MoveWin(block, p);
         blockPrev := block;
      end;
   end;
end;

function TGroupBlock.GetFoldedText: string;
begin
   result := FMemoFolder.Text;
end;

procedure TGroupBlock.SetFoldedText(const AText: string);
begin
   FMemoFolder.Text := AText;
end;

procedure TBlock.SetPage(APage: TBlockTabSheet);
begin
end;

function TBlock.GetPage: TBlockTabSheet;
begin
   result := FTopParentBlock.Page;
end;

procedure TBlock.SetFontStyle(const AStyle: TFontStyles);
var
   i: integer;
begin
   Font.Style := AStyle;
   for i := 0 to ControlCount-1 do
   begin
      if Controls[i] is TBlock then
         TBlock(Controls[i]).SetFontStyle(AStyle)
      else
         THackControl(Controls[i]).Font.Style := AStyle;
   end;
   Refresh;
end;

procedure TBlock.SetFontSize(ASize: integer);
var
   i: integer;
begin
   Font.Size := ASize;
   for i := 0 to ControlCount-1 do
   begin
      if Controls[i] is TBlock then
         TBlock(Controls[i]).SetFontSize(ASize)
      else
         TInfra.SetFontSize(Controls[i], ASize);
   end;
   PutTextControls;
   Refresh;
end;

function TBlock.GetFont: TFont;
begin
   result := Font;
end;

procedure TBlock.SetFont(AFont: TFont);
var
   i: integer;
begin
   Font.Assign(AFont);
   Refresh;
   for i := 0 to ControlCount-1 do
   begin
      if Controls[i] is TBlock then
      begin
         TBlock(Controls[i]).SetFontStyle(AFont.Style);
         TBlock(Controls[i]).SetFontSize(AFont.Size);
      end
      else
      begin
         THackControl(Controls[i]).Font.Style := AFont.Style;
         TInfra.SetFontSize(Controls[i], AFont.Size);
      end;
   end;
   PutTextControls;
end;

function TBlock.GetComments(AInFront: boolean = false): IEnumerable<TComment>;
var
   comment: TComment;
   isFront: boolean;
   lPage: TBlockTabSheet;
   list: TList<TComment>;
begin
   list := TList<TComment>.Create;
   if Visible then
   begin
      lPage := Page;
      for comment in GProject.GetComments do
      begin
         if comment.Page = lPage then
         begin
            if AInFront then
               isFront := IsInFront(comment)
            else
               isFront := true;
            if isFront and (comment.PinControl = nil) and ClientRect.Contains(ParentToClient(comment.BoundsRect.TopLeft, lPage.Box)) then
               list.Add(comment);
         end
      end;
   end;
   result := TEnumeratorFactory<TComment>.Create(list);
end;

procedure TBlock.BringAllToFront;
var
   comment: TComment;
begin
   BringToFront;
   for comment in GetComments do
      comment.BringToFront;
end;

function TBlock.IsInFront(AControl: TWinControl): boolean;
var
   hnd: THandle;
begin
   result := false;
   if AControl <> nil then
   begin
      hnd := GetWindow(AControl.Handle, GW_HWNDLAST);
      while hnd <> 0 do
      begin
         if hnd = FTopParentBlock.Handle then
         begin
            result := true;
            break;
         end
         else if hnd = AControl.Handle then
            break;
         hnd := GetNextWindow(hnd, GW_HWNDPREV);
      end;
   end;
end;

procedure TBlock.MoveComments(x, y: integer);
var
   comment: TComment;
begin
   if (x <> 0) and (y <> 0) and (Left <> 0) and (Top <> 0) and ((x <> Left) or (y <> Top)) then
   begin
      for comment in GetComments(true) do
      begin
         if comment.Visible then
            TInfra.MoveWinTopZ(comment, comment.Left+x-Left, comment.Top+y-Top);
      end;
   end;
end;

procedure TBlock.OnWindowPosChanged(x, y: integer);
begin
   MoveComments(x, y);
end;

procedure TBlock.WMWindowPosChanged(var Msg: TWMWindowPosChanged);
begin
   OnWindowPosChanged(Msg.WindowPos.x, Msg.WindowPos.y);
   inherited;
end;

function TBlock.GetPinComments: IEnumerable<TComment>;
var
   comment: TComment;
   list: TList<TComment>;
begin
   list := TList<TComment>.Create;
   for comment in GProject.GetComments do
   begin
      if comment.PinControl = Self then
         list.Add(comment);
   end;
   result := TEnumeratorFactory<TComment>.Create(list);
end;

procedure TBlock.PutTextControls;
begin
end;

function TGroupBlock.GetDiamondTop: TPoint;
begin
   result := Point(-1, -1);
end;

procedure TBlock.RefreshStatements;
var
   i: integer;
   b, b1: boolean;
   control: TControl;
begin
    b := NavigatorForm.InvalidateInd;
    NavigatorForm.InvalidateInd := false;
    b1 := FRefreshMode;
    FRefreshMode := true;
    try
       for i := 0 to ControlCount-1 do
       begin
          control := Controls[i];
          if control is TStatement then
             TStatement(control).DoEnter
          else if (control is TMemoEx) and Assigned(TMemoEx(control).OnChange) then
             TMemoEx(control).OnChange(control)
          else if (control is TEdit) and Assigned(TEdit(control).OnChange) then
             TEdit(control).OnChange(control)
          else if (control is TBlock) and (control <> GClpbrd.UndoObject) then
             TBlock(control).RefreshStatements;
       end;
    finally
       FRefreshMode := b1;
    end;
    NavigatorForm.InvalidateInd := b;
end;

function TBlock.GetId: integer;
begin
   result := FId;
end;

procedure TBlock.ChangeColor(AColor: TColor);
var
   comment: TComment;
   lEdit: THackCustomEdit;
   lColor: TColor;
begin
   Color := AColor;
   for comment in GetComments do
   begin
      if comment.Visible then
         comment.Color := AColor;
   end;
   lEdit := THackCustomEdit(GetTextControl);
   if lEdit <> nil then
   begin
      lColor := GSettings.GetShapeColor(FShape);
      if lColor = GSettings.DesktopColor then
         lEdit.Color := AColor
      else
         lEdit.Color := lColor;
   end;
end;

procedure TBlock.ClearSelection;
var
   lColor: TColor;
begin
   lColor := Page.Box.Color;
   if Color <> lColor then
      ChangeColor(lColor);
   NavigatorForm.Invalidate;
end;

procedure TGroupBlock.ChangeColor(AColor: TColor);
var
   i: integer;
   block: TBlock;
   lColor: TColor;
begin
   inherited ChangeColor(AColor);
   if Expanded then
   begin
      for i := PRIMARY_BRANCH_IDX to FBranchList.Count-1 do
      begin
         for block in FBranchList[i] do
             block.ChangeColor(AColor);
      end;
   end;
   lColor := GSettings.GetShapeColor(shpFolder);
   if lColor = GSettings.DesktopColor then
      FMemoFolder.Color := AColor
   else
      FMemoFolder.Color := lColor;
end;

procedure TBlock.SelectBlock(const APoint: TPoint);
begin
   if IsInSelect(APoint) then
   begin
      if Color <> GSettings.HighlightColor then
      begin
         ChangeColor(GSettings.HighlightColor);
         if GSettings.EditorAutoSelectBlock then
            TInfra.GetEditorForm.SelectCodeRange(Self);
         NavigatorForm.Invalidate;
      end;
   end
   else if Color <> Page.Box.Color then
   begin
      ChangeColor(Page.Box.Color);
      if GSettings.EditorAutoSelectBlock and not FFrame then
         TInfra.GetEditorForm.UnSelectCodeRange(Self);
      NavigatorForm.Invalidate;
   end;
end;

procedure TGroupBlock.ExpandAll;
var
   i: integer;
   block: TBlock;
begin
   if not Expanded then
      ExpandFold(true);
   for i := PRIMARY_BRANCH_IDX to FBranchList.Count-1 do
   begin
      for block in FBranchList[i] do
      begin
         if block is TGroupBlock then
            TGroupBlock(block).ExpandAll;
      end;
   end;
end;

procedure TBlock.RepaintAll;
var
   i: integer;
begin
   Repaint;
   for i := 0 to ControlCount-1 do
   begin
      if Controls[i] is TBlock then
         TBlock(Controls[i]).RepaintAll
      else
         Controls[i].Repaint;
   end;
end;

function TGroupBlock.HasFoldedBlocks: boolean;
var
   block: TBlock;
   i: integer;
begin
   result := not Expanded;
   if Expanded then
   begin
      for i := PRIMARY_BRANCH_IDX to FBranchList.Count-1 do
      begin
         for block in FBranchList[i] do
         begin
            if block is TGroupBlock then
            begin
               result := TGroupBlock(block).HasFoldedBlocks;
               if result then break;
            end;
         end;
         if result then break;
      end;
   end;
end;

procedure TBlock.Paint;
begin
   inherited;
   with Canvas do
   begin
      Brush.Style := bsSolid;
      Brush.Color := Self.Color;
      FillRect(ClipRect);
      Pen.Color := GSettings.PenColor;
      Pen.Width := 1;
      if FFrame then
      begin
         Pen.Style := psDashDot;
         PolyLine([TPoint.Zero, Point(Width-1, 0), Point(Width-1, Height-1), Point(0, Height-1), TPoint.Zero]);
         Pen.Style := psSolid;
      end;
      Font.Assign(Self.Font);
      Font.Color := GSettings.PenColor;
   end;
end;

procedure TBlock.DrawI;
begin
   if Page.DrawI then
   begin
      Canvas.PenPos := IPoint;
      Canvas.LineTo(IPoint.X, IPoint.Y+10);
   end;
end;

procedure TBlock.DrawBlockLabel(x, y: integer; const AText: string; rightJust: boolean = false; downJust: boolean = false);
var
   fontName: string;
   fontSize: integer;
   fontStyles: TFontStyles;
begin
   if GSettings.ShowBlockLabels and not AText.IsEmpty then
   begin
      fontName := Canvas.Font.Name;
      fontStyles := Canvas.Font.Style;
      Canvas.Font.Name := GInfra.CurrentLang.LabelFontName;
      Canvas.Font.Style := [fsBold];
      fontSize := Canvas.Font.Size;
      Canvas.Font.Size := GInfra.CurrentLang.LabelFontSize;
      DrawTextLabel(x, y, AText, rightJust, downJust);
      Canvas.Font.Name := fontName;
      Canvas.Font.Size := fontSize;
      Canvas.Font.Style := fontStyles;
   end;
end;

function TBlock.DrawTextLabel(x, y: integer; const AText: string; rightJust: boolean = false; downJust: boolean = false): TRect;
var
   fontStyles: TFontStyles;
   fontColor: TColor;
   tw, th: integer;
begin
   tw := 0;
   th := 0;
   if not AText.IsEmpty then
   begin
      fontStyles := Canvas.Font.Style;
      fontColor := Canvas.Font.Color;
      Canvas.Font.Style := [];
      Canvas.Font.Color := GSettings.PenColor;
      if fsBold in fontStyles then
         Canvas.Font.Style := Canvas.Font.Style + [fsBold];
      Canvas.Brush.Style := bsClear;
      tw := Canvas.TextWidth(AText);
      th := Canvas.TextHeight(AText);
      if rightJust then
         x := Max(x-tw, 0);
      if downJust then
         y := Max(y-th, 0);
      Canvas.TextOut(x, y, AText);
      Canvas.Font.Style := fontStyles;
      Canvas.Font.Color := fontColor;
   end;
   result := TRect.Create(Point(x, y), tw, th);
end;

procedure TBlock.DrawArrow(const aFrom, aTo: TPoint; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone);
begin
   DrawArrow(aFrom.X, aFrom.Y, aTo.X, aTo.Y, AArrowPos, AColor);
end;

procedure TBlock.DrawArrow(fromX, fromY: integer; const aTo: TPoint; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone);
begin
   DrawArrow(fromX, fromY, aTo.X, aTo.Y, AArrowPos, AColor);
end;

procedure TBlock.DrawArrow(const aFrom: TPoint; toX, toY: integer; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone);
begin
   DrawArrow(aFrom.X, aFrom.Y, toX, toY, AArrowPos, AColor);
end;

// this method draw arrow line from current pen position
procedure TBlock.DrawArrowTo(toX, toY: integer; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone);
begin
   DrawArrow(Canvas.PenPos, toX, toY, AArrowPos, AColor);
end;

// this method draw arrow line from current pen position
procedure TBlock.DrawArrowTo(const aTo: TPoint; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone);
begin
   DrawArrow(Canvas.PenPos, aTo, AArrowPos, AColor);
end;

procedure TBlock.DrawArrow(fromX, fromY, toX, toY: integer; AArrowPos: TArrowPosition = arrEnd; AColor: TColor = clNone);
const
   MX: array[boolean, boolean] of integer = ((10, -10), (-5, -5));
   MY: array[boolean, boolean] of integer = ((5, 5), (10, -10));
   MD: array[boolean, boolean] of integer = ((0, -10), (10, 0));
var
   isVert, toBottomRight: boolean;
   aX, aY: integer;
   p: TPoint;
begin
   if AColor = clNone then
      AColor := GSettings.PenColor;
   aX := toX;
   aY := toY;
   isVert := fromX = toX;
   if AArrowPos = arrMiddle then
   begin
      if isVert then
         Inc(aY, (fromY-toY) div 2)
      else
         Inc(aX, (fromX-toX) div 2);
   end;
   if isVert then
      toBottomRight := toY > fromY
   else
      toBottomRight := toX > fromX;
   p := Point(aX+MX[isVert, toBottomRight], aY+MY[isVert, toBottomRight]);
   Canvas.Brush.Style := bsSolid;
   Canvas.Pen.Color := AColor;
   Canvas.Brush.Color := AColor;
   Canvas.Polygon([p,
                   Point(p.X+MD[isVert, false], p.Y+MD[isVert, true]),
                   Point(aX, aY),
                   p]);
   Canvas.MoveTo(fromX, fromY);
   Canvas.LineTo(toX, toY);
end;

function TBlock.GetEllipseTextRect(ax, ay: integer; const AText: string): TRect;
const
   MIN_HALF_HEIGHT = 15;
   MIN_HALF_WIDTH = 30;
var
   a, b: integer;
   ar, br, cx, cy: single;
   R: TRect;
   wndExt, viewPort: TSize;
begin
   GetWindowExtEx(Canvas.Handle, wndExt);
   GetViewportExtEx(Canvas.Handle, viewPort);
   cx := viewPort.cx / wndExt.cx;
   cy := viewPort.cy / wndExt.cy;
   R := TRect.Empty;
   DrawText(Canvas.Handle, PChar(AText), -1, R, DT_CALCRECT);
   ar := R.Height * cy / Sqrt(2);
   br := R.Width * cx / Sqrt(2);
   if ar < MIN_HALF_HEIGHT then
   begin
      if IsZero(ar) then
         br := MIN_HALF_WIDTH
      else
         br := MIN_HALF_HEIGHT * br / ar;
      ar := MIN_HALF_HEIGHT;
   end;
   {if br < MIN_HALF_WIDTH then
   begin
      if br = 0 then
         ar := MIN_HALF_HEIGHT
      else
         ar := MIN_HALF_WIDTH * ar / br;
      br := MIN_HALF_WIDTH;
   end;}
   a := Round(ar);
   b := Round(br);
   result := Rect(ax-b, ay-2*a, ax+b, ay);
end;

function TBlock.DrawEllipsedText(ax, ay: integer; const AText: string): TRect;
var
   lColor: TColor;
begin
   result := GetEllipseTextRect(ax, ay, AText);
   Canvas.Brush.Style := bsClear;
   lColor := GSettings.GetShapeColor(shpEllipse);
   if lColor <> GSettings.DesktopColor then
      Canvas.Brush.Color := lColor;
   Canvas.Ellipse(result);
   DrawText(Canvas.Handle, PChar(AText), -1, result, DT_CENTER or DT_SINGLELINE or DT_VCENTER);
end;

function TBlock.GetMemoEx: TMemoEx;
begin
   result := nil;
end;

function TGroupBlock.GetMemoEx: TMemoEx;
begin
   result := FMemoFolder;
end;

function TBlock.CountErrWarn: TErrWarnCount;
var
   textControl: TCustomEdit;
begin
   result.ErrorCount := 0;
   result.WarningCount := 0;
   textControl := GetTextControl;
   if textControl <> nil then
   begin
      if THackControl(textControl).Font.Color = NOK_COLOR then
         result.ErrorCount := 1
      else if THackControl(textControl).Font.Color = WARN_COLOR then
         result.WarningCount := 1;
   end;
end;

function TGroupBlock.CountErrWarn: TErrWarnCount;
var
   errWarnCount: TErrWarnCount;
   block: TBlock;
begin
   result := inherited CountErrWarn;
   for block in GetBlocks do
   begin
      errWarnCount := block.CountErrWarn;
      Inc(result.ErrorCount, errWarnCount.ErrorCount);
      Inc(result.WarningCount, errWarnCount.WarningCount);
   end;
end;

procedure TGroupBlock.Paint;
var
   p: TPoint;
   brushStyle: TBrushStyle;
   lColor, lColor2: TColor;
   w, a: integer;
   edit: TCustomEdit;
   r: TRect;
begin
   inherited;
   brushStyle := Canvas.Brush.Style;
   lColor := Canvas.Brush.Color;
   w := Canvas.Pen.Width;
   if Expanded then
   begin
      p := GetDiamondTop;
      edit := GetTextControl;
      if (edit <> nil) and not InvalidPoint(p) then
      begin
         a := (edit.Height + edit.Width div 2) div 2 + 1;
         FDiamond[D_LEFT] := Point(p.X-2*a, p.Y+a);
         FDiamond[D_BOTTOM] := Point(p.X, p.Y+2*a);
         FDiamond[D_RIGHT] := Point(p.X+2*a, p.Y+a);
         FDiamond[D_TOP] := p;
         FDiamond[D_LEFT_CLOSE] := FDiamond[D_LEFT];
         TInfra.MoveWin(edit, p.X-edit.Width div 2, p.Y+a-edit.Height div 2);
         Canvas.Brush.Style := bsClear;
         lColor2 := GSettings.GetShapeColor(FShape);
         if lColor2 <> GSettings.DesktopColor then
            Canvas.Brush.Color := lColor2;
         Canvas.Polygon(FDiamond);
      end;
   end
   else
   begin
      lColor2 := GSettings.GetShapeColor(shpFolder);
      if lColor2 <> GSettings.DesktopColor then
         Canvas.Brush.Color := lColor2;
      Canvas.Pen.Width := 2;
      r := FMemoFolder.BoundsRect;
      r.Inflate(3, 3, 4, 4);
      Canvas.Rectangle(r);
      Canvas.Pen.Width := 1;
      if FTopParentBlock <> Self then
         DrawArrow(BottomPoint, BottomPoint.X, Height-1);
      r.Inflate(-2, -2, -3, -3);
      Canvas.Rectangle(r);
   end;
   Canvas.Brush.Style := brushStyle;
   Canvas.Brush.Color := lColor;
   Canvas.Pen.Width := w;
end;

// return value indicates if drawing was in fact locked by this call
// it may not since it's already locked by other block before
function TBlock.LockDrawing: boolean;
begin
   result := false;
   if not FTopParentBlock.FDrawingFlag then
   begin
      FTopParentBlock.FDrawingFlag := true;
      result := true;
      SendMessage(FTopParentBlock.Handle, WM_SETREDRAW, WPARAM(False), 0);
   end;
end;

procedure TBlock.UnLockDrawing;
begin
   if FTopParentBlock.FDrawingFlag then
   begin
      SendMessage(FTopParentBlock.Handle, WM_SETREDRAW, WPARAM(True), 0);
      GProject.RepaintFlowcharts;
      GProject.RepaintComments;
      RedrawWindow(Page.Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME or RDW_ERASE);
      FTopParentBlock.FDrawingFlag := false;
   end;
end;

function TBlock.CanInsertReturnBlock: boolean;
begin
   result := (Ired = 0) and (FParentBranch <> nil) and (FParentBranch.Count > 0) and (FParentBranch.Last = Self);
end;

function TGroupBlock.CanInsertReturnBlock: boolean;
var
   lBranch: TBranch;
begin
   if Ired = 0 then
      result := (FParentBranch <> nil) and (FParentBranch.Count > 0) and (FParentBranch.Last = Self)
   else
   begin
      lBranch := GetBranch(Ired);
      result := (lBranch <> nil) and (lBranch.Count = 0);
   end;
end;

procedure TBlock.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
var
   p: TPoint;
   box: TScrollBoxEx;
begin
   inherited;
   box := Page.Box;
   p := ClientToParent(TPoint.Zero, box);
   if FHResize then
      Msg.MinMaxInfo.ptMaxTrackSize.X := box.ClientWidth - p.X;
   if FVResize then
      Msg.MinMaxInfo.ptMaxTrackSize.Y := box.ClientHeight - p.Y;
end;

function TBlock.IsCursorSelect: boolean;
begin
   result := IsInSelect(ScreenToClient(Mouse.CursorPos));
end;

function TBlock.IsCursorResize: boolean;
begin
   result := -Cursor in [-crSizeWE, -crSizeNS, -crSizeNWSE];
end;

procedure TBlock.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
   Msg.Result := 1;
end;

function TGroupBlock.GetBranch(idx: integer): TBranch;
begin
   result := nil;
   if (idx >= PRIMARY_BRANCH_IDX) and (idx < FBranchList.Count) then
      result := FBranchList[idx];
end;

function TBlock.FindLastRow(AStart: integer; ALines: TStrings): integer;
begin
   result := TInfra.FindLastRow(Self, AStart, ALines);
end;

function TGroupBlock.FindLastRow(AStart: integer; ALines: TStrings): integer;
var
   i: integer;
   lBranch: TBranch;
begin
   result := inherited FindLastRow(AStart, ALines);
   for i := PRIMARY_BRANCH_IDX to FBranchList.Count-1 do
   begin
      lBranch := FBranchList[i];
      if lBranch.Count > 0 then
         result := Max(result, lBranch.Last.FindLastRow(AStart, ALines));
   end;
end;

procedure TBlock.MyOnChange(Sender: TObject);
begin
   NavigatorForm.DoInvalidate;
end;

procedure TBlock.OnChangeMemo(Sender: TObject);
var
   memo: TMemoEx;
begin
   memo := GetMemoEx;
   if memo <> nil then
      memo.UpdateScrolls;
   NavigatorForm.DoInvalidate;
end;

function TBlock.CanBeFocused: boolean;
var
   lParent: TGroupBlock;
   func: TUserFunction;
begin
   result := true;
   lParent := FParentBlock;
   while lParent <> nil do
   begin
      if not lParent.Expanded then
      begin
         result := false;
         break;
      end;
      lParent := lParent.ParentBlock;
   end;
   if result then
   begin
      func := TUserFunction(TMainBlock(FTopParentBlock).UserFunction);
      if func <> nil then
      begin
         result := func.Active;
         if result and (func.Header <> nil) then
            result := func.Header.chkBodyVisible.Checked;
      end;
      if result and (FParentBranch <> nil) and (FParentBranch.IndexOf(Self) = -1) then
         result := false;
   end;
end;

function TGroupBlock.CanBeFocused: boolean;
begin
   result := Expanded;
   if result then
      result := inherited CanBeFocused;
end;

function TBlock.RetrieveFocus(AInfo: TFocusInfo): boolean;
var
   lPage: TBlockTabSheet;
begin
   if AInfo.FocusEdit = nil then
      AInfo.FocusEdit := GetTextControl;
   lPage := Page;
   AInfo.FocusEditForm := lPage.Form;
   lPage.PageControl.ActivePage := lPage;
   result := FocusOnTextControl(AInfo);
end;

function TBlock.FocusOnTextControl(AInfo: TFocusInfo): boolean;
var
   idx, idx2, i: integer;
   txt: string;
   memo: TCustomMemo;
   box: TScrollBoxEx;
begin
   result := false;
   if ContainsControl(AInfo.FocusEdit) and AInfo.FocusEdit.CanFocus then
   begin
      box := Page.Box;
      box.Show;
      FTopParentBlock.BringAllToFront;
      box.ScrollInView(AInfo.FocusEdit);
      idx2 := 0;
      if AInfo.FocusEdit is TCustomMemo then
      begin
         memo := TCustomMemo(AInfo.FocusEdit);
         if AInfo.RelativeLine < memo.Lines.Count then
         begin
            txt := memo.Lines[AInfo.RelativeLine];
            if AInfo.RelativeLine > 0 then
            begin
               for i := 0 to AInfo.RelativeLine-1 do
                  idx2 := idx2 + (memo.Lines[i] + sLineBreak).Length;
            end;
         end
         else
            txt := memo.Text;
      end
      else
         txt := AInfo.FocusEdit.Text;
      idx := Pos(txt, AInfo.LineText);
      if idx <> 0 then
         AInfo.SelStart := AInfo.SelStart - idx + idx2
      else
      begin
         idx := Pos(AInfo.SelText, txt);
         if idx <> 0 then
            AInfo.SelStart := idx - 1 + idx2;
      end;
      AInfo.FocusEditCallBack := UpdateEditor;
      TFlashThread.Create(AInfo);
      result := true;
   end;
end;

function TBlock.GetErrorMsg(AEdit: TCustomEdit): string;
var
   lColor: TColor;
   i: integer;
begin
   result := '';
   if AEdit <>  nil then
   begin
      lColor := THackControl(AEdit).Font.Color;
      if TInfra.IsNOkColor(lColor) then
      begin
         result := AEdit.Hint;
         i := LastDelimiter(sLineBreak, result);
         if i > 0 then
            result := ' - ' + Copy(result, i+1, MaxInt);
      end;
   end;
end;

function TBlock.GenerateTree(AParentNode: TTreeNode): TTreeNode;
var
   errMsg, descTemplate: string;
   textControl: TCustomEdit;
begin
   result := AParentNode;
   textControl := GetTextControl;
   if textControl <> nil then
   begin
      errMsg := GetErrorMsg(textControl);
      descTemplate := GetDescTemplate(GInfra.CurrentLang.Name);
      result := AParentNode.Owner.AddChildObject(AParentNode, FillTemplate(GInfra.CurrentLang.Name, descTemplate) + errMsg, textControl);
      if not errMsg.IsEmpty then
      begin
         AParentNode.MakeVisible;
         AParentNode.Expand(false);
      end;
   end;
end;

function TGroupBlock.GenerateTree(AParentNode: TTreeNode): TTreeNode;
var
   block: TBlock;
begin
   result := inherited GenerateTree(AParentNode);
   for block in FBranchList[PRIMARY_BRANCH_IDX] do
       block.GenerateTree(result);
end;

function TGroupBlock.GetBranchIndexByControl(AControl: TControl): integer;
var
   i: integer;
begin
   result := BRANCH_IDX_NOT_FOUND;
   if FBranchList = nil then
      Exit;
   for i := PRIMARY_BRANCH_IDX to FBranchList.Count-1 do
   begin
      if FBranchList[i].Statement = AControl then
      begin
         result := i;
         break;
      end;
   end;
end;

function TGroupBlock.AddBranch(const AHook: TPoint; ABranchId: integer = ID_INVALID; ABranchStmntId: integer = ID_INVALID): TBranch;
begin
   result := TBranch.Create(Self, AHook, ABranchId);
   FBranchList.Add(result);
end;

function TBlock.CanRemove: boolean;
begin
   result := Visible;
end;

function TBlock.GetUndoObject: TObject;
begin
   result := Self;
end;

function TBlock.Remove(ANode: TTreeNodeWithFriend = nil): boolean;
begin
   result := CanRemove;
   if result then
   begin
      GClpbrd.UndoObject.Free;
      ClearSelection;
      SetVisible(false);
      if FParentBranch <> nil then
      begin
         FParentBranch.Remove(Self);
         if FParentBlock <> nil then
            FParentBlock.ResizeWithDrawLock;
      end;
      GClpbrd.UndoObject := GetUndoObject;
      TInfra.UpdateCodeEditor;
      NavigatorForm.Repaint;
   end;
end;

function TGroupBlock.Remove(ANode: TTreeNodeWithFriend = nil): boolean;
begin
   result := CanRemove;
   if result then
   begin
      if ANode <> nil then
         result := RemoveBranch(GetBranchIndexByControl(ANode.Data))
      else
         result := false;
      if not result then
         result := inherited Remove(ANode);
   end;
end;

function TBlock.IsBoldDesc: boolean;
begin
   result := false;
end;

function TBlock.PinComments: integer;
var
   comment: TComment;
   p: TPoint;
   lPage: TBlockTabSheet;
begin
   result := 0;
   lPage := Page;
   p := ClientToParent(TPoint.Zero, lPage.Box);
   for comment in GetComments do
   begin
      comment.Visible := false;
      TInfra.MoveWin(comment, comment.Left - p.X, comment.Top - p.Y);
      comment.PinControl := Self;
      comment.Parent := lPage;
      Inc(result);
   end;
end;

function TBlock.UnPinComments: integer;
var
   comment: TComment;
   p: TPoint;
   box: TScrollBoxEx;
begin
   result := 0;
   box := Page.Box;
   p := ClientToParent(TPoint.Zero, box);
   for comment in GetPinComments do
   begin
      TInfra.MoveWin(comment, comment.Left + p.X, comment.Top + p.Y);
      comment.Parent := box;
      comment.Visible := true;
      comment.PinControl := nil;
      comment.BringToFront;
      Inc(result);
   end;
end;

function TGroupBlock.UnPinComments: integer;
begin
   result := 0;
   if Expanded then
      result := inherited UnPinComments;
end;

procedure TBlock.SetVisible(AVisible: boolean; ASetComments: boolean = true);
begin
   if Visible <> AVisible then
   begin
      if ASetComments then
      begin
         if AVisible then
            UnPinComments
         else
            PinComments;
      end;
      Visible := AVisible;
   end;
end;

function TBlock.ExportToXMLFile(const AFile: string): TErrorType;
begin
   result := TXMLProcessor.ExportToXMLFile(ExportToXMLTag, AFile);
end;

procedure TGroupBlock.SetVisible(AVisible: boolean; ASetComments: boolean = true);
begin
   inherited SetVisible(AVisible, Expanded);
end;

function TBlock.ProcessComments: boolean;
begin
   result := (FParentBlock = nil) or not FParentBlock.BlockImportMode;
end;

function TGroupBlock.RemoveBranch(AIndex: integer): boolean;
var
   lBranch: TBranch;
   obj: TObject;
begin
   result := false;
   lBranch := GetBranch(AIndex);
   if (lBranch <> nil) and (AIndex > FFixedBranches) then
   begin
      obj := nil;
      if (GClpbrd.UndoObject is TBlock) and (TBlock(GClpbrd.UndoObject).ParentBranch = lBranch) then
         obj := GClpbrd.UndoObject;
      if FBranchList.Remove(lBranch) <> -1 then
      begin
         obj.Free;
         AfterRemovingBranch;
         result := true;
      end;
   end;
end;

procedure TGroupBlock.AfterRemovingBranch;
begin
   ResizeWithDrawLock;
   NavigatorForm.Invalidate;
end;

procedure TGroupBlock.ExpandFold(AResize: boolean);
var
   tmpWidth, tmpHeight, i: integer;
   block: TBlock;
   textControl: TCustomEdit;
begin
   GProject.SetChanged;
   Expanded := not Expanded;
   textControl := GetTextControl;
   if textControl <> nil then
      textControl.Visible := Expanded;
   FMemoFolder.Visible := not Expanded;

   for i := PRIMARY_BRANCH_IDX to FBranchList.Count-1 do
   begin
      for block in FBranchList[i] do
          block.Visible := Expanded;
   end;

   if Expanded then
   begin
      tmpWidth := Width;
      tmpHeight := Height;
      Width := FFoldParms.Width;
      Height := FFoldParms.Height;
      FFoldParms.Width := tmpWidth;
      FFoldParms.Height := tmpHeight;
      BottomHook := FFoldParms.BottomHook;
      TopHook.X := FFoldParms.TopHook;
      BottomPoint.X := FFoldParms.BottomPoint.X;
      BottomPoint.Y := FFoldParms.BottomPoint.Y;
      Branch.Hook.X := FFoldParms.BranchPoint.X;
      IPoint.X := FFoldParms.IPoint.X;
      IPoint.Y := FFoldParms.IPoint.Y;
      Constraints.MinWidth := FInitParms.Width;
      Constraints.MinHeight := FInitParms.Height;
      RefreshStatements;
   end
   else
   begin
      if ProcessComments then
         PinComments;
      tmpWidth := FFoldParms.Width;
      tmpHeight := FFoldParms.Height;
      FFoldParms.Width := Width;
      FFoldParms.Height := Height;
      FFoldParms.BottomHook := BottomHook;
      FFoldParms.TopHook := TopHook.X;
      FFoldParms.BottomPoint.X := BottomPoint.X;
      FFoldParms.BottomPoint.Y := BottomPoint.Y;
      FFoldParms.BranchPoint.X := Branch.Hook.X;
      FFoldParms.IPoint.X := IPoint.X;
      FFoldParms.IPoint.Y := IPoint.Y;
      Constraints.MinWidth := 140;
      Constraints.MinHeight := 54;
      Width := tmpWidth;
      Height := tmpHeight;
      FMemoFolder.SetBounds(4, 4, Width-8, Height-36);
      FMemoFolder.Anchors := [akRight, akLeft, akBottom, akTop];
      BottomHook := Width div 2;
      BottomPoint.X := BottomHook;
      BottomPoint.Y := Height - 28;
      IPoint.X := BottomHook + 30;
      IPoint.Y := FMemoFolder.Height + 15;
      TopHook.X := BottomHook;
   end;

   if AResize and (FParentBlock <> nil) then
   begin
      FParentBlock.ResizeWithDrawLock;
      NavigatorForm.Invalidate;
   end;
   
   UnPinComments;
end;

procedure TGroupBlock.SaveInXML(ATag: IXMLElement);
var
   brx, fw, fh, i: integer;
   txt: string;
   tag1, tag2: IXMLElement;
   lBranch: TBranch;
   unPin: boolean;
   comment: TComment;
   block: TBlock;
begin
   SaveInXML2(ATag);
   if ATag <> nil then
   begin
      unPin := false;
      if Expanded then
      begin
         fw := FFoldParms.Width;
         fh := FFoldParms.Height;
         brx := Branch.Hook.X;
         unPin := PinComments > 0;
      end
      else
      begin
         fw := Width;
         fh := Height;
         brx := FFoldParms.BranchPoint.X;
         ATag.SetAttribute('h', FFoldParms.Height.ToString);
         ATag.SetAttribute('w', FFoldParms.Width.ToString);
         ATag.SetAttribute('bh', FFoldParms.BottomHook.ToString);
      end;

      try
         ATag.SetAttribute('brx', brx.ToString);
         ATag.SetAttribute('bry', Branch.Hook.Y.ToString);
         ATag.SetAttribute('fw', fw.ToString);
         ATag.SetAttribute('fh', fh.ToString);
         ATag.SetAttribute(FOLDED_ATTR, (not Expanded).ToString);

         txt := GetFoldedText;
         if not txt.IsEmpty then
         begin
            tag1 := ATag.OwnerDocument.CreateElement(FOLD_TEXT_ATTR);
            TXMLProcessor.AddCDATA(tag1, txt);
            ATag.AppendChild(tag1);
         end;

         for comment in GetPinComments do
            comment.ExportToXMLTag2(ATag);

         for i := PRIMARY_BRANCH_IDX to FBranchList.Count-1 do
         begin
            lBranch := FBranchList[i];

            tag2 := ATag.OwnerDocument.CreateElement(BRANCH_TAG);
            ATag.AppendChild(tag2);

            tag2.SetAttribute(ID_ATTR, lBranch.Id.ToString);

            if lBranch.Statement <> nil then
               tag2.SetAttribute(BRANCH_STMNT_ATTR, lBranch.Statement.Id.ToString);

            tag1 := ATag.OwnerDocument.CreateElement('x');
            TXMLProcessor.AddText(tag1, lBranch.hook.X.ToString);
            tag2.AppendChild(tag1);

            tag1 := ATag.OwnerDocument.CreateElement('y');
            TXMLProcessor.AddText(tag1, lBranch.hook.Y.ToString);
            tag2.AppendChild(tag1);

            for block in GetBlocks(i) do
                TXMLProcessor.ExportBlockToXML(block, tag2);
         end;
      finally
         if unPin then
            UnPinComments;
      end;
   end;
end;

procedure TBlock.SaveInXML(ATag: IXMLElement);
var
   comment: TComment;
begin
   SaveInXML2(ATag);
   if (ATag <> nil) and (PinComments > 0) then
   begin
      for comment in GetPinComments do
         comment.ExportToXMLTag2(ATag);
      UnPinComments;
   end;
end;

procedure TBlock.SaveInXML2(ATag: IXMLElement);
var
   txtControl: TCustomEdit;
   txt: string;
   tag: IXMLElement;
   memo: TMemoEx;
begin
   if ATag <> nil then
   begin
      ATag.SetAttribute(BLOCK_TYPE_ATTR, TRttiEnumerationType.GetName(BType));
      ATag.SetAttribute(FRAME_ATTR, FFrame.ToString);
      ATag.SetAttribute('x', Left.ToString);
      ATag.SetAttribute('y', Top.ToString);
      ATag.SetAttribute('h', Height.ToString);
      ATag.SetAttribute('w', Width.ToString);
      ATag.SetAttribute('bh', BottomHook.ToString);
      ATag.SetAttribute('brx', BottomPoint.X.ToString);
      ATag.SetAttribute(ID_ATTR, FId.ToString);
      memo := GetMemoEx;
      if memo <> nil then
         memo.SaveInXML(ATag);
      ATag.SetAttribute(FONT_SIZE_ATTR, Font.Size.ToString);
      ATag.SetAttribute(FONT_STYLE_ATTR, TInfra.EncodeFontStyle(Font.Style));
      txtControl := GetTextControl;
      if (txtControl <> nil) and (txtControl.Text <> '') then
      begin
         txt := ReplaceStr(txtControl.Text, sLineBreak, LB_PHOLDER);
         tag := ATag.OwnerDocument.CreateElement(TEXT_TAG);
         TXMLProcessor.AddCDATA(tag, txt);
         ATag.AppendChild(tag);
      end;
   end;
end;

procedure TBlock.ImportCommentsFromXML(ATag: IXMLElement);
var
   tag: IXMLElement;
   comment: TComment;
begin
   if ProcessComments then
   begin
      tag := TXMLProcessor.FindChildTag(ATag, COMMENT_ATTR);
      while tag <> nil do
      begin
         comment := TComment.CreateDefault(Page);
         comment.ImportFromXMLTag(tag, Self);
         tag := TXMLProcessor.FindNextTag(tag);
      end;
      UnPinComments;
   end;
end;

function TBlock.GetFromXML(ATag: IXMLElement): TErrorType;
var
   tag: IXMLElement;
   textControl: TCustomEdit;
   i: integer;
   memo: TMemoEx;
begin
   result := errNone;
   if ATag <> nil then
   begin
      tag := TXMLProcessor.FindChildTag(ATag, TEXT_TAG);
      textControl := GetTextControl;
      if (tag <> nil) and (textControl <> nil) then
      begin
         FRefreshMode := true;
         textControl.Text := ReplaceStr(tag.Text, LB_PHOLDER, sLineBreak);
         FRefreshMode := false;
      end;

      i := StrToIntDef(ATag.GetAttribute(FONT_SIZE_ATTR), GSettings.FlowchartFontSize);
      if i in FLOWCHART_VALID_FONT_SIZES then
         SetFontSize(i);

      i := StrToIntDef(ATag.GetAttribute(FONT_STYLE_ATTR), 0);
      SetFontStyle(TInfra.DecodeFontStyle(i));
      
      Frame := TXMLProcessor.GetBoolFromAttr(ATag, FRAME_ATTR);

      memo := GetMemoEx;
      if memo <> nil then
         memo.GetFromXML(ATag);

      ImportCommentsFromXML(ATag);
   end;
end;

function TGroupBlock.GetFromXML(ATag: IXMLElement): TErrorType;
var
   tag1, tag2: IXMLElement;
   bId, idx, bStmntId, hx, hy: integer;
begin
   result := inherited GetFromXML(ATag);
   if ATag <> nil then
   begin
      tag1 := TXMLProcessor.FindChildTag(ATag, BRANCH_TAG);
      if tag1 <> nil then
      begin
         idx := PRIMARY_BRANCH_IDX;
         repeat
            tag2 := TXMLProcessor.FindChildTag(tag1, 'x');
            if tag2 <> nil then
               hx := StrToIntDef(tag2.Text, 0);
            tag2 := TXMLProcessor.FindChildTag(tag1, 'y');
            if tag2 <> nil then
               hy := StrToIntDef(tag2.Text, 0);
            bId := StrToIntDef(tag1.GetAttribute(ID_ATTR), ID_INVALID);
            bStmntId := StrToIntDef(tag1.GetAttribute(BRANCH_STMNT_ATTR), ID_INVALID);
            if GetBranch(idx) = nil then
               AddBranch(Point(hx, hy), bId, bStmntId);
            tag2 := TXMLProcessor.FindChildTag(tag1, BLOCK_TAG);
            if tag2 <> nil then
            begin
               TXMLProcessor.ImportFlowchartFromXMLTag(tag2, Self, nil, result, idx);
               if result <> errNone then break;
            end;
            idx := idx + 1;
            tag1 := TXMLProcessor.FindNextTag(tag1);
         until tag1 = nil;
      end;
      tag2 := TXMLProcessor.FindChildTag(ATag, FOLD_TEXT_ATTR);
      if tag2 <> nil then
         SetFoldedText(tag2.Text);
      FFoldParms.Width := StrToIntDef(ATag.GetAttribute('fw'), 140);
      FFoldParms.Height := StrToIntDef(ATag.GetAttribute('fh'), 91);
      if TXMLProcessor.GetBoolFromAttr(ATag, FOLDED_ATTR) then
         ExpandFold(false);
   end;
end;

procedure TBlock.ExportToXMLTag(ATag: IXMLElement);
var
   block: TBlock;
begin
   TXMLProcessor.ExportBlockToXML(Self, ATag);
   block := Next;
   while (block <> nil) and block.Frame do
   begin
      TXMLProcessor.ExportBlockToXML(block, ATag);
      block := block.Next;
   end;
end;

function TBlock.ImportFromXMLTag(ATag: IXMLElement; ASelect: boolean = false): TErrorType;
var
   block, newBlock: TBlock;
   lParent: TGroupBlock;
   tag: IXMLElement;
   bt: TBlockType;
begin
   result := errValidate;
   tag := TXMLProcessor.FindChildTag(ATag, BLOCK_TAG);
   if tag <> nil then
      bt := TRttiEnumerationType.GetValue<TBlockType>(tag.GetAttribute(BLOCK_TYPE_ATTR));
   if (tag = nil) or (bt in [blMain, blUnknown]) then
      Gerr_text := i18Manager.GetString('BadImportTag')
   else
   begin
      lParent := nil;
      block := Self;
      if (Ired = 0) and (FParentBlock <> nil) then
         lParent := FParentBlock
      else if Self is TGroupBlock then
      begin
         lParent := TGroupBlock(Self);
         block := nil;
      end;
      if lParent <> nil then
      begin
         lParent.BlockImportMode := true;
         try
            newBlock := TXMLProcessor.ImportFlowchartFromXMLTag(tag, lParent, block, result, Ired);
         finally
            lParent.BlockImportMode := false;
         end;
         if result = errNone then
         begin
            lParent.ResizeWithDrawLock;
            newBlock.ImportCommentsFromXML(tag);
         end;
      end;
   end;
end;

procedure TBlock.PopulateComboBoxes;
begin
end;

function TBlock.GetExportFileName: string;
begin
   result := '';
end;

function TBlock.GetFocusColor: TColor;
var
   edit: TCustomEdit;
begin
   edit := GetTextControl;
   if (edit <> nil) and edit.HasParent then
      result := THackControl(edit).Font.Color
   else
      result := OK_COLOR;
end;

procedure TBlock.UpdateEditor(AEdit: TCustomEdit);
var
   chLine: TChangeLine;
begin
   if (AEdit <> nil) and PerformEditorUpdate then
   begin
      chLine := TInfra.GetChangeLine(Self, AEdit);
      if chLine.Row <> ROW_NOT_FOUND then
      begin
         chLine.Text := ReplaceStr(chLine.Text, PRIMARY_PLACEHOLDER, Trim(AEdit.Text));
         chLine.Text := TInfra.StripInstrEnd(chLine.Text);
         if GSettings.UpdateEditor and not SkipUpdateEditor then
            TInfra.ChangeLine(chLine);
         TInfra.GetEditorForm.SetCaretPos(chLine);
      end;
   end;
end;

function TBlock.PerformEditorUpdate: boolean;
begin
   result := TInfra.GetEditorForm.Visible and (not FRefreshMode) and not (fsStrikeOut in Font.Style);
end;

function TBlock.GetDescTemplate(const ALangId: string): string;
begin
   result := '';
end;

function TBlock.FillTemplate(const ALangId: string; const ATemplate: string = ''): string;
var
   textControl: TCustomEdit;
   s, template: string;
   lang: TLangDefinition;
begin
   result := '';
   template := '';
   if ATemplate.IsEmpty then
   begin
      lang := GInfra.GetLangDefinition(ALangId);
      if (lang <> nil) and not lang.GetTemplate(ClassType).IsEmpty then
         template := lang.GetTemplateExpr(ClassType);
   end
   else
      template := ATemplate;
   if not template.IsEmpty then
   begin
      textControl := GetTextControl;
      if textControl <> nil then
         s := Trim(textControl.Text)
      else
         s := '';
      result := ReplaceStr(template, PRIMARY_PLACEHOLDER, s);
   end
   else
      result := FillCodedTemplate(ALangId);
end;

function TBlock.FillCodedTemplate(const ALangId: string): string;
var
   textControl: TCustomEdit;
begin
   result := '';
   textControl := GetTextControl;
   if textControl <> nil then
      result := Trim(textControl.Text);
end;

procedure TBlock.ExportToGraphic(AGraphic: TGraphic);
var
   bitmap: TBitmap;
   comment: TComment;
   pnt: TPoint;
   lPage: TBlockTabSheet;
begin
   ClearSelection;
   if AGraphic is TBitmap then
      bitmap := TBitmap(AGraphic)
   else
      bitmap := TBitmap.Create;
   bitmap.Width := Width + 2;
   bitmap.Height := Height + 2;
   lPage := Page;
   lPage.DrawI := false;
   bitmap.Canvas.Lock;
   try
      PaintTo(bitmap.Canvas.Handle, 1, 1);
      for comment in GetComments do
      begin
         pnt := ParentToClient(comment.BoundsRect.TopLeft, lPage.Box);
         comment.PaintTo(bitmap.Canvas.Handle, pnt.X, pnt.Y);
      end;
   finally
      bitmap.Canvas.Unlock;
      lPage.DrawI := true;
   end;
   if AGraphic <> bitmap then
   begin
      AGraphic.Assign(bitmap);
      bitmap.Free;
   end;
end;

procedure TGroupBlock.PopulateComboBoxes;
var
   i: integer;
   block: TBlock;
begin
   inherited PopulateComboBoxes;
   for i := PRIMARY_BRANCH_IDX to FBranchList.Count-1 do
   begin
      for block in FBranchList[i] do
          block.PopulateComboBoxes;
   end;
end;

function TGroupBlock.GetBlocks(AIndex: integer = PRIMARY_BRANCH_IDX-1): IEnumerable<TBlock>;
var
   first, last, i, a: integer;
   block: TBlock;
   list: TList<TBlock>;
begin
   list := TList<TBlock>.Create;
   if GetBranch(AIndex) <> nil then
   begin
      first := AIndex;
      last := AIndex;
   end
   else if AIndex < PRIMARY_BRANCH_IDX then
   begin
      first := PRIMARY_BRANCH_IDX;
      last := FBranchList.Count - 1;
   end
   else
   begin
      first := 0;
      last := -1;
   end;
   a := 0;
   for i := first to last do
      a := a + FBranchList[i].Count;
   if list.Capacity < a then
      list.Capacity := a;
   for i := first to last do
   begin
      for block in FBranchList[i] do
          list.Add(block);
   end;
   result := TEnumeratorFactory<TBlock>.Create(list);
end;

function TBlock.SkipUpdateEditor: boolean;
var
   funcHeader: TUserFunctionHeader;
begin
   funcHeader := TInfra.GetFunctionHeader(Self);
   result := (funcHeader <> nil) and (TInfra.IsNOkColor(funcHeader.Font.Color) or (funcHeader.chkExternal.Checked and not GInfra.CurrentLang.CodeIncludeExternFunction));
end;

function TBlock.GenerateCode(ALines: TStringList; const ALangId: string; ADeep: integer; AFromLine: integer = LAST_LINE): integer;
var
   tmpList: TStringList;
begin
   if fsStrikeOut in Font.Style then
      Exit(0);
   tmpList := TStringList.Create;
   try
      GenerateDefaultTemplate(tmpList, ALangId, ADeep);
      TInfra.InsertLinesIntoList(ALines, tmpList, AFromLine);
      result := tmpList.Count;
   finally
      tmpList.Free;
   end;
end;

procedure TBlock.GenerateDefaultTemplate(ALines: TStringList; const ALangId: string; ADeep: integer);
var
   langDef: TLangDefinition;
   template, txt: string;
   textControl: TCustomEdit;
begin
   langDef := GInfra.GetLangDefinition(ALangId);
   if langDef <> nil then
   begin
      txt := '';
      textControl := GetTextControl;
      if textControl is TCustomMemo then
         txt := textControl.Text
      else if textControl <> nil then
         txt := Trim(textControl.Text);
      template := langDef.GetTemplate(Self.ClassType);
      if template.IsEmpty then
         template := PRIMARY_PLACEHOLDER;
      template := ReplaceStr(template, PRIMARY_PLACEHOLDER, txt);
      GenerateTemplateSection(ALines, template, ALangId, ADeep);
   end;
end;

function TGroupBlock.ExtractBranchIndex(const AStr: string): integer;
var
   i, b: integer;
   val: string;
begin
   result := Pos('%b', AStr);
   if result <> 0 then
   begin
      val := '';
      for i := result+2 to AStr.Length do
      begin
         if TryStrToInt(AStr[i], b) then
            val := val + AStr[i]
         else
            break;
      end;
      result := StrToIntDef(val, 0);
      if result >= FBranchList.Count then
         result := 0;
   end;
end;

procedure TBlock.GenerateTemplateSection(ALines: TStringList; const ATemplate: string; const ALangId: string; ADeep: integer);
var
   lines: TStringList;
begin
   lines := TStringList.Create;
   try
      lines.Text := ATemplate;
      GenerateTemplateSection(ALines, lines, ALangId, ADeep);
   finally
      lines.Free;
   end;
end;

procedure TBlock.GenerateTemplateSection(ALines: TStringList; ATemplate: TStringList; const ALangId: string; ADeep: integer);
var
   line: string;
   i: integer;
   obj: TObject;
begin
   i := ALines.Count + ATemplate.Count;
   if ALines.Capacity < i then
      ALines.Capacity := i;
   for i := 0 to ATemplate.Count-1 do
   begin
      line := DupeString(GSettings.IndentString, ADeep) + ATemplate[i];
      line := ReplaceStr(line, INDENT_XML_CHAR, GSettings.IndentString);
      line := TInfra.StripInstrEnd(line);
      obj := ATemplate.Objects[i];
      if obj = nil then
         obj := Self;
      ALines.AddObject(line, obj);
   end;
end;

procedure TGroupBlock.GenerateTemplateSection(ALines: TStringList; ATemplate: TStringList; const ALangId: string; ADeep: integer);

   function CountLeadIndentChars(const AString: string): integer;
   var
      i: integer;
   begin
      result := 0;
      for i := 1 to AString.Length do
      begin
         if AString[i] = INDENT_XML_CHAR then
            result := result + 1
         else
            break;
      end;
   end;

var
   i, b: integer;
   line: string;
   obj: TObject;
begin
   for i := 0 to ATemplate.Count-1 do
   begin
      b := ExtractBranchIndex(ATemplate[i]);
      if b > 0 then
      begin
         if (ALines.Count > 0) and (ALines.Objects[ALines.Count-1] = nil) then
            ALines.Objects[ALines.Count-1] := FBranchList[b];
         GenerateNestedCode(ALines, b, ADeep+CountLeadIndentChars(ATemplate[i]), ALangId);
      end
      else
      begin
         line := DupeString(GSettings.IndentString, ADeep) + ATemplate[i];
         line := ReplaceStr(line, INDENT_XML_CHAR, GSettings.IndentString);
         obj := ATemplate.Objects[i];
         if obj = nil then
            obj := Self;
         ALines.AddObject(line, obj);
      end;
   end;
end;

function TBlock.Next: TBlock;
var
   idx: integer;
begin
   result := nil;
   if FParentBranch <> nil then
   begin
      idx := FParentBranch.IndexOf(Self);
      if (idx <> -1) and (FParentBranch.Last <> Self) then
         result := FParentBranch.Items[idx+1];
   end;
end;

function TBlock.Prev: TBlock;
var
   idx: integer;
begin
   result := nil;
   if FParentBranch <> nil then
   begin
      idx := FParentBranch.IndexOf(Self);
      if idx > 0 then
         result := FParentBranch.Items[idx-1];
   end;
end;

constructor TBranch.Create(const AParent: TGroupBlock; const AHook: TPoint; const AId: integer = ID_INVALID);
begin
   inherited Create;
   FParentBlock := AParent;
   Hook := AHook;
   FRmvBlockIdx := -1;
   Statement := nil;
   FId := GProject.Register(Self, AId);
end;

destructor TBranch.Destroy;
var
   i: integer;
begin
   Statement.Free;
   for i := 0 to Count-1 do
      Items[i].Free;
   GProject.UnRegister(Self);
   inherited Destroy;
end;

function TBranch.GetMostRight: integer;
var
   i, br: integer;
begin
   result := Hook.X;
   for i := 0 to Count-1 do
   begin
      br := Items[i].BoundsRect.Right;
      if br > result then
         result := br;
   end;
end;

procedure TBranch.InsertAfter(ANewBlock, ABlock: TBlock);
begin
   Insert(IndexOf(ABlock)+1, ANewBlock);
end;

function TBranch.GetHeight: integer;
var
   i: integer;
begin
   result := 0;
   for i := 0 to Count-1 do
      Inc(result, Items[i].Height);
end;

function TBranch.FindInstanceOf(AClass: TClass): integer;
var
   i: integer;
begin
   result := -1;
   for i := 0 to Count-1 do
   begin
      if Items[i].ClassType = AClass then
      begin
         result := i;
         break;
      end;
   end;
end;

procedure TBranch.UndoRemove(ABlock: TBlock);
begin
   if (ABlock <> nil) and (Self = ABlock.ParentBranch) and (FRmvBlockIdx > -1) then
   begin
      Insert(FRmvBlockIdx, ABlock);
      FRmvBlockIdx := -1;
   end;
end;

function TBranch.Remove(ABlock: TBlock): integer;
begin
   result := inherited Remove(ABlock);
   FRmvBlockIdx := result;
end;

function TBranch.GetId: integer;
begin
   result := FId;
end;

function TBranch.QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
begin
   if GetInterface(IID, Obj) then
      result := 0
   else
      result := E_NOINTERFACE;
end;

function TBranch._AddRef: Integer; stdcall;    // no reference counting
begin
   result := -1;
end;

function TBranch._Release: Integer; stdcall;
begin
   result := -1;
end;

end.
