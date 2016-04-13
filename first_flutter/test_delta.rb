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
          sum = 0
          for frame in 0..FRAMES-1 do
            sum = sum + x[num + frame * 16 * 3]
          end
          mfcc["a" << num.to_s] = sum / FRAMES
        end
        max = mfcc.max { |a, b| a[1] <=> b[1] }
        min = mfcc.min { |a, b| a[1] <=> b[1] }
        for num in 0..15 do
          val = mfcc["a" << num.to_s]
          mfcc["a" << num.to_s] = (val - min[1]) / (max[1] - min[1])
        end
        delta = {}
        for num in 0..15 do
          sum = 0
          for frame in 0..FRAMES-2 do
            sum = sum + x[num + 16 + frame * 16 * 3].abs
          end
          delta["d" << num.to_s] = sum / (FRAMES - 1)
        end
        max = delta.max { |a, b| a[1] <=> b[1] }
        min = delta.min { |a, b| a[1] <=> b[1] }
        for num in 0..15 do
          val = delta["d" << num.to_s]
          delta["d" << num.to_s] = (val - min[1]) / (max[1] - min[1])
        end
        mfcc.update(delta)
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
