module Partners
  class ProfilesController < BaseController
    def show; end

    def edit
      @counties = County.in_category_name_order
      @client_share_total = current_partner.profile.client_share_total

      if Flipper.enabled?("partner_step_form")
        @open_section = params[:open_section] || "agency_information"
        render "partners/profiles/step/edit"
      else
        render "edit"
      end
    end

    def update
      @counties = County.in_category_name_order
      result = PartnerProfileUpdateService.new(current_partner, partner_params, profile_params).call
      if result.success?
        if Flipper.enabled?("partner_step_form")
          # TODO: 4504 - temp debug - need to validate this to ensure its one of an allowed value!
          # probably better to pass in the override into NextStepService and use it there, then its easier to test
          puts "=== PROFILE UPDATE OVERRIDE: #{params[:open_section_override]}"
          submitted_partial = params[:submitted_partial]
          open_section = params[:open_section_override] || Partners::NextStepService.new(current_partner, submitted_partial).next_step
          # open_section = Partners::NextStepService.new(current_partner, submitted_partial).call
          redirect_to edit_partners_profile_path(open_section: open_section)
        else
          flash[:success] = "Details were successfully updated."
          redirect_to partners_profile_path
        end
      else
        flash[:error] = "There is a problem. Try again:  %s" % result.error
        render Flipper.enabled?("partner_step_form") ? "partners/profiles/step/edit" : :edit
      end
    end

    private

    def partner_params
      params.require(:partner).permit(:name)
    end

    def profile_params
      params.require(:partner).require(:profile).permit(
        :agency_type,
        :other_agency_type,
        :proof_of_partner_status,
        :agency_mission,
        :address1,
        :address2,
        :city,
        :state,
        :zip_code,
        :website,
        :facebook,
        :twitter,
        :instagram,
        :no_social_media_presence,
        :founded,
        :form_990,
        :proof_of_form_990,
        :program_name,
        :program_description,
        :program_age,
        :case_management,
        :evidence_based,
        :essentials_use,
        :receives_essentials_from_other,
        :currently_provide_diapers,
        :program_address1,
        :program_address2,
        :program_city,
        :program_state,
        :program_zip_code,
        :client_capacity,
        :storage_space,
        :describe_storage_space,
        :income_requirement_desc,
        :income_verification,
        :population_black,
        :population_white,
        :population_hispanic,
        :population_asian,
        :population_american_indian,
        :population_island,
        :population_multi_racial,
        :population_other,
        :zips_served,
        :at_fpl_or_below,
        :above_1_2_times_fpl,
        :greater_2_times_fpl,
        :poverty_unknown,
        :executive_director_name,
        :executive_director_phone,
        :executive_director_email,
        :primary_contact_name,
        :primary_contact_phone,
        :primary_contact_mobile,
        :primary_contact_email,
        :pick_up_name,
        :pick_up_phone,
        :pick_up_email,
        :distribution_times,
        :new_client_times,
        :more_docs_required,
        :sources_of_funding,
        :sources_of_diapers,
        :essentials_budget,
        :essentials_funding_source,
        :enable_child_based_requests,
        :enable_individual_requests,
        :enable_quantity_based_requests,
        served_areas_attributes: %i[county_id client_share _destroy],
        documents: []
      ).select { |k, v| k.present? }
    end
  end
end
