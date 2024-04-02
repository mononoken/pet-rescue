require "test_helper"

# See https://actionpolicy.evilmartians.io/#/testing?id=testing-policies
class AdopterApplicationPolicyTest < ActiveSupport::TestCase
  include PetRescue::PolicyAssertions

  setup do
    @user = build_stubbed(:user)
  end

  context "relation_scope" do
    setup do
      policy = -> {
        AdopterApplicationPolicy.new(AdopterApplication, user: @user)
      }
      target = -> { AdopterApplication.all }
      @scope = -> {
        policy.call.apply_scope(target.call, type: :active_record_relation)
          .pluck(:id)
      }
    end

    context "when user is adopter with profile" do
      setup do
        @user = create(:adopter, :with_profile)
      end

      context "when there are applications that do not belong to user" do
        setup do
          @user_applications = [
            create(:adopter_application, user: @user),
            create(:adopter_application, user: @user)
          ]
          @other_application = create(:adopter_application)
        end

        should "return only user's applications" do
          expected = @user_applications.map(&:id)

          assert_equal(@scope.call, expected)
        end
      end

      context "when user has no applications" do
        setup do
          @other_application = create(:adopter_application)
        end

        should "return empty array" do
          assert_equal(@scope.call, [])
        end
      end
    end
  end

  context "#index?" do
    setup do
      @policy = -> {
        AdopterApplicationPolicy.new(AdopterApplication, user: @user)
      }
      @action = -> { @policy.call.apply(:index?) }
    end

    context "when user is adopter with profile" do
      setup do
        @user = build_stubbed(:adopter, :with_profile)
      end

      context "when user has valid permissions" do
        setup do
          @user.stubs(:permissions).returns([:view_adopter_applications])
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

    context "when user not associated with adopter account" do
      setup do
        @user = build_stubbed(:user)
      end

      should "return false" do
        assert_equal @action.call, false
      end
    end

    context "when user is adopter without profile" do
      setup do
        @user = build_stubbed(:adopter)
      end

      should "return false" do
        assert_equal @action.call, false
      end
    end
  end

  context "#create?" do
    setup do
      @pet = create(:pet)
      @policy = -> {
        AdopterApplicationPolicy.new(AdopterApplication, user: @user,
          pet: @pet)
      }
      @action = -> { @policy.call.apply(:create?) }
    end

    context "when user is adopter with profile" do
      setup do
        @user = build_stubbed(:adopter, :with_profile)
      end

      context "when user has valid permissions" do
        setup do
          @user.stubs(:permissions).returns([:create_adopter_applications])
        end

        context "when pet application is not paused" do
          setup do
            @pet = create(:pet, application_paused: false)
          end

          context "when user already has an existing application for the pet" do
            setup do
              @user = create(:adopter, :with_profile)
              @user.stubs(:permissions).returns([:create_adopter_applications])
              @existing_app = create(:adopter_application, user: @user, pet: @pet)
            end

            should "return false" do
              assert_equal @action.call, false
            end
          end

          context "when user has not applied for the pet" do
            should "return true" do
              assert_equal @action.call, true
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

      context "when user not associated with adopter account" do
        setup do
          @user = build_stubbed(:user)
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when user is adopter without profile" do
        setup do
          @user = build_stubbed(:adopter)
        end

        should "return false" do
          assert_equal @action.call, false
        end
      end
    end
  end

  context "#update?" do
    setup do
      @adopter_application = build_stubbed(:adopter_application)
      @policy = -> {
        AdopterApplicationPolicy.new(@adopter_application, user: @user)
      }
      @action = -> { @policy.call.apply(:update?) }
    end

    context "when user is adopter with profile" do
      setup do
        @user = build_stubbed(:adopter, :with_profile)
      end

      context "when adopter account does not belong to user" do
        should "return false" do
          assert_equal @action.call, false
        end
      end

      context "when adopter account belongs to user" do
        setup do
          @user = @adopter_application.adopter_foster_account.user
        end

        context "when user has valid permissions" do
          setup do
            @user.stubs(:permissions).returns([:withdraw_adopter_applications])
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
    end

    context "when user not associated with adopter account" do
      setup do
        @user = build_stubbed(:user)
      end

      should "return false" do
        assert_equal @action.call, false
      end
    end

    context "when user is adopter without profile" do
      setup do
        @user = build_stubbed(:adopter)
      end

      should "return false" do
        assert_equal @action.call, false
      end
    end
  end
end
