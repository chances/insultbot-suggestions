class ERBNamespace
    def initialize(hash)
        hash.each do |key, value|
            singleton_class.send(:define_method, key) { value }
        end
    end

    def get_binding
        binding
    end
end

class String
    def erb(hash)
        template = self.to_s
        ns = ERBNamespace.new(hash)
        ERB.new(template).result(ns.get_binding)
    end
end