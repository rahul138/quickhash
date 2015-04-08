{
    Quick Hash - A Linux, Windows and Apple Mac GUI for quickly selecting one or more files
    and generating hash values for them.

    The use of the word 'quick' refers to the ease in which the software operates
    in both Linux, Apple Mac and Windows (very few options
    to worry about, no syntax to remember etc) though tests suggest that in most
    cases the hash values are generated as quick or quicker than most mainstream
    tools, such as FTK Imager (Windows), 'EnCase' (Windows), md5sum, sha1sum,
    sha256sum and sha512sum (Linux).

    Benchmark tests are welcomed to test on across various platforms and architectures.

    Contributions from members at the Lazarus forums, Stackoverflow and other
    StackExchnage groups are welcomed and acknowledged. In particular, user Engkin
    (http://forum.lazarus.freepascal.org/index.php?action=profile;u=52702) who
    helped with the speeds of the SHA1 and MD5 implementations ENORMOUSLY, David Heferman of the
    Stackoverflow forums who helped me with the methodology of hashing in buffers
    and Taazz who pointed out where I'd made some daft mistakes. Thanks guys!

    Copyright (C) 2011-2015  Ted Smith https://sourceforge.net/users/tedtechnology

    NOTE: Date and time values, as computed in recursive directory hashing, are not
    daylight saving time adjusted. Source file date and time values are recorded.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version. You are not granted permission to create
    another disk or file hashing tool based on this code and call it 'QuickHash'.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You can read a copy of the GNU General Public License at
    http://www.gnu.org/licenses/>. Also, http://www.gnu.org/copyleft/gpl.html

}

unit Unit2; // Unit 1 was superseeded and related to pre v2.0.0

{$mode objfpc}{$H+} // {$H+} ensures strings are of unlimited size

interface

uses
  {$IFDEF UNIX}
    {$IFDEF UseCThreads}
      cthreads,
    {$ENDIF}
  {$ENDIF}

    Classes, SysUtils, Strutils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Menus, ComCtrls, Grids, ExtCtrls, sysconst, LazUTF8Classes, lclintf,

  FindAllFilesEnhanced, // an enhanced version of FindAllFiles, to ensure hidden files are found, if needed

  // we have to use a customised MD5 library to process Unicode on Windows and
  // to run a customised MD5Transform function
  md5customised,
  // we use a customised SHA1 library to process Unicode on Windows and to run
  // a customised SHA1Transform function
  sha1customised,

  // The DCPCrypt library, for some of the hashing algorithms used in certain
  // circumstances. SHA256 and SHA512 are not part of FPC:
    DCPsha512, DCPsha256, DCPsha1, DCPmd5,

  // Remaining Uses clauses for specific OS's
  {$IFDEF Windows}
    Windows,
    // For Windows, this is a specific disk hashing tab for QuickHash. Not needed for Linux
    DiskModuleUnit1;
  {$ENDIF}
  {$IFDEF Darwin}
    MacOSAll;
  {$else}
    {$IFDEF UNIX and !$ifdef Darwin} // because Apple had to 'borrow' Unix for their OS!
      UNIX;
    {$ENDIF}
  {$ENDIF}

type

  { TMainForm }

   TMainForm = class(TForm)
    AlgorithmChoiceRadioBox3: TRadioGroup;
    AlgorithmChoiceRadioBox4: TRadioGroup;
    AlgorithmChoiceRadioBox1: TRadioGroup;
    AlgorithmChoiceRadioBox6: TRadioGroup;
    AlgorithmChoiceRadioBox5: TRadioGroup;
    btnCompare: TButton;
    btnCompareTwoFiles: TButton;
    btnCompareTwoFilesSaveAs: TButton;
    btnDirA: TButton;
    btnDirB: TButton;
    btnFileACompare: TButton;
    btnFileBCompare: TButton;
    btnHashFile: TButton;
    btnRecursiveDirectoryHashing: TButton;
    btnClipboardResults: TButton;
    btnClipboardResults2: TButton;
    btnCallDiskHasherModule: TButton;
    btnStopScan2: TButton;
    btnClearTextArea: TButton;
    btnCopyToClipboardA: TButton;
    btnCopyToClipboardB: TButton;
    btnSaveComparisons: TButton;
    Button6SelectSource: TButton;
    btnStopScan1: TButton;
    Button7SelectDestination: TButton;
    Button8CopyAndHash: TButton;
    chkHiddenFiles: TCheckBox;
    chkCopyHidden: TCheckBox;
    CheckBoxListOfDirsAndFilesOnly: TCheckBox;
    CheckBoxListOfDirsOnly: TCheckBox;
    chkFlagDuplicates: TCheckBox;
    chkNoRecursiveCopy: TCheckBox;
    chkNoPathReconstruction: TCheckBox;
    chkRecursiveDirOverride: TCheckBox;
    CopyAndHashGrid: TStringGrid;
    CopyFilesHashingGroupBox: TGroupBox;
    DirectoryHashingGroupBox: TGroupBox;
    DirSelectedField: TEdit;
    Edit2SourcePath: TEdit;
    Edit3DestinationPath: TEdit;
    FileHashingGroupBox: TGroupBox;
    edtFileNameToBeHashed: TEdit;
    FileMaskField: TEdit;
    FileTypeMaskCheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    gbDirectoryComparisons: TGroupBox;
    Label1: TLabel;
    lblURLBanner: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblDirAName: TLabel;
    lblDirBName: TLabel;
    lblFileAHash: TLabel;
    lblFileAName: TLabel;
    lblFileBHash: TLabel;
    lblFileBName: TLabel;
    lblFilesCopiedPercentage: TLabel;
    lblDataCopiedSoFar: TLabel;
    lblHashMatchResult: TLabel;
    lblNoOfFilesToExamine2: TLabel;
    lblNoOfFilesToExamine: TLabel;
    lblPercentageComplete: TLabel;
    lblTotalBytesExamined: TLabel;
    lblFilesExamined: TLabel;
    lblNoFilesInDir: TLabel;
    lblDragAndDropNudge: TLabel;
    lblDiskHashingRunAsAdminWarning: TLabel;
    lblTimeTakenB: TLabel;
    lblTimeFinishedB: TLabel;
    lblTimeStartB: TLabel;
    lblTimeFinishedA: TLabel;
    lblTimeTakenA: TLabel;
    lblTimeStartA: TLabel;
    lblStatusB: TLabel;
    lblStatusA: TLabel;
    lblHashMatchB: TLabel;
    lblHashMatchA: TLabel;
    lblFileCountDiffA: TLabel;
    lblFileCountDiffB: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    lblTimeTaken6C: TLabel;
    lblTimeTaken5C: TLabel;
    lblTimeTaken6A: TLabel;
    lblTimeTaken6B: TLabel;
    lblTimeTaken5B: TLabel;
    lblTimeTaken5A: TLabel;
    lblTimeTaken4: TLabel;
    lblTimeTaken3: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblTimeTaken1: TLabel;
    lblTimeTaken2: TLabel;
    AlgorithmChoiceRadioBox2: TRadioGroup;
    lblTotalFileCountA: TLabel;
    lblTotalFileCountB: TLabel;
    lblTotalFileCountNumberA: TLabel;
    lblTotalFileCountNumberB: TLabel;
    memFileHashField: TMemo;
    SaveDialog5: TSaveDialog;
    SaveDialog6: TSaveDialog;
    SelectDirectoryDialog4: TSelectDirectoryDialog;
    SelectDirectoryDialog5: TSelectDirectoryDialog;
    sgDirB: TStringGrid;
    StatusBar1: TStatusBar;
    StatusBar2: TStatusBar;
    StatusBar3: TStatusBar;
    StatusBar4: TStatusBar;
    StrHashValue: TMemo;
    memoHashText: TMemo;
    NoOfFilesExamined: TEdit;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1CopyAndHashOptions: TPanel;
    PercentageComplete: TLabel;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    SaveDialog3: TSaveDialog;
    SaveDialog4: TSaveDialog;
    SaveToCSVCheckBox1: TCheckBox;
    SaveToCSVCheckBox2: TCheckBox;
    SaveToHTMLCheckBox1: TCheckBox;
    SaveToHTMLCheckBox2: TCheckBox;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SelectDirectoryDialog2: TSelectDirectoryDialog;
    SelectDirectoryDialog3: TSelectDirectoryDialog;
    RecursiveDisplayGrid1: TStringGrid;
    sgDirA: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TextHashingGroupBox: TGroupBox;
    procedure AlgorithmChoiceRadioBox2SelectionChanged(Sender: TObject);
    procedure AlgorithmChoiceRadioBox5SelectionChanged(Sender: TObject);
    procedure btnClipboardHashValueClick(Sender: TObject);
    procedure btnClipboardResults2Click(Sender: TObject);
    procedure btnCompareTwoFilesClick(Sender: TObject);
    procedure btnCompareTwoFilesSaveAsClick(Sender: TObject);
    procedure btnCopyToClipboardAClick(Sender: TObject);
    procedure btnCopyToClipboardBClick(Sender: TObject);
    procedure btnDirAClick(Sender: TObject);
    procedure btnDirBClick(Sender: TObject);
    procedure btnFileACompareClick(Sender: TObject);
    procedure btnFileBCompareClick(Sender: TObject);
    //procedure btnHashTextClick(Sender: TObject);
    procedure btnHashFileClick(Sender: TObject);
    procedure btnLaunchDiskModuleClick(Sender: TObject);
    procedure btnRecursiveDirectoryHashingClick(Sender: TObject);
    procedure btnSaveComparisonsClick(Sender: TObject);
    procedure btnStopScan1Click(Sender: TObject);
    procedure btnClipboardResultsClick(Sender: TObject);
    procedure btnStopScan2Click(Sender: TObject);
    {$ifdef Windows}
    procedure btnCallDiskHasherModuleClick(Sender: TObject);
    {$endif}
    procedure btnCompareClick(Sender: TObject);
    procedure btnClearTextAreaClick(Sender: TObject);
    procedure Button6SelectSourceClick(Sender: TObject);
    procedure Button7SelectDestinationClick(Sender: TObject);
    procedure Button8CopyAndHashClick(Sender: TObject);
    procedure CheckBoxListOfDirsAndFilesOnlyChange(Sender: TObject);
    procedure CheckBoxListOfDirsOnlyChange(Sender: TObject);
    procedure FileTypeMaskCheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure HashFile(FileIterator: TFileIterator);
    procedure lblURLBannerClick(Sender: TObject);
    procedure ProcessDir(const SourceDirName: string);
    procedure MisMatchFileCountCompare(HashListA, HashListB, FileAndHashListA, FileAndHashListB : TStringList);
    procedure CompareTwoHashes(FileAHash, FileBHash : string);
    procedure HashText(Sender: TObject);
    procedure ClearText(Sender: TObject);
    procedure MisMatchHashCompare(HashListA, HashListB, FileAndHashListA, FileAndHashListB : TStringList);
    function  CalcTheHashString(strToBeHashed:ansistring):string;
    function  CalcTheHashFile(FileToBeHashed:string):string;
    function  FormatByteSize(const bytes: QWord): string;
    procedure SaveOutputAsCSV(Filename : string; GridName : TStringGrid);

    {$IFDEF Windows}
    function DateAttributesOfCurrentFile(var SourceDirectoryAndFileName:string):string;
    function FileTimeToDTime(FTime: TFileTime): TDateTime;
    {$ENDIF}
    {$IFDEF LINUX}
    function DateAttributesOfCurrentFileLinux(var SourceDirectoryAndFileName:string):string;
    {$ENDIF}
    {$ifdef UNIX}
      {$ifdef Darwin}
        function DateAttributesOfCurrentFileLinux(var SourceDirectoryAndFileName:string):string;
      {$ENDIF}
    {$ENDIF}
    function CustomisedForceDirectoriesUTF8(const Dir: string; PreserveTime: Boolean): Boolean;
    procedure SHA1RadioButton3Change(Sender: TObject);
    procedure TabSheet3ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);

  private
    { private declarations }
  public
    { public declarations }
   FileCounter, NoOfFilesInDir2: integer; // Used jointly by Button3Click and Hashfile procedures
   TotalBytesRead : UInt64;
   StopScan1, StopScan2, SourceDirValid, DestDirValid : Boolean;
   SourceDir, DestDir : string; // For the joint copy and hash routines
    DirA, DirB : string;
   sValue1 : string; // Set by GetWin32_DiskDriveInfo then used by ListDisks OnClick event - Windows only
  end;

var
  MainForm: TMainForm;

