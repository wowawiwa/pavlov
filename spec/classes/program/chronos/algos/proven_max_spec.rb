require 'spec_helper'
include ActionView::Helpers::DateHelper

PM = Program::Chronos::Algos::ProvenMax

describe PM do

  describe "#run_iteration" do
    let(:final_state){ PM.run_iteration( init_state, result, eval_date, timebase).symbolize_keys}
    let(:eval_date){ Time.zone.now}
    let(:timebase){ 1.day}
    let(:ground_state){ { created_at: 10.days.ago, last_evaluation_date: 3.seconds.ago}}

    describe "(Evaluation save & update hooking)" do
      it "is called when an evaluation is created" do
        PM.should_receive(:run_iteration).and_return({})
        build(:evaluation).save
      end
      it "is called when an evaluation is updated" do
        e = create(:evaluation)
        PM.should_receive(:run_iteration).and_return({})
        e.result = true
        e.save
      end
    end

    describe "field: current_success_count field" do
      [nil, 0, 3].each do |csc| describe "(csc #{csc.inspect})" do
        let(:init_state){ { created_at: 10.days.ago, current_success_count: csc}}

        context "when true result" do
          let(:result){ true}

          it "increments" do
            expect( final_state[:current_success_count]).to eq((csc || 0) + 1)
          end
        end

        context "when false result" do
          let(:result){ false}

          it "is set to 0" do
            expect( final_state[:current_success_count]).to eq( 0)
          end
        end
      end ; end
    end # current_success_count

    describe "field: next_evaluation_date field" do
      context "(natural delay)" do
        let(:result){ true}

        context "when current_success_count == 0" do
          let(:init_state){ ground_state}

          it "should delay 1T" do
            expect( final_state[:next_evaluation_date]).to be > ( eval_date + timebase - 1.second)
            expect( final_state[:next_evaluation_date]).to be < ( eval_date + timebase + 1.second)
          end
        end

        context "when current_success_count == 1" do
          let(:init_state){ ground_state.merge( current_success_count: 1)}

          it "should delay 2T" do
            expect( final_state[:next_evaluation_date]).to be > ( eval_date + 2 * timebase - 1.second)
            expect( final_state[:next_evaluation_date]).to be < ( eval_date + 2 * timebase + 1.second)
          end
        end
        context "when current_success_count == 2" do
          let(:init_state){ ground_state.merge( current_success_count: 2)}

          it "should delay 5T" do
            expect( final_state[:next_evaluation_date]).to be > ( eval_date + 5 * timebase - 1.second)
            expect( final_state[:next_evaluation_date]).to be < ( eval_date + 5 * timebase + 1.second)
          end
        end
        context "when current_success_count >= 3" do
          let(:init_state){ ground_state.merge( current_success_count: 4, current_timespan: 5.minutes)}

          it "should delay 5 current_timespan" do
            expect( final_state[:next_evaluation_date]).to be > ( eval_date + 5 * init_state[:current_timespan] - 1.second)
            expect( final_state[:next_evaluation_date]).to be < ( eval_date + 5 * init_state[:current_timespan] + 1.second)
          end
        end
      end

      context "(balanced delay)" do
      end
    end
  end
end
