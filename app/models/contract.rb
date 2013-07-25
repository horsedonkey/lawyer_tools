# == Schema Information
#
# Table name: contracts
#
#  id              :integer          not null, primary key
#  original        :text
#  undefined_terms :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Contract < ActiveRecord::Base
  attr_accessible :original, :undefined_terms
end
