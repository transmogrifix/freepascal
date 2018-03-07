{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 2018 by Michael Van Canneyt

    Unit tests for Pascal-to-Javascript precompile class.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************

 Examples:
   ./testpas2js --suite=TTestPrecompile.TestPC_EmptyUnit
}
unit tcfiler;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry,
  PasTree, PScanner, PasResolver, PasResolveEval, PParser, PasUseAnalyzer,
  FPPas2Js, Pas2JsFiler,
  tcmodules, jstree;

type

  { TCustomTestPrecompile }

  TCustomTestPrecompile = Class(TCustomTestModule)
  private
    FAnalyzer: TPasAnalyzer;
    FInitialFlags: TPJUInitialFlags;
    FPJUReader: TPJUReader;
    FPJUWriter: TPJUWriter;
    FRestAnalyzer: TPasAnalyzer;
    procedure OnFilerGetSrc(Sender: TObject; aFilename: string; out p: PChar;
      out Count: integer);
    function OnConverterIsElementUsed(Sender: TObject; El: TPasElement): boolean;
    function OnConverterIsTypeInfoUsed(Sender: TObject; El: TPasElement): boolean;
    function OnRestConverterIsElementUsed(Sender: TObject; El: TPasElement): boolean;
    function OnRestConverterIsTypeInfoUsed(Sender: TObject; El: TPasElement): boolean;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    function CreateConverter: TPasToJSConverter; override;
    procedure ParseUnit; override;
    procedure WriteReadUnit; virtual;
    procedure StartParsing; override;
    function CheckRestoredObject(const Path: string; Orig, Rest: TObject): boolean; virtual;
    procedure CheckRestoredJS(const Path, Orig, Rest: string); virtual;
    // check restored parser+resolver
    procedure CheckRestoredResolver(Original, Restored: TPas2JSResolver); virtual;
    procedure CheckRestoredDeclarations(const Path: string; Orig, Rest: TPasDeclarations); virtual;
    procedure CheckRestoredSection(const Path: string; Orig, Rest: TPasSection); virtual;
    procedure CheckRestoredModule(const Path: string; Orig, Rest: TPasModule); virtual;
    procedure CheckRestoredScopeReference(const Path: string; Orig, Rest: TPasScope); virtual;
    procedure CheckRestoredElementBase(const Path: string; Orig, Rest: TPasElementBase); virtual;
    procedure CheckRestoredResolveData(const Path: string; Orig, Rest: TResolveData); virtual;
    procedure CheckRestoredPasScope(const Path: string; Orig, Rest: TPasScope); virtual;
    procedure CheckRestoredModuleScope(const Path: string; Orig, Rest: TPas2JSModuleScope); virtual;
    procedure CheckRestoredIdentifierScope(const Path: string; Orig, Rest: TPasIdentifierScope); virtual;
    procedure CheckRestoredSectionScope(const Path: string; Orig, Rest: TPasSectionScope); virtual;
    procedure CheckRestoredInitialFinalizationScope(const Path: string; Orig, Rest: TPas2JSInitialFinalizationScope); virtual;
    procedure CheckRestoredEnumTypeScope(const Path: string; Orig, Rest: TPasEnumTypeScope); virtual;
    procedure CheckRestoredRecordScope(const Path: string; Orig, Rest: TPasRecordScope); virtual;
    procedure CheckRestoredClassScope(const Path: string; Orig, Rest: TPas2JSClassScope); virtual;
    procedure CheckRestoredProcScope(const Path: string; Orig, Rest: TPas2JSProcedureScope); virtual;
    procedure CheckRestoredScopeRefs(const Path: string; Orig, Rest: TPasScopeReferences); virtual;
    procedure CheckRestoredPropertyScope(const Path: string; Orig, Rest: TPasPropertyScope); virtual;
    procedure CheckRestoredResolvedReference(const Path: string; Orig, Rest: TResolvedReference); virtual;
    procedure CheckRestoredEvalValue(const Path: string; Orig, Rest: TResEvalValue); virtual;
    procedure CheckRestoredCustomData(const Path: string; RestoredEl: TPasElement; Orig, Rest: TObject); virtual;
    procedure CheckRestoredReference(const Path: string; Orig, Rest: TPasElement); virtual;
    procedure CheckRestoredElOrRef(const Path: string; Orig, OrigProp, Rest, RestProp: TPasElement); virtual;
    procedure CheckRestoredAnalyzerElement(const Path: string; Orig, Rest: TPasElement); virtual;
    procedure CheckRestoredElement(const Path: string; Orig, Rest: TPasElement); virtual;
    procedure CheckRestoredElementList(const Path: string; Orig, Rest: TFPList); virtual;
    procedure CheckRestoredElRefList(const Path: string; OrigParent: TPasElement;
      Orig: TFPList; RestParent: TPasElement; Rest: TFPList; AllowInSitu: boolean); virtual;
    procedure CheckRestoredPasExpr(const Path: string; Orig, Rest: TPasExpr); virtual;
    procedure CheckRestoredUnaryExpr(const Path: string; Orig, Rest: TUnaryExpr); virtual;
    procedure CheckRestoredBinaryExpr(const Path: string; Orig, Rest: TBinaryExpr); virtual;
    procedure CheckRestoredPrimitiveExpr(const Path: string; Orig, Rest: TPrimitiveExpr); virtual;
    procedure CheckRestoredBoolConstExpr(const Path: string; Orig, Rest: TBoolConstExpr); virtual;
    procedure CheckRestoredParamsExpr(const Path: string; Orig, Rest: TParamsExpr); virtual;
    procedure CheckRestoredRecordValues(const Path: string; Orig, Rest: TRecordValues); virtual;
    procedure CheckRestoredPasExprArray(const Path: string; Orig, Rest: TPasExprArray); virtual;
    procedure CheckRestoredArrayValues(const Path: string; Orig, Rest: TArrayValues); virtual;
    procedure CheckRestoredResString(const Path: string; Orig, Rest: TPasResString); virtual;
    procedure CheckRestoredAliasType(const Path: string; Orig, Rest: TPasAliasType); virtual;
    procedure CheckRestoredPointerType(const Path: string; Orig, Rest: TPasPointerType); virtual;
    procedure CheckRestoredSpecializedType(const Path: string; Orig, Rest: TPasSpecializeType); virtual;
    procedure CheckRestoredInlineSpecializedExpr(const Path: string; Orig, Rest: TInlineSpecializeExpr); virtual;
    procedure CheckRestoredRangeType(const Path: string; Orig, Rest: TPasRangeType); virtual;
    procedure CheckRestoredArrayType(const Path: string; Orig, Rest: TPasArrayType); virtual;
    procedure CheckRestoredFileType(const Path: string; Orig, Rest: TPasFileType); virtual;
    procedure CheckRestoredEnumValue(const Path: string; Orig, Rest: TPasEnumValue); virtual;
    procedure CheckRestoredEnumType(const Path: string; Orig, Rest: TPasEnumType); virtual;
    procedure CheckRestoredSetType(const Path: string; Orig, Rest: TPasSetType); virtual;
    procedure CheckRestoredVariant(const Path: string; Orig, Rest: TPasVariant); virtual;
    procedure CheckRestoredRecordType(const Path: string; Orig, Rest: TPasRecordType); virtual;
    procedure CheckRestoredClassType(const Path: string; Orig, Rest: TPasClassType); virtual;
    procedure CheckRestoredArgument(const Path: string; Orig, Rest: TPasArgument); virtual;
    procedure CheckRestoredProcedureType(const Path: string; Orig, Rest: TPasProcedureType); virtual;
    procedure CheckRestoredResultElement(const Path: string; Orig, Rest: TPasResultElement); virtual;
    procedure CheckRestoredFunctionType(const Path: string; Orig, Rest: TPasFunctionType); virtual;
    procedure CheckRestoredStringType(const Path: string; Orig, Rest: TPasStringType); virtual;
    procedure CheckRestoredVariable(const Path: string; Orig, Rest: TPasVariable); virtual;
    procedure CheckRestoredExportSymbol(const Path: string; Orig, Rest: TPasExportSymbol); virtual;
    procedure CheckRestoredConst(const Path: string; Orig, Rest: TPasConst); virtual;
    procedure CheckRestoredProperty(const Path: string; Orig, Rest: TPasProperty); virtual;
    procedure CheckRestoredProcedure(const Path: string; Orig, Rest: TPasProcedure); virtual;
    procedure CheckRestoredOperator(const Path: string; Orig, Rest: TPasOperator); virtual;
  public
    property Analyzer: TPasAnalyzer read FAnalyzer;
    property RestAnalyzer: TPasAnalyzer read FRestAnalyzer;
    property PJUWriter: TPJUWriter read FPJUWriter write FPJUWriter;
    property PJUReader: TPJUReader read FPJUReader write FPJUReader;
    property InitialFlags: TPJUInitialFlags read FInitialFlags;
  end;

  { TTestPrecompile }

  TTestPrecompile = class(TCustomTestPrecompile)
  published
    procedure Test_Base256VLQ;
    procedure TestPC_EmptyUnit;

    procedure TestPC_Const;
    procedure TestPC_Var;
    procedure TestPC_Enum;
    procedure TestPC_Set;
    procedure TestPC_Record;
    procedure TestPC_JSValue;
    procedure TestPC_Proc;
    procedure TestPC_Proc_Nested;
    procedure TestPC_Proc_LocalConst;
    procedure TestPC_Proc_UTF8;
    procedure TestPC_Class;
    procedure TestPC_Initialization;
  end;

function CompareListOfProcScopeRef(Item1, Item2: Pointer): integer;

implementation

function CompareListOfProcScopeRef(Item1, Item2: Pointer): integer;
var
  Ref1: TPasScopeReference absolute Item1;
  Ref2: TPasScopeReference absolute Item2;
