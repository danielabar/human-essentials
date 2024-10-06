class PartnerCreateService
  include ServiceObjectErrorsMixin

  attr_reader :partner

  def initialize(organization:, partner_attrs:)
    @organization = organization
    @partner_attrs = partner_attrs
  end

  def call
    @partner = organization.partners.build(partner_attrs)

    if @partner.valid?
      ActiveRecord::Base.transaction do
        @partner.save!

        # Profile must be created in a valid state, otherwise partner will start getting validation
        # errors from various sections as they try to navigate through the step-wise form.
        Partners::Profile.create!({
                                      partner_id: @partner.id,
                                      name: @partner.name,
                                      enable_child_based_requests: organization.enable_child_based_requests,
                                      enable_individual_requests: organization.enable_individual_requests,
                                      enable_quantity_based_requests: organization.enable_quantity_based_requests,
                                      no_social_media_presence: true
                                    })
      rescue StandardError => e
        errors.add(:base, e.message)
        raise ActiveRecord::Rollback
      end
    else
      @partner.errors.each do |error|
        errors.add(error.attribute, error.message)
      end
    end

    self
  end

  private

  attr_reader :organization, :partner_attrs
end
