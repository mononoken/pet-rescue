require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class AdoptablePetPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  def setup
    @policy = -> { AdoptablePetPolicy.new(@pet, user: @user) }
    @user = build_stubbed(:user)
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
