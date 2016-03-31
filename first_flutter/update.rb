#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

HOST = "127.0.0.1"
PORT = 9199
NAME = "mfcc_test";

require 'json'
require 'jubatus/recommender/client'

  path = "snd"

  recommender = Jubatus::Recommender::Client::Recommender.new(HOST, PORT, NAME)
  Dir::glob( path + "/*" ).each {|fname|
         IO.popen("./mfcc.sh " << fname, "r+") {|io|
            io.close_write
            lpc = io.read(16*4)
            x = lpc.unpack("f*")
            parameters = {}
            for num in 0..15 do
              parameters["a" << num.to_s] = x[num]
            end
            datum = Jubatus::Common::Datum.new(parameters)
            recommender.update_row(fname, datum)
         }
  }

