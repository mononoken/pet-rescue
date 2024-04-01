require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organizations::DashboardPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  setup do
    @user = build_stubbed(:staff)
    @organization = ActsAsTenant.current_tenant
    @policy = -> {
      Organizations::DashboardPolicy.new(
        organization: @organization,
        user: @user
      )
    }
  end

  context "#index?" do
    setup do
      @action = -> { @policy.call.apply(:index?) }
    end

    context "when user has valid permissions" do
      setup do
        @user.stubs(:permissions).returns([:view_organization_dashboard])
      end

      should "return true" do
        assert_equal @action.call, true
      end

      context "when user is not scoped within the organization context" do
        setup do
          ActsAsTenant.with_tenant(build_stubbed(:organization)) do
            @user = build_stubbed(:staff)
            @user.stubs(:permissions).returns([:view_organization_dashboard])
          end
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user's staff account is deactivated" do
        setup do
          @user = build_stubbed(:staff, :deactivated)
          @user.stubs(:permissions).returns([:view_organization_dashboard])
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
