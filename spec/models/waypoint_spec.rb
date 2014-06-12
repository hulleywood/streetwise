describe Waypoint do
  context 'validations' do
    it { should validate_presence_of :osm_node_id }
  end

  context 'associations' do
    it { should belong_to :node }
  end
end