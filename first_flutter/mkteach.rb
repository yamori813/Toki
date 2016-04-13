inpath = ARGV[0]
outpath = ARGV[1]

count = 0
Dir::glob( inpath + "/*" ).each {|fname|
  if(system("sox " << fname << " temp.raw >/dev/null 2>&1"))
    IO.popen("./dmpzero.sh" , "r+") {|io|
      io.close_write
      arr = []
      while(str=io.gets)
        str.chomp!
        val = str.split("\t")
        arr.push(val[1].to_i)
      end
      num = 5
      while(num < arr.length - 5) 
          if arr[num] > 10 && arr[num - 1] * 1.2 < arr[num] && arr[num] > arr[num + 1] * 1.2 then
          pos = (num * 0.05 - 0.2).round(2)
          system("sox " << fname << " " << outpath << "/T" << "%04d" % [count] << ".aiff trim " << pos.to_s << " 0.4")
          count = count + 1
          num = num + 10
        else
          num = num + 1
        end
      end
    }
  end
}
