# nttlive
A Twitch Integration mod for Nuclear Throne Together.

# Features
* Viewer nicknames and their messages above enemies!
* Mutation and crown voting!
* Timely events, such as dropping nukes on the streamer by typing something!
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
4. Create a `config.json` file with these fields:
   ```
   {
       "username": "",
       "password": "",
       "clientID": "",
       "channelName": ""
   }
   ```
4. **OPTIONAL STEP** - Create a Twitch account for your bot. If you want your bot to send messages from *your* account, then you can skip this step
5. Create a Twitch Application - this is required to get a password and an ID for your bot
   1. Go to https://dev.twitch.tv/console/apps and click "Register Your Application"
   2. Choose a name for your application, set OAuth Redirect URL to `http://localhost` and Category to "Game Integration"
   3. Copy the Client ID of your application and paste it in the `clientID` field of `config.json`
6. In the `username` field, type the username of your Twitch account (or your bot's account, if you made one)
7. While logged in your account (or your bot's account), go to https://twitchapps.com/tmi/, then copy the generated OAuth password and paste it in the `password` field
8. Type your main Twitch account's username in the `channelName` field. This is where the bot will connect to.
9. Open the command prompt and type `node .` in it. This will start your bot. If you did everything right, you should see a message that says "Successfully connected." in the command prompt

# Starting the mod
1. Open a command prompt in `<Nuclear Throne folder>/mods/nttlive/bot` and type `node .` to start the bot
2. Run Nuclear Throne Together and type `/load nttlive` in the character selection menu