implementation

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  x, y : integer;
begin
  x := screen.Width;
  y := screen.Height;

  if x < MainForm.Width then
    begin
       MainForm.Width := x - 50;
     end;

  if y < MainForm.Height then
    begin
       Mainform.Height := y - 50;
    end;

  StopScan1 := false;
  StopScan2 := false;

  btnCopyToClipboardA.Enabled := false;
  btnCopyToClipboardB.Enabled := false;

  {$IFDEF WINDOWS}
  Label8.Caption        := '';
  chkCopyHidden.Enabled := false;
  chkCopyHidden.ShowHint:= true;
  chkCopyHidden.Hint:= 'On Windows, QuickHash finds hidden files and folders by default';
  {$ENDIF}

  {$IFDEF LINUX}

 // For Linux users, we don't want them trying to use the Windows Disk hashing module
 // created for Windows users.
  Tabsheet5.Enabled     := true;
  Tabsheet5.Visible     := true;
  btnCallDiskHasherModule.Enabled := false;
  Label8.Caption        := 'LINUX USERS - Hash disks using "File" tab and navigate to /dev/sdX or /dev/sdXX as root';
  chkCopyHidden.Enabled := true;
  chkCopyHidden.ShowHint:= true;
  chkCopyHidden.Hint:= 'In Linux, tick this to ensure hidden directories and hidden files in them are detected, if you want them';
 {$Endif}

 {$ifdef UNIX}
    {$ifdef Darwin}
    // For Apple Mac users, we don't want them trying to use the Windows Disk hashing module
    // created for Windows users.
    Tabsheet5.Enabled     := true;
    Tabsheet5.Visible     := true;
    btnCallDiskHasherModule.Enabled := false;
    Label8.Caption        := 'Apple Mac Users - Hash disks using "File" tab and navigate to /dev/sdX or /dev/sdXX as root';
    chkCopyHidden.Enabled := true;
    chkCopyHidden.ShowHint:= true;
    chkCopyHidden.Hint:= 'In Apple Mac, tick this to ensure hidden directories and hidden files in them are detected, if you want them';

    {$ENDIF}
 {$ENDIF}

end;
// FormDropFiles is the same as btnHashFileClick, except it disables the OpenDialog
// element and computes the filename from the drag n drop variable and hashes the file.
procedure TMainForm.FormDropFiles(Sender: TObject;
  const FileNames: array of String);

var
  filename : ansistring;
  fileHashValue : ansistring;
  start, stop, elapsed : TDateTime;

begin
  StatusBar1.SimpleText := '';

  // First, clear the captions from any earlier file hashing actions
  lblTimeTaken1.Caption := '';
  lblTimeTaken2.Caption := '';
  Label1.Caption := '';
  memFileHashField.Clear;

   begin
    filename := FileNames[0];
    if DirectoryExists(filename) then
    begin
      ShowMessage('Drag and drop of folders is not supported in this tab.');
    end
    else
    if FileExistsUTF8(filename) then
     begin
       start := Now;
       lblTimeTaken1.Caption := 'Started at  : '+ TimeToStr(Start);
       Tabsheet2.Show;
       edtFileNameToBeHashed.Caption := (filename);
       label1.Caption := 'Hashing file... ';
       StatusBar1.SimpleText := ' HASHING FILE...PLEASE WAIT';
       Application.ProcessMessages;
       fileHashValue := CalcTheHashFile(Filename); // Custom function
       memFileHashField.Lines.Add(UpperCase(fileHashValue));
       label1.Caption := 'Complete.';
       StatusBar1.SimpleText := ' HASHING COMPLETE!';
       OpenDialog1.Close;

       stop := Now;
       elapsed := stop - start;
       lblTimeTaken2.Caption := 'Time taken : '+ TimeToStr(elapsed);
       Application.ProcessMessages;
     end
    else
      ShowMessage('An error occured opening the file. Error code: ' +  SysErrorMessageUTF8(GetLastOSError));
   end;
end;


procedure TMainForm.HashText(Sender: TObject);
begin
  if Length(memoHashText.Text) = 0 then
   begin
    StrHashValue.Caption := 'Awaiting input in text field...';
   end
   else
     StrHashValue.Caption := CalcTheHashString(memoHashText.Text);
end;

procedure TMainForm.btnHashFileClick(Sender: TObject);
var
  filename : string;
  fileHashValue : ansistring;
  start, stop, elapsed : TDateTime;

begin
  StatusBar1.SimpleText := '';
  if OpenDialog1.Execute then
    begin
      filename := OpenDialog1.Filename;
    end;
  // First, clear the captions from any earlier file hashing actions
  lblTimeTaken1.Caption := '';
  lblTimeTaken2.Caption := '';
  Label1.Caption := '';
  memFileHashField.Clear;

  if FileExistsUTF8(filename) then
   begin
     start := Now;
     lblTimeTaken1.Caption := 'Started at  : '+ FormatDateTime('dd/mm/yy hh:mm:ss', Start);

     edtFileNameToBeHashed.Caption := (filename);
     label1.Caption := 'Hashing file... ';
     StatusBar1.SimpleText := ' H A S H I N G  F I L E...P L E A S E  W A I T';
     Application.ProcessMessages;
     fileHashValue := CalcTheHashFile(Filename); // Custom function
     memFileHashField.Lines.Add(UpperCase(fileHashValue));
     label1.Caption := 'Complete.';
     StatusBar1.SimpleText := ' H A S H I N G  C OM P L E T E !';
     OpenDialog1.Close;

     stop := Now;
     elapsed := stop - start;
     lblTimeTaken2.Caption := 'Time taken : '+ TimeToStr(elapsed);
     Application.ProcessMessages;
   end
  else
    ShowMessage('An error occured opening the file. Error code: ' +  SysErrorMessageUTF8(GetLastOSError));
 end;

procedure TMainForm.btnLaunchDiskModuleClick(Sender: TObject);
begin

end;

// Procedure SaveOutputAsCSV
// An object orientated way to save any given display grid to CSV to save me
// retyping the same code over and over!
procedure TMainForm.SaveOutputAsCSV(Filename : string; GridName : TStringGrid);
var
  slTmpLoadedFromOutput : TStringLIst;
  InsTextPos : integer;
begin
  // Here we save the grid to CSV, then load into memory, insert
  // the title line and version number of QuickHash, then save it
  // back to CSV. A bit round the houses but best I can think of for now
  InsTextPos := 0;
  try
    GridName.SaveToCSVFile(FileName);
    slTmpLoadedFromOutput := TStringLIst.Create;
    slTmpLoadedFromOutput.LoadFromFile(FileName);
    slTmpLoadedFromOutput.Insert(InsTextPos, MainForm.Caption + '. Log generated: ' + DateTimeToStr(Now));
  finally
    // Write back the original data with the newly inserted first line
    slTmpLoadedFromOutput.SaveToFile(FileName);
    slTmpLoadedFromOutput.Free;
  end;
end;

// Procedure btnRecursiveDirectoryHashingClick
// Finds the files in a directory and hashes them, recursively by default
procedure TMainForm.btnRecursiveDirectoryHashingClick(Sender: TObject);
var
  DirToHash, CSVLogFile, HTMLLogFile1 : string;
  FS                                  : TFileSearcher;
  TotalFilesToExamine, slDuplicates   : TStringList;
  start, stop, elapsed                : TDateTime;
  j, i, DuplicatesDeleted             : integer;
  DeleteResult                        : Boolean;

  begin
  FileCounter                   := 1;
  TotalBytesRead                := 0;
  DuplicatesDeleted             := 0;
  lblTimeTaken3.Caption         := '...';
  lblTimeTaken4.Caption         := '...';
  lblFilesExamined.Caption      := '...';
  lblPercentageComplete.Caption := '...';
  lblTotalBytesExamined.Caption := '...';

  slDuplicates := TStringList.Create;
  slDuplicates.Sorted := true;

  if SelectDirectoryDialog1.Execute then
    begin
      DirSelectedField.Caption := SelectDirectoryDialog1.FileName;
      DirToHash := SelectDirectoryDialog1.FileName;
      RecursiveDisplayGrid1.Visible := false;
      RecursiveDisplayGrid1.rowcount := 0;
      // Check selected dir exists. If it does, start the process.
      if DirPathExists(DirToHash) then
        begin
        // Now lets recursively count each file,
         start := Now;
         lblTimeTaken3.Caption := 'Started at : '+ FormatDateTime('dd/mm/yy hh:mm:ss', Start);
         StatusBar2.SimpleText := ' C O U N T I N G  F I L E S...P L E A S E  W A I T   A   M O M E N T ...';
         Label5.Visible        := true;
         Application.ProcessMessages;

         // By default, the recursive dir hashing will hash all files of all sub-dirs
         // from the root of the chosen dir. If the box is ticked, the user just wants
         // to hash the files in the root of the chosen dir.

         if chkRecursiveDirOverride.Checked then   // User does NOT want recursive
           begin
             if chkHiddenFiles.Checked then        // ...but does want hidden files
               begin
                 TotalFilesToExamine := FindAllFilesEx(DirToHash, '*', False, True);
               end
             else                                  // User does not want hidden
               begin
                 TotalFilesToExamine := FindAllFiles(DirToHash, '*', False);
               end;
           end
         else
           begin                                  // User DOES want recursive
             if chkHiddenFiles.Checked then         // ...and he wants hidden
               begin
                 TotalFilesToExamine := FindAllFilesEx(DirToHash, '*', true, true);
               end
             else                                  // ...but not want hidden
               begin
                 TotalFilesToExamine := FindAllFiles(DirToHash, '*', true);
               end;
           end;
         lblNoFilesInDir.Caption := IntToStr(TotalFilesToExamine.count);
         NoOfFilesInDir2 := StrToInt(lblNoFilesInDir.Caption);  // A global var
         RecursiveDisplayGrid1.rowcount := TotalFilesToExamine.Count +1;
         Application.ProcessMessages;

         // Create and assign a File Searcher instance and dictate its behaviour.
         // Then hash each file accordingly.
         try
           FS := TFileSearcher.Create;

           // Set parameters for searching for hidden or non-hidden files and dirs
           if chkHiddenFiles.Checked then
             begin
               FS.DirectoryAttribute := faAnyFile or faHidden;
               FS.FileAttribute := faAnyFile or faHidden;
               FS.OnFileFound := @HashFile;
             end
           else
             begin
               FS.FileAttribute := faAnyFile;
               FS.OnFileFound := @HashFile;
             end;

           // Set parameters for searching recursivley or not
           if chkRecursiveDirOverride.Checked then
             begin
               FS.Search(DirToHash, '*', False);
             end
           else
             begin
               FS.Search(DirToHash, '*', True);
             end;
         finally
           // Hashing complete. Now free resources
           FS.Free;
           TotalFilesToExamine.Free;
         end;

         {  Now that the data is all computed, display the grid in the GUI.
            We have this hidden during processing for speed purposes.
            In a test, 3K files took 3 minutes with the grid display refreshed for each file.
            With the grid hidden until this point though, the same files took just 12 seconds! }

         RecursiveDisplayGrid1.Visible := true;

         // Now traverse the grid for duplicate hash entries, if the user wishes to

         if chkFlagDuplicates.Checked then
           begin
           RecursiveDisplayGrid1.SortOrder := soAscending;
           RecursiveDisplayGrid1.SortColRow(true, 3, RecursiveDisplayGrid1.FixedRows, RecursiveDisplayGrid1.RowCount - 1);
            for i := 1 to RecursiveDisplayGrid1.RowCount -1 do
            begin
              if RecursiveDisplayGrid1.Cells[3, i] = RecursiveDisplayGrid1.Cells[3, i-1] then
                begin
                 RecursiveDisplayGrid1.Cells[5, i] := 'Yes, of file ' + RecursiveDisplayGrid1.Cells[1,i-1];
                 slDuplicates.Add(RecursiveDisplayGrid1.Cells[2,i-1] + RecursiveDisplayGrid1.Cells[1, i-1]);
                end;
            end;
            slDuplicates.Sort;
           end;

         // and conclude timings and update display
         stop := Now;
         elapsed := stop - start;
         lblTimeTaken4.Caption := 'Time taken : '+ TimeToStr(elapsed);
         StatusBar2.SimpleText := ' DONE! ';
         btnClipboardResults.Enabled := true;

        // Now output the complete StringGrid to a csv text file

        // FYI, RecursiveDisplayGrid1.Cols[X].savetofile('/home/ted/test.txt'); is good for columns
        // RecursiveDisplayGrid1.Rows[X].savetofile('/home/ted/test.txt'); is good for rows

         if SaveToCSVCheckBox1.Checked then
           begin
             SaveDialog1.Title := 'Save your CSV text log file as...';
             SaveDialog1.InitialDir := GetCurrentDir;
             SaveDialog1.Filter := 'Comma Sep|*.csv|Text file|*.txt';
             SaveDialog1.DefaultExt := 'csv';
             if SaveDialog1.Execute then
               begin
                SaveOutputAsCSV(SaveDialog1.FileName, RecursiveDisplayGrid1);
               end;
           end;

         // And\Or, output the complete StringGrid to a HTML file

         if SaveToHTMLCheckBox1.Checked then
           begin
           SaveDialog2.Title := 'Save your HTML log file as...';
           SaveDialog2.InitialDir := GetCurrentDir;
           SaveDialog2.Filter := 'HTML|*.html';
           SaveDialog2.DefaultExt := 'html';
           if SaveDialog2.Execute then
             begin
               i := 0;
               j := 0;
               HTMLLogFile1 := SaveDialog2.FileName;
               with TStringList.Create do
               try
                 Add('<html>');
                 Add('<title>QuickHash HTML Output</title>');
                 Add('<body>');
                 Add('<br />');
                 Add('<p><strong>' + MainForm.Caption + '. ' + 'Log Created: ' + DateTimeToStr(Now)+'</strong></p>');
                 Add('<p><strong>File and Hash listing for: ' + DirToHash + '</strong></p>');
                 Add('<table border=1>');
                 Add('<tr>');
                 Add('<td>' + 'ID');
                 Add('<td>' + 'File Name');
                 Add('<td>' + 'File Path');
                 Add('<td>' + 'Hash');
                 Add('<td>' + 'Size');
                 for i := 0 to RecursiveDisplayGrid1.RowCount-1 do
                   begin
                     Add('<tr>');
                     for j := 0 to RecursiveDisplayGrid1.ColCount-1 do
                       Add('<td>' + RecursiveDisplayGrid1.Cells[j,i] + '</td>');
                       add('</tr>');
                   end;
                 Add('</table>');
                 Add('</body>');
                 Add('</html>');
                 SaveToFile(HTMLLogFile1);
               finally
                 Free;
                 HTMLLogFile1 := '';
               end;
             end;
          end;
        end
        else
        begin
          ShowMessage('Invalid directory selected' + sLineBreak + 'You must select a directory. Error code : ' + SysErrorMessageUTF8(GetLastOSError));
        end;
    end;

  // Now see if the user wishes to delete any found duplicates
  if chkFlagDuplicates.Checked then
    begin
      if slDuplicates.Count > 0 then
        if MessageDlg(IntToStr(slDuplicates.Count) + ' duplicate files were found. Delete them now?', mtConfirmation,
          [mbCancel, mbNo, mbYes],0) = mrYes then
            begin
              for i := 0 to (slDuplicates.Count -1) do
                begin
                  StatusBar2.SimpleText:= 'Deleting duplicate file ' + slDuplicates.Strings[i];
                  StatusBar2.Refresh;
                  if SysUtils.DeleteFile(slDuplicates.Strings[i]) then
                    inc(DuplicatesDeleted);
                end;
              StatusBar2.SimpleText:= 'Finished deleting ' + IntToStr(DuplicatesDeleted) + ' duplicate files';
              StatusBar2.Refresh;
              ShowMessage(IntToStr(DuplicatesDeleted) + ' duplicate files deleted.');
            end;
      slDuplicates.Free;  // this needs to be freed, regardless of whether it contained any entries or not
    end; // end of duplicate deletion phase
