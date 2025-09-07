require "dry-types"
require "dry-validation"

module Types
  include Dry.Types
end

def monetary; end

Dry::Types.register("params.monetary", Types::Nominal::Float.constructor do |value|
  return nil if value.blank?

  value.to_s.gsub(/[^0-9.]/, "").to_f
end)

def checkbox; end

Dry::Types.register("params.checkbox", Types::Nominal::Bool.constructor { |value| value == "on" })

def non_empty_values_array; end

Dry::Types.register("params.non_empty_values_array", Types::Array.constructor { |arr| arr.reject(&:blank?) })
