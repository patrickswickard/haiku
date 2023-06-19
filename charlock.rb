require 'charlock_holmes'

s = open("cmudict-0.7b", "r") { |io| io.read }
d = CharlockHolmes::EncodingDetector.detect(s)
print d
