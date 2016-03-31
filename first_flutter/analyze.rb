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
         sr = recommender.similar_row_from_id(fname, 4)
         puts("player #{fname} is similar to : #{sr[1].id} #{sr[1].score} #{sr[2].id} #{sr[3].id}")
  }

