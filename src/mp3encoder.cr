@[Link(ldflags: "-L#{__DIR__}/../ext/lib -lmp3encoder")]
lib Native
  fun hello = hello : Void
  fun start_pcm_to_mp3(mp3_path : LibC::Char*, sample_rate : UInt32) : LibC::Int
  fun write_pcm_to_mp3(pcm : Int16*, frames : UInt32) : LibC::Int
  fun stop_pcm_to_mp3 : Void
end

class MP3Encoder
  def initiliaze

  end

  def start(mp3_path : String, sample_rate : UInt32 = 48000_u32)
    Native.start_pcm_to_mp3(mp3_path, sample_rate)
  end

  def write(pcm : Pointer(Int16), frames : UInt32)
    Native.write_pcm_to_mp3(pcm, frames)
  end

  def stop
    Native.stop_pcm_to_mp3
  end

  def hello
    Native.hello()
  end
end
