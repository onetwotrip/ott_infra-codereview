require 'ott_infra/codereview/version'
require 'git'

module OttInfra
  module CodeReview
    def self.run
      get_last_changes
      true
    end

    def self.get_last_changes
      g = Git.open( find_git_root )
      g.log.first.diff_parent.stats[:files].keys
    end

    def self.find_git_root( path = Dir.pwd )
      path = File.expand_path( path )
      # Base Cases
      return nil if path == "/"
      return path if File.exist?( File.join(path,'.git') )
      # Recurse
      return find_git_root( File.dirname(path) )
    end
  end
end
