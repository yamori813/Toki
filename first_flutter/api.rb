#
# toki prototype
#

require 'jubatus/classifier/client'

class API < Grape::API
  format :json
  prefix "api"
  version "v1", using: :path

  # jubatus host
  host = "10.0.1.37"
  port = 9199
  name = "mfcc_test"

  # curl http://localhost:3000/api/v1/debug
  get :debug do
     {"debug"=>"hello"}
  end

  # curl http://localhost:3000/api/v1/upload -F sndfile=@T30.aiff
  resource :upload do
    post do
    sndfile = params[:sndfile]
    attachment = {
            :filename => sndfile[:filename],
            :type => sndfile[:type],
            :headers => sndfile[:head],
            :tempfile => sndfile[:tempfile]
        }
    tmpfile = ActionDispatch::Http::UploadedFile.new(attachment)
    File.open("public/snd/test.aiff", 'wb') { |f|
      f.write(tmpfile.read)
    }
    x = []
    system("sox public/snd/test.aiff public/snd/test.raw")
    pos = File.size("public/snd/test.raw") / 2 / 1024 / 2
    IO.popen("x2x +sf public/snd/test.raw | frame -p 1024 -l 1024 | bcut +f -l 1024 -s " << pos.to_s << " -e " << pos.to_s << " | mfcc -l 1024 -f 44.1 -m 16 -n 20 -a 0.97 ", "r+") {|io|
      io.close_write
      lpc = io.read(16*4)
      x = lpc.unpack("f*")
    }
    client = Jubatus::Classifier::Client::Classifier.new(host, port, name)
    hash = {}
    for num in 0..15 do
      hash["a" << num.to_s] = x[num]
    end
    results = client.classify [Jubatus::Common::Datum.new(hash)]
p results[0].max_by{ |x| x.score }.label
    {"result"=>results[0].max_by{ |x| x.score }.label }
    end
  end
end
