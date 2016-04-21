inpath = ARGV[0]
outpath = ARGV[1]

interval = 0.8

count = 0
Dir::glob( inpath + "/*" ).each {|fname|
  if(system("sox " << fname << " temp.raw >/dev/null 2>&1"))
    IO.popen("./pitch.sh" , "r+") {|io|
      io.close_write
      arr = []
      while(str=io.gets)
        str.chomp!
        val = str.split(" ")
        arr.push(val)
      end
      time = arr[1][0].to_f - arr[0][0].to_f
      num = (0.2 / time).to_i
      while(num < arr.length - (0.2 / time).to_i) 
        if arr[num][1].to_f != 0
          pos = arr[num][0].to_f.round(2) - 0.2
          system("sox " << fname << " " << outpath << "/S" << "%04d" % [count] << ".aiff trim " << pos.to_s << " 0.4")
          puts fname + ",S%04d.aiff" % [count] + ",%.2f" % pos
          count = count + 1
          num = num + interval / time
        else
          num = num + 1
        end
      end
    }
  end
}
