# == Schema Information
#
# Table name: organizations
#
#  id         :bigint           not null, primary key
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_on_slug  (slug) UNIQUE
#
class Organization < ApplicationRecord
  # Rolify resource
  resourcify

  has_many :staff_accounts
  has_many :users, through: :staff_accounts
  has_many :pets
  has_many :default_pet_tasks
  has_many :forms, class_name: "CustomForm::Form", dependent: :destroy
  has_many :faqs

  has_many :form_answers, dependent: :destroy
  has_many :people

  has_one :profile, dependent: :destroy, class_name: "OrganizationProfile", required: true
  has_one :location, through: :profile
  has_one :form_submission, dependent: :destroy
  has_one :custom_page, dependent: :destroy
end
