class MediaController < ApplicationController
  before_action :set_medium, only: %i[update edit]

  def index
    @media = Medium.order(created_at: :desc)
  end

  def new
    @medium = Medium.new
  end

  def create
    @medium = Medium.new(medium_params)

    respond_to do |format|
      if @medium.save
        format.html { redirect_to media_path, notice: "Medium was successfully created." }
      else
        format.html { render :new, alert: "error", status: :unprocessable_entity }
        # format.html { render :new, warning: "#{@medium.errors}", status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @medium.update(medium_params)
      redirect_to media_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Medium.destroy(params[:id])
    redirect_to media_path
  end

  private

  def medium_params
    params.require(:medium).permit(:name, :url, :rss)
  end

  def set_medium
    @medium = Medium.find_by(id: params[:id])
  end
end
