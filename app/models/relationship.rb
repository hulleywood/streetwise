class Relationship < ActiveRecord::Base
  belongs_to :node
  belongs_to :start_node, class_name: 'Node'
  belongs_to :end_node, class_name: 'Node'

  def self.create_from_csv_args(args)
    start_node = Node.find_by_osm_node_id(args["osm_start_id"])
    end_node = Node.find_by_osm_node_id(args["osm_end_id"])
    args.delete('osm_start_id')
    args.delete('osm_end_id')

    rel = self.create(args)
    rel.start_node = start_node if start_node
    rel.end_node = end_node if end_node
    start_node.relationships << rel
    end_node.relationships << rel

    start_node.save
    end_node.save
    rel.save
  end

  def self.create_neighbors(node, wpt)
    make_neighbor_relationship(node, wpt.previous_node) if wpt.previous_node
    make_neighbor_relationship(node, wpt.next_node) if wpt.next_node
  end

  def self.make_neighbor_relationship(node, neighbor)
    unless relationship_exists(node, neighbor)
      rel = self.new(start_node: node, end_node: neighbor)
      rel.intersectional = node.intersection? && neighbor.intersection?
      rel.populate_distance
      rel.populate_crime_rating
      rel.populate_gradient
      rel.save
    end
  end

  def normalize_relationship_properties
    self.normalize_distance
    self.normalize_crime_rating
    self.normalize_gradient
  end

  def self.relationship_exists(n1, n2)
    rel = Relationship.where(start_node: n1, end_node: n2).limit(1)
    rel = Relationship.where(start_node: n2, end_node: n1).limit(1) if rel.empty?
    rel.present?
  end

  def populate_distance
    self.distance = calc_node_distance
  end

  def normalize_distance
    self.n_distance = ENV['distance_coefficient'] * self.distance
  end

  def populate_crime_rating
    self.crime_rating = calc_crime_rating
  end

  def normalize_crime_rating
    self.n_crime_rating = ENV['crime_rating_coefficient'] * self.crime_rating
  end

  def populate_gradient
    self.gradient = calc_node_gradient
  end

  def normalize_gradient
    self.n_grad_out = ( ENV['gradient_coefficient'] * self.gradient ).abs
    self.n_grad_in = self.n_grad_out
    self.nw_grad_out = self.gradient < 0 ? (self.n_grad_out * 0.5) : self.n_grad_out
    self.nw_grad_in = self.gradient < 0 ? self.n_grad_out : (self.n_grad_out * 0.5)
  end

  def set_relationship_wieghts
    self.weight_attributes.each do |attr|
      self.send("#{attr}=".to_sym, self.calc_weight_from_attribute_name(attr))
    end
  end

  def calc_node_distance
    conv_node1 = { 'lat' => self.start_node.lat, 'lon' => start_node.lon }
    conv_node2 = { 'lat' => self.end_node.lat, 'lon' => end_node.lon }
    Node.point_distance_hvs(conv_node1, conv_node2)
  end

  def calc_crime_rating
    (self.start_node.crime_rating + self.end_node.crime_rating)/2
  end

  def calc_node_gradient
    rise = self.start_node.elevation - self.end_node.elevation
    run = self.distance
    slope = rise/run
    gradient = (slope**2)*run
  end

  def calc_weight_from_attribute_name(attr)
    attr1 = self.attr_from_char(/^w_(.{1})/.match(attr), /^w_.{5}(.{1})/.match(attr))
    attr1_weight = /^w_.{1}(.{1})/.match(attr)
    attr2 = self.attr_from_char(/^w_.{2}(.{1})/.match(attr), /^w_.{5}(.{1})/.match(attr))
    attr2_weight = /^w_.{3}(.{1})/.match(attr)

    weight = self.send(attr1.to_sym) * attr1_weight + self.send(attr2.to_sym) * attr2_weight
    weight/(attr1_weight + attr2_weight)
  end

  def weight_attributes
    attributes = self.attributes.keys
    attribures.select {|attr| !!(attr =~ /^w_.*/)}
  end

  def attr_from_char(char, direction)
    case char
    when 'c'
      'n_crime_rating'
    when 'd'
      'n_dist'
    when 'g'
      if direction == 'o'
        'nw_grad_out'
      else
        'nw_grad_in'
      end
    end
  end
end
