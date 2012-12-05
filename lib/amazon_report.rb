require "amazon_report/version"
require 'amazon_report/fetch'
require 'amazon_report/parser'

module AmazonReport
  def self.logger=(logger)
    Fetcher.logger = logger
    Parser.logger = logger
  end
end
