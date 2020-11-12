{ Requires units from fptest }
unit CodewarsTestRunner;

{$IFDEF FPC}
  {$mode delphi}{$H+}
  {$UNDEF FASTMM}
{$ENDIF}

interface

uses
  Classes,
  TestFrameworkProxyIfaces;

type
  TRunnerExitBehavior = (
    rxbContinue,
    rxbPause,
    rxbHaltOnFailures
    );

type
  TCodewarsTestListener = class(TInterfacedObject, ITestListener, ITestListenerX)
  private
    class function IniFileName: string;
  protected
    // implement the IStatusListener interface
    procedure Status(const ATest: ITestProxy; AMessage: string);

    // implement the ITestListener interface
    procedure AddSuccess(Test: ITestProxy); virtual;
    procedure AddError(Error: TTestFailure); virtual;
    procedure AddFailure(Failure: TTestFailure); virtual;
    procedure AddWarning(AWarning: TTestFailure); virtual;
    procedure TestingStarts; virtual;
    procedure StartTest(Test: ITestProxy); virtual;
    procedure EndTest(Test: ITestProxy); virtual;
    procedure TestingEnds(ATestResult: ITestResult); virtual;
    function  ShouldRunTest(const ATest :ITestProxy):boolean; virtual;

    // Implement the ITestListenerX interface
    procedure StartSuite(Suite: ITestProxy); virtual;
    procedure EndSuite(Suite: ITestProxy); virtual;

  public
    constructor Create;
    destructor Destroy; override;
  end;

{ Run the given Test Suite }
function RunTest(Suite: ITestProxy; exitBehavior: TRunnerExitBehavior = rxbContinue): ITestResult; overload;
function RunRegisteredTests: ITestResult; overload;
function RunRegisteredTests(const AExitBehavior: TRunnerExitBehavior): ITestResult; overload;

implementation
uses
  TestFrameworkProxy,
  SysUtils,
  strutils,
  TimeManager;

function EscapeLF(AMessage: string): string;
begin
  Result := ReplaceStr(AMessage, #10, '<:LF:>');
end;

class function TCodewarsTestListener.IniFileName: string;
const
  TEST_INI_FILE = 'fptest.ini';
begin
  result := {LocalAppDataPath +} TEST_INI_FILE;
end;

constructor TCodewarsTestListener.Create;
begin
  inherited Create;
end;

destructor TCodewarsTestListener.Destroy;
begin
  inherited;
end;

procedure TCodewarsTestListener.AddSuccess(Test: ITestProxy);
begin
  if Test.IsTestMethod then
  begin
    writeln;
    writeln('<PASSED::>Test Passed');
  end;
end;

procedure TCodewarsTestListener.AddError(Error: TTestFailure);
begin
  writeln;
  writeln(EscapeLF(Format('<ERROR::>%s at %s'#10'%s', [
    Error.thrownExceptionName,
    Error.LocationInfo,
    Error.thrownExceptionMessage
  ])));
end;

procedure TCodewarsTestListener.AddFailure(Failure: TTestFailure);
begin
  writeln;
  writeln(EscapeLF(Format('<FAILED::>%s', [Failure.thrownExceptionMessage])));
end;

procedure TCodewarsTestListener.AddWarning(AWarning: TTestFailure);
begin
  writeln(stderr, Format('%s'#10'%s', [
    AWarning.LocationInfo,
    AWarning.thrownExceptionMessage
  ]));
end;

procedure TCodewarsTestListener.TestingStarts;
begin
end;

procedure TCodewarsTestListener.TestingEnds(ATestResult: ITestResult);
begin
end;

function RunTest(Suite: ITestProxy; exitBehavior: TRunnerExitBehavior = rxbContinue): ITestResult;
begin
  Result := nil;
  try
    if Suite = nil then
      writeln('No tests registered')
    else
    try
      Suite.LoadConfiguration(TCodewarsTestListener.IniFileName, False, False);
      Result := RunTest(Suite, [TCodewarsTestListener.Create]);
    finally
      Suite.SaveConfiguration(TCodewarsTestListener.IniFileName, False, False);
      Result.ReleaseListeners;
      Suite.ReleaseTests;
    end;
  finally
    if Assigned(Result) then
    with Result do
    begin
      if not WasSuccessful then
        System.Halt(1);
    end;
  end;
end;

function RunRegisteredTests: ITestResult;
var
  LExitBehavior: TRunnerExitBehavior;
begin
  LExitBehavior := rxbHaltOnFailures;
  Result := RunTest(RegisteredTests, LExitBehavior);
end;

function RunRegisteredTests(const AExitBehavior: TRunnerExitBehavior): ITestResult;
begin
  Result := RunTest(RegisteredTests, AExitBehavior);
end;

procedure TCodewarsTestListener.Status(const ATest: ITestProxy; AMessage: string);
begin
  writeln(Format('%s: %s', [ATest.Name, AMessage]));
end;

function TCodewarsTestListener.ShouldRunTest(const ATest :ITestProxy):boolean;
begin
  Result := not ATest.Excluded;
end;

procedure TCodewarsTestListener.StartSuite(Suite: ITestProxy);
begin
  writeln;
  writeln(Format('<DESCRIBE::>%s', [Suite.Name]));
end;

procedure TCodewarsTestListener.StartTest(Test: ITestProxy);
begin
  if Test.IsTestMethod then
  begin
    writeln;
    writeln(Format('<IT::>%s', [Test.Name]));
  end
end;

procedure TCodewarsTestListener.EndTest(Test: ITestProxy);
begin
  if Test.IsTestMethod then
  begin
    writeln;
    writeln(Format('<COMPLETEDIN::>%0.4f', [Test.ElapsedTestTime * 1000]));
  end
end;

procedure TCodewarsTestListener.EndSuite(Suite: ITestProxy);
begin
  writeln;
  writeln(Format('<COMPLETEDIN::>%0.4f', [Suite.ElapsedTestTime * 1000]));
end;

end.
