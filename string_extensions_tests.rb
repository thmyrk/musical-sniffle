require_relative 'string_extensions'
require 'test/unit'

class TestStringExtensions < Test::Unit::TestCase
  def test_to_filename
    assert_equal '3aGf6 aS34 Bv'.to_filename, '3agf6_as34_bv'
    assert_equal 'A Song Name'.to_filename, 'a_song_name'
  end

  def test_to_songname
    assert_equal 'a_filename'.to_songname, 'A Filename'
    assert_equal '3agf6_as34_bv'.to_songname, '3agf6 As34 Bv'
  end
end
