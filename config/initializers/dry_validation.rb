require 'dry-types'
require 'dry-validation'

module Types
  include Dry.Types
end

def monetary; end

Dry::Types.register('params.monetary', Types::Nominal::Float.constructor do |value|
  return nil if value.blank?

  value.to_s.gsub(/[^0-9.]/, "").to_f
end)

def checkbox; end

Dry::Types.register('params.checkbox', Types::Params::Bool.constructor { |value| value == "on" })
