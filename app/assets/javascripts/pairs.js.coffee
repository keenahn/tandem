TANDEM.module "pairs", ->
  @setup_select2 = () ->
    $(".select2").select2()

jQuery ->
  TANDEM.pairs.setup_select2()
