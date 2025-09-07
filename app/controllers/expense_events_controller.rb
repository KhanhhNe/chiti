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

  rescue_render :create do
    @event = ExpenseEvent.new(params[:expense_event].to_unsafe_h)
    render :new, status: :unprocessable_entity
  end
  def create
    @event = ExpenseEvent.new(event_params[:expense_event])
    @event.users << @current_user

    event_params[:expense_event][:participant_names].each do |participant_name|
      @event.event_participants << EventParticipant.new(name: participant_name)
    end

    @event.save!
    flash.now[:notice] = "Expense event was successfully created."
    redirect_to @event
  end

  private

  def event_params; end

  dry_params :event_params do
    params do
      required(:expense_event).hash do
        required(:name).filled(:string)
        required(:participant_names).maybe(:non_empty_values_array)
      end
    end
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
