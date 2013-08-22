{
|  termtris: a console mode frontend for learntris, written in free pascal.
|  copyright 2013 michal j wallace. all rights reserved.
|  available to the public under the terms of the MIT/X11 license.
}
{$mode objfpc} {$H+}
program termtris;
uses
  kvm, kbd, cw,
  process,
  processlinetalk in 'lib/processlinetalk.pas',
  sysutils;

function BuildProcess : TProcessLineTalk;
  begin
    result := TProcessLineTalk.Create(Nil);
    result.Executable := './learntris';
    result.Execute;
  end;

procedure Update(s : string);
  var cmd : TProcessLineTalk; ch : char; i: byte;
  begin
    kvm.gotoxy(0,0);
    cmd := BuildProcess;
    if length(s) > 0 then cmd.WriteLine(s);
    cmd.WriteLine('P');
    cmd.WriteLine('?b');
    cmd.WriteLine('q');
    for i := 0 to 21 do begin
      for ch in cmd.ReadLine do begin
	// color codes ('krgybmcwKRGYBMCW')
	if ch in cw.ccolset then kvm.fg(ch)
	else
	  case ch of
	    'O'	: fg($D6); // light orange
	    'o' : fg($AC); // dark orange
	    '.' : if i > 2 then kvm.fg('K')  // dark gray
		  else kvm.fg('k'); // black
	  end;
	Write(ch);
      end;
      WriteLn; ClrEol;
    end;
    // show current bounds:
    cw.cwritexy(25, 0, '|w' + cmd.ReadLine());
    kvm.ClrEol;
    cw.colorxy(0, 23, $7, s);
    kvm.ClrEol;

  end;
 
var
  ch : char;  s : string = '';
begin
  kvm.clrscr;
  repeat
    Update(s); ch := kbd.ReadKey;
    if ch in [#32..#126] then s := s + ch
    else if ch = kbd.BKSP then setlength(s, length(s)-1);
  until ch = ^C
end.
