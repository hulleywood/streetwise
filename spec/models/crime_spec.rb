describe Crime do
  context 'validations' do
    it { should validate_presence_of :x }
    it { should validate_presence_of :y }
    it { should validate_presence_of :date }
  end

  context 'get_near_crimes method' do
    let(:node) { FactoryGirl.create(:node) }

    it "should not return far crimes" do
      crime = Crime.new({ x: "-123.397446", y: "38.784841", date: "2014-05-31 07:00:00"  })
      expect{ crime.save }.not_to change{ Crime.get_near_crimes(node).count }
    end

    it "should accurately report number of near crimes" do
      crime = Crime.new({ x: "-122.398446", y: "37.784841", date: "2014-05-31 07:00:00" })
      expect{ crime.save }.to change{ Crime.get_near_crimes(node).count }.from(0).to(1)
    end

  end
end