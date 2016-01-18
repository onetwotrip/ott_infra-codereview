require 'optimism'
require "sendgrid-ruby"

module OttInfra
  class SendMail
    attr_accessor :config

    def initialize
      @config = Optimism.require_env(/(SENDGRID_.*)/, split: '_')
    end

    def send(email, opts = {})
      opts[:subject] ||= "Subject"
      opts[:message] ||= "Message"
      mail = SendGrid::Mail.new do |m|
        m.to = email
        m.from = @config.sendgrid.from
        m.subject = opts[:subject]
        m.html = opts[:message]
      end
      opts[:attach].each do |path|
        mail.add_attachment(path)
      end
      SendGrid::Client.new(sendmail_options).send mail
    end

    def valid?
      unless @config.sendgrid.from.class.eql? String
        puts "SENDGRID_FROM is not defined"
        return false
      end
      unless @config.sendgrid.user.class.eql? String
        puts "SENDGRID_USER is not defined"
        return false
      end
      unless @config.sendgrid.pass.class.eql? String
        puts "SENDGRID_PASS is not defined"
        return false
      end
      true
    end

    private

    def sendmail_options
      { api_user: @config.sendgrid.user, api_key: @config.sendgrid.pass }
    end
  end
end
