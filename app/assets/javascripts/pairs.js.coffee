TANDEM.module "pairs", ->
  @loaded = true

  @setup_select2 = () ->
    $(".select2").select2()

  @setup_timepickers = () ->
    $(".time-picker").timepicker
      step: 15
      timeFormat: "g:i a"


  @init = () ->
    @setup_select2()
    @setup_timepickers()

jQuery -> TANDEM.pairs.init()
