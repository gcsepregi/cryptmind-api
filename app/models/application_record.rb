class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  include Hashid::Rails

  def to_param
    hashid
  end

end
