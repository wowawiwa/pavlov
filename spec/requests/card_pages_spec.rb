require "spec_helper"

describe "Card pages" do
  let(:card){ create(:card)}
  let(:user){ card.user}
  before{ sign_in user}

  subject{ page}

  describe "Add-Card" do
    before{ visit new_card_path}
    let(:submit){ "Save card"}
    let(:title){ "New card"}

    describe "page itself" do
      it_behaves_like "title"

      describe "Backlink" do
        let!(:a_back_page){ cards_url(list_name: card.list.name)}
        # TODO pending (causes ambiguous "Card" link)
        #it_behaves_like "form back link", "Card", "Cancel" do
        #  before{ visit a_back_page}
        #end
      end
    end

    describe "Form sending" do
      let!(:before_card_count){ user.cards.count}
      let!(:before_word_count){ Word.count}
      let!(:before_word_reverse_count){ WordReverse.count}
      let!(:before_list_count){ user.lists.count}

      context "with valid information" do
        let(:example_content){ "Example Content"}
        let(:example_tip){ "Example Tip"}
        before do
          fill_in "word[content]",  with: example_content
          fill_in "word[tip]",      with: example_tip
          fill_in "list[name]",     with: card.list.name
        end

        describe "(Card and Word model instances)" do
          before{ click_button submit}

          it "creates 2 cards" do
            expect(user.cards.count).to eq(before_card_count + 2)
          end

          it "creates a Word with the right content and tip, and card" do
            expect(Word.count).to eq( before_word_count + 1)
            expect(Word.last.content).to eq( example_content)
            expect(Word.last.tip).to eq( example_tip)
            expect(Word.last.card.user.id).to eq( user.id)
          end

          it "creates a Reverse Word with the right card" do
            expect(WordReverse.count).to eq( before_word_reverse_count + 1)
            expect(WordReverse.last.word.content).to eq( example_content)
          end
        end

        describe "(List model instance)" do

          context "when list exists already" do
            before{ click_button submit}

            it "does not create a new list" do
              expect(List.count).to eq( before_list_count)
            end
          end

          context "when list does not exists already" do
            before{ fill_in "list[name]", with: "non existing list name "}
            before{ click_button submit}

            it "creates a new list" do
              expect(List.count).to eq( before_list_count + 1)
            end
          end
        end
      end

      context "with invalid information" do
        invalids = [
          { "word[content]" => "toto", "word[tip]" => "tata", "list[name]" => "" } 
        ]
        invalids.each do |h|
          context "(#{h})" do
            before do
              h.each{|k,v| fill_in k, with: v}
              click_button submit
            end

            it_behaves_like "flash alert", "warning"

            it "should not create a new card" do
              expect( Card.count).to eq( before_card_count)
            end

            it "should not create a new list" do
              expect( List.count).to eq( before_list_count)
            end
          end
        end
      end
    end
  end # Add

  describe "Edit" do
    describe "page itself"
    describe "with valid informations" do

      #it "updates information"

      context "when new list exists" do
        #it "does not create a new list"
      end
      context "when new list does not exist" do
        #it "creates a new list"
      end
    end
    describe "with invalid informations"
  end # Edit

  describe "Index" do
  end # Index
end
