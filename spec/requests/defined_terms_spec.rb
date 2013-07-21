require 'spec_helper'

describe "DefinedTerms" do

  describe "Input page" do

    it "should have the content 'Defined Terms'" do
      visit input_path
      page.should have_content('Defined Terms')
    end
  end
end
