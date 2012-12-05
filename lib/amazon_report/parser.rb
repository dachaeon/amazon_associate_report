#!/bin/env ruby
# encoding: utf-8
# Author: kimoto

module AmazonReport
  class Parser
    class BlackCartError < StandardError; end

    @@logger = Logger.new(nil)
    def self.logger=(logger)
      @@logger = logger
    end

    def parse_sales_xml(xml_string)
      hash = {}
      doc = Nokogiri::XML(xml_string)
      doc.search("Items > Item").each{ |item|
        asin = item.attributes["ASIN"].value
        revenue = item.attributes["Revenue"].value
        qty = item.attributes["Qty"].value
        earnings = item.attributes["Earnings"].value
        date = Time.parse(item.attributes["Date"].value)
        hash[asin] = {
          :revenue => revenue,
          :qty => qty,
          :earnings => earnings,
        }
      }
      hash
    end

    def parse_orders_xml(xml_string)
      hash = {}
      doc = Nokogiri::XML(xml_string)
      doc.search("Items > Item").each{ |item|
        asin = item.attributes["ASIN"].value
        nqty = item.attributes["NQty"].value # その他注文された商品
        dqty = item.attributes["DQty"].value # 注文数合計
        qty = item.attributes["Qty"].value # 直接リンクによる注文数
        clicks = item.attributes["Clicks"].value # クリック数
        date = Time.parse(item.attributes["Date"].value) # 日付
        tag = item.attributes["Tag"].value
        hash[asin] = {
          :nqty => nqty,
          :dqty => dqty,
          :qty => qty,
          :clicks => clicks,
        }
      }
      doc.search("ItemsNoOrders > Item").each{ |item|
        asin = item.attributes["ASIN"].value
        clicks = item.attributes["Clicks"].value
        hash[asin] = {
          :nqty => "0",
          :dqty => "0",
          :qty => "0",
          :clicks => clicks
        }
      }
      hash
    end

    def to_number(string)
      string.gsub(/,/, "").to_i
    end
  end
end
