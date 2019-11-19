class PagesController < ApplicationController
  
  before_action :authenticate_user!
  
  def home
      @users = User.where.not(id: current_user.id)
  end
  
  def state
     if current_user.busy?
         current_user.available!
     else
         current_user.busy!
     end
     
     # Broadcast the change to the users
     
     respond_to do |format|
         format.js
     end
  end
  
end
