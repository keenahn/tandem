class window.TANDEM

  # Utility functions
  @document = () -> @_document ||= $(document)

  @window = () -> @_window ||= $(window)

  @redir = (url) -> window.location = url

  @reload = () -> window.location.reload()

  @alert = (txt) -> alert txt

  @confirm = (txt) -> confirm txt

  @get_vars = ->
    return @_get_vars if @_get_vars
    @_get_vars = {}
    parts = window.location.href.replace /[?&]+([^=&]+)=([^&]*)/g, (m, key, value) => @_get_vars[key] = value
    @_get_vars

  ################################################################################
  # Module Pattern
  # http://stackoverflow.com/questions/6107705/module-pattern-in-coffeescript-with-hidden-variables#answer-6595285
  # https://github.com/disnet/contracts.coffee/wiki/Easy-modules-with-CoffeeScript
  ################################################################################
  # EXAMPLE 1:
  # @module "foo", ->
  #   @module "bar", ->
  #     class @Amazing
  #       toString: "ain't it"
  # x = new @foo.bar.Amazing
  ################################################################################
  # EXAMPLE 2 (shortcut notation):
  # @module "foo.bar", ->
  #   class @Amazing
  #     toString: "ain't it"
  # x = new @foo.bar.Amazing
  @module = (names, fn) ->
    names = names.split "." if typeof names is "string"
    space = @[names.shift()] ||= {}
    space.module ||= window.TANDEM.module
    space.ROOT = window.TANDEM # Every module should have direct access to the root namespace
    if names.length
      space.module names, fn
    else
      fn.call space

  @bind_ajax_success_error = (form_selector, success, error = false) ->
    $document = @document()
    $document.on "ajax:remotipartSubmit", form_selector, {}, (e, xhr, settings) -> settings.dataType = "json"
    $document.on "ajax:success", form_selector, {}, success
    unless error
      error = (evt, data, status, xhr) =>
        a = $.parseJSON(data.responseText)
        if data.errors
          @alert data.errors
        else
          @alert a.errors if a.errors
        if data.next_url
          @redir data.next_url
        else
          @redir a.next_url if a.next_url
        return false
    $document.on "ajax:error", form_selector, {}, error

