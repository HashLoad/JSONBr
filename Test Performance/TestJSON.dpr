program TestJSON;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  Vcl.Graphics,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  Test.JSON in 'Test.JSON.pas',
  Test.Consts in 'Test.Consts.pas',
  Test.Model in 'Test.Model.pas',
  XSuperJSON in 'x-superobject\XSuperJSON.pas',
  XSuperObject in 'x-superobject\XSuperObject.pas',
  test.res_json in 'test.res_json.pas',
  test.json_br in 'test.json_br.pas',
  test.xsuper in 'test.xsuper.pas',
  jsonbr in '..\Source\jsonbr.pas',
  jsonbr.builders in '..\Source\Core\jsonbr.builders.pas',
  jsonbr.reader in '..\Source\Core\jsonbr.reader.pas',
  jsonbr.types in '..\Source\Core\jsonbr.types.pas',
  jsonbr.utils in '..\Source\Core\jsonbr.utils.pas',
  jsonbr.writer in '..\Source\Core\jsonbr.writer.pas';

{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
//    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
//    begin
//      logger := TDUnitXConsoleLogger.Create(True {TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet});
//      runner.AddLogger(logger);
//    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      SetColorConsole(clWhite);
      System.Writeln(' ');
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
