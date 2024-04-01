require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organizations::PageTextPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  setup do
    @user = build_stubbed(:staff)
    @organization = ActsAsTenant.current_tenant
    @policy = -> {
      Organizations::PageTextPolicy.new(Pet, user: @user,
        organization: @organization)
    }
  end

  context "#manage?" do
    setup do
      @action = -> { @policy.call.apply(:manage?) }
    end

    context "when user has valid permissions" do
      setup do
        @user.stubs(:permissions).returns([:manage_page_text])
      end

      should "return true" do
        assert_equal @action.call, true
      end

      context "when user is not scoped witin the organization context" do
        setup do
          ActsAsTenant.with_tenant(build_stubbed(:organization)) do
            @user = build_stubbed(:staff)
            @user.stubs(:permissions).returns([:manage_page_text])
          end
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user's staff account is deactivated" do
        setup do
          @user = build_stubbed(:staff, :deactivated)
          @user.stubs(:permissions).returns([:manage_page_text])
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
