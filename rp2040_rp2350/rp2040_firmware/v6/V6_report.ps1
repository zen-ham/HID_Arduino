# Poll the board's mount_count / host_reports for ~70s and print every change.
# Run this, then have the user unplug+replug the mouse into the board's USB-A port.
$ErrorActionPreference = 'Stop'
$sig = @'
using System;
using System.Runtime.InteropServices;
public static class Hid {
  [DllImport("hid.dll")] public static extern void HidD_GetHidGuid(out Guid g);
  [DllImport("hid.dll")] public static extern bool HidD_GetPreparsedData(IntPtr h, out IntPtr pp);
  [DllImport("hid.dll")] public static extern bool HidD_FreePreparsedData(IntPtr pp);
  [DllImport("hid.dll")] public static extern int  HidP_GetCaps(IntPtr pp, out HIDP_CAPS caps);
  [DllImport("hid.dll", SetLastError=true)] public static extern bool HidD_SetOutputReport(IntPtr h, byte[] b, int n);
  [StructLayout(LayoutKind.Sequential)] public struct HIDP_CAPS {
    public ushort Usage, UsagePage, InputReportByteLength, OutputReportByteLength, FeatureReportByteLength;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=17)] public ushort[] Reserved;
    public ushort a,b,c,d,e,f,g2,h2,i,j;
  }
  [DllImport("setupapi.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SetupDiGetClassDevs(ref Guid g, IntPtr e, IntPtr h, int f);
  [DllImport("setupapi.dll")] public static extern bool SetupDiEnumDeviceInterfaces(IntPtr s, IntPtr d, ref Guid g, int i, ref SP_DIDATA a);
  [DllImport("setupapi.dll", CharSet=CharSet.Unicode)] public static extern bool SetupDiGetDeviceInterfaceDetail(IntPtr s, ref SP_DIDATA a, IntPtr d, int ds, ref int rq, IntPtr dd);
  [DllImport("setupapi.dll")] public static extern bool SetupDiDestroyDeviceInfoList(IntPtr s);
  [StructLayout(LayoutKind.Sequential)] public struct SP_DIDATA { public int cbSize; public Guid g; public int Flags; public IntPtr Reserved; }
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] public static extern IntPtr CreateFile(string p, uint acc, uint share, IntPtr sa, uint disp, uint flags, IntPtr t);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool ReadFile(IntPtr h, byte[] b, int n, out int r, byte[] ov);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern IntPtr CreateEvent(IntPtr a, bool manual, bool init, string name);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern uint WaitForSingleObject(IntPtr h, uint ms);
  [DllImport("kernel32.dll", SetLastError=true)] public static extern bool GetOverlappedResult(IntPtr h, byte[] ov, out int n, bool wait);
  [DllImport("kernel32.dll")] public static extern bool CancelIo(IntPtr h);
  [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
}
'@
Add-Type -TypeDefinition $sig
$GENREAD=[uint32]2147483648; $GENWRITE=[uint32]1073741824; $OVERLAP=[uint32]1073741824
function New-Ov($e){ $o=New-Object byte[] 32; [BitConverter]::GetBytes([int64]$e).CopyTo($o,24); return $o }
function Paths(){
  $g=[Guid]::Empty; [Hid]::HidD_GetHidGuid([ref]$g)
  $s=[Hid]::SetupDiGetClassDevs([ref]$g,[IntPtr]::Zero,[IntPtr]::Zero,0x12); $out=@(); $i=0
  while($true){ $d=New-Object Hid+SP_DIDATA; $d.cbSize=[Runtime.InteropServices.Marshal]::SizeOf($d)
    if(-not [Hid]::SetupDiEnumDeviceInterfaces($s,[IntPtr]::Zero,[ref]$g,$i,[ref]$d)){break}; $i++
    $rq=0; [Hid]::SetupDiGetDeviceInterfaceDetail($s,[ref]$d,[IntPtr]::Zero,0,[ref]$rq,[IntPtr]::Zero)|Out-Null
    if($rq -le 0){continue}
    $b=[Runtime.InteropServices.Marshal]::AllocHGlobal($rq)
    try{ if([IntPtr]::Size -eq 8){$cb=8}else{$cb=6}; [Runtime.InteropServices.Marshal]::WriteInt32($b,$cb)
      if([Hid]::SetupDiGetDeviceInterfaceDetail($s,[ref]$d,$b,$rq,[ref]$rq,[IntPtr]::Zero)){ $out+=[Runtime.InteropServices.Marshal]::PtrToStringUni([IntPtr]($b.ToInt64()+4)) }
    } finally { [Runtime.InteropServices.Marshal]::FreeHGlobal($b) }
  }
  [Hid]::SetupDiDestroyDeviceInfoList($s)|Out-Null; return $out
}
function Query($h,$payload,$olen,$ilen,$to){
  $ob=New-Object byte[] $olen; $ob[0]=2
  for($k=0;$k -lt $payload.Length -and ($k+1) -lt $olen;$k++){ $ob[$k+1]=$payload[$k] }
  [Hid]::HidD_SetOutputReport($h,$ob,$olen)|Out-Null
  Start-Sleep -Milliseconds 40
  $ev=[Hid]::CreateEvent([IntPtr]::Zero,$false,$false,$null)
  try{
    $ib=New-Object byte[] $ilen; $ov=New-Ov $ev; $r=0
    $ok=[Hid]::ReadFile($h,$ib,$ilen,[ref]$r,$ov)
    if(-not $ok){ $err=[Runtime.InteropServices.Marshal]::GetLastWin32Error()
      if($err -ne 997){ return $null }
      if([Hid]::WaitForSingleObject($ev,$to) -ne 0){ [Hid]::CancelIo($h)|Out-Null; return $null }
      if(-not [Hid]::GetOverlappedResult($h,$ov,[ref]$r,$false)){ return $null }
    }
    if($r -le 0){ return $null }
    $n=[Math]::Min($r,$ilen); $by=New-Object byte[] $n; [Array]::Copy($ib,$by,$n); return ,$by
  } finally { [Hid]::CloseHandle($ev)|Out-Null }
}
function U32($b,$o){ return [BitConverter]::ToUInt32($b,$o) }
function FindBoard(){
  foreach($p in Paths){
    $h=[Hid]::CreateFile($p,($GENREAD -bor $GENWRITE),3,[IntPtr]::Zero,3,$OVERLAP,[IntPtr]::Zero)
    if($h -eq [IntPtr](-1)){continue}
    $pp=[IntPtr]::Zero
    if([Hid]::HidD_GetPreparsedData($h,[ref]$pp)){
      $caps=New-Object Hid+HIDP_CAPS
      if([Hid]::HidP_GetCaps($pp,[ref]$caps) -eq 0x110000 -and $caps.UsagePage -eq 0xFF5A){
        $o=[int]$caps.OutputReportByteLength; if($o -lt 17){$o=17}
        $i2=[int]$caps.InputReportByteLength; if($i2 -lt 17){$i2=17}
        $t=Query $h @(0xFD) $o $i2 800
        if($t -and $t[1] -eq 0xDB){ [Hid]::HidD_FreePreparsedData($pp)|Out-Null; return @{h=$h;o=$o;i=$i2;fd=$t} }
      }
      [Hid]::HidD_FreePreparsedData($pp)|Out-Null
    }
    [Hid]::CloseHandle($h)|Out-Null
  }
  return $null
}

function Ask($h,$o,$i,$bytes){ $r = Query $h $bytes $o $i 1500; if(-not $r){ $r = Query $h $bytes $o $i 1500 }; return $r }
function Hex($b){ if($b.Count -eq 0){ return '' }; return [BitConverter]::ToString([byte[]]$b).Replace('-',' ') }

Write-Output "=== Zelesis V6 report ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) ==="
$b = FindBoard
if(-not $b){
  Write-Output "Board not found. Is it plugged into the PC with its USB-C port, and is it running the V6 firmware?"
  Write-Output "(V5 and older boards use a different channel and are not shown by this script.)"
  exit 1
}

$fd = Ask $b.h $b.o $b.i @(0xFD)
$modeName = @('LEARNING a mouse (capture mode)','passthrough')
Write-Output ""
Write-Output "--- board ---"
Write-Output ("uptime: {0:N0} s   mode: {1}" -f ((U32 $fd 10)/1000.0),$modeName[[int]$fd[14]])
$fv = Ask $b.h $b.o $b.i @(0xFF,9)
if($fv -and $fv[1] -eq 0xA4){ Write-Output ("firmware: {0} (build {1})" -f ([Text.Encoding]::ASCII.GetString($fv,2,8).TrimEnd([char]0)),(U32 $fv 10)) } else { Write-Output "firmware: older than 6.0b2 (no version readout)" }
Write-Output ("reports mouse -> board: {0:N0}   board -> PC: {1:N0}" -f (U32 $fd 2),(U32 $fd 6))

# Where is the board plugged in? A board behind a USB hub (or a dock / front panel header on a hub) showed whole-chip freezes
# under load on the bench that vanished on a direct motherboard port.
$sv = Ask $b.h $b.o $b.i @(0xF6)
if($sv -and $sv[1] -eq 0xB6 -and $sv[2] -eq 1){
  $bvid = '{0:X4}' -f [BitConverter]::ToUInt16($sv,5); $bpid = '{0:X4}' -f [BitConverter]::ToUInt16($sv,7)
  # The mouse itself shares the board's VID:PID when it is also plugged into the PC, so find the BOARD by its own vendor
  # interface (the one after the mirrored mouse interfaces) and look at that interface's parent device.
  $vi = [int]$sv[3]
  $vif = Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -like ("USB\VID_{0}&PID_{1}&MI_{2:D2}\*" -f $bvid,$bpid,$vi) } | Select-Object -First 1
  if($vif){
    $par = (Get-PnpDeviceProperty -InstanceId $vif.InstanceId -KeyName DEVPKEY_Device_Parent -ErrorAction SilentlyContinue).Data
    $lp = $null
    if($par){ $lp = (Get-PnpDeviceProperty -InstanceId $par -KeyName DEVPKEY_Device_LocationPaths -ErrorAction SilentlyContinue).Data }
    if($lp){
      $path = [string]$lp[0]; $hops = ([regex]::Matches($path,'USB\(\d+\)')).Count
      Write-Output ("USB port path: {0}" -f $path)
      if($hops -gt 1){ Write-Output "WARNING: the board is plugged in BEHIND A USB HUB (or a dock / front-panel header). Please plug it directly into a USB port on the back of the PC and test again: hub ports can freeze and reset the board under load." }
      else { Write-Output "the board is plugged directly into the PC (good)" }
    }
  }
}

