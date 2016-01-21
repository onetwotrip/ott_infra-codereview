require 'ottinfra/codereview/version'
require 'ottinfra/sendmail'
require 'git'

module OttInfra
  class CodeReview

    def initialize
      @g = Git.open( find_git_root )
    end

    def self.run
      codereview = self.new
      review = codereview.get_review_info
      unless review[:reviewers].nil?
        OttInfra::SendMail.new.send(
          review[:reviewers],
          subject: "CodeReview",
          message: "Message",
          attach: [review[:patch]] )
      end
    end

    def get_review_info
      {
        :author => get_author,
        :reviewers => get_reviewers,
        :patch => get_patch
      }
    end

    private

    def find_git_root( path = Dir.pwd )
      path = File.expand_path( path )
      # Base Cases
      return nil if path == "/"
      return path if File.exist?( File.join(path,'.git') )
      # Recurse
      return find_git_root( File.dirname(path) )
    end

    def get_last_changes
      @g.log.first.diff_parent.stats[:files].keys
    end

    def get_file_attrs( file )
      result = Hash[
        @g.lib.checkattr(file).split("\n").map{ |i| i.split(': ')[1,2] }
      ]
      result.each { |attr, val| result[attr] = val.split(',') }
    end

    def get_reviewers
      reviewers = []
      get_last_changes.each do |file|
        reviewer = get_file_attrs( file )["owner.mail"]
        reviewers += reviewer
      end
      reviewers.uniq
    end

    def get_author
      { :name => @g.log.first.author.name,
        :email => @g.log.first.author.email}
    end

    def get_patch
      patch_path = "/tmp/#{@g.log.first.objectish}.patch"
      diff = @g.lib.diff_full( @g.log.first.parent, @g.log.first )
      File.open(patch_path, 'w') { |file| file.write(diff) }
      patch_path
    end

  end
end
