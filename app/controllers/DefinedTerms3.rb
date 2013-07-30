require_relative 'Text_Utilities.rb'
require 'pp'
require 'rubygems'
require 'active_support/inflector'

class Defined_Terms

  @defined_terms
  @plural_defined_terms = []
  @array_of_words
  @last_was_capitalized
  @last_was_period_or_newline
  @capital_term
  @TU
  @result_array
  
  attr_accessor :defined_terms
  
  def initialize(file_text)
    
    @defined_terms = get_defined_terms(file_text)
    temp_arr = []
    @defined_terms.each do |x|
      temp_arr.push(ActiveSupport::Inflector.pluralize(x))
    end
    @plural_defined_terms = temp_arr
    puts "@plural_defined_terms are: #{@plural_defined_terms}"
    @TU = Text_Utilities.new
    @array_of_words = @TU.string_to_array(file_text)

    @last_was_capitalized = false
    @last_was_defined_term = false
    @last_was_period_or_newline = false 
    @capital_term = ""
    @defined_term_tag = "i"
    @ALL_CAPS_TAG = "u"
    @UNDEFINED_TERM_TAG = "b"
    @newline_tag = "<br>"
    @tab_tag = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
      
    @result_array = []
    @capitalized_terms = []
    @MONTHS_AND_DAYS = ["January", "February", "March", "April", "May", "June", "July", "August", "September",
      "October", "November", "December", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @COMMON_AGREEMENT_WORDS = ["Section", "Sections", "Paragraph", "This", "Agreement", "Recitals", "Whereas", "Without", "Any", "Accordingly", 
      "The", "Except", "Nothing", "In", "This", "All", "Each", "Either", "Neither", "To", "Both", "Upon", "Notwithstanding", "Exhibit", "Schedule",
      "Pursuant", "If", "On", "When"]
    @STATES = ["Delaware", "California", "United States", "America", "State"]

  end
  
  def find_and_markup_whitespace()
    #puts "in find_and_markup_whitespace() and @array_of_words is: #{@array_of_words}"
    
    temp_results = []
    
    @array_of_words.each do |word|
    
      if @TU.is_newline(word)
        temp_results.push(@newline_tag)
      elsif @TU.is_tab(word)
        temp_results.push(@tab_tag)
      else 
        temp_results.push(word)
      end
  
    end
    
    #puts "temp_results is: #{temp_results}"
    
    @array_of_words = temp_results
    temp_results
    
  end
  
  def is_likely_defined_or_common(word)
    
    ret_val = false
    
    # check if it is in the list of defined terms
    if @defined_terms.index(word) != nil or @plural_defined_terms.index(word) != nil
      ret_val = true
    elsif @MONTHS_AND_DAYS.index(word) != nil
      ret_val = true
    elsif @TU.is_company_name(word)
      ret_val = true
    elsif @STATES.index(word) != nil
      ret_val = true
    elsif @COMMON_AGREEMENT_WORDS.index(word) != nil
      ret_val = true
    else
      ret_val = false
    end
        
    return ret_val
    
  end
  
  def find_and_markup_unused_defined_terms(file_text)
    
    # Check each defined term to see if it is in the document (but not in quotes).
    # If not, then replace it with a tagged version of itself
    @defined_terms.each do |term|
      puts "term is: #{term}"
      if file_text.match('[^\"]' + term + '[^\"]') == nil
        puts "we found it" 
        file_text.sub!(term , '<b><i>' + term  + '</b></i>')
      end
    end
    
    puts file_text
  end
    
  def find_and_markup_undefined_terms3()
    
    #puts "in find_and_markup_undefined_terms3(text) and @array_of_words is: #{@array_of_words}"
    
    last_was_capitalized = false
    last_was_period_or_newline = false
    capitalized_term = ""
    temp_results = []
    tag = @UNDEFINED_TERM_TAG
    beg_tag = '<'+tag+'>'; end_tag = '</'+tag+'>'
    
    i = 0
    
    until (@array_of_words.length == 0 or i == (@array_of_words.length - 2))
    
      word = @array_of_words[i]
      
      is_last_word = (i >= @array_of_words.length - 1) ? true : false
      
      if @TU.is_html(word)
        temp_results.push(word)
      elsif @TU.is_capitalized(word)
        if (! is_last_word and @TU.is_capitalized(@array_of_words[i+2]) and 
          ! @TU.starts_with_period(@array_of_words[i+1]) and ! @TU.starts_with_comma(@array_of_words[i+1]) and 
          ! @TU.starts_with_newline(@array_of_words[i+1]))
          if last_was_period_or_newline and is_likely_defined_or_common(word)
            temp_results.push(word)
            capitalized_term = ""
            last_was_capitalized = false; last_was_period_or_newline = false
          else
            capitalized_term += word
            last_was_capitalized = true
            last_was_period_or_newline = false
          end
        else
          capitalized_term += word
          #if @defined_terms.index(capitalized_term) != nil
          if is_likely_defined_or_common(capitalized_term)
            temp_results.push(capitalized_term); 
          else
            temp_results.push(beg_tag + capitalized_term + end_tag)
          end
          capitalized_term = ""
          last_was_capitalized = false
          last_was_period_or_newline = false
        end
      elsif last_was_capitalized
        capitalized_term += word
      else
        temp_results.push(word)
        last_was_capitalized = false
        last_was_period_or_newline = @TU.starts_with_period(word) or  @TU.starts_with_newline(word) ? true : false
      end
      i += 1
    end
    @array_of_words = temp_results
    temp_results
  end

  
  def find_and_markup_ALLCAPS()
    
    #puts "in find_and_markup_ALLCAPS() and @array_of_words is: #{@array_of_words}"
    
    last_was_ALLCAPS = false
    all_caps_term = ""
    temp_results = []
    tag = @ALL_CAPS_TAG
    beg_tag = '<'+tag+'>'; end_tag = '</'+tag+'>'
    
    i = 0
    
    until (@array_of_words.length == 0 or i == (@array_of_words.length - 2))
    
      word = @array_of_words[i]
      
      is_last_word = (i >= @array_of_words.length - 1) ? true : false
      
      if @TU.is_html(word)
        temp_results.push(word)
      elsif @TU.is_ALLCAPS(word)
        if ! is_last_word and @TU.is_ALLCAPS(@array_of_words[i+2])
          all_caps_term += word
          last_was_ALLCAPS = true
        else
          all_caps_term += word
          temp_results.push(beg_tag + all_caps_term + end_tag)
          all_caps_term = ""
          last_was_ALLCAPS = false
        end
      elsif last_was_ALLCAPS
        all_caps_term += word
      else
        temp_results.push(word)
        last_was_ALLCAPS = false
      end
      i += 1
    end
    @array_of_words = temp_results
    temp_results
  end
  
  def find_and_markup_quoted_terms()
    #puts "in find_and_markup_quoted_terms() and @array_of_words is: #{@array_of_words}"
    
    last_was_defined_term = false
    i = 0
    temp_results = []
    array_of_defined_terms = []
    tag = @defined_term_tag
    beg_tag = '<'+tag+'>'; end_tag = '</'+tag+'>'
    defined_term = ""
    
    @array_of_words.each do |word|
    
      is_last_word = (i >= @array_of_words.length - 1) ? true : false
      
      if @TU.is_fully_quoted_word(word)
        temp_results.push(beg_tag + word + end_tag)
        array_of_defined_terms.push(word)
        last_was_defined_term = false
        defined_term = ""
      elsif @TU.is_start_of_defined_term(word)
        defined_term = word
        last_was_defined_term = true
      elsif @TU.is_end_of_defined_term(word)
        defined_term += word 
        temp_results.push(beg_tag + defined_term + end_tag)
        array_of_defined_terms.push(defined_term)
        last_was_defined_term = false
        defined_term = ""
      elsif last_was_defined_term
        defined_term += word
      else 
        last_was_defined_term = false
        temp_results.push(word)
      end
  
    end
    
    #puts "temp_results is: #{temp_results}"
    @array_of_words = temp_results
    temp_results
    
  end
  
  def find_and_markup_undefined_terms2()
    
    #puts "in find_and_markup_undefined_terms(text) and @array_of_words is: #{@array_of_words}"
    
    @last_was_defined_term = false
    @last_was_capitalized = false
    i = 0
    
    until (@array_of_words.length == 0 or i == (@array_of_words.length - 2))
    
      word = @array_of_words[i]
      is_last_word = (i >= @array_of_words.length - 1) ? true : false
      
      if @TU.is_capitalized(word)
        if @last_was_defined_term
          @result_array.push(word)
          @last_was_capitalized = false
          @last_was_defined_term = true
        else
          @last_was_defined_term = false
          if ! is_last_word and @TU.is_capitalized(@array_of_words[i+2])
            @capital_term += word
            @last_was_capitalized = true
          else
            @capital_term += word
            if @defined_terms.index(@capital_term) != nil
              @result_array.push(@capital_term); 
            else
              @result_array.push("<B>"+@capital_term+"</B>")
            end
            @capital_term = ""
            @last_was_capitalized = false
          end
        end
      elsif @TU.is_lowercase(word)
        @result_array.push(word)
        @last_was_capitalized = false
       elsif @TU.is_space(word) or @TU.starts_with_comma(word) or @TU.starts_with_period(word)
        if @last_was_capitalized
          @capital_term += word
        else
          @result_array.push(word)
          @last_was_defined_term = false
        end
      elsif @TU.is_ALLCAPS(word)
        if ! is_last_word and @last_was_capitalized and @TU.is_capitalized(@array_of_words[i+2])
          @capital_term += word
        else
          @result_array.push(word)
          @last_was_capitalized = false
        end
        @last_was_capitalized = false
      elsif @TU.is_newline(word)
        @result_array.push('<br>')
        @last_was_capitalized = false
        @last_was_defined_term = false
      elsif @TU.is_tab(word)
        @result_array.push('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;')
        @last_was_capitalized = false
      elsif @TU.is_whitespace(word)
        @result_array.push(word + " ")
        @last_was_capitalized = false
        @last_was_defined_term = false
      elsif @TU.is_start_of_defined_term(word)
        @result_array.push(word)
        @last_was_capitalized = false
        @last_was_defined_term = true
      else
        #puts "in the else statement and word is: #{word}"
        @result_array.push(word)
        @last_was_capitalized = false
      end
    
    i += 1
    
  end
  
  @result_array.push(@array_of_words[@array_of_words.length - 1])
    
  @result_array
  
end
  

  def find_and_markup_undefined_terms(text)

    puts "in find_and_markup_undefined_terms(text) and @array_of_words is: #{@array_of_words}"
    @array_of_words.each do |word|         
        
    # special case: if last_was_period_or_newline and we are at a word, skip a certain set of common words
    if @last_was_period_or_newline
      process_if_last_was_period_or_newline(word)       
      next # no need to process anything else
    end
    
    # if word is a period or a newline AND we have been gathering up a capitalized
    # term, then we can replace that term with a markup
    if @TU.is_newline(word) or @TU.is_period(word)
      if @last_was_capitalized
        push_capitalized_term(word)
        push_period_or_newline(word)
        @last_was_period_or_newline = true
      else
        push_period_or_newline(word)
      end
    elsif @TU.is_capitalized(word) # if we encounter a capitalized term, start grabbing it
      build_capitalized_term(word)
    elsif @TU.is_lowercase(word) or @TU.is_ALLCAPS(word) # if we encounter a lowercase word, push it (and maybe a new cap term) to the result array and keep going
      if @last_was_capitalized
        push_capitalized_term(word)
        @last_was_period_or_newline = false
      else
        push_lowercase(word)
        @last_was_capitalized = false
        @last_was_period_or_newline = false
      end
    #elsif ! @TU.is_text(word)
    #  push_lowercase(word)
    elsif word == " "
      if @last_was_capitalized 
        #puts "word is ' '"
        build_capitalized_term(word)
      else
        push_lowercase(word)
      end
    else
      push_lowercase(word)
      #puts "In find_and_markup_undefined_terms(text) and we are in an else statement we shouldn't hit. word is: #{word}"
    end
    
  end
  
  puts "@Capitalized_terms are: #{@capitalized_terms}"
  
  #pp self
  
  puts "@result_array is: #{@result_array}"
  
  @result_array
  
  end
  
  # Helper Functions
  
  def push_lowercase(word)
    #puts "in push_lowercase and word is: #{word}, @last_was_capitalized is: #{@last_was_capitalized}, and @last_was_period_or_newline is: #{@last_was_period_or_newline}"
    if @TU.is_newline(word)
      @result_array.push("<br>")
    else
      if @last_was_capitalized
        @result_array.push(" ")
      end
      @result_array.push(word)
    end
    
    @last_was_capitalized = false
    @last_was_period_or_newline = false
  end
  
  def push_period_or_newline(word)
    @last_was_capitalized = false
    @last_was_period_or_newline = true
    if @TU.is_newline(word)
      @result_array.push("<br>")
    else
      @result_array.push(word)
    end
  end
  
  def push_capitalized_term(word)
    #puts "in push_capitalized_term and @capital_term is: #{@capital_term}"
    if @defined_terms.index(@capital_term) != nil
      @result_array.push(@capital_term); 
    else
      @result_array.push("<B>"+@capital_term+"</B>");
    end
    @capitalized_terms.push(@capital_term)
    
    @capital_term = ""
    @last_was_capitalized = false
    @result_array.push(" "); push_lowercase(word)
  end
  
  def build_capitalized_term(word)
    if @last_was_capitalized and @TU.is_capitalized(word)
      @capital_term += " " + word
    elsif @TU.is_capitalized(word)
      @capital_term += word
    end
    @last_was_capitalized = true
    @last_was_period_or_newline = false
    
    #puts "@capital_terms is: #{@capital_term}"
  end
  
  def process_if_last_was_period_or_newline(word)
    if @TU.is_capitalized(word)
      if @TU.is_common_capitalized_term(word)
        push_lowercase(word)
      else
        build_capitalized_term(word)
      end
    else # word is lowercase or newline or a period
      push_lowercase(word)
    end
  end
  
  def get_defined_terms(file_text)
    # create an array of the defined terms [Note, this won't pick up hyphenated words]
    #defined_terms = file_text.scan(/"[A-Z]\w*"|"[A-Z]\w*\s[A-Z]\w*"|"[A-Z]\w*\s[A-Z]\w*\s[A-Z]\w*"/)
    defined_terms = file_text.scan(/"[A-Z]\w*"|"[A-Z][\w-]* (?:[A-Za-z]\w*\s){0,4}[A-Z][\w-]*"/)
    
    #puts "defined_terms is: #{defined_terms}"
    #puts "defined_terms.flatten is: #{defined_terms.flatten}"
    
    fixed_defined_terms = []
    
    defined_terms.each do |term|
      fixed_defined_terms.push(term[1, term.length-2]) # remove the quotation marks
    end

    #puts "Fixed_defined_terms are: #{fixed_defined_terms}"
    fixed_defined_terms 

  end
end

