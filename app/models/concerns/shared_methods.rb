module SharedMethods
  extend ActiveSupport::Concern

  def strip_whitespaces *field_list
    field_list.each do |f|
      self[f] = self[f].strip if self[f].respond_to?(:strip)
    end
  end

  module ClassMethods
  end
end