begin
  Result:=CompareText(Ref1.Element.Name,Ref2.Element.Name);
  if Result<>0 then exit;
  Result:=ComparePointer(Ref1.Element,Ref2.Element);
end;

{ TCustomTestPrecompile }

procedure TCustomTestPrecompile.OnFilerGetSrc(Sender: TObject;
  aFilename: string; out p: PChar; out Count: integer);
var
  i: Integer;
  aModule: TTestEnginePasResolver;
  Src: String;
begin
  for i:=0 to ResolverCount-1 do
    begin
    aModule:=Resolvers[i];
    if aModule.Filename<>aFilename then continue;
    Src:=aModule.Source;
    p:=PChar(Src);
    Count:=length(Src);
    end;
end;

function TCustomTestPrecompile.OnConverterIsElementUsed(Sender: TObject;
  El: TPasElement): boolean;
begin
  Result:=Analyzer.IsUsed(El);
end;

function TCustomTestPrecompile.OnConverterIsTypeInfoUsed(Sender: TObject;
  El: TPasElement): boolean;
begin
  Result:=Analyzer.IsTypeInfoUsed(El);
end;

function TCustomTestPrecompile.OnRestConverterIsElementUsed(Sender: TObject;
  El: TPasElement): boolean;
begin
  Result:=RestAnalyzer.IsUsed(El);
end;

function TCustomTestPrecompile.OnRestConverterIsTypeInfoUsed(Sender: TObject;
  El: TPasElement): boolean;
begin
  Result:=RestAnalyzer.IsTypeInfoUsed(El);
end;

procedure TCustomTestPrecompile.SetUp;
begin
  inherited SetUp;
  FInitialFlags:=TPJUInitialFlags.Create;
  FAnalyzer:=TPasAnalyzer.Create;
  Analyzer.Resolver:=Engine;
  Analyzer.Options:=Analyzer.Options+[paoImplReferences];
  Converter.OnIsElementUsed:=@OnConverterIsElementUsed;
  Converter.OnIsTypeInfoUsed:=@OnConverterIsTypeInfoUsed;
end;

procedure TCustomTestPrecompile.TearDown;
begin
  FreeAndNil(FAnalyzer);
  FreeAndNil(FPJUWriter);
  FreeAndNil(FPJUReader);
  FreeAndNil(FInitialFlags);
  inherited TearDown;
end;

function TCustomTestPrecompile.CreateConverter: TPasToJSConverter;
begin
  Result:=inherited CreateConverter;
  Result.Options:=Result.Options+[coStoreImplJS];
end;

procedure TCustomTestPrecompile.ParseUnit;
begin
  inherited ParseUnit;
  Analyzer.AnalyzeModule(Module);
end;

procedure TCustomTestPrecompile.WriteReadUnit;
var
  ms: TMemoryStream;
  PJU, RestJSSrc, OrigJSSrc: string;
  // restored classes:
  RestResolver: TTestEnginePasResolver;
  RestFileResolver: TFileResolver;
  RestScanner: TPascalScanner;
  RestParser: TPasParser;
  RestConverter: TPasToJSConverter;
  RestJSModule: TJSSourceElements;
begin
  ConvertUnit;

  FPJUWriter:=TPJUWriter.Create;
  FPJUReader:=TPJUReader.Create;
  ms:=TMemoryStream.Create;
  RestParser:=nil;
  RestScanner:=nil;
  RestResolver:=nil;
  RestFileResolver:=nil;
  RestConverter:=nil;
  RestJSModule:=nil;
  try
    try
      PJUWriter.OnGetSrc:=@OnFilerGetSrc;
      PJUWriter.WritePJU(Engine,Converter,InitialFlags,ms,false);
    except
      on E: Exception do
      begin
        {$IFDEF VerbosePas2JS}
        writeln('TCustomTestPrecompile.WriteReadUnit WRITE failed');
        {$ENDIF}
        Fail('Write failed('+E.ClassName+'): '+E.Message);
      end;
    end;

    try
      SetLength(PJU,ms.Size);
      System.Move(ms.Memory^,PJU[1],length(PJU));

      writeln('TCustomTestPrecompile.WriteReadUnit PJU START-----');
      writeln(PJU);
      writeln('TCustomTestPrecompile.WriteReadUnit PJU END-------');

      RestFileResolver:=TFileResolver.Create;
      RestScanner:=TPascalScanner.Create(RestFileResolver);
      InitScanner(RestScanner);
      RestResolver:=TTestEnginePasResolver.Create;
      RestResolver.Filename:=Engine.Filename;
      RestResolver.AddObjFPCBuiltInIdentifiers(btAllJSBaseTypes,bfAllJSBaseProcs);
      //RestResolver.OnFindUnit:=@OnPasResolverFindUnit;
      RestParser:=TPasParser.Create(RestScanner,RestFileResolver,RestResolver);
      RestParser.Options:=po_tcmodules;
      RestResolver.CurrentParser:=RestParser;
      ms.Position:=0;
      PJUReader.ReadPJU(RestResolver,ms);
    except
      on E: Exception do
      begin
        {$IFDEF VerbosePas2JS}
        writeln('TCustomTestPrecompile.WriteReadUnit READ failed');
        {$ENDIF}
        Fail('Read failed('+E.ClassName+'): '+E.Message);
      end;
    end;

    // analyze
    FRestAnalyzer:=TPasAnalyzer.Create;
    FRestAnalyzer.Resolver:=RestResolver;
    try
      RestAnalyzer.AnalyzeModule(RestResolver.RootElement);
    except
      on E: Exception do
      begin
        {$IFDEF VerbosePas2JS}
        writeln('TCustomTestPrecompile.WriteReadUnit ANALYZEMODULE failed');
        {$ENDIF}
        Fail('AnalyzeModule precompiled failed('+E.ClassName+'): '+E.Message);
      end;
    end;
    // check parser+resolver+analyzer
    CheckRestoredResolver(Engine,RestResolver);

    // convert using the precompiled procs
    RestConverter:=CreateConverter;
    RestConverter.OnIsElementUsed:=@OnRestConverterIsElementUsed;
    RestConverter.OnIsTypeInfoUsed:=@OnRestConverterIsTypeInfoUsed;
    try
      RestJSModule:=RestConverter.ConvertPasElement(RestResolver.RootElement,RestResolver) as TJSSourceElements;
    except
      on E: Exception do
      begin
        {$IFDEF VerbosePas2JS}
        writeln('TCustomTestPrecompile.WriteReadUnit CONVERTER failed');
        {$ENDIF}
        Fail('Convert precompiled failed('+E.ClassName+'): '+E.Message);
      end;
    end;

    OrigJSSrc:=JSToStr(JSModule);
    RestJSSrc:=JSToStr(RestJSModule);

    if OrigJSSrc<>RestJSSrc then
      begin
      writeln('TCustomTestPrecompile.WriteReadUnit OrigJSSrc:---------START');
      writeln(OrigJSSrc);
      writeln('TCustomTestPrecompile.WriteReadUnit OrigJSSrc:---------END');
      writeln('TCustomTestPrecompile.WriteReadUnit RestJSSrc:---------START');
      writeln(RestJSSrc);
      writeln('TCustomTestPrecompile.WriteReadUnit RestJSSrc:---------END');
      CheckDiff('WriteReadUnit JS diff',OrigJSSrc,RestJSSrc);
      end;

  finally
    RestJSModule.Free;
    RestConverter.Free;
    FreeAndNil(FRestAnalyzer);
    RestParser.Free;
    RestScanner.Free;
    RestResolver.Free; // free parser before resolver
    RestFileResolver.Free;
    ms.Free;
  end;
end;

procedure TCustomTestPrecompile.StartParsing;
begin
  inherited StartParsing;
  FInitialFlags.ParserOptions:=Parser.Options;
  FInitialFlags.ModeSwitches:=Scanner.CurrentModeSwitches;
  FInitialFlags.BoolSwitches:=Scanner.CurrentBoolSwitches;
  FInitialFlags.ConverterOptions:=Converter.Options;
  FInitialFlags.TargetPlatform:=Converter.TargetPlatform;
  FInitialFlags.TargetProcessor:=Converter.TargetProcessor;
  // ToDo: defines
end;

function TCustomTestPrecompile.CheckRestoredObject(const Path: string; Orig,
  Rest: TObject): boolean;
begin
  if Orig=nil then
    begin
    if Rest<>nil then
      Fail(Path+': Orig=nil Rest='+GetObjName(Rest));
    exit(false);
    end
  else if Rest=nil then
    Fail(Path+': Orig='+GetObjName(Orig)+' Rest=nil');
  if Orig.ClassType<>Rest.ClassType then
    Fail(Path+': Orig='+GetObjName(Orig)+' Rest='+GetObjName(Rest));
  Result:=true;
end;

procedure TCustomTestPrecompile.CheckRestoredJS(const Path, Orig, Rest: string);
var
  OrigList, RestList: TStringList;
  i: Integer;
begin
  if Orig=Rest then exit;
  writeln('TCustomTestPrecompile.CheckRestoredJS ORIG START--------------');
  writeln(Orig);
  writeln('TCustomTestPrecompile.CheckRestoredJS ORIG END----------------');
  writeln('TCustomTestPrecompile.CheckRestoredJS REST START--------------');
  writeln(Rest);
  writeln('TCustomTestPrecompile.CheckRestoredJS REST END----------------');
  OrigList:=TStringList.Create;
  RestList:=TStringList.Create;
  try
    OrigList.Text:=Orig;
    RestList.Text:=Rest;
    for i:=0 to OrigList.Count-1 do
      begin
      if i>=RestList.Count then
        Fail(Path+' missing: '+OrigList[i]);
      writeln('  ',i,': '+OrigList[i]);
      end;
    if OrigList.Count<RestList.Count then
      Fail(Path+' too much: '+RestList[OrigList.Count]);
 finally
    OrigList.Free;
    RestList.Free;
  end;
