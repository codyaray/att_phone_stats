#!/usr/bin/env ruby

require 'rubygems'
require 'ostruct'
require 'csv'
require 'pp'

def new_stats
  stats = OpenStruct.new
  stats.mins = 0
  stats.number_calls  = 0
  stats.incoming_calls = 0
  stats.outgoing_calls = 0
  stats.mins_incoming = 0
  stats.mins_outgoing = 0
  stats.calls_per = OpenStruct.new
  stats.calls_per.mon = 0
  stats.calls_per.tue = 0
  stats.calls_per.wed = 0
  stats.calls_per.thu = 0
  stats.calls_per.fri = 0
  stats.calls_per.sat = 0
  stats.calls_per.sun = 0
  # stats.dates = {}
  stats
end

if ARGV.length < 1
  puts "Please enter the filename of the phone bill (in .csv format) to analyze."
  exit
else
  filename = ARGV[0]
end

total_stats = new_stats

caller_stats = {}
reader = CSV.open(filename, 'r', nil, ?\r)
header = reader.shift
reader.each do |row|
  item              = row[0].to_i
  day               = row[1]
  date              = row[2].strip
  time              = row[3]
  number_called     = row[4]
  call_to           = row[5]
  min               = row[6].to_i
  rate_code         = row[7]
  rate_pd           = row[8]
  feature           = row[9]
  airtime_charge    = row[10].to_i
  ld_or_addl_charge = row[11].to_i
  total_charge      = row[12].to_i
  
  total_stats.mins += min
  total_stats.number_calls += 1
  if call_to == 'INCOMING CL'
    total_stats.incoming_calls += 1
    total_stats.mins_incoming += min 
  else
    total_stats.outgoing_calls += 1
    total_stats.mins_outgoing += min 
  end
  
  puts item if number_called == nil
  
  if caller_stats.has_key? number_called
    record = caller_stats[number_called]
    record.mins += min
    record.number_calls += 1
    
    if call_to == 'INCOMING CL'
      record.incoming_calls += 1
      record.mins_incoming += min 
    else
      record.outgoing_calls += 1
      record.mins_outgoing += min 
    end
    
    # if record.dates.has_key? date
    #   record.dates[date] += 1
    # else
    #   record.dates[date] = 1
    # end
  else
    record = OpenStruct.new
    record.mins = min
    record.number_calls = 1
    if call_to == 'INCOMING CL'
      record.incoming_calls = 1
      record.outgoing_calls = 0
      record.mins_incoming  = min
      record.mins_outgoing  = 0
    else
      record.incoming_calls = 0
      record.outgoing_calls = 1
      record.mins_incoming  = 0
      record.mins_outgoing  = min
    end
    # record.dates = {}
    # record.dates[date] = 1
    caller_stats[number_called] = record
  end
end

# pp caller_stats
# pp total_stats

src = []
src << ["Number Called", "Total Number Calls", "Total Mins", "Number Incoming Calls", "Number Outgoing Calls", "Incoming Mins", "Outgoing Mins"]
caller_stats.each { |r| src << [r[0], r[1].number_calls, r[1].mins, r[1].incoming_calls, r[1].outgoing_calls, r[1].mins_incoming, r[1].mins_outgoing] }

buf = ''
src.each { |row| CSV.generate_row(row, 7, buf) }

puts buf