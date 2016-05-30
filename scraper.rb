#!/bin/env ruby
# encoding: utf-8

require 'csv'
require 'nokogiri'
require 'scraperwiki'
require 'pry'
require 'date'

def gender_from(str)
  return if str.to_s.empty?
  return 'male' if str.downcase == 'm'
  return 'female' if str.downcase == 'f'
end

def dob_from(str)
  return if str.to_s.empty?
  return if str.strip.downcase.include? 'non fourni'
  Date.parse(str).to_s rescue binding.pry
end

@terms = %w(1992 1997 2002 2007 2012 2014 2015)

def reprocess_csv(file)
  raw = open(file).read
  csv = CSV.parse(raw)
  headers = csv.shift
  csv.each do |row|
    given_name  = row[3].to_s.strip 
    next if given_name.empty?

    family_name = row[2].strip.upcase
    term = @terms.find_index(row[0]) or raise "Invalid term: #{row[0]}"

    data = { 
      name: "#{given_name} #{family_name}",
      given_name: given_name,
      family_name: family_name,
      sort_name: "#{family_name}, #{given_name}",
      gender: gender_from(row[4]),
      birth_date: dob_from(row[5]),
      party: row[9].to_s.strip,
      term: term + 1
    }
    ScraperWiki.save_sqlite([:name, :party, :term], data)
  end
end

csv_data = reprocess_csv('https://docs.google.com/spreadsheets/d/11U-Anvno77e7Uu8e4c4jgkTLXJ5JbzoAZqZVhRN1HMg/export?format=csv&gid=1745431985')