end;

procedure TCustomTestPrecompile.CheckRestoredResolver(Original,
  Restored: TPas2JSResolver);
begin
  AssertNotNull('CheckRestoredResolver Original',Original);
  AssertNotNull('CheckRestoredResolver Restored',Restored);
  if Original.ClassType<>Restored.ClassType then
    Fail('CheckRestoredResolver Original='+Original.ClassName+' Restored='+Restored.ClassName);
  CheckRestoredElement('RootElement',Original.RootElement,Restored.RootElement);
end;

procedure TCustomTestPrecompile.CheckRestoredDeclarations(const Path: string;
  Orig, Rest: TPasDeclarations);
var
  i: Integer;
  OrigDecl, RestDecl: TPasElement;
  SubPath: String;
begin
  for i:=0 to Orig.Declarations.Count-1 do
    begin
    OrigDecl:=TPasElement(Orig.Declarations[i]);
    if i>=Rest.Declarations.Count then
      AssertEquals(Path+'.Declarations.Count',Orig.Declarations.Count,Rest.Declarations.Count);
    RestDecl:=TPasElement(Rest.Declarations[i]);
    SubPath:=Path+'['+IntToStr(i)+']';
    if OrigDecl.Name<>'' then
      SubPath:=SubPath+'"'+OrigDecl.Name+'"'
    else
      SubPath:=SubPath+'?noname?';
    CheckRestoredElement(SubPath,OrigDecl,RestDecl);
    end;
  AssertEquals(Path+'.Declarations.Count',Orig.Declarations.Count,Rest.Declarations.Count);
end;

procedure TCustomTestPrecompile.CheckRestoredSection(const Path: string; Orig,
  Rest: TPasSection);
