class ListsController < ApplicationController
  before_action :signed_in_user

  def index
    @lists = current_user.lists
  end

  def new
    @list = current_user.lists.build
  end

  def create
    @list = current_user.lists.build(list_params)
    if @list.save
      flash[:success] = 'List created!'
      redirect_to @list
    else
      render 'new'
    end
  end

  def show
    @list = current_user.lists.find(params[:id])
  end

  def update
    @list = current_user.lists.find(params[:id])
    @list.update_attributes(list_params)
    updated_item_map = updated_item_params
    @list.list_items.each do |item|
      name = updated_item_map[item.id.to_s]
      if name
        item.update_attributes(name: name)
      else
        item.destroy()
      end
    end
    updated_item_params.each do |id, name|
      item = @list.list_items.find(id)
      item.update_attributes(name: name)
    end
    # Delete removed items
    new_item_params.each do |_, name|
      # TODO: Handle the exception when .save returns false.
      @list.list_items.build(name: name).save
    end
    redirect_to action: :index
  end

  private

    def list_params
      params.require(:list).permit(:name)
    end

    def updated_item_params
      Hash[params[:list].map do |k, v|
        [k.match(/\d+/).to_s, v]
      end.select do |k, _|
        k.present?
      end]
    end

    def new_item_params
      params.select {|k, v| k.start_with? 'new-item' and v.size > 0}
    end

end
