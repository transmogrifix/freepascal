{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 2018 by Michael Van Canneyt

    Unit tests for Pascal-to-Javascript converter class.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************

 Examples:
    ./testpas2js --suite=TTestModule.TestEmptyProgram
    ./testpas2js --suite=TTestModule.TestEmptyUnit
}
unit tcunitsearch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs,
  fpcunit, testregistry,
  Pas2jsFileUtils, Pas2jsCompiler, Pas2jsFileCache, Pas2jsLogger,
  tcmodules, PScanner;

type

  { TTestCompiler }

  TTestCompiler = class(TPas2jsCompiler)
  private
    FExitCode: longint;
  protected
    function GetExitCode: Longint; override;
    procedure SetExitCode(Value: Longint); override;
  end;

  { TCLIFile }

  TCLIFile = class
  public
    Filename: string;
    Source: string;
    Age: TPas2jsFileAgeTime;
    Attr: TPas2jsFileAttr;
    constructor Create(const aFilename, Src: string; aAge: TPas2jsFileAgeTime;
       aAttr: TPas2jsFileAttr);
  end;

  { TCLILogMsg }

  TCLILogMsg = class
  public
    Msg: string;
    MsgTxt: string;
    MsgType: TMessageType;
    MsgNumber: integer;
    MsgFile: string;
    MsgLine: integer;
    MsgCol: integer;
  end;

  { TCustomTestCLI }

  TCustomTestCLI = class(TTestCase)
  private
    FErrorCol: integer;
    FErrorFile: string;
    FErrorLine: integer;
    FErrorMsg: string;
    FErrorNumber: integer;
    FWorkDir: string;
    FCompilerExe: string;
    FCompiler: TTestCompiler;
    FDefaultFileAge: longint;
    FFiles: TObjectList; // list of TCLIFile
    FLogMsgs: TObjectList; // list ot TCLILogMsg
    FParams: TStringList;
    function GetExitCode: integer;
    function GetFiles(Index: integer): TCLIFile;
    function GetLogMsgs(Index: integer): TCLILogMsg;
    procedure SetExitCode(const AValue: integer);
    procedure SetWorkDir(const AValue: string);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure DoLog(Sender: TObject; const Msg: String);
    Function OnReadDirectory(Dir: TPas2jsCachedDirectory): boolean; virtual;
    Function OnReadFile(aFilename: string; var aSource: string): boolean; virtual;
    procedure OnWriteFile(aFilename: string; Source: string);
    procedure WriteSources;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Compile(const Args: array of string; ExpectedExitCode: longint = 0);
    property Compiler: TTestCompiler read FCompiler;
    property CompilerExe: string read FCompilerExe write FCompilerExe;
    property Params: TStringList read FParams;
    property Files[Index: integer]: TCLIFile read GetFiles; // files an directories
    function FileCount: integer;
    function FindFile(Filename: string): TCLIFile; // files and directories
    function ExpandFilename(const Filename: string): string;
    function AddFile(Filename, Source: string): TCLIFile;
    function AddFile(Filename: string; const SourceLines: array of string): TCLIFile;
    function AddUnit(Filename: string; const Intf, Impl: array of string): TCLIFile;
    function AddDir(Filename: string): TCLIFile;
    property WorkDir: string read FWorkDir write SetWorkDir;
    property DefaultFileAge: longint read FDefaultFileAge write FDefaultFileAge;
    property ExitCode: integer read GetExitCode write SetExitCode;
    property LogMsgs[Index: integer]: TCLILogMsg read GetLogMsgs;
    function GetLogCount: integer;
    property ErrorMsg: string read FErrorMsg write FErrorMsg;
    property ErrorFile: string read FErrorFile write FErrorFile;
    property ErrorLine: integer read FErrorLine write FErrorLine;
    property ErrorCol: integer read FErrorCol write FErrorCol;
    property ErrorNumber: integer read FErrorNumber write FErrorNumber;
  end;

  { TTestCLI_UnitSearch }

  TTestCLI_UnitSearch = class(TCustomTestCLI)
  published
    procedure TestUS_Program;
    procedure TestUS_UsesEmptyFileFail;

    procedure TestUS_UsesInFile;
    procedure TestUS_UsesInFile_Duplicate;
    procedure TestUS_UsesInFile_IndirectDuplicate;
  end;

