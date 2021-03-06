class LabResult < Entry
  field :referenceRange, as: :reference_range, type: String
  field :referenceRangeHigh, as: :reference_range_high, type: String
  field :referenceRangeLow, as: :reference_range_low, type: String
  field :interpretation, type: Hash  
  field :reaction,   type: Hash
  field :method,  type: Hash
  # The resulting status of a procedure as defined in the QDM documentation. This is different
  # than the status associated with the `Entry` object, which relates to the data criteria
  # status as defined in health-data-standards/lib/hqmf-model/data_criteria.json.
  field :qdm_status, type: Hash
  
end
