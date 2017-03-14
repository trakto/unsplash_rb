require "spec_helper"

describe Unsplash::Photo do

  describe "#find" do
    let(:photo_id) { "tAKXap853rY" }
    let(:fake_id)  { "abc123" }

    it "returns a Photo object" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.find(photo_id)
      end

      expect(@photo).to be_a Unsplash::Photo
    end

    it "errors if the photo doesn't exist" do
      expect {
        VCR.use_cassette("photos") do
          @photo = Unsplash::Photo.find(fake_id)
        end
      }.to raise_error Unsplash::Error
    end

    it "parses the nested user object" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.find(photo_id)
      end

      expect(@photo.user).to be_an Unsplash::User
    end

    it "supports nested method access" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.find(photo_id)
      end

      expect(@photo.user.links.html).to eq("http://lvh.me:3000/alejandroescamilla")
    end
  end

  describe "#random" do

    let(:params) do
      {
        categories: [2],
        featured:   true,
        width:      320,
        height:     200
      }
    end

    it "returns a Photo object" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.random(params)
      end

      expect(@photo).to be_a Unsplash::Photo
    end

    it "errors if there are no photos to choose from" do
      expect {
        VCR.use_cassette("photos") do
          @photo = Unsplash::Photo.random(user: "bigfoot")
        end
      }.to raise_error Unsplash::Error
    end

    it "parses the nested user object" do
      VCR.use_cassette("photos") do
        @photo = Unsplash::Photo.random(params)
      end

      expect(@photo.user).to be_an Unsplash::User
    end

    context "with categories" do
      it "joins them" do
        expect(Unsplash::Photo.connection)
          .to receive(:get).with("/photos/random", category: "1,2,3")
          .and_return double(body: "{}")

        photo = Unsplash::Photo.random(categories: [1,2,3])
      end
    end

    context "with collections" do
      it "joins them" do
        expect(Unsplash::Photo.connection)
          .to receive(:get).with("/photos/random", collections: "4,5,6")
          .and_return double(body: "{}")

        photo = Unsplash::Photo.random(collections: [4,5,6])
      end
    end


    context "without categories" do
      it "removes them" do
        expect(Unsplash::Photo.connection)
          .to receive(:get).with("/photos/random", {})
          .and_return double(body: "{}")

        photo = Unsplash::Photo.random
      end
    end

    context "with orientation" do
      it "returns a landscaped photo" do

        VCR.use_cassette("photos") do
          @photo = Unsplash::Photo.random(orientation: :landscape)
        end

        expect(@photo).to be_a Unsplash::Photo
      end
    end

  end

  describe "#search" do
    it "returns an array of Photos" do
      VCR.use_cassette("photos") do
        @response = Unsplash::Photo.search("dog", 1)
      end

      expect(@response[:total]).to eq 4
      expect(@response[:total_pages]).to eq 1
      expect(@response[:results]).to be_an Array
      expect(@response[:results].size).to eq 4
    end

    it "returns an array of Photos with number of elements per page defined" do
      VCR.use_cassette("photos") do
        @response = Unsplash::Photo.search("dog", 1, 3)
      end

      expect(@response[:total]).to eq 3
      expect(@response[:total_pages]).to eq 1
      expect(@response[:results]).to be_an Array
      expect(@response[:results].size).to eq 3
    end
  end

  describe "#index" do
    it "returns an array of Photos" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.all(1, 6)
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 6
    end

    it "returns an array of Photos order by oldest criteria" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.all(1, 6, "oldest")
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 6
    end
  end

  describe "#curated" do
    it "returns an array of Photos" do
      VCR.use_cassette("photos") do
        @photos = Unsplash::Photo.curated(1, 6)
      end

      expect(@photos).to be_an Array
      expect(@photos.size).to eq 6
    end
  end

  describe "#create" do

    it "errors on trying to upload a photo" do
      stub_oauth_authorization

      expect {
        VCR.use_cassette("photos", match_requests_on: [:method, :path, :body]) do
          @photo = Unsplash::Photo.create "spec/support/upload-1.txt"
        end
      }.to raise_error Unsplash::Error
    end

  end

  describe "#like!" do
    let(:photo_id) { "tAKXap853rY" }

    it "returns true on success" do
      stub_oauth_authorization

      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.find(photo_id)
        expect(photo.like!).to eq true
      end
    end

    it "raises on error" do
      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.new(id: "abc123")
        expect {
          photo.like!
        }.to raise_error Unsplash::Error
      end
    end

  end

  describe "#unlike!" do
    let(:photo_id) { "tAKXap853rY" }

    it "returns true on success" do
      stub_oauth_authorization

      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.find(photo_id)
        expect(photo.unlike!).to eq true
      end
    end

    it "raises on error" do
      VCR.use_cassette("photos") do
        photo = Unsplash::Photo.new(id: "abc123")
        expect {
          photo.unlike!
        }.to raise_error Unsplash::Error
      end
    end

  end



end
