<h1 align="center">
  Kyber Mod Manager
</h1>


<h4 align="center">A Mod Manager build for <a href="https://kyber.gg" target="_blank">Kyber</a>.</h4>
<p align="center"><small>This app is not affiliated with Kyber or any of its creators.</small></p>

<p align="center">
  <a href="https://discord.gg/t2YBaHqbkb">
    <img src="https://img.shields.io/discord/946919254622629928.svg?label=Discord&logo=discord&color=778cd4"
         alt="Discord">
  </a>
  <a href="https://github.com/7reax/kyber-mod-manager">
      <img src="https://img.shields.io/badge/star_it_on-github-black?style=shield&logo=github">
  </a>
  <img src="https://img.shields.io/github/downloads/7reax/kyber-mod-manager/total">
  <a title="Made with Fluent Design" href="https://github.com/bdlukaa/fluent_ui">
    <img
      src="https://img.shields.io/badge/fluent-design-blue?style=flat-square&color=7A7574&labelColor=0078D7"
    />
  </a>
  <a title="Crowdin" target="_blank" href="https://crowdin.com"><img src="https://badges.crowdin.net/kyber-mod-manager/localized.svg"></a>
</p>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#download">Download</a> •
  <a href="#credits">Credits</a> •
  <a href="#license">License</a>
</p>

# IMPORTANT

#### In order for the Mod Manager to work you need the following applications installed:

* [WinRAR](https://www.win-rar.com/) or [7-Zip](https://www.7-zip.org/)

## Key Features

* Automatic mod downloading (Mods are directly downloaded from [NexusMods](https://www.nexusmods.com/))
* Hosting & Joining servers
* Automatic Kyber injection
* FrostyFix like function
* Automatic Mod Profile creation
    * It creates a Frosty-Pack and applies the mods automatically.

## General Information

* As soon as **Kyber v2** is getting released this Mod Manager will be updated.
* For the best experience it is recommended to use **EA-Desktop**.
* PRs are welcome

## Download

#### [Windows ![windows](https://media.discordapp.net/attachments/810799100940255260/838488668816932965/ezgif-6-ac9683508192.png)](https://github.com/7reax/kyber-mod-manager/releases/latest)

- Download the exe, click More Info > Run Anyway > Open Kyber Mod Manager

## Screenshots

| <p style="width: 30vw;">Pages</p> |                         <p></p>                     |
|:---------------------------------:|:--------------------------------------------:|
|          Server Browser           | <img src="https://share.reax.at/ghMCmR.png"> |
|           Hosting Page            | <img src="https://share.reax.at/r05ytu.png"> |
|       Mod Profile Edit Page       | <img src="https://share.reax.at/m52oM9.png"> |
|       Settings                    | <img src="https://share.reax.at/IXpSOy.png"> |

## Questions

### How does the automatic mod download work?
The Mod Manager opens NexusMods in the background during the login process. If you successfully logged in, it saves the cookies. If you now want to download mods, it opens the browser again (with the saved cookies) and clicks on the "Download" button
on the mod page.

## For developers: How to modify the Mod Manager

To clone and run this application, you'll need [Git](https://git-scm.com) and [Flutter](https://docs.flutter.dev/get-started/install) installed on your computer. From your command line:

```bash
# Clone this repository
$ git clone https://github.com/7reax/kyber-mod-manager.git

# Go into the repository
$ cd kyber-mod-manager

# Install dependencies
$ flutter pub get

# Run the generator
$ flutter pub run build_runner build

# Run the app
$ flutter run lib/main.dart

# Build the app
$ flutter build windows
```

## Credits

This software uses the following open source projects:

- [Flutter](https://flutter.com/)
- [Fluent UI](https://pub.dev/packages/fluent_ui)

## License

MIT

---

> [reax.at](https://reax.at) &nbsp;&middot;&nbsp;
> GitHub [@7reax](https://github.com/7reax) &nbsp;&middot;&nbsp;
> Discord [liam#2306](https://discord.gg/6WMrYRwqhr)
