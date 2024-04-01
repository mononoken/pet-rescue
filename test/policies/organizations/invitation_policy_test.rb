require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organizations::InvitationPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  setup do
    @user = build_stubbed(:staff)
    @organization = ActsAsTenant.current_tenant
    @policy = -> {
      Organizations::InvitationPolicy.new(
        StaffAccount, organization: @organization, user: @user
      )
    }
  end

  context "#new?" do
    should "be an alias to :create?" do
      assert_alias_rule @policy.call, :new?, :create?
    end
  end

  context "#create?" do
    setup do
      @action = -> { @policy.call.apply(:create?) }
    end

    context "when user has valid permissions" do
      setup do
        @user.stubs(:permissions).returns([:invite_staff])
      end

      should "return true" do
        assert_equal @action.call, true
      end

      context "when user is not scoped within the organization context" do
        setup do
          ActsAsTenant.with_tenant(build_stubbed(:organization)) do
            @user = build_stubbed(:staff)
            @user.stubs(:permissions).returns([:invite_staff])
          end
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user's staff account is deactivated" do
        setup do
          @user = build_stubbed(:staff, :deactivated)
          @user.stubs(:permissions).returns([:invite_staff])
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
end
