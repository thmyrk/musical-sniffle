class String
  def to_filename
    downcase.tr(' ', '_')
  end

  def to_songname
    split('_').map(&:capitalize).join(' ')
  end
end
