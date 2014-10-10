require 'spec_helper'

describe Melcatalog do

  before do
    Melcatalog.configure do |config|
      config.service_endpoint = 'http://localhost:4000/api'
    end
  end

  describe '#search' do

     it 'search by wildcard' do
        term = "%"
        results = Melcatalog.search( term, Melcatalog.configuration.default_result_limit )
        fail if results.empty?
     end

     it 'search by type' do
       term = "%"

       results = Melcatalog.search( term, Melcatalog.configuration.default_result_limit, [:text] )
       fail if results.empty?
       fail if results[:text].nil?
       fail if results[:person].nil? == false
       fail if results[:artwork].nil? == false

       results = Melcatalog.search( term, Melcatalog.configuration.default_result_limit, [:person] )
       fail if results.empty?
       fail if results[:text].nil? == false
       fail if results[:person].nil?
       fail if results[:artwork].nil? == false

       results = Melcatalog.search( term, Melcatalog.configuration.default_result_limit, [:artwork] )
       fail if results.empty?
       fail if results[:text].nil? == false
       fail if results[:person].nil? == false
       fail if results[:artwork].nil?

     end

     it 'search by type list' do
       term = "%"

       results = Melcatalog.search( term, Melcatalog.configuration.default_result_limit, [:text, :person ] )
       fail if results.empty?
       fail if results[:text].nil?
       fail if results[:person].nil?
       fail if results[:artwork].nil? == false
     end

     it 'limit result count' do
       max = 1
       results = Melcatalog.search( "", max )
       fail if results.empty?

       fail if results[:text].nil? == false && results[:text].size > max
       fail if results[:person].nil? == false && results[:person].size > max
       fail if results[:artwork].nil? == false && results[:artwork].size > max
     end

     it 'image only results' do
        # TODO
     end

  end

  describe '#explicit' do

    it 'get by eid' do

      # get the first text entry by EID
      metadata = Melcatalog.texts(  )
      fail if metadata.empty?
      eid = ""
      eid = metadata[:text][ 0 ]['eid'] unless metadata[:text].nil?
      fail if eid.empty?
      results = Melcatalog.get( eid )
      fail if results.size != 1
      check_texts( results[:text], true )

      # get the first person entry by EID
      metadata = Melcatalog.people(  )
      fail if metadata.empty?
      eid = ""
      eid = metadata[:person][ 0 ]['eid'] unless metadata[:person].nil?
      fail if eid.empty?
      results = Melcatalog.get( eid )
      fail if results.size != 1
      check_people( results[:person], true )

      # get the first artwork entry by EID
      metadata = Melcatalog.artwork(  )
      fail if metadata.empty?
      eid = ""
      eid = metadata[:artwork][ 0 ]['eid'] unless metadata[:artwork].nil?
      fail if eid.empty?
      results = Melcatalog.get( eid )
      fail if results.size != 1
      check_artworks( results[:artwork], true )

    end

  end

  describe '#metadata' do

    it 'gets AAT tag hierarchy' do
       metadata = Melcatalog.aat_hierarchy(  )
       fail if metadata.empty?
       process_tag_peers( metadata )
    end

  end

  describe '#helpers' do

    it 'gets texts metadata' do
      metadata = Melcatalog.texts(  )
      fail if metadata.empty?
      must_exist( metadata, :text )
      check_texts( metadata[:text], false )
    end

    it 'gets people metadata' do
      metadata = Melcatalog.people(  )
      fail if metadata.empty?
      must_exist( metadata, :person )
      check_people( metadata[:person], false )
    end

    it 'gets artwork metadata' do
      metadata = Melcatalog.artwork(  )
      fail if metadata.empty?
      must_exist( metadata, :artwork )
      check_artworks( metadata[:artwork], false )
    end

  end

  private

  def check_texts( entities, contentOk )
    entities.each { | entity |

      must_exist( entity, 'eid' )
      must_exist( entity, 'name' )
      must_exist( entity, 'author' )
      must_exist( entity, 'witnesses' )
      must_exist( entity, 'edition' )
      must_exist( entity, 'publisher' )
      must_exist( entity, 'publication_date' )
      must_exist( entity, 'source' )
      must_exist( entity, 'copyright' )

      must_not_exist( entity, 'content' ) if contentOk == false
      must_exist( entity, 'content' ) if contentOk == true
    }
  end

  def check_people( entities, contentOk )
    entities.each { | entity |
      must_exist( entity, 'eid' )
      must_exist( entity, 'name' )
      must_exist( entity, 'surname' )
      must_exist( entity, 'forename' )
      must_exist( entity, 'role' )
      must_exist( entity, 'additional_name_info' )
      must_exist( entity, 'birth' )
      must_exist( entity, 'death' )
      must_exist( entity, 'nationality' )
      must_exist( entity, 'education' )

      must_exist( entity, 'url' )
      must_exist( entity, 'image_full' )
      must_exist( entity, 'image_medium' )
      must_exist( entity, 'image_thumb' )
    }
  end

  def check_artworks( entities, contentOk )
    entities.each { | entity |
      must_exist( entity, 'eid' )
      must_exist( entity, 'artist' )
      must_exist( entity, 'artist_national_origin' )
      must_exist( entity, 'engraver' )
      must_exist( entity, 'engraver_national_origin' )
      must_exist( entity, 'title' )
      must_exist( entity, 'publication' )
      must_exist( entity, 'medium' )
      must_exist( entity, 'medium_of_original' )
      must_exist( entity, 'location_of_print' )
      must_exist( entity, 'genre' )
      must_exist( entity, 'geography' )
      must_exist( entity, 'subject' )
      must_exist( entity, 'viewed' )
      must_exist( entity, 'permissions' )
      must_exist( entity, 'owned_acquired_borrowed' )
      must_exist( entity, 'explicit_reference' )
      must_exist( entity, 'associated_reference' )

      must_exist( entity, 'url' )
      must_exist( entity, 'image_full' )
      must_exist( entity, 'image_medium' )
      must_exist( entity, 'image_thumb' )
    }
  end

  def process_tag_peers( peers )
    peers.each { | entity |
      must_exist( entity, 'text' )
      process_tag_peers( entity[ 'nodes' ] ) unless entity[ 'nodes' ].nil?
      fail if entity[ 'eid' ].nil? == false && entity[ 'eid' ].empty?
    }
  end

  def must_exist( obj, field )
    puts "ERROR: missing required field: #{field}" if obj.has_key?( field ) == false
    fail if obj.has_key?( field ) == false
  end

  def must_not_exist( obj, field )
    puts "ERROR: exists #{field}" if obj.has_key?( field ) == true
    fail if obj.has_key?( field ) == true
  end
end