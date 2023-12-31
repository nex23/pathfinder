class InternshipsController < ApplicationController
  before_action :set_internship, only: %i[show edit update]
  skip_before_action :authenticate_user!, only: %i[index show categories]

  def index
    if user_signed_in? == false || current_user.role == false
      #student or logout
      @internships = Internship.all
      if params[:query].present?
        @internships = @internships.search_by_title(params[:query])
        @no_results = @internships.empty?
      end
    else
      #company
      @internships = Internship.where(user: current_user)
      if params[:filter] == 'Abierta'
        @internships = @internships.where(status: 'Abierta')
      elsif params[:filter] == 'Finalizada'
        @internships = @internships.where(status: 'Finalizada')
      end
    end
  end

  def show
    @postulation = Postulation.new
  end

  def new
    @internship = Internship.new
  end

  def create
    @internship = Internship.new(internship_params)
    @internship.user = current_user

    if @internship.save
      redirect_to internship_path(@internship)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @internship.update(internship_params)
    redirect_to internship_path(@internship)
  end

  def categories
    @category = params[:category]
    @internships = Internship.search_by_category(@category)
    @no_results = @internships.empty?
  end


  def change_status_to_finished
    @internship = Internship.find(params[:id])
    @internship.status = true
    if @internship.save
      redirect_to internship_path(@internship)
    else
      render :new, status: :unprocessable_entity
    end
  end


    private

  def internship_params
    params.require(:internship).permit(:category, :title, :description, :tipo, :status, :duration, :paid, :city, :country, :start_date, :end_date)
  end

  def set_internship
    @internship = Internship.find(params[:id])
  end
end
