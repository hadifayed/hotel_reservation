class RangeParserService
  attr_reader :range

  def initialize(room_reservation_params)
    @check_in = room_reservation_params[:check_in]
    @check_out = room_reservation_params[:check_out]
    @range = nil
  end

  def parse_range
    return if @check_in.blank? || @check_out.blank?

    begin
      @range = @check_in.to_date..@check_out.to_date
    rescue Date::Error
      @range = nil
    end
  end
end