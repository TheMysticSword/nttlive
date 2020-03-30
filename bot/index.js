const fs = require('fs');
const tmi = require('tmi.js');
const hexRgb = require('hex-rgb');

const config = JSON.parse(fs.readFileSync('config.json').toString());
const dir = process.env.LOCALAPPDATA + '/nuclearthrone/data/nttlive.mod/';
const options = {
    identity: {
        username: config['userName'],
        password: config['oauthToken']
    },
    channels: [
        config['channelName']
    ]
};

if (!fs.existsSync(dir)) fs.mkdirSync(dir);
if (!fs.existsSync(dir + '/messages')) fs.mkdirSync(dir + '/messages');
if (!fs.existsSync(dir + '/sendmessage')) {
    fs.mkdirSync(dir + '/sendmessage');
} else {
    let sendMessageFiles = fs.readdirSync(dir + '/sendmessage');
    if (sendMessageFiles.length > 0) {
        sendMessageFiles.forEach(file => {
            let filePath = dir + '/sendmessage/' + file;
            fs.unlinkSync(filePath);
        });
    }
}
var chatters = [];

const client = new tmi.client(options);

client.on('message', function(channel, state, message, self) {
    if (self) return;
    message = message.trim();
    let color = state['color'];
    if (color == null) color = "#808080";
    let messageFile = {
        color: hexRgb(color),
        content: message,
        author: state['display-name']
    };
    fs.writeFileSync(dir + '/messages/message_' + state['id'].toString() + '.txt', JSON.stringify(messageFile), err => console.error(err.message));

    let myChatter = null;
    chatters.forEach(chatter => {
        if (chatter['userName'] == state['display-name']) {
            myChatter = chatter;
        }
    });
    if (myChatter == null) {
        chatters.push({
            userName: state['display-name'],
            lastTime: Date.now()
        });
    } else {
        myChatter['lastTime'] = Date.now();
    }
});

function arrayRandom(array) {
    return array[Math.floor(Math.random() * array.length)];
}

function sendAllMessages() {
    let sendMessageFiles = fs.readdirSync(dir + '/sendmessage');
    if (sendMessageFiles.length > 0) {
        sendMessageFiles.forEach(file => {
            let filePath = dir + '/sendmessage/' + file;
            let fileContents = stringFormat(fs.readFileSync(filePath).toString());
            client.channels.forEach(channel => {
                client.say(channel, fileContents);
            });
            fs.unlinkSync(filePath);
        });
    }
}

function filterChatterList() {
    let activeChatters = [];
    chatters.filter(chatter => chatter['lastTime'] + 1000 * 60 * 5 > Date.now()).forEach(chatter => {
        activeChatters.push(chatter['userName']);
    });

    fs.writeFileSync(dir + "/chatters.txt", JSON.stringify(activeChatters));
}

function saveViewerCount() {
    client.api({
        url: 'https://api.twitch.tv/helix/users?login=' + config.channelName,
        headers: {
            'Client-ID': config.clientID
        }
    }, function (err, res, body) {
        // first we need to get the user id
        let userID = body['data'][0]['id'];
        client.api({
            url: 'https://api.twitch.tv/kraken/streams/' + userID,
            headers: {
                'Client-ID': config['clientID'],
                'Accept': 'application/vnd.twitchtv.v5+json'
            }
        }, function (err, res, body) {
            let viewers = 0;
            if (body['stream'] != null) { // if the channel is offline, 'stream' is null
                viewers = body['stream']['viewers'];
            } else {
                viewers = 0;
            }
            fs.writeFileSync(dir + '/viewer_count.txt', viewers);
        });
    });
}

client.on('connected', function(address, port) {
    console.log('Successfully connected.');
    saveViewerCount();
});

client.on('disconnected', function(reason) {
    console.log('Disconnected! ' + reason);
});

setInterval(function () {
    sendAllMessages();
    filterChatterList();
}, 1000);

setInterval(function () {
    saveViewerCount();
}, 1000 * 60 * 2);

client.connect();

/**
 * Replaces the NTTLive-specific keywords in a string and returns it.
 * @param {String} string
 * @returns {String}
 */
function stringFormat(string) {
    string = string.replace(/BROADCASTER_NAME/g, config['channelName']);
    return string;
}