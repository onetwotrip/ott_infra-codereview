require 'ott_infra/codereview/version'
require 'ott_infra/git'

module OttInfra
  module CodeReview
    def self.run
    end

    def self.get_last_changes
      @@g.log.first.diff_parent.stats[:files].keys
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
      @@g.lib.checkattr( file ).split("\n").each do |record|
        value,attr = record.split(': ').reverse
        result.push(value) if (opts[:attr].eql? attr or opts[:attr].nil? )
      end
      result
    end

    def self.get_reviewers
      reviewers = []
      get_last_changes.each do |file|
        reviewer = get_file_attrs( file, :attr => 'owner.mail' )
        reviewers.push( reviewer ) unless reviewers.include? reviewer
      end
      reviewers
    end

    def self.get_diff
      @@g.lib.diff_full( @@g.log.first.parent, @@g.log.first )
    end

    # Module variables
    @@g = Git.open( find_git_root )
  end
end
