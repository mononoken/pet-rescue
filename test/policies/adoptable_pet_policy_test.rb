require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class AdoptablePetPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  def setup
    @user = build_stubbed(:user)
    @policy = -> { AdoptablePetPolicy.new(@pet, user: @user) }
  end

  context "relation_scope" do
    setup do
      @policy = AdoptablePetPolicy.new(Pet, user: @user)
      @unadopted_pet = create(:pet)
      @adopted_pet = create(:pet, :adopted)
    end

    should "return published pets where missing match" do
      expected = [@unadopted_pet].map(&:id)

      scoped = @policy
        .apply_scope(Pet.all, type: :active_record_relation)
        .pluck(:id)

      assert_equal(scoped, expected)
    end
  end

  context "#show?" do
    setup do
      @action = -> { @policy.call.apply(:show?) }
    end

    context "when pet is not published" do
      setup do
        @pet = build_stubbed(:pet, published: false)
      end

      context "when user is allowed to manage pets" do
        setup do
          @policy = @policy.call
          @policy.stubs(:allowed_to?)
            .with(:manage?, @pet, namespace: Organizations)
            .returns(true)
          @action = @policy.apply(:show?)
        end

        should "return true" do
          assert_equal @action, true
        end
      end

      context "when user is not allowed to manage pets" do
        setup do
          @policy = @policy.call
          @policy.stubs(:allowed_to?)
            .returns(false)
          @action = @policy.apply(:show?)
        end

        should "return false" do
          assert_equal @action, false
        end
      end
    end

    context "when pet is published" do
      setup do
        @pet = build_stubbed(:pet, published: true)
      end

      should "return true" do
        assert_equal @action.call, true
      end
    end

    context "when pet already has a match" do
      setup do
        @pet = build_stubbed(:pet, :adopted)
      end

      should "return false" do
        assert_equal @action.call, false
      end
    end
  end
end
