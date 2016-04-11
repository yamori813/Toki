#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

HOST = "127.0.0.1"
PORT = 9199
NAME = "mfcc_test";
FRAMES = 8;

require 'json'
require 'jubatus/recommender/client'

  path = ARGV[0]

  recommender = Jubatus::Recommender::Client::Recommender.new(HOST, PORT, NAME)
  Dir::glob( path + "/*" ).each {|fname|
         IO.popen("./delta.sh " << FRAMES.to_s << " " << fname, "r+") {|io|
            io.close_write
            lpc = io.read(16*4*FRAMES*3)
            x = lpc.unpack("f*")
            parameters = {}
            for num in 0..15 do
              sum = 0
              for frame in 0..FRAMES-1 do
                sum = sum + x[num + frame * 16 * 3]
              end
              parameters["a" << num.to_s] = sum / FRAMES
            end
            for num in 0..15 do
              sum = 0
              for frame in 0..FRAMES-2 do
                sum = sum + x[num + 16 + frame * 16 * 3].abs
              end
              parameters["d" << num.to_s] = sum / (FRAMES - 1)
            end
            datum = Jubatus::Common::Datum.new(parameters)
            recommender.update_row(fname, datum)
         }
  }

