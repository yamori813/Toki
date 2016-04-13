#!/usr/bin/env ruby

host = "127.0.0.1"
port = 9199
name = "mfcc_test"

require 'jubatus/classifier/client'

client = Jubatus::Classifier::Client::Classifier.new(host, port, name)

train_data = []

open("list.csv") do |file|
    while l = file.gets
        array = l.chomp.split(",")
        IO.popen("./mfcc.sh " << array[0], "r+") {|io|
            io.close_write
            lpc = io.read(16*4)
            x = lpc.unpack("f*")
            hash = {}
            for num in 0..15 do
                hash["a" << num.to_s] = x[num]
            end
            train_data.push [array[1], Jubatus::Common::Datum.new(hash)]
        }
    end
end

# training data must be shuffled on online learning!
train_data.sort_by{rand}

client.train(train_data)

