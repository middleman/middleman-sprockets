# encoding: utf-8
module Middleman
  module Sprockets
    class AssetList
      attr_reader :assets

      def initialize(assets = [])
        @assets = Array(assets)
      end

      # Find candidate in list
      #
      # @param [#source_path] candidate
      #   The candidate to search for
      #
      # @yield
      #   This blocks gets the candidate found
      def lookup(candidate, &block)
        found_asset = assets.find { |a| a.match? candidate.source_path }

        block.call(candidate, found_asset) if block_given? && found_asset

        found_asset
      end

      # Append asset to list
      #
      # @param [Asset]
      #   The asset to be appended
      def add(asset)
        assets << asset
      end
      alias_method :<<, :add

    end
  end
end
