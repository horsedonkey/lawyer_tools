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

require 'spec_helper'

describe Contract do

  before { @contract = Contract.new(original: "This is the original", undefined_terms: "This the markup.") }

  subject { @contract }

  it { should respond_to(:original) }
  it { should respond_to(:undefined_terms) }

end
