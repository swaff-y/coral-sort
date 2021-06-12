#!/usr/bin/ruby
file = ARGV[0]

def get_lines file
  arr = []
  File.foreach(file) do |line|
    line = line.chomp.split(" ")
    # p line.include? "one"
    if line.include?('"okay",') && line.include?("CH20")
      arr.push line[8].tr('"', '') + " " + line[1]
    end
  end
  arr
end

def sort_lines get_lines
  arr = []
  get_lines.sort.each do |line|
    line = line.split(",")
    arr.push line
  end
  arr
end

def calc_lines sort_arr
  i = 0
  sum = 0
  added = 0
  sort_arr.each do |line|
    if sort_arr[i+1]
      if sort_arr[i+1][0] ==  line[0]
        sum += 1
        added += sort_arr[i+1][1].to_f - line[1].to_f
      end
    end

    i += 1
  end
  calc = added.to_f / sum.to_f
end

if File.exists?(file) == true

  sort_arr = sort_lines(get_lines(file))

  puts "average time: " +  calc_lines(sort_arr).to_s

elsif
  puts "File does not exist"
end
