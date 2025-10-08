awk '
{
  for(i=2; i<=NF; i++) {
    word = $i
    if (seen[word] == 1) {
      collisions++
    }
    triggers++
    seen[word] = 1
  }
}
END { 
    print "------------------";
    print "Total Collisions: " collisions;
    print "Total Triggers: " triggers;
    print "C/T: " collisions/triggers;
}'

