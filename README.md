# This project was abandoned and will not receive any updates
---
# NTTLive
A Twitch Integration mod for Nuclear Throne Together.

# Features
* Viewer nicknames and their messages above enemies!
* Mutation and crown voting!
* New weapons powered by messages!
* Timely events!
* A once-per-run revive voting!
* Chat-controlled Throne!

# Prerequisites
* [Nuclear Throne Together](https://yellowafterlife.itch.io/nuclear-throne-together) - a mod for Nuclear Throne that adds online co-op and modding support
* [node.js](https://nodejs.org/en/) - a JavaScript runtime, required for the Twitch bot to work

# Setup
1. Download this repo and unpack the `nttlive` folder in your `mods` folder of Nuclear Throne
2. Open a command prompt in `<Nuclear Throne folder>/mods/nttlive/bot`
3. Type `npm install` to automatically install all required dependencies for the Twitch bot:
   * tmi.js - the core functionality for the bot
   * hex-rgb - allows convertion of the Twitch's hex colour values to GML-friendly RGB values
4. Create a `config.json` file in the same folder with these fields:
   ```
   {
      "channelName": "",
      "userName": "",
      "oauthToken": "",
      "clientID": "htxmau31hiywpoaa0wgcakmgup38f9"
   }
   ```
4. Type your username in the `channelName` and `userName` fields
5. Go to https://twitchapps.com/tmi/ and get a Twitch OAuth Token, then paste it in the `oauthToken` field. **DO NOT share the token**   
   
   **OPTIONAL**: If you want to send messages from a separate chat bot account:
7. Type the username of your bot's Twitch account in the `userName` field
8. Get the OAuth token from https://twitchapps.com/tmi/ while logged in your bot's Twitch account

# Starting the mod
1. Open a command prompt in `<Nuclear Throne folder>/mods/nttlive/bot` and type `node .` to start the bot   
   If you did everything correctly, the command prompt should say "Successfully connected."
2. Run Nuclear Throne Together and type `/load nttlive` in the character selection menu
