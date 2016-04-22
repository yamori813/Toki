#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

HOST = "127.0.0.1"
PORT = 9199
NAME = "mfcc_test"
FRAMES = 8

require 'json'
require 'jubatus/clustering/client'

  path = ARGV[0]

  clustering = Jubatus::Clustering::Client::Clustering.new(HOST, PORT, NAME)
  datum = []
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
            mfcc["file"] = fname
            datum << Jubatus::Common::Datum.new(mfcc)
         }
  }
  clustering.push(datum);

  sleep(5)

  centers = clustering.get_core_members()

  for var in datum do
         clus = clustering.get_nearest_center(var)
         p var.string_values[0][1] << " " << clus.string_values[0][1]
  end

