#!/usr/bin/env bash

FILE_PATH=$1
# Highlander is an option that makes sure there are no collisions with the triggers.
HIGHLANDER=0
MINIMUM_WORD_LENGTH=5
MINIMUM_TRIGGER_LENGTH=3
PAD=$(($MINIMUM_WORD_LENGTH-3))
# bad triggers are words from the wordlist that are shorter than MINIMUM_WORD_LENGTH and have the form VCC.. or CCC..
bad_triggers=$(rg ^.[^aeiouy]{$PAD}[^aeiouy]?$  wiki_20k.txt | paste -sd ",")

awk -v highlander=$HIGHLANDER -v minimum_word_length=$MINIMUM_WORD_LENGTH -v minimum_trigger_length=$MINIMUM_TRIGGER_LENGTH -v bad_triggers="$bad_triggers" '
function disemvowel(word) {
  gsub(/[aeiouy]/, "", word)
  return word
}
function keep_first_letter_disemvowel(word){
  first_letter = substr(word, 1, 1)
  rest_of_word = substr(word, 2)
  return first_letter disemvowel(rest_of_word)
}
function remove_silent_letters(word){
  gsub(/ckn/, "ckkn", word) # fixes nickname
  gsub(/kn/, "n", word)
  gsub(/wh/, "w", word)
  gsub(/ck/, "k", word)
  gsub(/ght/, "t", word)
  gsub(/dge/, "j", word)
  gsub(/ph/, "f", word)
  return word
}
function remove_repeating_letters(word){
  # gsub(/(.)\1+/, "\\1", word) # remove repeating letters, not working for some reason
  gsub(/.*lly/, "", word) # skip words that ends in lly so the adverb doesnt conflict with the adjective. e.g. gradually and gradual.
  gsub(/ll/, "l", word)
  gsub(/tt/, "t", word)
  gsub(/ss/, "s", word)
  gsub(/rr/, "r", word)
  gsub(/dd/, "d", word)
  gsub(/ff/, "f", word)
  gsub(/pp/, "p", word)
  gsub(/nn/, "n", word)
  gsub(/hh/, "h", word)
  gsub(/mm/, "m", word)
  gsub(/cc/, "c", word)
  gsub(/gg/, "g", word)
  gsub(/bb/, "b", word)
  gsub(/zz/, "z", word)
  gsub(/kk/, "k", word)
  return word
}
function filter_bad(array){
  for (i in array){
    e = array[i]
    if (index(bad_triggers, e) != 0){
      delete array[i] 
    }
  }
}
function filter_short(array){
  for (i in array){
    e = array[i]
    if (length(e) < minimum_trigger_length){
      delete array[i] 
    }
  }
}
function filter_redundant(array,  seen){
  seen[original_word] = 1 
  for (i in array){
    e = array[i]
    if (seen[e] || length(e) == 0){
      delete array[i]
    }else{
      seen[e] = 1
    }
  }
}
{
  original_word = $0
  if (length(original_word) < minimum_word_length) {
    next
  }
    
  triggers["base"] = disemvowel(original_word)
  triggers["vowel_first"] = keep_first_letter_disemvowel(original_word)
  triggers["silent_letters"] = disemvowel(remove_silent_letters(original_word))
  triggers["vowel_silent_letters"] = keep_first_letter_disemvowel(remove_silent_letters(original_word))
  triggers["repeating_letters"] = disemvowel(remove_repeating_letters(original_word))
  triggers["vowel_repeating_letters"] = keep_first_letter_disemvowel(remove_repeating_letters(original_word))
  triggers["silent_repeating_letters"] = disemvowel(remove_silent_letters(remove_repeating_letters(original_word)))


  filter_bad(triggers)
  filter_short(triggers)
  # persist seen array for highlander edition
  if (highlander == 1) filter_redundant(triggers, seen) 
  else filter_redundant(triggers)
  
  if (length(triggers) == 0) {
    next
  }
  
  output = original_word
  for (i in triggers){
    e = triggers[i]
    output = output "\t" e
  }
  print output
}
' "$FILE_PATH"
