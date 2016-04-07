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
        arr.push([val[0],val[1].to_i])
      end
      newarr = arr.sort { |a,b| a[1] <=> b[1] }.reverse
      num = 0
      last = 0
      while num < 2 do
        zero = newarr[num]
        if(zero)
          pos = zero[0].to_f * 2205 / 44100 - 0.2
          if(num == 0 || (last - pos).abs > 1)
          system("sox " << fname << " " << outpath << "/T" << count.to_s << ".aiff trim " << pos.to_s << " 0.4")
            count = count + 1
            last = pos
          end
        end
        num = num + 1
      end
    }
  end
}
