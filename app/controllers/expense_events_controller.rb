class ExpenseEventsController < ApplicationController
  def index
    @events = @current_user.expense_events
  end

  def show
    @event = ExpenseEvent.find(params[:id])
    unless @event.users.include?(@current_user)
      redirect_to expense_events_path, alert: "You do not have access to this event."
    end
  end

  def new
    @event = ExpenseEvent.new
  end

  def create
    @event = ExpenseEvent.new(event_params.slice(:name))
    @event.users << @current_user

    participant_names = event_params[:participant_names].filter_map { |name| name.strip.presence }
    participant_names.each do |participant_name|
      @event.event_participants << EventParticipant.new(name: participant_name)
    end

    if @event.save
      redirect_to @event, notice: "Expense event was successfully created."
    else
      flash.now[:errors] = @event.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  private

  def event_params
    params.expect(expense_event: [:name, participant_names: []])
  end

  helper_method :unsafe_participant_names
  def unsafe_participant_names
    params.dig(:expense_event, :participant_names).presence || []
  end
end
