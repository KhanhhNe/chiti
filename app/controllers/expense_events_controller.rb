class ExpenseEventsController < ApplicationController
  def index
    @events = @current_user.expense_events
  end

  def show
    @event = @current_user.expense_events.find(params[:id])
    @items = @event.expense_items.includes(:paid_by => :user).order(:paid_on => :desc).group_by(&:paid_on)
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

  helper_method :unsafe_participant_names, :total_my_expenses, :total_expenses

  def unsafe_participant_names
    params.dig(:expense_event, :participant_names).presence || []
  end

  def total_my_expenses
    @event
      .item_participants
      .joins(:event_participant)
      .where(event_participants: { user: @current_user })
      .select('SUM(item_participants.amount) as total_expense_amount')
      .as_json.first['total_expense_amount'] || 0
  end

  def total_expenses
    @event
      .item_participants
      .select('SUM(item_participants.amount) as total_expense_amount')
      .as_json.first['total_expense_amount'] || 0
  end
end
