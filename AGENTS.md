# Repository Guidelines

## Project Structure & Module Organization

This repository is a Windows C#/.NET Framework solution. The main solution lives at `src/HuntAndPeck.sln`.

- `src/HuntAndPeck/` contains the WPF application, including `Models/`, `Services/`, `ViewModels/`, and `Views/`.
- `src/NativeMethods/` contains Win32 interop wrappers and native structures used for hotkeys and window integration.
- `src/HuntAndPeck.Tests/` contains xUnit tests, currently organized by feature area such as `Services/`.
- `assets/` contains repository documentation images, such as screenshots used by `README.md`.
- `src/build.cake` and `src/build.ps1` define restore, build, test, and package automation.

## Build, Test, and Development Commands

Run build commands from `src/`.

```powershell
.\build.ps1 -Target Build -Configuration Debug
```
Restores NuGet packages and builds `HuntAndPeck.sln`.

```powershell
.\build.ps1 -Target Test -Configuration Debug
```
Builds the solution and runs xUnit tests, writing XML results under `src/TestResults/`.

```powershell
.\build.ps1 -Target Package -Configuration Release
```
Builds the release app and creates `src/Dist/HuntAndPeck.zip`.

The app output assembly is named `hap.exe`; documented runtime options include `hap.exe /hint` and `hap.exe /tray`.

## Coding Style & Naming Conventions

Use the existing C# style: four-space indentation, braces on their own lines, PascalCase for public types and members, camelCase for locals and parameters, and `I` prefixes for interfaces. Keep WPF MVVM boundaries clear: UI markup and code-behind in `Views/`, bindable state in `ViewModels/`, behavior in `Services/`, and shared data in `Models/`. Do not manually edit generated files such as `*.Designer.cs` unless regenerating their source settings or resources.

## Testing Guidelines

Tests use xUnit. Place new tests in `src/HuntAndPeck.Tests/` mirroring the production namespace or feature folder. Name test classes after the subject under test, for example `HintLabelServiceTest`, and use descriptive method names such as `GetHintStrings_UniqueStrings`. Add focused tests for service logic and regressions around hint generation, matching, configuration, and native integration boundaries where practical.

## Commit & Pull Request Guidelines

Recent history uses short imperative or descriptive subjects, such as `Update README.md` and `Refactor README for better structure and clarity`. Keep commits scoped to one logical change. Pull requests should include a concise summary, test results or the command run, linked issues when applicable, and screenshots or GIFs for visible WPF UI changes.

## Agent-Specific Instructions

Before editing, check for user changes and avoid reverting unrelated work. Prefer the Cake targets above for verification, and keep generated artifacts such as `bin/`, `obj/`, `Dist/`, and `TestResults/` out of commits unless explicitly requested.
