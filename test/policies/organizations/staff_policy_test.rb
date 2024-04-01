require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organizations::StaffAccountPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  setup do
    @user = build_stubbed(:user)
    @staff = build_stubbed(:staff_account)
    @policy = -> { Organizations::StaffAccountPolicy.new(@staff, user: @user) }
  end

  context "#index?" do
    setup do
      @action = -> { @policy.call.apply(:index?) }
    end

    context "when user has valid permissions" do
      setup do
        @user.stubs(:permissions).returns([:manage_staff])
      end

      should "return true" do
        assert_equal @action.call, true
      end

      context "when user is not scoped witin the organization context" do
        setup do
          ActsAsTenant.with_tenant(build_stubbed(:organization)) do
            @user = build_stubbed(:user)
            @user.stubs(:permissions).returns([:manage_staff])
          end
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

  context "#activate?" do
    setup do
      @action = -> { @policy.call.apply(:activate?) }
    end

    context "when user has valid permissions" do
      setup do
        @user.stubs(:permissions).returns([:activate_staff])
      end

      should "return true" do
        assert_equal @action.call, true
      end

      context "when user is not scoped witin the organization context" do
        setup do
          ActsAsTenant.with_tenant(build_stubbed(:organization)) do
            @user = build_stubbed(:user)
            @user.stubs(:permissions).returns([:activate_staff])
          end
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

  context "#deactivate?" do
    should "be an alias to :activate?" do
      assert_alias_rule @policy.call, :deactivate?, :activate?
    end
  end

  context "#update_activation?" do
    should "be an alias to :activate?" do
      assert_alias_rule @policy.call, :update_activation?, :activate?
    end
  end
end
