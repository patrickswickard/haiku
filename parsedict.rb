require 'json'

text = File.readlines('cleancmu.txt')
text2 = File.read('dict-old.json')

sylhash = JSON.parse(text2)
#print sylhash

text.each do |thisline|
  if thisline =~ /^\w/
    thisarray = thisline.split(/\s+/)
    thisword = thisarray[0]
    sylcount = 0
    thisarray.each do |thisdatum|
      if thisdatum =~ /(\d)$/
        sylcount += 1
      end
    end
    if not sylhash[thisword.downcase]
      #print("hi #{thisword}\n")
      sylhash[thisword.downcase] = sylcount
    else
      #print("innit #{thisword.downcase}\n")
    end
  end
end
print sylhash.to_json
