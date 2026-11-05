# Obsidian Vault Launcher for Windows

Open a folder as an Obsidian vault with `ov .`, from File Explorer's address bar or a terminal.

Explorer launches are quiet on success. Failures display a dialog with the error. Terminal launches retain text output. `ov --check .` shows the resolved folder without opening Obsidian.

## Install

Requirements: Windows 10/11, Windows PowerShell 5.1, .NET Framework 4.5+ with its C# compiler, and Obsidian installed with its `obsidian://` handler registered. No .NET SDK or administrator privileges are required. Tested on the author's Windows machine; broader Windows compatibility has not yet been verified.

Clone this repository to a permanent location, open PowerShell in that folder, and run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1
```

The installer builds `ov.exe` locally, registers it under the current user's Windows App Paths, and adds this folder to the user's PATH for terminal use. Open a new terminal afterward. Keep the checkout in place: the executable needs `ov-core.ps1` beside it. Rerun the installer after updating the source. If moving the checkout, uninstall first and install again in the new location.

The repository is currently private, so other users need repository access before they can clone it.

## Use

In File Explorer, open the desired folder, click the address bar and type:

```text
ov .
```

In PowerShell or CMD:

```powershell
ov .
ov "D:\My Notes"
ov --check .
```

Already registered vaults open through the official Obsidian URI. For a folder that has never been registered, enable Obsidian's CLI under Settings → General and keep Obsidian running. The launcher must be able to find `Obsidian.com` on PATH or in a standard installation location. Consult the [official CLI setup documentation](https://obsidian.md/help/cli).

Opening unregistered folders currently uses an **unofficial internal Obsidian IPC call**, via CLI `eval`. It may stop working after an Obsidian update. If the CLI is missing, the launcher opens the vault chooser and explains that manual setup is needed. It does not directly edit the global vault registry.

## Troubleshooting

- If Explorer searches the web, rerun `install.ps1` and check `ov.exe` exists. Fallback: `cmd /k ov .`.
- If a terminal cannot find `ov`, open a new terminal; signing out and back in may be necessary for stale PATH environments.
- Use `ov --check .` to inspect which directory Windows passed to the launcher.
- For detailed output or to wait synchronously in CMD, use `ov.cmd .`. The GUI executable can return control to an interactive CMD prompt before it finishes.
- An existing App Paths registration pointing to another `ov.exe` causes installation to stop, rather than overwrite it.

## Uninstall or revert

From the checkout, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\uninstall-exe.ps1
```

This removes the generated executable and its matching App Paths registration. The original `ov.cmd` and PATH entry remain usable. To uninstall completely, also remove this checkout's directory from your **user PATH** in Windows Environment Variables, then remove the checkout.

Git reverts do not undo Windows registry changes. Run the uninstall script before returning to the pre-executable version (`d795407`). The initial executable version is `e54a059`.

## Files

- `Launcher.cs`: small GUI executable; attaches to an existing terminal when available, otherwise shows failures in a dialog.
- `ov-core.ps1`: vault discovery and Obsidian opening logic.
- `ov.cmd`: original terminal entry point.
- `install.ps1`: combined installation; `install-exe.ps1` and `install-path.ps1` can also run separately.
- `uninstall-exe.ps1`: removes the executable integration.

`ov.exe` and local backup files are excluded from Git. Source is compiled locally during installation.
