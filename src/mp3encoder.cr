@[Link(ldflags: "-L#{__DIR__}/../lib -llibmp3encoder")]
lib Native
  fun hello = hello : Void
end

class MP3Encoder
  def initiliaze

  end

  def hello
    Native.hello()
  end
end
