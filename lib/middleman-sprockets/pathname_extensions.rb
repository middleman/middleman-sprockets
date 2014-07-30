# encoding: utf-8
class Pathname
  def start_with?(*paths)
    to_s.start_with?(*paths)
  end

  def end_with?(*paths)
    to_s.end_with?(*paths)
  end
end
