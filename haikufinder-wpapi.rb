#! /usr/bin/ruby
require 'json'
require 'mechanize'

# USAGE - can take as argument either a file or a url
# This could be slicker obviously
if ARGV.empty?
  puts "Usage: haikufinder [file|url]"
  exit
end
if ARGV[0] =~ /^http/
  url = ARGV[0]
  agent = Mechanize.new
  page = agent.get(url)
  wp_output = page.body
else
  wp_output = File.read(ARGV[0])
end

json_list = JSON.parse(wp_output)
text_string = ""

# grab titles and content and cleanup tags
json_list.each do |thisitem|
  title = thisitem['title']['rendered'].to_s.gsub(/<[^>]*>/,' ').gsub(/\s+/,' ').strip
  content = thisitem['content']['rendered'].to_s.gsub(/<[^>]*>/,' ').gsub(/\s+/,' ').strip
  text_string += title + '. '
  text_string += content + ' '
end

text = text_string
print text
SYLHASH = JSON.parse(File.read('dict.json'))

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
