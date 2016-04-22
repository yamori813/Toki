#!/usr/bin/env ruby

host = "127.0.0.1"
port = 9199
name = "mfcc_test"
FRAMES = 8

require 'jubatus/classifier/client'

client = Jubatus::Classifier::Client::Classifier.new(host, port, name)

testsnd = []

if ARGV[0] != nil 
testsnd = [ARGV[0]]
else
testsnd = [
"snd/T40.aiff",
"snd/T8.aiff",
"snd/T30.aiff",
"snd/T68.aiff"
]
end

testsnd.each{|file|
    IO.popen("./delta.sh " << FRAMES.to_s << " " << file, "r+") {|io|
        io.close_write
        lpc = io.read(16*4*FRAMES*3)
        x = lpc.unpack("f*")
        mfcc = {}
        for num in 0..15 do
          for frame in 0..FRAMES-1 do
            mfcc["a" << frame.to_s << num.to_s] = x[num + frame * 16 * 3]
          end
        end
        results = client.classify [Jubatus::Common::Datum.new(mfcc)]
        puts file + " " + results[0].max_by{ |x| x.score }.label 
#        results.each { |result|
#            result.each { |r|
#                puts(r.label + " " + r.score.to_s)
#            }
#        puts
#        }
    }
}
