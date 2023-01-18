volume_strip = nil
class MA12070P : DACDriver
    var volume_table
    def init()
        # define a volume table, saves up on log10
        self.volume_table = [255,160,120,100,90,85,80, 75, 70, 65, 61, 57, 53, 50, 47, 44, 41, 38, 35, 32, 29, 26, 23, 20, 17, 14, 12, 10, 8, 6, 4, 2, 0]
        self.name = "MA12070P"
        self.hardware_volume_control = true
        self.datasheet_link = "https://www.infineon.com/dgdl/Infineon-MA12070P-DS-v01_00-EN.pdf?fileId=5546d46264a8de7e0164b761f2f261e4"
    end

    def init_i2s()
        # PINOUT: SDA: 23, SCL: 22, SDATA: 26, LRCLK: 25, BCLK: 5
        # All of I2S init logic goes here
        
        var ADDR = 0x20

        var config = I2SConfig()
        config.sample_rate = 44100
        config.bits_per_sample = 32
        
        # MCLK: 22.58MHz @ 44.1KHz - sufficient for running the dedicated dsp!
        config.mclk = 512       
        config.comm_format = I2S_CHANNEL_FMT_RIGHT_LEFT
        config.channel_format = I2S_COMM_FORMAT_I2S

        i2s.install(config)
        i2s.set_pins(self.get_i2s_pins())

        # Ensures we expand from 16 to 32 bit, to match MA12070P Clock system.
        i2s.expand(16, 32)

        # Start I2C Driver
        i2c.install(self.get_gpio('sda'), self.get_gpio('scl'))

        # Mute Amplifier before i2c comm & enable. Mute pin: 21
        gpio.pin_mode(self.get_gpio('mutePin'), gpio.OUTPUT)
        gpio.digital_write(self.get_gpio('mutePin'), gpio.LOW)

        # Enable Amplifier. Enable pin: 19
        gpio.pin_mode(self.get_gpio('enablePin'), gpio.OUTPUT)
        gpio.digital_write(self.get_gpio('enablePin'), gpio.LOW)

        # Set Amp to Left-justified format
        i2c.write(ADDR, 53, 8)

        # Set Volume to a safe level..
        i2c.write(ADDR, 64, 0x50)

        # Clear static error register.
        i2c.write(ADDR, 45, 0x34)
        i2c.write(ADDR, 45, 0x30)

        # Init done.

        # Unmute Amplifier 
        gpio.digital_write(self.get_gpio('mutePin'), gpio.HIGH)
        self.set_volume(28)
    end

    def unload_i2s()
        i2s.disable_expand()
        i2s.uninstall()
        i2c.delete()
    end

    def set_volume(volume)
        # Volume is in range from 1 to 100
        # Volume register is flipped in MA12070P.. Hence 100 - realvol.
        var volume_step = volume / 100.0
        var actual_volume = int(volume_step * 32)

        var ADDR = 0x20 

        # Write it..
        i2c.write(ADDR, 64, self.volume_table[actual_volume])

    end

    def make_config_form(ctx, state)
        ctx.create_group('MA12070P_pins', { 'label': 'DAC binary pins' })
        
        ctx.number_field('enablePin', {
            'label': "Enable Pin",
            'default': "0",
            'group': 'MA12070P_pins',
        })

        ctx.number_field('mutePin', {
            'label': "Mute Pin",
            'default': "0",
            'group': 'MA12070P_pins',
        })
        super(self).make_config_form(ctx, state)
    end

end

hardware.register_driver(MA12070P())
