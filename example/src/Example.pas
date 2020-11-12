unit Example;

{$mode objfpc}{$H+}

interface

function Add(const A: Integer; const B: Integer): Integer;
function BadAdd(const A: Integer; const B: Integer): Integer;

implementation

function Add(const A: Integer; const B: Integer): Integer;
begin
  Result := A + B;
end;

function BadAdd(const A: Integer; const B: Integer): Integer;
begin
  Result := A - B;
end;

end.
