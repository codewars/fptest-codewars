program challenge;

{$Mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  CodewarsTestRunner,
  Classes,
  SysUtils,
  ExampleTests;

begin
  ExampleTests.RegisterTests;
  RunRegisteredTests;
end.

