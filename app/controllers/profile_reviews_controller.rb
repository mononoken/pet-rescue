# Controller to permit roles admin & staff to see user profiles
class ProfileReviewsController < ApplicationController
  verify_authorized

  def show
    @adopter_foster_profile = AdopterFosterProfile.find(params[:id])

    authorize! @adopter_foster_profile, with: ProfileReviewPolicy
  end
end
