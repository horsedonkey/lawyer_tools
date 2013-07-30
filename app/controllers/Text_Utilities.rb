
class Text_Utilities

  def is_delimiter (char)
    (char.match(' ') or char.match(',') or char.match('\n') or char.match('\t') or char.match('\.') or char.match(';') or char.match('\s')) == nil ? false : true
  end

  def is_something(word, test)
    ret_val = false
    if (word != nil and word[0] != nil)
      ret_val = word.match(test) == nil ?  false : true
    end
    ret_val
  end

  def is_capitalized(word)
    is_something(word, '^[A-Z][a-z]*$|[A-Z][a-z]*-[A-Z][a-z]*$')
  end
  
  def is_lowercase(word)
    is_something(word, '^[a-z]+$|[a-z]+-[a-z]+$')
  end
  
  def is_ALLCAPS(word)
    ret_val = false
    if word != nil and ! is_whitespace(word) and is_text(word)
      ret_val = (word.upcase == word)
    end
    ret_val
  end

  def is_whitespace(word)
    is_something(word, '^\s+$')
  end

  def is_period(word)
    is_something(word, '^\.$')
  end
  
  def starts_with_period(word)
    is_something(word, '^\.\s*$')
  end
  
  def starts_with_comma(word)
    is_something(word, '^\,\s*$')
  end
  
  def is_newline(word)
    is_something(word, '^\n$')
  end
  
  def starts_with_newline(word)
    is_something(word, '^\n\s*$')
  end
  
  def is_tab(word)
    is_something(word, '^\t$')
  end
  
  def is_space(word)
    is_something(word, '^ $')
  end
  
  def is_text(word)
    is_something(word, '^[A-Za-z]+$')
  end
  
  def is_bracketed(word)
    is_something(word, '^<.*>$')
  end
  
  def is_company_name(word)
    is_something(word, '.* Inc\.$|.+ LLC$|.* Corp\.$')
    #is_something(word, '.* Corp\.$')
  end
  
  def is_start_of_defined_term(word)
    is_something(word, '^\(?\"[A-Z][a-z]*$|\(?\"[A-Z][a-z]*-[A-Z][a-z]*$')
  end
  
  def is_end_of_defined_term(word)
    is_something(word, '^[A-Z]\w*\"\)?$|[A-Z]\w*-[A-Z]\w*\"\)?$')
  end
  
  def is_fully_quoted_word(word)
    is_something(word, '^\(?\"[A-Z][a-z]*\"\)?$|^\(?\"[A-Z][a-z]*-[A-Z][a-z]*\"\)?$')
  end
  
  def is_common_capitalized_term(word)
    ['The', 'This', 'Except', 'Nothing', 'In', 'On', 'Whereas', 'Section'].index(word) == nil ? false : true
  end
  
  def is_marked_up_term(word, tag)
    is_something(word, '^<'+tag+'>.*</'+tag+'>$')
  end
  
  def is_html(word)
    is_something(word, '^<.*>$')
  end
  
  def remove_words_after_periods(word_array)
    
    last_was_period = false
    return_arr = []
  
    word_array.each do |word|
      if last_was_period
        last_was_period = false
      else
        return_arr.push(word)
      end
      
      if is_period(word)
        last_was_period = true
      else 
        last_was_period = false
      end
    end
    return_arr 
  end
  
  def string_to_array(text)
    word_arr = []
    temp_string = ""
    last_char_was_whitespace = false
    text.each_char do |char|
      
      delimiter = is_delimiter(char)
      #puts "In the char loop and char is: #{char} || and delimiter is: #{delimiter} || is_newline is: #{is_newline(char)}"
      
      if is_newline(char) or is_tab(char)
        unless (temp_string == nil or temp_string == "") 
          word_arr.push(temp_string)
        end
        word_arr.push(char)
        temp_string = ""
        last_char_was_whitespace = false
        next
      end
      
      if delimiter and ! last_char_was_whitespace # we found the end of a word
        word_arr.push(temp_string)
        temp_string = char
        last_char_was_whitespace = true
      elsif delimiter and last_char_was_whitespace # we are in the middle of a block of whitespace
          temp_string += char
      elsif !delimiter and last_char_was_whitespace # we found the start of a word
        word_arr.push(temp_string)
        temp_string = char
        last_char_was_whitespace = false
      else # we are in the middle of a word
        temp_string += char
        last_char_was_whitespace = false
      end
    end
    
    word_arr.push(temp_string)
    
    word_arr
  end
  
  def print_array(arr)
    temp = ""
    arr.each { |x| temp += x}
    temp
  end
  
end