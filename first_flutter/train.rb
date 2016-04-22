#!/usr/bin/env ruby

host = "127.0.0.1"
port = 9199
name = "mfcc_test"
FRAMES = 8

require 'jubatus/classifier/client'

client = Jubatus::Classifier::Client::Classifier.new(host, port, name)

train_data = []

listfile = ""

if ARGV[0] != nil
  listfile = ARGV[0]
else
  listfile = "list.csv"
end

open(listfile) do |file|
    while l = file.gets
        array = l.chomp.split(",")
        if array[1] != nil
p array[1]
        IO.popen("./delta.sh " << FRAMES.to_s << " " << array[0], "r+") {|io|
            io.close_write
            lpc = io.read(16*4*FRAMES*3)
            x = lpc.unpack("f*")
            mfcc = {}
            for num in 0..15 do
              for frame in 0..FRAMES-1 do
                mfcc["a" << frame.to_s << num.to_s] = x[num + frame * 16 * 3]
              end
            end
            train_data.push [array[1], Jubatus::Common::Datum.new(mfcc)]
        }
        end
    end
end

# training data must be shuffled on online learning!
train_data.sort_by{rand}

client.train(train_data)