$s = Ask $b.h $b.o $b.i @(0xF6)
Write-Output ""
Write-Output "--- mouse the board has learned ---"
if($s -and $s[1] -eq 0xB6 -and $s[2] -eq 1){
  $flags = $s[4]
  Write-Output ("VID:PID {0:X4}:{1:X4}   bcdDevice {2:X4}   HID interfaces: {3}" -f [BitConverter]::ToUInt16($s,5),[BitConverter]::ToUInt16($s,7),[BitConverter]::ToUInt16($s,9),$s[3])
  if($flags -band 1){ Write-Output "WARNING: at least one report descriptor was too long to read; that interface is NOT mirrored" }
  if($flags -band 2){ Write-Output "WARNING: the device has more HID interfaces than the board can mirror (6)" }
  for($i=0;$i -lt $s[3];$i++){
    $m = Ask $b.h $b.o $b.i @(0xF7,$i,0xFF)
    $len = [BitConverter]::ToUInt16($m,4)
    $proto = @('none','keyboard','mouse')[[Math]::Min([int]$m[8],2)]
    Write-Output ("  interface {0}: boot={1}/{2}  OUT endpoint={3}  interval={4} ms  max packet={5}  report descriptor {6} bytes" -f $m[6],$m[7],$proto,$m[9],$m[10],$m[11],$len)
    $all = New-Object System.Collections.Generic.List[byte]
    for($c=0;$c -lt [int][Math]::Ceiling($len/11.0);$c++){
      $d = Ask $b.h $b.o $b.i @(0xF7,$i,$c)
      if(-not $d -or $d[1] -ne 0xB7){ break }
      for($k=0;$k -lt 11 -and ($c*11+$k) -lt $len;$k++){ $all.Add($d[6+$k]) }
    }
    Write-Output ("    descriptor: " + (Hex $all.ToArray()))
  }
} else { Write-Output "no mouse learned yet (plug one into the board's USB-A port)" }