function LinesToStr(const Lines: array of string): string;

implementation

function LinesToStr(const Lines: array of string): string;
var
  i: Integer;
begin
  Result:='';
  for i:=low(Lines) to high(Lines) do
    Result:=Result+Lines[i]+LineEnding;
end;

{ TCLIFile }

constructor TCLIFile.Create(const aFilename, Src: string;
  aAge: TPas2jsFileAgeTime; aAttr: TPas2jsFileAttr);
begin
  Filename:=aFilename;
  Source:=Src;
  Age:=aAge;
  Attr:=aAttr;
end;

{ TTestCompiler }

function TTestCompiler.GetExitCode: Longint;
begin
  Result:=FExitCode;
end;

procedure TTestCompiler.SetExitCode(Value: Longint);
begin
  FExitCode:=Value;
end;

{ TCustomTestCLI }

function TCustomTestCLI.GetFiles(Index: integer): TCLIFile;
begin
  Result:=TCLIFile(FFiles[Index]);
end;

function TCustomTestCLI.GetExitCode: integer;
begin
  Result:=Compiler.ExitCode;
end;

function TCustomTestCLI.GetLogMsgs(Index: integer): TCLILogMsg;
begin
  Result:=TCLILogMsg(FLogMsgs[Index]);
end;

procedure TCustomTestCLI.SetExitCode(const AValue: integer);
begin
  Compiler.ExitCode:=AValue;
end;

procedure TCustomTestCLI.SetWorkDir(const AValue: string);
var
  NewValue: String;
begin
  NewValue:=IncludeTrailingPathDelimiter(ResolveDots(AValue));
  if FWorkDir=NewValue then Exit;
  FWorkDir:=NewValue;
end;

procedure TCustomTestCLI.SetUp;
begin
  inherited SetUp;
  FDefaultFileAge:=DateTimeToFileDate(Now);
  {$IFDEF Windows}
  BaseDir:='P:\pascal\test';
  CompilerExe:='P:\pascal\bin\pas2js.exe';
  {$ELSE}
  WorkDir:='/home/user';
  CompilerExe:='/usr/bin/pas2js';
  {$ENDIF}
  FCompiler:=TTestCompiler.Create;
  Compiler.Log.OnLog:=@DoLog;
  Compiler.FileCache.DirectoryCache.OnReadDirectory:=@OnReadDirectory;
  Compiler.FileCache.OnReadFile:=@OnReadFile;
  Compiler.FileCache.OnWriteFile:=@OnWriteFile;
end;

procedure TCustomTestCLI.TearDown;
begin
  FreeAndNil(FCompiler);
  FParams.Clear;
  FFiles.Clear;
  FLogMsgs.Clear;
  FErrorMsg:='';
  FErrorFile:='';
  FErrorLine:=0;
  FErrorCol:=0;
  FErrorNumber:=0;
  inherited TearDown;
end;

procedure TCustomTestCLI.DoLog(Sender: TObject; const Msg: String);
var
  LogMsg: TCLILogMsg;
begin
  {$IFDEF VerbosePasResolver}
  writeln('TCustomTestCLI.DoLog ',Msg,' File=',Compiler.Log.LastMsgFile,' Line=',Compiler.Log.LastMsgLine);
  {$ENDIF}
  LogMsg:=TCLILogMsg.Create;
  LogMsg.Msg:=Msg;
  LogMsg.MsgTxt:=Compiler.Log.LastMsgTxt;
  LogMsg.MsgType:=Compiler.Log.LastMsgType;
  LogMsg.MsgFile:=Compiler.Log.LastMsgFile;
  LogMsg.MsgLine:=Compiler.Log.LastMsgLine;
  LogMsg.MsgCol:=Compiler.Log.LastMsgCol;
  LogMsg.MsgNumber:=Compiler.Log.LastMsgNumber;
  FLogMsgs.Add(LogMsg);
  if (LogMsg.MsgType<=mtError) then
  begin
    if (ErrorFile='')
        or ((ErrorLine<1) and (LogMsg.MsgLine>0)) then
    begin
      ErrorMsg:=LogMsg.MsgTxt;
      ErrorFile:=LogMsg.MsgFile;
      ErrorLine:=LogMsg.MsgLine;
      ErrorCol:=LogMsg.MsgCol;
    end;
  end;
