unit ExampleTests;

{$mode objfpc}{$H+}

interface

uses
  TestFramework,
  Example;

type
  TExampleTests = class(TTestCase)
  published
    procedure TestAdd;
    procedure TestBadAdd;
  end;

procedure RegisterTests;

implementation

procedure RegisterTests;
begin
  TestFramework.RegisterTest(TExampleTests.Suite);
end;

procedure TExampleTests.TestAdd;
begin
  CheckEquals(2, Add(1, 1));
end;

procedure TExampleTests.TestBadAdd;
begin
  CheckEquals(2, BadAdd(1, 1));
end;



end.