$j = Ask $b.h $b.o $b.i @(0xF3)
Write-Output ""
Write-Output "--- injection (what Zelesis uses to move and click) ---"
if($j -and $j[1] -eq 0xB3 -and $j[2] -eq 1){
  Write-Output ("available: yes   interface {0}   clicks: {1}   wheel: {2}   buttons: {3}   X/Y bits: {4}" -f $j[4],(($j[3] -band 1) -ne 0),(($j[3] -band 2) -ne 0),$j[9],$j[11])
} else { Write-Output "available: NO (no interface with a relative X/Y mouse report was found; the mouse still works as a normal mouse)" }

$p = Ask $b.h $b.o $b.i @(0xFF)
Write-Output ""
Write-Output "--- host (USB-A) port ---"
if($p -and $p[1] -eq 0xAF){
  $ls = @('nothing attached / reset','full-speed idle','LOW-SPEED idle','invalid')
  Write-Output ("line state: {0}   connected: {1}   speed at last attach: {2}   attach events: {3}   detach events: {4}   HID interfaces mounted: {5}   status LED running: {6}" -f $ls[$p[4]],(($p[5] -band 2) -ne 0),@('never','full','LOW')[$p[13]],[BitConverter]::ToUInt16($p,9),[BitConverter]::ToUInt16($p,11),$p[14],($p[15] -eq 1))
}

