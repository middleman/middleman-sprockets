# encoding: utf-8

RSpec.describe AssetList do
  context '#add' do
    it 'adds an asset to the list' do
      asset = instance_double 'Middleman::Sprockets::Asset'
      list  = AssetList.new

      expect {
        list << asset
      }.not_to raise_error
    end
  end
  context '#lookup' do
    it 'finds an asset in list' do
      asset = instance_double 'Middleman::Sprockets::Asset'
      expect(asset).to receive(:source_path).and_return 'path/to/source'
      expect(asset).to receive(:match?).and_return true

      list  = AssetList.new
      list << asset

      expect(list.lookup(asset)).to be asset
    end

    it 'supports a block which gets the found asset passed' do
      asset = instance_double 'Middleman::Sprockets::Asset'
      allow(asset).to receive(:source_path).and_return 'path/to/source'
      expect(asset).to receive(:destination_path=).with 'path/to/source'
      expect(asset).to receive(:match?).and_return true

      list  = AssetList.new
      list << asset

      list.lookup(asset) { |candidate, found_asset| found_asset.destination_path = found_asset.source_path }
    end
  end
end
