require 'spec_helper'

describe "ContractPages" do

  subject { page }

  describe "Contract Input" do
    before { visit input_path }

    it { should have_selector('h1', text: 'Contract') }
  end
end