$st = Ask $b.h $b.o $b.i @(0xF5,0)
$rl = Ask $b.h $b.o $b.i @(0xF4)
Write-Output ""
Write-Output "--- health ---"
if($st -and $st[1] -eq 0xB5){ Write-Output ("worst stall: USB-host core {0} ms, main core {1} ms; report buffer high-water {2} of 7; reports dropped {3}" -f [BitConverter]::ToUInt16($st,2),[BitConverter]::ToUInt16($st,4),$st[14],$st[15]) }
if($rl -and $rl[1] -eq 0xB4){ Write-Output ("PC -> mouse relay (mouse software): ok {0}, failed {1}, dropped {2}" -f (U32 $rl 2),(U32 $rl 6),(U32 $rl 10)) }

$ev = Ask $b.h $b.o $b.i @(0xFF,4)
Write-Output ""
Write-Output "--- chip environment ---"
if($ev -and $ev[1] -eq 0xAB){
  $vn = @{6='0.85';7='0.90';8='0.95';9='1.00';10='1.05';11='1.10';12='1.15';13='1.20';14='1.25';15='1.30'}
  Write-Output ("chip temperature {0:N1} C   core voltage {1} V   clock {2} MHz   flash clock divider {3}" -f ([BitConverter]::ToInt16($ev,2)/10.0),$vn[[int]$ev[12]],$ev[13],$ev[14])
  Write-Output ("3.3 V rail noise: worst spread {0} counts (a quiet board shows 10 to 15), seconds with a droop since boot: {1}" -f [BitConverter]::ToUInt16($ev,8),[BitConverter]::ToUInt16($ev,10))
  if($ev[15] -eq 1){ Write-Output "NOTE: the board is in SAFE BOOT (it crashed several times right after start, so it runs at 120 MHz and writes nothing to its flash until the next restart)" }
}

