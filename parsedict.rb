require 'json'

text = File.readlines('cleancmu.txt')

sylhash = {}

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
    sylhash[thisword.downcase] = sylcount
  end
end
print sylhash.to_json
