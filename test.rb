class A
    attr_reader :a
    def initialize()
        @a = 3
    end
end

v = A.new()
puts v.a