end;

procedure TMainForm.btnSaveComparisonsClick(Sender: TObject);
var
  slHTMLOutput : TStringList;
  HTMLLogFile3 : string;
  i, j         : integer;
begin
  SaveDialog6.Title := 'Save Grid A as CSV log file as...';
  SaveDialog6.InitialDir := GetCurrentDir;
  SaveDialog6.Filter := 'Comma Sep|*.csv|Text file|*.txt';
  SaveDialog6.DefaultExt := 'csv';
  ShowMessage('You will now be prompted to save two seperate CSV files and one combined HTML file...');

  if SaveDialog6.Execute then
    begin
      SaveOutputAsCSV(SaveDialog6.FileName, sgDirA);
    end;

  SaveDialog6.Title := 'Save Grid B as CSV log file as...';
  if SaveDialog6.Execute then
    begin
      SaveOutputAsCSV(SaveDialog6.FileName, sgDirB);
    end;

  // HTML Output
  SaveDialog6.Title := 'Save Grids A and B as HTML log file as...';
  SaveDialog6.InitialDir := GetCurrentDir;
  SaveDialog6.Filter := 'HTML|*.html';
  SaveDialog6.DefaultExt := 'html';
  if SaveDialog6.Execute then
    begin
      HTMLLogFile3 := SaveDialog6.FileName;
      slHTMLOutput := TStringList.Create;
      try
       slHTMLOutput.Add('<html>');
       slHTMLOutput.Add('<title>QuickHash HTML Output</title>');
       slHTMLOutput.Add('<body>');
       slHTMLOutput.Add('<br />');
       slHTMLOutput.Add('<p><strong>' + MainForm.Caption + '. ' + 'Log Created: ' + DateTimeToStr(Now)+'</strong></p>');
       slHTMLOutput.Add('<p><strong>File and Hash Comparisons of ' + lblDirAName.Caption + ' and ' + lblDirBName.Caption + '</strong></p>');

       // Grid A content to HTML

       slHTMLOutput.Add('<p>Table A</p>');
       slHTMLOutput.Add('<table border=1>');
       slHTMLOutput.Add('<tr>');
       slHTMLOutput.Add('<td>' + 'ID');
       slHTMLOutput.Add('<td>' + 'File Path & Name');
       slHTMLOutput.Add('<td>' + 'Hash');

       i := 0;
       j := 0;
       for i := 0 to sgDirA.RowCount-1 do
         begin
           slHTMLOutput.Add('<tr>');
           for j := 0 to sgDirA.ColCount-1 do
             slHTMLOutput.Add('<td>' + sgDirA.Cells[j,i] + '</td>');
             slHTMLOutput.Add('</tr>');
         end;
       slHTMLOutput.Add('</table>');

       // Grid B content to HTML

       slHTMLOutput.Add('<p>Table B</p>');
       slHTMLOutput.Add('<table border=1>');
       slHTMLOutput.Add('<tr>');
       slHTMLOutput.Add('<td>' + 'ID');
       slHTMLOutput.Add('<td>' + 'File Path & Name');
       slHTMLOutput.Add('<td>' + 'Hash');
       slHTMLOutput.Add('</tr>');

       i := 0;
       j := 0;
       for i := 0 to sgDirB.RowCount-1 do
         begin
           slHTMLOutput.Add('<tr>');
           for j := 0 to sgDirB.ColCount-1 do
             slHTMLOutput.Add('<td>' + sgDirB.Cells[j,i] + '</td>');
             slHTMLOutput.Add('</tr>');
         end;
       slHTMLOutput.Add('</table>');
       slHTMLOutput.Add('</body>');
       slHTMLOutput.Add('</html>');
       slHTMLOutput.SaveToFile(HTMLLogFile3);
      finally
       slHTMLOutput.Free;
       HTMLLogFile3 := '';
      end;
    end; // End of Savedialog6.Execute for HTML
end;


procedure TMainForm.btnClipboardResultsClick(Sender: TObject);
begin
  try
    RecursiveDisplayGrid1.CopyToClipboard();
  finally
    ShowMessage('Grid content now in clipboard...Paste (Ctrl+V) into spreadsheet or text editor')
  end
end;

procedure TMainForm.btnStopScan1Click(Sender: TObject);
begin
  StopScan1 := TRUE;
  if StopScan1 = TRUE then
  begin
    Abort;
  end;
end;

procedure TMainForm.btnStopScan2Click(Sender: TObject);
begin
  StopScan2 := TRUE;
  if StopScan2 = TRUE then
  begin
    Abort;
  end;
end;


{$ifdef Windows}
// Calls the 'frmDiskHashingModule' Form used for disk hashing in Windows.
// It also clears all labels from any previous runs of the form.
procedure TMainForm.btnCallDiskHasherModuleClick(Sender: TObject);
begin
  DiskModuleUnit1.frmDiskHashingModule.lbledtStartAtTime.Text := 'HH:MM';
  DiskModuleUnit1.frmDiskHashingModule.ListBox1.Clear;
  DiskModuleUnit1.frmDiskHashingModule.lblSpeedB.Caption             := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblDiskNameB.Caption          := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblByteCapacityB.Caption      := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblBytesLeftToHashB.Caption   := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblStartTimeB.Caption         := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblEndTimeB.Caption           := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblSpeedB.Caption             := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblModelB.Caption             := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblMediaTypeB.Caption         := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblInterfaceB.Caption         := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblSectorsB.Caption           := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblTimeTakenB.Caption         := '...';
  DiskModuleUnit1.frmDiskHashingModule.lblManufacturerB.Caption      := '...';
  DiskModuleUnit1.frmDiskHashingModule.edtComputedHash.Text          := '...';
  DiskModuleUnit1.frmDiskHashingModule.Show;
end;
 {$Endif}

 // btnCompareClick : Will compare the listings of two directories, inc hidden files
 // The user is not presented with a choice for hiddne files because a comparison
 // of directories must be an exacting process.
procedure TMainForm.btnCompareClick(Sender: TObject);
var
  FilePath, FileName, FullPathAndName, FileHashA, FileHashB,
    HashOfListA, HashOfListB, Mismatch, s, strTimeTaken, strTimeDifference : string;

  TotalFilesDirA, TotalFilesDirB,       // Stringlists just for the file names
    HashListA, HashListB,               // Stringlists just for the hashes of each file in each directory
    FileAndHashListA, FileAndHashListB, // Stringlists for the combined lists of both hashes with filenames
    MisMatchList : TStringList;

  i : integer;

  StartTime, EndTime, TimeTaken : TDateTime;

