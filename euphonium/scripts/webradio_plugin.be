class WebRadioPlugin : Plugin
    def init()
        self.configSchema = {
            'radioBrowserApi': {
                'tooltip': 'Radio Browser instance url',
                'type': 'string',
                'defaultValue': 'http://webradio.radiobrowser.com/api/v1/stations/'
            },
        }

        self.applyDefaultValues()
        self.name = "webradio"
        self.themeColor = "#d2c464"
        self.displayName = "Web Radio"
        self.type = "plugin"
        self.exposeWebApp = true
    end
    def onEvent(event, data)
        if event == EVENT_SET_PAUSE
            webradio_set_pause(data)
        end
    end
end

app.registerPlugin(WebRadioPlugin())

# HTTP Handlers
http.handle('POST', '/webradio', def(request)
    var body = json.load(request['body'])

    app.updateSong({
        'songName': body["stationName"],
        'artistName': 'Internet Radio',
        'sourceName': 'webradio',
        'icon': body['favicon'],
        'albumName': body['codec']
    })
    webradio_queue_url(body['stationUrl'], (body["codec"] == "AAC" || body["codec"] == "AAC+"))
    app.setStatus('playing')
    http.sendJSON({ 'status': 'playing'}, request['connection'], 200)
end)
