# encoding: utf-8
RSpec.describe Asset do
  context '#has_type?' do
    it 'finds type by extension' do
      asset = Asset.new('/source/path/to/image.png', source_directory: '/source/path/to')
      expect(asset).to have_type :image
    end

    it 'finds type by path' do
      asset = Asset.new('/source/path/to/images/image.xz', source_directory: '/source/path/to/images')
      expect(asset).to have_type :image
    end

    it 'finds type by double extension' do
      asset = Asset.new('/source/path/to/image.png.xz', source_directory: '/source/path/to')
      expect(asset).to have_type :image
    end

    it 'finds type in an unlimited number of extensions' do
      asset = Asset.new('/source/path/to/image.asdf.png.asdf.xz', source_directory: '/source/path/to')
      expect(asset).to have_type :image
    end
  end

  context '#import?, #import_it' do
    it 'fails if file does not exist' do
      in_current_dir do
        base_path = File.expand_path('source/path/to')
        file_path = File.expand_path('source/path/to/image.xz')

        asset = Asset.new(file_path, source_directory: base_path)

        expect(asset).not_to be_import
      end
    end

    it 'succeeds if import it is set' do
      in_current_dir do
        base_path = File.expand_path('source/path/to')
        file_path = File.expand_path('source/path/to/image.xz')
        write_file file_path, 'asdf'

        asset = Asset.new(file_path, source_directory: base_path)
        asset.import_it

        expect(asset).to be_import
      end
    end

    it 'succeeds if is in trusted directory images' do
      in_current_dir do
        base_path = File.expand_path('source/path/to/images')
        file_path = File.expand_path('source/path/to/images/image.xz')
        write_file file_path, 'asdf'

        asset = Asset.new(file_path, source_directory: base_path)

        expect(asset).to be_import
      end
    end
  end

  context '#destination_path, #destination_path=, #destination_directory' do
    it 'returns @destination_path if set' do
      in_current_dir do
        base_path = File.expand_path('source/path/to/images')
        file_path = File.expand_path('source/path/to/images/image.xz')

        asset = Asset.new(file_path, source_directory: base_path)
        asset.destination_path = 'asdf/image.xz'

        expect(asset.destination_path).to eq Pathname.new('asdf/image.xz')
      end
    end

    it 'builds path based on destination_directory and relative file path' do
      in_current_dir do
        base_path = File.expand_path('source/path/to/images')
        file_path = File.expand_path('source/path/to/images/image.xz')

        asset = Asset.new(file_path, source_directory: base_path)
        asset.destination_directory = '/images'

        expect(asset.destination_path.to_s).to eq '/images/image.xz'
      end
    end

    it 'fails if destination_directory and @destination_path are not set' do
      in_current_dir do
        base_path = File.expand_path('source/path/to/images')
        file_path = File.expand_path('source/path/to/images/image.xz')

        asset = Asset.new(file_path, source_directory: base_path)

        expect { 
          asset.destination_path
        }.to raise_error ::Sprockets::FileNotFound
      end
    end
  end

  context '#match?' do
    it 'success if source path is equal' do
      in_current_dir do
        base_path = File.expand_path('source/path/to')
        file_path = File.expand_path('source/path/to/images/image.xz')

        asset1 = Asset.new(file_path, source_directory: base_path)

        expect(asset1).to be_match file_path
      end
    end

    it 'fails if source path is not equal' do
      in_current_dir do
        base_path = File.expand_path('source/path/to')
        file_path = File.expand_path('source/path/to/images/image.xz')

        asset1 = Asset.new(file_path, source_directory: base_path)

        expect(asset1).not_to be_match 'asdf'
      end
    end
  end
end
