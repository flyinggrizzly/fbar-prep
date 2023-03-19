module FBARPrep
  class CSVMap
    module SpecialValueEvaluators
      module Constants
        class Null
          def evaluate
            nil
          end
        end
      end
    end
  end
end