begin
  // Initialise vars and display captions, to ensure any previous runs are cleared
  i                                := 0;
  DirA                             := lblDirAName.Caption;
  DirB                             := lblDirBName.Caption;
  StartTime                        := Now;
  sgDirA.Clean;
  sgDirB.Clean;
  lblTotalFileCountNumberA.Caption := '...';
  lblTotalFileCountNumberB.Caption := '...';
  lblFileCountDiffB.Caption        := '...';
  lblHashMatchB.Caption            := '...';
  lblTimeStartB.Caption            := FormatDateTime('dd/mm/yy hh:mm:ss', StartTime);
  lblTimeFinishedB.Caption         := 'Please wait...';
  lblTimeTakenB.Caption            := '...';
  lblTimeStartB.Refresh;
  lblTimeFinishedB.Refresh;

  try
    // First, list and hash the files in DirA
    lblStatusB.Caption      := 'Counting files in ' + DirA + ' ...please wait';
    TotalFilesDirA          := TStringList.Create;
    TotalFilesDirA.Sorted   := true;
    TotalFilesDirA          := FindAllFilesEx(DirA, '*', True, True);
    TotalFilesDirA.Sort;
    sgDirA.RowCount         := TotalFilesDirA.Count + 1;

    HashListA               := TStringList.Create;
    FileAndHashListA        := TStringList.Create;
    HashListA.Sorted        := true;
    FileAndHashListA.Sorted := true;

    lblStatusB.Caption      := 'Examining files in ' + DirA + ' ...please wait';
    Application.ProcessMessages;

    for i := 0 to TotalFilesDirA.Count -1 do
      begin
        FilePath            := ExtractFilePath(TotalFilesDirA.Strings[i]);
        FileName            := ExtractFileName(TotalFilesDirA.Strings[i]);
        FullPathAndName     := FilePath + FileName;
        FileHashA           := CalcTheHashFile(FullPathAndName);
        HashListA.Add(FileHashA);
        FileAndHashListA.Add(FullPathAndName + ':' + FileHashA + ':');
        // Populate display grid for DirA
        sgDirA.Cells[0, i+1] := IntToStr(i+1);
        sgDirA.Cells[1, i+1] := FullPathAndName;
        sgDirA.Cells[2, i+1] := UpperCase(FileHashA);
        sgDirA.Row           := i;
        sgDirA.col           := 1;
        end;

    HashListA.Sort;

    lblTotalFileCountNumberA.Caption := IntToStr(TotalFilesDirA.Count);

    Application.ProcessMessages;

    // Then, list and hash the files in DirB
    lblStatusB.Caption       := 'Counting and examining files in ' + DirB + ' ...please wait';
    TotalFilesDirB           := TStringList.Create;
    TotalFilesDirB.Sorted    := true;
    TotalFilesDirB           := FindAllFilesEx(DirB, '*', True, True);
    TotalFilesDirB.Sort;
    sgDirB.RowCount          := TotalFilesDirB.Count + 1;

    HashListB                := TStringList.Create;
    FileAndHashListB         := TStringList.Create;
    HashListB.Sorted         := true;
    FileAndHashListB.Sorted  := true;

    lblStatusB.Caption       := 'Counting and examining files in ' + DirB + ' ...please wait';
    lblStatusB.Refresh;
    for i := 0 to TotalFilesDirB.Count -1 do
        begin
          FilePath             := ExtractFilePath(TotalFilesDirB.Strings[i]);
          FileName             := ExtractFileName(TotalFilesDirB.Strings[i]);
          FullPathAndName      := FilePath + FileName;
          FileHashB            := CalcTheHashFile(FullPathAndName);
          HashListB.Add(FileHashB);
          FileAndHashListB.Add(FullPathAndName + ':' + FileHashB + ':');
          // Populate display grid for DirB
          sgDirB.Cells[0, i+1] := IntToStr(i+1);
          sgDirB.Cells[1, i+1] := FullPathAndName;
          sgDirB.Cells[2, i+1] := Uppercase(FileHashB);
          sgDirB.Row           := i;
          sgDirB.col           := 1;
        end;
    HashListB.Sort;
    FileAndHashListB.Sort;

    lblTotalFileCountNumberB.Caption := IntToStr(TotalFilesDirB.Count);
    lblStatusB.Caption := 'Comparing files in ' + DirA + ' against files in ' + DirB + ' ...please wait';
    lblStatusB.Refresh;
    Application.ProcessMessages;
    // Now work out where the differences are.
    // Start by establishing if the dirs are identical : same no of files + same hashes = matching dirs
    if TotalFilesDirB.Count > TotalFilesDirA.Count then
      begin
        lblFileCountDiffB.Caption := IntToStr(TotalFilesDirB.Count - TotalFilesDirA.Count);
      end
    else if TotalFilesDirA.Count > TotalFilesDirB.Count then
      begin
        lblFileCountDiffB.Caption := IntToStr(TotalFilesDirA.Count - TotalFilesDirB.Count);
      end
    else lblFileCountDiffB.Caption := '0';

    { If there is no difference between file count, then if all the files are
      actually the same files, the hash lists themselves will be identical if there
      were no errors or no file mistmatches.
      So instead of comparing each hash line by line, just hash the two hash lists and see if they match
      However, we don't know whether DirA or DirB is the one that might have most files in,
      so we do a count of each subtracted by the other
    }
    if ((TotalFilesDirB.Count - TotalFilesDirA.Count) = 0) or ((TotalFilesDirA.Count - TotalFilesDirB.Count) = 0) then
      begin
      // We compare the hashlists using the developers choice of hash alg, i.e. SHA1
      HashOfListA    := SHA1Print(SHA1String(HashListA.Text));
      HashOfListB    := SHA1Print(SHA1String(HashListB.Text));
      if HashOfListA = HashOfListB then
        begin
        lblStatusB.Caption := 'Finished examining files. ' + DirA + ' matches ' + DirB;
        lblStatusB.Refresh;
        lblHashMatchB.Caption:= 'MATCH!';
        end
      else
        begin
          // So the file counts match but the hash lists differ.
          lblStatusB.Caption    := DirA + ' does not match match ' + DirB;
          lblHashMatchB.Caption := 'MIS-MATCH! File count is the same, but hashes differ.';
          MisMatchHashCompare(HashListA, HashListB, FileAndHashListA, FileAndHashListB);
        end;
      end;

    // If both matched, the previous loop will have been executed.
    // If, however, one dir has a higher file count than the other, the following loop runs
    // Start of Mis-Match Loop:
    if (TotalFilesDirB.Count < TotalFilesDirA.Count) or (TotalFilesDirB.Count > TotalFilesDirA.Count) then
      begin
        lblHashMatchB.Caption:= 'MIS-MATCH! File counts are different.';
        FileAndHashListA.Sort;
        FileAndHashListB.Sort;
        MisMatchFileCountCompare(HashListA, HashListB, FileAndHashListA, FileAndHashListB);
      end; // End of mis-match loop
  finally
    HashListA.Free;
    TotalFilesDirA.Free;
    FileAndHashListA.Free;

    TotalFilesDirB.Free;
    FileAndHashListB.Free;
    HashListB.Free;

    // Only enable the copy to clipboard and save button if the grids have more
    // rows of data in them besides the header row.
    if sgDirA.RowCount > 1 then btnCopyToClipboardA.Enabled := true;
    if sgDirB.RowCount > 1 then btnCopyToClipboardB.Enabled := true;
    if (sgDirA.RowCount > 1) or (sgDirB.RowCount > 1) then
      btnSaveComparisons.Enabled  := true;
    Application.ProcessMessages;
  end;

  // Compute timings and display them
  EndTime                  := Now;
  lblTimeFinishedB.Caption := FormatDateTime('dd/mm/yy hh:mm:ss', EndTime);
  TimeTaken                := EndTime - StartTime;
  strTimeTaken             := FormatDateTime('h" hrs, "n" min, "s" sec"', TimeTaken);
  lblTimeTakenB.Caption    := strTimeTaken;
  Application.ProcessMessages;
end;

// btnClearTextAreaClick : Clears the whole text field if the user requests to do so
procedure TMainForm.btnClearTextAreaClick(Sender: TObject);
begin
  memoHashText.Clear;
end;

// ClearText : Invoked OnEnter of the text field only if the standing text exists
procedure TMainForm.ClearText(Sender: TObject);
begin
  if memoHashText.Lines[0] = 'Type or paste text here - hash will update as you type' then memoHashText.Clear;
end;

// MisMatchCompare takes two hash lists generated from two directories, along with
// two other lists that include both the hashes and the filenames, and it compares
// one pair against the other and highlights the mis matches.
procedure TMainForm.MisMatchFileCountCompare(HashListA, HashListB, FileAndHashListA, FileAndHashListB : TStringList);
var
  i, indexA, indexB,  HashPosStart , FileNameAndPathPosStart, FileNameAndPathPosEnd : integer;
  MisMatchList : TStringList;
  MissingHash, ExtractedFileName : string;

begin
  i := 0;
  indexA := 0;
  indexB := 0;
  HashPosStart := 0;
  FileNameAndPathPosStart := 0;
  FileNameAndPathPosEnd := 0;

  try
    MismatchList := TStringList.Create;

    // Check the content of ListB against ListA

    lblStatusB.Caption := 'Checking files in ' + DirB + ' against those in ' + DirA;
    lblStatusB.Refresh;
    for i := 0 to HashListB.Count -1 do
     begin
       if not HashListA.Find(HashListB.Strings[i], indexA) then
         begin
           MissingHash := HashListB.Strings[i];
           HashPosStart := Pos(MissingHash, FileAndHashListB.Text);
           FileNameAndPathPosEnd := RPosEx(':', FileAndHashListB.Text, HashPosStart);
           FileNameAndPathPosStart := RPosEx(':', FileAndHashListB.Text, FileNameAndPathPosEnd -1);
           if (HashPosStart > 0) and (FileNameAndPathPosStart > 0) and (FileNameAndPathPosEnd > 0) then
             begin
               ExtractedFileName := Copy(FileAndHashListB.Text, FileNameAndPathPosStart -1, (FileNameAndPathPosEnd - FileNameAndPathPosStart) +1);
               MisMatchList.Add(ExtractedFileName + ' ' + MissingHash + ' is NOT in both directories');
             end;
         end;
     end;

    // Check the content of ListA against ListB

    lblStatusB.Caption := 'Checking files in ' + DirA + ' against those in ' + DirB;
    lblStatusB.Refresh;
    for i := 0 to HashListA.Count -1 do
     begin
       if not HashListB.Find(HashListA.Strings[i], indexA) then
         begin
           MissingHash := HashListA.Strings[i];
           HashPosStart := Pos(MissingHash, FileAndHashListA.Text);
           FileNameAndPathPosEnd := RPosEx(':', FileAndHashListA.Text, HashPosStart);
           FileNameAndPathPosStart := RPosEx(':', FileAndHashListA.Text, FileNameAndPathPosEnd -1);
           if (HashPosStart > 0) and (FileNameAndPathPosStart > 0) and (FileNameAndPathPosEnd > 0) then
             begin
               ExtractedFileName := Copy(FileAndHashListA.Text, FileNameAndPathPosStart -1, (FileNameAndPathPosEnd - FileNameAndPathPosStart) +1);
               MisMatchList.Add(ExtractedFileName + ' ' + MissingHash + ' is NOT in both directories');
             end;
         end;
     end;

    // Notify user of mis-matched files that are in one dir but not the other
    if (MisMatchList.Count > 0) then
     begin
       lblStatusB.Caption := 'There is a mis-match between the two directories.';
       ShowMessage(MisMatchList.Text)
     end
     else
     begin
       ShowMessageFmt('Dir A and Dir B contain %d identical files',[HashListB.Count]);
     end;
    finally // Finally for MisMatch
      if assigned (MisMatchList) then MismatchList.Free;
    end;
end;

// MisMatchHashCompare : When file counts match in both directories but hashes differ, this works out what files are different by hash
procedure TMainForm.MisMatchHashCompare(HashListA, HashListB, FileAndHashListA, FileAndHashListB : TStringList);
var
  i, indexA, indexB,  HashPosStart , FileNameAndPathPosStart, FileNameAndPathPosEnd : integer;
  MisMatchList : TStringList;
  MissingHash, ExtractedFileName : string;

begin
  i := 0;
  indexA := 0;
  indexB := 0;
  HashPosStart := 0;
  FileNameAndPathPosStart := 0;
  FileNameAndPathPosEnd := 0;

  try
    MismatchList := TStringList.Create;

    // Check the content of ListB against ListA

    lblStatusB.Caption := 'Checking files in ' + DirB + ' against those in ' + DirA;
    lblStatusB.Refresh;
    for i := 0 to HashListB.Count -1 do
     begin
       if not HashListA.Find(HashListB.Strings[i], indexA) then
         begin
           MissingHash := HashListB.Strings[i];
           HashPosStart := Pos(MissingHash, FileAndHashListB.Text);
           FileNameAndPathPosEnd := RPosEx(':', FileAndHashListB.Text, HashPosStart);
           FileNameAndPathPosStart := RPosEx(':', FileAndHashListB.Text, FileNameAndPathPosEnd -1);
           if (HashPosStart > 0) and (FileNameAndPathPosStart > 0) and (FileNameAndPathPosEnd > 0) then
             begin
               ExtractedFileName := Copy(FileAndHashListB.Text, FileNameAndPathPosStart -1, (FileNameAndPathPosEnd - FileNameAndPathPosStart) +1);
               MisMatchList.Add(ExtractedFileName + ' ' + MissingHash + ' is a hash mismatch');
             end;
         end;
     end;

    // Check the content of ListA against ListB

    lblStatusB.Caption := 'Checking files in ' + DirA + ' against those in ' + DirB;
    lblStatusB.Refresh;
    for i := 0 to HashListA.Count -1 do
     begin
       if not HashListB.Find(HashListA.Strings[i], indexA) then
         begin
           MissingHash := HashListA.Strings[i];
           HashPosStart := Pos(MissingHash, FileAndHashListA.Text);
           FileNameAndPathPosEnd := RPosEx(':', FileAndHashListA.Text, HashPosStart);
           FileNameAndPathPosStart := RPosEx(':', FileAndHashListA.Text, FileNameAndPathPosEnd -1);
           if (HashPosStart > 0) and (FileNameAndPathPosStart > 0) and (FileNameAndPathPosEnd > 0) then
             begin
               ExtractedFileName := Copy(FileAndHashListA.Text, FileNameAndPathPosStart -1, (FileNameAndPathPosEnd - FileNameAndPathPosStart) +1);
               MisMatchList.Add(ExtractedFileName + ' ' + MissingHash + ' is a hash mismatch');
             end;
         end;
     end;

    // Notify user of mis-matched files that are in one dir but not the other
    if (MisMatchList.Count > 0) then
     begin
       lblStatusB.Caption := 'There is a hash mis-match between the two directories.';
       ShowMessage(MisMatchList.Text)
     end
     else
     begin
       ShowMessageFmt('Dir A and Dir B contain %d identical files',[HashListB.Count]);
     end;
    finally // Finally for MisMatch
      if assigned (MisMatchList) then MismatchList.Free;
    end;

end;


procedure TMainForm.Button6SelectSourceClick(Sender: TObject);
begin
  // Now enable directory selection of source
  ShowMessage('NOTE: This feature is designed for hashing and copying typical user space files and not OS system critical files or files currently in use. Attempting to copy such files may result in failure. Click OK to proceed beyond this warning and then either continue with your directory selection or click cancel to abort');
  SelectDirectoryDialog2.Title := 'Select SOURCE directory to copy FROM ';
  if SelectDirectoryDialog2.Execute then
    begin
      if DirectoryExists(UTF8ToSys(SelectDirectoryDialog2.FileName)) then
        begin
          Edit2SourcePath.Text := UTF8ToSys(SelectDirectoryDialog2.FileName);
          SourceDir := UTF8ToSys(SelectDirectoryDialog2.FileName);
          SourceDirValid := TRUE;
        end
      else
        ShowMessage('Source directory does not exist or has not been specified. Error code: ' +  SysErrorMessageUTF8(GetLastOSError));
    end;
end;

procedure TMainForm.Button7SelectDestinationClick(Sender: TObject);
begin
  // Now enable directory selection of destination
  SelectDirectoryDialog3.Title := 'Select write-enabled DESTINATION directory to copy TO ';
  if SelectDirectoryDialog3.Execute then
    begin
      if DirectoryExists(UTF8ToSys(SelectDirectoryDialog3.FileName)) then
        begin
          Edit3DestinationPath.Text := UTF8ToSys(SelectDirectoryDialog3.FileName);
          DestDir := UTF8ToSys(SelectDirectoryDialog3.FileName);
          DestDirValid := TRUE;
          if SourceDirValid AND DestDirValid = TRUE then
            begin
              // Now enable the 'Go!' button as both SourceDir and DestDir are valid
              Button8CopyAndHash.Enabled := true;
            end;
        end
      else
        ShowMessage('Destination directory does not exist or has not been specified. Error code: ' +  SysErrorMessageUTF8(GetLastOSError));
    end;