end;

function TCustomTestCLI.OnReadDirectory(Dir: TPas2jsCachedDirectory): boolean;
var
  i: Integer;
  aFile: TCLIFile;
  Path: String;
begin
  Path:=Dir.Path;
  //writeln('TCustomTestCLI.ReadDirectory START ',Path,' ',Dir.Count);
  Dir.Add('.',DefaultFileAge,faDirectory,4096);
  Dir.Add('..',DefaultFileAge,faDirectory,4096);
  for i:=0 to FileCount-1 do
    begin
    aFile:=Files[i];
    if CompareFilenames(ExtractFilePath(aFile.Filename),Path)<>0 then continue;
    //writeln('TCustomTestCLI.ReadDirectory ',aFile.Filename);
    Dir.Add(ExtractFileName(aFile.Filename),aFile.Age,aFile.Attr,length(aFile.Source));
    end;
  //writeln('TCustomTestCLI.ReadDirectory END ',Path,' ',Dir.Count);
  Result:=true;
end;

function TCustomTestCLI.OnReadFile(aFilename: string; var aSource: string
  ): boolean;
var
  aFile: TCLIFile;
begin
  aFile:=FindFile(aFilename);
  //writeln('TCustomTestCLI.ReadFile ',aFilename,' Found=',aFile<>nil);
  if aFile=nil then exit(false);
  if (faDirectory and aFile.Attr)>0 then
  begin
    {$IFDEF VerbosePasResolver}
    writeln('[20180224000557] TCustomTestCLI.OnReadFile ',aFilename);
    {$ENDIF}
    EPas2jsFileCache.Create('TCustomTestCLI.OnReadFile: reading directory '+aFilename);
  end;
  aSource:=aFile.Source;
  Result:=true;
end;

procedure TCustomTestCLI.OnWriteFile(aFilename: string; Source: string);
var
  aFile: TCLIFile;
begin
  aFile:=FindFile(aFilename);
  {$IFDEF VerbosePasResolver}
  writeln('TCustomTestCLI.WriteFile ',aFilename,' Found=',aFile<>nil);
  {$ENDIF}
  if aFile<>nil then
  begin
    if faDirectory and aFile.Attr>0 then
    begin
      {$IFDEF VerbosePasResolver}
      writeln('[20180223175616] TCustomTestCLI.OnWriteFile ',aFilename);
      {$ENDIF}
      raise EPas2jsFileCache.Create('unable to write file to directory "'+aFilename+'"');
    end;
  end else
  begin
    aFile:=TCLIFile.Create(aFilename,'',0,0);
    FFiles.Add(aFile);
  end;
  aFile.Source:=Source;
  aFile.Attr:=faDirectory;
  aFile.Age:=DateTimeToFileDate(Now);
end;

procedure TCustomTestCLI.WriteSources;
var
  i, j, aRow, aCol: Integer;
  aFile: TCLIFile;
  SrcLines: TStringList;
  Line, aFilename: String;
  IsSrc: Boolean;
begin
  writeln('TCustomTestCLI.WriteSources START');
  aFilename:=ErrorFile;
  aRow:=ErrorLine;
  aCol:=ErrorCol;
  SrcLines:=TStringList.Create;
  try
    for i:=0 to FileCount-1 do
    begin
      aFile:=Files[i];
      if (faDirectory and aFile.Attr)>0 then continue;
      writeln('Testcode:-File="',aFile.Filename,'"----------------------------------:');
      SrcLines.Text:=aFile.Source;
      IsSrc:=ExtractFilename(aFile.Filename)=ExtractFileName(aFilename);
      for j:=1 to SrcLines.Count do
        begin
        Line:=SrcLines[j-1];
        if IsSrc and (j=aRow) then
          begin
          write('*');
          Line:=LeftStr(Line,aCol-1)+'|'+copy(Line,aCol,length(Line));
          end;
        writeln(Format('%:4d: ',[j]),Line);
        end;
    end;
  finally
    SrcLines.Free;
  end;
