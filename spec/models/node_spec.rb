describe Node do
  context 'validations' do
    it { should validate_presence_of :osm_node_id }
    it { should validate_presence_of :crime_rating }
    it { should validate_presence_of :lat }
    it { should validate_presence_of :lon }
  end

  context 'associations' do
    it { should have_many :waypoints }
  end

  context 'external methods' do
    it "should return the closest node to input" do
      node1_args = {  osm_node_id: 1, crime_rating: 1,
                      lat: 37.25, lon: -122.25, intersection: true }

      node2_args = {  osm_node_id: 2, crime_rating: 1,
                      lat: 38.00, lon: -123.00, intersection: true }

      node3_args = {  osm_node_id: 3, crime_rating: 1,
                      lat: 37.00, lon: -122.00, intersection: false }

      args = { coords: { "lat" => 37.00, "lon" => -122.00 } }

      node1 = Node.create(node1_args)
      node2 = Node.create(node2_args)
      node3 = Node.create(node3_args)
      closest_node = Node.closest_node(args)

      expect{ closest_node }.to equal(node1)
    end
  end
end