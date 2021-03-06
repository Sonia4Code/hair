class SalonsController < ApplicationController
	  before_action :set_salon, only: [:show, :edit, :update, :destroy]
  
  def index
    @salons = Salon.all.order("created_at DESC").page(params[:page])
  end

  def new
    @salon = Salon.new
  end 

  def create
    @salon = Salon.new(salon_params)
    @salon.user_id = current_user.id
      if @salon.save
        flash[:success] = 'You have successfully listed your services!'
        redirect_to @salon
      else
        flash[:danger] = 'Something went wrong with salon your services!'
        redirect_to new_salon_path(@salon)
      end
  end   

  def show
  end

  def edit
    current_user = @salon.user_id
  end

  def update
    if @salon.update(salon_params)
      redirect_to @salon
    else
      redirect_to edit_salon_path
    end
  end

  def destroy
    @salon.destroy
    redirect_to "/profile"
  end

  def search
    @salons =  Salon.all
      filtering_params(params).each do |key,value|
        @salons = @salons.public_send(key, value) if value.present?
        if @salons.empty?
          flash.now[:notice] = "Sorry there are no results for your search. Try again."
        end
        @salons = @salons.page(params[:page]).order(created_at: :desc)
        respond_to do |format|
          format.js
          format.html {render "index"}
        end
      end
  end

  def insta
    @insta = @salon.instafeed
    @insta = @insta.gsub(/^(.{39,}?).*$/m,'\1/embed')
  end
    helper_method :insta

private

  def salon_params
    params.require(:salon).permit(:id, :page, :country, :location, :title, :description, :business_name, :contact,:contact_person, :suburb, :address, :facebook, :instagram, :website, :instafeed, speciality:[])
  end

  def set_salon
      @salon = Salon.find(params[:id]) 
  end

  def filtering_params(params)
    params.slice(:country, :location, :suburb, :instafeed)
  end


end