end;

constructor TCustomTestCLI.Create;
begin
  inherited Create;
  FFiles:=TObjectList.Create(true);
  FLogMsgs:=TObjectList.Create(true);
  FParams:=TStringList.Create;
end;

destructor TCustomTestCLI.Destroy;
begin
  FreeAndNil(FFiles);
  FreeAndNil(FLogMsgs);
  FreeAndNil(FParams);
  inherited Destroy;
end;

procedure TCustomTestCLI.Compile(const Args: array of string;
  ExpectedExitCode: longint);
var
  i: Integer;
begin
  AssertEquals('Initial System.ExitCode',0,system.ExitCode);
  for i:=low(Args) to High(Args) do
    Params.Add(Args[i]);
  try
    try
      //writeln('TCustomTestCLI.Compile WorkDir=',WorkDir);
      Compiler.Run(CompilerExe,WorkDir,Params,false);
    except
      on E: ECompilerTerminate do
      begin
        {$IFDEF VerbosePasResolver}
        writeln('TCustomTestCLI.Compile ',E.ClassName,':',E.Message);
        {$ENDIF}
      end;
      on E: Exception do
      begin
        {$IFDEF VerbosePasResolver}
        writeln('TCustomTestCLI.Compile ',E.ClassName,':',E.Message);
        {$ENDIF}
        Fail('TCustomTestCLI.Compile '+E.ClassName+':'+E.Message);
      end;
    end;
  finally
    Compiler.Log.CloseOutputFile;
  end;

  if ExpectedExitCode<>ExitCode then
  begin
    WriteSources;
    AssertEquals('ExitCode',ExpectedExitCode,ExitCode);
  end;
end;

function TCustomTestCLI.FileCount: integer;
begin
  Result:=FFiles.Count;
end;

function TCustomTestCLI.FindFile(Filename: string): TCLIFile;
var
  i: Integer;
begin
  Filename:=ExpandFilename(Filename);
  for i:=0 to FileCount-1 do
    if CompareFilenames(Files[i].Filename,Filename)=0 then
      exit(Files[i]);
  Result:=nil;
end;

function TCustomTestCLI.ExpandFilename(const Filename: string): string;
begin
  Result:=SetDirSeparators(Filename);
  if not FilenameIsAbsolute(Result) then
    Result:=WorkDir+Result;
  Result:=ResolveDots(Result);
end;

function TCustomTestCLI.AddFile(Filename, Source: string): TCLIFile;
begin
  Filename:=ExpandFilename(Filename);
  Result:=FindFile(Filename);
  if Result<>nil then
    raise Exception.Create('[20180224001050] TCustomTestCLI.AddFile already exists: '+Filename);
  FFiles.Add(TCLIFile.Create(Filename,Source,DefaultFileAge,faNormal));
  AddDir(ExtractFilePath(Filename));
end;

function TCustomTestCLI.AddFile(Filename: string;
  const SourceLines: array of string): TCLIFile;
begin
  Result:=AddFile(Filename,LinesToStr(SourceLines));
end;

function TCustomTestCLI.AddUnit(Filename: string; const Intf,
  Impl: array of string): TCLIFile;
var
  Name: String;
begin
  Name:=ExtractFilenameOnly(Filename);
  Result:=AddFile(Filename,
    'unit '+Name+';'+LineEnding
    +'interface'+LineEnding
    +LinesToStr(Intf)
    +'implementation'+LineEnding
    +LinesToStr(Impl)
    +'end.'+LineEnding);
end;

