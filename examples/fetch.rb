#!/bin/env ruby
#
require 'amazon_associate_report'

p email = ENV["AMAZON_USERNAME"]
p password = ENV["AMAZON_PASSWORD"]
from = to = Time.parse("2012/11/25 00:00:00 UTC")

AmazonAssociateReport.logger = Logger.new(STDERR)

f = AmazonAssociateReport::Fetcher.new(email, password)
parser = AmazonAssociateReport::Parser.new

#data = f.fetch_orders_xml("oh-my-zsh-22", from, to)
data = f.fetch_orders_xml("alfalfalafa-22", from, to)
p parser.parse_orders_xml(data)

data = f.fetch_sales_xml("alfalfalafa-22", from, to)
#data = f.fetch_sales_xml("oh-my-zsh-22", from, to)
p parser.parse_sales_xml(data)

