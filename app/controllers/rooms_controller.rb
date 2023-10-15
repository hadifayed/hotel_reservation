class RoomsController < ApplicationController
  before_action :authenticate_user!
  
  # GET /rooms
  def index
    @rooms = Room.all

    render json: @rooms
  end

  # POST /rooms
  def create
    @room = Room.new(room_params)
    authorize! :create, @room

    if @room.save
      render json: @room, status: :created, location: @room
    else
      render json: @room.errors.full_messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /rooms/1
  def update
    @room = Room.find(params[:id])
    authorize! :update, @room

    if @room.update(room_params)
      render json: @room
    else
      render json: @room.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def room_params
    params.require(:room).permit(:description, :capacity, :price_per_night)
  end

  def current_ability
    @current_ability ||= RoomAbility.new(current_user)
  end
end
