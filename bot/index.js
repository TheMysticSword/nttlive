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
            let file_path = dir + '/sendmessage/' + file;
            fs.unlinkSync(file_path);
        });
    }
}
var chatters = [config['channelName']];

const client = new tmi.client(options);

client.on('message', function(channel, state, message, self) {
    if (self) return;
    message = message.trim();
    let message_file = {
        color: hexRgb(state['color']),
        content: message,
        author: state['display-name'],
        badges: state['badges']
    };
    fs.writeFileSync(dir + '/messages/message_' + state['id'].toString() + '.txt', JSON.stringify(message_file), err => console.error(err.message));
});

client.on('connected', function(address, port) {
    console.log('Successfully connected.');
});

client.on('disconnected', function(reason) {
    console.log('Disconnected! ' + reason);
});

client.on('join', (channel, username, self) => {
    if (!self) {
        if (channel == "#" + config.channelName) {
            if (chatters.indexOf(username) == -1) {
                chatters.push(username);
            }
        }
    }
});

client.on('part', (channel, username, self) => {
    if (!self) {
        if (channel == "#" + config.channelName) {
            chatters.splice(chatters.indexOf(username));
        }
    }
});

setInterval(function () {
    let sendMessageFiles = fs.readdirSync(dir + '/sendmessage');
    if (sendMessageFiles.length > 0) {
        sendMessageFiles.forEach(file => {
            let file_path = dir + '/sendmessage/' + file;
            let file_contents = stringFormat(fs.readFileSync(file_path).toString());
            client.channels.forEach(channel => {
                client.say(channel, file_contents);
            });
            fs.unlinkSync(file_path);
        });
    }
    fs.writeFileSync(dir + "/chatters.txt", JSON.stringify(chatters));
}, 1000);

setInterval(function () {
    // viewer count
    client.api({
        url: 'https://api.twitch.tv/helix/users?login=' + config.channelName,
        headers: {
            'Client-ID': config.clientID
        }
    }, function (err, res, body) {
        // first we need to get the user id
        let user_id = body['data'][0]['id'];
        client.api({
            url: 'https://api.twitch.tv/kraken/streams/' + user_id,
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