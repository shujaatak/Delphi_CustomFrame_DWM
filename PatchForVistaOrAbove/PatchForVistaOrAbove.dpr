program PatchForVistaOrAbove;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Classes,
  XPMan;

procedure PatchPE(const FileName: string);
const
  NewValuesToSet: LongRec = (Lo: 6; Hi: 0);
var
  DOSHeader: TImageDosHeader;
  NTHeader: TImageNtHeaders;
  Stream: TFileStream;
begin
  Writeln('Processing "', FileName, '"...');
  Stream := TFileStream.Create(FileName, fmOpenReadWrite);
  try
    Stream.ReadBuffer(DOSHeader, SizeOf(DOSHeader));
    if DOSHeader.e_magic <> IMAGE_DOS_SIGNATURE then
      raise EParserError.Create('Invalid PE file - DOS header not found.');
    Stream.Seek(DOSHeader._lfanew, soBeginning);
    Stream.ReadBuffer(NTHeader, SizeOf(NTHeader));
    if NTHeader.Signature <> IMAGE_NT_SIGNATURE then
      raise EParserError.Create('Invalid PE file - NT header not found.');
    if NTHeader.OptionalHeader.Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC then
      raise EParserError.Create('Invalid PE file - optional header does not start with the expected magin number.');
    if NTHeader.OptionalHeader.MajorSubsystemVersion >= 6 then
    begin
      Writeln('File is already marked to require Vista or later.');
      Exit;
    end;
    Stream.Seek(-SizeOf(NTHeader.OptionalHeader) + 48, soCurrent);
    Stream.WriteBuffer(NewValuesToSet, SizeOf(NewValuesToSet));
  finally
    Stream.Free;
  end;
  Writeln('Successfully updated file to require Vista or later.');
end;

var
  S: string;
begin
  try
    S := ParamStr(1);
    if (S <> '') and (ParamCount = 1) then
      case S[1] of
        '-', '/', '?': ;
      else
        PatchPE(ExpandFileName(S));
        Exit;
      end;
    Writeln('-----------------------------------------');
    Writeln('Patch a PE file to require Vista or later');
    Writeln('-----------------------------------------');
    Writeln;
    Writeln('Syntax: PatchForVistaOrAbove FileName');
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.
