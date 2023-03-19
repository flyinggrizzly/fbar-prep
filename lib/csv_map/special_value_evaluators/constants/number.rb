module FBARPrep
  class CSVMap
    module SpecialValueEvaluators
      module Constants
        class Number
          def initialize(args)
            @number = Float(args)
          end

          def evaluate
            @number
          end
        end
      end
    end
  end
end
