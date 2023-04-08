class ResetRestorePlugin : Plugin 
  def init()
    self.name = "reset_restore"
    self.theme_color = "#1DB954"
    self.display_name = "Reset & Restore"
    self.type = "system"
    self.state = {}
    # self.fetch_config()
  end
  def make_form(ctx, state)
    var group = ctx.create_group('reset', { 'label': 'Reset' })

    var btn = group.button_field('factoryResetButton', {
        'label': "Factory reset",
        'buttonText': "Reset",
    })

    if btn.has_been("click")
      state.setitem("factoryResetButton", true)
    end
    if state.find("factoryResetButton") == true 
      
      var modal_group = group.modal_group("factoryResetConfirm", {
        'title': "Factory reset",
      })
      modal_group.text_field("factoryResetConfirmText", {
        'label': "Are you sure you want to reset the device to factory defaults?",
        'default': "Are you sure you want to reset the device to factory defaults?",
      
      })
      modal_group.button_field("factoryResetConfirmButton", {
        'label': "Confirm",
        'buttonText': "Confirm",
      })
      modal_group.button_field("factoryResetCancelButton", {
        'label': "Cancel",
        'buttonText': "Cancel",
      })
    end
    if state.find("factoryResetConfirm") == true 
      state.setitem("factoryResetConfirm", nil)
      self.perform_factory_reset()
    end

   
    # ctx.modal_group("test_modal", {
    #   'title': "Test modal",
    #   'global': true,
    # })
    # ctx.button_field("test_modal_button", {
    #   'label': "Test asassaas",
    #   'buttonText': "eerreer",
    #   'group': 'test_modal',
    # })
  end
  def perform_factory_reset()
    core.delete_config_files();
    wifi.clear_config();
    core.restart();
  end
end

var reset_restore = ResetRestorePlugin()

euphonium.register_plugin(reset_restore)
