class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def assign_attributes(new_attributes)
    valid_attributes = new_attributes.slice(*self.class.column_names.map(&:to_sym))
    if valid_attributes.empty?
      raise ArgumentError, "Cannot assign attributes, none of the provided attributes are valid: #{new_attributes.keys.join(', ')}"
    end

    super(valid_attributes)
  end
end
