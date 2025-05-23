# == Schema Information
#
# Table name: requests
#
#  id              :bigint           not null, primary key
#  comments        :text
#  discard_reason  :text
#  discarded_at    :datetime
#  request_items   :jsonb
#  request_type    :string
#  status          :integer          default("pending")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  distribution_id :integer
#  organization_id :bigint
#  partner_id      :bigint
#  partner_user_id :integer
#

class Request < ApplicationRecord
  has_paper_trail
  include Discard::Model
  include Exportable

  belongs_to :partner
  belongs_to :partner_user, class_name: "::User", optional: true
  belongs_to :organization
  belongs_to :distribution, optional: true

  has_many :item_requests, class_name: "Partners::ItemRequest", foreign_key: :partner_request_id, dependent: :destroy, inverse_of: :request
  accepts_nested_attributes_for :item_requests, allow_destroy: true, reject_if: proc { |attributes| attributes["quantity"].blank? }
  has_many :child_item_requests, through: :item_requests

  enum :status, { pending: 0, started: 1, fulfilled: 2, discarded: 3 }, prefix: true
  enum :request_type, %w[quantity individual child].map { |v| [v, v] }.to_h

  validates :distribution_id, uniqueness: true, allow_nil: true
  validate :item_requests_uniqueness_by_item_id
  validate :not_completely_empty

  after_validation :sanitize_items_data

  include Filterable
  # add request item scope to allow filtering distributions by request item
  scope :by_request_item_id, ->(item_id) { where("request_items @> :with_item_id ", with_item_id: [{ item_id: item_id.to_i }].to_json) }
  # partner scope to allow filtering by partner
  scope :by_partner, ->(partner_id) { where(partner_id: partner_id) }
  # status scope to allow filtering by status
  scope :by_status, ->(status) { where(status: status) }
  scope :by_request_type, ->(request_type) { where(request_type: request_type) }
  scope :during, ->(range) { where(created_at: range) }

  def total_items
    request_items.sum { |item| item["quantity"] }
  end

  def requester
    # Despite the field being called "partner_user_id", it can refer to both a partner user or an organization admin
    partner_user_id ? partner_user : partner
  end

  def request_type_label
    request_type&.first&.capitalize
  end

  private

  def item_requests_uniqueness_by_item_id
    item_ids = item_requests.map(&:item_id)
    if item_ids.uniq.length != item_ids.length
      errors.add(:item_requests, "should have unique item_ids")
    end
  end

  def sanitize_items_data
    return unless request_items && request_items_changed?

    self.request_items = request_items.map do |item|
      item.merge("item_id" => item["item_id"]&.to_i, "quantity" => item["quantity"]&.to_i)
    end
  end

  def not_completely_empty
    if comments.blank? && item_requests.blank?
      errors.add(:base, "completely empty request")
    end
  end
end
