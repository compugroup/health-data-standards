module HQMF2
  # Handles various tasks that the Data Criteria needs performed to obtain and
  # modify secific occurrences
  class SpecificOccurrenceAndSource
    include HQMF2::Utilities

    def initialize(entry, id, local_variable_name, data_criteria_references, occurrences_map)
      @entry = entry
      @id = id
      @local_variable_name = local_variable_name
      @occurrences_map = occurrences_map
      @is_variable = DataCriteriaMethods.extract_variable(@local_variable_name, @id)
      @data_criteria_references = data_criteria_references
    end

    def extract_specific_and_source
      specific_def = @entry.at_xpath('./*/cda:outboundRelationship[@typeCode="OCCR"]', HQMF2::Document::NAMESPACES)
      source_def = @entry.at_xpath('./*/cda:outboundRelationship[cda:subsetCode/@code="SOURCE"]', HQMF2::Document::NAMESPACES)
      if specific_def
        source_data_criteria_extension = HQMF2::Utilities.attr_val(specific_def, './cda:criteriaReference/cda:id/@extension')
        source_data_criteria_root = HQMF2::Utilities.attr_val(specific_def, './cda:criteriaReference/cda:id/@root')

        occurrence_criteria = @data_criteria_references[strip_tokens "#{source_data_criteria_extension}_#{source_data_criteria_root}"]

        return if occurrence_criteria.nil?
        specific_occurrence_const = HQMF2::Utilities.attr_val(specific_def, './cda:localVariableName/@controlInformationRoot')
        specific_occurrence = HQMF2::Utilities.attr_val(specific_def, './cda:localVariableName/@controlInformationExtension')

        # FIXME: Remove debug statements after cleaning up occurrence handling
        # build regex for extracting alpha-index of specific occurrences
        occurrence_identifier = obtain_occurrence_identifier(strip_tokens(@id),
                                                             strip_tokens(@local_variable_name) || '',
                                                             strip_tokens(source_data_criteria_extension),
                                                             @is_variable)

        handle_specific_and_source(occurrence_identifier, source_data_criteria_extension, source_data_criteria_root,
                                   specific_occurrence_const, specific_occurrence)

      elsif source_def
        extension = HQMF2::Utilities.attr_val(source_def, './cda:criteriaReference/cda:id/@extension')
        root = HQMF2::Utilities.attr_val(source_def, './cda:criteriaReference/cda:id/@root')
        ["#{extension}_#{root}"] # return the soruce data criteria itself, the rest will be blank
      end
    end

    # Handle setting the specific and source instance variables with a given occurrence identifier
    def handle_specific_and_source(occurrence_identifier, source_data_criteria_extension, source_data_criteria_root,
                                   specific_occurrence_const, specific_occurrence)
      source_data_criteria = "#{source_data_criteria_extension}_#{source_data_criteria_root}"
      if !occurrence_identifier.blank?
        # if it doesn't exist, add extracted occurrence to the map
        # puts "\tSetting #{@source_data_criteria}-#{@source_data_criteria_root} to #{occurrence_identifier}"
        @occurrences_map[source_data_criteria] ||= occurrence_identifier
        specific_occurrence ||= occurrence_identifier
        specific_occurrence_const = "#{source_data_criteria}".upcase
      else
        # create variable occurrences that do not already exist
        if @is_variable
          # puts "\tSetting #{@source_data_criteria}-#{@source_data_criteria_root} to #{occurrence_identifier}"
          @occurrences_map[source_data_criteria] ||= occurrence_identifier
        end
        occurrence = @occurrences_map.try(:[], source_data_criteria)
        fail "Could not find occurrence mapping for #{source_data_criteria}, #{source_data_criteria_root}" unless occurrence
        # puts "\tUsing #{occurrence} for #{@id}"
        specific_occurrence ||= occurrence
      end

      specific_occurrence = 'A' unless specific_occurrence
      specific_occurrence_const = source_data_criteria.upcase unless specific_occurrence_const
      [source_data_criteria, source_data_criteria_root, source_data_criteria_extension, specific_occurrence, specific_occurrence_const]
    end

    def obtain_occurrence_identifier(stripped_id, stripped_lvn, stripped_sdc, is_variable)
      if is_variable
        occurrence_lvn_regex = 'occ[A-Z]of_'
        occurrence_id_regex = 'occ[A-Z]of_'
        occ_index = 3
        return handle_occurrence_var(stripped_id, stripped_lvn, occurrence_id_regex, occurrence_lvn_regex, occ_index)
      else
        occurrence_lvn_regex = 'Occurrence[A-Z]of'
        occurrence_id_regex = 'Occurrence[A-Z]_'
        occ_index = 10
      end
      # TODO: What should happen is neither @id or @lvn has occurrence label?
      # puts "Checking #{"#{occurrence_id_regex}#{stripped_sdc}"} against #{stripped_id}"
      # puts "Checking #{"#{occurrence_lvn_regex}#{stripped_sdc}"} against #{stripped_lvn}"
      if stripped_id.match(/^#{occurrence_id_regex}#{stripped_sdc}/)
        return stripped_id[occ_index]
      elsif stripped_lvn.match(/^#{occurrence_lvn_regex}#{stripped_sdc}/)
        return stripped_lvn[occ_index]
      end

      stripped_sdc[occ_index] if stripped_sdc.match(
        /(^#{occurrence_id_regex}| ^#{occurrence_id_regex}qdm_var_| ^#{occurrence_lvn_regex})| ^#{occurrence_lvn_regex}qdm_var_/)
    end

    def handle_occurrence_var(stripped_id, stripped_lvn, occurrence_id_regex, occurrence_lvn_regex, occ_index)
      # TODO: Handle specific occurrences of variables that don't self-reference?
      if stripped_id.match(/^#{occurrence_id_regex}qdm_var_/)
        return stripped_id[occ_index]
      elsif stripped_lvn.match(/^#{occurrence_lvn_regex}qdm_var/)
        return stripped_lvn[occ_index]
      end
    end
  end
end
