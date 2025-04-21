class DonationFilter
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Filter attributes
  attribute :at_storage_location, :string
  attribute :by_source, :string
  attribute :by_product_drive, :string
  attribute :by_product_drive_participant, :string
  attribute :from_manufacturer, :string
  attribute :from_donation_site, :string
  attribute :date_range, :string
  attribute :date_range_label, :string

  attr_reader :start_date, :end_date

  validate :date_range_must_be_valid

  def initialize(attributes = nil)
    super
    parse_or_set_default_dates
  end

  def selected_range
    (start_date.beginning_of_day)..(end_date.end_of_day)
  end

  def to_filter_params
    {
      at_storage_location: at_storage_location,
      by_source: by_source,
      by_product_drive: by_product_drive,
      by_product_drive_participant: by_product_drive_participant,
      from_manufacturer: from_manufacturer,
      from_donation_site: from_donation_site
    }.compact_blank
  end

  private

  def parse_or_set_default_dates
    if date_range.blank?
      set_default_dates
    else
      parse_date_range(date_range)
    end
  end

  def parse_date_range(range_str)
    parts = range_str.split(" - ")
    if parts.size == 2
      @start_date = Date.strptime(parts[0].strip, "%B %d, %Y")
      @end_date = Date.strptime(parts[1].strip, "%B %d, %Y")
    else
      set_default_dates # fallback to default if invalid format
    end
  rescue ArgumentError
    set_default_dates # fallback if parse fails
  end

  def set_default_dates
    @start_date = 2.months.ago.to_date
    @end_date = 1.month.from_now.to_date
  end

  # def date_range_must_be_valid
  #   # Optional: add validation errors, but won't interfere with initialization
  #   return if date_range.blank?

  #   parts = date_range.split(" - ")
  #   if parts.size != 2
  #     errors.add(:date_range, "must be in format 'Month Day, Year - Month Day, Year'")
  #   else
  #     begin
  #       Date.strptime(parts[0].strip, "%B %d, %Y")
  #       Date.strptime(parts[1].strip, "%B %d, %Y")
  #     rescue ArgumentError
  #       errors.add(:date_range, "contains an invalid date")
  #     end
  #   end
  # end
  def date_range_must_be_valid
    return if date_range.blank?

    parts = date_range.split(" - ")
    if parts.size != 2
      errors.add(:date_range, "must be in format 'Month Day, Year - Month Day, Year' (got: '#{date_range}')")
    else
      begin
        Date.strptime(parts[0].strip, "%B %d, %Y")
        Date.strptime(parts[1].strip, "%B %d, %Y")
      rescue ArgumentError
        errors.add(:date_range, "contains an invalid date (got: '#{date_range}')")
      end
    end
  end
end
