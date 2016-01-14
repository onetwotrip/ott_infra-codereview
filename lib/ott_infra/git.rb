require 'git'

class Git::Lib
  def checkattr ( file )
    command( 'check-attr', ['-a', file] )
  end
end
