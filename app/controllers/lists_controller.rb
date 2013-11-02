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
      flash[:success] = "#{@list.name} created!"
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
      value = updated_item_map[item.id.to_s]
      if value
        item.update_attributes(name: value)
      else
        item.destroy()
      end
    end
    new_item_params.each do |_, name|
      @list.list_items.build(name: name).save
    end
    flash[:success] = "#{@list.name} updated!"
    redirect_to action: :index
  end

  private

    def list_params
      params.require(:list).permit(:name)
    end

    def updated_item_params
      Hash[
        params[:list].map do |k, v|
          id = k.match(/^item-(\d+)$/).try(:[], 1)
          [id, v] if id
        end.select(&:present?)
      ]
    end

    def new_item_params
      params.select{|k, v| k.start_with? 'new-item' and v.present?}
    end

end
