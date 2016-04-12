#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

HOST = "127.0.0.1"
PORT = 9199
NAME = "mfcc_test"
FRAMES = 8

require 'json'
require 'jubatus/recommender/client'

  path = ARGV[0]

  recommender = Jubatus::Recommender::Client::Recommender.new(HOST, PORT, NAME)
  Dir::glob( path + "/*" ).each {|fname|
         IO.popen("./delta.sh " << FRAMES.to_s << " " << fname, "r+") {|io|
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
            datum = Jubatus::Common::Datum.new(mfcc)
            recommender.update_row(fname, datum)
         }
  }

