# This policy is broken because it violates the rule that an empty request must always be refused.

module CertmeisterPolicyHelper

  class BrokenPolicy

    def authenticate(request)
      :white_elephant
    end

  end

end

