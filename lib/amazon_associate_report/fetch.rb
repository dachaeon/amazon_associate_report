#!/bin/env ruby
# encoding: utf-8
# Author: kimoto
require 'mechanize'
require 'nokogiri'
require 'time'
require 'logger'

module AmazonAssociateReport
  class AmazonAssociateReportError < StandardError; end
  class LoginError < StandardError; end

  class Fetcher
    LOGIN_URL = 'https://affiliate-program.amazon.com/gp/associates/login/login.html'
    TOP_URL = 'https://affiliate-program.amazon.com/gp/associates/network/reports/main.html'
    BLACK_CURT = "BLACK-CURT"
    class UnknownTrackingId < StandardError; end

    @@logger = Logger.new(nil)
    def self.logger=(logger)
      @@logger = logger
    end

    def initialize(email, password)
      @agent = Mechanize.new{ |agent|
        agent.user_agent_alias = 'Windows IE 7'
      }
      login(email, password)
    end

    def fetch_xml(tracking_code, from, to, options={})
      go_top
      choose_tracking(tracking_code)
      report(from, to, options)
    end

    def fetch_orders_xml(tracking_code, from, to)
      fetch_xml(tracking_code, from, to, :report_type => 'ordersReport')
    end

    def fetch_sales_xml(tracking_code, from, to)
      fetch_xml(tracking_code, from, to, :report_type => 'salesReport')
    end

    private
    def login(email, password, url = LOGIN_URL)
      if email.nil? or password.nil?
        raise ArgumentError.new
      end
      @agent.get(url)
      @agent.page.form_with(:name => 'sign-in') {|f|
        f.field_with(:name => 'email').value = email
        f.field_with(:name => 'password').value = password
        f.click_button
      }
    end

    def go_top
      @agent.get TOP_URL
    end

    def choose_tracking(tracking_id)
      @tracking_id = tracking_id
      @agent.page.link_with(:href => /trendsReport/).click()
      @agent.page.form_with(:name => 'idbox_tracking_id_form'){ |f|
        f.field_with(:name => 'idbox_tracking_id').value = tracking_id
        f.submit()
      }

      registered_tracking_ids = begin
                                  Nokogiri::HTML(@agent.page.body).search("select[name = 'idbox_tracking_id']").first.search("option").map(&:text)
                                rescue
                                  []
                                end

      unless registered_tracking_ids.include? tracking_id
        raise UnknownTrackingId
      end
    end

    # :period_type => :exact
    def report(from, to, options = {})
      options = {
        :period_type => :exact,
        :report_type => 'earningsReport',
        :format => :xml
      }.merge(options)

      @agent.page.form_with(:name => 'htmlReport'){ |f|
        f['program'] = 'all'
        f['tag'] = @tracking_id

        if options[:period_type] == :exact
          f.radiobutton_with(:value => 'exact').check
          f['startYear'] = from.year
          f['startMonth'] = from.month - 1
          f['startDay'] = from.day
          f['endYear'] = to.year
          f['endMonth'] = to.month - 1
          f['endDay'] = to.day
        else
          f.radiobutton_with(:value => 'preSelected').check

          # 昨日分抽出するやつ
          f['preSelectedPeriod'] = 'yesterday'
          f['periodType'] = 'preSelected'
        end

        f['reportType'] = options[:report_type]

        if options[:format] == :xml
          f.click_button(f.button_with(:name => 'submit.download_XML'))
        elsif options[:format] == :csv
          f.click_button(f.button_with(:name => 'submit.download_CSV'))
        else
          f.click_button(f.button_with(:name => 'submit.display'))
        end
      }
      @agent.page.body
    end
  end
end
