module Autofill

  
  STOPWORDS = ['', 'for', 'and', 'of', 'or', 'the', 'a', 'in']

  def self.stopword?(word)
    STOPWORDS.include?(word.downcase)
  end

  # Given a set of words, returns a set of phrases.
  # For example, if words = ["Who's", "on", "first"],
  # the return value would be ["first", "on first",
  # "Who's on first"]. This is used in constructing
  # autofill entries.
  def self.collect_phrases(words, ignore_list = [])
    phrases = []
    last = words.length - 1
    i = last
    while i > 0 do
      word = words[(i - 1)]
      if stopword?(word) or ignore_list.include?(word)
        i -= 1
      end
      phrases.push(words[(i - 1)..last].join(' '))
      i -= 1
    end
    phrases
  end

  # Splits string into words and phrases for autofill.
  # Returns a list of tuples, in which each tuple is
  # [word_or_phrase, string_starts_with]
  # First item is a word or a phrase. Second is a bool
  # indicating whether the original string starts with
  # that word or phrase.
  def self.words_and_phrases(string, ignore_list = [])
    char_only_string = string.gsub(/\W+/, '')
    word_list = []
    words = string.split(/\W+/) 
    words.each do |word|
      next if word.nil? or stopword?(word) or ignore_list.include?(word)
      word_list.push([word, string.start_with?(word)])
    end
    collect_phrases(words, ignore_list).each do |phrase|
      word_list.push([phrase, 
                      (string.start_with?(phrase) or 
                       phrase.gsub(/\W+/, '') == char_only_string)])
    end
    word_list
  end

end
