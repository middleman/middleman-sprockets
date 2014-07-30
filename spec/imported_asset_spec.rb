# encoding: utf-8
RSpec.describe ImportedAsset do
  context '#output_path' do
    it 'uses block as second argument on initialize to get path' do
      asset = ImportedAsset.new 'source/to/asset/image.png', proc { 'hello/world.png' }

      expect(asset.output_path.to_s).to eq 'hello/world.png'
    end
  end

  context '#resolve_path_with' do
    it 'resolves path' do
      in_current_dir do
        relative_path = 'source/path/to/image.xz'
        file_path = File.expand_path(relative_path)

        resolver = double('Environment')
        expect(resolver).to receive(:resolve).with(Pathname.new(relative_path)).and_return file_path 

        asset = ImportedAsset.new relative_path
        asset.resolve_path_with resolver
      end
    end

    it 'raises an error if path could not be resolved' do
      in_current_dir do
        relative_path = 'source/path/to/image.xz'

        resolver = double('Environment')
        allow(resolver).to receive(:resolve).with(Pathname.new(relative_path)).and_return nil

        asset = ImportedAsset.new relative_path

        expect {
          asset.resolve_path_with resolver
        }.to raise_error ::Sprockets::FileNotFound
      end
    end
  end

  context '#match?' do
    it 'succeeds if real path matches' do
      in_current_dir do
        relative_path = 'source/path/to/image.xz'
        file_path = File.expand_path(relative_path)

        resolver = double('Environment')
        allow(resolver).to receive(:resolve).and_return file_path

        asset = ImportedAsset.new relative_path
        asset.resolve_path_with resolver

        expect(asset).to be_match file_path
      end
    end

    it 'fails if does not match' do
      in_current_dir do
        relative_path = 'source/path/to/image.xz'
        file_path = File.expand_path(relative_path)

        resolver = double('Environment')
        allow(resolver).to receive(:resolve).and_return file_path + 'fail'

        asset = ImportedAsset.new relative_path
        asset.resolve_path_with resolver

        expect(asset).not_to be_match file_path
      end
    end
  end
end
