class ExpenseEventsController < ApplicationController
  def index
    @events = @current_user.expense_events
  end

  def show
    @event = @current_user.expense_events.find(params[:id])
    @items = @event.expense_items.includes(paid_by: :user).order(paid_on: :desc).group_by(&:paid_on)
  end

  def new
    @event = @current_user.expense_events.new
  end

  rescue_render :create do
    @event = @current_user.expense_events.new(params[:expense_event].to_unsafe_h)
    @participants_info = params.dig(:expense_event, :participants_info) || []
    render :new, status: :unprocessable_entity
  end

  def create
    @event = @current_user.expense_events.new(event_params[:expense_event])
    @event.users << @current_user

    event_params[:expense_event][:participants_info].each do |participant|
      @event.event_participants << EventParticipant.new(name: participant[:name])
    end

    @event.save!
    flash[:notice] = "Expense event was successfully created."
    redirect_to @event
  end

  def edit
    @event = @current_user.expense_events.find(params[:id])
    @participants_info = @event
      .event_participants
      .includes(:user)
      .map { |p| { user_id: p.user_id, name: p.participant_name, readonly: true } }
    @participants_info += params.dig(:expense_event, :participants_info) || []
  end

  rescue_render :update do
    @event = @current_user.expense_events.find(params[:id])
    @event.assign_attributes(params[:expense_event].to_unsafe_h)
    @participants_info = params.dig(:expense_event, :participants_info) || []
    render :edit, status: :unprocessable_entity
  end

  def update
    @event = @current_user.expense_events.find(params[:id])
    @event.assign_attributes(event_params[:expense_event])

    event_params[:expense_event][:participants_info].each do |participant|
      next if participant[:readonly]
      @event.event_participants << EventParticipant.new(name: participant[:name])
    end

    @event.save!
    flash[:notice] = "Expense event was successfully updated."
    redirect_to @event
  end

  def destroy
    @event = @current_user.expense_events.find(params[:id])
    @event.destroy
    flash[:notice] = "Expense event was successfully deleted."
    redirect_to expense_events_path
  end

  private

  def event_params; end

  dry_params :event_params do
    params do
      required(:expense_event).hash do
        required(:name).filled(:stripped_string)
        required(:participants_info).array(:hash) do
          required(:name).filled(:stripped_string)
          optional(:readonly).filled(:checkbox)
        end
      end
    end

    rule(expense_event: :participants_info) do
      key.failure("participant name must be present") if value.any? { |p| p[:name].empty? }
    end
  end

  helper_method :total_my_expenses, :total_expenses

  def total_my_expenses
    @event
      .item_participants
      .joins(:event_participant)
      .where(event_participants: { user: @current_user })
      .select("SUM(item_participants.amount) as total_expense_amount")
      .as_json.first["total_expense_amount"] || 0
  end

  def total_expenses
    @event
      .item_participants
      .select("SUM(item_participants.amount) as total_expense_amount")
      .as_json.first["total_expense_amount"] || 0
  end
end
