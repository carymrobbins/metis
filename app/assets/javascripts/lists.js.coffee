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
    # TODO: Refactor to reuse this block in this file and the show view.
    new_row = $("""
      <tr>
        <td>
          <input type="text" class="list-item-field" autocomplete="off" />
          <a class="close delete-item-button">&times;</a>
        </td>
      </tr>
    """)
    self.closest('tr').before(new_row)
    input = new_row.find('input').attr(
      name: 'new-item-' + next_id,
    ).trigger('focus')

  if $('.list-item-field').length == 0
    add_list_item_button.trigger('click')

  edit_list_form = $('form.edit_list')

  edit_list_form.on 'keydown', '.list-item-field', (event) ->
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

  edit_list_form.on 'click', '.delete-item-button', (event) ->
    $(this).closest('tr').detach()

  $('.list-index').on 'click', '.delete-item-button', (event) ->
    event.preventDefault()
    self = $(this)
    # TODO: Replace with modal.
    if confirm("Do you really want to delete #{self.attr('data_name')}?")
      req = $.ajax(
        url: self.attr('href'),
        type: 'post',
        dataType: 'json',
        data: {_method: 'delete'},
      )
      req.done (data) ->
        self.closest('tr').detach()
      req.fail ->
        alert "Delete failed!"
