require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class AdopterFosterProfilePolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  setup do
    @user = build_stubbed(:user)
  end

  context "#new?" do
    setup do
      @policy = -> { AdopterFosterProfilePolicy.new(AdopterFosterProfile, user: @user) }
    end

    should "be an alias to :create?" do
      assert_alias_rule @policy.call, :new?, :create?
    end
  end

  context "#create?" do
    setup do
      @policy = -> { AdopterFosterProfilePolicy.new(AdopterFosterProfile, user: @user) }
      @action = -> { @policy.call.apply(:create?) }
    end

    context "when user has valid permissions" do
      setup do
        @user.stubs(:permissions).returns([:create_adopter_foster_profiles])
      end

      should "return true" do
        assert_equal @action.call, true
      end

      context "when user is adopter with profile" do
        setup do
          @user = build_stubbed(:adopter, :with_profile)
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end
    end

    context "when user does not have valid permissions" do
      setup do
        @user.stubs(:permissions).returns([])
      end

      should "return false" do
        assert_equal @action.call, false
      end
    end
  end

  context "existing record action" do
    setup do
      @profile = build_stubbed(:adopter_foster_profile)
      @policy = -> { AdopterFosterProfilePolicy.new(@profile, user: @user) }
    end

    context "#manage?" do
      setup do
        @action = -> { @policy.call.apply(:manage?) }
      end

      context "when user owns the profile" do
        setup do
          @user = @profile.adopter_foster_account.user
        end

        context "when user has valid permissions" do
          setup do
            @user.stubs(:permissions).returns([:manage_adopter_foster_profiles])
          end

          should "return true" do
            assert_equal @action.call, true
          end
        end

        context "when user does not have valid permissions" do
          setup do
            @user.stubs(:permissions).returns([])
          end

          should "return false" do
            assert_equal @action.call, false
          end
        end
      end

      context "when user does not own the profile" do
        setup do
          @user = build_stubbed(:adopter, :with_profile)
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end
    end

    context "#show?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :show?, :manage?
      end
    end

    context "#edit?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :edit?, :manage?
      end
    end

    context "#update?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :update?, :manage?
      end
    end
  end
end