end;

procedure TMainForm.Button8CopyAndHashClick(Sender: TObject);
begin
  CopyAndHashGrid.Visible      := false; // Hide the grid if it was left visible from an earlier run
  lblNoOfFilesToExamine.Caption:= '';
  lblNoOfFilesToExamine2.Caption  := '';
  lblFilesCopiedPercentage.Caption:= '';
  lblDataCopiedSoFar.Caption   := '';
  lblTimeTaken6A.Caption       := '...';
  lblTimeTaken6B.Caption       := '...';
  lblTimeTaken6C.Caption       := '...';
  Label3.Caption := ('Counting files...please wait');
  StatusBar3.Caption := ('Counting files...please wait');
  Application.ProcessMessages;
  ProcessDir(SourceDir);
  Label3.Caption := ('Finished.');

  // Clear the variables for the next run if it is run again without restarting
  SourceDir := '';
  DestDir := '';
  SourceDirValid := FALSE;
  DestDirValid := FALSE;

  if SourceDirValid AND DestDirValid = FALSE then
    begin
      // Now disable the 'Go!' button again
      Button8CopyAndHash.Enabled := false;
    end;
  Application.ProcessMessages;
end;

procedure TMainForm.FileTypeMaskCheckBox1Change(Sender: TObject);
begin
  if FileMaskField.Visible then
    begin
    FileMaskField.Visible := false
    end
  else if FileMaskField.Visible = false then
    begin
    FileMaskField.Visible := true;
    end;
  {$IFDEF LINUX}
  if FileTypeMaskCheckBox1.Checked then
    ShowMessage('Remember *.JPG and *.jpg are different extension types in Linux!');
 {$ENDIF}

  {$ifdef UNIX}
    {$ifdef Darwin}
    if FileTypeMaskCheckBox1.Checked then
    ShowMessage('Remember *.JPG and *.jpg are different extension types in Apple Mac!');

    {$ENDIF}
 {$ENDIF}
end;


procedure TMainForm.btnClipboardResults2Click(Sender: TObject);
begin
  try
    CopyAndHashGrid.CopyToClipboard();
  finally
    ShowMessage('Grid content now in clipboard...Paste (Ctrl+V) into spreadsheet or text editor')
  end
end;

procedure TMainForm.btnCompareTwoFilesClick(Sender: TObject);
var
  FileA, FileB, FileAHash, FileBHash : string;
begin
  FileA                      := '';
  FileB                      := '';
  FileAHash                  := '';
  FileBHash                  := '';
  lblHashMatchResult.Caption := '';
  lblFileAHash.Caption       := '';
  lblFileBHash.Caption       := '';

  FileA := Trim(lblFileAName.Caption);
  FileB := Trim(lblFileBName.Caption);

  if (FileExistsUTF8(FileA) = false) or (FileExistsUTF8(FileB) = false) then
  begin
    StatusBar4.SimpleText := 'BOTH FILES MUST BE SELECTED!';
    Application.ProcessMessages;
    Abort;
  end
  else
    begin
      // FileA
      StatusBar4.SimpleText := 'Computing hash of ' + FileA + '...';

      if FileExistsUTF8(FileA) then
      begin
        Application.ProcessMessages;
        FileAHash := Uppercase(CalcTheHashFile(FileA));
        lblFileAHash.Caption := FileAHash;
      end
      else ShowMessage('File A is invalid or cannot be accessed');

      //FileB
      StatusBar4.SimpleText := 'Computing hash of ' + FileB + '...';
      if FileExistsUTF8(FileB) then
      begin
        Application.ProcessMessages;
        FileBHash := Uppercase(CalcTheHashFile(FileB));
        lblFileBHash.Caption := FileBHash;
      end
      else ShowMessage('File B is invalid or cannot be accessed');

      // Compare FileA and FileB Hash values
      CompareTwoHashes(FileAHash, FileBHash);
      StatusBar4.SimpleText := 'Hash comparison complete.';
      btnCompareTwoFilesSaveAs.Enabled := true;
      Application.ProcessMessages;
    end;
end;

procedure TMainForm.btnCompareTwoFilesSaveAsClick(Sender: TObject);
var
  slCompareTwoFiles : TStringList;
begin
  slCompareTwoFiles := TStringList.Create;
  slCompareTwoFiles.Add('File A: ' + lblFileAName.Caption + ', ' + 'Hash: ' + lblFileAHash.Caption);
  slCompareTwoFiles.Add('File B: ' + lblFileBName.Caption + ', ' + 'Hash: ' + lblFileBHash.Caption);
  slCompareTwoFiles.Add('Result: ' + lblHashMatchResult.Caption);

  if SaveDialog5.Execute then
  begin
    SaveDialog5.InitialDir := GetCurrentDir;
    slCompareTwoFiles.SaveToFile(SaveDialog5.FileName);
  end;
  slCompareTwoFiles.Free;
end;

// Procedure CompareTwoHashes : Simply checks two hash strings and compares them
procedure TMainForm.CompareTwoHashes(FileAHash, FileBHash : string);
begin
  lblHashMatchResult.Caption := '';
  if FileAHash = FileBHash then
  begin
  lblHashMatchResult.Caption:= 'MATCH!';
  end
  else
  lblHashMatchResult.Caption:= 'MIS-MATCH!';
end;

procedure TMainForm.btnDirAClick(Sender: TObject);
begin
  SelectDirectoryDialog4.Execute;
  lblDirAName.Caption := SelectDirectoryDialog4.FileName;
end;

procedure TMainForm.btnDirBClick(Sender: TObject);
begin
  SelectDirectoryDialog5.Execute;
  lblDirBName.Caption := SelectDirectoryDialog5.FileName;
end;

procedure TMainForm.btnCopyToClipboardAClick(Sender: TObject);
begin
  sgDirA.CopyToClipboard(false);
  ShowMessage('Content of Grid A is in clipboard. Ctrl+V to paste it elsewhere');
end;

procedure TMainForm.btnCopyToClipboardBClick(Sender: TObject);
begin
  sgDirB.CopyToClipboard(false);
  ShowMessage('Content of Grid B is in clipboard. Ctrl+V to paste it elsewhere');
end;


// Used in "Compare Two Files" tab, to select File A
procedure TMainForm.btnFileACompareClick(Sender: TObject);
begin
  btnCompareTwoFilesSaveAs.Enabled := false;
  if OpenDialog1.Execute then
  begin
    lblFileAName.Caption := OpenDialog1.FileName;
  end;
end;
// Used in "Compare Two Files" tab, to select FileB
procedure TMainForm.btnFileBCompareClick(Sender: TObject);
begin
  btnCompareTwoFilesSaveAs.Enabled := false;
  if OpenDialog1.Execute then
  begin
    lblFileBName.Caption := OpenDialog1.FileName;
  end;
end;

procedure TMainForm.btnClipboardHashValueClick(Sender: TObject);
begin
  try
    memoHashText.CopyToClipboard;
  finally
   ShowMessage('Hash value is in clipboard');
  end;
end;

// For users hashing a single file, where they decide to switch the hash choice.
// Saves them re-adding the file again.
procedure TMainForm.AlgorithmChoiceRadioBox2SelectionChanged(Sender: TObject);
var
  HashValue : ansistring;
begin
  if edtFileNameToBeHashed.Text <> 'File being hashed...' then
    begin
      memFileHashField.Clear;
      StatusBar1.SimpleText := 'RECOMPUTING NEW HASH VALUE...Please wait.';
      Application.ProcessMessages;
      HashValue := CalcTheHashFile(edtFileNameToBeHashed.Text);
      memFileHashField.Lines.Add(Uppercase(HashValue));
      StatusBar1.SimpleText := 'RECOMPUTED NEW HASH VALUE.';
    end;
end;

procedure TMainForm.AlgorithmChoiceRadioBox5SelectionChanged(Sender: TObject);
var
  HashValueA, HashValueB : ansistring;
begin
  HashValueA := '';
  HashValueB := '';
  if FileExists(lblFileAName.Caption) and FileExists(lblFileBName.Caption) then
    begin
      StatusBar4.SimpleText := 'RECOMPUTING NEW HASH VALUES...Please wait.';
      Application.ProcessMessages;
      HashValueA := Uppercase(CalcTheHashFile(lblFileAName.Caption));
      lblFileAHash.Caption := HashValueA;
      Application.ProcessMessages;
      HashValueB := Uppercase(CalcTheHashFile(lblFileBName.Caption));
      lblFileBHash.Caption := HashValueB;
      StatusBar4.SimpleText := 'RECOMPUTED NEW HASH VALUES.';
      Application.ProcessMessages;
    end;
end;
// As strings are so quick to compute, I have used the DCPCrypt library for all
// of the 4 hashing algorithms for consistancy and simplicity. This differs though
// for file and disk hashing, where speed is more important - see CalcTheHashFile

function TMainForm.CalcTheHashString(strToBeHashed:ansistring):string;

  var
    TabRadioGroup1: TRadioGroup;
    varMD5Hash: TDCP_MD5;
    varSHA1Hash: TDCP_SHA1;
    varSHA256Hash: TDCP_SHA256;
    varSHA512Hash: TDCP_SHA512;

    DigestMD5: array[0..31] of byte;     // MD5 produces a 128 bit digest (32 byte output)
    DigestSHA1: array[0..31] of byte;    // SHA1 produces a 160 bit digest (32 byte output)
    DigestSHA256: array[0..31] of byte;  // SHA256 produces a 256 bit digest (32 byte output)
    DigestSHA512: array[0..63] of byte;  // SHA512 produces a 512 bit digest (64 byte output)

    i: integer;
    GeneratedHash: string;
    SourceData : ansistring;

  begin
    SourceData := '';
    GeneratedHash := '';
    SourceData := strToBeHashed;
    if Length(SourceData) > 0 then
      begin
        case PageControl1.TabIndex of
          0: TabRadioGroup1 := AlgorithmChoiceRadioBox1;  //RadioGroup on the 1st tab.
          1: TabRadioGroup1 := AlgorithmChoiceRadioBox2;  //RadioGroup on the 2nd tab.
          2: TabRadioGroup1 := AlgorithmChoiceRadioBox3;  //RadioGroup on the 3rd tab.
          3: TabRadioGroup1 := AlgorithmChoiceRadioBox4;  //RadioGroup on the 4th tab.
          4: TabRadioGroup1 := AlgorithmChoiceRadioBox6;  //RadioGroup on the 5th tab.
        end;

        case TabRadioGroup1.ItemIndex of
          0: begin
               varMD5Hash := TDCP_MD5.Create(nil);        // create the hash instance
               varMD5Hash.Init;                           // initialize it
               varMD5Hash.UpdateStr(SourceData);          // hash the string
               varMD5Hash.Final(DigestMD5);               // produce the digest
               varMD5Hash.Free;                           // Free the resource
               for i := 0 to 15 do                        // Generate 32 (16 hex values)character output
                 GeneratedHash := GeneratedHash + IntToHex(DigestMD5[i],2);
             end;
          1: begin
               varSHA1Hash := TDCP_SHA1.Create(nil);
               varSHA1Hash.Init;
               varSHA1Hash.UpdateStr(SourceData);
               varSHA1Hash.Final(DigestSHA1);
               varSHA1Hash.Free;
               for i := 0 to 19 do                        // 40 (20 hex values) character output
                GeneratedHash := GeneratedHash + IntToHex(DigestSHA1[i],2);
             end;
          2: begin
               varSHA256Hash := TDCP_SHA256.Create(nil);
               varSHA256Hash.Init;
               varSHA256Hash.UpdateStr(SourceData);
               varSHA256Hash.Final(DigestSHA256);
               varSHA256Hash.Free;
               for i := 0 to 31 do                        // 64 (32 hex values) character output
                GeneratedHash := GeneratedHash + IntToHex(DigestSHA256[i],2);
             end;
          3: begin
               varSHA512Hash := TDCP_SHA512.Create(nil);
               varSHA512Hash.Init;
               varSHA512Hash.UpdateStr(SourceData);
               varSHA512Hash.Final(DigestSHA512);
               varSHA512Hash.Free;
               for i := 0 to 63 do                        // 128 (64 hex values) character output
                GeneratedHash := GeneratedHash + IntToHex(DigestSHA512[i],2);
             end;
      end;
    end;
    result := GeneratedHash;  // return the resultant hash digest, if successfully computed
  end;

