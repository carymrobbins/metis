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
      redirect_to lists_path
    else
      render 'new'
    end
  end

  def show
    @list = current_user.lists.find(params[:id])
  end

  private

    def list_params
      params.require(:list).permit(:name)
    end

end
