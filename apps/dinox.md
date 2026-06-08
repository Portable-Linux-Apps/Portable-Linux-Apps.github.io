# DINOX

DinoX is a secure XMPP messenger for Linux and Windows. It focuses on private 1:1 chats, group chats, file sharing, and media calls with optional encryption stacks.

- GTK4/libadwaita desktop client
- Encrypted 1:1 chats and group chats with OMEMO / OpenPGP support
- Voice/video calls, voice/video messages, and inline media playback
- Local data encryption (SQLCipher), panic wipe and privacy controls
- File transfer, MUC moderation, reactions, stickers, and automation plugins
- Optional Tor routing for privacy-aware deployments

![Dinox chat window](https://git.dinox.im/dinoxim/dinox/raw/branch/master/docs/assets/chat.png)

| ![Private chat](https://git.dinox.im/dinoxim/dinox/raw/branch/master/docs/assets/privt.png) | ![Voice/video call](https://git.dinox.im/dinoxim/dinox/raw/branch/master/docs/assets/voicecal.png) |
|---|---|
| Private chat and roster overview | Voice and video call workflow |

## What this is good for

- Daily and team communication on self-hosted or public XMPP servers
- Private desktop chat that includes call/media workflows
- Users who want a native Linux/Windows client instead of a browser IM

## Main features

- 1:1 and group chats (MUC) with moderation, receipts, message replies, and quick history handling
- Voice and video calls with media controls
- Voice/video messages with inline playback
- Encrypted file sharing and secure local cache handling
- Rich notifications and tray integration
- Multi-device aware with local backup/restore flows
- Optional integrations: MQTT automation, Botmother, and REST endpoints

## Installation

### Linux (AppImage)

1. Download the latest AppImage from the releases page.
2. Make it executable:

   ```bash
   chmod +x DinoX-<version>-x86_64.AppImage
   ```
3. Start it:

   ```bash
   ./DinoX-<version>-x86_64.AppImage
   ```

4. Replace `<version>` with the latest release filename.

### Windows and other package formats

See official releases for ZIP, Flatpak, and DEB variants and any optional package helpers.

## Useful links

- Website: https://dinox.im
- Source: https://git.dinox.im/dinoxim/dinox
- Releases: https://git.dinox.im/dinoxim/dinox/releases
- Wiki: https://git.dinox.im/dinoxim/dinox/wiki/Home

| [Applications](https://portable-linux-apps.github.io/apps.html) | [Home](https://portable-linux-apps.github.io)
| --- | --- |