begin
  if length(Orig.UsesClause)>0 then
    ; // ToDo
  CheckRestoredDeclarations(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredModule(const Path: string; Orig,
  Rest: TPasModule);

  procedure CheckInitFinal(const Path: string; OrigBlock, RestBlock: TPasImplBlock);
  begin
    CheckRestoredObject(Path,OrigBlock,RestBlock);
    if OrigBlock=nil then exit;
    CheckRestoredCustomData(Path+'.CustomData',RestBlock,OrigBlock.CustomData,RestBlock.CustomData);
  end;

begin
  if not (Orig.CustomData is TPas2JSModuleScope) then
    Fail(Path+'.CustomData is not TPasModuleScope'+GetObjName(Orig.CustomData));

  CheckRestoredElement(Path+'.InterfaceSection',Orig.InterfaceSection,Rest.InterfaceSection);
  CheckRestoredElement(Path+'.ImplementationSection',Orig.ImplementationSection,Rest.ImplementationSection);
  if Orig is TPasProgram then
    CheckRestoredElement(Path+'.ProgramSection',TPasProgram(Orig).ProgramSection,TPasProgram(Rest).ProgramSection)
  else if Orig is TPasLibrary then
    CheckRestoredElement(Path+'.LibrarySection',TPasLibrary(Orig).LibrarySection,TPasLibrary(Rest).LibrarySection);

  CheckInitFinal(Path+'.InitializationSection',Orig.InitializationSection,Rest.InitializationSection);
  CheckInitFinal(Path+'.FnializationSection',Orig.FinalizationSection,Rest.FinalizationSection);
end;

procedure TCustomTestPrecompile.CheckRestoredScopeReference(const Path: string;
  Orig, Rest: TPasScope);
begin
  if not CheckRestoredObject(Path,Orig,Rest) then exit;
  CheckRestoredReference(Path+'.Element',Orig.Element,Rest.Element);
end;

procedure TCustomTestPrecompile.CheckRestoredElementBase(const Path: string;
  Orig, Rest: TPasElementBase);
begin
  CheckRestoredObject(Path+'.CustomData',Orig.CustomData,Rest.CustomData);
end;

procedure TCustomTestPrecompile.CheckRestoredResolveData(const Path: string;
  Orig, Rest: TResolveData);
begin
  CheckRestoredElementBase(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredPasScope(const Path: string; Orig,
  Rest: TPasScope);
begin
  CheckRestoredReference(Path+'.VisibilityContext',Orig.VisibilityContext,Rest.VisibilityContext);
  CheckRestoredResolveData(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredModuleScope(const Path: string;
  Orig, Rest: TPas2JSModuleScope);
begin
  AssertEquals(Path+'.FirstName',Orig.FirstName,Rest.FirstName);
  if Orig.Flags<>Rest.Flags then
    Fail(Path+'.Flags');
  if Orig.BoolSwitches<>Rest.BoolSwitches then
    Fail(Path+'.BoolSwitches');
  CheckRestoredReference(Path+'.AssertClass',Orig.AssertClass,Rest.AssertClass);
  CheckRestoredReference(Path+'.AssertDefConstructor',Orig.AssertDefConstructor,Rest.AssertDefConstructor);
  CheckRestoredReference(Path+'.AssertMsgConstructor',Orig.AssertMsgConstructor,Rest.AssertMsgConstructor);
  CheckRestoredReference(Path+'.RangeErrorClass',Orig.RangeErrorClass,Rest.RangeErrorClass);
  CheckRestoredReference(Path+'.RangeErrorConstructor',Orig.RangeErrorConstructor,Rest.RangeErrorConstructor);
  CheckRestoredPasScope(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredIdentifierScope(
  const Path: string; Orig, Rest: TPasIdentifierScope);
var
  OrigList: TFPList;
  i: Integer;
  OrigIdentifier, RestIdentifier: TPasIdentifier;
begin
  OrigList:=nil;
  try
    OrigList:=Orig.GetLocalIdentifiers;
    for i:=0 to OrigList.Count-1 do
    begin
      OrigIdentifier:=TPasIdentifier(OrigList[i]);
      RestIdentifier:=Rest.FindLocalIdentifier(OrigIdentifier.Identifier);
      if RestIdentifier=nil then
        Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Missing RestIdentifier Orig='+OrigIdentifier.Identifier);
      repeat
        AssertEquals(Path+'.Local.Identifier',OrigIdentifier.Identifier,RestIdentifier.Identifier);
        CheckRestoredReference(Path+'.Local',OrigIdentifier.Element,RestIdentifier.Element);
        if OrigIdentifier.Kind<>RestIdentifier.Kind then
          Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Orig='+PJUIdentifierKindNames[OrigIdentifier.Kind]+' Rest='+PJUIdentifierKindNames[RestIdentifier.Kind]);
        if OrigIdentifier.NextSameIdentifier=nil then
        begin
          if RestIdentifier.NextSameIdentifier<>nil then
            Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Too many RestIdentifier.NextSameIdentifier='+GetObjName(RestIdentifier.Element));
          break;
        end
        else begin
          if RestIdentifier.NextSameIdentifier=nil then
            Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Missing RestIdentifier.NextSameIdentifier Orig='+GetObjName(OrigIdentifier.NextSameIdentifier.Element));
        end;
        if CompareText(OrigIdentifier.Identifier,OrigIdentifier.NextSameIdentifier.Identifier)<>0 then
          Fail(Path+'.Local['+OrigIdentifier.Identifier+'] Cur.Identifier<>Next.Identifier '+OrigIdentifier.Identifier+'<>'+OrigIdentifier.NextSameIdentifier.Identifier);
        OrigIdentifier:=OrigIdentifier.NextSameIdentifier;
        RestIdentifier:=RestIdentifier.NextSameIdentifier;
      until false;
    end;
  finally
    OrigList.Free;
  end;
  CheckRestoredPasScope(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredSectionScope(const Path: string;
  Orig, Rest: TPasSectionScope);
var
  i: Integer;
  OrigUses, RestUses: TPasSectionScope;
begin
  AssertEquals(Path+' UsesScopes.Count',Orig.UsesScopes.Count,Rest.UsesScopes.Count);
  for i:=0 to Orig.UsesScopes.Count-1 do
    begin
    OrigUses:=TPasSectionScope(Orig.UsesScopes[i]);
    if not (TObject(Rest.UsesScopes[i]) is TPasSectionScope) then
      Fail(Path+'.UsesScopes['+IntToStr(i)+'] Rest='+GetObjName(TObject(Rest.UsesScopes[i])));
    RestUses:=TPasSectionScope(Rest.UsesScopes[i]);
    if OrigUses.ClassType<>RestUses.ClassType then
      Fail(Path+'.Uses['+IntToStr(i)+'] Orig='+GetObjName(OrigUses)+' Rest='+GetObjName(RestUses));
    CheckRestoredReference(Path+'.Uses['+IntToStr(i)+']',OrigUses.Element,RestUses.Element);
    end;
  AssertEquals(Path+'.Finished',Orig.Finished,Rest.Finished);
  CheckRestoredIdentifierScope(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredInitialFinalizationScope(
  const Path: string; Orig, Rest: TPas2JSInitialFinalizationScope);
begin
  CheckRestoredScopeRefs(Path+'.References',Orig.References,Rest.References);
  if Orig.JS<>Rest.JS then
    CheckRestoredJS(Path+'.JS',Orig.JS,Rest.JS);
end;

procedure TCustomTestPrecompile.CheckRestoredEnumTypeScope(const Path: string;
  Orig, Rest: TPasEnumTypeScope);
begin
  CheckRestoredElement(Path+'.CanonicalSet',Orig.CanonicalSet,Rest.CanonicalSet);
  CheckRestoredIdentifierScope(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredRecordScope(const Path: string;
  Orig, Rest: TPasRecordScope);
begin
  CheckRestoredIdentifierScope(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredClassScope(const Path: string;
  Orig, Rest: TPas2JSClassScope);
var
  i: Integer;
begin
  CheckRestoredScopeReference(Path+'.AncestorScope',Orig.AncestorScope,Rest.AncestorScope);
  CheckRestoredElement(Path+'.CanonicalClassOf',Orig.CanonicalClassOf,Rest.CanonicalClassOf);
  CheckRestoredReference(Path+'.DirectAncestor',Orig.DirectAncestor,Rest.DirectAncestor);
  CheckRestoredReference(Path+'.DefaultProperty',Orig.DefaultProperty,Rest.DefaultProperty);
  if Orig.Flags<>Rest.Flags then
    Fail(Path+'.Flags');
  AssertEquals(Path+'.AbstractProcs.length',length(Orig.AbstractProcs),length(Rest.AbstractProcs));
  for i:=0 to length(Orig.AbstractProcs)-1 do
    CheckRestoredReference(Path+'.AbstractProcs['+IntToStr(i)+']',Orig.AbstractProcs[i],Rest.AbstractProcs[i]);
  CheckRestoredReference(Path+'.NewInstanceFunction',Orig.NewInstanceFunction,Rest.NewInstanceFunction);

  CheckRestoredIdentifierScope(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredProcScope(const Path: string;
  Orig, Rest: TPas2JSProcedureScope);
var
  i: Integer;
begin
  CheckRestoredReference(Path+'.DeclarationProc',Orig.DeclarationProc,Rest.DeclarationProc);
  CheckRestoredReference(Path+'.ImplProc',Orig.ImplProc,Rest.ImplProc);
  CheckRestoredScopeRefs(Path+'.References',Orig.References,Rest.References);
  if Orig.BodyJS<>Rest.BodyJS then
    CheckRestoredJS(Path+'.BodyJS',Orig.BodyJS,Rest.BodyJS);

  CheckRestoredObject(Path+'.GlobalJS',Orig.GlobalJS,Rest.GlobalJS);
  if Orig.GlobalJS<>nil then
    begin
    for i:=0 to Orig.GlobalJS.Count-1 do
      begin
      if i>=Rest.GlobalJS.Count then
        Fail(Path+'.GlobalJS['+IntToStr(i)+'] missing: '+Orig.GlobalJS[i]);
      CheckRestoredJS(Path+'.GlobalJS['+IntToStr(i)+']',Orig.GlobalJS[i],Rest.GlobalJS[i]);
      end;
    if Orig.GlobalJS.Count<Rest.GlobalJS.Count then
      Fail(Path+'.GlobalJS['+IntToStr(i)+'] too much: '+Rest.GlobalJS[Orig.GlobalJS.Count]);
    end;

  if Rest.DeclarationProc=nil then
    begin
    AssertEquals(Path+'.ResultVarName',Orig.ResultVarName,Rest.ResultVarName);
    CheckRestoredReference(Path+'.OverriddenProc',Orig.OverriddenProc,Rest.OverriddenProc);

    CheckRestoredScopeReference(Path+'.ClassScope',Orig.ClassScope,Rest.ClassScope);
    CheckRestoredElement(Path+'.SelfArg',Orig.SelfArg,Rest.SelfArg);
    AssertEquals(Path+'.Mode',PJUModeSwitchNames[Orig.Mode],PJUModeSwitchNames[Rest.Mode]);
    if Orig.Flags<>Rest.Flags then
      Fail(Path+'.Flags');
    if Orig.BoolSwitches<>Rest.BoolSwitches then
      Fail(Path+'.BoolSwitches');

    CheckRestoredIdentifierScope(Path,Orig,Rest);
    end
  else
    begin
    // ImplProc
    end;
end;

procedure TCustomTestPrecompile.CheckRestoredScopeRefs(const Path: string;
  Orig, Rest: TPasScopeReferences);
var
  OrigList, RestList: TFPList;
  i: Integer;
  OrigRef, RestRef: TPasScopeReference;
begin
  CheckRestoredObject(Path,Orig,Rest);
  if Orig=nil then exit;
  OrigList:=nil;
  RestList:=nil;
  try
    OrigList:=Orig.GetList;
    RestList:=Rest.GetList;
    OrigList.Sort(@CompareListOfProcScopeRef);
    RestList.Sort(@CompareListOfProcScopeRef);
    for i:=0 to OrigList.Count-1 do
      begin
      OrigRef:=TPasScopeReference(OrigList[i]);
      if i>=RestList.Count then
        Fail(Path+'['+IntToStr(i)+'] Missing in Rest: "'+OrigRef.Element.Name+'"');
      RestRef:=TPasScopeReference(RestList[i]);
      CheckRestoredReference(Path+'['+IntToStr(i)+'].Name="'+OrigRef.Element.Name+'"',OrigRef.Element,RestRef.Element);
      if OrigRef.Access<>RestRef.Access then
        AssertEquals(Path+'['+IntToStr(i)+']"'+OrigRef.Element.Name+'".Access',
          PJUPSRefAccessNames[OrigRef.Access],PJUPSRefAccessNames[RestRef.Access]);
      end;
    if RestList.Count>OrigList.Count then
      begin
      i:=OrigList.Count;
      RestRef:=TPasScopeReference(RestList[i]);
      Fail(Path+'['+IntToStr(i)+'] Too many in Rest: "'+RestRef.Element.Name+'"');
      end;
  finally
    OrigList.Free;
    RestList.Free;
  end;
end;

procedure TCustomTestPrecompile.CheckRestoredPropertyScope(const Path: string;
  Orig, Rest: TPasPropertyScope);
begin
  CheckRestoredReference(Path+'.AncestorProp',Orig.AncestorProp,Rest.AncestorProp);
  CheckRestoredIdentifierScope(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredResolvedReference(
  const Path: string; Orig, Rest: TResolvedReference);
var
  C: TClass;
begin
  if Orig.Flags<>Rest.Flags then
    Fail(Path+'.Flags');
  if Orig.Access<>Rest.Access then
    AssertEquals(Path+'.Access',PJUResolvedRefAccessNames[Orig.Access],PJUResolvedRefAccessNames[Rest.Access]);
  if not CheckRestoredObject(Path+'.Context',Orig.Context,Rest.Context) then exit;
  if Orig.Context<>nil then
    begin
    C:=Orig.Context.ClassType;
    if C=TResolvedRefCtxConstructor then
      CheckRestoredReference(Path+'.Context[TResolvedRefCtxConstructor].Typ',
        TResolvedRefCtxConstructor(Orig.Context).Typ,
        TResolvedRefCtxConstructor(Rest.Context).Typ);
    end;
  CheckRestoredScopeReference(Path+'.WithExprScope',Orig.WithExprScope,Rest.WithExprScope);
  CheckRestoredReference(Path+'.Declaration',Orig.Declaration,Rest.Declaration);

  CheckRestoredResolveData(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredEvalValue(const Path: string;
  Orig, Rest: TResEvalValue);
var
  i: Integer;
begin
  if not CheckRestoredObject(Path,Orig,Rest) then exit;
  if Orig.Kind<>Rest.Kind then
    Fail(Path+'.Kind');
  if not CheckRestoredObject(Path+'.Element',Orig.Element,Rest.Element) then exit;
  CheckRestoredReference(Path+'.IdentEl',Orig.IdentEl,Rest.IdentEl);
  case Orig.Kind of
    revkNone: Fail(Path+'.Kind=revkNone');
    revkCustom: Fail(Path+'.Kind=revkNone');
    revkNil: ;
    revkBool: AssertEquals(Path+'.B',TResEvalBool(Orig).B,TResEvalBool(Rest).B);
    revkInt: AssertEquals(Path+'.Int',TResEvalInt(Orig).Int,TResEvalInt(Rest).Int);
    revkUInt:
      if TResEvalUInt(Orig).UInt<>TResEvalUInt(Rest).UInt then
        Fail(Path+'.UInt');
    revkFloat: AssertEquals(Path+'.FloatValue',TResEvalFloat(Orig).FloatValue,TResEvalFloat(Rest).FloatValue);
    revkString: AssertEquals(Path+'.S,Raw',TResEvalString(Orig).S,TResEvalString(Rest).S);
    revkUnicodeString: AssertEquals(Path+'.S,UTF16',String(TResEvalUTF16(Orig).S),String(TResEvalUTF16(Rest).S));
    revkEnum:
      begin
      AssertEquals(Path+'.Index',TResEvalEnum(Orig).Index,TResEvalEnum(Rest).Index);
      CheckRestoredReference(Path+'.ElType',TResEvalEnum(Orig).ElType,TResEvalEnum(Rest).ElType);
      end;
    revkRangeInt:
      begin
      if TResEvalRangeInt(Orig).ElKind<>TResEvalRangeInt(Rest).ElKind then
        Fail(Path+'.Int/ElKind');
      CheckRestoredReference(Path+'.Int/ElType',TResEvalRangeInt(Orig).ElType,TResEvalRangeInt(Rest).ElType);
      AssertEquals(Path+'.Int/RangeStart',TResEvalRangeInt(Orig).RangeStart,TResEvalRangeInt(Rest).RangeStart);
      AssertEquals(Path+'.Int/RangeEnd',TResEvalRangeInt(Orig).RangeEnd,TResEvalRangeInt(Rest).RangeEnd);
      end;
    revkRangeUInt:
      begin
      if TResEvalRangeUInt(Orig).RangeStart<>TResEvalRangeUInt(Rest).RangeStart then
        Fail(Path+'.UInt/RangeStart');
      if TResEvalRangeUInt(Orig).RangeEnd<>TResEvalRangeUInt(Rest).RangeEnd then
        Fail(Path+'.UInt/RangeEnd');
      end;
    revkSetOfInt:
      begin
      if TResEvalSet(Orig).ElKind<>TResEvalSet(Rest).ElKind then
        Fail(Path+'.SetInt/ElKind');
      CheckRestoredReference(Path+'.SetInt/ElType',TResEvalSet(Orig).ElType,TResEvalSet(Rest).ElType);
      AssertEquals(Path+'.SetInt/RangeStart',TResEvalSet(Orig).RangeStart,TResEvalSet(Rest).RangeStart);
      AssertEquals(Path+'.SetInt/RangeEnd',TResEvalSet(Orig).RangeEnd,TResEvalSet(Rest).RangeEnd);
      AssertEquals(Path+'.SetInt/length(Items)',length(TResEvalSet(Orig).Ranges),length(TResEvalSet(Rest).Ranges));
      for i:=0 to length(TResEvalSet(Orig).Ranges)-1 do
        begin
        AssertEquals(Path+'.SetInt/Items['+IntToStr(i)+'].RangeStart',
          TResEvalSet(Orig).Ranges[i].RangeStart,TResEvalSet(Rest).Ranges[i].RangeStart);
        AssertEquals(Path+'.SetInt/Items['+IntToStr(i)+'].RangeEnd',
          TResEvalSet(Orig).Ranges[i].RangeEnd,TResEvalSet(Rest).Ranges[i].RangeEnd);
        end;
      end;
  end;
end;

procedure TCustomTestPrecompile.CheckRestoredCustomData(const Path: string;
  RestoredEl: TPasElement; Orig, Rest: TObject);
var
  C: TClass;
begin
  if not CheckRestoredObject(Path,Orig,Rest) then exit;

  C:=Orig.ClassType;
  if C=TResolvedReference then
    CheckRestoredResolvedReference(Path+'[TResolvedReference]',TResolvedReference(Orig),TResolvedReference(Rest))
  else if C=TPas2JSModuleScope then
    CheckRestoredModuleScope(Path+'[TPas2JSModuleScope]',TPas2JSModuleScope(Orig),TPas2JSModuleScope(Rest))
  else if C=TPasSectionScope then
    CheckRestoredSectionScope(Path+'[TPasSectionScope]',TPasSectionScope(Orig),TPasSectionScope(Rest))
  else if C=TPas2JSInitialFinalizationScope then
    CheckRestoredInitialFinalizationScope(Path+'[TPas2JSInitialFinalizationScope]',TPas2JSInitialFinalizationScope(Orig),TPas2JSInitialFinalizationScope(Rest))
  else if C=TPasEnumTypeScope then
    CheckRestoredEnumTypeScope(Path+'[TPasEnumTypeScope]',TPasEnumTypeScope(Orig),TPasEnumTypeScope(Rest))
  else if C=TPasRecordScope then
    CheckRestoredRecordScope(Path+'[TPasRecordScope]',TPasRecordScope(Orig),TPasRecordScope(Rest))
  else if C=TPas2JSClassScope then
    CheckRestoredClassScope(Path+'[TPas2JSClassScope]',TPas2JSClassScope(Orig),TPas2JSClassScope(Rest))
  else if C=TPas2JSProcedureScope then
    CheckRestoredProcScope(Path+'[TPas2JSProcedureScope]',TPas2JSProcedureScope(Orig),TPas2JSProcedureScope(Rest))
  else if C=TPasPropertyScope then
    CheckRestoredPropertyScope(Path+'[TPasPropertyScope]',TPasPropertyScope(Orig),TPasPropertyScope(Rest))
  else if C.InheritsFrom(TResEvalValue) then
    CheckRestoredEvalValue(Path+'['+Orig.ClassName+']',TResEvalValue(Orig),TResEvalValue(Rest))
  else
    Fail(Path+': unknown CustomData "'+GetObjName(Orig)+'" El='+GetObjName(RestoredEl));
end;

procedure TCustomTestPrecompile.CheckRestoredReference(const Path: string;
  Orig, Rest: TPasElement);
begin
  if not CheckRestoredObject(Path,Orig,Rest) then exit;
  AssertEquals(Path+'.Name',Orig.Name,Rest.Name);

  if Orig is TPasUnresolvedSymbolRef then
    exit; // compiler types and procs are the same in every unit -> skip checking unit

  CheckRestoredReference(Path+'.Parent',Orig.Parent,Rest.Parent);
end;

procedure TCustomTestPrecompile.CheckRestoredElOrRef(const Path: string; Orig,
  OrigProp, Rest, RestProp: TPasElement);
begin
  if not CheckRestoredObject(Path,OrigProp,RestProp) then exit;
  if Orig<>OrigProp.Parent then
    begin
    if Rest=RestProp.Parent then
      Fail(Path+' Orig "'+GetObjName(OrigProp)+'" is reference Orig.Parent='+GetObjName(Orig)+', Rest "'+GetObjName(RestProp)+'" is insitu');
    CheckRestoredReference(Path,OrigProp,RestProp);
    end
  else
    CheckRestoredElement(Path,OrigProp,RestProp);
end;

procedure TCustomTestPrecompile.CheckRestoredAnalyzerElement(
  const Path: string; Orig, Rest: TPasElement);
var
  OrigUsed, RestUsed: TPAElement;
begin
  //writeln('TCustomTestPrecompile.CheckRestoredAnalyzerElement ',GetObjName(RestAnalyzer));
  if RestAnalyzer=nil then exit;
  OrigUsed:=Analyzer.FindUsedElement(Orig);
  //writeln('TCustomTestPrecompile.CheckRestoredAnalyzerElement ',GetObjName(Orig),'=',OrigUsed<>nil,' ',GetObjName(Rest),'=',RestAnalyzer.FindUsedElement(Rest)<>nil);
  if OrigUsed<>nil then
    begin
    RestUsed:=RestAnalyzer.FindUsedElement(Rest);
    if RestUsed=nil then
      Fail(Path+': used in OrigAnalyzer, but not used in RestAnalyzer');
    if OrigUsed.Access<>RestUsed.Access then
      AssertEquals(Path+'->Analyzer.Access',dbgs(OrigUsed.Access),dbgs(RestUsed.Access));
    end
  else if RestAnalyzer.IsUsed(Rest) then
    begin
    Fail(Path+': not used in OrigAnalyzer, but used in RestAnalyzer');
    end;
end;

procedure TCustomTestPrecompile.CheckRestoredElement(const Path: string; Orig,
  Rest: TPasElement);
var
  C: TClass;
  AModule: TPasModule;
begin
  if not CheckRestoredObject(Path,Orig,Rest) then exit;

  AModule:=Orig.GetModule;
  if AModule<>Module then
    Fail(Path+' wrong module: Orig='+GetObjName(AModule)+' '+GetObjName(Module));

  AssertEquals(Path+'.Name',Orig.Name,Rest.Name);
  AssertEquals(Path+'.SourceFilename',Orig.SourceFilename,Rest.SourceFilename);
  AssertEquals(Path+'.SourceLinenumber',Orig.SourceLinenumber,Rest.SourceLinenumber);
  //AssertEquals(Path+'.SourceEndLinenumber',Orig.SourceEndLinenumber,Rest.SourceEndLinenumber);
  if Orig.Visibility<>Rest.Visibility then
    Fail(Path+'.Visibility '+PJUMemberVisibilityNames[Orig.Visibility]+' '+PJUMemberVisibilityNames[Rest.Visibility]);
  if Orig.Hints<>Rest.Hints then
    Fail(Path+'.Hints');
  AssertEquals(Path+'.HintMessage',Orig.HintMessage,Rest.HintMessage);

  CheckRestoredReference(Path+'.Parent',Orig.Parent,Rest.Parent);

  CheckRestoredCustomData(Path+'.CustomData',Rest,Orig.CustomData,Rest.CustomData);

  C:=Orig.ClassType;
  if C=TUnaryExpr then
    CheckRestoredUnaryExpr(Path,TUnaryExpr(Orig),TUnaryExpr(Rest))
  else if C=TBinaryExpr then
    CheckRestoredBinaryExpr(Path,TBinaryExpr(Orig),TBinaryExpr(Rest))
  else if C=TPrimitiveExpr then
    CheckRestoredPrimitiveExpr(Path,TPrimitiveExpr(Orig),TPrimitiveExpr(Rest))
  else if C=TBoolConstExpr then
    CheckRestoredBoolConstExpr(Path,TBoolConstExpr(Orig),TBoolConstExpr(Rest))
  else if (C=TNilExpr)
      or (C=TInheritedExpr)
      or (C=TSelfExpr) then
    CheckRestoredPasExpr(Path,TPasExpr(Orig),TPasExpr(Rest))
  else if C=TParamsExpr then
    CheckRestoredParamsExpr(Path,TParamsExpr(Orig),TParamsExpr(Rest))
  else if C=TRecordValues then
    CheckRestoredRecordValues(Path,TRecordValues(Orig),TRecordValues(Rest))
  else if C=TArrayValues then
    CheckRestoredArrayValues(Path,TArrayValues(Orig),TArrayValues(Rest))
  // TPasDeclarations is a base class
  // TPasUsesUnit is checked in usesclause
  // TPasSection is a base class
  else if C=TPasResString then
    CheckRestoredResString(Path,TPasResString(Orig),TPasResString(Rest))
  // TPasType is a base clas
  else if (C=TPasAliasType)
      or (C=TPasTypeAliasType)
      or (C=TPasClassOfType) then
    CheckRestoredAliasType(Path,TPasAliasType(Orig),TPasAliasType(Rest))
  else if C=TPasPointerType then
    CheckRestoredPointerType(Path,TPasPointerType(Orig),TPasPointerType(Rest))
  else if C=TPasSpecializeType then
    CheckRestoredSpecializedType(Path,TPasSpecializeType(Orig),TPasSpecializeType(Rest))
  else if C=TInlineSpecializeExpr then
    CheckRestoredInlineSpecializedExpr(Path,TInlineSpecializeExpr(Orig),TInlineSpecializeExpr(Rest))
  else if C=TPasRangeType then
    CheckRestoredRangeType(Path,TPasRangeType(Orig),TPasRangeType(Rest))
  else if C=TPasArrayType then
    CheckRestoredArrayType(Path,TPasArrayType(Orig),TPasArrayType(Rest))
  else if C=TPasFileType then
    CheckRestoredFileType(Path,TPasFileType(Orig),TPasFileType(Rest))
  else if C=TPasEnumValue then
    CheckRestoredEnumValue(Path,TPasEnumValue(Orig),TPasEnumValue(Rest))
  else if C=TPasEnumType then
    CheckRestoredEnumType(Path,TPasEnumType(Orig),TPasEnumType(Rest))
  else if C=TPasSetType then
    CheckRestoredSetType(Path,TPasSetType(Orig),TPasSetType(Rest))
  else if C=TPasVariant then
    CheckRestoredVariant(Path,TPasVariant(Orig),TPasVariant(Rest))
  else if C=TPasRecordType then
    CheckRestoredRecordType(Path,TPasRecordType(Orig),TPasRecordType(Rest))
  else if C=TPasClassType then
    CheckRestoredClassType(Path,TPasClassType(Orig),TPasClassType(Rest))
  else if C=TPasArgument then
    CheckRestoredArgument(Path,TPasArgument(Orig),TPasArgument(Rest))
  else if C=TPasProcedureType then
    CheckRestoredProcedureType(Path,TPasProcedureType(Orig),TPasProcedureType(Rest))
  else if C=TPasResultElement then
    CheckRestoredResultElement(Path,TPasResultElement(Orig),TPasResultElement(Rest))
  else if C=TPasFunctionType then
    CheckRestoredFunctionType(Path,TPasFunctionType(Orig),TPasFunctionType(Rest))
  else if C=TPasStringType then
    CheckRestoredStringType(Path,TPasStringType(Orig),TPasStringType(Rest))
  else if C=TPasVariable then
    CheckRestoredVariable(Path,TPasVariable(Orig),TPasVariable(Rest))
  else if C=TPasExportSymbol then
    CheckRestoredExportSymbol(Path,TPasExportSymbol(Orig),TPasExportSymbol(Rest))
  else if C=TPasConst then
    CheckRestoredConst(Path,TPasConst(Orig),TPasConst(Rest))
  else if C=TPasProperty then
    CheckRestoredProperty(Path,TPasProperty(Orig),TPasProperty(Rest))
  else if (C=TPasProcedure)
      or (C=TPasFunction)
      or (C=TPasConstructor)
      or (C=TPasClassConstructor)
      or (C=TPasDestructor)
      or (C=TPasClassDestructor)
      or (C=TPasClassProcedure)
      or (C=TPasClassFunction)
      then
    CheckRestoredProcedure(Path,TPasProcedure(Orig),TPasProcedure(Rest))
  else if (C=TPasOperator)
      or (C=TPasClassOperator) then
    CheckRestoredOperator(Path,TPasOperator(Orig),TPasOperator(Rest))
  else if (C=TPasModule)
        or (C=TPasProgram)
        or (C=TPasLibrary) then
    CheckRestoredModule(Path,TPasModule(Orig),TPasModule(Rest))
  else if C.InheritsFrom(TPasSection) then
    CheckRestoredSection(Path,TPasSection(Orig),TPasSection(Rest))
  else
    Fail(Path+': unknown class '+C.ClassName);

  CheckRestoredAnalyzerElement(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredElementList(const Path: string;
  Orig, Rest: TFPList);
var
  OrigItem, RestItem: TObject;
  i: Integer;
  SubPath: String;
begin
  if not CheckRestoredObject(Path,Orig,Rest) then exit;
  AssertEquals(Path+'.Count',Orig.Count,Rest.Count);
  for i:=0 to Orig.Count-1 do
    begin
    SubPath:=Path+'['+IntToStr(i)+']';
    OrigItem:=TObject(Orig[i]);
    if not (OrigItem is TPasElement) then
      Fail(SubPath+' Orig='+GetObjName(OrigItem));
    RestItem:=TObject(Rest[i]);
    if not (RestItem is TPasElement) then
      Fail(SubPath+' Rest='+GetObjName(RestItem));
    CheckRestoredElement(SubPath,TPasElement(OrigItem),TPasElement(RestItem));
    end;
end;

procedure TCustomTestPrecompile.CheckRestoredElRefList(const Path: string;
  OrigParent: TPasElement; Orig: TFPList; RestParent: TPasElement;
  Rest: TFPList; AllowInSitu: boolean);
var
  OrigItem, RestItem: TObject;
  i: Integer;
  SubPath: String;
begin
  if not CheckRestoredObject(Path,Orig,Rest) then exit;
  AssertEquals(Path+'.Count',Orig.Count,Rest.Count);
  for i:=0 to Orig.Count-1 do
    begin
    SubPath:=Path+'['+IntToStr(i)+']';
    OrigItem:=TObject(Orig[i]);
    if not (OrigItem is TPasElement) then
      Fail(SubPath+' Orig='+GetObjName(OrigItem));
    RestItem:=TObject(Rest[i]);
    if not (RestItem is TPasElement) then
      Fail(SubPath+' Rest='+GetObjName(RestItem));
    if AllowInSitu then
      CheckRestoredElOrRef(SubPath,OrigParent,TPasElement(OrigItem),RestParent,TPasElement(RestItem))
    else
      CheckRestoredReference(SubPath,TPasElement(OrigItem),TPasElement(RestItem));
    end;
end;

procedure TCustomTestPrecompile.CheckRestoredPasExpr(const Path: string; Orig,
  Rest: TPasExpr);
begin
  if Orig.Kind<>Rest.Kind then
    Fail(Path+'.Kind');
  if Orig.OpCode<>Rest.OpCode then
    Fail(Path+'.OpCode');
  CheckRestoredElement(Path+'.Format1',Orig.format1,Rest.format1);
  CheckRestoredElement(Path+'.Format2',Orig.format2,Rest.format2);
end;

procedure TCustomTestPrecompile.CheckRestoredUnaryExpr(const Path: string;
  Orig, Rest: TUnaryExpr);
begin
  CheckRestoredElement(Path+'.Operand',Orig.Operand,Rest.Operand);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredBinaryExpr(const Path: string;
  Orig, Rest: TBinaryExpr);
begin
  CheckRestoredElement(Path+'.left',Orig.left,Rest.left);
  CheckRestoredElement(Path+'.right',Orig.right,Rest.right);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredPrimitiveExpr(const Path: string;
  Orig, Rest: TPrimitiveExpr);
begin
  AssertEquals(Path+'.Value',Orig.Value,Rest.Value);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredBoolConstExpr(const Path: string;
  Orig, Rest: TBoolConstExpr);
begin
  AssertEquals(Path+'.Value',Orig.Value,Rest.Value);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredParamsExpr(const Path: string;
  Orig, Rest: TParamsExpr);
begin
  CheckRestoredElement(Path+'.Value',Orig.Value,Rest.Value);
  CheckRestoredPasExprArray(Path+'.Params',Orig.Params,Rest.Params);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredRecordValues(const Path: string;
  Orig, Rest: TRecordValues);
var
  i: Integer;
begin
  AssertEquals(Path+'.Fields.length',length(Orig.Fields),length(Rest.Fields));
  for i:=0 to length(Orig.Fields)-1 do
    begin
    AssertEquals(Path+'.Field['+IntToStr(i)+'].Name',Orig.Fields[i].Name,Rest.Fields[i].Name);
    CheckRestoredElement(Path+'.Field['+IntToStr(i)+'].ValueExp',Orig.Fields[i].ValueExp,Rest.Fields[i].ValueExp);
    end;
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredPasExprArray(const Path: string;
  Orig, Rest: TPasExprArray);
var
  i: Integer;
begin
  AssertEquals(Path+'.length',length(Orig),length(Rest));
  for i:=0 to length(Orig)-1 do
    CheckRestoredElement(Path+'['+IntToStr(i)+']',Orig[i],Rest[i]);
end;

procedure TCustomTestPrecompile.CheckRestoredArrayValues(const Path: string;
  Orig, Rest: TArrayValues);
begin
  CheckRestoredPasExprArray(Path+'.Values',Orig.Values,Rest.Values);
  CheckRestoredPasExpr(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredResString(const Path: string;
  Orig, Rest: TPasResString);
begin
  CheckRestoredElement(Path+'.Expr',Orig.Expr,Rest.Expr);
end;

procedure TCustomTestPrecompile.CheckRestoredAliasType(const Path: string;
  Orig, Rest: TPasAliasType);
begin
  CheckRestoredElOrRef(Path+'.DestType',Orig,Orig.DestType,Rest,Rest.DestType);
  CheckRestoredElement(Path+'.Expr',Orig.Expr,Rest.Expr);
end;

procedure TCustomTestPrecompile.CheckRestoredPointerType(const Path: string;
  Orig, Rest: TPasPointerType);
begin
  CheckRestoredElOrRef(Path+'.DestType',Orig,Orig.DestType,Rest,Rest.DestType);
end;

procedure TCustomTestPrecompile.CheckRestoredSpecializedType(
  const Path: string; Orig, Rest: TPasSpecializeType);
begin
  CheckRestoredElementList(Path+'.Params',Orig.Params,Rest.Params);
  CheckRestoredElOrRef(Path+'.DestType',Orig,Orig.DestType,Rest,Rest.DestType);
end;

procedure TCustomTestPrecompile.CheckRestoredInlineSpecializedExpr(
  const Path: string; Orig, Rest: TInlineSpecializeExpr);
begin
  CheckRestoredElOrRef(Path+'.DestType',Orig,Orig.DestType,Rest,Rest.DestType);
end;

procedure TCustomTestPrecompile.CheckRestoredRangeType(const Path: string;
  Orig, Rest: TPasRangeType);
begin
  CheckRestoredElement(Path+'.RangeExpr',Orig.RangeExpr,Rest.RangeExpr);
end;

procedure TCustomTestPrecompile.CheckRestoredArrayType(const Path: string;
  Orig, Rest: TPasArrayType);
begin
  CheckRestoredPasExprArray(Path+'.Ranges',Orig.Ranges,Rest.Ranges);
  if Orig.PackMode<>Rest.PackMode then
    Fail(Path+'.PackMode Orig='+PJUPackModeNames[Orig.PackMode]+' Rest='+PJUPackModeNames[Rest.PackMode]);
  CheckRestoredElOrRef(Path+'.ElType',Orig,Orig.ElType,Rest,Rest.ElType);
end;

procedure TCustomTestPrecompile.CheckRestoredFileType(const Path: string; Orig,
  Rest: TPasFileType);
begin
  CheckRestoredElOrRef(Path+'.ElType',Orig,Orig.ElType,Rest,Rest.ElType);
end;

procedure TCustomTestPrecompile.CheckRestoredEnumValue(const Path: string;
  Orig, Rest: TPasEnumValue);
begin
  CheckRestoredElement(Path+'.Value',Orig.Value,Rest.Value);
end;

procedure TCustomTestPrecompile.CheckRestoredEnumType(const Path: string; Orig,
  Rest: TPasEnumType);
begin
  CheckRestoredElementList(Path+'.Values',Orig.Values,Rest.Values);
end;

procedure TCustomTestPrecompile.CheckRestoredSetType(const Path: string; Orig,
  Rest: TPasSetType);
begin
  CheckRestoredElOrRef(Path+'.EnumType',Orig,Orig.EnumType,Rest,Rest.EnumType);
  AssertEquals(Path+'.IsPacked',Orig.IsPacked,Rest.IsPacked);
end;

procedure TCustomTestPrecompile.CheckRestoredVariant(const Path: string; Orig,
  Rest: TPasVariant);
begin
  CheckRestoredElementList(Path+'.Values',Orig.Values,Rest.Values);
  CheckRestoredElement(Path+'.Members',Orig.Members,Rest.Members);
end;

procedure TCustomTestPrecompile.CheckRestoredRecordType(const Path: string;
  Orig, Rest: TPasRecordType);
begin
  if Orig.PackMode<>Rest.PackMode then
    Fail(Path+'.PackMode Orig='+PJUPackModeNames[Orig.PackMode]+' Rest='+PJUPackModeNames[Rest.PackMode]);
  CheckRestoredElementList(Path+'.Members',Orig.Members,Rest.Members);
  CheckRestoredElOrRef(Path+'.VariantEl',Orig,Orig.VariantEl,Rest,Rest.VariantEl);
  CheckRestoredElementList(Path+'.Variants',Orig.Variants,Rest.Variants);
  CheckRestoredElementList(Path+'.GenericTemplateTypes',Orig.GenericTemplateTypes,Rest.GenericTemplateTypes);
end;

procedure TCustomTestPrecompile.CheckRestoredClassType(const Path: string;
  Orig, Rest: TPasClassType);
begin
  if Orig.PackMode<>Rest.PackMode then
    Fail(Path+'.PackMode Orig='+PJUPackModeNames[Orig.PackMode]+' Rest='+PJUPackModeNames[Rest.PackMode]);
  if Orig.ObjKind<>Rest.ObjKind then
    Fail(Path+'.ObjKind Orig='+PJUObjKindNames[Orig.ObjKind]+' Rest='+PJUObjKindNames[Rest.ObjKind]);
  CheckRestoredReference(Path+'.AncestorType',Orig.AncestorType,Rest.AncestorType);
  CheckRestoredReference(Path+'.HelperForType',Orig.HelperForType,Rest.HelperForType);
  AssertEquals(Path+'.IsForward',Orig.IsForward,Rest.IsForward);
  AssertEquals(Path+'.IsExternal',Orig.IsExternal,Rest.IsExternal);
  // irrelevant: IsShortDefinition
  CheckRestoredElement(Path+'.GUIDExpr',Orig.GUIDExpr,Rest.GUIDExpr);
  CheckRestoredElementList(Path+'.Members',Orig.Members,Rest.Members);
  AssertEquals(Path+'.Modifiers',Orig.Modifiers.Text,Rest.Modifiers.Text);
  CheckRestoredElRefList(Path+'.Interfaces',Orig,Orig.Interfaces,Rest,Rest.Interfaces,false);
  CheckRestoredElementList(Path+'.GenericTemplateTypes',Orig.GenericTemplateTypes,Rest.GenericTemplateTypes);
  AssertEquals(Path+'.ExternalNameSpace',Orig.ExternalNameSpace,Rest.ExternalNameSpace);
  AssertEquals(Path+'.ExternalName',Orig.ExternalName,Rest.ExternalName);
end;

procedure TCustomTestPrecompile.CheckRestoredArgument(const Path: string; Orig,
  Rest: TPasArgument);
begin
  if Orig.Access<>Rest.Access then
    Fail(Path+'.Access Orig='+PJUArgumentAccessNames[Orig.Access]+' Rest='+PJUArgumentAccessNames[Rest.Access]);
  CheckRestoredElOrRef(Path+'.ArgType',Orig,Orig.ArgType,Rest,Rest.ArgType);
  CheckRestoredElement(Path+'.ValueExpr',Orig.ValueExpr,Rest.ValueExpr);
end;

procedure TCustomTestPrecompile.CheckRestoredProcedureType(const Path: string;
  Orig, Rest: TPasProcedureType);
begin
  CheckRestoredElementList(Path+'.Args',Orig.Args,Rest.Args);
  if Orig.CallingConvention<>Rest.CallingConvention then
    Fail(Path+'.CallingConvention Orig='+PJUCallingConventionNames[Orig.CallingConvention]+' Rest='+PJUCallingConventionNames[Rest.CallingConvention]);
  if Orig.Modifiers<>Rest.Modifiers then
    Fail(Path+'.Modifiers');
end;

procedure TCustomTestPrecompile.CheckRestoredResultElement(const Path: string;
  Orig, Rest: TPasResultElement);
begin
  CheckRestoredElOrRef(Path+'.ResultType',Orig,Orig.ResultType,Rest,Rest.ResultType);
end;

procedure TCustomTestPrecompile.CheckRestoredFunctionType(const Path: string;
  Orig, Rest: TPasFunctionType);
begin
  CheckRestoredElement(Path+'.ResultEl',Orig.ResultEl,Rest.ResultEl);
  CheckRestoredProcedureType(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredStringType(const Path: string;
  Orig, Rest: TPasStringType);
begin
  AssertEquals(Path+'.LengthExpr',Orig.LengthExpr,Rest.LengthExpr);
end;

procedure TCustomTestPrecompile.CheckRestoredVariable(const Path: string; Orig,
  Rest: TPasVariable);
begin
  CheckRestoredElOrRef(Path+'.VarType',Orig,Orig.VarType,Rest,Rest.VarType);
  if Orig.VarModifiers<>Rest.VarModifiers then
    Fail(Path+'.VarModifiers');
  CheckRestoredElement(Path+'.LibraryName',Orig.LibraryName,Rest.LibraryName);
  CheckRestoredElement(Path+'.ExportName',Orig.ExportName,Rest.ExportName);
  CheckRestoredElement(Path+'.AbsoluteExpr',Orig.AbsoluteExpr,Rest.AbsoluteExpr);
  CheckRestoredElement(Path+'.Expr',Orig.Expr,Rest.Expr);
end;

procedure TCustomTestPrecompile.CheckRestoredExportSymbol(const Path: string;
  Orig, Rest: TPasExportSymbol);
begin
  CheckRestoredElement(Path+'.ExportName',Orig.ExportName,Rest.ExportName);
  CheckRestoredElement(Path+'.ExportIndex',Orig.ExportIndex,Rest.ExportIndex);
end;

procedure TCustomTestPrecompile.CheckRestoredConst(const Path: string; Orig,
  Rest: TPasConst);
begin
  AssertEquals(Path+'.IsConst',Orig.IsConst,Rest.IsConst);
  CheckRestoredVariable(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredProperty(const Path: string; Orig,
  Rest: TPasProperty);
begin
  CheckRestoredElement(Path+'.IndexExpr',Orig.IndexExpr,Rest.IndexExpr);
  CheckRestoredElement(Path+'.ReadAccessor',Orig.ReadAccessor,Rest.ReadAccessor);
  CheckRestoredElement(Path+'.WriteAccessor',Orig.WriteAccessor,Rest.WriteAccessor);
  CheckRestoredElement(Path+'.ImplementsFunc',Orig.ImplementsFunc,Rest.ImplementsFunc);
  CheckRestoredElement(Path+'.DispIDExpr',Orig.DispIDExpr,Rest.DispIDExpr);
  CheckRestoredElement(Path+'.StoredAccessor',Orig.StoredAccessor,Rest.StoredAccessor);
  CheckRestoredElement(Path+'.DefaultExpr',Orig.DefaultExpr,Rest.DefaultExpr);
  CheckRestoredElementList(Path+'.Args',Orig.Args,Rest.Args);
  // not needed: ReadAccessorName, WriteAccessorName, ImplementsName, StoredAccessorName
  AssertEquals(Path+'.DispIDReadOnly',Orig.DispIDReadOnly,Rest.DispIDReadOnly);
  AssertEquals(Path+'.IsDefault',Orig.IsDefault,Rest.IsDefault);
  AssertEquals(Path+'.IsNodefault',Orig.IsNodefault,Rest.IsNodefault);
  CheckRestoredVariable(Path,Orig,Rest);
end;

procedure TCustomTestPrecompile.CheckRestoredProcedure(const Path: string;
  Orig, Rest: TPasProcedure);
var
  RestScope, OrigScope: TPas2JSProcedureScope;
begin
  CheckRestoredObject(Path+'.CustomData',Orig.CustomData,Rest.CustomData);
  OrigScope:=Orig.CustomData as TPas2JSProcedureScope;
  RestScope:=Rest.CustomData as TPas2JSProcedureScope;
  CheckRestoredReference(Path+'.CustomData[TPas2JSProcedureScope].DeclarationProc',
    OrigScope.DeclarationProc,RestScope.DeclarationProc);
  if RestScope.DeclarationProc=nil then
    begin
    CheckRestoredElement(Path+'.ProcType',Orig.ProcType,Rest.ProcType);
    CheckRestoredElement(Path+'.PublicName',Orig.PublicName,Rest.PublicName);
    CheckRestoredElement(Path+'.LibrarySymbolName',Orig.LibrarySymbolName,Rest.LibrarySymbolName);
    CheckRestoredElement(Path+'.LibraryExpr',Orig.LibraryExpr,Rest.LibraryExpr);
    CheckRestoredElement(Path+'.DispIDExpr',Orig.DispIDExpr,Rest.DispIDExpr);
    AssertEquals(Path+'.AliasName',Orig.AliasName,Rest.AliasName);
    if Orig.Modifiers<>Rest.Modifiers then
      Fail(Path+'.Modifiers');
    AssertEquals(Path+'.MessageName',Orig.MessageName,Rest.MessageName);
    if Orig.MessageType<>Rest.MessageType then
      Fail(Path+'.MessageType Orig='+PJUProcedureMessageTypeNames[Orig.MessageType]+' Rest='+PJUProcedureMessageTypeNames[Rest.MessageType]);
    end
  else
    begin
    // ImplProc
    end;
  // ToDo: Body
end;

procedure TCustomTestPrecompile.CheckRestoredOperator(const Path: string; Orig,
  Rest: TPasOperator);
begin
  if Orig.OperatorType<>Rest.OperatorType then
    Fail(Path+'.OperatorType Orig='+PJUOperatorTypeNames[Orig.OperatorType]+' Rest='+PJUOperatorTypeNames[Rest.OperatorType]);
  AssertEquals(Path+'.TokenBased',Orig.TokenBased,Rest.TokenBased);
  CheckRestoredProcedure(Path,Orig,Rest);
end;

{ TTestPrecompile }

procedure TTestPrecompile.Test_Base256VLQ;

  procedure Test(i: MaxPrecInt);
  var
    s: String;
    p: PByte;
    j: NativeInt;
  begin
    s:=EncodeVLQ(i);
    p:=PByte(s);
    j:=DecodeVLQ(p);
    if i<>j then
      Fail('Encode/DecodeVLQ OrigIndex='+IntToStr(i)+' Code="'+s+'" NewIndex='+IntToStr(j));
  end;

  procedure TestStr(i: MaxPrecInt; Expected: string);
  var
    Actual: String;
  begin
    Actual:=EncodeVLQ(i);
    AssertEquals('EncodeVLQ('+IntToStr(i)+')',Expected,Actual);
  end;

var
  i: Integer;
begin
  TestStr(0,#0);
  TestStr(1,#2);
  TestStr(-1,#3);
  for i:=-8200 to 8200 do
    Test(i);
  Test(High(MaxPrecInt));
  Test(High(MaxPrecInt)-1);
  Test(Low(MaxPrecInt)+2);
  Test(Low(MaxPrecInt)+1);
  //Test(Low(MaxPrecInt)); such a high number is not needed by pastojs
end;

procedure TTestPrecompile.TestPC_EmptyUnit;
begin
  StartUnit(false);
  Add([
  'interface',
  'implementation']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Const;
begin
  StartUnit(false);
  Add([
  'interface',
  'const',
  '  Three = 3;',
  '  FourPlusFive: longint = 4+5 deprecated ''deprtext'';',
  '  Four: byte = +6-2*2 platform;',
  '  Affirmative = true;',
  '  Negative = false;', // bool lit
  '  NotNegative = not Negative;', // boolconst
  '  UnaryMinus = -3;', // unary minus
  '  FloatA = -31.678E-012;', // float lit
  '  HighInt = High(longint);', // func params, built-in function
  '  s = ''abc'';', // string lit
  '  c: char = s[1];', // array params
  '  a: array[1..2] of longint = (3,4);', // anonymous array, range, array values
  'resourcestring',
  '  rs = ''rs'';',
  'implementation']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Var;
begin
  StartUnit(false);
  Add([
  'interface',
  'var',
  '  FourPlusFive: longint = 4+5 deprecated ''deprtext'';',
  '  e: double external name ''Math.e'';',
  '  AnoArr: array of longint = (1,2,3);',
  '  s: string = ''aaaäö'';',
  '  s2: string = ''😊'';', // 1F60A
  'implementation']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Enum;
begin
  StartUnit(false);
  Add([
  'interface',
  'type',
  '  TEnum = (red,green,blue);',
  '  TEnumRg = green..blue;',
  '  TArrOfEnum = array of TEnum;',
  '  TArrOfEnumRg = array of TEnumRg;',
  '  TArrEnumOfInt = array[TEnum] of longint;',
  'var',
  '  HighEnum: TEnum = high(TEnum);',
  'implementation']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Set;
begin
  StartUnit(false);
  Add([
  'interface',
  'type',
  '  TEnum = (red,green,blue);',
  '  TEnumRg = green..blue;',
  '  TEnumAlias = TEnum;', // alias
  '  TSetOfEnum = set of TEnum;',
  '  TSetOfAnoEnum = set of TEnum;', // anonymous enumtype
  '  TSetOfEnumRg = set of TEnumRg;',
  'var',
  '  Empty: TSetOfEnum = [];', // empty set lit
  '  All: TSetOfEnum = [low(TEnum)..pred(high(TEnum)),high(TEnum)];', // full set lit, range in set
  'implementation']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Record;
begin
  StartUnit(false);
  Add([
  'interface',
  'type',
  '  TRec = record',
  '    i: longint;',
  '    s: string;',
  '  end;',
  '  P = pointer;', // alias type to built-in type
  '  TArrOfRec = array of TRec;',
  'var',
  '  r: TRec;', // full set lit, range in set
  'implementation']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_JSValue;
begin
  StartUnit(false);
  Add([
  'interface',
  'var',
  '  p: pointer = nil;', // pointer, nil lit
  '  js: jsvalue = 13 div 4;', // jsvalue
  'implementation']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Proc;
begin
  StartUnit(false);
  Add([
  'interface',
  '  function Abs(d: double): double; external name ''Math.Abs'';',
  '  function GetIt(d: double): double;',
  'implementation',
  'var k: double;',
  'function GetIt(d: double): double;',
  'var j: double;',
  'begin',
  '  j:=Abs(d+k);',
  '  Result:=j;',
  'end;',
  'procedure NotUsed;',
  'begin',
  'end;',
  '']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Proc_Nested;
begin
  StartUnit(false);
  Add([
  'interface',
  '  function GetIt(d: longint): longint;',
  'implementation',
  'var k: double;',
  'function GetIt(d: longint): longint;',
  'var j: double;',
  '  function GetSum(a,b: longint): longint; forward;',
  '  function GetMul(a,b: longint): longint; ',
  '  begin',
  '    Result:=a*b;',
  '  end;',
  '  function GetSum(a,b: longint): longint;',
  '  begin',
  '    Result:=a+b;',
  '  end;',
  '  procedure NotUsed;',
  '  begin',
  '  end;',
  'begin',
  '  Result:=GetMul(GetSum(d,2),3);',
  'end;',
  'procedure NotUsed;',
  'begin',
  'end;',
  '']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Proc_LocalConst;
begin
  StartUnit(false);
  Add([
  'interface',
  '  function GetIt(d: double): double;',
  'implementation',
  'function GetIt(d: double): double;',
  'const',
  '  c: double = 3.3;',
  '  e: double = 2.7;', // e is not used
  'begin',
  '  Result:=d+c;',
  'end;',
  '']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Proc_UTF8;
begin
  StartUnit(false);
  Add([
  'interface',
  '  function DoIt: string;',
  'implementation',
  'function DoIt: string;',
  'const',
  '  c = ''äöü😊'';',
  'begin',
  '  Result:=''ÄÖÜ😊''+c;',
  'end;',
  '']);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Class;
begin
  StartUnit(false);
  Add([
  'interface',
  'type',
  '  TObject = class',
  '  protected',
  '    FInt: longint;',
  '    procedure SetInt(Value: longint); virtual; abstract;',
  '  public',
  '    property Int: longint read FInt write SetInt default 3;',
  '  end;',
  '  TBird = class',
  '  protected',
  '    procedure SetInt(Value: longint); override;',
  '  published',
  '    property Int;',
  '  end;',
  'var',
  '  o: tobject;',
  'implementation',
  'procedure TBird.SetInt(Value: longint);',
  'begin',
  'end;'
  ]);
  WriteReadUnit;
end;

procedure TTestPrecompile.TestPC_Initialization;
begin
  StartUnit(false);
  Add([
  'interface',
  'implementation',
  'type',
  '  TCaption = string;',
  '  TRec = record h: string; end;',
  'var',
  '  s: TCaption;',
  '  r: TRec;',
  'initialization',
  '  s:=''ö😊'';',
  '  r.h:=''Ä😊'';',
  'end.',
  '']);
  WriteReadUnit;
end;

Initialization
  RegisterTests([TTestPrecompile]);
end.

