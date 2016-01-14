require 'ott_infra/codereview/version'
require 'ott_infra/git'

module OttInfra
  module CodeReview
    def self.run
      get_last_changes.each do |file|
        get_file_attrs( file, :attr => 'owner.mail' )
      end
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

    def self.get_file_attrs( file, opts = {} )
      result = []
      Git::Lib.new.checkattr( file ).split("\n").each do |record|
        value,attr = record.split(': ').reverse
        result.push(value) if (opts[:attr].eql? attr or opts[:attr].nil? )
      end
      result
    end
  end
end
