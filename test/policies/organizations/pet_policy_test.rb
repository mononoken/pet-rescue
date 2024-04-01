require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class Organizations::PetPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  context "context only action" do
    setup do
      @user = build_stubbed(:staff)
      @organization = ActsAsTenant.current_tenant
      @policy = -> {
        Organizations::PetPolicy.new(Pet, user: @user,
          organization: @organization)
      }
    end

    context "#manage?" do
      setup do
        @action = -> { @policy.call.apply(:manage?) }
      end

      context "when user has valid permissions" do
        setup do
          @user.stubs(:permissions).returns([:manage_pets])
        end

        should "return true" do
          assert_equal @action.call, true
        end

        context "when user is not scoped witin the organization context" do
          setup do
            ActsAsTenant.with_tenant(build_stubbed(:organization)) do
              @user = build_stubbed(:staff)
              @user.stubs(:permissions).returns([:manage_pets])
            end
          end

          should "return false" do
            assert_equal @action.call, false
          end
        end

        context "when user's staff account is deactivated" do
          setup do
            @user = build_stubbed(:staff, :deactivated)
            @user.stubs(:permissions).returns([:manage_pets])
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

    context "#index?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :index?, :manage?
      end
    end

    context "#new?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :new?, :manage?
      end
    end

    context "#create?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :create?, :manage?
      end
    end
  end

  context "existing record action" do
    setup do
      @user = build_stubbed(:staff)
      @pet = create(:pet)
      @policy = -> { Organizations::PetPolicy.new(@pet, user: @user) }
    end

    context "#manage?" do
      setup do
        @action = -> { @policy.call.apply(:manage?) }
      end

      context "when user has valid permissions" do
        setup do
          @user.stubs(:permissions).returns([:manage_pets])
        end

        should "return true" do
          assert_equal @action.call, true
        end

        context "when user is not scoped witin the organization context" do
          setup do
            ActsAsTenant.with_tenant(build_stubbed(:organization)) do
              @user = build_stubbed(:staff)
              @user.stubs(:permissions).returns([:manage_pets])
            end
          end

          should "return false" do
            assert_equal @action.call, false
          end
        end

        context "when user's staff account is deactivated" do
          setup do
            @user = build_stubbed(:staff, :deactivated)
            @user.stubs(:permissions).returns([:manage_pets])
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

    context "#destroy?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :destroy?, :manage?
      end
    end

    context "#attach_images?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :attach_images?, :manage?
      end
    end

    context "#attach_files?" do
      should "be an alias to :manage?" do
        assert_alias_rule @policy.call, :attach_files?, :manage?
      end
    end
  end
end
