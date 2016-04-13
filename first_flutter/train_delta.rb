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
        IO.popen("./delta.sh " << FRAMES.to_s << " " << array[0], "r+") {|io|
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
            train_data.push [array[1], Jubatus::Common::Datum.new(mfcc)]
        }
    end
end

# training data must be shuffled on online learning!
train_data.sort_by{rand}

client.train(train_data)
