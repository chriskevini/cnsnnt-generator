awk '
{
  for(i=2; i<=NF; i++) {
    word = $i
    count[word]++

    if (count[word] == 1) {
      j++
      order[j] = word
    }
  }
}

END {
  for (k = 1; k <= j; k++) {
    word_to_check = order[k]
    
    if (count[word_to_check] == 1) {
      print word_to_check
    }
  }
}
'
