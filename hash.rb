class Hash
    def flatten(keyDelimiter='', entryDelimiter='')
        self.inject([]) { |a, b| a << b.join(keyDelimiter) }.join(entryDelimiter)
    end

    def flatten_css
        flattened = self.flatten(': ', ';')
        flattened + ';' if not flattened.empty?
    end
end