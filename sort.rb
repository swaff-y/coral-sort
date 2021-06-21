#!/usr/bin/ruby
require 'json'
file = ARGV[0]

#match the correct line types
def get_lines file
  arr = []
  File.foreach(file,:encoding => 'utf-8') do |line|
    # regex match the type 'login'
    if line.match(/"type":"login"/) || line.match(/"type": "login"/)
      # remove the line break '/n' at end of line and great array on spaces
      line2 = line.chomp.split(" ")
      # Check if the line includes 'CH2O'
      if line.include?("CH2O")
        #On the line CH2O there are two types of login events
        #incoming and outgoing, They both present their data differently
        #so we need to test these two lines seperatly to create the array we are going
        #to use to sort the data
        if line.include?("incoming")
          line_nine = JSON.parse(line2[9])
          # arr.push line_nine["context"].tr('Rbuggy:','') + " " + line2[1].tr(':','') + " incoming"
          arr.push line_nine["context"].tr('Rbuggy:','') + " " + line2[1].tr(':','')
        elsif line.include?("outgoing")
          # arr.push line2[1].tr(':','') + " " + line2[12].tr('","sequence":','').tr('Rbggy','') + " outgoing"
          arr.push line2[12].tr('","sequence":','').tr('Rbggy','') + " " + line2[1].tr(':','')
        end
      end
    end
  end
  # puts arr
  arr
end

#sort the line types to make sure we are comparing the correct data
def sort_lines get_lines
  arr = []
  #sort the lines and go through each item to create a sorted array
  #with nested arrays to assist with the calculation
  get_lines.sort.each do |line|
    line = line.split(" ")
    arr.push line
  end
  # puts arr
  arr
end

#Calculate the differences between outgoing and incoming events
def calc_lines sort_arr
  #iterators and value stores
  i = 0
  sum = 0
  added = 0

  #Go through each item
  sort_arr.each do |line|
    #Test for the end of the array
    if sort_arr[i+1]
      #compare the ID from this line item to the next line item
      #if they match, increment the matches count 'sum'
      #then subtract the second line form the first to get a difference
      #and add it to the diff total
      if sort_arr[i+1][0] ==  line[0]
        sum += 1
        added += sort_arr[i+1][1].to_f - line[1].to_f
      end
    end

    i += 1
  end
  puts "sum: " + sum.to_s
  puts "added: " + added.to_s
  # divide the added total by the sum "matches count" to get the average respone time
  calc = added.to_f / sum.to_f
end

if File.exists?(file) == true

  # puts get_lines(file)

  sort_arr = sort_lines(get_lines(file))

  puts "average time: " +  calc_lines(sort_arr).to_s

elsif
  puts "File does not exist"
end
