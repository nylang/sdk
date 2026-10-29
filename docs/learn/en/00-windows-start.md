# 00: Your first program on Windows

[中文](../00-windows-start.md) · [Course index](README.md) · [Choose a platform](00-start.md) · [Next](01-values.md)

Use Windows x86_64 and PowerShell. Replace example paths with actual locations.

## 1. Prepare the prerequisites

Install Python 3.12 or a compatible newer version, Visual Studio/Build Tools
with Desktop development with C++, a Windows SDK and the complete Nyra SDK.
The developer environment supplies native headers and libraries, not just Clang.

Open **x64 Native Tools Command Prompt**, then start PowerShell inside it:

```text
powershell
```

The resulting session inherits the x64 toolchain environment. Follow
[Microsoft's command-line guide](https://learn.microsoft.com/en-us/cpp/build/building-on-the-command-line)
if your installation uses different shortcut names.

## 2. Select the SDK

Download, verify and extract the Windows archive using [INSTALL.md](../../../INSTALL.md).
Replace the directory below with its real location:

```powershell
$env:NYRA_SDK = "E:/sdks/nyra-sdk-1.0.3-windows-x86_64"
$env:NYRA_SDK_ROOT = $env:NYRA_SDK
$env:NYRA_HOST = "windows-x86_64"
$env:NYRAC = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/bin/nyrac.exe"
$env:NYRA_ANALYZER = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/bin/nyra-analyzer.exe"
$env:NYRA_WORK = "$env:USERPROFILE/nyra-learning"
$env:CC = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/llvm/bin/clang.exe"
$env:AR = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/llvm/bin/llvm-ar.exe"
$env:PATH = "$env:NYRA_SDK/hosts/$env:NYRA_HOST/bin;$env:NYRA_SDK/hosts/$env:NYRA_HOST/llvm/bin;$env:PATH"
$env:PYTHONUTF8 = "1"

python --version
& $env:NYRAC version
& $env:NYRA_ANALYZER version
```

Set these variables again when opening a new terminal.

## 3. Create a practice package

```powershell
New-Item -ItemType Directory -Force "$env:NYRA_WORK/playground" | Out-Null
Set-Location "$env:NYRA_WORK/playground"

@'
from pathlib import Path
Path("package.yaml").write_text("name: nyra_lessons\n", encoding="utf-8")
'@ | python -
```

SDK 1.0.3 finds kernel, stdlib and ntest without private source dependencies.
The here-string markers must occupy separate lines.

## 4. Save and run the program

Create `playground/main.ny`, saved as UTF-8:

```nyra
import "stdlib:stdlib.ny";

func main() -> int32 {
  Console.Println("你好，Nyra！");
  return 0;
}
```

Run:

```powershell
& $env:NYRAC check "$env:NYRA_WORK/playground/main.ny"
& $env:NYRAC run "$env:NYRA_WORK/playground/main.ny" --out-dir "$env:NYRA_WORK/out/hello"
```

Expect the Chinese greeting from the other platform lessons. Build an executable:

```powershell
& $env:NYRAC build "$env:NYRA_WORK/playground/main.ny" --link --out-dir "$env:NYRA_WORK/out/hello-build" -o "$env:NYRA_WORK/out/hello-build/hello.exe"
& "$env:NYRA_WORK/out/hello-build/hello.exe"
```

## Translate later commands to PowerShell

Use `$env:NYRA_WORK` instead of `$NYRA_WORK`, and similarly for other variables.
Invoke executable variables with `&`. Use `python` where Bash examples say
`python3`. Bash's trailing backslash is not PowerShell continuation syntax;
put a command on one line when learning. Use `New-Item -ItemType Directory -Force`
for directory creation and `.exe` for generated executables.

```powershell
& $env:NYRAC check "$env:NYRA_WORK/playground/main.ny"
& $env:NYRAC run "$env:NYRA_WORK/playground/main.ny" --out-dir "$env:NYRA_WORK/out/current"
& $env:NYRA_ANALYZER analyze "$env:NYRA_WORK/playground/main.ny"
```

For a Bash Python heredoc, use a PowerShell here-string piped to `python -`,
as in section 3, or save the Python code in a file. Older Windows PowerShell
redirection may re-encode raw output. To preserve probe bytes, use Python and
binary file mode instead:

```python
import os
import subprocess
from pathlib import Path

work = Path(os.environ["NYRA_WORK"])
out = work / "out/capture"
out.mkdir(parents=True, exist_ok=True)
command = [os.environ["NYRAC"], "check", str(work / "playground/main.ny")]
with (out / "stdout.log").open("wb") as stdout, (out / "stderr.log").open("wb") as stderr:
    subprocess.run(command, stdout=stdout, stderr=stderr, check=True)
```

Save and run that Python script; change its command list for another probe.

## Troubleshooting

Confirm `python --version`, `Test-Path $env:NYRAC` and the x64 developer terminal.
Missing Windows headers/CRT files indicate developer-environment problems.
Keep path quotes and `&`; distinguish a missing third-party DLL from a source
error. For garbled text, check UTF-8 source/terminal handling before changing
business strings. This lesson does not establish Windows ARM64 or old-Windows
acceptance.
