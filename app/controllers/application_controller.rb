require "dry-validation"

class ParamsValidationError < StandardError
  attr_reader :errors

  def initialize(first_message, *messages)
    super([first_message, *messages].join(", "))

    @errors = [first_message, *messages]
  end
end

class ApplicationController < ActionController::Base
  include Authentication

  def self.rescue_render(method, &block)
    prepend_before_action -> do
      @_rescue_render = block
    end, only: [method]
  end

  rescue_from ParamsValidationError, ActiveRecord::ActiveRecordError do |exception|
    case exception
    in ParamsValidationError
      flash[:errors] = exception.errors
    in ActiveRecord::ActiveRecordError
      flash[:errors] = [exception.message]
    else
      flash[:errors] = ["An unexpected error occurred: #{exception.message} (class #{exception.class.name})"]
    end

    if @_rescue_render.blank?
      raise "No rescue_render block defined for #{self.class.name}##{action_name}"
    end
    instance_exec exception, &@_rescue_render
  end

  protect_from_forgery with: :exception

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: { ie: false }

  helper_method :format_monetary

  def format_monetary(amount)
    return "" if amount.nil?
    return "0" if amount <= 0

    decimal = amount % 1.0
    value = amount.floor
    result = ""

    while value > 0
      result = "," + (value % 1000).to_s.rjust(3, "0") + result
      value = (value / 1000).floor
    end

    result = result.sub(/^[,0]+/, "")
    result += decimal.to_s.sub(/^0/, "") if decimal > 0
    result
  end

  def self.dry_params(params_name, &block)
    define_method params_name do
      contract = Dry::Validation.Contract(&block)
      result = contract.call(params.to_unsafe_h)

      if result.failure?
        raise ParamsValidationError.new(*result.errors(full: true).map { |e| e.text })
      end

      result.to_h
    end
  end
end
