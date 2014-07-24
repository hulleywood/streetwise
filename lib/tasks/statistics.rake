namespace :statistics do
  desc 'Find max, min, avg crime and distance'
  task node_crime_distance_stats: :environment do

    rels = Graph.all_relationships
    rel_stats = rels.map do |rel|
      distance = Graph.distance_from_relationship(rel)

      { crime_rating: rel['data']['crime_rating'],
        distance: distance }
    end

    avg_distance = prop_avg(rel_stats, :distance)
    avg_crime_rating = prop_avg(rel_stats, :crime_rating)
    median_distance = prop_median(rel_stats, :distance)
    median_crime_rating = prop_median(rel_stats, :crime_rating)

    summary = {
      avg_distance: avg_distance,
      avg_crime_rating: avg_crime_rating,
      median_distance: median_distance,
      median_crime_rating: median_crime_rating,
      max_distance: rel_stats.max_by {|r| r[:distance] },
      max_crime_rating: rel_stats.max_by {|r| r[:crime_rating] },
      min_distance: rel_stats.min_by {|r| r[:crime_rating] },
      min_crime_rating: rel_stats.min_by {|r| r[:crime_rating] }
    }

    puts summary
  end

  desc 'Write crime and distance stats to file'
  task print_crime_distance_stats: :environment do

    rels = Graph.all_relationships
    rel_stats = rels.map do |rel|
      distance = Graph.distance_from_relationship(rel)

      [ rel['data']['crime_rating'], distance ]
    end

    Dir.chdir('./lib/assets')
    file = File.join( Dir.pwd, '/node_data.csv')
    headers = ['crime_rating', 'distance']

    CSV.open(file, 'w+') do |csv|
      csv << headers
      rel_stats.each { |rel| csv << rel }
    end

  end

  desc 'Calculate crime and distance distribution'
  task calc_distributions: :environment do

    rels = Graph.all_relationships
    rel_stats = rels.map do |rel|
      distance = Graph.distance_from_relationship(rel)

      { crime_rating: rel['data']['crime_rating'],
        distance: distance }
    end

    crime_freq = create_freq(rel_stats, :crime_rating)
    distance_freq = create_freq(rel_stats, :distance)

    dist = crime_freq.zip(distance_freq)

    Dir.chdir('./lib/assets')
    file = File.join( Dir.pwd, '/node_data.csv')
    headers = ['crime_rating', 'distance']

    CSV.open(file, 'w+') do |csv|
      csv << headers
      dist.each { |d| csv << d }
    end
  end
end

def prop_avg(data, prop)
  arr = []
  data.each {|r| arr << r[prop] }
  arr.reduce(:+)/data.length
end

def prop_median(data, prop)
  arr = []
  data.each {|r| arr << r[prop] }
  arr.sort[data.length/2]
end

def create_freq(data, prop, steps = 40)
  prop_data = []
  data.each {|r| prop_data << r[prop] }

  min = prop_data.min
  max = prop_data.max
  step_size = (max - min)/(steps - 1)

  freq = []

  (steps - 1).times do |i|
    freq << get_number(prop_data, i+1, step_size, min)
  end

  freq
end

def get_number(data, i, step_size, min)
  min = min + step_size * (i - 1)
  max = min + step_size * i
  pts = data.select { |n| n > min && n <= max }
  pts.count
end