function TCustomTestCLI.AddDir(Filename: string): TCLIFile;
var
  p: Integer;
  Dir: String;
  aFile: TCLIFile;
begin
  Result:=nil;
  Filename:=ExpandFilename(Filename);
  p:=length(Filename);
  while p>1 do
  begin
    if Filename[p]=PathDelim then
    begin
      Dir:=LeftStr(Filename,p-1);
      aFile:=FindFile(Dir);
      if Result=nil then
        Result:=aFile;
      if aFile=nil then
        FFiles.Add(TCLIFile.Create(Dir,'',DefaultFileAge,faDirectory))
      else if (aFile.Attr and faDirectory)=0 then
      begin
        {$IFDEF VerbosePasResolver}
        writeln('[20180224001036] TCustomTestCLI.AddDir Dir=',Dir);
        {$ENDIF}
        raise EPas2jsFileCache.Create('[20180224001036] TCustomTestCLI.AddDir Dir='+Dir);
      end;
      dec(p);
    end else
      dec(p);
  end;
end;

function TCustomTestCLI.GetLogCount: integer;
begin
  Result:=FLogMsgs.Count;
end;

{ TTestCLI_UnitSearch }

procedure TTestCLI_UnitSearch.TestUS_Program;
begin
  AddUnit('system.pp',[''],['']);
  AddFile('test1.pas',[
    'begin',
    'end.']);
  Compile(['test1.pas','-va']);
end;

procedure TTestCLI_UnitSearch.TestUS_UsesEmptyFileFail;
begin
  AddFile('system.pp','');
  AddFile('test1.pas',[
    'begin',
    'end.']);
  Compile(['test1.pas',''],ExitCodeSyntaxError);
  AssertEquals('ErrorMsg','Expected "unit"',ErrorMsg);
end;

procedure TTestCLI_UnitSearch.TestUS_UsesInFile;
begin
  AddUnit('system.pp',[''],['']);
  AddUnit('unit1.pas',
  ['uses bird in ''unit2.pas'';',
   'var a: longint;'],
  ['']);
  AddUnit('unit2.pas',
  ['var b: longint;'],
  ['']);
  AddFile('test1.pas',[
    'uses foo in ''unit1.pas'', bar in ''unit2.pas'';',
    'begin',
    '  bar.b:=foo.a;',
    '  a:=b;',
    'end.']);
  Compile(['test1.pas','-Jc']);
end;

procedure TTestCLI_UnitSearch.TestUS_UsesInFile_Duplicate;
begin
  AddUnit('system.pp',[''],['']);
  AddUnit('unit1.pas',
  ['var a: longint;'],
  ['']);
  AddUnit('sub/unit1.pas',
  ['var b: longint;'],
  ['']);
  AddFile('test1.pas',[
    'uses foo in ''unit1.pas'', bar in ''sub/unit1.pas'';',
    'begin',
    '  bar.b:=foo.a;',
    '  a:=b;',
    'end.']);
  Compile(['test1.pas','-Jc'],ExitCodeSyntaxError);
  AssertEquals('ErrorMsg','Duplicate file found: "/home/user/sub/unit1.pas" and "/home/user/unit1.pas"',ErrorMsg);
end;

procedure TTestCLI_UnitSearch.TestUS_UsesInFile_IndirectDuplicate;
begin
  AddUnit('system.pp',[''],['']);
  AddUnit('unit1.pas',
  ['var a: longint;'],
  ['']);
  AddUnit('sub/unit1.pas',
  ['var b: longint;'],
  ['']);
  AddUnit('unit2.pas',
  ['uses unit1 in ''unit1.pas'';'],
  ['']);
  AddFile('test1.pas',[
    'uses unit2, foo in ''sub/unit1.pas'';',
    'begin',
    'end.']);
  Compile(['test1.pas','-Jc'],ExitCodeSyntaxError);
  AssertEquals('ErrorMsg','Duplicate file found: "/home/user/unit1.pas" and "/home/user/sub/unit1.pas"',ErrorMsg);
end;

Initialization
  RegisterTests([TTestCLI_UnitSearch]);
end.

