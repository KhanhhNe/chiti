class ExpenseItemsController < ApplicationController
  before_action :set_expense_event

  def new
    @expense_item = @expense_event.expense_items.new(paid_on: Date.today)
  end

  def create
    @expense_item = @expense_event.expense_items.new(expense_item_model_params)

    return unless validate_participants
    return unless validate_total_amount

    update_participants(@expense_item, participants_params)

    if @expense_item.save
      redirect_to @expense_event, notice: "Expense item was successfully added."
    else
      flash.now[:errors] = @expense_item.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @expense_item = @expense_event.expense_items.find(params[:id])
  end

  def update
    @expense_item = @expense_event.expense_items.find(params[:id])

    validate_participants
    validate_total_amount

    update_participants(@expense_item, participants_params)

    if @expense_item.save
      redirect_to @expense_item, notice: "Expense item was successfully added."
    else
      flash.now[:errors] = @expense_item.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  private

  def update_participants(expense_item, new_participants)
    current_participants = expense_item.item_participants

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
      flash.now[:errors] = ["One or more participants are invalid."]
      render :new, status: :unprocessable_entity
      return false
    end

    true
  end

  def validate_total_amount
    total_amount = participants_params.sum { |p| p[:amount] }
    if total_amount != expense_item_params[:amount]
      flash.now[:errors] = ["Total amount (#{total_amount}) does not equal to expense item amount (#{expense_item_params[:amount]})."]
      render :new, status: :unprocessable_entity
      return false
    end

    true
  end

  def set_expense_event
    @expense_event = @current_user.expense_events.find(params[:expense_event_id])
  end

  def expense_item_params
    parsed = params.require(:expense_item).permit(
      :name, :amount, :paid_by_id, :expense_event_id, :paid_on,
      participants: [[:id, :enabled, :amount]]
    )

    update_hash_path!(parsed, [:amount], method(:parse_monetary_number))
    update_hash_path!(parsed, [:paid_by_id], ->(v) { v&.to_i })
    parsed[:participants] = (parsed[:participants] || []).map do |p|
      p.merge(
        {
          id: p[:id].to_i,
          amount: parse_monetary_number(p[:amount])
        }
      )
    end

    parsed
  end

  def expense_item_model_params
    expense_item_params.slice(:name, :amount, :paid_by_id, :expense_event_id, :paid_on)
  end

  def participants_params
    expense_item_params[:participants] || []
  end

  helper_method :participants

  def participants
    @_participants ||= @expense_event.event_participants.includes(:user).map do |participant|
      name = participant.participant_name || "Unknown"
      name = "#{name} (Me)" if participant.user_id == @current_user.id
      {
        id: participant.id,
        name: name
      }
    end
  end
end
