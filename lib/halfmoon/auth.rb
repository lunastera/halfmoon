require 'digest/sha1'

module HalfMoon
  class Auth
    class << self
      def hash(user, password)
        Digest::SHA1.hexdigest("#{salt(user)}#{password}")
      end

      def salt(user)
        Digest::SHA1.hexdigest("#{user}")
      end
    end
  end
end
