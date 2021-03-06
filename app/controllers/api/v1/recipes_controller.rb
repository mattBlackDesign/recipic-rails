class Api::V1::RecipesController < ApplicationController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  before_filter :check_authentication

  # include Serializers::V1::ItemsSerializer

  # Just skip the authentication for now
  # before_filter :authenticate_user!

  respond_to :json

  def index
    if params[:term]
      @recipes = Recipe.where("lower(name) LIKE lower(?)", "%#{params[:term]}%").page(params[:page]).per(params[:page_limit])
    else
      @recipes = Recipe.all.page(params[:page]).per(params[:page_limit])
    end
    render :status => 200,
               :json => { :success => true,
                          :info => "Received recipes",
                          :data => {recipes: @recipes} }
  end


  def search 
    if params[:items]
      items = []
      params[:items].each do |item|
        
        if (Item.where(name: item).count == 0)
          Item.create(name: item)
        else
          items << Item.find_by_name(item)
        end
      end
      render :status => 200,
               :json => { :success => true,
                          :info => "Received recipes",
                          :data => {recipes: Recipe.with_items(items)} }
    else
      render :status => 200,
               :json => { :success => false,
                          :info => "Error",
                          :data => {} }
    end

  end

  private


    def check_authentication
       if User.where(authentication_token: params[:auth_token]).count == 1
        @user = User.where(authentication_token: params[:auth_token]).first
       else
        render :status => 401,
               :json => { :success => false,
                          :info => "Authentication failed",
                          :data => {} }
       end

   end

end