$h = Ask $b.h $b.o $b.i @(0xFA,0,0)
Write-Output ""
Write-Output "--- failure history kept in the board's flash (newest first) ---"
if($h -and $h[1] -eq 0xAA){
  $avail = $h[2]; $total = $h[8]
  if($avail -eq 0){ Write-Output "no failures recorded" } else {
    Write-Output ("{0} events in total, showing {1}" -f $total,$avail)
    $kinds = @{1='hardware watchdog timeout (the chip hung and was reset)';2='software watchdog (the USB host side stalled and was reset)';3='PC stopped polling the board';4='re-learn (a different mouse was plugged in)';5='a core crashed (hardfault)';6='firmware panic';7='where each core was (goes with the entry before it)';8='chip environment just before (goes with the entry before it)';9='hardware state while a core was frozen (goes with the entry before it)';10='hardware state, part 2';11='a spinlock pointer in RAM was found corrupted'}
    $c0 = @{1='loop top';2='hw watchdog feed';3='tud task';4='service_diag';5='drain/merge';6='inside sendReport';7='soft watchdog check';8='re-learn reboot';9='status LED'}
    $c1 = @{1='loop1 top';2='inside tuh_task';3='relay_service';4='mount callback';5='report callback';6='enumeration hooks';7='relay completion callbacks'}
    for($n=0;$n -lt $avail;$n++){
      $p0 = Ask $b.h $b.o $b.i @(0xFA,$n,0); $p1 = Ask $b.h $b.o $b.i @(0xFA,$n,1)
      $kind = [int]$p0[5]; $u0 = U32 $p0 9; $u1 = U32 $p0 13; $u2 = U32 $p1 9
      $name = $kinds[$kind]; if(-not $name){ $name = "kind $kind" }
      if($kind -eq 1){ $d = ("core0 last alive {0} ms, core1 last alive {1} ms; last phase: core0 '{2}', core1 '{3}'" -f $u0,$u1,$c0[[int]$p1[13]],$c1[[int]$p1[14]]) }
      elseif($kind -eq 2){ $d = ("uptime {0} ms; SOF still running {1}, host loop still running {2}" -f $u0,$p1[13],$p1[14]) }
      elseif($kind -eq 4){ $d = ("to device {0:X4}:{1:X4}" -f ($u1 -shr 16),($u1 -band 0xFFFF)) }
      elseif($kind -eq 5){ $d = ("core {0}: pc={1:X8} lr={2:X8} sp={3:X8}  (send this report so it can be decoded)" -f $p1[13],$u0,$u1,$u2) }
      elseif($kind -eq 6){ $d = ("core {0}: called from {1:X8}" -f $p1[13],$u0) }
      elseif($kind -eq 7){ $od = [BitConverter]::ToInt32([BitConverter]::GetBytes([uint32]$u2),0); $d = ("core {0}: pc={1:X8} lr={2:X8} inside interrupt {3}; its sampler ran {4} ms after the core's last sign of life" -f $p1[13],$u0,$u1,$p1[14],$od) }
      elseif($kind -eq 8){ $tc = [int]$p1[14]; if($tc -gt 127){ $tc -= 256 }; $d = ("chip {0} C, core voltage code {1}, ADC max {2} min {3}, worst spread {4}, droop seconds {5}, at uptime {6} ms" -f $tc,$p1[13],($u0 -shr 16),($u0 -band 0xFFFF),($u1 -shr 16),($u1 -band 0xFFFF),$u2) }
      elseif($kind -eq 9){ $d = ("core {0} frozen: spinlocks held {1:X8}, flash divider {2}, flash controller status {3:X2}, FIFO {4}/{5}, XIP {6:X4}, DMA busy {7:X3}" -f $p1[13],$u0,$p1[14],($u1 -band 0xFF),(($u1 -shr 8) -band 0xFF),(($u1 -shr 16) -band 0xFF),($u2 -band 0xFFFF),($u2 -shr 16)) }
      elseif($kind -eq 10){ $d = ("capture stage {0} of 6, USB controller status {1:X8}, PIO0 {2:X8}, PIO1 {3:X8}" -f $p1[13],$u0,$u1,$u2) }
      elseif($kind -eq 11){ $d = ("word at {0:X8} held {1:X8} after boot, found {2:X8} ({3} bits differ)" -f $u0,$u1,$u2,$p1[14]) }
      else { $d = ("uptime {0} ms" -f $u0) }
      Write-Output ("  #{0}: {1} | {2}" -f $n,$name,$d)
    }
  }
}

if($s -and $s[2] -eq 1){
  $vid = '{0:X4}' -f [BitConverter]::ToUInt16($s,5)
  Write-Output ""
  Write-Output "--- Windows' view of the board ---"
  Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object { $_.InstanceId -match "VID_$vid" } | Sort-Object InstanceId | ForEach-Object { Write-Output ("  {0,-8} {1,-14} {2}" -f $_.Status,$_.Class,$_.FriendlyName) }
}
Write-Output ""
Write-Output "=== end of report: copy everything above and send it ==="
[Hid]::CloseHandle($b.h)|Out-Null
