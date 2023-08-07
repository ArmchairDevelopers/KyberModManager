## [1.0.11] - [08/08/23]
- Added input saving for the Host page.
    - So if you leave the page and come back, your inputs will still be there.
- Fixed connection issues with the Kyber API.

**Known Issues**:
- Sometimes even if a preferred "Server Host Faction" is selected, the game will still put you on the other team.


## [1.0.10] - [22/06/23]
- **Fixed Nexusmods Login**.
- Minor UI changes and improvements.
- Fixed auto-save for cosmetic mods.
- Upgraded fluent_ui.
- Updated dependencies.
- Disabled selector for "Server Host Faction" if auto balance is enabled.
- Reduced timeout for proxy checking.
- Added warning message for slow "saved profiles" loading.
- Reset faction selector when auto balance gets enabled.
- Fixed frosty auto updater not parsing the frosty version.
- Fixed path for installing/updating frosty.
- Disabled delete button if no mods are selected.
- Added missing translations.

**Known Issues**:
- Sometimes even if a preferred "Server Host Faction" is selected, the game will still put you on the other team.

## [1.0.9] - [12/01/23]

- Fixed the Dynamic Environment Plugin so that FrostyFix is no longer needed.
- Fix transparent background on Windows 11.
- Added Buttons to Discord Rich Presence.
- Added missing translations.
- Performance improvements.
- Added a new events tab for Kyber Discord events.
- Redesigned the settings & installed mods page.

## [1.0.8] - [21/10/22]

- Added a selection menu for Kyber release channels.
- Faster loading of saved profile through symlinks.
- Added the ability to manually select the BF2 path.
- Added the faction selector on the host page.
- Added an in-app browser for logging in.
- Added button to manually select a Frosty pack when joining a server.
- Fixed the infinite Cloudflare loading screen.
- Fixed Frosty Collections for the cosmetics page.
- Several minor bug fixes.
- UI improvements.

## [1.0.7] - [13/06/22]

- If the Kyber injection fails, KMM will show an error message and close Battlefront II.
- Added warnings for using cosmetic mods with large mod packs.
- Added validation for selecting a mod profile on the host page.
- Added Kyber & Frosty related links to feedback page.
- Added a new error page for when Battlefront II isn't installed.
- Added skip button for the Kyber Dll download.
- Added support for new Frosty mod that contains the download link.
- Added support for Frosty collections.
- Added ability to view the pings from the proxy locations.
- Added version checker for Frosty.
- KMM now shows an error if you got logged out of your Nexusmods account.
- Fixed Frosty Pack generation with cosmetic mods.
- Fixed that if a mod is already installed, the new mod gets a different name so that you can use both versions.
- Fixed a bug where extracting mods after downloading could cause lags.
- Fixed a window border issue on Windows 10.
- Fixed that sometimes KMM wouldn't detect that the download has already started.
- Fixed the cancel button while launching into a server.
- Fixed WinRAR extraction.
- Fixed links in the update changelog
- Fixed that opening the cosmetics page too early could cause crashes.
- Fixed that sometimes the progress bar during downloads would disappear.
- Added missing translations.
- Added a minimum window size.
- Download speed is now being shown.
- Not installed mods are now being handled correctly.
- Several UI fixes
- Upgraded to Flutter 3.0

## [1.0.6] - [13/05/2022]

- Added export buttons to both the mod profiles and cosmetics list.
- Added a shortcut to disable the background effect.
- Added an option to automatically download Frosty in the setup process.
- Added caching to not exceed GitHub Api limits.
- Fixed a bug where KMM would search in the wrong directories for the Frosty config.
- Added missing translations.
- Several UI changes.

## [1.0.5] - [3/05/2022]

- Fixes a bug where unsupported languages could cause some errors.
- Fixes a bug where the Kyber Config could not be loaded correctly
- The supported Frosty versions are now dynamically loaded.

## [1.0.4] - [27/04/2022]

- Added support for NexusMods premium.
- Added an installed mods page.
- Mods can now be dragged and dropped into the mod manager. It will then install them.
- Added Started At field in the server browser.
- Added a custom window title bar.
- Added mica background effect for Windows 11.
- Saved profiles progress is now being shown in the Windows taskbar.
- Several UI changes.

## [1.0.3] - [14/04/2022]

- **Added Discord activity feature**.
- **Added the abilitity to select cosmetic mods**.
- KMM now uses the default Windows locale.
- Frosty is now being skipped if the mods are already applied.
- Logs are now being stored in a file.
- Added the "Last used" tab to saved profiles.
- Added a new button to export the log file.
- Added a new "Check for updates" button.
- Added a progress bar when a saved profile is being loaded.
- Removed mod profiles from the "Run Battlefront" tab.
- Added missing translations.
- Now only Kyber releated Mods are being imported to mod profiles.
- Fixed a bug where during the setup the mods could not be loaded.
- Minor UI changes.
- Several minor fixes.

## [1.0.2] - [07/04/2022]

- **Fixes the NexusMods login. Now everything should work properly**.
- Added missing translations.
- Added a page for missing admin rights.
- Minor bug fixes.
