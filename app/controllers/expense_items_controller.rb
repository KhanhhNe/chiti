class ExpenseItemsController < ApplicationController
  before_action -> { @expense_event = @current_user.expense_events.find(params[:expense_event_id]) }

  def new
    @expense_item = @expense_event.expense_items.new(paid_on: Date.today)
  end

  rescue_render :create do
    @expense_item = @expense_event.expense_items.new(params[:expense_item].to_unsafe_h)
    render :new, status: :unprocessable_entity
  end
  def create
    @expense_item = @expense_event.expense_items.new(expense_item_params[:expense_item])

    validate_participants
    validate_total_amount

    update_participants(@expense_item, participants_params)

    @expense_item.save!
    flash.now[:notice] = "Expense item was successfully created."
    redirect_to @expense_event
  end

  def edit
    @expense_item = @expense_event.expense_items.find(params[:id])
  end

  rescue_render :update do
    render :edit, status: :unprocessable_entity
  end
  def update
    @expense_item = @expense_event.expense_items.find(params[:id])
    @expense_item.update(expense_item_params[:expense_item])

    validate_participants
    validate_total_amount

    update_participants(@expense_item, participants_params)

    @expense_item.save!
    flash.now[:notice] = "Expense item was successfully updated."
    redirect_to @expense_item
  end

  def show
    @expense_item = @expense_event.expense_items.includes(:item_participants => :event_participant).find(params[:id])
  end

  def expense_item_url(item)
    expense_event_expense_item_url(item.expense_event_id, item)
  end

  private

  def update_participants(expense_item, new_participants)
    current_participants = expense_item.item_participants.to_a

    new_participants.each do |participant|
      event_participant_id = participant[:id]

      item_participant = current_participants.find { |ip| ip.event_participant_id == event_participant_id }
      if item_participant.present?
        item_participant.amount = participant[:amount]
      else
        item_participant ||= ItemParticipant.new(
          expense_event_id: expense_item.expense_event_id,
          expense_item: expense_item,
          event_participant_id: event_participant_id,
          amount: participant[:amount]
        )
        expense_item.item_participants << item_participant
      end
    end
  end

  def validate_participants
    participant_ids = @expense_event.event_participants.pluck(:id)
    params_participant_ids = participants_params.map { |p| p[:id].to_i }

    if params_participant_ids - participant_ids != []
      raise ParamsValidationError.new("One or more participants are invalid.")
    end
  end

  def validate_total_amount
    total_amount = participants_params.sum { |p| p[:amount] }

    if total_amount != expense_item_params[:expense_item][:amount]
      raise ParamsValidationError.new("Total amount (#{total_amount}) does not equal to expense item amount (#{expense_item_params[:expense_item][:amount]}).")
    end
  end

  def expense_item_params; end

  dry_params :expense_item_params do
    params do
      required(:expense_item).hash do
        required(:name).filled(:string)
        required(:amount).filled(:monetary)
        required(:paid_by_id).filled(:integer)
        required(:paid_on).filled(:date)
        required(:participants).array(:hash) do
          required(:id).filled(:integer)
          optional(:enabled).filled(:checkbox)
          required(:amount).filled(:monetary)
        end
      end
    end
  end

  def participants_params
    expense_item_params[:expense_item][:participants] || []
  end

  helper_method :participants

  def participants
    return @_participants if defined?(@_participants)

    item_participants = @expense_item&.item_participants&.to_a || []
    participant_params = params.dig(:expense_item, :participants) || []

    @_participants ||= @expense_event.event_participants.includes(:user).map do |participant|
      item_participant = item_participants.find { |ip| ip.event_participant_id == participant.id }
      participant_param = participant_params.find { |pp| pp[:id].to_i == participant.id }

      name = participant.participant_name || "Unknown"
      name = "#{name} (Me)" if participant.user_id == @current_user.id
      {
        id: participant.id,
        name: name,
        enabled: participant_param.present? ? participant_param[:enabled] == "on" : true,
        amount: item_participant&.amount || 0.0
      }
    end
  end
end
