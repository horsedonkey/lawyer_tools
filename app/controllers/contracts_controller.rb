require_relative 'DefinedTerms3.rb'
require_relative 'Text_Utilities.rb'

class ContractsController < ApplicationController
  def input
  end

  def new
    @contract = Contract.new
  end

  def show 
    @contract = Contract.find(params[:id])
  end

  def create
    @contract = Contract.new(params[:contract])

    dts = Defined_Terms.new(@contract.original)

    dts.find_and_markup_unused_defined_terms(@contract.original)

    dts.find_and_markup_whitespace()
    dts.find_and_markup_quoted_terms()
    dts.find_and_markup_ALLCAPS()

    @contract.undefined_terms = Text_Utilities.new.print_array(dts.find_and_markup_undefined_terms3()) 
    @contract.save
    redirect_to @contract
  end    
    
end