function TMainForm.CalcTheHashFile(FileToBeHashed:string):string;
  var
    {MD5 and SHA1 utilise the LCL functions, whereas SHA256 and SHA512 utilise
    the DCPCrypt library. MD5 and SHA1 from LCL seem to be much faster for large
    files and disks than the DCPCrypt ones, so DCPCrypt only used for SHA256\512
    on the grounds that there is no other LCL utilisation to choose from, yet.
    Also, FileStreams are used for SHA256/512.
    Streams are not necessary for MD5 and SHA1.}
    TabRadioGroup2: TRadioGroup;
    varSHA256Hash: TDCP_SHA256;
    varSHA512Hash: TDCP_SHA512;

    DigestSHA256: array[0..31] of byte;  // SHA256 produces a 256 bit digest (32 byte output)
    DigestSHA512: array[0..63] of byte;  // SHA512 produces a 512 bit digest (64 byte output)

    i : integer;
    SourceDataSHA256, SourceDataSHA512: TFileStreamUTF8;
    GeneratedHash: string;

  begin
    SourceDataSHA256 := nil;
    SourceDataSHA512 := nil;
    GeneratedHash := '';

    case PageControl1.TabIndex of
      0: TabRadioGroup2 := AlgorithmChoiceRadioBox1;  //RadioGroup for Text.
      1: TabRadioGroup2 := AlgorithmChoiceRadioBox2;  //RadioGroup for File.
      2: TabRadioGroup2 := AlgorithmChoiceRadioBox3;  //RadioGroup for FileS.
      3: TabRadioGroup2 := AlgorithmChoiceRadioBox4;  //RadioGroup for Copy.
      4: TabRadioGroup2 := AlgorithmChoiceRadioBox5;  //RadioGroup for Compare Two Files.
      5: TabRadioGroup2 := AlgorithmChoiceRadioBox6;  //RadioGroup for Compare Direcories.
    end;

    case TabRadioGroup2.ItemIndex of
      0: begin
           if FileSize(FileToBeHashed) > 1048576 then    // if file > 1Mb
             begin
              GeneratedHash := MD5Print(MD5File(FileToBeHashed, 2097152));    //2Mb buffer
             end
           else
           if FileSize(FileToBeHashed) = 0 then
             begin
             GeneratedHash := 'Not computed, zero byte file';
             end
           else
            GeneratedHash := MD5Print(MD5File(FileToBeHashed));            //1024 bytes buffer
         end;
      1: begin
           if FileSize(FileToBeHashed) > 1048576 then
             begin
               GeneratedHash := SHA1Print(SHA1File(FileToBeHashed, 2097152));  //2Mb buffer
             end
           else
           if FileSize(FileToBeHashed) = 0 then
             begin
             GeneratedHash := 'Not computed, zero byte file';
             end
           else
             GeneratedHash := SHA1Print(SHA1File(FileToBeHashed))            //1024 bytes buffer
         end;
      2: begin
           // The LCL does not have a SHA256 implementation, so DCPCrypt used instead
           // Note the use of UTF8 FileStreams, to cope with Unicode on Windows
           SourceDataSHA256 := TFileStreamUTF8.Create(FileToBeHashed, fmOpenRead);
           if SourceDataSHA256 <> nil then
             begin
             i := 0;
             varSHA256Hash := TDCP_SHA256.Create(nil);
             varSHA256Hash.Init;
             varSHA256Hash.UpdateStream(SourceDataSHA256, SourceDataSHA256.Size);
             varSHA256Hash.Final(DigestSHA256);
             varSHA256Hash.Free;
             for i := 0 to 31 do                        // 64 character output
               GeneratedHash := GeneratedHash + IntToHex(DigestSHA256[i],2);
             end;  // End of SHA256 else if
           // If the file is a zero byte file, override the default zero size hash
           // with a "not computed" message, rather than a 'fake' hash.
           if SourceDataSHA256.Size = 0 then
             begin
             GeneratedHash := 'Not computed, zero byte file';
             end;
         SourceDataSHA256.Free;
         end;
       3: begin
            // The LCL does not have a SHA512 implementation, so DCPCrypt used instead
            // Note the use of UTF8 FileStreams, to cope with Unicode on Windows
            SourceDataSHA512 := TFileStreamUTF8.Create(FileToBeHashed, fmOpenRead);
            if SourceDataSHA512 <> nil then
              begin
              i := 0;
              varSHA512Hash := TDCP_SHA512.Create(nil);
              varSHA512Hash.Init;
              varSHA512Hash.UpdateStream(SourceDataSHA512, SourceDataSHA512.Size);
              varSHA512Hash.Final(DigestSHA512);
              varSHA512Hash.Free;
              for i := 0 to 63 do                        // 128 character output
               GeneratedHash := GeneratedHash + IntToHex(DigestSHA512[i],2);
              end;
            // If the file is a zero byte file, override the default zero size hash
            // with a "not computed" message, rather than a 'fake' hash.
            if SourceDataSHA512.Size = 0 then
              begin
              GeneratedHash := 'Not computed, zero byte file';
              end;
          SourceDataSHA512.Free;
          end;
    end;
  result := GeneratedHash;  // return the resultant hash digest, if successfully computed
  end;

procedure TMainForm.HashFile(FileIterator: TFileIterator);
var
  SizeOfFile : int64;
  NameOfFileToHashFull, PathOnly, NameOnly, PercentageProgress : string;
  fileHashValue : ansistring;
  SG : TStringGrid;

begin
  SG := TStringGrid.Create(self);
  SizeOfFile := 0;
  fileHashValue := '';

  if StopScan1 = FALSE then    // If Stop button clicked, cancel scan
    begin
    NameOfFileToHashFull := FileIterator.FileName;
    PathOnly := FileIterator.Path;
    NameOnly := ExtractFileName(FileIterator.FileName);
    SizeOfFile := FileIterator.FileInfo.Size;

    // This function is called by all three tabs seperately but I dont know how
    // to tell it to update the progress bar of its calling tab, so all three
    // updated for now.

    StatusBar1.SimpleText := 'Currently Hashing: ' + NameOfFileToHashFull;
    StatusBar2.SimpleText := 'Currently Hashing: ' + NameOfFileToHashFull;
    StatusBar3.SimpleText := 'Currently Hashing: ' + NameOfFileToHashFull;

    // Now generate the hash value using a custom function and convert the result to uppercase

    FileHashValue := UpperCase(CalcTheHashFile(NameOfFileToHashFull));

    // Now lets update the stringgrid and text fields

    // StringGrid Elements:
    // Col 0 is FileCounter. Col 1 is File Name. Col 2 is Hash. Col 3 is filesize as a string

    RecursiveDisplayGrid1.Cells[0,FileCounter] := IntToStr(FileCounter);
    RecursiveDisplayGrid1.Cells[1,FileCounter] := NameOnly;
    RecursiveDisplayGrid1.Cells[2,FileCounter] := PathOnly;
    RecursiveDisplayGrid1.Cells[3,FileCounter] := FileHashValue;
    RecursiveDisplayGrid1.Cells[4,FileCounter] := IntToStr(SizeOfFile) + ' bytes ' + '(' + FormatByteSize(SizeOfFile) + ')';

    // Dynamically scroll the list so the user always has the most recently hashed
    // file insight

    RecursiveDisplayGrid1.row := FileCounter;

    // Progress Status Elements:

    lblFilesExamined.Caption:= IntToStr(FileCounter);
    PercentageProgress := IntToStr((FileCounter * 100) DIV NoOfFilesInDir2);
    lblPercentageComplete.Caption := PercentageProgress + '%';
    TotalBytesRead := TotalBytesRead + SizeOfFile;
    lblTotalBytesExamined.Caption := FormatByteSize(TotalBytesRead);

    Application.ProcessMessages;
    FileCounter := FileCounter+1;
    end;

  StatusBar1.SimpleText := '';
  StatusBar2.SimpleText := '';
  StatusBar3.SimpleText := '';
  SG.Free;
end;

procedure TMainForm.lblURLBannerClick(Sender: TObject);
var
  QuickHashURL: string;
begin
  QuickHashURL := 'https://sourceforge.net/projects/quickhash/';
  OpenURL(QuickHashURL);
end;

procedure TMainForm.ProcessDir(const SourceDirName: string);

{$IFDEF WINDOWS}
type
  TRange = 'A'..'Z';   // For the drive lettering of Windows systems
{$ENDIF}
var
  i, NoOfFilesCopiedOK, j, k, HashMismtachCount,
    FileCopyErrors, ZeroByteFilesCounter, DupCount : integer;

  SizeOfFile2, TotalBytesRead2, NoFilesExamined, m: Int64;

  SubDirStructure, SourceFileHasHash, DestinationFileHasHash, FinalisedDestDir,
    FinalisedFileName, CopiedFilePathAndName, SourceDirectoryAndFileName,
    FormattedSystemDate, OutputDirDateFormatted,
    CrDateModDateAccDate, CurrentFile, CSVLogFile2, HTMLLogFile2,
    strNoOfFilesToExamine, SubDirStructureParent, strTimeDifference : string;

  SystemDate, StartTime, EndTime, TimeDifference : TDateTime;

  FilesFoundToCopy, DirectoriesFoundList, SLCopyErrors : TStringList;

  {$IFDEF WINDOWS}
  DriveLetter : char;  // For MS Windows drive letter irritances only

  const
    LongPathOverride : string = '\\?\'; // For coping better with 260 MAX_PATH
  {$ENDIF}


  {$IFDEF Darwin}
  const
    LongPathOverride : string = '';     // MAX_PATH is 4096 is Linux & Mac, so not needed
  {$else}
    {$IFDEF UNIX and !$ifdef Darwin}
  const
    LongPathOverride : string = '';
    {$ENDIF}
  {$ENDIF}

