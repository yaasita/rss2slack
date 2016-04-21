#!/usr/bin/env ruby
# coding: utf-8
#############################################
urls=[
  "https://www.w3.org/blog/feed",
]
token = ENV["TOKEN"] || (print "Token: "; gets.strip)
#############################################

require 'rss'
require 'active_record'
require 'nokogiri'
require 'slack'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
unless ActiveRecord::Base.connection.table_exists? :rsssites
  ActiveRecord::Migration.create_table :rsssites do |t|
    t.string :url, :null => false
    t.string :last_get_date, :null => false
    t.timestamps
  end
end
class Rsssites < ActiveRecord::Base
end

urls.each do |url|
  if Rsssites.find_by_url(url).nil?
    db = Rsssites.new
    db.url = url
    db.last_get_date = "2000-01-01 00:00:00 +0900"
  else
    db = Rsssites.find_by_url(url)
  end
  rss = RSS::Parser.parse(url)
  rss.items.each do |item|
    if !defined?(item.pubDate) or item.pubDate.nil?
      class << item
        def pubDate
          dc_date
        end
      end
    end
  end
  rss.items.sort{|a,b|a.pubDate <=> b.pubDate}.each do |item|
    if item.pubDate <= Time.parse(db.last_get_date)
      next
    else
      db.last_get_date = item.pubDate.to_s
    end
    client = Slack::Client.new token: token
    client.chat_postMessage(channel: "hoge", text: "#{item.link}}", as_user: true)
  end
  db.save
end
