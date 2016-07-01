class Lyric
  attr_accessor :labels, :text
  attr_reader :date

  def initialize(date = nil)
    @date = date ? date : Time.now
    @labels = []
  end
end
