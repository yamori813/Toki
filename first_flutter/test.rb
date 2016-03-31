#!/usr/bin/env ruby

host = "127.0.0.1"
port = 9199
name = "gain_test"

require 'jubatus/classifier/client'

client = Jubatus::Classifier::Client::Classifier.new(host, port, name)

testsnd = [
"snd/T8.aiff",
"snd/T68.aiff"
]

testsnd.each{|file|
    IO.popen("./mfcc.sh " << file, "r+") {|io|
        io.close_write
        lpc = io.read(16*4)
        x = []
        x = lpc.unpack("f*")
        hash = {}
        for num in 0..15 do
            hash["a" << num.to_s] = x[num]
        end
        results = client.classify [Jubatus::Common::Datum.new(hash)]
        puts file + " " + results[0].max_by{ |x| x.score }.label 
#        results.each { |result|
#            result.each { |r|
#                puts(r.label + " " + r.score.to_s)
#            }
#        puts
#        }
    }
}
