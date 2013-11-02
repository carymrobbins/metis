# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

onLoad ->
  $('form.edit_list').on 'keydown', (event) ->
    if event.which == KEY.ENTER
      event.preventDefault()
      return false

  add_list_item_button = $('#add-list-item-button')

  add_list_item_button.on 'click', (event) ->
    event.preventDefault()
    self = $(this)
    next_id = self.data('next_id') or 0
    self.data('next_id', next_id + 1)
    new_row = $('<tr><td><input/></td></tr>')
    self.closest('tr').before(new_row)
    input = new_row.find('input').attr(
      type: 'text',
      name: 'new-item-' + next_id,
      class: 'list-item-field',
      autocomplete: 'off',
    ).trigger('focus')

  if $('.list-item-field').length == 0
    add_list_item_button.trigger('click')

  $('form.edit_list').on 'keydown', '.list-item-field', (event) ->
    self = $(this)
    this_row = self.closest('tr')
    prev_item = this_row.prev('tr').find('.list-item-field')
    next_item = this_row.next('tr').find('.list-item-field')
    if event.which == KEY.ENTER
      next_item = self.closest('tr').next('tr').find('.list-item-field')
      if next_item.length
        next_item.trigger('focus')
      else
        add_list_item_button.trigger('click')
    if event.which == KEY.BACKSPACE
      if self.val() == ''
        prev_item = this_row.prev('tr').find('.list-item-field')
        prev_item.trigger('focus') if prev_item
        this_row.detach()
        # Prevent backspace from moving us to the previous page.
        event.preventDefault()
    if event.which == KEY.UPARROW
      prev_item.trigger('focus') if prev_item.length
    if event.which == KEY.DOWNARROW
      next_item.trigger('focus') if next_item.length
