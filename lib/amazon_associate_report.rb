require "amazon_associate_report/version"
require 'amazon_associate_report/fetch'
require 'amazon_associate_report/parser'

module AmazonAssociateReport
  def self.logger=(logger)
    Fetcher.logger = logger
    Parser.logger = logger
  end
end
