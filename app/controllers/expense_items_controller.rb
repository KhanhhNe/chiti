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
    @expense_item.update_participants(participants_params)

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
    @expense_item.update_participants(participants_params)

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

    rule(:amount) do
      participants_amount = values[:participants].sum { |p| p[:amount] }
      if participants_amount != value
        key.failure("must be equal to the sum of participants' amounts (#{participants_amount})")
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
