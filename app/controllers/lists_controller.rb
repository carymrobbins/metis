class ListsController < ApplicationController
  before_action :signed_in_user

  def index
    @lists = current_user.lists
  end
end
