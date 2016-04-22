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
              for frame in 0..FRAMES-1 do
                mfcc["a" << frame.to_s << num.to_s] = x[num + frame * 16 * 3]
              end
            end
            datum = Jubatus::Common::Datum.new(mfcc)
            recommender.update_row(fname, datum)
         }
  }

