#! /usr/bin/ruby

# USAGE - can take as argument either a file or a url
# This could be slicker obviously
if ARGV.empty?
  puts "Usage: haikufinder [file|url]"
  exit
end
if ARGV[0] =~ /^http/
  url = ARGV[0]
  text = `wget #{url} -O -`
else
  text = File.read(ARGV[0])
end

# First we parse our hyphenated dictionary file (modified from wherever I originally found this)
# Entries in this file are split with either a "|" or for hyphenated words a "-"
# We're creating a constant SYLHASH in which we can look up words and determine number of syllables
# Note that some words can be pronounced with multiple numbers of syllables so this isn't perfect
SYLHASH = {}
sylfile = File.open('hyphenated_dict.txt')
sylfile.each_line do |line|
  splitline = line.chomp.split(/[\|-]/)
  word = splitline.join('')
  syllables = splitline.size
  SYLHASH[word.downcase] = syllables unless SYLHASH[word.downcase].to_i > 0 and SYLHASH[word.downcase].to_i < syllables
end

# This takes a line/sentence and returns an array with the number of syllables per word
def getsyllist(line)
  originalline = line
  line = line.gsub(/[\.!?,":;()_]/,'').gsub(/--/,'').gsub(/\s+/,' ').downcase
  linewordlist = line.split(/\s+/)
  sylcount = 0
  if linewordlist.size >= 0
    sylcount = 0
    syllist = []
    linewordlist.each do |word|
      word = word.chomp.strip
      if SYLHASH[word].to_i > 0
        syllist.push(SYLHASH[word].to_i)
        sylcount = sylcount + SYLHASH[word].to_i
      else
        return []
      end
    end
    return syllist
  end
end

def get_haiku_list(text)
  haikulist = []
  wholetext = ''
  text.each_line do |line|
    wholetext += line.chomp + ' '
  end
  wholetext = wholetext.gsub(/\s+/,' ')

  # Need to split on punctuation but avoid ending prematurely on punctuated honorifics
  wholetextlist = wholetext.scan(/[^\.!?]+(?<!Mr|Mrs|Dr)[\.!?]/).map {|s| s.strip}

  # wholetextlist now should have entire text parsed into sentences if all has gone well
  wholetextlist.each do |line|
    originalline = line
    syllist = getsyllist(line)
    sylcount = 0
    syllist.each do |thissyl|
      sylcount += thissyl.to_i
    end
    if sylcount == 17
      haikulist.push([originalline, syllist])
    end
  end
  return haikulist
end

haikulist = get_haiku_list(text)
haikulist.each do |thishaiku|
  originalline = thishaiku[0]
  syllist = thishaiku[1]
  puts originalline
  puts syllist.join('-')
end
