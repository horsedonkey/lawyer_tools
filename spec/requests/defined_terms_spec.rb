require 'spec_helper'

describe "DefinedTerms" do

  describe "Input page" do

    it "should have the content 'Defined Terms'" do
      visit '/defined_terms/input'
      page.should have_content('Defined Terms')
    end
  end
end
