# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

TANDEM.module "members", ->
  @module "index", ->
    @en = {
      no_contacts: "Please enter at least one row",
      bad_contacts_format: "Please make sure to use the format 'name, phone number'",
    }

    @bulk_import_modal_selector = "#bulk-import-modal"

    @bulk_import_textarea_selector = "#{@bulk_import_modal_selector} textarea.contacts"

    @hide_bulk_import_modal = () => $(@bulk_import_modal_selector).modal("hide")

    @setup_bulk_import_modal = () =>
      $("#{@bulk_import_modal_selector} .btn.import").click =>
        data = @clean_contacts_input(@bulk_import_textarea_selector)
        @submit_bulk_import(data) if data

    @error_rows = []

    @clean_contacts_input = (textarea_selector) =>
      $textarea = $(textarea_selector)
      rows = $textarea.val().split("\n")
      if rows == ""
        @ROOT.alert(@[@ROOT.language].no_contacts)
        return nil
      else
        @error_rows = []
        ret = rows.map (row) =>
          entry = row.split(",")
          if entry.length >= 2
            { name: entry[0].trim(), phone_number: entry[1].trim() }
          else
            @error_rows.push(row) if row.trim() != ""
            null
        ret = ret.filter((n) -> n != null)
        if ret.length > 0
          return { members: ret }
        else
          @handle_bulk_import_errors()
          null

    @handle_bulk_import_errors = () =>
      $textarea = $(@bulk_import_textarea_selector)
      $bulk_import_modal = $(@bulk_import_modal_selector)
      $textarea.val(@error_rows.join("\n"))
      $bulk_import_modal.addClass("has-error")

    @submit_bulk_import = (data) =>
      $textarea = $(@bulk_import_textarea_selector)
      $bulk_import_modal = $(@bulk_import_modal_selector)
      $.ajax
        type: "POST"
        url: @bulk_import_group_members_path
        data: data
        beforeSend: @ROOT.show_ajax_loader
        complete: @ROOT.hide_ajax_loader
        success: (data) =>
          $(".members-table tbody").prepend(data.rendered_rows)
          $(".page-header").prepend(data.alert) if data.alert
          @error_rows = @error_rows.concat(data.error_rows)
          if @error_rows.length > 0
            @handle_bulk_import_errors()
          else
            $bulk_import_modal.removeClass("has-error")
            @hide_bulk_import_modal()
        error: (data) => @handle_bulk_import_errors()

    @init = () =>
      @setup_bulk_import_modal()



jQuery ->
  TANDEM.members.index.init() if $("body.members.index").length > 0