begin
  SubDirStructure         := '';
  FinalisedDestDir        := '';
  SourceFileHasHash       := '';
  DestinationFileHasHash  := '';
  CrDateModDateAccDate    := '';
  NoOfFilesCopiedOK       := 0;
  HashMismtachCount       := 0;
  FileCopyErrors          := 0;
  ZeroByteFilesCounter    := 0;
  SizeOfFile2             := 0;
  TotalBytesRead2         := 0;
  DupCount                := 0;
  i                       := 0;
  j                       := 0;
  k                       := 0;
  m                       := 0;

  SLCopyErrors := TStringList.Create;

  // Ensures the selected source directory is set as the directory to be searched
  // and then finds all the files and directories within, storing as a StringList.
  // Check with the user that he wants to proceed before starting the copy, compute
  // the systems date and time settings, display that, and also generate part of
  // the output directory based on time of execution

  // This is for the GUI output
  StartTime  := Now;
  // This is for the user, to alert him if it is incorrect
  SystemDate := Now();
  DateTimeToStr(SystemDate);

  // Date and time for the user, to be displayed later
  FormattedSystemDate := FormatDateTime('dd/mm/yy hh:mm:ss', SystemDate);

  // Date and time for the output directory, to be used later with other dir structures
  OutputDirDateFormatted := FormatDateTime('yy-mm-dd_hhmmss', SystemDate);

  SetCurrentDir(SourceDirName);

  {$IFDEF WINDOWS}
  // FindFilesEx will find hidden files in hidden directories, or hidden files
  // in unhidden directories.
  // On Linux, though, we need different behaviour - see IFDEF below
  if chkNoRecursiveCopy.Checked then          // Does not want recursive
    begin
      if FileTypeMaskCheckBox1.Checked then   // ...and does want a file mask
        begin
          FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, False, True);
        end
      else                                    // but does not want a file mask
        begin
          FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', False, True);
        end;
    end;

  if not chkNoRecursiveCopy.Checked then     // Does want recursive
    begin
      if FileTypeMaskCheckBox1.Checked then   // ...but does want a file mask
        begin
          FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, True, True);
        end
      else                                    // but does not want a file mask
        begin
          FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', True, True);
        end;
    end;
  {$ENDIF}

  {$IFDEF LINUX}
  // Determine whether a file mask, recursive, or hidden files are included
  // On Linux, the "Hidden Files?" button is enabled to allow them to be
  // found and copied as needed
  if chkNoRecursiveCopy.Checked then
    begin
      if FileTypeMaskCheckBox1.Checked then   // ...but does want a file mask
        if chkCopyHidden.Checked then         // ... but does want hidden files
          begin
            FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, False, True);
          end;

      if FileTypeMaskCheckBox1.Checked then   // ...but does want a file mask
        if not chkCopyHidden.Checked then         // ... but does want hidden files
          begin
            FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, False, False);
          end;

       if chkCopyHidden.Checked then         // ... but does want hidden files
         if not FileTypeMaskCheckBox1.Checked then   // ...but does want a file mask
           begin
             FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', False, False);
           end;

       if not FileTypeMaskCheckBox1.Checked then
         if not chkCopyHidden.Checked then
           begin
             FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', False, False);
           end;
    end;

  if not chkNoRecursiveCopy.Checked then
    begin
      if chkCopyHidden.Checked then         // ... but does want hidden files
        if FileTypeMaskCheckBox1.Checked then   // ...but does want a file mask
          begin
            FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, True, True);
          end;

      if chkCopyHidden.Checked then         // ... but does want hidden files
        if not FileTypeMaskCheckBox1.Checked then   // ...but does want a file mask
          begin
            FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', True, True);
          end;

      if not chkCopyHidden.Checked then         // ... but does want hidden files
        if FileTypeMaskCheckBox1.Checked then   // ...but does want a file mask
          begin
            FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, True, False);
          end;

      if not chkCopyHidden.Checked then         // ... but does want hidden files
        if not FileTypeMaskCheckBox1.Checked then   // ...but does want a file mask
          begin
            FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', true, False);
          end;
     end;
  {$ENDIF}

  {$IFDEF UNIX}
    {$IFDEF Darwin}
    // Determine whether a file mask, recursive, or hidden files are included
    // On Apple, same as Linux, the "Hidden Files?" button is enabled to allow them to be
    // found and copied as needed
    if chkNoRecursiveCopy.Checked then
      begin
        if FileTypeMaskCheckBox1.Checked then
          if chkCopyHidden.Checked then
            begin
              FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, False, True);
            end;

        if FileTypeMaskCheckBox1.Checked then
          if not chkCopyHidden.Checked then
            begin
              FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, False, False);
            end;

         if chkCopyHidden.Checked then
           if not FileTypeMaskCheckBox1.Checked then
             begin
               FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', False, False);
             end;

         if not FileTypeMaskCheckBox1.Checked then
           if not chkCopyHidden.Checked then
             begin
               FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', False, False);
             end;
      end;

    if not chkNoRecursiveCopy.Checked then
      begin
        if chkCopyHidden.Checked then
          if FileTypeMaskCheckBox1.Checked then
            begin
              FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, True, True);
            end;

        if chkCopyHidden.Checked then
          if not FileTypeMaskCheckBox1.Checked then
            begin
              FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', True, True);
            end;

        if not chkCopyHidden.Checked then
          if FileTypeMaskCheckBox1.Checked then
            begin
              FilesFoundToCopy := FindAllFilesEx(SourceDirName, FileMaskField.Text, True, False);
            end;

        if not chkCopyHidden.Checked then
          if not FileTypeMaskCheckBox1.Checked then
            begin
              FilesFoundToCopy := FindAllFilesEx(SourceDirName, '*', true, False);
            end;
       end;
    {$ENDIF}
  {$ENDIF}

  if MessageDlg('Proceed?', 'Source directory contains ' + IntToStr(FilesFoundToCopy.Count) + ' mask-matched files, inc sub-dirs. FYI, the host system date settings are : ' + FormattedSystemDate + '. Do you want to proceed?', mtConfirmation,
   [mbCancel, mbNo, mbYes],0) = mrYes then

    begin
    strNoOfFilesToExamine := IntToStr(FilesFoundToCopy.Count);
    lblTimeTaken6A.Caption := FormatDateTime('dd/mm/yy hh:mm:ss', SystemDate);
    Label3.Caption := ('Processing files...please wait');
    Application.ProcessMessages;

    try
      // If the user just wants a list of the source dir, do that. Otherwise, do
      // the copying and hashing and everything after the else

      // 1st if : User wants to just generate a list of dirs & files. Date values added, too
      if CheckBoxListOfDirsAndFilesOnly.Checked then
        begin
        i := 0;
          for i := 0 to FilesFoundToCopy.Count -1 do
            begin
              CurrentFile := FilesFoundToCopy.Strings[i];
              {$IFDEF Windows}
              CrDateModDateAccDate := DateAttributesOfCurrentFile(CurrentFile);
              {$ENDIF}
              CopyAndHashGrid.rowcount    := i + 1;
              CopyAndHashGrid.Cells[0, i] := IntToStr(i);
              CopyAndHashGrid.Cells[1, i] := FilesFoundToCopy.Strings[i];
              CopyAndHashGrid.Cells[5, i] := CrDateModDateAccDate;
              CopyAndHashGrid.row         := i;
              CopyAndHashGrid.col         := 1;
            end;
          ShowMessage('An attempt to compute file date attributes was also conducted. Scroll to the right if they are not visible.');
          btnClipboardResults2.Enabled := true;
        end
      else
      // 2nd if : User wants to just generate a list of directories
      if CheckBoxListOfDirsOnly.Checked then
        begin
        i := 0;
        DirectoriesFoundList := FindAllDirectories(SourceDir, true);
        if DirectoriesFoundList.Count = 0 then
          ShowMessage('No subdirectories found (though files may exist). No data to display.')
        else
          try
            for i := 0 to DirectoriesFoundList.Count -1 do
              begin
                CopyAndHashGrid.rowcount    := i + 1;
                CopyAndHashGrid.Cells[0, i] := IntToStr(i);
                CopyAndHashGrid.Cells[1, i] := DirectoriesFoundList.Strings[i];
                CopyAndHashGrid.Row         := i;
                CopyAndHashGrid.col         := 1;
              end;
          finally
            btnClipboardResults2.Enabled := true;
            DirectoriesFoundList.free;
          end;
        end
      else

      // Else: User wants to do a full copy and hash of all files, so lets begin

      for i := 0 to FilesFoundToCopy.Count -1 do
        begin
          if StopScan1 = FALSE then
            begin
            SourceFileHasHash := '';
            DestinationFileHasHash := '';

            m := FileSize(FilesFoundToCopy.Strings[i]);

            if m >= 0 then
              begin
              StatusBar3.SimpleText := 'Currently hashing and copying: ' + FilesFoundToCopy.Strings[i];

              { Now we have some output directory jiggery pokery to deal with, that
                needs to accomodate both OS's. Firstly,
                In Linux   : /home/ted/SrcDir/ needs to become /home/ted/NewDestDir/home/ted/SrcDir
                In Windows : C:\SrcDir\SubDirA needs to become E:\NewDestDir\SrcDir\SubDirA

                In addition, we need to generate a datestamped parent directory for the output
                in case the user generates several seperate outputs to the same parent dir
              }
                // Firstly, compute the original filename and path, less trailing slash
                SourceDirectoryAndFileName := ChompPathDelim(CleanAndExpandDirectory(FilesFoundToCopy.Strings[i]));

                // Now reformulate the source sub-dir structure, from the selected dir downwards
                // but only if the user has not checked the box "Dont rebuild path?"
                // If he has, then just dump the files to the root of the destination dir
                if chkNoPathReconstruction.Checked = false then
                  begin
                    SubDirStructure := IncludeTrailingPathDelimiter(ExtractFileDir(SourceDirectoryAndFileName));
                  end
                else
                 begin
                    SubDirStructure := IncludeTrailingPathDelimiter(DestDir);
                  end;

                // And also generate a timestamped parent directory for the output dir, named after the time of execution
                SubDirStructureParent := ChompPathDelim(IncludeTrailingPathDelimiter(DestDir) + IncludeTrailingPathDelimiter('QH_' + OutputDirDateFormatted));

              { Now concatenate the original sub directory to the destination directory
                and the datestamped parent directory to form the total path, inc filename
                Note : Only directories containing files will be recreated in destination.
                Empty dirs and files whose extension do match a chosen mask (if any)
                are skipped.
                If user wishes to dump files to root of destination, use destination dir name instead}

                if chkNoPathReconstruction.Checked = false then
                  begin
                    FinalisedDestDir := SubDirStructureParent + SubDirStructure;
                  end
                else
                  begin
                     FinalisedDestDir := SelectDirectoryDialog3.FileName;
                  end;

              {$IFDEF Windows}
              { Due to the nonsensories of Windows drive lettering, we have to allow
                for driver lettering in the finalised destination path.
                This loop finds 'C:' in the middle of the concatanated path and
                return its position. It then deletes 'C:' of 'C:\' if found, or any
                other A-Z drive letter, leaving the '\' for the path
                So, C:\SrcDir\SubDirA becomes E:\NewDestDir\SrcDir\SubDirA instead of
                E:\NewDestDir\C:SrcDir\SubDirA. UNC paths are taken care of by ForceDirectories }

              for DriveLetter in TRange do
                begin
                  k := posex(DriveLetter+':', FinalisedDestDir, 4);
                  Delete(FinalisedDestDir, k, 2);
                end;

              {Now, again, only if Windows, obtain the Created, Modified and Last Accessed
              dates from the sourcefile by calling custom function 'DateAttributesOfCurrentFile'
              Linux does not have 'Created Dates' so this does not need to run on Linux platforms}

              CrDateModDateAccDate := DateAttributesOfCurrentFile(SourceDirectoryAndFileName);

              {$ENDIF}

              {$IFDEF LINUX}
              // Get the 'Last Modified' date, only, for Linux files
              CrDateModDateAccDate := DateAttributesOfCurrentFileLinux(SourceDirectoryAndFileName);
              {$ENDIF}

              {$IFDEF UNIX}
                {$IFDEF Darwin}
              // Get the 'Last Modified' date, only, for Apple Mac files
              CrDateModDateAccDate := DateAttributesOfCurrentFileLinux(SourceDirectoryAndFileName);

                {$ENDIF}
              {$ENDIF}
              // Determine the filename string of the file to be copied
              FinalisedFileName := ExtractFileName(FilesFoundToCopy.Strings[i]);

              // Before copying the file and creating storage areas, lets hash the source file
              SourceFileHasHash := Uppercase(CalcTheHashFile(SourceDirectoryAndFileName));

              // Now create the destination directory structure, if it is not yet created.

              if not DirectoryExistsUTF8(LongPathOverride+FinalisedDestDir) then
                begin
                  if not CustomisedForceDirectoriesUTF8(LongPathOverride+FinalisedDestDir, true) then
                    begin
                      ShowMessage(FinalisedDestDir+' cannot be created. Error code: ' +  SysErrorMessageUTF8(GetLastOSError));
                    end;
                end;

              // Now copy the file to the newly formed or already existing destination dir
              // and hash it. Then check that source and destination hashes match.
              // Then total up how many copied and hashed OK, or not.
              // If the user chooses not to reconstruct source dir structure,
              // check for filename conflicts, create an incrementer to ensure uniqueness,
              // and rename to "name.ext_DuplicatedNameX". Otherwise, reconstruct source path

              if chkNoPathReconstruction.Checked = false then
                begin
                  CopiedFilePathAndName := IncludeTrailingPathDelimiter(FinalisedDestDir) + FinalisedFileName;
                end
                else
                  begin
                    if FileExists(IncludeTrailingPathDelimiter(FinalisedDestDir) + FinalisedFileName) then // ExtractFileName(SourceDirectoryAndFileName)) then
                    begin
                      DupCount := DupCount + 1;
                      CopiedFilePathAndName := IncludeTrailingPathDelimiter(FinalisedDestDir) + FinalisedFileName + '_DuplicatedName' + IntToStr(DupCount);
                    end
                    else
                    CopiedFilePathAndName := IncludeTrailingPathDelimiter(FinalisedDestDir) + FinalisedFileName;
                  end;

              // Now copy the file, either to the reconstructed path or to the root

              if not FileUtil.CopyFile(LongPathOverride+SourceDirectoryAndFileName, LongPathOverride+CopiedFilePathAndName) then
                begin
                  ShowMessage('Failed to copy file : ' + SourceDirectoryAndFileName + ' Error code: ' +  SysErrorMessageUTF8(GetLastOSError));
                  SLCopyErrors.Add('Failed to copy: ' + SourceDirectoryAndFileName + ' ' + SourceFileHasHash);
                  FileCopyErrors := FileCopyErrors + 1;
                end
              else
              DestinationFileHasHash := UpperCase(CalcTheHashFile(LongPathOverride+CopiedFilePathAndName));
              NoOfFilesCopiedOK := NoOfFilesCopiedOK + 1;

              // Check for hash errors
              if SourceFileHasHash <> DestinationFileHasHash then
                begin
                  HashMismtachCount := HashMismtachCount + 1;
                  SLCopyErrors.Add('Hash mismatch. Source file ' + SourceDirectoryAndFileName + ' ' + SourceFileHasHash + ' Hash of copied file: ' + CopiedFilePathAndName + ' ' + DestinationFileHasHash);
                end
              else if SourceFileHasHash = DestinationFileHasHash then
                begin
                // With the display grid, adding one to each value ensures the first row headings do not conceal the first file
                  CopyAndHashGrid.rowcount      := i + 2; // Add a grid buffer count to allow for failed copies - avoids 'Index Out of Range' error
                  CopyAndHashGrid.Cells[0, i+1] := IntToStr(i);
                  CopyAndHashGrid.Cells[1, i+1] := FilesFoundToCopy.Strings[i];
                  CopyAndHashGrid.Cells[2, i+1] := SourceFileHasHash;
                  CopyAndHashGrid.Cells[3, i+1] := CopiedFilePathAndName;
                  CopyAndHashGrid.Cells[4, i+1] := DestinationFileHasHash;
                  CopyAndHashGrid.Cells[5, i+1] := CrDateModDateAccDate;
                  CopyAndHashGrid.row           := i + 1; //NoOfFilesCopiedOK +1 ;
                  CopyAndHashGrid.col           := 1;
                end;

              // Progress Status Elements:
              lblNoOfFilesToExamine.Caption := strNoOfFilesToExamine;
              NoFilesExamined := (i + 1);  // The total of files examined plus those that didnt hash or copy OK
              lblNoOfFilesToExamine2.Caption := IntToStr(NoFilesExamined);
              SizeOfFile2 := FileSize(FilesFoundToCopy.Strings[i]);
              TotalBytesRead2 := TotalBytesRead2 + SizeOfFile2;
              lblDataCopiedSoFar.Caption := FormatByteSize(TotalBytesRead2);
              lblFilesCopiedPercentage.Caption := IntToStr((NoFilesExamined * 100) DIV FilesFoundToCopy.Count) + '%';
              Application.ProcessMessages;
              end; // End of the if m > 0 then statement

            // Otherwise file is probably a zero byte file
            if m = 0 then
              begin
              ZeroByteFilesCounter := ZeroByteFilesCounter + 1; // A file of zero bytes was found in this loop
              end;
          end; // End of the "If Stop button pressed" if
        end;   // End of the 'for Count' of Memo StringList loop

      // Now we can show the grid. Having it displayed for every file as it goes
      // wastes time and isn't especially necessary given the other progress indicators

      CopyAndHashGrid.Visible := true;
      EndTime := Now;
      lblTimeTaken6B.Caption  := FormatDateTime('dd/mm/yy hh:mm:ss', EndTime);
      TimeDifference          := EndTime - StartTime;
      strTimeDifference       := FormatDateTime('h" hrs, "n" min, "s" sec"', TimeDifference);
      lblTimeTaken6C.Caption  := strTimeDifference;

      // Now lets save the generated values to a CSV file.

      if SaveToCSVCheckBox2.Checked then
      begin
        SaveDialog3.Title := 'DONE! Save your CSV text log of results as...';
        // Try to help make sure the log file goes to the users destination dir and NOT source dir!:
        SaveDialog3.InitialDir := DestDir;
        SaveDialog3.Filter := 'Comma Sep|*.csv|Text file|*.txt';
        SaveDialog3.DefaultExt := 'csv';
        if SaveDialog3.Execute then
          begin
            CSVLogFile2 := SaveDialog3.FileName;
            SaveOutputAsCSV(CSVLogFile2, CopyAndHashGrid);
          end;
      end;

      if SaveToHTMLCheckBox2.Checked then
        begin
          i := 0;
          j := 0;
          SaveDialog4.Title := 'DONE! Save your HTML log file of results as...';
          // Try to help make sure the log file goes to the users destination dir and NOT source dir!:
          SaveDialog4.InitialDir := DestDir;
          SaveDialog4.Filter := 'HTML|*.html';
          SaveDialog4.DefaultExt := 'html';
          if SaveDialog4.Execute then
           begin
             HTMLLogFile2 := SaveDialog4.FileName;
             with TStringList.Create do
               try
                 Add('<html>');
                 Add('<title> QuickHash HTML Output </title>');
                 Add('<body>');
                 Add('<p><strong>' + MainForm.Caption + '. ' + 'Log Created: ' + DateTimeToStr(Now)+'</strong></p>');
                 Add('<p><strong>File and Hash listing for: ' + SourceDirName + '</strong></p>');
                 Add('<p>System date & time was ' + FormattedSystemDate + #$0D#$0A +'</p>');
                 Add('<br />');
                 Add('<table border=1>');
                 Add('<tr>');
                 Add('<td>' + 'ID');
                 Add('<td>' + 'Source Name');
                 Add('<td>' + 'Source Hash');
                 Add('<td>' + 'Destination Name');
                 Add('<td>' + 'Destination Hash');
                 Add('<td>' + 'Source Date Attributes');
                 for i := 0 to CopyAndHashGrid.RowCount-1 do
                   begin
                     Add('<tr>');
                     for j := 0 to CopyAndHashGrid.ColCount-1 do
                       Add('<td>' + CopyAndHashGrid.Cells[j,i] + '</td>');
                       add('</tr>');
                   end;
                 Add('</table>');
                 Add('</body>');
                 Add('</html>');
                 SaveToFile(HTMLLogFile2);
               finally
                 Free;
                 HTMLLogFile2 := '';
               end;
           end;
        end;

      // If there is one or more errors, display them to the user and save to a log file
      if Length(SLCopyErrors.Text) > 0 then
       begin
        SLCopyErrors.SaveToFile(IncludeTrailingPathDelimiter(DestDir)+'QHErrorsLog.txt');
        ShowMessage(SLCopyErrors.Text);
      end;

      // All done. End the loops, free resources and notify user
      finally
        FilesFoundToCopy.Free;
        SLCopyErrors.Free;
        StatusBar3.SimpleText := 'Finished.';
        btnClipboardResults2.Enabled := true;
      end;
    ShowMessage('Files copied (zero based counter): ' + IntToStr(NoOfFilesCopiedOK) + '. Copy errors : ' + IntToStr(FileCopyErrors) + '. Hash mismatches: ' + IntToStr(HashMismtachCount) + '. Zero byte files: '+ (IntToStr(ZeroByteFilesCounter)));
    end
  else // End of Proceed Message dialog "Yes, No, Cancel".
   ShowMessage('Process aborted by user.');
   Button8CopyAndHash.Enabled := true;
end;

{$IFDEF Windows}
// FUNCTION FileTimeToDTime - Windows specific,
// kindly acknowledged from xenblaise @ http://forum.lazarus.freepascal.org/index.php?topic=10869.0
function TMainForm.FileTimeToDTime(FTime: TFileTime): TDateTime;
var
  LocalFTime  : TFileTime;
  STime       : TSystemTime;

begin
  FileTimeToLocalFileTime(FTime, LocalFTime);
  FileTimeToSystemTime(LocalFTime, STime);
  Result := SystemTimeToDateTime(STime);
end;

// FUNCTION DateAttributesOfCurrentFile (renamed and customised by Ted) - Windows specific,
// to account for the Created, Modified and Accessed dates of NTFS etc. Linux version
// is below. Code is kindly acknowledged from xenblaise @ http://forum.lazarus.freepascal.org/index.php?topic=10869.0
function TMainForm.DateAttributesOfCurrentFile(var SourceDirectoryAndFileName:string):string;

var
  SR: TSearchRec;
  CreatedDT, LastModifiedDT, LastAccessedDT: TDateTime;

begin
  if FindFirst(SourceDirectoryAndFileName, faAnyFile, SR) = 0 then
    begin
      CreatedDT := FileTimeToDTime(SR.FindData.ftCreationTime);
      LastModifiedDT := FileTimeToDTime(SR.FindData.ftLastWriteTime);;
      LastAccessedDT := FileTimeToDTime(SR.FindData.ftLastAccessTime);;

      Result := ('  Cr: ' + DateTimeToStr(CreatedDT) +
                 '  LMod: ' + DateTimeToStr(LastModifiedDT) +
                 '  LAcc: ' + DateTimeToStr(LastAccessedDT));
    end
  else
    Result := 'Date attributes could not be computed';
end;
{$ENDIF}

{$IFDEF LINUX}
// FUNCTION DateAttributesOfCurrentFileLinux - Same as above but for Linux version
// http://www.freepascal.org/docs-html/rtl/sysutils/fileage.html
function TMainForm.DateAttributesOfCurrentFileLinux(var SourceDirectoryAndFileName:string):string;
var
  SR: TSearchRec;
  LastModifiedDT: TDateTime;

begin
  if FindFirst(SourceDirectoryAndFileName, faAnyFile, SR) = 0 then
    begin
      LastModifiedDT := FileDateTodateTime(FileAgeUTF8(SourceDirectoryAndFileName));
      Result := ('  LMod: ' + DateTimeToStr(LastModifiedDT));
    end
  else
    Result := 'Date attributes could not be computed';
end;

{$ENDIF}

{$IFDEF UNIX}
  {$IFDEF Darwin}
  // FUNCTION DateAttributesOfCurrentFileLinux - Same as above but for Apple Mac version
  // http://www.freepascal.org/docs-html/rtl/sysutils/fileage.html
  function TMainForm.DateAttributesOfCurrentFileLinux(var SourceDirectoryAndFileName:string):string;
  var
    SR: TSearchRec;
    LastModifiedDT: TDateTime;

  begin
    if FindFirst(SourceDirectoryAndFileName, faAnyFile, SR) = 0 then
      begin
        LastModifiedDT := FileDateTodateTime(FileAgeUTF8(SourceDirectoryAndFileName));
        Result := ('  LMod: ' + DateTimeToStr(LastModifiedDT));
      end
    else
      Result := 'Date attributes could not be computed';
  end;

  {$ENDIF}
{$ENDIF}

procedure TMainForm.CheckBoxListOfDirsAndFilesOnlyChange(Sender: TObject);
begin
  if CheckBoxListOfDirsAndFilesOnly.Checked then
    begin
      Button7SelectDestination.Visible := false;
      CheckBoxListOfDirsOnly.Hide;
      Button8CopyAndHash.Enabled := true;
      Edit3DestinationPath.Text := '';
      DestDir := ''
    end
    else if CheckBoxListOfDirsAndFilesOnly.Checked = false then
      begin
        Button7SelectDestination.Visible := true;
        CheckBoxListOfDirsOnly.Visible := true;
      end;
end;

procedure TMainForm.CheckBoxListOfDirsOnlyChange(Sender: TObject);
begin
  if CheckBoxListOfDirsOnly.Checked then
    begin
      Button7SelectDestination.Visible := false;
      CheckBoxListOfDirsAndFilesOnly.Hide;
      Button8CopyAndHash.Enabled := true;
      Edit3DestinationPath.Text := '';
      DestDir := ''
    end
  else if CheckBoxListOfDirsOnly.Checked = false then
    begin
      Button7SelectDestination.Visible := true;
      CheckBoxListOfDirsAndFilesOnly.Visible := true;
    end;
end;

function TMainForm.FormatByteSize(const bytes: QWord): string;
var
  B: byte;
  KB: word;
  MB: QWord;
  GB: QWord;
  TB: QWord;
begin

  B  := 1; //byte
  KB := 1024 * B; //kilobyte
  MB := 1024 * KB; //megabyte
  GB := 1024 * MB; //gigabyte
  TB := 1024 * GB; //terabyte

  if bytes > TB then
    result := FormatFloat('#.## TiB', bytes / TB)
  else
    if bytes > GB then
      result := FormatFloat('#.## GiB', bytes / GB)
    else
      if bytes > MB then
        result := FormatFloat('#.## MiB', bytes / MB)
      else
        if bytes > KB then
          result := FormatFloat('#.## KiB', bytes / KB)
        else
          result := FormatFloat('#.## bytes', bytes) ;
end;



{------------------------------------------------------------------------------
  TO DO : function CustomisedForceDirectoriesUTF8(const Dir: string): Boolean;
  Copied from function ForceDirectoriesUTF8 of 'fileutil.inc' for the purpose
  of eventually ensuring original date attributes are retained by the copied
  directories in Windows. The library function sets the date of the copy process.
 ------------------------------------------------------------------------------}
function TMainForm.CustomisedForceDirectoriesUTF8(const Dir: string; PreserveTime: Boolean): Boolean;

  var
    E: EInOutError;
    ADrv : String;

  function DoForceDirectories(Const Dir: string): Boolean;

  var
    ADir : String;
    APath: String;

  begin
    Result:=True;
    ADir:=ExcludeTrailingPathDelimiter(Dir);

    if (ADir='') then Exit;
    if Not DirectoryExistsUTF8(ADir) then
      begin
        APath := ExtractFilePath(ADir);
        //this can happen on Windows if user specifies Dir like \user\name/test/
        //and would, if not checked for, cause an infinite recusrsion and a stack overflow
        if (APath = ADir) then Result := False
          else Result:=DoForceDirectories(APath);
      If Result then
        {//TO DO : Make this work so that date attr of source directories match the copy
        if PreserveTime then
        DirDate := DateToStr(FileAge(ADir));
        ShowMessage('Value of ADirDate : ' + DirDate);  }
        Result := CreateDirUTF8(ADir);
      end;
  end;

  function IsUncDrive(const Drv: String): Boolean;
  begin
    Result := (Length(Drv) > 2) and (Drv[1] = PathDelim) and (Drv[2] = PathDelim);
  end;

begin
  Result := False;
  ADrv := ExtractFileDrive(Dir);
  if (ADrv<>'') and (not DirectoryExistsUTF8(ADrv))
  {$IFNDEF FORCEDIR_NO_UNC_SUPPORT} and (not IsUncDrive(ADrv)){$ENDIF} then Exit;
  if Dir='' then
    begin
      E:=EInOutError.Create(SCannotCreateEmptyDir);
      E.ErrorCode:=3;
      Raise E;
    end;
  Result := DoForceDirectories(SetDirSeparators(Dir));
end;

procedure TMainForm.SHA1RadioButton3Change(Sender: TObject);
begin

end;

procedure TMainForm.TabSheet3ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

initialization
  {$I unit2.lrs}

end.
